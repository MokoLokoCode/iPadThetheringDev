# Decision Register

Baseline: 2026-09-04. This file records why, not current task completion. Accepted decisions are product/engineering constraints; **acceptance is not evidence that hardware supports them**. Proposed implementation choices must be revisited against results.

## Index

| ID | Decision | State |
| --- | --- | --- |
| D-001 | Direct wired iPad client-review companion, not an editor | Accepted |
| D-002 | Public ImageCaptureCore path first, hardware-gated | Accepted approach; feasibility unverified |
| D-003 | Prefer JPEG transfer and protect camera RAWs | Accepted requirement; feasibility unverified |
| D-004 | Diagnostic-first development with explicit gates | Accepted |
| D-005 | Native Swift, SwiftUI shell, no backend | Accepted starting direction |
| D-006 | One selection flag and filename export in V1 | Accepted scope simplification |
| D-007 | User-controlled follow-latest behavior | Proposed |
| D-008 | Lightweight persistent session manifest first | Proposed |
| D-009 | Serialized acquisition and bounded image memory | Accepted principle; implementation proposed |
| D-010 | Retain provenance; distinguish observed from inferred RAW names | Accepted |
| D-011 | Seven-file documentation contract | Accepted |

All records below were initialized on 2026-09-04 from the owner's requirements and approved handoff structure. They are not retrospective claims of implemented changes.

## D-001 — Direct wired review companion

**State:** Accepted. **Basis:** Owner's primary workflow.

Build X-T4 → USB-C → iPad, with physical-shutter capture, immediate preview, review, and selection. Keep final RAW processing in Lightroom.

Alternatives: full RAW editor, desktop relay, cloud review service. These enlarge scope or change the intended portable setup. No backend, account system, or payment model is needed. Any topology change requires owner approval and a new decision.

## D-002 — Public API path before vendor protocol work

**State:** Accepted approach; X-T4 behavior unverified.

Start with ImageCaptureCore discovery, session and catalog APIs, and object/PTP event observation. Prefer documented operations over vendor-specific commands. Sources are linked in README; exact availability and declarations must be checked against the installed SDK.

Alternative: immediately implement a Fujifilm PTP stack. Rejected as premature because the necessary subset is unknown. The public PTP command API is a possible mechanism, not proof that a particular opcode is safe, documented, or supported. If generic object access fails, preserve logs and ask for approval of a bounded investigation.

## D-003 — JPEG preview with RAW safety

**State:** Accepted requirement; storage behavior unverified.

Prefer camera RAW+JPEG with RAW retained on SD and JPEG copied to app storage. Never delete camera objects or enable delete-after-download. Do not configure capture destinations without a separate justified decision and owner consent.

Alternative: transfer/process RAW or use only embedded thumbnails. RAW adds latency and memory cost; thumbnails may not support meaningful focus inspection. Neither is an automatic substitute if JPEG access fails.

Fujifilm's documented tether/FIXED mode caveats mean selecting RAW+JPEG alone is insufficient evidence. V-03 is mandatory before proceeding to a useful-shoot workflow.

## D-004 — Feasibility gates before feature construction

**State:** Accepted. **Basis:** Owner explicitly requested incremental build/test/feedback.

Sequence: SDK/build verification → discovery control → physical-shutter events and RAW safety → JPEG download/display → reliability → review/selections/export.

Alternative: build the complete UI against a fake backend first. Fake tests are useful in limited scope, but cannot advance hardware gates. This reduces the risk of producing a polished app around an unavailable acquisition path.

## D-005 — Native app and minimal framework set

**State:** Accepted starting direction; exact toolchain not selected.

Use Swift and ImageCaptureCore. SwiftUI owns the basic UI; consider UIKit for zoom where it offers reliable behavior. ImageIO is the proposed downsampling mechanism. Do not add Metal, Core Image, a cross-platform framework, or third-party dependencies without a demonstrated need.

The user's backend experience supports a protocol-oriented design, but a native framework adapter avoids hiding Apple's lifecycle rules. Deployment target, Swift language mode, concurrency settings, and signing must be chosen and recorded under P-010.

Do not assume a paid Apple membership. Verify personal-device signing options first; explain any actual paid capability/distribution requirement before adopting it.

