# Progress

Work items have stable IDs (`M<n>` milestones, `W-NNN` items). Do not renumber. Completed items keep their row and gain **Evidence**.

Adapter gates (`S-GN` for Sony, `F-GN` for Fujifilm) live in that adapter's
instructions under `.github/agents/` and are cited from the evidence column
here — see D-004.

## Milestones

| ID | Milestone | Status |
| --- | --- | --- |
| M0 | Project scaffold and decisions locked | In progress — W-001/002/003 done; blocked on W-007 (adapter) for anything on the iPad |
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
| W-004 | M1 | Xcode project skeleton | W-002, W-008 | App builds and runs on device | Open | |
| W-005 | M1 | Camera enumeration spike | W-004 | Camera name appears on screen when connected | Open | |
| W-006 | M0 | Desktop `PC Remote` baseline, no code | W-002 | Camera leaves "Connecting... USB" under Imaging Edge (Remote) on the Mac; shutter confirmed live; image destination recorded for `Still Img. Save Dest.` at default vs `PC+Camera` (procedure V-006) | Open | |
| W-007 | M0 | Acquire Apple Lightning to USB 3 Camera Adapter (A1619) | — | Adapter in hand; iPad enumerates the camera at all | Open | |
| W-008 | M0 | Install Xcode 27 on the development Mac | — | `xcodebuild -version` reports Xcode 27; a device build target is selectable | Open | |
| W-009 | M1 | iPad discovery/session probe in `PC Remote` (rig gate S-G1) | W-005, W-007 | `ICDeviceBrowser` reports the a7R III and `requestOpenSession` succeeds on the iPad, with logs (procedure V-001) | Open | |
| W-010 | M1 | Sony vendor PTP handshake (rig gate S-G2) | W-009, W-006 | Camera leaves "Connecting... USB" when driven from the iPad; shutter is live | Open | |
| W-011 | M2 | RAW retention safety check (rig gate S-G4) | W-010 | With `Still Img. Save Dest. = PC+Camera`, ARW and JPG are present on the card with names matching what the iPad received (procedure V-007) | Open | |
| W-012 | M2 | First automatic JPEG transfer and display | W-010 | Physical shutter → valid local JPEG → on-screen preview with no import tap. Ten single captures produce ten matching previews, no losses or duplicates. Zero-byte transfers are visible failures, never previews (procedures V-002, V-003) | Open | |
| W-013 | M2 | Durable session store and provenance | W-012 | Data model from ARCHITECTURE implemented: stable capture UUIDs, observed source metadata, RAW confidence levels, atomic manifest writes. Relaunch reconstructs downloaded captures (procedures V-009, V-011) | Open | |
| W-014 | M4 | Acquisition recovery | W-013 | Generation-scoped callbacks, deduplication, bounded retry, safe reconnect reconciliation. Late callbacks cannot mutate a replacement connection (procedures V-008, V-009) | Open | |
| W-015 | M5 | Review UI | W-014 | Large preview, lazy filmstrip, swipe, pinch and double-tap zoom, follow-latest with review protection. New captures keep ingesting during review (procedure V-010; confirms or revises D-007) | Open | |
| W-016 | M5 | Selection and plain-text export | W-015 | Selections survive navigation, new captures, reconnect, and relaunch. Export honors the contract in ARCHITECTURE → Selection export contract (procedure V-011) | Open | |
| W-018 | M3 | Meet the preview latency target | W-012, W-013 | Event-to-display p50/p95 measured and within the agreed `N`; `N` itself recorded in DECISIONS.md after the V-012 baseline, not guessed (procedure V-003) | Open | |
| W-017 | M6 | Capacity baseline and V1 acceptance | W-016 | V-001…V-012 pass with hardware gates backed by real logs; memory, disk, p50/p95 latency, queue depth and errors reported; numeric targets agreed and recorded in DECISIONS.md (procedure V-012) | Open | |

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

