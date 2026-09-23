# Decisions

Each decision gets a stable ID. Never delete an entry — mark it **Superseded by D-NNN** instead.

## Template

```
## D-NNN: <title>
- Status: Accepted | Superseded by D-NNN | Rejected
- Date: YYYY-MM-DD
- Context: why a decision was needed
- Decision: what we chose
- Alternatives: what else was considered
- Rationale: why this one
- Deviations: any known departures from the decision in the code, and why
```

## D-001: Repository documentation structure
- Status: Accepted
- Date: 2026-09-20
- Context: Need a shared, agent-readable source of truth for scope, design, and progress.
- Decision: Seven top-level markdown files (README, ARCHITECTURE, DECISIONS, STATUS, PROGRESS, AGENTS, VALIDATION), each with a fixed purpose (see README documentation map).
- Alternatives: Single README; wiki; issue tracker only.
- Rationale: Files live with the code, are diffable, and give an implementing agent a fixed reading order.
- Deviations: None.

## D-002: The Sony adapter uses ImageCaptureCore plus a vendor PTP handshake in PC Remote
- Status: Accepted
- Date: 2026-09-22
- Context: W-002. The target camera is a Sony a7R III (D-004 rig). Its USB modes were surveyed on a Mac on 2026-09-20: `Mass Storage` and `MTP` both **lock the shutter**, so neither supports live capture; `MTP` also exposes slot 1 only. `PC Remote` is the only mode that permits tethered shooting, and it sits on "Connecting... USB" indefinitely until the host completes Sony's proprietary PTP handshake.
- Decision: Scoped to the **Sony adapter**; it says nothing about how the Fujifilm adapter reaches its camera. The adapter opens an `ImageCaptureCore` session against the camera in `PC Remote` mode and drives Sony's vendor PTP operations through `ICCameraDevice.requestSendPTPCommand` to complete the handshake and receive capture events. No third-party SDK or library is taken as a dependency. The handshake stays inside the adapter — the shared layers above the transport contract must not learn that it exists.
- Alternatives:
  - Standard PTP/MTP via ImageCaptureCore alone — **ruled out by observation**: the shutter is locked in `MTP`.
  - `Mass Storage` polling — **ruled out**: shutter locked; a card reader, not a tether.
  - Wi-Fi / Sony Imaging Edge Mobile protocol — deferred; the project's stated goal is a wired tether, and this path is undocumented in a different way.
  - Vendoring libgphoto2 or a commercial SDK — ruled out for now; adds a dependency (which AGENTS.md gates on a decision) and Apple's public API is believed sufficient.
- Rationale: It is the only mode that can work, and it is reachable from public Apple API. Two independent existence proofs that the vendor handshake is achievable this way: the libgphoto2 Sony driver documents the operations, and Cascable ships a7R III tethering on iPadOS. This is real adapter work, not a thin shim, and the estimate in PROGRESS.md should reflect that.
- Supersedes: the earlier X-T4 design package held the opposite position — *public API path before vendor protocol work*, i.e. prefer documented operations and treat a vendor PTP stack as premature. That was the right default with no evidence. The 2026-09-20 mode survey removed the option: on this body there is no documented path to a live shutter, so the vendor handshake is the entry condition rather than an optimization. The underlying caution still applies — a public command API is a mechanism, not proof any particular opcode is safe or supported.
- Deviations: None yet — no code exists. **Unverified on the iPad path**: rig gates S-G1 (discovery/session) and S-G2 (handshake) are blocked on the Camera Adapter purchase. If S-G2 fails, this decision must be revisited rather than worked around.

## D-003: Captures are stored in a Files-app-visible app container
- Status: Accepted
- Date: 2026-09-22
- Context: W-003. ARCHITECTURE.md left "app sandbox vs. Files-app-visible location" open. The owner's downstream workflow is Lightroom, so captures must be able to leave the app.
- Decision: `Sessions/<yyyy-MM-dd_HHmmss>/` lives in the app's Documents directory, exposed to the Files app via `UIFileSharingEnabled` and `LSSupportsOpeningDocumentsInPlace`. The session store remains the only component that writes there.
- Alternatives:
  - Private sandbox — rejected: every route out of the app would need an export feature built first, which is scope the MVP does not have.
  - Photos library — rejected: AGENTS.md forbids touching the user's photos outside the app's session directory.
