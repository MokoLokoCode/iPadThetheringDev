# Status

_Last updated: 2026-09-23_

Shared project checkpoint, authoritative for the whole application. Per-adapter
equipment and gate results live in [.github/agents/](../agents/) — currently
[sony/AGENTS.md](../agents/sony/AGENTS.md) and [fujifilm/AGENTS.md](../agents/fujifilm/AGENTS.md).

## What actually works

- No software build or device launch has been demonstrated. The shared launch-only Xcode scaffold is proposed in [PR #6](https://github.com/MokoLokoCode/iPadThetheringDev/pull/6); it is not part of this documentation branch and is not a camera implementation.
- Fujifilm (X-T4): Mario is the lead per his 2026-09-23 instruction; W-020–W-024 and F-G0–F-G3 are now defined. No adapter implementation or hardware result yet — see [Fujifilm instructions](../agents/fujifilm/AGENTS.md).
- Sony: Mario's colleague leads the adapter, per the same instruction; their name was not supplied. Existing Sony findings and work items are retained.
- Hardware: rig gate **S-G0 passed** 2026-09-20 — the cable carries data and the camera's USB modes have been surveyed. Observations are in the [Sony adapter instructions](../agents/sony/AGENTS.md); the consequence for the design is D-002.
- Documentation: scope, target rig, transport (D-002), storage (D-003), docs layout (D-004), and the product decisions harvested from the X-T4 package (D-005…D-009) are settled. W-001, W-002, and W-003 are Done with evidence. The backlog now runs to V1 acceptance (W-017) with procedures V-001…V-012 behind it.

## What is unverified

- **Everything on the iPad path.** Adapter enumeration, `ICDeviceBrowser` discovery and `requestOpenSession` in `PC Remote` (S-G1 / W-009), the vendor handshake through `requestSendPTPCommand` (S-G2 / W-010), capture events (S-G3), and card retention (S-G4 / W-011).
- Whether `PC Remote` tethering works at all on this body, even from a desktop. V-006 answers this with no code and no new hardware — it is the cheapest thing on the list and should run first.
- Everything else in ARCHITECTURE.md remains a proposal. Preview latency target `N` (M3) and preview cache size are still unset.
- Fujifilm: iPad Air 4 OS, X-T4 firmware, and Mario's Mac/Xcode versions remain unrecorded. USB visibility, AUTO physical-shutter events, JPEG retrieval, and RAW retention are all unverified.
- Sony bench deployment target: the iPad Air 3 is on iPadOS 18.2.1; whether it can go further is unchecked. These are not Fujifilm environment values.

## Blockers

- **Sony bench:** Apple Lightning to USB 3 Camera Adapter (A1619) not purchased (W-007); Xcode not installed (W-008), Command Line Tools only. These recorded blockers apply to the Sony bench, not Mario's USB-C iPad Air 4.
- **Fujifilm bench:** Mario plans to run the shared scaffold after it merges. F-G0 needs his launch/toolchain evidence before the observational probe; no camera gate can be advanced yet.

## Environment versions

The following are the existing **Sony bench** observations. Fujifilm values are
pending W-020 and must be recorded separately.

| Tool | Version |
| --- | --- |
| macOS | 26.6.2 (25G83) |
| Xcode | Not installed (Command Line Tools only) — install Xcode 27 |
| iPadOS (iPad Air 3) | 18.2.1 |
| Camera firmware | 3.10 (Sony a7R III / ILCE-7RM3) |

## Last test results

- 2026-09-20 — rig gate S-G0, Mac cable and USB-mode survey: **pass**. Details in the rig README → Camera USB modes.
- No app build, automated test, or iPad-side test has been run.

## Next action per workstream

**Fujifilm / Mario:** after the shared scaffold merges, run W-020 / F-G0 on the
Mac and iPad Air 4. Return Xcode/Swift/SDK/iPadOS/firmware/cable details plus the
launch result or first error. Then implement the observational probe (W-021).

**Sony / colleague:** retain the existing next action:

Run **V-006** (desktop `PC Remote` baseline, W-006). It needs no code and no new
hardware: install Sony Imaging Edge Desktop (Remote) on the Mac, confirm the camera
leaves "Connecting... USB", confirm the shutter is live, and record where images land
with `Still Img. Save Dest.` at default versus `PC+Camera`.

If V-006 fails, stop the Sony transport work and revisit D-002. This does not halt
the independent Fujifilm path. If it passes, the existing Sony plan continues with
W-007 and W-008.
