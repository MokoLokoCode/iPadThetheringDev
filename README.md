# iPadTetheringDev

Tethered camera capture to an iPad: shoot, see the frame on the iPad within seconds, keep shooting.

## Problem

<!-- TODO: one paragraph — what's painful about the current tethering workflow and what "solved" looks like. -->

## Your equipment

| Item | Model | Notes |
| --- | --- | --- |
| Camera | TODO | Tethering protocol (PTP/USB, Wi‑Fi, vendor SDK) |
| iPad | TODO | iPadOS version, USB‑C vs Lightning |
| Cable / adapter | TODO | |
| Other | TODO | Storage, power, stands |

## Intended workflow

1. Connect camera to iPad.
2. Open the app; it detects the camera and starts a session.
3. Each shutter press transfers the image and shows a preview on the iPad.
4. Images are saved to a session folder for later review/export.

<!-- TODO: refine once ARCHITECTURE.md capture-to-preview flow is settled. -->

## MVP scope

- Detect a connected camera and start/stop a session.
- Transfer each new capture to the iPad automatically.
- Show the latest capture as a full-screen preview.
- Persist captures in a session folder.
- Survive cable disconnect/reconnect without losing already-transferred images.

## Non-goals

- Remote camera control (changing exposure, triggering the shutter).
- Editing, rating, or color-management tooling.
- Cloud sync or multi-device viewing.
- Support for cameras/protocols other than the one listed above.

## Documentation map

| File | Purpose | Contents |
| --- | --- | --- |
| [README.md](README.md) | Fast project orientation | Problem, your equipment, intended workflow, MVP scope, non-goals, documentation map, and reading order |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Technical design | Component responsibilities, capture-to-preview flow, storage, concurrency, memory limits, disconnect handling, and Mermaid diagrams |
| [DECISIONS.md](DECISIONS.md) | Decision history | Accepted decisions, alternatives, rationale, deviations, and decisions superseded later |
| [STATUS.md](STATUS.md) | Current checkpoint | What actually works, what is unverified, blockers, environment versions, last test results, and the immediate next action |
| [PROGRESS.md](PROGRESS.md) | Work backlog | Milestones and work items with stable IDs, dependencies, acceptance criteria, and completion evidence |
| [AGENTS.md](AGENTS.md) | Instructions for the implementing agent | Reading order, engineering rules, scope boundaries, validation requirements, and when to stop and ask |
| [VALIDATION.md](VALIDATION.md) | Reproducible testing | Hardware setup, test procedures, expected observations, failure interpretation, and safety checks |

## Reading order

1. README.md — this file
2. STATUS.md — where things stand right now
3. ARCHITECTURE.md — how it's built
4. DECISIONS.md — why it's built that way
5. PROGRESS.md — what's next
6. VALIDATION.md — how to prove it works
7. AGENTS.md — rules for anyone (human or agent) making changes
