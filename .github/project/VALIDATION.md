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

### V-013: Mac event rehearsal (D-015)
Sony Mac bench only. Covers W-027. Expendable shots and a backed-up card.

1. Pass V-006 first. `Still Img. Save Dest. = PC+Camera`.
2. Launch CameraTether; **Copy Path** of the Inbox and set it as Imaging Edge Remote's save folder, JPEG only to the PC.
3. Take 10 shots. **Expected:** each appears within a few seconds and shows a countdown.
4. Delete 3 before the countdown ends, delete 1 after it uploaded, and restore 1 with ⌘Z.
5. **Expected:** the iCloud Drive session folder holds exactly the 7 kept JPEGs; `Rejected/` holds 3; the card holds all 10 ARW + JPG.
6. Quit and relaunch mid-session. **Expected:** the same shots and states reappear.
7. **Failure interpretation:** shot never appears → Imaging Edge folder or JPEG setting; it appears late → file-completion wait; cloud copy survives a delete → sync client lag, which must be visible on the cloud side before the event is relied on.

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

### RUN-20260924-F0 — Fujifilm launch and browser preparation

| Field | Value |
| --- | --- |
| Procedure | W-004 launch evidence; W-020/F-G0 partial; W-021 browser preparation |
| Date / operator | 2026-09-24 / Mario's report; code authored remotely on Linux |
| Adapter | Fujifilm X-T4, firmware 2.12 (owner-reported) |
| Camera mode / connection | USB CARD READER selected during earlier Mac-connected test; no physical X-T4 → iPad camera run yet |
| Environment | Xcode 27 reported; physical iPad Air 4 launched Diagnostic View; physical iPadOS and exact cable still unknown. iPadOS 27 was simulator runtime |
| Observed result | Static Diagnostic View appeared on the physical iPad; no discovery outcome reported |
| Code verification | Project parse, source membership and whitespace checked on Linux; no Xcode/SDK compile or real USB execution here |
| Follow-up | Build browser branch on physical iPad; share log for X-T4 direct USB connection in CARD READER. Then add session/catalog/event bridge |

### RUN-20260924-F1 — Discovery probe compiler feedback

| Field | Value |
| --- | --- |
| Procedure | W-021 Xcode build of Fujifilm browser probe |
| Operator | Mario, physical iPad development environment |
| Observed result | Build failed in `FujifilmDiscovery.swift` at `deviceBrowserDidEnumerateLocalDevices`: `Cannot override 'deviceBrowserDidEnumerateLocalDevices' which has been marked unavailable` |
| Response | Removed the unavailable callback and its expected log line from the hardware instructions. Camera add/remove callbacks remain the discovery signal. |
| Follow-up | Rebuild PR #9 and report the first remaining compiler error or the on-device browser log; USB detection has not yet been validated. |

### RUN-20260924-F2 — X-T4 physical iPad USB discovery

| Field | Value |
| --- | --- |
| Procedure | W-021 browser observation; discovery portion of F-G1 |
| Date / operator | 2026-09-23 23:11–23:13 local, 2026-09-24 UTC / Mario |
| Camera / transport | `X-T4`, `ICTransportTypeUSB`; X-T4 USB mode and cable were not stated with this log |
| Observed result | `Browser starting`, then `Device added: X-T4; transport=ICTransportTypeUSB; moreComing=false` and `Fujifilm candidate identified; session not opened yet`. After Stop/Start, the same add and identification occurred again. |
| Conclusion | **Discovery passes** on the physical iPad. The Stop/Start sequence shows re-enumeration by the browser, not physical USB disconnect/reconnect or session access. |
| Follow-up | Build the D-017 session probe; report open/close or error lines, X-T4 USB mode, physical iPadOS, and connection path. Do not infer file or capture-event access yet. |

### RUN-20260924-F3 — X-T4 physical iPad session and reconnect