- Rationale: Hands JPEGs to Lightroom, AirDrop, and Finder with no export code, which keeps the MVP small. The cost is accepted deliberately.
- Deviations: None yet. **Consequence to honor in code**: files are now user-mutable, so `session.json` must tolerate captures being renamed or deleted underneath it — it is a record of what was transferred, not an assertion about what is currently on disk.

## D-004: Camera-specific material lives with its adapter, not in the shared documents
- Status: Accepted
- Date: 2026-09-22
- Context: The project targets more than one camera. An earlier revision of this decision organized camera facts by *rig* (`rigs/<camera>-<ipad>/`), on the assumption of a single target pairing. That is the wrong axis: the README's integration model treats Fujifilm and Sony as parallel **adapters** against one shared application, and the iPad is a property of the developer's bench, not of the adapter.
- Decision: Follow the layout the README specifies.
  - Root holds the human-facing `README.md`, a small `AGENTS.md` that routes, and `.gitignore`.
  - `.github/project/` holds the shared, camera-neutral documents about the product — ARCHITECTURE, DECISIONS, PROGRESS, STATUS, VALIDATION — and they are **not** duplicated per camera.
  - `.github/agents/shared/AGENTS.md` holds the rules every adapter follows; `.github/agents/<vendor>/AGENTS.md` holds one vendor's equipment, observed camera behavior, gates (`<X>-GN`), and constraints.
  - `.github/CONTRIBUTING.md` holds process — how contributors work, rather than what is being built. It is deliberately not in `.github/project/`, which is about the product, and not at the root, which the README limits to the three files above. The name is GitHub's: as a recognised community health file it is linked automatically when someone opens a pull request or an issue, which puts the rules in front of a contributor at the moment they would otherwise break them. Previously `git-discipline.md`, then `GIT.md`, both at the root and in neither case listed in the README's layout.
  - Superseded and source material is not kept in the working tree. It stays in git history, cited by revision where it is relevant.
  - The root `AGENTS.md` references `.github/CONTRIBUTING.md` with `@` rather than a markdown link. Verified on Claude Code 2.1.280, in an isolated directory with no `CLAUDE.md` and all tools disabled: an `@` path in `AGENTS.md` is loaded into context, including one pointing into a subdirectory, while a markdown link is not. The contributing rules are the ones that cause damage when skipped, so they are loaded unconditionally; items 1-4 stay links because those documents only need to be findable. Tools that do not process imports see a literal path, which still reads as a pointer. Do not "fix" this back to a link.
- Alternatives:
  - Organize by rig (`rigs/<camera>-<ipad>/`) — the superseded form of this decision. It cannot express a shared application with two adapters, and it puts the iPad in the taxonomy where it does not belong.
  - Duplicate the five shared documents per camera — forbidden by the README, and it is what produced the parallel doc sets this decision cleans up.
  - Everything in the root files — what D-001 produced; it did not survive a second camera.
- Rationale: The split matches how the code will be split. If a fact would change when the *adapter* changes, it belongs with that adapter; if it holds above the camera transport boundary, it is shared. Keeping the documentation axis identical to the architecture axis means neither can drift from the other unnoticed.
- Deviations: None. Supersedes the `rigs/<camera>-<ipad>/` form, which never reached `main`. An earlier revision of this entry also listed a `docs/history/` directory; that material now lives in git history instead.

## D-005: RAW stays on the card; the app transfers JPEG only
- Status: Accepted
- Date: 2026-09-22
- Context: Harvested from the earlier X-T4 design package (its D-003), which this project supersedes on camera specifics but not on principle. The rig makes the hazard concrete: in `PC Remote` the a7R III defaults `Still Img. Save Dest.` to **PC Only**, so captures are not written to the card at all unless the setting is changed.
- Decision: The camera shoots RAW+JPEG; RAW is retained on the SD card and the app transfers only the JPEG. The app **never** deletes camera objects, never enables delete-after-download, and never changes the camera's capture destination. `Still Img. Save Dest. = PC+Camera` is the photographer's setting to make, verified by V-007 before any real shoot.
- Alternatives: transfer RAW (latency and memory cost the MVP cannot absorb); use embedded thumbnails only (may not support focus inspection).
- Rationale: The photographer's negatives are the one irreplaceable thing in the system. The app is a review companion, not the system of record. This also matches AGENTS.md's rule against touching photos outside the session directory.
- Deviations: None yet. Unverified — V-007 / rig gate S-G4 has not been run.

