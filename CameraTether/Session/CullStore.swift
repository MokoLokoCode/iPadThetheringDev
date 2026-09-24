import Foundation
import Observation

/// One capture in the culling session.
struct Shot: Identifiable, Equatable, Sendable {
    enum State: Equatable, Sendable {
        /// In the inbox; publishes at `deadline` unless rejected first.
        case pending(deadline: Date)
        /// Copied to the outbox, so the sync client uploads it.
        case published
        /// Moved to Rejected under `storedName`; never uploaded, or withdrawn.
        case rejected(storedName: String)
    }

    let id: UUID
    /// Inbox filename. Stable for the shot's life except when a restore has to rename.
    var filename: String
    let capturedAt: Date
    var state: State
}

/// The culling session: shots arrive from a `CaptureSource`, publish after a delay
/// unless deleted, and delete is reversible (D-015). All file moves go through
/// `SessionFolders`; this type only decides when.
@MainActor
@Observable
final class CullStore {
    private(set) var folders: SessionFolders
    private let sessionsRoot: URL
    private var outboxRoot: URL
    private(set) var shots: [Shot] = []
    var selectedID: Shot.ID?
    /// While true, the newest arrival becomes the selection. Browsing back turns it off.
    var followLatest = true
    var publishDelay: TimeInterval {
        didSet { UserDefaults.standard.set(publishDelay, forKey: Keys.delay) }
    }
    var isPaused = false
    private(set) var lastError: String?

    private var watchTask: Task<Void, Never>?
    private var tickTask: Task<Void, Never>?
    private var rejectHistory: [Shot.ID] = []

    /// Reopens the last session, so a relaunch mid-event picks up where it left off.
    init(sessionsRoot: URL, defaultOutboxRoot: URL) {
        let defaults = UserDefaults.standard
        let outboxRoot = defaults.string(forKey: Keys.outboxRoot).map { URL(filePath: $0, directoryHint: .isDirectory) }
            ?? defaultOutboxRoot
        let name = defaults.string(forKey: Keys.session) ?? Self.newSessionName()
        self.sessionsRoot = sessionsRoot
        self.outboxRoot = outboxRoot
        folders = SessionFolders(name: name, sessionsRoot: sessionsRoot, outboxRoot: outboxRoot)
        defaults.set(name, forKey: Keys.session)
        let saved = UserDefaults.standard.double(forKey: Keys.delay)
        publishDelay = saved > 0 ? saved : 20
    }

    // MARK: Lifecycle