| Field | Value |
| --- | --- |
| Procedure | W-021 session probe; partial F-G1 |
| Date / operator | 2026-09-24 13:02–13:07 local / Mario |
| Environment | Physical personal iPad with merged PRs #9/#10; X-T4 firmware 2.12 previously reported. iPadOS, exact cable, USB mode and card contents not supplied with this run. |
| Observed result | A first Start/Stop produced only browser start/stop. On a later connection, `Device added: X-T4; transport=ICTransportTypeUSB`, followed immediately by `Camera session opened; hasOpenSession=true`. Device delegate removal appeared at 13:03:23. The log later records session opens at 13:06:16, 13:06:40 and 13:07:09, with device removals between the latter connections. |
| Conclusion | **Session opening passes** on the physical iPad; removal and physical reconnection can lead to another session. Browser Stop/Start while the cable remained connected did not visibly rediscover a camera in this run. The log lacks a session-close callback, so a clean close on Stop is not established. No catalog or new-photo signal was implemented in this build. |
| Follow-up | Build D-018 catalog/item/PTP observer. In USB CARD READER, compare sample names with known files, record catalog completion and idle reconnect; collect physical iPadOS, camera mode, cable and build result. |

### DOC-20260923-FUJI — Workstream activation

- Work: W-019; decision D-013; documentation only, not a hardware run.
- Source: owner's 2026-09-23 instruction assigning himself Fujifilm and his colleague Sony. No colleague identity or tooling preference inferred.
- Changes: ownership recorded; Fujifilm W-020–W-024 and F-G0–F-G3 defined; shared prerequisites scoped per bench; shared safety instructions distinguish Sony settings from Fujifilm modes.
- Validation: `git diff --check` passed; all 21 relative link targets in the eight changed Markdown files resolved; W-NNN table rows are unique and W-019–W-024 are present. No Swift files or Xcode settings changed; no compilation, simulator run, or hardware test performed.
- Outcome: documents prepared for review. Every Fujifilm hardware gate remains pending.

### RUN-20260923-01 — V-006 desktop `PC Remote` baseline (Sony)
- Bench: MacBook Pro M2 Pro (2023), macOS 26.6.2; a7R III firmware 3.10; Imaging Edge Remote 4.1.00.03062.
- Connection: Mac USB-C → USB-C-to-Lightning cable → Lightning-to-USB-C adapter → camera USB-C. Enumerated as `ILCE-7RM3` (0x054C:0x0C33) at 480 Mb/s. A different path through a USB-C hub/dongle did not enumerate the camera (only a `VLI USB2.0 BILLBOARD` device appeared); Apple Image Capture was quit before Remote connected.
- Result: **pass.** LCD left "Connecting... USB"; Remote showed live view. `Still Img. Save Dest.` was found already at PC+Camera, so the factory-default behavior (step 5) was not observed; the shot landed on the Mac and the card, checked at both. With File Format RAW only the Mac received ARW; after File Format RAW & JPEG and `RAW+J PC Save Img = JPEG Only`, the card held RAW + JPEG and the Mac received JPEG only.

### RUN-20260923-02 — Imaging Edge + CameraTether on the Mac (Sony; partial V-013)
- Bench as RUN-20260923-01; CameraTether debug build from `julian/mac-event-cull`, Xcode 27.0; outbox in iCloud Drive.
- Hang: Remote's save folder changed to the session Inbox mid-session, then one shot → Remote hung and was closed; shot lost on Mac and card (see Sony instructions). Recovered by battery pull; PC transfer setting had reverted.
- Test A (CameraTether closed, Inbox set before shooting): Remote stayed responsive; JPEG saved to Inbox. Path with a space is fine.
- Test B (CameraTether running): new shot appeared with countdown and published to iCloud Drive; the ARW from the reset shot was ignored as designed.
- Delete before upload: never reached iCloud Drive. Delete after upload: removed from the local iCloud Drive folder in ~2 s (cloud-side propagation not measured). ⌘Z restore: republished immediately.
- Relaunch mid-session (V-013 step 6): pass — shots and states restored; the pending shot's countdown restarted and it then published. Cloud-side sync observed as effectively immediate.
- Ten-shot run: pass as reported by the Sony lead — no transfer or display lag noticed, deleted subset never uploaded, all shots persisted on the card. Exact per-file counts were not recorded.
- V-013: **pass** (all steps).
- Conclusion: CameraTether was not involved (Test B). The hang followed a save-folder change made while connected — one occurrence, not reproduced, so the cause is suspected, not proven. Workaround: do not change Remote's save folder while the camera is connected; disconnect in Remote first.

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
