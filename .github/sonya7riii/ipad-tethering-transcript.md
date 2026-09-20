# iPad Tethering App Development — extracted conversation

## User

iPad Fujifilm Tethering App — Project Context & Development Prompt

I want to build my own iPadOS tethering application for photography. Treat this conversation as an ongoing software-engineering/design project and help me architect, implement, test, and iterate on the application.

About Me

I am a Software Engineer with a B.S. in Computer Engineering. I primarily have backend/software experience and am comfortable with programming, architecture, APIs, debugging, protocols, and lower-level technical concepts.

Do not oversimplify technical explanations for me. I am comfortable reading code, documentation, API definitions, protocol specifications, logs, and debugging output.

I may not be familiar with every Apple/iOS-specific framework, Swift, SwiftUI, or camera/PTP implementation detail, so explain those concepts when relevant while assuming I have the technical background to understand them.

I want this to be a hands-on engineering project where we progressively build a working application rather than only discussing theoretical architecture.

⸻

Photography Context

My primary camera is a Fujifilm X-T4.

My tablet is an iPad Air 4th Generation with USB-C.

I also own a MacBook Pro, but the goal of this project is specifically to create a portable iPad-based tethering solution.

I primarily photograph:

* Headshots
* Portraits
* Engagement sessions
* Graduation sessions
* Weddings

I shoot more outdoors/on-location than in a permanent studio.

For lighting, I use Godox equipment including an AD200 Pro and a Godox iT30 Pro Mini for Fujifilm.

I currently use Adobe Lightroom for my photography workflow.

I’ve investigated existing iPad tethering solutions including:

* Evoto
* Capture One Mobile
* Cascable Studio
* Fujifilm XApp
* Adobe Lightroom for iPad

Evoto is currently interesting because it supports wired tethering from the X-T4 to an iPad. However, Evoto uses a credit system for exporting AI-edited images.

Rather than depending entirely on another service, I want to explore building a lightweight tethering application tailored specifically to my workflow.

⸻

Primary Problem

I want to connect:

Fujifilm X-T4 → USB-C → iPad Air 4

When I press the shutter button on the X-T4, I want the resulting photograph to automatically appear on the iPad.

The iPad should essentially become a portable client-review monitor.

The initial application does NOT need to replace Lightroom.

I will continue using Lightroom for my final RAW processing, editing, organization, and delivery.

The purpose of this application is primarily:

Capture → Immediate Preview → Review → Client Selection

⸻

Important Technical Context

The Fujifilm X-T4 supports USB tethered shooting modes such as USB TETHER SHOOTING AUTO/FIXED.

Apple provides the ImageCaptureCore framework on iPadOS for communicating with cameras.

Relevant Apple APIs/framework concepts may include:

* ImageCaptureCore
* ICDeviceBrowser
* ICCameraDevice
* ICCameraDeviceDelegate
* ICCameraFile
* PTP / Picture Transfer Protocol
* Camera event handling
* USB camera communication
* requestTakePicture()
* requestSendPTPCommand(...)
* PTP event handling

I want us to investigate what functionality Apple officially exposes on current iPadOS versions and what functionality the Fujifilm X-T4 exposes through standard PTP versus Fujifilm-specific PTP extensions.

Do not assume an API supports something just because it theoretically should. Verify against current Apple/Fujifilm documentation when we’re making implementation decisions.

⸻

MVP — Version 1

Keep the first version intentionally simple.

The camera should continue doing the actual photography.

The application should:

1. Detect when my Fujifilm X-T4 is connected over USB-C.
2. Establish communication with the camera.
3. Detect when I take a new photograph using the camera’s physical shutter button.
4. Automatically transfer the newly captured image to the iPad.
5. Display the newest photograph prominently.
6. Maintain a filmstrip/gallery of photographs captured during the session.
7. Allow me or the client to zoom into the photograph to inspect focus.
8. Allow photographs to be marked as favorites/selections.
9. Maintain those selections for the current session.
10. Export or display a list of selected filenames.

Example:

DSCF4127.RAF
DSCF4132.RAF
DSCF4145.RAF

I can then use those filenames later to find/filter the corresponding RAW files in Lightroom.

⸻

