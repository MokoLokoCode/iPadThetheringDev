import Combine
import Foundation
import ImageCaptureCore

/// Read-only discovery and session probe. File callbacks follow after the
/// X-T4 has been observed opening a session on the physical iPad.
@MainActor
final class FujifilmDiscovery: NSObject, ObservableObject, @preconcurrency ICDeviceBrowserDelegate, @preconcurrency ICDeviceDelegate {
    @Published private(set) var status = "Not browsing"
    @Published private(set) var events: [CameraDiagnosticEvent] = []

    private let browser = ICDeviceBrowser()
    private var matchedDevice: ICDevice?
    private var running = false
    private var openingSession = false
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
        if running { status = "Camera removed; searching" }
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
