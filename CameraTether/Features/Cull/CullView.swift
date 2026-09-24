import SwiftUI

/// Review-and-delete screen (D-015): the newest shot fills the window, a filmstrip runs
/// along the bottom, and every shot uploads after a countdown unless it is deleted first.
struct CullView: View {
    @Bindable var store: CullStore
    @State private var showingOutboxPicker = false

    var body: some View {
        VStack(spacing: 0) {
            SessionBar(store: store, showingOutboxPicker: $showingOutboxPicker)
            Divider()
            ShotPreview(store: store)
            Divider()
            FilmstripView(store: store)
        }
        .background(.black)
        .toolbar { toolbarContent }
        .fileImporter(isPresented: $showingOutboxPicker, allowedContentTypes: [.folder]) { result in
            if case .success(let url) = result { store.changeOutboxRoot(to: url) }
        }
        .alert("Something went wrong", isPresented: .constant(store.lastError != nil)) {
            Button("OK") { store.dismissError() }
        } message: {
            Text(store.lastError ?? "")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup {
            Button("Previous", systemImage: "chevron.left") { store.selectNeighbor(-1) }
                .keyboardShortcut(.leftArrow, modifiers: [])
            Button("Next", systemImage: "chevron.right") { store.selectNeighbor(1) }
                .keyboardShortcut(.rightArrow, modifiers: [])
            Button("Latest", systemImage: "forward.end") { store.resumeFollowing() }
                .keyboardShortcut("l", modifiers: [])
                .help("Jump to the newest shot and follow new ones (L)")
        }
        ToolbarItemGroup {
            Button("Delete", systemImage: "trash") {
                if let id = store.selectedID { store.reject(id) }
            }
            .keyboardShortcut(.delete, modifiers: [])
            .help("Delete this shot; it never uploads, or is withdrawn if it already did (Delete)")
            Button("Upload Now", systemImage: "icloud.and.arrow.up") {
                if let id = store.selectedID { store.publishNow(id) }
            }
            .keyboardShortcut(.return, modifiers: [])
            .help("Skip the countdown for this shot (Return)")
            Button("Restore", systemImage: "arrow.uturn.backward") {
                if let shot = store.selectedShot, shot.isRejected { store.restore(shot.id) } else { store.undoLastReject() }
            }
            .keyboardShortcut("z", modifiers: .command)
            .help("Restore the selected deleted shot, or the last one deleted (⌘Z)")
        }
    }
}

/// Session folders, counts, and upload controls.
private struct SessionBar: View {
    @Bindable var store: CullStore
    @Binding var showingOutboxPicker: Bool

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text(store.folders.name).font(.headline)
                HStack(spacing: 6) {
                    Text("Inbox").foregroundStyle(.secondary)
                    Button("Copy Path") { PlatformShell.copyToClipboard(store.folders.inbox.path) }
                        .help("Paste this as Imaging Edge's save folder")
                    if PlatformShell.canRevealInFileBrowser {
                        Button("Show") { PlatformShell.reveal(store.folders.inbox) }
                    }
                    Text("Uploads to").foregroundStyle(.secondary).padding(.leading, 8)
                    Text(store.folders.outbox.path.replacingOccurrences(of: URL.homeDirectory.path, with: "~"))
                        .lineLimit(1).truncationMode(.head)
                    Button("Change…") { showingOutboxPicker = true }
                }
                .font(.caption)
                .buttonStyle(.borderless)
            }
            Spacer()
            Label("\(store.pendingCount)", systemImage: "timer").help("Waiting to upload")
            Label("\(store.publishedCount)", systemImage: "checkmark.icloud").help("Uploaded")
            Label("\(store.rejectedCount)", systemImage: "trash").help("Deleted")
            Stepper("Delay \(Int(store.publishDelay)) s", value: $store.publishDelay, in: 5...120, step: 5)
                .fixedSize()
            Toggle(isOn: $store.isPaused) { Label("Pause uploads", systemImage: "pause.circle") }
                .toggleStyle(.button)
                .help("Hold every countdown; waiting shots upload when you resume")
            Button("New Session") { store.startNewSession() }
        }
        .monospacedDigit()
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.bar)
    }
}

/// The selected shot, large, with its upload state.
private struct ShotPreview: View {
    let store: CullStore
    @State private var image: CGImage?

    var body: some View {
        ZStack {
            Color.black
            if let image {
                Image(decorative: image, scale: 1)
                    .resizable()
                    .scaledToFit()
                    .opacity(store.selectedShot?.isRejected == true ? 0.35 : 1)
            } else if store.shots.isEmpty {
                ContentUnavailableView(
                    "Waiting for shots",
                    systemImage: "camera",
                    description: Text("Set Imaging Edge to save into this session's Inbox (Copy Path above).")
                )
            }
        }
        .overlay(alignment: .topLeading) {
            if let shot = store.selectedShot {
                StatusBadge(shot: shot, isPaused: store.isPaused).padding(12)
            }
        }
        .overlay(alignment: .topTrailing) {
            if !store.followLatest, store.newerCount > 0 {
                Button("\(store.newerCount) newer — L") { store.resumeFollowing() }
                    .buttonStyle(.borderedProminent)
                    .padding(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(id: store.selectedShot.map { store.url(for: $0) }) {
            guard let shot = store.selectedShot else { image = nil; return }
            image = await ImageLoader.shared.image(for: store.url(for: shot), maxPixelSize: 3000)
        }
    }
}

private struct StatusBadge: View {
    let shot: Shot
    let isPaused: Bool

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.25)) { context in
            HStack(spacing: 8) {
                Text(shot.filename).bold()
                Text(label(now: context.date))
            }
            .font(.callout.monospacedDigit())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.85), in: .capsule)
            .foregroundStyle(.white)
        }
    }

    private func label(now: Date) -> String {
        switch shot.state {
        case .pending(let deadline):
            isPaused ? "Paused" : "Uploads in \(max(0, Int(deadline.timeIntervalSince(now).rounded(.up)))) s"
        case .published: "Uploaded"
        case .rejected: "Deleted — ⌘Z to restore"
        }
    }

    private var color: Color {
        switch shot.state {
        case .pending: .orange
        case .published: .green
        case .rejected: .red
        }
    }
}
