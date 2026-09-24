import Combine
import Foundation
import ImageCaptureCore

/// Read-only discovery. A camera session and file callbacks follow after the
/// X-T4 has been observed on the physical iPad in USB CARD READER mode.
@MainActor
final class FujifilmDiscovery: NSObject, ObservableObject, @preconcurrency ICDeviceBrowserDelegate {
    @Published private(set) var status = "Not browsing"
    @Published private(set) var events: [CameraDiagnosticEvent] = []

    private let browser = ICDeviceBrowser()
    private var matchedDevice: ICDevice?
    private var running = false
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
        matchedDevice = nil
        status = "Stopped"
        record("Browser stopped")
    }

    var exportText: String {
        events.map { "\($0.time.formatted(date: .numeric, time: .standard)) \($0.message)" }
            .joined(separator: "\n")
    }

    func deviceBrowser(_ browser: ICDeviceBrowser, didAdd device: ICDevice, moreComing: Bool) {
        guard running else { return }
        let name = device.name ?? "unnamed camera"
        record("Device added: \(name); transport=\(device.transportType ?? "unknown"); moreComing=\(moreComing)")
        guard device is ICCameraDevice else { return }
        if name.localizedCaseInsensitiveContains("FUJIFILM") || name.localizedCaseInsensitiveContains("X-T4") {
            matchedDevice = device
            status = "Discovered \(name)"
            record("Fujifilm candidate identified; session not opened yet")
        } else {
            record("Other camera observed; no session requested")
        }
    }

    func deviceBrowser(_ browser: ICDeviceBrowser, didRemove device: ICDevice, moreGoing: Bool) {
        guard running else { return }
        record("Device removed: \(device.name ?? "unnamed camera"); moreGoing=\(moreGoing)")
        if matchedDevice === device {
            matchedDevice = nil
            status = "Camera removed; searching"
        }
    }

    func deviceBrowserDidEnumerateLocalDevices(_ browser: ICDeviceBrowser) {
        guard running else { return }
        record("Initial local camera enumeration completed")
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