## D-006 — One V1 selection flag

**State:** Accepted scope simplification from the approved package proposal.

Use selected/unselected per capture, represented by one consistent icon. Export selected filenames as plain text. Separate photographer favorites, client choices, ratings, color labels, CSV, and multi-reviewer voting are deferred.

This preserves the core Lightroom handoff without ambiguous star-versus-heart semantics. The owner may later request multiple selection dimensions; record that as a scope change rather than quietly overloading the existing flag.

## D-007 — Follow-latest with review protection

**State:** Proposed; confirm during review UI work.

Follow latest by default. Reviewing older images pauses auto-navigation; a visible action resumes it. This prevents a client inspecting focus from being interrupted by new captures.

Alternative: always jump to newest. Simpler, but conflicts with simultaneous review. Evidence needed: owner's response to V-07 UX test. Do not let delayed transfer completion make an older capture appear “latest.”

## D-008 — Session persistence implementation

**State:** Proposed; decide under P-060.

Start with local UUID-based asset directories and a versioned Codable JSON manifest written atomically by a serialized store. Persist selections and provenance, not image pixels in the manifest.

Alternatives: SwiftData or SQLite. They may be preferable for transactional relationships, frequent updates, migrations, or query needs. At 1,000+ captures, measure manifest write latency and crash recovery; if inadequate, adopt a database with a new record. The requirement is durable session state, not JSON itself. Named multi-session management remains deferred.

## D-009 — Bounded acquisition and rendering

**State:** Accepted principle; tuning pending evidence.

One camera transfer at a time initially, generation-scoped callbacks, bounded retry/backlog policy, atomic files, and cost-limited decoded-image caches. Never retain all full-size bitmaps in an ObservableObject collection.

Alternative: parallelize transfers and eager decode. Rejected initially because compatibility and bottlenecks are not measured. Concurrency can increase only with repeatable improvement and no reliability regression. Establish latency/memory/storage baselines under V-09 before promising numeric targets.

## D-010 — Honest source identity and exports

**State:** Accepted.

Use local stable capture IDs and observed source metadata. Treat transient handles and basenames as insufficient identity. Record RAW association as observed/inferred/unresolved; never silently claim that replacing .JPG with .RAF proves a RAW exists.

This is necessary for trustworthy Lightroom handoff, reconnect deduplication, and repeated camera filenames. Warn when plain filenames cannot uniquely identify selected captures; defer richer CSV rather than concealing ambiguity.

## D-011 — Documentation as an operational handoff

**State:** Accepted by owner.

README holds entry context; ARCHITECTURE holds the technical model; DECISIONS holds rationale/history; STATUS is the current checkpoint; PROGRESS is the work backlog; AGENTS defines execution constraints; VALIDATION holds reproducible tests and evidence records.

Do not duplicate current task states across all files. Keep stable IDs and cross-reference them. Supersede decisions explicitly rather than rewriting history to match the latest implementation.

## Open questions

| Question | Resolve through |
| --- | --- |
| Actual SDK signatures, authorization, and callback isolation? | P-010 / V-00 |
| Does tether AUTO expose physical-shutter files? | P-040 / V-02 |
| Is RAW retained, and are JPEG and RAW retrievable/paired as intended? | P-040 / V-03 |
| Does catalog completion occur in tether mode? | P-030/P-040 observations |
| Do volatile buffers require protocol acknowledgments or fetching additional objects? | Observed traces; bounded investigation only if approved |
| JSON manifest versus database? | P-060 / V-08/V-09 |
| Acceptable preview latency, backlog, and storage budget? | Measured V-09 baseline plus owner decision |
| Default JPEG resolution/quality and full-pixel zoom behavior? | V-04/V-07 measurements with actual X-T4 files |

## New decision / deviation template

### D-NNN — Short title

- Date:
- State: proposed / accepted / rejected / superseded
- Owner/approval, if needed:
- Context and evidence: test IDs, run records, source links, SDK versions
- Decision:
- Alternatives considered:
- Consequences and migration/rollback implications:
- Supersedes / superseded by:
- Affected work items and architecture sections:

For deviations, explicitly state the earlier assumption, what disproved it, and whether owner approval is needed. Never erase failed experiments or uncertain results by converting them into accepted claims.
