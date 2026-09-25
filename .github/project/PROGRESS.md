# Progress

Work items have stable IDs (`M<n>` milestones, `W-NNN` items). Do not renumber. Completed items keep their row and gain **Evidence**.

Adapter gates (`S-GN` for Sony, `F-GN` for Fujifilm) live in that adapter's
instructions under `.github/agents/` and are cited from the evidence column
here — see D-004.

## Milestones

| ID | Milestone | Status |
| --- | --- | --- |
| M0 | Project scaffold and decisions locked | In progress — W-001/002/003 done; W-007 blocks the Sony iPad bench only; Fujifilm prerequisites are W-020 |
| M1 | Camera detected and session started on iPad | Not started |
| M2 | Captures transfer and persist | Not started |
| M3 | Preview shown within N seconds of shutter | Not started — `N` is deliberately unset until the V-012 baseline exists (D-009) |
| M4 | Disconnect/reconnect survives | Not started |
| M5 | Review and selection workflow | Not started |
| M6 | V1 acceptance for real shoots | Not started |

## Work items

| ID | Milestone | Item | Depends on | Acceptance criteria | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| W-001 | M0 | Fill README equipment table | — | All TODO rows replaced with real models | **Done** | [Sony adapter instructions](../agents/sony/AGENTS.md). Cable data path observed 2026-09-20 (rig gate S-G0 pass: Mass Storage mount + MTP listing on the Mac) |
| W-002 | M0 | Decide camera protocol/SDK | W-001 | D-002 recorded in DECISIONS.md | **Done** | D-002. Based on the 2026-09-20 USB-mode survey on the Mac (rig README → Camera USB modes): shutter locked in `Mass Storage` and `MTP`; `PC Remote` stalls pending Sony's vendor handshake |
| W-003 | M0 | Decide storage location | — | D-003 recorded in DECISIONS.md | **Done** | D-003 |
| W-004 | M1 | Shared Xcode project skeleton | Compatible Xcode and device setup on the validating bench | One shared app builds and runs on device; record which bench passed | **Done for Fujifilm bench** | Mario reported 2026-09-24 that Diagnostic View launches on his physical iPad; Xcode 27 reported, device iPadOS/cable details still unrecorded. Sony validation remains independent (RUN-20260924-F0) |
| W-005 | M1 | Camera enumeration spike | W-004 | Camera name appears on screen when connected | Open | |
| W-006 | M0 | Desktop `PC Remote` baseline, no code | W-002 | Camera leaves "Connecting... USB" under Imaging Edge (Remote) on the Mac; shutter confirmed live; image destination recorded for `Still Img. Save Dest.` at default vs `PC+Camera` (procedure V-006) | **Done** | 2026-09-23, V-006 on the Mac: camera left "Connecting... USB" under Imaging Edge Remote 4.1.00; live view shown. `Still Img. Save Dest.` was found at PC+Camera; the shot was on the Mac and the card (checked in both). See RUN-20260923-01 |
| W-007 | M0 | Acquire Apple Lightning to USB 3 Camera Adapter (A1619) | — | Adapter in hand; iPad enumerates the camera at all | Open | |
| W-008 | M0 | Install Xcode 27 on the development Mac | — | `xcodebuild -version` reports Xcode 27; a device build target is selectable | **Done** | 2026-09-23: `xcodebuild -version` → Xcode 27.0 (27A266a); macOS and iOS Simulator builds succeed (W-025) |
| W-009 | M1 | iPad discovery/session probe in `PC Remote` (rig gate S-G1) | W-005, W-007 | `ICDeviceBrowser` reports the a7R III and `requestOpenSession` succeeds on the iPad, with logs (procedure V-001) | Open | |
| W-010 | M1 | Sony vendor PTP handshake (rig gate S-G2) | W-009, W-006 | Camera leaves "Connecting... USB" when driven from the iPad; shutter is live | Open | |
| W-011 | M2 | RAW retention safety check (rig gate S-G4) | W-010 | With `Still Img. Save Dest. = PC+Camera`, ARW and JPG are present on the card with names matching what the iPad received (procedure V-007) | Open | |
| W-012 | M2 | First automatic JPEG transfer and display | W-010 | Physical shutter → valid local JPEG → on-screen preview with no import tap. Ten single captures produce ten matching previews, no losses or duplicates. Zero-byte transfers are visible failures, never previews (procedures V-002, V-003) | Open | |
| W-013 | M2 | Durable session store and provenance | W-012 or W-024, with that adapter's RAW-safety gate passed | Data model from ARCHITECTURE implemented: stable capture UUIDs, observed source metadata, RAW confidence levels, atomic manifest writes. Relaunch reconstructs downloaded captures (procedures V-009, V-011) | Open | |
| W-014 | M4 | Acquisition recovery | W-013 | Generation-scoped callbacks, deduplication, bounded retry, safe reconnect reconciliation. Late callbacks cannot mutate a replacement connection (procedures V-008, V-009) | Open | |
| W-015 | M5 | Review UI | W-014 | Large preview, lazy filmstrip, swipe, pinch and double-tap zoom, follow-latest with review protection. New captures keep ingesting during review (procedure V-010; confirms or revises D-007) | Open | |
| W-016 | M5 | Selection and plain-text export | W-015 | Selections survive navigation, new captures, reconnect, and relaunch. Export honors the contract in ARCHITECTURE → Selection export contract (procedure V-011) | Open | |
| W-018 | M3 | Meet the preview latency target | W-013 plus W-012 or W-024 | Event-to-display p50/p95 measured on the named supported adapter and within the agreed `N`; `N` itself recorded in DECISIONS.md after the V-012 baseline, not guessed (procedure V-003) | Open | |
| W-017 | M6 | Capacity baseline and V1 acceptance | W-016 | Applicable shared V-001…V-012 procedures and the claimed adapter's gates pass with real logs; memory, disk, p50/p95 latency, queue depth and errors reported; numeric targets agreed (V-012). V-006/V-007 remain Sony-only; Fujifilm uses F-G2 for RAW safety. Support is declared separately per adapter | Open | |
| W-019 | M0 | Activate Fujifilm workstream and ownership | Owner's 2026-09-23 instruction | Lead, adapter scope, independent prerequisites, W-020–W-024, and F-G0–F-G3 documented without duplicating shared app/features | Done | DOC-20260923-FUJI in VALIDATION; D-013; documentation only, no hardware gate passed |
| W-020 | M0 | Fujifilm bench environment, launch and SDK baseline | Shared scaffold available (PR #6); Mario's Mac/iPad | F-G0: record actual versions/settings and cable; shared app builds/launches on Mario's iPad; relevant current Apple docs and installed SDK declarations checked | In progress | Owner-reported physical app launch on 2026-09-24, Xcode 27, X-T4 firmware 2.12; physical iPadOS, SDK declarations and cable details remain pending (RUN-20260924-F0) |
| W-021 | M1 | Fujifilm observational diagnostic probe | W-020 / F-G0 | Build/install succeeds; bounded logs distinguish discovery/session/catalog/items/PTP/errors/restrictions; capture markers and log export; safe idempotent start/stop; no downloads/writes/shutter commands | In progress | Physical iPad discovery, session and 17-file catalog observed twice (RUN-20260924-F2/F3/F4). Capture marker and post-catalog/PTP capture behavior remain pending. |
| W-022 | M1 | X-T4 USB CARD READER visibility control | W-021 | F-G1: real device/session/catalog and known filenames observed; one idle disconnect/reconnect recorded | In progress | Mario confirmed USB CARD READER, RAW-only format and filenames matching the SD card (RUN-20260924-F4). F3 recorded a physical reconnect but without the mode; an idle reconnect explicitly in CARD READER remains to clear F-G1. |
| W-023 | M2 | X-T4 AUTO capture access and RAW retention | W-022 / F-G1 | F-G2: three marked physical-shutter exposures yield accessible JPEG objects; corresponding RAF files verified on SD; names/renames and pairing evidence preserved | Open | No hardware result |
| W-024 | M2 | X-T4 first automatic JPEG preview | W-023 / F-G2 | F-G3: ten spaced captures yield matching valid JPEG previews through shared storage/UI; no loss/duplicates/deletes; RAW retention rechecked; zero-byte/truncated failures tested | Open | No hardware result |
| W-025 | M1 | Native macOS destination and platform shell (D-014) | W-008 | One target builds for macOS and iOS Simulator with no Swift warnings; `#if os` confined to `App/` and `Platform/` | **Done** | 2026-09-23: both builds succeed on Xcode 27.0. Compiled only; no iPad device install |
| W-026 | M2 | Event culling flow on the Mac (D-015) | W-025 | Inbox shots publish after the countdown unless deleted; delete withdraws a published copy; restore republishes; partial files never publish or upload | **Done** | 2026-09-23: file-logic harness 11/11 pass; app smoke test published three synthetic JPEGs to a scratch outbox after the delay. Hardware: RUN-20260923-02 publish, delete-before, delete-after, and restore passed with the a7R III via Imaging Edge |
| W-027 | M2 | Event rehearsal on the real Sony Mac rig | W-026, W-006 | V-013 passes end to end with the a7R III, Imaging Edge, and iCloud Drive | **Done** | 2026-09-23: V-013 pass on the real rig, RUN-20260923-02 |

W-020–W-024 are Mario's Fujifilm path. Sony retains W-005–W-012 and S-GN
gates. Shared work W-013 onward is implemented once; either verified adapter may
unblock it. W-004 is the shared scaffold, with validation attributed to the actual
bench. Passing one bench never clears the other adapter's compatibility gates.

## Deferred backlog

Not scoped for V1. Each needs a trigger before it becomes a `W-NNN`.

| ID | Candidate | Trigger |
| --- | --- | --- |
| F-001 | Dedicated client-review mode | Owner prioritizes after V1 |
| F-002 | A/B, two-up, four-up comparison | Stable review and selection workflow |
| F-003 | Ratings, color labels, rejects, multiple reviewers | Semantics and persistence needs confirmed (would revisit D-006) |
| F-004 | Named client/shoot sessions and retention tools | Owner approves session-management UX |
| F-005 | CSV or richer Lightroom handoff | Demonstrated limits of filename-only export |
| F-006 | Histogram, clipping, EXIF, battery/card status | Verified metadata path from the camera |
| F-007 | External display and Pencil annotations | Stable rendering and storage foundation |
| F-008 | Preset/LUT preview and local JPEG adjustments | Owner approves editing scope (currently a README non-goal) |
| F-009 | Camera settings, remote shutter, live view | Separate feasibility study (currently a README non-goal) |
| F-010 | Exploit dual-slot `Sort(RAW/JPEG)` — RAW to slot 1, JPEG to slot 2 | After S-G4; rig-specific, see the Sony rig README |
| F-011 | Wi-Fi transport | Only if the wired path proves unworkable; would supersede D-002 |

## Work-item update format

- ID and state
- What changed
- Acceptance criteria met / not met
- Evidence: procedure ID, run record, commit
- Decisions or deviations referenced
- Remaining blocker and next action

Keep failed runs and scope changes. Do not recycle IDs, and do not substitute
"code written" for "test passed".
