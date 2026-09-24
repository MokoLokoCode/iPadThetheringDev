# Fujifilm adapter — X-T4

Adds to [../shared/AGENTS.md](../shared/AGENTS.md).

**Lead: Mario**, per the owner's instruction on 2026-09-23; his colleague leads Sony.
**Status: physical iPad launch owner-reported; browser discovery implementation authored, not yet compiled/tested on camera.**
W-020–W-024 in the [shared backlog](../../project/PROGRESS.md) define the X-T4 path.
`FujifilmDiscovery.swift` is the read-only browser increment. Mario reported on
2026-09-24 that Diagnostic View launches on his physical iPad. No X-T4 enumeration
result, session, item callback, or RAW-retention run has been supplied.

## Equipment

| Item | Model | Notes |
| --- | --- | --- |
| Camera | Fujifilm X-T4 | Firmware 2.12, owner-reported 2026-09-24 |
| Bench iPad | iPad Air (4th gen), USB-C | Physical iPadOS version still needed. The reported iPadOS 27 was for an M4 simulator, not this iPad. This is **not** the Lightning iPad used for Sony work |
| Cable | Direct data-capable USB-C | Model, length, and speed unrecorded |

## Camera USB modes

From Fujifilm's documentation, not from observation here.

| Mode | Purpose | Notes |
| --- | --- | --- |
| `USB CARD READER` | Visibility control | Enumerate and list existing files; establishes that discovery and session work before tethering is attempted |
| `USB TETHER SHOOTING AUTO` | The tethering target | Whether it delivers physical-shutter events through ImageCaptureCore is **unestablished** |
| `USB TETHER SHOOTING FIXED` | — | Fujifilm's manual warns about card recording behavior in this mode. Do not move to it silently |

Sequence: card reader first as a control, then tether auto. On a control failure,
investigate cable, power, authorization, app/SDK behavior, and camera compatibility;
do not assume the failure already identifies its cause.

## RAW safety

Intended behavior is RAW+JPEG with RAW retained on the card and only the JPEG copied
to the iPad. Fujifilm's FIXED-mode caveat means selecting RAW+JPEG is **not** by itself
evidence that the card keeps the file. Verify after tethered captures (D-005).

## Filenames

`DSCF####.RAF` / `DSCF####.JPG`. Never label an inferred `.RAF` as an observed RAW
file (D-008).

## Scope and integration

Use `CameraTether/Camera/Adapters/Fujifilm/` for eventual vendor implementation.
Do not add empty adapter types or capability flags that imply support before the
probe establishes behavior. Use the shared diagnostic UI and brand-neutral models;
keep `ICCameraDevice` and vendor details behind the adapter boundary. Shared browser
or transport infrastructure is introduced only when validated behavior justifies it.

The X-T4's first implementation is an observational probe: detect the camera,
open/close a session, log device/session/catalog information, item names, errors,
restrictions, and raw PTP events. No downloads, shutter triggers, storage-setting
changes, deletions, or speculative vendor commands. Sony's D-002 handshake decision
does not authorize Fujifilm vendor commands.

The initial browser increment only discovers/removes devices and logs their names.
It cannot yet enumerate files or respond to physical shutter captures. W-021 stays
in progress until the SDK-verified session and camera delegates are added.

## Gates and work sequence

These gates preserve the original X-T4 safety sequence while using the shared
W-NNN backlog. **All are pending.** Stop at each gate for Mario's actual results;
mock events and another vendor's results cannot pass them.

| Gate | Work | Required evidence |
| --- | --- | --- |
| F-G0 | W-020 | Actual Mac/Xcode/Swift/iPadOS/firmware/cable record; shared app builds and launches on Mario's iPad; relevant ImageCaptureCore SDK declarations checked |
| F-G1 | W-021, W-022 | Probe builds and runs; USB CARD READER discovery, session and known-file catalog observations; idle disconnect/reconnect |
| F-G2 | W-023 | Physical-shutter captures in USB TETHER SHOOTING AUTO expose accessible JPEGs; corresponding RAWs verified on the SD card |
| F-G3 | W-024 | Ten spaced captures automatically download/display matching valid JPEGs; RAW retention rechecked; no camera deletion |

### F-G0 — Environment and shared launch baseline

