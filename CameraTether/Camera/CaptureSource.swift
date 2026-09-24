import Foundation

/// Where finished JPEG captures come from. Brand- and platform-neutral: the culling
/// flow only ever sees complete files that have landed in the session inbox.
///
/// Implementations: `FolderCaptureSource` (another app writes the inbox — Imaging Edge
/// on the Mac, D-015). An ImageCaptureCore adapter will download into the same inbox.
protocol CaptureSource: Sendable {
    /// Yields each capture once, when its file is complete. Files already present at
    /// start are yielded first, oldest first.
    func captures() -> AsyncStream<URL>
}
