# Status

_Last updated: 2026-09-22_

Shared project checkpoint, authoritative for the whole application. Per-adapter
equipment and gate results live in [.github/agents/](../agents/) — currently
[sony/AGENTS.md](../agents/sony/AGENTS.md) and [fujifilm/AGENTS.md](../agents/fujifilm/AGENTS.md).

## What actually works

- Nothing in software — there is still **no Xcode project and no code**, for either adapter.
- Fujifilm (X-T4): design material only, none of it hardware-verified, and no open work item references it — see [.github/agents/fujifilm/AGENTS.md](../agents/fujifilm/AGENTS.md).
- Hardware: rig gate **S-G0 passed** 2026-09-20 — the cable carries data and the camera's USB modes have been surveyed. Observations are in the [Sony adapter instructions](../agents/sony/AGENTS.md); the consequence for the design is D-002.
- Documentation: scope, target rig, transport (D-002), storage (D-003), docs layout (D-004), and the product decisions harvested from the X-T4 package (D-005…D-009) are settled. W-001, W-002, and W-003 are Done with evidence. The backlog now runs to V1 acceptance (W-017) with procedures V-001…V-012 behind it.

## What is unverified

- **Everything on the iPad path.** Adapter enumeration, `ICDeviceBrowser` discovery and `requestOpenSession` in `PC Remote` (S-G1 / W-009), the vendor handshake through `requestSendPTPCommand` (S-G2 / W-010), capture events (S-G3), and card retention (S-G4 / W-011).
- Whether `PC Remote` tethering works at all on this body, even from a desktop. V-006 answers this with no code and no new hardware — it is the cheapest thing on the list and should run first.
- Everything else in ARCHITECTURE.md remains a proposal. Preview latency target `N` (M3) and preview cache size are still unset.
- Deployment target: the iPad Air 3 is on iPadOS 18.2.1; whether it can go further is unchecked.

## Blockers

- **Apple Lightning to USB 3 Camera Adapter (A1619) not purchased** (W-007). Blocks every iPad-side test. Only Apple's Camera Adapter puts a Lightning iPad into USB-host mode; a USB-C-to-Lightning cable cannot substitute, because it wires the iPad as a device.
- **Xcode not installed** (W-008) — Command Line Tools only. Blocks W-004.

## Environment versions

| Tool | Version |
| --- | --- |
| macOS | 26.6.2 (25G83) |
| Xcode | Not installed (Command Line Tools only) — install Xcode 27 |
| iPadOS (iPad Air 3) | 18.2.1 |
| Camera firmware | 3.10 (Sony a7R III / ILCE-7RM3) |

## Last test results

- 2026-09-20 — rig gate S-G0, Mac cable and USB-mode survey: **pass**. Details in the rig README → Camera USB modes.
- No app build, automated test, or iPad-side test has been run.

## Immediate next action

Run **V-006** (desktop `PC Remote` baseline, W-006). It needs no code and no new
hardware: install Sony Imaging Edge Desktop (Remote) on the Mac, confirm the camera
leaves "Connecting... USB", confirm the shutter is live, and record where images land
with `Still Img. Save Dest.` at default versus `PC+Camera`.

If V-006 fails, D-002 is in trouble and the project should stop and reconsider the
transport before any money or Xcode time is spent. If it passes, buy the Camera
Adapter (W-007) and install Xcode 27 (W-008) in parallel.