## D-006: One selection flag in V1
- Status: Accepted
- Date: 2026-09-22
- Context: Harvested from the X-T4 package (its D-006). Review needs a way to mark keepers for the Lightroom handoff.
- Decision: One selected/unselected flag per capture, one consistent icon. Export is plain text, one filename per selected capture, in stable capture order.
- Alternatives: stars, color labels, separate photographer/client picks, multi-reviewer voting, CSV — all deferred (see the deferred backlog in PROGRESS.md).
- Rationale: Preserves the Lightroom handoff without ambiguous star-versus-heart semantics.
- Deviations: None yet. If more selection dimensions are wanted later, record it as a scope change rather than quietly overloading this flag.

## D-007: Follow-latest, with review protection
- Status: Proposed — confirm during review UI work
- Date: 2026-09-22
- Context: Harvested from the X-T4 package (its D-007). A client inspecting focus on an older frame should not be yanked away by the next capture.
- Decision: Follow the latest capture by default. Navigating to an older image pauses auto-advance; a visible control resumes it.
- Alternatives: always jump to newest — simpler, but conflicts with reviewing while shooting continues.
- Rationale: Reviewing and shooting happen at the same time; that is the point of the product.
- Deviations: Still **Proposed**, not Accepted — it needs the owner's reaction to a real review session before it is settled. Note also that a delayed transfer must not let an older capture masquerade as "latest".

## D-008: Honest capture identity and export
- Status: Accepted
- Date: 2026-09-22
- Context: Harvested from the X-T4 package (its D-010). PTP object handles may be session-scoped or reused, and camera filenames repeat once the counter rolls over.
- Decision: Every capture gets a locally generated stable UUID. Source filenames and handles are recorded as observed metadata, never used as identity and never used directly as filesystem path components. RAW association is recorded with explicit confidence: **observed**, **inferred**, or **unresolved**.
- Alternatives: basename identity (collapses distinct captures); assuming `DSC00123.JPG` implies `DSC00123.ARW` exists.
- Rationale: The export's whole value is that the photographer can trust it against their actual card. Silently swapping an extension and presenting the result as verified would destroy that. Duplicate or ambiguous names get a warning, not a silent drop; an empty selection says so explicitly.
- Deviations: None yet. This is a handoff aid for manual Lightroom lookup — not XMP sync, not automatic catalog integration.

## D-009: Bounded acquisition and rendering
- Status: Accepted — numeric tuning pending measurement
- Date: 2026-09-22
- Context: Harvested from the X-T4 package (its D-009). Root ARCHITECTURE.md stated memory limits but left the acquisition policy open.
- Decision: One camera transfer at a time to start. Callbacks are scoped to a connection generation so a late reply from a dead connection cannot mutate its replacement. Retry and backlog are bounded. Files are written atomically. Decoded-image caches are cost-limited; memory depends on the active viewing window, not the number of captures taken.
- Alternatives: parallel transfers and eager decode — rejected for now because neither the camera's tolerance nor the actual bottleneck has been measured.
- Rationale: On an A12 iPad over a USB 2.0 adapter link, the transport is the likely bottleneck and parallelism mostly buys memory pressure. Concurrency can increase later, but only with a repeatable measured improvement.
- Deviations: None yet. Numeric targets (preview latency `N`, cache size, queue depth) are deliberately unset until the V-012 baseline exists — do not fabricate them.

