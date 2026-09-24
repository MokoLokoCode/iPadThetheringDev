import Foundation

/// The on-disk layout of one culling session (D-015).
///
/// ```
/// <sessions root>/<name>/Inbox      capture source writes here (Imaging Edge on the Mac)
/// <sessions root>/<name>/Rejected   deleted shots, kept so a delete can be undone
/// <outbox root>/<name>/             published JPEGs; a sync client (iCloud Drive) uploads it
/// ```
///
/// A shot's state is derived from where its file is, so there is no manifest to
/// corrupt and a relaunch reconstructs the session exactly.
struct SessionFolders: Sendable, Equatable {
    let name: String
    let inbox: URL
    let rejected: URL
    let outbox: URL

    init(name: String, sessionsRoot: URL, outboxRoot: URL) {
        self.name = name
        let session = sessionsRoot.appending(path: name, directoryHint: .isDirectory)
        inbox = session.appending(path: "Inbox", directoryHint: .isDirectory)
        rejected = session.appending(path: "Rejected", directoryHint: .isDirectory)
        outbox = outboxRoot.appending(path: name, directoryHint: .isDirectory)
    }

    func create() throws {
        for folder in [inbox, rejected, outbox] {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
    }

    static func isCapture(_ url: URL) -> Bool {
        let name = url.lastPathComponent
        guard !name.hasPrefix(".") else { return false }
        return ["jpg", "jpeg"].contains(url.pathExtension.lowercased())
    }

    /// JPEG filenames in `folder`, oldest first. Missing folder reads as empty.
    static func captures(in folder: URL) -> [URL] {
        let keys: [URLResourceKey] = [.creationDateKey, .isRegularFileKey]
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: folder, includingPropertiesForKeys: keys, options: [.skipsHiddenFiles]
        )) ?? []
        func created(_ url: URL) -> Date {
            (try? url.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? .distantPast
        }
        let dated: [(url: URL, date: Date)] = urls.filter(isCapture).map { ($0, created($0)) }
        let sorted = dated.sorted { lhs, rhs in
            lhs.date == rhs.date ? lhs.url.lastPathComponent < rhs.url.lastPathComponent : lhs.date < rhs.date
        }
        return sorted.map(\.url)
    }

    // MARK: - Transitions. Each one is a single move or an atomic copy.

    /// Copies an inbox shot to the outbox. Written under a hidden temporary name and
    /// renamed into place, so the sync client never uploads a partial file.
    func publish(_ filename: String) throws {
        let source = inbox.appending(path: filename)
        let destination = outbox.appending(path: filename)
        guard !FileManager.default.fileExists(atPath: destination.path) else { return }
        let temporary = outbox.appending(path: ".\(filename).\(UUID().uuidString).partial")
        try FileManager.default.copyItem(at: source, to: temporary)
        do {
            try FileManager.default.moveItem(at: temporary, to: destination)
        } catch {
            try? FileManager.default.removeItem(at: temporary)
            throw error
        }
    }

    /// Moves an inbox shot to Rejected and withdraws any published copy.
    /// Returns the filename it was stored under in Rejected.
    @discardableResult
    func reject(_ filename: String) throws -> String {
        let stored = Self.unusedName(filename, in: rejected)
        try FileManager.default.moveItem(at: inbox.appending(path: filename), to: rejected.appending(path: stored))
        let published = outbox.appending(path: filename)
        if FileManager.default.fileExists(atPath: published.path) {
            // Our own copy; the original is now in Rejected and still on the camera card.
            try FileManager.default.removeItem(at: published)
        }
        return stored
    }

    /// Moves a rejected shot back into the inbox. Returns its inbox filename.
    @discardableResult
    func restore(_ storedName: String) throws -> String {
        let name = Self.unusedName(storedName, in: inbox)
        try FileManager.default.moveItem(at: rejected.appending(path: storedName), to: inbox.appending(path: name))
        return name
    }

    /// `name`, or `name-2`, `name-3`… — never overwrites an existing file.
    static func unusedName(_ name: String, in folder: URL) -> String {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: folder.appending(path: name).path) else { return name }
        let url = URL(filePath: name)
        let stem = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        var index = 2
        while true {
            let candidate = ext.isEmpty ? "\(stem)-\(index)" : "\(stem)-\(index).\(ext)"
            if !fileManager.fileExists(atPath: folder.appending(path: candidate).path) { return candidate }
            index += 1
        }
    }
}
