import CoreGraphics
import Foundation
import ImageIO

/// Decodes downsampled, orientation-corrected images off the main actor and keeps a
/// bounded cache, so memory follows what is on screen rather than shots taken (D-009).
@MainActor
final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSString, CGImageBox>()

    private init() {
        cache.countLimit = 400
    }

    func image(for url: URL, maxPixelSize: Int) async -> CGImage? {
        let key = "\(maxPixelSize)|\(url.path)" as NSString
        if let hit = cache.object(forKey: key) { return hit.image }
        let decoded = await Task.detached(priority: .userInitiated) {
            Self.decode(url, maxPixelSize: maxPixelSize).map(CGImageBox.init)
        }.value
        if let decoded { cache.setObject(decoded, forKey: key) }
        return decoded?.image
    }

    nonisolated static func decode(_ url: URL, maxPixelSize: Int) -> CGImage? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary)
        else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
            kCGImageSourceShouldCacheImmediately: true,
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }
}

final class CGImageBox: @unchecked Sendable {
    let image: CGImage
    init(_ image: CGImage) { self.image = image }
}
