# Current Status

Last updated: **2026-09-04**. Maintainer: documentation author. This is a checkpoint, not a chronological work log.

## Snapshot

**Phase: design handoff prepared; implementation and hardware validation not started in this package.**

The seven Markdown documents define the scope, decisions, architecture proposal, work items, and validation gates. They contain no working Xcode project. Earlier chat code was not compiled or run against the user's hardware and must be revalidated rather than copied unquestioningly.

| Capability | Evidence level | Current finding |
| --- | --- | --- |
| Product requirements and phased plan | Documented | Captured in this package |
| Apple ImageCaptureCore API surface | Prior documentation research | Relevant discovery, session, media, and PTP APIs identified; current SDK declarations must be checked |
| X-T4 USB mode behavior | Prior manual research | Card-reader and tether modes documented; safety caveat around card retention |
| Diagnostic app | Not implemented here | No build result |
| iPad detects X-T4 | Unverified | No physical-device logs supplied |
| Physical-shutter event/new file | Unverified | May require Fujifilm-specific behavior |
| JPEG download and display | Unverified | Must follow event/access gate |
| RAW retention and filename pairing | Unverified | Mandatory safety gate |
| Session persistence, selections, export | Proposed | No implementation |
| Reconnect reliability and performance | Unverified | No measurements |

## Immediate next action

Start **P-010** in [PROGRESS.md](PROGRESS.md): establish the actual development environment, verify relevant declarations/authorization requirements in the installed SDK, and record them below. Then implement P-020, the smallest diagnostic app.

The first user-dependent checkpoint is **G1**: Test V-01 must demonstrate basic discovery/session/catalog behavior in USB CARD READER mode. It is a control test, not proof of tethered capture.

## Environment record

| Field | Value |
| --- | --- |
| Camera | Fujifilm X-T4 |
| Camera firmware | Not supplied |
| iPad | iPad Air, 4th generation |
| iPadOS version/build | Not supplied |
| Mac model/architecture | MacBook Pro; remaining details not supplied |
| macOS | Not supplied |
| Xcode version/build | Not supplied |
| SDK version | Not supplied |
| Swift version/language mode | Not selected |
| Concurrency/default isolation settings | Not selected |
| Minimum deployment target | Not selected; choose against actual device and API needs |
| Signing | Developer tooling available in principle; actual account setup not checked |
| USB cable/hubs | USB-C available; data capability, length, and topology not recorded |
| Source repository/commit | No repository associated with this package |

## Blockers and uncertainties

- No direct access to the owner's X-T4/iPad hardware from this documentation task.
- No evidence the X-T4 emits usable added-file callbacks in tether mode through ImageCaptureCore.
- No evidence the intended RAW-on-card/JPEG-to-iPad behavior is available without changing storage settings.
- No established behavior for temporary filenames, duplicate callbacks, PTP handles, or RAW/JPEG pairing.
- No measured preview latency, full-size transfer time, memory use, or sustained session capacity.

## Latest validation

Documentation checks: seven Markdown files prepared with relative cross-links, stable work/decision/test IDs, and explicit unresolved hardware assumptions. No app build, automated app test, or hardware validation was performed as part of this handoff.

Hardware result records: **none**. Use the template in [VALIDATION.md](VALIDATION.md).

## Next handoff should include

1. Xcode/SDK/iPadOS/firmware versions and selected signing/deployment settings.
2. Build success or exact compiler diagnostics for P-020.
3. V-01 logs with connection mode and timestamps, then stop for interpretation if it fails.
4. When allowed by G1, V-02 capture event logs and V-03 card-retention observations.

## Checkpoint maintenance template

Replace the snapshot on each meaningful handoff. Keep history in commits, decision records, and validation evidence instead of appending an endless diary here.

- Updated date / agent:
- Repository / commit:
- Current milestone and active item:
- Proven capability and evidence:
- Last build/test command and result:
- Hardware gate state:
- Blockers / user observations needed:
- Exactly one immediate next action:
