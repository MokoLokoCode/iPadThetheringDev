# Work Backlog

Baseline: 2026-09-04. Stable IDs identify tasks; [STATUS.md](STATUS.md) is the current checkpoint. Do not confuse a proposed task with completed implementation.

States: **TODO**, **IN_PROGRESS**, **BLOCKED**, **DONE**, **DEFERRED**. DONE requires the listed acceptance criteria and an evidence reference. A dependency being unfinished does not mean a failed attempt occurred.

## Milestones and gates

| Milestone | Work | Exit gate |
| --- | --- | --- |
| M0 — Buildable probe | P-010, P-020 | V-00 successful build and device installation |
| M1 — Visibility control | P-030 | G1: V-01 physical camera discovery/session/catalog evidence |
| M2 — Tether feasibility and safety | P-040 | G2: V-02 physical-shutter accessible object and V-03 RAW retention verified |
| M3 — First JPEG | P-050 | G3: V-04 real JPEG downloaded and displayed reliably |
| M4 — Durable ingestion | P-060, P-070 | V-05/V-06/V-08 recovery, identity, and persistence checks |
| M5 — V1 review workflow | P-080, P-090 | V-07 review and V-08 filename export checks |
| M6 — Release candidate for owner testing | P-100 | V-09 stress baseline and documented end-to-end acceptance |

**G1/G2/G3 require the owner's physical-device results.** Stop rather than declaring success from simulated events. Safe mocked tests may be prepared while waiting, but do not bypass the gates. If a control test fails, analyze it before attempting a mode/workflow change.

## Task register

| ID | Task | State | Dependencies | Evidence |
| --- | --- | --- | --- | --- |
| P-001 | Create seven-file handoff package | DONE | None | Seven Markdown documents; documentation-only validation |
| P-010 | Record environment and validate SDK/API requirements | TODO | P-001 | None |
| P-020 | Implement and compile diagnostic probe | TODO | P-010 | None |
| P-030 | Run card-reader visibility control | TODO | P-020 | None |
| P-040 | Validate tether events, file access, and RAW safety | TODO | G1 | None |
| P-050 | Download and display one JPEG automatically | TODO | G2 | None |
| P-060 | Persist source identity and capture/session records | TODO | G3 | None |
| P-070 | Recover from duplicates, errors, and reconnects | TODO | P-060 | None |
| P-080 | Implement large preview, filmstrip, zoom, follow-latest | TODO | P-070 | None |
| P-090 | Add durable selection and honest filename export | TODO | P-080 | None |
| P-100 | Measure stress behavior and complete V1 acceptance | TODO | P-090 | None |

## P-010 — Environment and API baseline

Record actual host/device versions in STATUS; select deployment target, language mode, isolation settings, and signing approach. Inspect Apple's current docs and SDK for browser masks, delegate requirements, session APIs, content authorization/restriction callbacks, download completion semantics, and PTP event APIs.

Acceptance:

- Environment fields are populated or explicitly identified as still missing.
- Relevant APIs have source/SDK references and availability notes.
- Required permissions and entitlements are evidence-based; no guessed plist keys.
- The plan to observe logs while the iPad USB port connects to the camera is runnable.
- Any paid tooling requirement is explained before adoption.

Validation: V-00. Output: environment/API findings and smallest project setup instructions. Do not claim SDK verification on a machine without access to that SDK.

## P-020 — Diagnostic application

Implement the three-file starting structure from ARCHITECTURE. Keep strong ownership of browser/device and satisfy the SDK's delegate protocol requirements. Add unique log IDs, bounded timestamped logs, capture markers, and a way to copy/share text from the iPad. Preserve raw PTP bytes without decoding speculative vendor commands.

Acceptance:

- Xcode build succeeds for the chosen physical iPad target with recorded settings.
- App installs/launches; authorization/restriction state is observable.
- Start/stop and removal are idempotent; logs cannot grow without bound.
- Discovery, session lifecycle, catalog, item additions/renames, and PTP events are distinguishable.
- No camera writes, downloads, shutter trigger, or deletion calls are included.
- Build output and instructions are supplied to the owner.

Validation: V-00. Stop for compile feedback if needed; do not hide missing delegate methods with unrelated API substitutions.

## P-030 — Card-reader control

Run V-01 with test files and USB CARD READER. Capture actual device identity, transport, session result, catalog behavior, and observed source filenames.

Acceptance: physical-device discovery and session/catalog evidence, compared with known card contents. Report elapsed observation time and errors if incomplete. Existing-file enumeration is not labeled tether capture.

Gate G1: owner supplies passing V-01 evidence. On failure, diagnose cable/power/authorization/mode using VALIDATION before advancing.

## P-040 — Tether events and card retention

Run V-02 in USB TETHER SHOOTING AUTO and V-03 with RAW+JPEG. Record whether physical-shutter capture produces object additions, PTP events, temporary names, RAW/JPEG objects, and catalog readiness. Verify actual SD-card files after the capture.

Acceptance:

- Controlled shutter actions correlate with newly accessible JPEG objects or a documented, tested equivalent path.
- Capture is not confused with initial catalog enumeration.
- RAW retention is observed on the card and associated with the test exposures.
- Repeated single captures remain possible without the app downloading RAWs or changing camera storage settings.
- Ambiguous filenames, absent catalog readiness, and unexpected buffering are documented.

Gate G2: V-02 and V-03 pass. If only raw PTP events appear or storage safety fails, stop, summarize evidence, and propose a bounded investigation/decision. Do not mark this task done because a commercial application can tether.

## P-050 — First automatic JPEG preview

Use the verified ImageCaptureCore download API, one transfer at a time, into a unique temporary file; validate/commit it atomically and display it. Filter on observed format metadata/extension with sensible handling for missing metadata. Do not silently transfer RAWs.

Acceptance:

- Physical shutter → valid local JPEG → display, without tapping an import button.
- Ten single captures, spaced to finish each transfer, produce matching previews and filenames with no lost/duplicate captures.
- Failed/zero-byte transfers are visible and never treated as completed previews.
- Download preserves camera files; card retention is rechecked after the series.
- Event-to-display timings are recorded separately from true shutter latency.

Gate G3: V-04 passes. This is proof of JPEG flow, not a 1,000-image reliability claim.

## P-060 — Durable session and provenance

Implement stable local identities, source descriptors, observed/inferred RAW associations, transfer states, versioned storage, and atomic metadata persistence. Resolve D-008 based on actual data volume and write behavior. Add fake event sequences for unit tests; keep actual camera conformance independent.

Acceptance: no basename-only identity; RAW/JPEG arrival order and rename tests pass; relaunch reconstructs downloaded captures; interrupted writes have explicit recovery; metadata and image files stay consistent. Selection field can exist before UI is added.

Validation: V-06, V-08 persistence subset. Output: storage decision, tests, and schema/recovery notes.

## P-070 — Acquisition recovery

Add generation-based invalidation, deduplication, bounded retry/backlog behavior, access/session error states, and safe reconnect reconciliation. Define foreground-only behavior visibly.

Acceptance: late callbacks cannot mutate a replacement connection; downloaded images survive disconnect; retry does not create duplicates; denied access and storage failures are visible; no speculative recovery of unavailable buffered files is promised.

Validation: V-05 and V-06. Begin fault injection with mocks; run hardware interruption tests only on expendable captures after basic card safety has passed.

## P-080 — Review UI

Build prominent preview, lazy filmstrip, swipe navigation, pinch and double-tap zoom, and proposed follow-latest behavior. Use the real downloaded JPEG for inspection and bounded rendering caches. Confirm D-007 with the owner.

Acceptance: navigating older images prevents auto-jumps; resume-live action works; new captures still ingest during review; current image stays visible during transfer; zoom state is predictable on navigation; thumbnails are not misrepresented as full-resolution inspection.

Validation: V-07; begin V-09 memory checks. Dedicated Client Mode/comparison is not part of this task.

## P-090 — Selection and export

Add one selected flag, selected/capture counts, persistence, and plain-text copy/share. Enforce observed/inferred/unresolved RAW association behavior from ARCHITECTURE.

Acceptance: selections survive navigation, new captures, reconnect and relaunch; empty selections are explicit; exported order is stable; duplicate/ambiguous filenames are warned about, not silently discarded; exact observed names are retained; inferred RAW candidates require clear disclosure/confirmation.

Validation: V-08. Manually verify a sample list against actual RAW files; do not claim automatic Lightroom integration.

## P-100 — V1 acceptance and operating limits

Exercise 50, 250, and 1,000+ capture records with realistic JPEG sizes. Simulated/local replay can validate rendering/storage, but must be labeled separately from an actual tethered session. Agree the physical-camera soak size with the owner; report exactly how many real captures were tested.

Acceptance:

- V-00 through V-09 required checks pass, with hardware gates supported by real logs.
- Report memory, disk, event-to-display p50/p95, queue depth, errors, and reconnect findings.
- No linear growth from retaining all decoded full-size images; no known lost selections or overwrites.
- Numeric operating targets and supported capture cadence are agreed after measurement.
- Remaining limitations are explicit; unsupported workflows are not disguised as passed tests.
- README/ARCHITECTURE/STATUS reflect implemented behavior; owner has reproducible run instructions.

## Deferred backlog

| ID | Candidate | State | Trigger |
| --- | --- | --- | --- |
| F-010 | Dedicated Client Mode | DEFERRED | Owner prioritizes after V1 |
| F-020 | A/B, two-up, four-up comparison | DEFERRED | Stable review/selection workflow |
| F-030 | Ratings, color labels, rejects, multiple reviewers | DEFERRED | Confirm semantics and persistence needs |
| F-040 | Named client/shoot sessions and retention tools | DEFERRED | Owner approves session-management UX |
| F-050 | CSV, richer Lightroom handoff, preview sharing | DEFERRED | Demonstrated filename-only limitations |
| F-060 | Histogram, clipping, EXIF, battery/card status | DEFERRED | Verified metadata/capability path |
| F-070 | External display and Pencil annotations | DEFERRED | Stable rendering/storage foundation |
| F-080 | Preset/LUT preview and local JPEG adjustments | DEFERRED | Owner approves editing scope |
| F-090 | Camera settings, remote shutter, live view | DEFERRED | Separate feasibility study and authorization |

## Work-item update format

- ID and state:
- Implemented change:
- Acceptance criteria met / not met:
- Evidence: validation run ID, source commit, commands/results
- Decision/deviation references:
- Remaining blocker and next action:

Retain failed tests and scope changes. Do not recycle IDs or substitute “code written” for “test passed.”
