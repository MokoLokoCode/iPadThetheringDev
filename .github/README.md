# iPadThetheringDev
## Fuji Tether — Agent Handoff

Documentation baseline: 2026-09-04. Working project name: **Fuji Tether**.

## Start here

Build a native iPadOS app that turns an iPad into a portable review monitor for photographs taken with the **physical shutter of a Fujifilm X-T4**, connected over USB-C. The app is a capture-preview-review-selection companion, not a Lightroom replacement.

**Current reality:** this package contains design documents, not a working application. Earlier conversation proposed a diagnostic Swift implementation, but no successful build, physical-device test, or PTP trace has been reported. Device discovery, new-capture access in tether mode, and card retention must be verified. Do not treat the earlier code as an SDK-validated starter project.

### Reading order

1. [AGENTS.md](AGENTS.md): execution rules and stop conditions.
2. [STATUS.md](STATUS.md): authoritative current checkpoint and immediate next action.
3. [PROGRESS.md](PROGRESS.md): dependency-ordered work and acceptance criteria.
4. [ARCHITECTURE.md](ARCHITECTURE.md): target design; distinguish proposed components from implemented ones.
5. [VALIDATION.md](VALIDATION.md): required tests and evidence format.
6. [DECISIONS.md](DECISIONS.md): decisions, rationale, and unresolved choices.

For a resumed session, read README, AGENTS, and STATUS first, then the current task and its referenced tests/decisions. Do not assume a previous agent's narrative is test evidence.

## Owner and development context

The owner is a software engineer with a B.S. in Computer Engineering and backend experience. Technical explanations can assume familiarity with architecture, concurrency, protocols, debugging, and APIs. Explain Swift, Apple framework, and PTP-specific conventions where relevant. Build incrementally; provide code, execution instructions, expected observations, and debugging guidance, then wait for hardware results at the defined gates.

| Item | Context |
| --- | --- |
| Camera | Fujifilm X-T4; firmware version not supplied |
| Tablet | iPad Air 4th generation, USB-C; installed iPadOS version not supplied |
| Development host | MacBook Pro; architecture, macOS, and Xcode versions not supplied |
| Connection | Direct, data-capable USB-C cable; model/length/speed unknown |
| Existing workflow | Adobe Lightroom for final RAW processing, organization, and delivery |
| Photography | Headshots, portraits, engagements, graduations, weddings; mostly outdoors/on location |
| Lighting | Godox AD200 Pro and Godox iT30 Pro Mini for Fujifilm; no lighting integration required |
| Prior product exploration | Evoto, Capture One Mobile, Cascable Studio, Fujifilm XApp, Lightroom for iPad |

The owner reported interest in Evoto's wired X-T4 workflow and credit-based AI exports. This is motivation, not verified evidence that our chosen API path works. No commercial-app integration is required.

## Product contract

**Desired flow:** photograph on camera → JPEG appears on iPad → inspect/review → mark selections → export filenames for locating RAW files in Lightroom.

V1 must:

1. Discover the connected camera and establish a session.
2. Detect new physical-shutter captures without requiring an iPad shutter button.
3. Transfer a JPEG preview automatically, subject to hardware feasibility.
4. Show the latest successfully downloaded image prominently and maintain a session filmstrip.
5. Support navigation, pinch zoom, and double-tap focus inspection.
6. Support one simple selected/unselected flag per capture.
7. Preserve selections for the session, including app relaunch through lightweight local persistence.
8. Copy/share a newline-separated list of selected source filenames, with honest RAW mapping.
9. Remain usable with 50–1,000+ captures without retaining every decoded full-resolution image in RAM.
10. Surface disconnects and transfer failures without erasing existing previews or selections.

One selection flag represents the initial star/heart concept. Separate photographer favorites, client selections, and star ratings are deferred (D-006).

### RAW + JPEG intent and safety

Configure the camera for RAW+JPEG. Desired behavior is RAW retained on the SD card and JPEG copied to the iPad. **This is a goal, not a verified X-T4 tether-mode capability.** The app must never delete camera files, format media, or silently change capture destinations. If card retention cannot be demonstrated, stop before treating this as a usable photography workflow.

The app must not label an inferred RAF filename as an observed RAW file. Filename stems can repeat between folders/cards/sessions; they are not unique identifiers.

## Out of scope for V1

RAW development, AI edits, Lightroom catalog manipulation, cloud services, accounts, payment/credit systems, live view, camera exposure controls, app-triggered capture, burst-performance guarantees, multi-camera support, and background tethering guarantees.

Future candidates: dedicated locked-down Client Mode; A/B and 4-up comparison; ratings/color labels/rejects; histogram and clipping; EXIF and camera status; named client/shoot sessions; multiple reviewers; CSV export; preview sharing/AirDrop; external displays; Apple Pencil annotations; LUTs and local JPEG adjustments. Do not build these ahead of the gates.

## Engineering priorities

In order: reliable acquisition and RAW safety; fast previews; simple shooting UX; stable wired sessions; bounded memory; recovery from disconnection; minimal interference with camera operation. Offline local operation is the baseline. No backend is needed.

The first deliverable is **a diagnostic app**, not the full product. It logs discovery, session/catalog lifecycle, added items, raw PTP events, errors, and restrictions; it downloads or deletes nothing. Exact implementation depends on the installed SDK.

## Sources and provenance

These official sources were identified during the preceding conversation. They are reference starting points, not a fresh verification of every API signature or OS behavior on 2026-09-04. The implementing agent must verify the relevant current documentation and installed SDK before code decisions and record availability findings in STATUS.

- [Apple: ImageCaptureCore](https://developer.apple.com/documentation/imagecapturecore)
- [Apple: ICDeviceBrowser](https://developer.apple.com/documentation/imagecapturecore/icdevicebrowser)
- [Apple: ICCameraDevice](https://developer.apple.com/documentation/imagecapturecore/iccameradevice)
- [Apple: ICCameraDeviceDelegate](https://developer.apple.com/documentation/imagecapturecore/iccameradevicedelegate)
- [Apple: requestSendPTPCommand completion API](https://developer.apple.com/documentation/imagecapturecore/iccameradevice/requestsendptpcommand(_:outdata:completion:))
- [Fujifilm: X-T4 USB connection instructions](https://fujifilm-dsc.com/en/manual/x-t4/connections/computer/index.html)
- [Fujifilm: X-T4 connection settings](https://fujifilm-dsc.com/en/manual/x-t4/menu_setup/connection_setting/index.html)

The prior research identified ImageCaptureCore discovery and related camera APIs as available on iPadOS. It did not establish native X-T4 physical-shutter event delivery through those APIs. Fujifilm's manual documents card-reader and tether modes and warns about card recording behavior in FIXED mode.

## Handoff instruction

Give the next agent all seven files, ideally at the repository root so AGENTS.md is discovered. Ask it to begin with **P-010**, verify the actual environment and SDK, then build **P-020**. Do not ask it to implement the entire backlog in one unattended pass. Hardware-dependent gates require the owner's results.
