import Foundation

/// Watches a folder that another app writes captures into (D-015).
///
/// Polls rather than using file-system events: the writer may create, grow and rename
/// files in any order, and a poll only has to answer "which JPEGs are finished now?".
/// A file counts as finished once its size is unchanged across two polls and it ends
/// with the JPEG end-of-image marker.
struct FolderCaptureSource: CaptureSource {
    let folder: URL
    var interval: Duration = .milliseconds(500)

    func captures() -> AsyncStream<URL> {
        let folder = folder
        let interval = interval
        return AsyncStream { continuation in
            let task = Task {
                var yielded = Set<String>()
                var lastSizes: [String: Int] = [:]
                while !Task.isCancelled {
                    var sizes: [String: Int] = [:]
                    for url in SessionFolders.captures(in: folder) {
                        let name = url.lastPathComponent
                        guard !yielded.contains(name) else { continue }
                        let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                        sizes[name] = size
                        if size > 0, lastSizes[name] == size, Self.endsWithJPEGMarker(url) {
                            yielded.insert(name)
                            continuation.yield(url)
                        }
                    }
                    // Forget names that left the folder, so a restored file is seen again.
                    let present = Set(SessionFolders.captures(in: folder).map(\.lastPathComponent))
                    yielded.formIntersection(present)
                    lastSizes = sizes
                    try? await Task.sleep(for: interval)
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    static func endsWithJPEGMarker(_ url: URL) -> Bool {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return false }
        defer { try? handle.close() }
        guard let end = try? handle.seekToEnd(), end >= 2 else { return false }
        try? handle.seek(toOffset: end - 2)
        return handle.readData(ofLength: 2) == Data([0xFF, 0xD9])
    }
}