RAW + JPEG Strategy

For the MVP, I do NOT want to build a RAW processing engine.

Instead, assume I configure the X-T4 to shoot:

RAW + JPEG

Ideally:

* RAW remains on the X-T4 SD card for Lightroom.
* JPEG transfers to the iPad for fast previews.

If there is a better implementation strategy based on how Fujifilm/PTP exposes files, explain it.

Preview latency is more important than transferring maximum-quality files.

The goal should be for the image to appear on the iPad as quickly as reasonably possible after pressing the shutter.

⸻

Initial UI Concept

The main shooting interface should be extremely photography-focused.

Something conceptually like:

                 X-T4
                   │
                USB-C
                   │
                   ▼
            iPad Application
 ┌─────────────────────────────┐
 │                             │
 │                             │
 │       LARGE PHOTO           │
 │         PREVIEW             │
 │                             │
 │                             │
 ├─────────────────────────────┤
 │ Previous images / filmstrip │
 └─────────────────────────────┘

Primary interactions:

* Swipe between photographs
* Pinch to zoom
* Double-tap to inspect focus
* ⭐ Favorite
* ❤️ Client selection
* Compare photographs
* Return automatically to newest capture

Keep controls minimal while I’m actively shooting.

⸻

Client Mode

Eventually I would like a dedicated Client Mode.

Client Mode should hide technical/camera controls and give the client a very simple interface.

For example:

Previous ← | ❤️ Favorite | → Next

The client should be able to review images and select favorites without accidentally changing camera/application settings.

At the end of the session I want something like:

127 photographs captured

14 selected

Then I can export/copy the selected filenames.

⸻

Potential Future Features

Do NOT try to implement all of these in V1.

Keep the architecture extensible enough that we could investigate them later.

Potential future features include:

* Side-by-side A/B comparison
* 2-image comparison
* 4-image comparison
* Star ratings
* Color labels
* Reject flag
* Focus checking
* Histogram
* Highlight/shadow clipping warnings
* EXIF display
* Aperture display
* Shutter speed display
* ISO display
* Camera battery level
* Remaining SD-card capacity
* Session management
* Client names
* Shoot names
* Automatic session folders
* Multiple-client selections
* Selection export
* CSV export
* Lightroom-friendly selection workflow
* Share selected previews
* AirDrop
* External display support
* Apple Pencil annotations
* Before/after comparison
* LUT/preset preview
* Local lightweight JPEG adjustments

Eventually we could investigate whether camera controls are possible:

* Aperture
* Shutter speed
* ISO
* White balance
* Exposure compensation
* Trigger shutter from iPad
* Live View

These should NOT block development of the basic tethering/preview application.

⸻

PTP / Fujifilm Investigation

One of the most important engineering questions is determining what the X-T4 exposes through:

Standard PTP

versus

Fujifilm proprietary/vendor-specific PTP extensions.

If necessary, I am willing to investigate/debug the USB/PTP communication.

If we eventually need to inspect commands/events sent between Fujifilm software and the X-T4, explain the legal/safe technical options for doing so.

However, prefer documented Apple/Fujifilm APIs and standard PTP functionality whenever possible.

⸻

Architecture Priorities

Optimize for:

1. Reliability
2. Fast image appearance
3. Simple shooting experience
4. Wired USB stability
5. Low memory usage
6. Efficient handling of hundreds of photographs
7. Recovering gracefully from camera disconnect/reconnect
8. Keeping RAW files safe on the camera
9. Avoiding interruption of normal X-T4 operation

Assume a typical session could contain anywhere from:

50–1,000+ photographs.

Do not load every full-resolution image into RAM simultaneously.

Use appropriate caching, thumbnails, asynchronous loading, and storage strategies.

⸻

Technology

I expect the application will likely use:

* Swift
* SwiftUI
* ImageCaptureCore
* Apple’s photo/image frameworks
* async/await where appropriate

However, I don’t want us to blindly choose technology.

If UIKit, Core Image, Metal, SQLite/SwiftData, or another framework makes more sense for a particular component, explain why.

⸻

Development Philosophy

I want to build this incrementally.

Do NOT dump an entire finished application on me at once.

Treat this like we’re developing a real software project together.

For each stage:

1. Explain what we’re trying to accomplish.
2. Explain the relevant Apple/camera architecture.
3. Show the implementation.
4. Explain important parts of the code.
5. Tell me how to run/test it.
6. Tell me what behavior I should expect.
7. Give me debugging steps if it doesn’t work.
8. Wait for my results before moving to hardware-dependent assumptions.

I can provide:

* Compiler errors
* Console logs
* Xcode screenshots
* Camera behavior
* USB connection behavior
* PTP responses
* Crash logs

Use those results to iterate.

⸻

Development Environment

Assume I have:

* Fujifilm X-T4
* iPad Air 4th Gen
* USB-C connectivity
* MacBook Pro
* Xcode or the ability to install/use the current Xcode release
* Apple developer tooling

If an Apple Developer Program membership becomes necessary, tell me exactly when and why rather than assuming I need a paid membership from the beginning.

⸻

First Objective

Start by helping me validate the lowest-level assumption of the entire project:

Can an iPadOS application using Apple’s currently available APIs detect my Fujifilm X-T4 over USB and receive notification/access when a new photograph is captured?

Before designing the entire application, let’s build the smallest possible proof of concept.

Something like:

X-T4 connected → app recognizes camera → console displays camera information → take photo on X-T4 → app detects new file/event → print filename to console.

Once that works, the next milestone should be:

Automatically download and display that JPEG on the iPad.

After that works reliably, we can begin building the actual UI, session management, client-selection system, and other features.

Please begin by researching/verifying the current Apple APIs and X-T4 compatibility relevant to this proof of concept, then propose the smallest sensible Xcode project structure and walk me through building the first hardware test.

---

## Assistant

Yes—the lowest-level approach is viable enough to justify a hardware proof of concept.

Apple officially exposes ImageCaptureCore on iPadOS 13+, including:

- USB camera discovery through `ICDeviceBrowser`
- Opening a camera session
- Enumerating camera media
- Receiving `ICCameraDeviceDelegate` notifications when objects are added
- Sending raw PTP commands when necessary