    func start() {
        guard watchTask == nil else { return }
        do { try folders.create() } catch { report(error) }
        for url in SessionFolders.captures(in: folders.rejected) {
            insert(Shot(id: UUID(), filename: url.lastPathComponent, capturedAt: Self.creationDate(url),
                        state: .rejected(storedName: url.lastPathComponent)), select: false)
        }
        let source = FolderCaptureSource(folder: folders.inbox)
        watchTask = Task { [weak self] in
            for await url in source.captures() {
                self?.arrived(url)
            }
        }
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                self?.publishDue()
                try? await Task.sleep(for: .milliseconds(250))
            }
        }
    }

    func stop() {
        watchTask?.cancel()
        tickTask?.cancel()
        watchTask = nil
        tickTask = nil
    }

    func startNewSession() {
        switchSession(to: SessionFolders(name: Self.newSessionName(), sessionsRoot: sessionsRoot, outboxRoot: outboxRoot))
    }

    /// Publishes go to `root` from now on. Shots not yet in the new folder count as waiting
    /// again and upload there after the countdown; nothing is removed from the old one.
    func changeOutboxRoot(to root: URL) {
        outboxRoot = root
        UserDefaults.standard.set(root.path, forKey: Keys.outboxRoot)
        switchSession(to: SessionFolders(name: folders.name, sessionsRoot: sessionsRoot, outboxRoot: root))
    }

    private func switchSession(to folders: SessionFolders) {
        stop()
        publishDue()
        self.folders = folders
        shots = []
        selectedID = nil
        rejectHistory = []
        followLatest = true
        UserDefaults.standard.set(folders.name, forKey: Keys.session)
        start()
    }

    // MARK: Actions

    func reject(_ id: Shot.ID) {
        guard let index = shots.firstIndex(where: { $0.id == id }), !shots[index].isRejected else { return }
        do {
            let stored = try folders.reject(shots[index].filename)
            shots[index].state = .rejected(storedName: stored)
            rejectHistory.append(id)
            if selectedID == id { selectAfterRejecting(index) }
        } catch { report(error) }
    }

    /// Brings a rejected shot back and publishes it at once: restoring is a keep decision.
    func restore(_ id: Shot.ID) {
        guard let index = shots.firstIndex(where: { $0.id == id }),
              case .rejected(let stored) = shots[index].state else { return }
        do {
            shots[index].filename = try folders.restore(stored)
            try folders.publish(shots[index].filename)
            shots[index].state = .published
            rejectHistory.removeAll { $0 == id }
        } catch { report(error) }
    }

    func undoLastReject() {
        guard let id = rejectHistory.popLast() else { return }
        restore(id)
        selectedID = id
        followLatest = false
    }

    func publishNow(_ id: Shot.ID) {
        guard let index = shots.firstIndex(where: { $0.id == id }),
              case .pending = shots[index].state else { return }
        publish(at: index)
    }

    func select(_ id: Shot.ID?) {
        selectedID = id
        followLatest = id == nil || id == shots.last?.id
    }

    func selectNeighbor(_ offset: Int) {
        guard !shots.isEmpty else { return }
        let current = selectedIndex ?? shots.count - 1
        let target = min(max(current + offset, 0), shots.count - 1)
        select(shots[target].id)
    }

    func resumeFollowing() { select(shots.last?.id) }

    func dismissError() { lastError = nil }

    // MARK: Derived

    var selectedIndex: Int? { shots.firstIndex { $0.id == selectedID } }
    var selectedShot: Shot? { selectedIndex.map { shots[$0] } }
    /// Arrivals newer than the selection while not following.
    var newerCount: Int { selectedIndex.map { shots.count - 1 - $0 } ?? 0 }
    var pendingCount: Int { shots.count { if case .pending = $0.state { true } else { false } } }
    var publishedCount: Int { shots.count { $0.state == .published } }
    var rejectedCount: Int { shots.count { if case .rejected = $0.state { true } else { false } } }

    func url(for shot: Shot) -> URL {
        if case .rejected(let stored) = shot.state { return folders.rejected.appending(path: stored) }
        return folders.inbox.appending(path: shot.filename)
    }

    // MARK: Internals

    private func arrived(_ url: URL) {
        let name = url.lastPathComponent
        guard !shots.contains(where: { $0.filename == name && !$0.isRejected }) else { return }
        let alreadyPublished = FileManager.default.fileExists(atPath: folders.outbox.appending(path: name).path)
        let state: Shot.State = alreadyPublished ? .published : .pending(deadline: .now + publishDelay)
        insert(Shot(id: UUID(), filename: name, capturedAt: Self.creationDate(url), state: state),
               select: followLatest)
    }

    private func insert(_ shot: Shot, select: Bool) {
        let index = shots.firstIndex { $0.capturedAt > shot.capturedAt } ?? shots.endIndex
        shots.insert(shot, at: index)
        if select && index == shots.endIndex - 1 { selectedID = shot.id }
    }

    private func publishDue() {
        guard !isPaused else { return }
        let now = Date.now
        let due = shots.filter { if case .pending(let deadline) = $0.state { deadline <= now } else { false } }
        for shot in due {
            if let index = shots.firstIndex(where: { $0.id == shot.id }) { publish(at: index) }
        }
    }

    private func publish(at index: Int) {
        do {
            try folders.publish(shots[index].filename)
            shots[index].state = .published
        } catch {
            // Leave it pending; the next tick retries. A missing file means it left the inbox.
            if !FileManager.default.fileExists(atPath: folders.inbox.appending(path: shots[index].filename).path) {
                shots.remove(at: index)
            }
            report(error)
        }
    }

    private func selectAfterRejecting(_ index: Int) {
        let newer = shots[(index + 1)...].first { !$0.isRejected }
        let older = shots[..<index].last { !$0.isRejected }
        selectedID = (newer ?? older)?.id ?? shots[index].id
        followLatest = selectedID == shots.last?.id
    }

    private func report(_ error: Error) {
        lastError = error.localizedDescription
    }

    private static func newSessionName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HHmm"
        return formatter.string(from: .now)
    }

    private static func creationDate(_ url: URL) -> Date {
        (try? url.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? .now
    }

    enum Keys {
        static let delay = "publishDelaySeconds"
        static let session = "lastSessionName"
        static let outboxRoot = "outboxRootPath"
    }
}

extension Shot {
    var isRejected: Bool { if case .rejected = state { true } else { false } }
}
