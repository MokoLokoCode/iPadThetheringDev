# Run the first CameraTether build

This increment supplies a shared SwiftUI iPad application, not camera detection.
The screen says **CameraTether is running** and explicitly states that camera
connection is not implemented. Connecting a camera will have no effect yet.

## Get the project on your Mac

If you already cloned the repository, run these from its directory after saving
any local work:

```bash
git fetch origin
git switch --track origin/mario/cameratether-bootstrap
open CameraTether.xcodeproj
```

If you already have that local branch, use `git switch mario/cameratether-bootstrap`
instead. For a fresh clone:

```bash
git clone --branch mario/cameratether-bootstrap https://github.com/MokoLokoCode/iPadThetheringDev.git
cd iPadThetheringDev
open CameraTether.xcodeproj
```

Open the checked-in project directly. Do not create another Xcode project or copy
these files into a second repository. All changes stay on a feature branch and
go through a PR; this bootstrap PR must not be merged automatically.

## Toolchain and settings

Use a stable Xcode with Swift 6 support (Xcode 16 or later), compatible with your
Mac and installed iPadOS. A newer device OS may require a newer Xcode. Record:

```bash
xcodebuild -version
xcrun swift --version
xcodebuild -showsdks
```

| Setting | Checked-in value |
| --- | --- |
| Project, app target, shared scheme | `CameraTether` |
| Destinations | iPad and iPad simulator |
| Minimum deployment target | iPadOS 17.0; provisional until your iPad version is recorded |
| Language | Swift 6; no concurrency suppression or default-isolation override |
| Configurations | Debug and Release |
| Signing | Automatic; no development team checked in |
| Bundle identifier | `com.example.CameraTether`; replace for device signing |
| Dependencies, camera permissions, entitlements | None in this launch-only build |

The `.xcodeproj` is the only app build definition. Its older project-file format
does not lower the Swift 6 compiler requirement. There is no package manifest or
project generator. Xcode generates Info.plist and the launch screen from build
settings. A custom app icon and test target are deferred; this build has no
application logic to unit-test and is not a distribution-ready archive.

## Simulator first

1. Open Xcode and let it install any requested iOS platform components.
2. Select the **CameraTether** scheme and an installed **iPad** simulator.
3. Press **Command-R**.
4. Expect the setup screen. Rotate the simulator and check that its text remains readable.

For a compile-only check with no signing:

```bash
xcodebuild -project CameraTether.xcodeproj -scheme CameraTether -list
xcodebuild -project CameraTether.xcodeproj -scheme CameraTether \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
```

This command compiles; it does not launch a simulator. There is no automated test
target yet, so do not use an empty test run as evidence that the app works.

## Install on your iPad

1. Connect the iPad to your Mac, unlock it, and accept any device trust prompts.
2. In Xcode Settings, add your Apple Account if necessary.
3. Select the project, then **TARGETS → CameraTether → Signing & Capabilities**.
4. Keep automatic signing enabled and select your team. A Personal Team can be
   used for this owned-device development build.
5. Replace `com.example.CameraTether` with a unique identifier for your team,
   such as `com.mariopalacios.CameraTether.dev` if available. Apply it to both
   Debug and Release. The example does not claim ownership of a domain or App ID.
6. Select the physical iPad as the run destination. Follow Xcode's pairing and
   Developer Mode instructions if prompted, then press **Command-R**.
7. Confirm the setup screen appears. This test does not need the camera attached.

Team and bundle identifier edits are local signing setup, not evidence of camera
compatibility. Review those diffs before including them in a shared PR.

## If it fails

| Symptom | Next check |
| --- | --- |
| `xcodebuild` requires Xcode or uses Command Line Tools | Select your full Xcode installation under Xcode Settings → Locations → Command Line Tools |
| No iPad simulator destination | Install an iOS simulator runtime in Xcode Settings and create/select an iPad simulator |
| Signing needs a team / identifier is unavailable | Select your team and choose a unique bundle identifier on the app target |
| Physical iPad is unavailable | Check pairing, trust, Developer Mode, installed iPadOS, and whether Xcode supports that OS |
| Project parsing or Swift compiler error | Send the first exact error plus Xcode/Swift versions; do not recreate the project or change language mode as a workaround |

## Handoff evidence

Report the Xcode and Swift outputs, iPadOS version, whether simulator and iPad
launches succeeded, and the first error if either failed. Do not send account
credentials, signing certificates, or device identifiers.

The project was authored on Linux without Xcode, an Apple SDK, or physical iPad
access. Static structure validation is not compilation. The next increment is
SDK-verified ImageCaptureCore discovery/session/event logging after this baseline
launches. Fujifilm and Sony remain separate future adapters to this one app.

Official references checked for this scaffold:

- [Apple: creating an Xcode project](https://developer.apple.com/documentation/xcode/creating-an-xcode-project-for-an-app)
- [Apple: build settings](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Swift: Swift 6 language mode](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/enabledataracesafety/)

Repository-layout PR #4 and commit-guard PR #5 are separate work. Preserve this
runbook and the bootstrap evidence when reconciling their documentation moves;
this branch does not merge or overwrite either branch.
