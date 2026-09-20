# Progress

Work items have stable IDs (`M<n>` milestones, `W-NNN` items). Do not renumber. Completed items keep their row and gain **Evidence**.

## Milestones

| ID | Milestone | Status |
| --- | --- | --- |
| M0 | Project scaffold and decisions locked | In progress |
| M1 | Camera detected and session started on iPad | Not started |
| M2 | Captures transfer and persist | Not started |
| M3 | Preview shown within N seconds of shutter | Not started |
| M4 | Disconnect/reconnect survives | Not started |

## Work items

| ID | Milestone | Item | Depends on | Acceptance criteria | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| W-001 | M0 | Fill README equipment table | — | All TODO rows replaced with real models | Open | |
| W-002 | M0 | Decide camera protocol/SDK | W-001 | D-002 recorded in DECISIONS.md | Open | |
| W-003 | M0 | Decide storage location | — | D-003 recorded in DECISIONS.md | Open | |
| W-004 | M1 | Xcode project skeleton | W-002 | App builds and runs on device | Open | |
| W-005 | M1 | Camera enumeration spike | W-004 | Camera name appears on screen when connected | Open | |