However, Apple does not publish a camera-by-camera compatibility list, and Fujifilm only documents automatic tether downloads with specific desktop applications. Therefore, we still need to establish whether the X‑T4 exposes newly captured files to ImageCaptureCore while operating in `USB TETHER SHOOTING AUTO`. [ICDeviceBrowser](https://developer.apple.com/documentation/imagecapturecore/icdevicebrowser), [ICCameraDeviceDelegate](https://developer.apple.com/documentation/imagecapturecore/iccameradevicedelegate), [Fujifilm X‑T4 USB documentation](https://fujifilm-dsc.com/en/manual/x-t4/connections/computer/index.html)

## Important X-T4 caveat

Fujifilm separates two materially different USB behaviors:

| X-T4 mode | Expected behavior | Value to our test |
|---|---|---|
| `USB CARD READER` | Exposes files already stored on the SD card | Confirms iPad/ImageCaptureCore can recognize and enumerate the camera |
| `USB TETHER SHOOTING AUTO` | Enters tether mode when a compatible host opens communication | Tests whether physical-shutter captures generate accessible PTP objects |
| `USB TETHER SHOOTING FIXED` | Camera remains in tether mode even after disconnect | Avoid initially; images may not be recorded to the card |
| `USB RAW CONV./BACKUP RESTORE` | Fujifilm RAW conversion/backup protocol | Not relevant to the MVP |

Fujifilm explicitly warns that in tethered mode—especially `FIXED`—pictures are not necessarily recorded to the memory card under default settings. We must verify card behavior before shooting anything important. [Fujifilm Connection Settings](https://fujifilm-dsc.com/en/manual/x-t4/menu_setup/connection_setting/index.html)

For the first experiment, use a blank/test SD card and unimportant photographs.

## Proof-of-concept scope

The first application should answer these questions separately:

1. Does iPadOS discover the X-T4?
2. Can it open an ImageCaptureCore session?
3. Does the camera expose a media catalog?
4. In tether mode, does pressing the physical shutter produce:
   - `didAdd` with an `ICCameraFile`,
   - a raw PTP event,
   - both,
   - or nothing?
5. Does the JPEG appear as a separate object when shooting RAW+JPEG?
6. Is the RAW/JPEG retained on the SD card?

We should not download anything yet. That keeps the first diagnostic clean.

# Create the Xcode project

Create a new project:

- Template: **iOS → App**
- Product name: `FujiTetherProbe`
- Interface: **SwiftUI**
- Language: **Swift**
- Storage: None
- Deployment target: your iPad’s installed iPadOS version, or a reasonably recent baseline such as iPadOS 17

ImageCaptureCore requires a physical device. This will not produce meaningful results in the simulator.

You do not need a paid Apple Developer Program membership for this experiment. A normal Apple ID can install a development build on your own iPad through Xcode. Free provisioning is temporary and has limitations, but it is adequate here. Paid membership becomes relevant for TestFlight, App Store distribution, longer-lived signing, or distribution to other people.

Use this structure:

```text
FujiTetherProbe/
├── FujiTetherProbeApp.swift
├── ContentView.swift
└── CameraProbe.swift
```

# 1. CameraProbe.swift

Add a new Swift file:

```swift
@preconcurrency import ImageCaptureCore
import Foundation
import Combine

final class CameraProbe: NSObject, ObservableObject {
    @Published private(set) var status = "Not started"
    @Published private(set) var events: [String] = []

    private let browser = ICDeviceBrowser()
    private var camera: ICCameraDevice?
    private var receivedCompleteCatalog = false

    override init() {
        super.init()

        browser.delegate = self
        browser.browsedDeviceTypeMask = .camera
    }

    func start() {
        log("Starting ImageCaptureCore device browser")
        status = "Searching for camera…"
        browser.start()
    }

    func stop() {
        browser.stop()

        if let camera, camera.hasOpenSession {
            camera.requestCloseSession()
        }

        camera = nil
        status = "Stopped"
        log("Device browser stopped")
    }

    private func log(_ message: String) {
        let timestamp = Date.now.formatted(
            .dateTime
                .hour(.twoDigits(amPM: .omitted))
                .minute(.twoDigits)
                .second(.twoDigits)
        )

        let line = "\(timestamp)  \(message)"

        print("[FujiTetherProbe] \(line)")

        // ImageCaptureCore normally delivers these delegate callbacks on
        // the main thread, but keep UI mutation defensive.
        if Thread.isMainThread {
            events.insert(line, at: 0)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.events.insert(line, at: 0)
            }
        }
    }
}

// MARK: - Device discovery

extension CameraProbe: ICDeviceBrowserDelegate {
    func deviceBrowser(
        _ browser: ICDeviceBrowser,
        didAdd device: ICDevice,
        moreComing: Bool
    ) {
        log("""
            Device discovered:
              name: \(device.name)
              type: \(device.type)
              transport: \(String(describing: device.transportType))
            """)

        guard let camera = device as? ICCameraDevice else {
            log("Discovered device is not an ICCameraDevice")
            return
        }

        self.camera = camera
        camera.delegate = self

        status = "Opening \(camera.name)…"
        log("Requesting camera session")
        camera.requestOpenSession()
    }

    func deviceBrowser(
        _ browser: ICDeviceBrowser,
        didRemove device: ICDevice,
        moreGoing: Bool
    ) {
        log("Device removed: \(device.name)")

        if device === camera {
            camera = nil
            receivedCompleteCatalog = false
            status = "Camera disconnected"
        }
    }
}

// MARK: - General device lifecycle

extension CameraProbe: ICDeviceDelegate {
    func device(
        _ device: ICDevice,
        didOpenSessionWithError error: Error?
    ) {
        if let error {
            status = "Session failed"
            log("SESSION OPEN ERROR: \(error)")
        } else {
            status = "Connected: \(device.name)"
            log("Camera session opened successfully")
        }
    }

    func device(
        _ device: ICDevice,
        didCloseSessionWithError error: Error?
    ) {
        if let error {
            log("SESSION CLOSE ERROR: \(error)")
        } else {
            log("Camera session closed")
        }
    }

    func deviceDidBecomeReady(_ device: ICDevice) {
        log("Device became ready: \(device.name)")
    }

    func device(
        _ device: ICDevice,
        didEncounterError error: Error?
    ) {
        log("DEVICE ERROR: \(String(describing: error))")
    }

    func device(
        _ device: ICDevice,
        didReceiveStatusInformation status: [ICDeviceStatus: Any]
    ) {
        log("Device status: \(status)")
    }
}

// MARK: - Camera events

extension CameraProbe: ICCameraDeviceDelegate {
    func deviceDidBecomeReady(
        withCompleteContentCatalog device: ICCameraDevice
    ) {
        receivedCompleteCatalog = true

        let fileCount = device.mediaFiles?.count ?? 0

        status = "Ready: \(device.name)"
        log("Complete media catalog received: \(fileCount) files")
    }

    func cameraDevice(
        _ camera: ICCameraDevice,
        didAdd items: [ICCameraItem]
    ) {
        let phase = receivedCompleteCatalog ? "NEW" : "CATALOG"

        for item in items {
            if let file = item as? ICCameraFile {
                log("""
                    \(phase) FILE:
                      name: \(file.name)
                      size: \(file.fileSize)
                      UTI: \(String(describing: file.uti))
                    """)
            } else {
                log("\(phase) ITEM: \(item.name) [\(type(of: item))]")
            }
        }
    }

    func cameraDevice(
        _ camera: ICCameraDevice,
        didRemove items: [ICCameraItem]
    ) {
        for item in items {
            log("REMOVED ITEM: \(item.name)")
        }
    }

    func cameraDevice(
        _ camera: ICCameraDevice,
        didReceivePTPEvent eventData: Data
    ) {
        let hex = eventData
            .map { String(format: "%02X", $0) }
            .joined(separator: " ")

        log("PTP EVENT [\(eventData.count) bytes]: \(hex)")
    }
}
```

The distinction between `CATALOG FILE` and `NEW FILE` matters. When the session initially opens, ImageCaptureCore can report existing objects while building the camera catalog. Only additions after `receivedCompleteCatalog` becomes true should initially be treated as new captures.

Apple’s current API exposes the `didAdd` callback as an array of items. If the Xcode SDK you have installed presents a slightly different imported method name, use Xcode’s protocol-conformance fix-it as the authority; Apple has changed some Swift imports across SDK generations.

# 2. ContentView.swift

Replace the generated view:

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var probe = CameraProbe()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 12, height: 12)

                    Text(probe.status)
                        .font(.headline)

                    Spacer()
                }

                if probe.events.isEmpty {
                    ContentUnavailableView(
                        "Waiting for Camera",
                        systemImage: "camera",
                        description: Text(
                            "Connect the Fujifilm X-T4 over USB-C."
                        )
                    )
                } else {
                    List(probe.events, id: \.self) { event in
                        Text(event)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
            .navigationTitle("Fuji Tether Probe")
        }
        .onAppear {
            probe.start()
        }
        .onDisappear {
            probe.stop()
        }
    }

    private var statusColor: Color {
        probe.status.hasPrefix("Ready") ||
        probe.status.hasPrefix("Connected")
            ? .green
            : .orange
    }
}
```

Leave the generated app entry point essentially unchanged:

```swift
import SwiftUI

