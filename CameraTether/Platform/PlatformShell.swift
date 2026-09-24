import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// The platform seam (D-014). `#if os(...)` belongs here and in other `Platform/` files,
/// never in the session, camera, or feature code.
@MainActor
enum PlatformShell {
    /// Where session folders (Inbox, Rejected) are created.
    static var sessionsRoot: URL {
        #if os(macOS)
        URL.picturesDirectory.appending(path: "CameraTether", directoryHint: .isDirectory)
        #else
        URL.documentsDirectory.appending(path: "Sessions", directoryHint: .isDirectory)
        #endif
    }

    /// Default publish destination: a folder the platform's sync client uploads.
    static var defaultOutboxRoot: URL {
        #if os(macOS)
        URL.homeDirectory
            .appending(path: "Library/Mobile Documents/com~apple~CloudDocs/CameraTether", directoryHint: .isDirectory)
        #else
        URL.documentsDirectory.appending(path: "Outbox", directoryHint: .isDirectory)
        #endif
    }

    static var canRevealInFileBrowser: Bool {
        #if os(macOS)
        true
        #else
        false
        #endif
    }

    static func reveal(_ url: URL) {
        #if os(macOS)
        NSWorkspace.shared.activateFileViewerSelecting([url])
        #endif
    }

    static func copyToClipboard(_ text: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #else
        UIPasteboard.general.string = text
        #endif
    }
}
