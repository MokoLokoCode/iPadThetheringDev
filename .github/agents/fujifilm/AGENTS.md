# Fujifilm adapter — X-T4

Adds to [../shared/AGENTS.md](../shared/AGENTS.md).

**Status: dormant.** No one is working this adapter. It was the project's original and
first-named target, and the README still treats it as such; it is recorded here so the
workstream can be resumed without re-deriving it. Nothing below is hardware-verified.

## Equipment

| Item | Model | Notes |
| --- | --- | --- |
| Camera | Fujifilm X-T4 | Firmware version never supplied |
| Bench iPad | iPad Air (4th gen), USB-C | iPadOS version never supplied. Note this is **not** the iPad used for Sony work, which is Lightning |
| Cable | Direct data-capable USB-C | Model, length, and speed unrecorded |

The USB-C iPad means no Camera Adapter is needed — the camera connects directly. That
is a material difference from the Sony bench and changes what the first probe tests.

## Camera USB modes

From Fujifilm's documentation, not from observation here.

| Mode | Purpose | Notes |
| --- | --- | --- |
| `USB CARD READER` | Visibility control | Enumerate and list existing files; establishes that discovery and session work before tethering is attempted |
| `USB TETHER SHOOTING AUTO` | The tethering target | Whether it delivers physical-shutter events through ImageCaptureCore is **unestablished** |
| `USB TETHER SHOOTING FIXED` | — | Fujifilm's manual warns about card recording behavior in this mode. Do not move to it silently |

Sequence: card reader first as a control, then tether auto. Do not skip the control —
a failure there is a cable, power, or authorization problem, not a tethering problem.

## RAW safety

Intended behavior is RAW+JPEG with RAW retained on the card and only the JPEG copied
to the iPad. Fujifilm's FIXED-mode caveat means selecting RAW+JPEG is **not** by itself
evidence that the card keeps the file. Verify after tethered captures (D-005).

## Filenames

`DSCF####.RAF` / `DSCF####.JPG`. Never label an inferred `.RAF` as an observed RAW
file (D-008).

## Gates

| Gate | Question | State |
| --- | --- | --- |
| F-G0 | Does the cable pass data, and does the camera enumerate on the iPad in `USB CARD READER`? | Not started |
| F-G1 | Does discovery, `requestOpenSession`, and catalog enumeration succeed? | Not started |
| F-G2 | In `USB TETHER SHOOTING AUTO`, does a physical shutter press produce an accessible new object or PTP event? | Not started |
| F-G3 | Is RAW retained on the card, with names matching what the iPad received? | Not started |

## Resuming this adapter

The original X-T4 design package and the conversation it came from are in git history,
not in the working tree:

```bash
git show 98353d0 --stat          # the seven-file package as committed
git show a0e4320 --stat          # the design conversation transcript
```

Its camera-neutral content is already in `.github/project/` — do not copy it back.
Take only X-T4 facts from it, and re-verify them against current Fujifilm
documentation before relying on any.