@main
struct FujiTetherProbeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

# Build and signing

In Xcode:

1. Select the project.
2. Open **Signing & Capabilities**.
3. Select your Apple ID development team.
4. Give the app a unique bundle identifier, such as:
   `com.yourname.FujiTetherProbe`
5. Connect the iPad to the Mac.
6. Select the physical iPad as the run destination.
7. Build and run.

If the iPad asks whether to allow the app to access the connected camera or storage, allow it. ImageCaptureCore may present its own content-access authorization prompt; this is separate from permission to use the iPad’s built-in camera.

The app does not use `AVCaptureDevice`, so we should not add `NSCameraUsageDescription` merely to silence hypothetical warnings. If the installed SDK explicitly requests a privacy key at runtime, capture the exact console message and we will add the documented key it names.

# Hardware test procedure

## Test A: Establish basic PTP visibility

Configure the X-T4:

- Insert a test SD card containing a few images.
- Set `D → CONNECTION SETTING → CONNECTION MODE`
  to `USB CARD READER`.
- Set `USB POWER SUPPLY SETTING` to `OFF` initially.
- Use a known data-capable USB-C cable.
- Fully charge the X-T4 battery.
- Turn the X-T4 off.
- Connect it directly to the iPad.
- Turn the X-T4 on.

Fujifilm recommends a data-capable cable no longer than 1.5 m and a direct connection. For this test, avoid hubs. [X‑T4 USB instructions](https://fujifilm-dsc.com/en/manual/x-t4/connections/computer/index.html)

Expected output:

```text
Starting ImageCaptureCore device browser
Device discovered:
  name: X-T4
  ...
Requesting camera session
Camera session opened successfully
Device became ready: X-T4
CATALOG FILE: DSCF4127.JPG
CATALOG FILE: DSCF4127.RAF
Complete media catalog received: ...
```

The precise device name and callback order may vary.

This test does not prove tethering, but it proves the entire iPad → USB → PTP → ImageCaptureCore discovery path.

## Test B: Physical-shutter tether experiment

Disconnect safely and turn the camera off. Then set:

- `IMAGE QUALITY`: `FINE+RAW` or `NORMAL+RAW`
- `CONNECTION MODE`: `USB TETHER SHOOTING AUTO`
- `USB POWER SUPPLY SETTING`: `OFF`
- `AUTO POWER OFF`: `OFF` for testing

Reconnect, run the app, and wait until it reports the camera ready. Then press the physical shutter once.

Watch both the in-app log and Xcode console.

The ideal result is:

```text
PTP EVENT [...]
NEW FILE:
  name: DSCF4128.JPG
  size: ...
```

You might instead see:

1. JPEG only
2. RAW and JPEG
3. A temporary/unnamed object followed by a rename
4. A PTP event but no `didAdd`
5. No media catalog in tether mode
6. The device failing to open a session
7. The camera being discovered only in card-reader mode

Each outcome gives us a specific next step.

# How to interpret the result

| Result | Meaning | Next action |
|---|---|---|
| Discovery + new JPEG in tether mode | Best case: V1 can probably remain mostly within public ImageCaptureCore APIs | Add JPEG download |
| Discovery + RAW and JPEG | Filter by extension/UTI and download only JPEG | Add JPEG download |
| Discovery + PTP event but no file | X-T4 is signaling the capture, but file retrieval may require Fujifilm-specific object handling | Decode the event payload |
| Discovery only in card-reader mode | Generic PTP import works, but Fujifilm tether mode is using a different/vendor-specific session | Inspect capabilities and PTP operations |
| Session opens but shutter capture is not stored | Camera is operating in host-transfer-only mode | Investigate Fujifilm save-to-card behavior |
| No discovery in any mode | USB negotiation, cable, power, permission, or iPadOS compatibility problem | Test Photos import and inspect logs |

Also verify the SD card immediately after Test B:

- Was `DSCF4128.RAF` saved?
- Was `DSCF4128.JPG` saved?
- Did the filename reported to the iPad match the card filename?

That determines whether the desired “RAW stays on the card, JPEG transfers to iPad” design is available directly or needs a different transfer strategy.

## What not to add yet

For this milestone, do not use:

- `requestTakePicture()`
- `requestSendPTPCommand(...)`
- File download APIs
- Fujifilm vendor opcodes
- SwiftData
- Photo-library access
- RAW decoding
- A full gallery UI

The physical-shutter `didAdd` result is the decision gate. If it works, our next milestone is small: filter for JPEG, download it to an application-support session directory, and display it. If it does not, the raw PTP-event log tells us whether the next investigation belongs at the event, command, or USB-mode layer.

---

## User

Now that we have an understanding of what needs to be done. I want to create design docs that I can pass to another AI agent to complete the work. The ideal structure should all be in Markdown file type. We will have a Decisions file to have a track of where we deviate, status so we can understand where we stand, progress a file where we list our work items to tackle, a readme to store all our context for easy and fast loading. Lastly if you think we need an architecture file to have a visual representation of how our app will be then add that as well. 

How does this sound to you? Also I am open to suggestions and places to improve

---

## Assistant

That’s a solid approach. I’d organize it as an **agent handoff package**: enough context for another agent to work independently, with explicit boundaries around what still needs hardware validation.

The main improvement is giving each file a distinct responsibility so they don’t become overlapping summaries.

## Recommended structure

| File | Purpose | Contents |
|---|---|---|
| `README.md` | Fast project orientation | Problem, your equipment, intended workflow, MVP scope, non-goals, documentation map, and reading order |
| `ARCHITECTURE.md` | Technical design | Component responsibilities, capture-to-preview flow, storage, concurrency, memory limits, disconnect handling, and Mermaid diagrams |
| `DECISIONS.md` | Decision history | Accepted decisions, alternatives, rationale, deviations, and decisions superseded later |
| `STATUS.md` | Current checkpoint | What actually works, what is unverified, blockers, environment versions, last test results, and the immediate next action |
| `PROGRESS.md` | Work backlog | Milestones and work items with stable IDs, dependencies, acceptance criteria, and completion evidence |
| `AGENTS.md` | Instructions for the implementing agent | Reading order, engineering rules, scope boundaries, validation requirements, and when to stop and ask you |
| `VALIDATION.md` | Reproducible testing | Hardware setup, test procedures, expected observations, failure interpretation, and safety checks |

I’d start with those seven Markdown files. No need for a larger documentation system yet.

## Important improvements

### 1. Separate “planned” from “proven”

This is especially important for this project.

Our current state is:

- Relevant Apple APIs have been identified.
- A preliminary proof-of-concept implementation has been proposed.
- That implementation has **not been compiled or hardware-tested here**.
- Physical-shutter notifications, JPEG access, and RAW retention on the X‑T4 remain unverified.

The documents must preserve those distinctions. Another agent should not interpret an architectural assumption as confirmed camera behavior.

### 2. Make hardware validation a gate

The backlog should enforce this sequence:

1. Compile the diagnostic app.
2. Verify device discovery and session opening.
3. Verify physical-shutter events and accessible files.
4. Verify RAW/JPEG retention on the SD card.
5. Download and display a JPEG.
6. Build session browsing and selections.

The agent can implement independently where appropriate, but must stop for your hardware results before making dependent assumptions.

### 3. Keep status, progress, and decisions separate

- **Status:** “Where are we right now?”
- **Progress:** “What work remains, and how do we know it is done?”
- **Decisions:** “Why did we choose this approach?”

Completed work should reference test evidence—not just a checked box.

### 4. Keep the README short

Use it as an entry point, not a transcript dump. Preserve detailed requirements in the relevant documents and link to them.

My recommendation is to create this package as **a staged engineering specification, not a promise of a finished architecture**. That gives the next agent clear implementation instructions while allowing the camera tests to change the design responsibly.

---

## User

I like those suggestions can you do this for me

---

## Assistant

Created the complete handoff package: [fuji-tether-design.zip](sandbox:/workspace/scratch/3ec4d3e9947b/fuji-tether-design.zip).

It contains seven Markdown files:

- [README.md](sandbox:/workspace/scratch/3ec4d3e9947b/fuji-tether-design/README.md) — context and reading order
- [AGENTS.md](sandbox:/workspace/scratch/3ec4d3e9947b/fuji-tether-design/AGENTS.md) — implementation rules and stop conditions
- [STATUS.md](sandbox:/workspace/scratch/3ec4d3e9947b/fuji-tether-design/STATUS.md) — current checkpoint
- [PROGRESS.md](sandbox:/workspace/scratch/3ec4d3e9947b/fuji-tether-design/PROGRESS.md) — work items and acceptance criteria
- [ARCHITECTURE.md](sandbox:/workspace/scratch/3ec4d3e9947b/fuji-tether-design/ARCHITECTURE.md) — technical design and diagrams
- [DECISIONS.md](sandbox:/workspace/scratch/3ec4d3e9947b/fuji-tether-design/DECISIONS.md) — rationale and deviation tracking
- [VALIDATION.md](sandbox:/workspace/scratch/3ec4d3e9947b/fuji-tether-design/VALIDATION.md) — tests and evidence templates

The documents explicitly mark hardware assumptions as unverified and require RAW-retention checks before advancing.

Extract them into your project root. The next agent should start with `README.md` and work item **P-010: environment and SDK verification**.