After the shared scaffold is merged, record `xcodebuild -version`, `xcrun swift
--version`, SDK versions, project language/concurrency/deployment settings, iPadOS,
X-T4 firmware, and the exact cable/hub setup. Use a stable Xcode compatible with
Mario's Mac and iPad; do not inherit the Sony bench's toolchain or OS values.

Build/launch the shared app in a simulator and on the physical iPad. Then inspect
current Apple docs and installed SDK declarations for browser masks, required
delegates, sessions, authorization/restrictions, callback isolation and event APIs.
Record applicable permissions from evidence; do not guess privacy keys. A successful
launch alone does not verify ImageCaptureCore or clear F-G1.

### F-G1 — Read-only probe and card-reader control

1. Implement W-021 after F-G0. Keep bounded timestamped logs with unique IDs, raw
   errors/events, capture markers, and copy/share text. Distinguish discovery,
   session-open, and catalog readiness. Log events even if catalog-ready is absent.
2. Build/install from Xcode first. While the camera occupies the iPad's USB-C port,
   use in-app logs or supported wireless debugging; no passive USB splitter.
3. With a backed-up/test card containing known expendable JPEG/RAW images, follow
   current Fujifilm connection guidance and select USB CARD READER explicitly.
4. Record camera identity, transport, open-session result, catalog behavior and
   filenames; compare with known card contents. Do not classify enumeration as a
   new capture. Record elapsed observation time and errors for missing callbacks.
5. At idle, disconnect safely and reconnect once; log removal and session behavior.

Do not proceed to tether mode if the control is inconclusive. Bring back the exact
logs and setup so the failure can be investigated without changing several variables.

### F-G2 — AUTO physical-shutter access and RAW safety

1. After F-G1, safely disconnect and configure USB TETHER SHOOTING AUTO, RAW+JPEG,
   and single-shot drive. Record card-slot settings, JPEG quality/size, USB power,
   and auto-power-off settings. Do not silently select FIXED or change destinations.
2. Reconnect and preserve all session/catalog events. Mark a test-capture window in
   the app, then press the camera's physical shutter for one distinct test subject.
3. Repeat for three spaced exposures. Record added/renamed JPEG/RAW items, observed
   names, types/sizes, raw PTP events, busy indicator behavior, and whether shooting
   can continue. RAW+JPEG can yield multiple objects for one exposure.
4. Correlate exposures against the baseline and marked windows. An event alone is
   not proof of an accessible JPEG; ambiguity is a finding, not a pass.
5. Once activity ends, disconnect/shut down safely and inspect the card without
   altering it. Verify the corresponding RAF files and their sizes/content, and
   record observed versus inferred JPEG/RAW pairing across folders/cards.

If events/file access or durable RAW retention remain unclear, stop before downloads
or real shoots. Propose a bounded investigation; no autonomous PTP fuzzing, vendor
handshake, relay, or storage changes.

### F-G3 — First automatic JPEG

After F-G2, implement W-024 using the verified download API and the shared
storage/preview path. Start with one transfer at a time, atomic writes, explicit
failures, and no delete-after-download. Ten spaced physical-shutter captures must
produce ten matching local JPEGs and previews without an import tap. Check valid
decoding, names/content, duplicate/lost captures, errors, and event-to-display
timings; recheck the RAWs on the card. Inject zero-byte/truncated outcomes with a
test double before claiming those failure paths work. This is not a burst or
1,000-image reliability claim.

## Evidence and source history

Record results in the shared [VALIDATION evidence records](../../project/VALIDATION.md#evidence-records),
identifying `fujifilm`, F-GN, W-NNN, exact setup/commit, outcome, sanitized logs, and
card-retention observations where relevant. Update shared STATUS/PROGRESS; do not
create a second copy of those documents under this folder.

The source package and conversation remain in git history:

```bash
git show 98353d0:.github/VALIDATION.md   # V-00..V-09, including the X-T4 gates G1/G2/G3
git show 98353d0:.github/PROGRESS.md     # P-010..P-100 and their acceptance criteria
git show 98353d0:.github/README.md       # equipment and product context as first stated
git show a0e4320:.github/sonya7riii/ipad-tethering-transcript.md   # the design conversation
```

The original P-010/P-020/P-030/P-040/P-050 correspond to W-020/W-021/W-022/W-023/W-024.
Historical V-01/V-02/V-03 procedures inform F-G1/F-G2 above; their old numbering
must not be confused with the current shared V-NNN procedures. Re-verify current
Apple/Fujifilm documentation before implementing any API or relying on mode behavior.
