# Sony adapter — a7R III

Adds to [../shared/AGENTS.md](../shared/AGENTS.md). Everything here is
vendor-specific; anything above the camera transport boundary belongs in
[.github/project/](../../project/) instead.

_Last hardware observation: 2026-09-20._

## Equipment

| Item | Model | Notes |
| --- | --- | --- |
| Camera | Sony a7R III (ILCE-7RM3), firmware **3.10** | Dual SD slots. USB-C (USB 3.1 Gen 1) and Micro-USB multi-terminal; use USB-C |
| Bench iPad | iPad Air (3rd gen), iPadOS **18.2.1** | **Lightning**, not USB-C. A12 |
| Host adapter | Apple Lightning to USB 3 Camera Adapter (A1619) | **Not yet purchased.** Required: only Apple's Camera Adapter puts a Lightning iPad into USB-host mode. Negotiates USB 2.0 (480 Mbps) here. Lightning passthrough allows charging during a session |
| Cable | USB-A to USB-C, 2 ft | Data-capable, verified 2026-09-20 |
| Development host | MacBook Pro M2 Pro (2023), macOS 26.6.2 (25G83) | Xcode 27.0 (27A266a). Also the **event bench** for 2026-09-26: Imaging Edge tethers, CameraTether culls (D-014, D-015) |

## Tether chain

```
a7R III USB-C ──(USB-C → USB-A, 2 ft)──▶ [USB-A] Lightning to USB 3 Camera Adapter [Lightning] ──▶ iPad Air 3
                                                    └── [Lightning socket] optional charger passthrough
```

A USB-C-to-Lightning cable cannot substitute. In a tether the iPad must be the USB
**host**; that cable wires the Lightning end as a *device*, so camera and iPad are
device-to-device and nothing enumerates. The Camera Adapter contains the controller
that flips the iPad into host mode.

Throughput ceiling is the adapter's USB 2.0 link, not the cable — a USB 3.x cable buys
nothing here. Cable requirements: data-capable, ≤1.5 m, USB-IF compliant (correct
56 kΩ pull-up on the C end; out-of-spec resistors cause flaky power negotiation and
random disconnects).

## Camera USB modes

`MENU → Setup → USB Connection`. Observed 2026-09-20 from a MacBook Pro over
`Mac USB-C → C-to-A socket adapter → USB-A-to-C cable → camera`. **The iPad path is
untested.**

| Mode | Observed behavior (Mac) | Shutter | Relevance |
| --- | --- | --- | --- |
| `Mass Storage` | Mounts one volume per SD slot plus a small read-only `PMHOME` volume (PlayMemories installer stub; ignore) | **Locked** | Cable/enumeration test only |
| `MTP` | Appears in Image Capture as the camera; lists files. **Slot 1 only** | **Locked** — LCD shows "USB MODE MTP" | Standard PTP can read the card but cannot do live capture |
| `PC Remote` | LCD sits on "Connecting... USB" indefinitely unless the host completes Sony's proprietary PTP handshake | Expected yes (unverified) | **The only mode allowing tethered shooting** |
| `Auto` | Not tested | — | Avoid; mode selection must be explicit |

Consequence: there is no standard-PTP path to live capture on this body. The adapter
must open an ImageCaptureCore session **and** drive Sony's vendor PTP operations
(`requestSendPTPCommand`) to leave "Connecting...". Documented in the libgphoto2 Sony
driver, and Cascable ships a7R III tethering on iPad, so it is reachable through
Apple's public APIs — but it is real adapter work, not a thin shim. See D-002.

## RAW safety

Menu path on firmware 3.10: **MENU → Setup 4 → PC Remote Settings** holds
`Still Img. Save Dest.` and `RAW+J PC Save Img`. Event configuration, verified
2026-09-23: File Format **RAW & JPEG**, `Still Img. Save Dest.` **PC+Camera**,
`RAW+J PC Save Img` **JPEG Only** — ARW + JPG on the card, JPG only on the Mac.

In `PC Remote`, `Still Img. Save Dest.` is documented to default to **PC Only**: captures go to the
host and are *not* written to the card. Set **PC+Camera** before any real shoot and
verify ARW presence on the card (procedure V-007). This is the Sony counterpart of the
X-T4's `TETHER SHOOTING FIXED` caveat, and it is worse — the default loses the file.

**Observed 2026-09-23 — a hung host can lose a shot on both sides.** After Remote's
save folder was changed mid-session, the next shot hung Remote. The camera showed a
pending-transfer "1" icon, then a black "-PC-" screen, and locked `USB Connection`
("PC Remote: On") across an off/on cycle. A battery pull cleared it, but at power-on the
camera reported "Writing to the memory card was not completed correctly. Recover data?"
(cancelled). That shot was on neither the Mac nor the card. Rules: never pull the battery
while a transfer is pending; if the host hangs, quit it and unplug USB first. Cause of
the hang is suspected, not proven (one occurrence, RUN-20260923-02): do not change
Remote's save folder while the camera is connected — disconnect in Remote first. The battery pull also reverted the PC transfer setting: the
next shot arrived on the Mac as ARW. **After any battery removal, recheck File Format,
`Still Img. Save Dest.`, and `RAW+J PC Save Img` before shooting.** With them reset,
the card held RAW + JPEG and the Mac received JPEG only.

Dual-slot option for later: `Rec. Media Settings → Recording Mode → Sort(RAW/JPEG)`
writes RAW to slot 1 and JPEG to slot 2 — a natural fit for "RAW stays on card, JPEG
goes to iPad" (deferred, F-010).

## Debugging while tethered

The iPad's only port holds the Camera Adapter. The adapter's second socket is
**Lightning passthrough for charging** — it is not a data path, so it gives back no
route to Xcode. Plan for install-then-run-standalone and export the in-app log
afterwards. See ARCHITECTURE → *The single-port problem*.

## Filenames

`DSC#####.ARW` / `DSC#####.JPG` — note this differs from Fujifilm's `DSCF####.RAF`.
Export must not hardcode one vendor's pattern. Stems repeat across folders, cards, and
sessions; they are not identity (D-008).

## Gates

| Gate | Question | State |
| --- | --- | --- |
| S-G0 | Does the cable pass data? | **Pass** 2026-09-20 — Mass Storage mount and MTP listing on the Mac |
| S-G1 | Does `ICDeviceBrowser` on the iPad discover the camera in `PC Remote`, and does `requestOpenSession` succeed? | Blocked — Camera Adapter not purchased (W-007) |
| S-G2 | Can the adapter complete the vendor handshake via `requestSendPTPCommand` so the camera leaves "Connecting..." and the shutter goes live? | Not started (W-010) |
| S-G3 | On shutter press, does a new object arrive, and is the JPEG separately downloadable? | Not started |
| S-G4 | With `Still Img. Save Dest. = PC+Camera`, are ARW and JPG on the card with names matching what the iPad received? | Not started (W-011, procedure V-007) |

## Stop conditions for this adapter

- Do not send vendor PTP opcodes beyond those needed for the documented handshake, and never an unknown one. Preserve raw bytes in logs rather than guessing at semantics.
- Do not change `Still Img. Save Dest.` from software. It is the photographer's setting.
- If S-G2 fails, stop. D-002 is then wrong and needs revisiting, not working around.
- Run **V-006** — the desktop `PC Remote` baseline under Sony's own Imaging Edge — before spending money or Xcode time on the iPad path. It needs no adapter and no code.
