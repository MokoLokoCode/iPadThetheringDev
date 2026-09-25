import Combine
import CoreGraphics
import Foundation
import ImageCaptureCore

/// Read-only discovery, session and camera item/event probe.
@MainActor
final class FujifilmDiscovery: NSObject, ObservableObject, @preconcurrency ICDeviceBrowserDelegate, @preconcurrency ICCameraDeviceDelegate {
    @Published private(set) var status = "Not browsing"
    @Published private(set) var events: [CameraDiagnosticEvent] = []

    private let browser = ICDeviceBrowser()
    private var matchedDevice: ICDevice?
    private var running = false
    private var openingSession = false
    private var catalogReady = false
    private let eventLimit = 200

    func start() {
        guard !running else { return }
        running = true
        browser.delegate = self
        browser.browsedDeviceTypeMask = .camera
        status = "Searching for cameras"
        record("Browser starting (camera mask)")
        browser.start()
    }

    func stop() {
        guard running else { return }
        running = false
        browser.stop()
        browser.delegate = nil
        status = "Stopped"
        record("Browser stopped")
        if let device = matchedDevice {
            if device.hasOpenSession {
                record("Requesting camera session close")
                device.requestCloseSession()
            } else if !openingSession {
                device.delegate = nil
                matchedDevice = nil
            }
        }
    }

    var exportText: String {
        events.map { "\($0.time.formatted(date: .numeric, time: .standard)) \($0.message)" }
            .joined(separator: "\n")
    }

    func deviceBrowser(_ browser: ICDeviceBrowser, didAdd device: ICDevice, moreComing: Bool) {
        guard running else { return }
        let name = device.name ?? "unnamed camera"
        record("Device added: \(name); transport=\(device.transportType ?? "unknown"); moreComing=\(moreComing)")
        guard let camera = device as? ICCameraDevice else { return }
        if name.localizedCaseInsensitiveContains("FUJIFILM") || name.localizedCaseInsensitiveContains("X-T4") {
            guard matchedDevice == nil else {
                record("A Fujifilm session is already pending; skipping duplicate")
                return
            }
            matchedDevice = device
            catalogReady = false
            status = "Opening session with \(name)"
            camera.delegate = self
            openingSession = true
            record("Fujifilm candidate identified; requesting camera session")
            camera.requestOpenSession()
        } else {
            record("Other camera observed; no session requested")
        }
    }

    func deviceBrowser(_ browser: ICDeviceBrowser, didRemove device: ICDevice, moreGoing: Bool) {
        guard running else { return }
        record("Device removed: \(device.name ?? "unnamed camera"); moreGoing=\(moreGoing)")
        if matchedDevice === device {
            device.delegate = nil
            matchedDevice = nil
            openingSession = false
            catalogReady = false
            status = "Camera removed; searching"
        }
    }

    func device(_ device: ICDevice, didOpenSessionWithError error: (any Error)?) {
        guard matchedDevice === device else { return }
        openingSession = false
        if let error {
            status = running ? "Session failed" : "Stopped"
            record("Camera session open failed: \(error.localizedDescription)")
            if !running {
                device.delegate = nil
                matchedDevice = nil
            }
        } else {
            status = running ? "Session open with \(device.name ?? "X-T4")" : "Stopped"
            record("Camera session opened; hasOpenSession=\(device.hasOpenSession)")
            if !running {
                record("Requesting camera session close after Stop")
                device.requestCloseSession()
            }
        }
    }

    func device(_ device: ICDevice, didCloseSessionWithError error: (any Error)?) {
        guard matchedDevice === device else { return }
        record(error.map { "Camera session close failed: \($0.localizedDescription)" } ?? "Camera session closed")
        if !running {
            device.delegate = nil
            matchedDevice = nil
        }
    }

    func didRemove(_ device: ICDevice) {
        guard matchedDevice === device else { return }
        record("Camera device delegate reported removal: \(device.name ?? "X-T4")")
        device.delegate = nil
        matchedDevice = nil
        openingSession = false
        catalogReady = false
        if running { status = "Camera removed; searching" }
    }

    // MARK: - Camera catalog and event callbacks

    func deviceDidBecomeReady(withCompleteContentCatalog camera: ICCameraDevice) {
        guard matchedDevice === camera, running else { return }
        catalogReady = true
        record("Camera catalog ready; mediaFiles=\(camera.mediaFiles?.count ?? 0)")
        recordItems(camera.mediaFiles ?? [])
    }

    func cameraDevice(_ camera: ICCameraDevice, didAdd items: [ICCameraItem]) {
        guard matchedDevice === camera, running else { return }
        record("\(catalogReady ? "Items added after catalog ready" : "Catalog items added"): count=\(items.count)")
        recordItems(items)
    }

    func cameraDevice(_ camera: ICCameraDevice, didRemove items: [ICCameraItem]) {
        guard matchedDevice === camera, running else { return }
        record("Camera items removed: count=\(items.count)")
        recordItems(items)
    }

    func cameraDevice(_ camera: ICCameraDevice, didRenameItems items: [ICCameraItem]) {
        guard matchedDevice === camera, running else { return }
        record("Camera items renamed: count=\(items.count)")
        recordItems(items)
    }

    func cameraDevice(_ camera: ICCameraDevice, didReceivePTPEvent eventData: Data) {
        guard matchedDevice === camera, running else { return }
        let prefix = eventData.prefix(32).map { String(format: "%02X", $0) }.joined(separator: " ")
        record("PTP event: bytes=\(eventData.count); first32=\(prefix)")
    }

    func cameraDeviceDidChangeCapability(_ camera: ICCameraDevice) {
        guard matchedDevice === camera, running else { return }
        record("Camera capability changed")
    }

    func cameraDeviceDidEnableAccessRestriction(_ device: ICDevice) {
        guard matchedDevice === device, running else { return }
        record("Camera access restricted")
    }

    func cameraDeviceDidRemoveAccessRestriction(_ device: ICDevice) {
        guard matchedDevice === device, running else { return }
        record("Camera access restriction removed")
    }

    func cameraDevice(_ camera: ICCameraDevice, didReceiveMetadata metadata: [AnyHashable: Any]?, for item: ICCameraItem, error: (any Error)?) {
        guard matchedDevice === camera, running else { return }
        record("Metadata response: \(item.name ?? "unnamed"); error=\(error?.localizedDescription ?? "none")")
    }

    func cameraDevice(_ camera: ICCameraDevice, didReceiveThumbnail thumbnail: CGImage?, for item: ICCameraItem, error: (any Error)?) {
        guard matchedDevice === camera, running else { return }
        record("Thumbnail response: \(item.name ?? "unnamed"); error=\(error?.localizedDescription ?? "none")")
    }

    private func recordItems(_ items: [ICCameraItem]) {
        for item in items.prefix(5) {
            let kind = item is ICCameraFile ? "file" : "folder"
            record("  \(kind): \(item.name ?? "unnamed"); handle=\(item.ptpObjectHandle); uti=\(item.uti ?? "unknown")")
        }
        if items.count > 5 { record("  ... \(items.count - 5) more items omitted from log") }
    }

    private func record(_ message: String) {
        let event = CameraDiagnosticEvent(message: message)
        events.append(event)
        if events.count > eventLimit {
            events.removeFirst(events.count - eventLimit)
        }
        print("CameraTether: \(event.time.formatted(date: .numeric, time: .standard)) \(message)")
    }
}
