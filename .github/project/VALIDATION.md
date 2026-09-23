# Validation

Procedures have stable IDs (`V-NNN`). PROGRESS.md evidence cites these.

## Hardware setup

| Item | Requirement |
| --- | --- |
| Camera | The model named in the relevant `.github/agents/<vendor>/AGENTS.md`, battery ≥ 50%, card inserted, tethering mode enabled |
| iPad | The model named in that adapter's instructions, ≥ 2 GB free, Low Power Mode off |
| Cable | The exact cable and adapter named in that adapter's instructions |
| Environment | Well-lit surface so test shots are distinguishable |

## Safety checks (run before every session)

- [ ] Use expendable captures on a backed-up/test card. Normal test exposures write files; tests must not delete or format camera media.
- [ ] iPad session directory is empty or backed up.
- [ ] Cable is undamaged; connectors seat fully.
- [ ] Select the connection mode specified by that adapter's procedure. Sony uses explicit `PC Remote`; Fujifilm uses `USB CARD READER` for the control and then `USB TETHER SHOOTING AUTO`. Sony's ban on its automatic USB mode does not prohibit Fujifilm's named AUTO tether mode.
- [ ] Pass the relevant adapter's RAW-retention gate before any real shoot. Sony uses S-G4 / V-007 and its `Still Img. Save Dest.` setting; Fujifilm uses F-G2 card inspection. Do not apply Sony setting names to the X-T4 or change destinations from the app.

## Procedure scope

