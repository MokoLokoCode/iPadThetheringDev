# Instructions for Implementing Agents

Applies to the project containing this file. Baseline: 2026-09-04.

## Mission

Implement the owner's X-T4-to-iPad review app incrementally. Start with a diagnostic build, establish hardware feasibility, then add JPEG display and finally the V1 review workflow. Respect the owner's engineering experience; explain Apple-specific details without obscuring technical tradeoffs.

## Load context and select work

1. Read [README.md](README.md) and [STATUS.md](STATUS.md).
2. Read the current work item in [PROGRESS.md](PROGRESS.md), its acceptance criteria, dependencies, and tests in [VALIDATION.md](VALIDATION.md).
3. Read relevant sections of [ARCHITECTURE.md](ARCHITECTURE.md) and [DECISIONS.md](DECISIONS.md).
4. Inspect the actual repository and preserve unrelated edits. The documentation package does not imply that source code or an Xcode project already exists.
5. Work on the smallest runnable increment. Do not mark downstream tasks complete on mocks alone.

## Evidence and API discipline

- Verify current Apple/Fujifilm documentation and installed SDK declarations before relying on a signature, availability, entitlement, privacy key, callback threading rule, or camera operation.
- Record the Xcode/SDK, Swift language mode, concurrency settings, deployment target, iPadOS, camera firmware, and cable setup used for each hardware run.
- Distinguish **documented**, **proposed**, **compiled**, **simulated**, and **hardware-verified**. Compilation does not establish camera compatibility.
- Treat earlier conversation snippets as uncompiled sketches. Check required delegate methods, type masks, optionals, method imports, and current deprecations. Do not hide compile problems behind force unwraps or disable concurrency checking without a documented reason.
- Do not assume discovery, session-open, and catalog-ready imply the same thing. Log each independently. A missing catalog-ready callback in tether mode is a finding, not grounds to discard all later events.
- Treat advertised camera capabilities as clues, not proof of physical-shutter access or safe storage behavior.

## Safety boundaries

- Initial hardware tests use expendable photographs and a backed-up/test card. Never format a card or delete camera files as troubleshooting.
- Do not call deletion APIs or enable delete-after-download. Do not send reset, format, firmware-update, unknown vendor commands, or capture-destination changes.
- Begin with USB CARD READER as a visibility control, then USB TETHER SHOOTING AUTO. Do not silently move to FIXED mode.
- Do not claim RAW remains on the SD card until it has been checked after tethered captures. A shutter sound, thumbnail, or object-added event is not proof of durable card storage.
- Never use a paying client's session as the initial compatibility test.
- Keep client images and filenames local. Do not upload images, logs, or USB traces to external services without permission. Redact serial numbers and personal filenames when appropriate.
- App switching, lock, power loss, and cable removal may disrupt acquisition. Do not promise background capture or power-loss recovery of camera-only buffers.

## Mandatory stop conditions

Stop at G1, G2, and G3 in PROGRESS until required physical-device evidence is supplied. You may prepare clearly labeled mock/unit tests, but cannot use them to advance a hardware gate.

Stop and explain options if:

- Direct wired physical-shutter access does not work through the tested public API path.
- Reliable SD-card RAW retention is unavailable or unclear.
- A workaround changes the product topology (Mac relay, Wi-Fi, external capture device, or cloud service).
- Paid membership, a paid SDK, licensing agreement, entitlement approval, or unsupported/private API appears necessary.
- Progress requires protocol reverse engineering, changing camera storage behavior, or installing invasive monitoring tools beyond the current diagnostic scope.

Do not autonomously fuzz PTP. If protocol investigation is approved, first propose a bounded plan: documented read-only capability queries, sanitized logs from owned hardware, available vendor SDK terms, then lawful passive capture options. Check applicable licenses and legal constraints rather than declaring reverse engineering universally permitted.

## Implementation conventions

- Native Swift app; SwiftUI is the initial UI choice, not a requirement for every interaction. UIKit-backed zoom may be appropriate after validation.
- Use the SDK's supported actor/delegate isolation model. MainActor owns UI-observed state; serialize camera session access on its documented executor. Avoid moving non-Sendable framework objects across actors unchecked.
- Keep device transport separate from session/review logic. Introduce a small fake transport for tests only when useful; do not build an elaborate plugin system before the first JPEG.
- One transfer at a time initially. Use session/connection generation tokens to reject stale callbacks after reconnect.
- Write files atomically, bound caches and diagnostic logs, and keep image decoding off the UI path where supported.
- Store selections transactionally. Do not identify a capture solely by a basename or transient PTP object handle.
- No third-party dependencies unless they solve a demonstrated need and their cost/license is recorded.
- No source-control push, app distribution, or external publication unless authorized by the owner.

## Testing and definition of done

For each item, provide changed files, commands run, result, and evidence reference. On a host without Xcode, explicitly say build and hardware tests were not run. Static inspection is not a successful build.

A work item is done only when its acceptance criteria pass at the required evidence level. Follow VALIDATION for disconnects, duplicate callbacks, RAW/JPEG pairing, selection export, and memory tests. Do not make up latency or success-rate measurements.

## Documentation update contract

Before handing off any meaningful increment:

1. Update PROGRESS item state and link evidence; retain stable IDs.
2. Update STATUS with exact current capability, remaining blocker, and one next action.
3. Append a decision when deviating from an accepted design. Mark superseded decisions and link replacements; do not erase history.
4. Update ARCHITECTURE when implemented behavior or interfaces differ from its proposal.
5. Update VALIDATION with test results or new reproducible cases.
6. Change README only when product context, scope, or navigation changes.

Unverified choices stay proposed. Decisions affecting RAW safety, connectivity topology, paid dependencies, or scope require owner approval. At each hardware handoff, ask for only the specific missing observations needed to unblock the next step.
