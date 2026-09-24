# Status

_Last updated: 2026-09-24_

Shared project checkpoint, authoritative for the whole application. Per-adapter
equipment and gate results live in [.github/agents/](../agents/) — currently
[sony/AGENTS.md](../agents/sony/AGENTS.md) and [fujifilm/AGENTS.md](../agents/fujifilm/AGENTS.md).

## What actually works

- **Mac event culling flow (D-014, D-015; W-025, W-026), 2026-09-23:** the shared app builds for macOS and the iOS Simulator on Xcode 27.0. On the Mac, JPEGs landing in a session Inbox publish to an outbox after a countdown unless deleted. File-logic harness 11/11; app smoke test with synthetic JPEGs and a scratch outbox passed. **Hardware-verified 2026-09-23** with the a7R III, Imaging Edge Remote and iCloud Drive: V-013 pass (RUN-20260923-02). Desktop `PC Remote` tethering works (V-006, RUN-20260923-01).
- Mario reported the shared Diagnostic View launched on his physical iPad on 2026-09-24. The Fujifilm browser-only probe is authored on `mario/fujifilm-discovery`; it has not been built with an Apple SDK or exercised over USB yet (RUN-20260924-F0). Earlier launch-scaffold wording is superseded by this report.
- Fujifilm (X-T4): Mario is the lead per his 2026-09-23 instruction; W-020–W-024 and F-G0–F-G3 are now defined. No adapter implementation or hardware result yet — see [Fujifilm instructions](../agents/fujifilm/AGENTS.md).
- Sony: Mario's colleague leads the adapter, per the same instruction; their name was not supplied. Existing Sony findings and work items are retained.
- Hardware: rig gate **S-G0 passed** 2026-09-20 — the cable carries data and the camera's USB modes have been surveyed. Observations are in the [Sony adapter instructions](../agents/sony/AGENTS.md); the consequence for the design is D-002.
- Documentation: scope, target rig, transport (D-002), storage (D-003), docs layout (D-004), and the product decisions harvested from the X-T4 package (D-005…D-009) are settled. W-001, W-002, and W-003 are Done with evidence. The backlog now runs to V1 acceptance (W-017) with procedures V-001…V-012 behind it.

## What is unverified

- **Everything on the iPad path.** Adapter enumeration, `ICDeviceBrowser` discovery and `requestOpenSession` in `PC Remote` (S-G1 / W-009), the vendor handshake through `requestSendPTPCommand` (S-G2 / W-010), capture events (S-G3), and card retention (S-G4 / W-011).
- Whether our own `PC Remote` handshake (S-G2) works; desktop tethering via Imaging Edge is verified (V-006).
- Cause of the Remote hang after a mid-session save-folder change; avoided by setting the folder first.
- Everything else in ARCHITECTURE.md remains a proposal. Preview latency target `N` (M3) and preview cache size are still unset.
- Fujifilm: iPad Air 4 OS and exact cable remain unrecorded. Mario reported Xcode 27 and X-T4 firmware 2.12. USB camera visibility, open session/catalog, AUTO physical-shutter events, JPEG retrieval, and RAW retention are unverified.
- Sony bench deployment target: the iPad Air 3 is on iPadOS 18.2.1; whether it can go further is unchecked. These are not Fujifilm environment values.

## Blockers

- **Sony bench:** Apple Lightning to USB 3 Camera Adapter (A1619) not purchased (W-007); Xcode not installed (W-008), Command Line Tools only. These recorded blockers apply to the Sony bench, not Mario's USB-C iPad Air 4.
- **Fujifilm bench:** physical app launch was reported. F-G0 still needs iPadOS/cable and installed SDK checks; browser discovery needs a real iPad → X-T4 USB run. No camera gate is cleared.

## Environment versions

The following are the existing **Sony bench** observations. Fujifilm values are
pending W-020 and must be recorded separately.

| Tool | Version |
| --- | --- |
| macOS | 26.6.2 (25G83) |
| Xcode | 27.0 (27A266a); Swift 6 language mode |
| Mac | MacBook Pro M2 Pro, 2023 (Sony event bench) |
| iPadOS (iPad Air 3) | 18.2.1 |
| Camera firmware | 3.10 (Sony a7R III / ILCE-7RM3) |

## Last test results

- 2026-09-24 — owner-reported Diagnostic View launch on physical iPad (Xcode 27); distinct from the earlier iPad Air M4 simulator launch. No camera connected to physical iPad during this report. The browser-only code has static checks only; no Xcode or camera run (RUN-20260924-F0).
- 2026-09-20 — rig gate S-G0, Mac cable and USB-mode survey: **pass**. Details in the rig README → Camera USB modes.
- 2026-09-23 — macOS + iOS Simulator builds succeed; D-015 file-logic harness 11/11 pass; Mac app smoke test (synthetic JPEGs, scratch outbox) pass. No camera run, no iPad device run.

## Next action per workstream

**Fujifilm / Mario:** build the discovery branch on the physical iPad, then connect
the X-T4 directly to the iPad in USB CARD READER mode and share the in-app log.
Report physical iPadOS and exact cable. Session/catalog and shutter callbacks follow
only after we interpret the enumeration result.

**Sony / colleague:** event on 2026-09-26 16:30 runs on the Mac (D-014, D-015).
V-006 and V-013 passed 2026-09-23; code is event-ready. Freeze after any final
UI tweaks; rerun V-013 once on Friday. Plan A is Imaging Edge alone if V-013 fails.
The iPad path (W-007, S-G1/S-G2) resumes after the event. Earlier next action, still
the first step:

Run **V-006** (desktop `PC Remote` baseline, W-006). It needs no code and no new
hardware: install Sony Imaging Edge Desktop (Remote) on the Mac, confirm the camera
leaves "Connecting... USB", confirm the shutter is live, and record where images land
with `Still Img. Save Dest.` at default versus `PC+Camera`.

If V-006 fails, stop the Sony transport work and revisit D-002. This does not halt
the independent Fujifilm path. If it passes, the existing Sony plan continues with
W-007 and W-008.