V-006 and V-007 are Sony-specific. Fujifilm's setup, card-reader control, AUTO
physical-shutter test and RAW inspection are defined in
[F-G0–F-G3](../agents/fujifilm/AGENTS.md#gates-and-work-sequence).
Use the applicable shared validation procedures for common features after that
adapter's prerequisites pass. A Sony result cannot clear an F-GN gate, or vice versa.

## Procedures

### V-001: Camera detection
1. Launch app with no camera attached — expect "No camera" state.
2. Connect camera, power on.
3. **Expected:** camera model name shown within 5 s.
4. **Failure interpretation:** no name → transport enumeration; wrong name → identity parsing.

### V-002: Single capture transfer
1. Start a session. Take one shot.
2. **Expected:** file appears in session folder, byte-identical to the camera's copy.
3. **Failure interpretation:** missing file → ingest; size mismatch → streaming/atomic write.

### V-003: Preview latency
1. Take one shot; start a stopwatch at shutter release.
2. **Expected:** preview visible within N s (N set in PROGRESS.md M3).
3. **Failure interpretation:** file present but no preview → preview pipeline; both slow → transport.

### V-004: Disconnect during transfer
1. Start a burst of 5 shots; pull the cable during shot 3.
2. **Expected:** shots 1–2 intact, no partial file for 3, UI shows "reconnecting".
3. Reconnect.
4. **Expected:** session resumes; shots 4–5 (still on card) are not required to auto-transfer in MVP.
5. **Failure interpretation:** partial file present → atomic write broken; app crash → disconnect handling.

### V-005: Memory under sustained shooting
1. Take 50 shots over ~5 minutes.
2. **Expected:** no memory warning; app remains responsive.
3. **Failure interpretation:** growth per shot → preview cache/eviction.

### V-006: Desktop `PC Remote` baseline (no app code)
Establishes that the camera can be tethered at all, and what the vendor handshake
has to achieve, before any iPad work. Runs on the Mac. Covers W-006.

1. Set `MENU → Setup → USB Connection → PC Remote`. Connect the camera to the Mac.
2. **Expected:** LCD shows "Connecting... USB" and stays there with no host software running.
3. Launch Sony Imaging Edge Desktop (Remote).
4. **Expected:** the camera leaves "Connecting..." and appears in Remote; the shutter fires from both the camera body and the app.
5. With `Still Img. Save Dest.` at its default, take one shot. Record where the file lands (host, card, or both).
6. Set `Still Img. Save Dest. = PC+Camera`, take one shot, and record the same.
7. **Failure interpretation:** never leaves "Connecting..." → cable/port/mode, not software; leaves it but no shutter → camera-side `PC Remote` restriction; card empty in step 5 → confirms the **PC Only** default and the RAW-safety caveat in the rig README.

### V-007: RAW retention on the card (rig gate S-G4)
Safety gate. Must pass before the app is used on anything irreplaceable. Covers W-011.

1. `Still Img. Save Dest. = PC+Camera`. Start a session from the iPad; take 3 shots.
2. Eject the card and read it on the Mac.
3. **Expected:** 3 `DSC#####.ARW` files present, and their numbers match the `DSC#####.JPG` names the iPad received.
4. **Failure interpretation:** card empty → save destination reverted or the app changed it; ARW present but numbering unmatched → pairing logic cannot rely on basename; missing subset → transfer is racing the card write.

### V-008: Disconnect, access, and lifecycle recovery
Fault simulation first; physical idle/reconnect tests only afterward, and only on
expendable captures once the relevant RAW-safety gate has passed (Sony V-007/S-G4;
Fujifilm F-G2). Covers W-014.

| Case | Expected result |
| --- | --- |
| Disconnect while idle | Clear disconnected state; existing images and selections remain |
| Simulated mid-transfer disconnect | Transfer marked interrupted; partial file never treated as success |
| Late completion from an old connection | Generation check rejects the stale mutation |
| Reconnect | New session opens; reconciliation does not duplicate completed captures |
| Authorization denied or restricted | Clear actionable state; no infinite retries |
| App backgrounded / device locked | Observed suspension behavior documented; no claim of background acquisition |
| Return to foreground | Explicit session revalidation or reconnect |
| Low storage / write failure | Visible error; no overwrite, no falsely persisted success |
| Download or session error | Bounded retries with an error code and visible retry state |
| Repeated removal/close callbacks | Idempotent teardown, no crash |

**Pass:** correct state transitions, durable data preserved, no stale writes, no silent loss. Recheck card contents after any physical fault test. Captures stranded in the camera's buffer are documented, not hidden.

### V-009: Identity, reconciliation, and RAW pairing
Unit tests over fake event sequences, plus real observed traces. Covers W-013, W-014.

Exercise: initial catalog vs. new capture; duplicate add callbacks; repeated basenames across folders or cards; reused handles after reconnect; RAW before JPEG; JPEG before RAW; missing RAW object; temporary filename then rename; unknown type; delayed old events; reconnect with a pending object that is available, and one that is not.

**Pass:** stable capture IDs, no accidental overwrite or collapse, no selection lost to a rename, honest observed/inferred/unresolved pairing, no filename-only identity. Every deduplication assumption has a test and a documented scope.

### V-010: Review interactions
UI tests plus the owner's hands-on review on the iPad. Covers W-015.

1. Capture several images; the newest successful capture is visible while follow-latest is ON.
2. Swipe to an older image and zoom; a new capture must **not** steal review focus.
3. Resume live/newest explicitly; the newest capture appears and zoom resets predictably.
4. Verify pinch and double-tap reveal the downloaded JPEG's real detail, not an enlarged thumbnail.
5. Scroll the filmstrip during ingestion; row identities stay stable, no flicker or selection jumps.
6. Check portrait/landscape and accessible control labels. A failed transfer leaves the last good preview visible with an honest error state.

**Pass:** the owner can inspect older images and return to shooting without losing context. Confirm or revise **D-007** explicitly on the basis of this run.

### V-011: Persistence, selection, and export
Storage unit tests plus an end-to-end owner check. Covers W-013, W-016.

1. Select several captures, including nonadjacent ones; verify selected and total counts.
2. Navigate, ingest another capture, disconnect/reconnect, and relaunch. Selections and local previews must survive all four.
3. Simulate process interruption around asset and manifest writes; recover, or surface a repairable state — never silently lose a selected capture.
4. Export zero selections, then a normal set. Confirm deterministic order and exact observed filenames.
5. Test observed RAW pairs, inferred candidates, unresolved pairs, duplicate basenames, and mixed-case extensions. No inferred RAW filename (`.ARW`, `.RAF`, or otherwise) is presented as observed; ambiguities are warned about.
6. Compare an exported sample against the actual card contents and a manual Lightroom lookup. This validates the handoff, not catalog integration.

**Pass:** durable selections, honest and stable exports, no silent deduplication of distinct selected captures, reported persistence failures.

### V-012: Capacity, latency, and reliability baseline
Local/simulated stress, plus a separately labeled hardware soak. Covers W-017.

- Test 50, 250, and 1,000+ realistic capture records. **State for each dataset whether it is synthetic, replayed, or actually tethered.**
- Measure peak and steady memory, decoded-cache cost, disk usage, selection-write latency, queue depth, failures, and p50/p95 event-to-display latency.
- Scroll, review, and zoom during ingestion; trigger memory warnings; simulate low storage safely.
- Verify decoded bitmap memory is bounded by the active viewing window rather than total capture count. Persisted metadata may scale with count — explain that separately.
- Agree the physical soak size with the owner. Do not require 1,000 real shutter actuations to validate a 1,000-row filmstrip, and do not claim physical 1,000-capture reliability from a synthetic dataset.

**Pass:** bounded rendering memory, no known selection loss or overwrite, explicit measured limits. Numeric responsiveness and reliability targets are agreed **after** this baseline and recorded in DECISIONS.md. Report failed cases, not just averages.

Note on timing vocabulary: instrument observed event → queue → transfer completion →
first display with monotonic timestamps. True shutter-to-event latency needs external
observation; app-only timings must not be called shutter latency.

## Evidence records

PROGRESS.md cites these. One record per run; keep failed runs.

### DOC-20260923-FUJI — Workstream activation

- Work: W-019; decision D-013; documentation only, not a hardware run.
- Source: owner's 2026-09-23 instruction assigning himself Fujifilm and his colleague Sony. No colleague identity or tooling preference inferred.
- Changes: ownership recorded; Fujifilm W-020–W-024 and F-G0–F-G3 defined; shared prerequisites scoped per bench; shared safety instructions distinguish Sony settings from Fujifilm modes.
- Validation: `git diff --check` passed; all 21 relative link targets in the eight changed Markdown files resolved; W-NNN table rows are unique and W-019–W-024 are present. No Swift files or Xcode settings changed; no compilation, simulator run, or hardware test performed.
- Outcome: documents prepared for review. Every Fujifilm hardware gate remains pending.

### RUN-YYYYMMDD-NN — template

| Field | Value |
| --- | --- |
| Procedure | Applicable V-NNN or F-GN; work item W-NNN |
| Date / operator | |
| Adapter | e.g. `sony` / `fujifilm` |
| Camera mode | Exact vendor mode and applicable capture/card settings; do not substitute another vendor's names |
| Build / commit | |
| Environment | iPadOS, Xcode, camera firmware |
| Result | Pass / Fail / Partial |
| Observations | What was actually seen, including timings |
| Deviations from procedure | |
| Follow-up | Work item or decision raised |
