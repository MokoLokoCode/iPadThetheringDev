# Fujifilm adapter — X-T4

Adds to [../shared/AGENTS.md](../shared/AGENTS.md).

**Status: no active work recorded.** No code exists for this adapter, no hardware run
has been logged against it, and no open work item references it. It was the project's
original and first-named target, and the README still treats it as such; it is recorded
here so the workstream can be resumed without re-deriving it. Nothing below is
hardware-verified.

## Equipment

| Item | Model | Notes |
| --- | --- | --- |
| Camera | Fujifilm X-T4 | Firmware version never supplied |
| Bench iPad | iPad Air (4th gen), USB-C | iPadOS version never supplied. Note this is **not** the iPad used for Sony work, which is Lightning |
| Cable | Direct data-capable USB-C | Model, length, and speed unrecorded |

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

## Resuming this adapter

This file records X-T4 equipment and camera behavior. It deliberately defines **no
gates and no work sequence** for this adapter — the original package already has both,
and whoever resumes the workstream should decide whether to keep them rather than
inherit a structure written by someone not running it.

That package and the conversation it came from are in git history:

```bash
git show 98353d0:.github/VALIDATION.md   # V-00..V-09, including the X-T4 gates G1/G2/G3
git show 98353d0:.github/PROGRESS.md     # P-010..P-100 and their acceptance criteria
git show 98353d0:.github/README.md       # equipment and product context as first stated
git show a0e4320:.github/sonya7riii/ipad-tethering-transcript.md   # the design conversation
```

V-01, V-02, and V-03 in that VALIDATION are the X-T4 hardware procedures in full —
observation windows, exposure spacing, busy-indicator behavior, RAW/JPEG object counts,
card inspection afterwards. They were not carried into `.github/project/VALIDATION.md`,
which holds the camera-neutral procedures only.

Its camera-neutral content is already in `.github/project/` — do not copy it back. Take
only X-T4 facts from it, and re-verify them against current Fujifilm documentation
before relying on any.