## D-010: Shared documents record observations, not inferences about people
- Status: Accepted
- Date: 2026-09-22
- Context: More than one person works in this repository, and its documents are written partly by agents. Two near-misses prompted this. A `.gitignore` comment asserted that a shared `.claude/settings.json` "is the shared half and SHOULD be committed" — a file that has never existed here. And the Fujifilm adapter instructions read "No one is working this adapter", which is a claim about a colleague's activity, written into their own repository, unverifiable by the person making it. The contributing guide (then `GIT.md`) separately invited filling in a second contributor's branch namespace on their behalf.
- Decision: Shared documents assert what the repository shows. Claims about a person's state, intent, preferences, or conventions are either attributed to a dated source (a review, a message, a commit) or left blank. Blank is a valid, accurate value. The operational form of this rule lives in `.github/agents/shared/AGENTS.md` → *Claims about people*.
- Alternatives:
  - Rely on ordinary care — rejected; both near-misses were written by someone being careful, and neither produced a failing test.
  - Ban speculation about people entirely — rejected; attributed positions are genuinely useful. "Asked for in review on PR #2" is exactly the kind of fact a decision record should hold.
- Rationale: It is the existing evidence discipline applied to people instead of hardware. The repository already refuses to call a capability verified without a device run; a claim about a colleague deserves the same sourcing, and has weaker natural defenses — hardware guesses eventually fail loudly, guesses about people just sit there and get built upon.
- Deviations: None outstanding. Three instances prompted or followed this entry, all corrected. The third is instructive: the rule as first written said "state your own and leave theirs open", and the contributing guide duly named one contributor's branch namespace as the example. That satisfies the letter of the rule and still gives a co-owned document an owner. The rule now covers filling in your own conventions too, and the guide gives the shape with no example.

## D-011: Local hooks are opt-in reminders; enforcement belongs in CI
- Status: Accepted
- Date: 2026-09-22
- Context: `.github/CONTRIBUTING.md` says `main` is protected and reached only through pull requests. Nothing made that true locally. One contributor works largely through agents and wanted repo-embedded guards; the risk is that guards written for one person's workflow become obligations on the other's hand-written commits.
- Decision: Committed hooks live in `.github/hooks/` and are activated per clone with `git config core.hooksPath .github/hooks`. They stay small and fast, and they are reminders rather than authorities — `--no-verify` and a documented environment variable both bypass them. Any rule that must hold for everyone goes in GitHub branch protection or CI, never in a local hook.
- Alternatives:
  - `.githooks/` at the root — the conventional path, rejected because it would be a fourth root entry against the README's layout. `core.hooksPath` accepts any path, and `.github/` is where the README puts detail.
  - Automatic installation from a script or a session hook — rejected. A repository that silently reconfigures a contributor's git is worse than one that asks.
  - Enforce the same checks in a hook and in CI — rejected for now; duplicated enforcement drifts, and a slow pre-commit hook trains people to pass `--no-verify` habitually.
- Rationale: The pattern is taken from the `agentic-engineering-platform` repository, where the installed pre-commit hook is four lines and the three-hundred-line layout validator runs in CI instead. That split is the useful part: a local guard has to be cheap enough that nobody wants to skip it, and anything expensive or mandatory has to run somewhere a contributor cannot bypass.
- Deviations: None outstanding, but two limits are inherent rather than incidental.
  - `core.hooksPath` resolves against the working tree, so a committed hook only exists on branches that contain it. Verified in a clean clone with the config active: standing on `main` before this hook merged, a commit to `main` succeeded, because the file was not there to run. Any branch cut before a hook lands is unguarded by it, and so is `main` until the hook merges.
  - Only one hook exists (protect-main), and there is no CI. Server-side enforcement does exist and predates this entry: the repository ruleset **Protect Main** has been active since 2026-09-20, targeting `refs/heads/main` with no bypass actors, and blocks deletion and non-fast-forward pushes while requiring a pull request with one approving review, stale-review dismissal on push, and resolved review threads. An earlier revision of this entry stated that no branch protection was set up; that was asserted without checking and was wrong.
  - What the ruleset governs is the remote. It cannot stop a local commit on `main`, only the push. That is the hook's actual and narrower job: fail at commit time rather than at push time, so the work is never on the wrong branch in the first place. Treat hooks as ergonomics; the ruleset is what stands between `main` and a mistake.

<!-- TODO next decisions: min iPadOS version, UI framework, session persistence
     mechanism (JSON manifest vs. SwiftData/SQLite — decide with real data volume,
     see W-013), and numeric performance targets once V-012 has a baseline. -->
