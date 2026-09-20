# Validation Plan and Evidence

Baseline: 2026-09-04. **No application tests or hardware runs have been performed in this package.** Procedures below are plans, not results.

## Safety and prerequisites

- Use expendable photographs and a backed-up/test SD card. Do not format or erase media as part of these procedures.
- Use a charged camera battery and known data-capable cable, initially direct with no hub. Fujifilm's [X-T4 USB guidance](https://fujifilm-dsc.com/en/manual/x-t4/connections/computer/index.html) specifies a suitable data cable no longer than 1.5 m.
- Begin with camera USB power supply OFF as a controlled baseline, and record the setting. Any later change is a separate test variable.
- Record USB mode, image quality, firmware, iPadOS, SDK/build, card layout, and cable for every run. Set RAW+JPEG for tether tests; record exact JPEG quality/size.
- Do not assume AUTO guarantees SD retention. Avoid FIXED initially; see [Fujifilm connection settings](https://fujifilm-dsc.com/en/manual/x-t4/menu_setup/connection_setting/index.html).
- For normal disconnect, let camera activity/transfer finish and follow the manufacturer's shutdown instructions. Unplugging during transfer is a fault test with potential loss/corruption; begin with simulated faults and use only expendable data if physical fault injection is approved.
- Install from Xcode first. Use supported wireless debugging or the in-app text log while the iPad USB port is occupied by the camera.
- Keep photos/traces local. Share only necessary sanitized logs; remove serial numbers or sensitive filenames where appropriate.

## Required log schema

Record unique entry ID, wall timestamp, monotonic elapsed time, build/run ID, connection generation, camera mode, event category, source object identifier if available, exact observed filename, format/size when available, and full error domain/code/message. Do not use localized error text alone.

Categories: browser start/stop; device add/remove; authorization/restriction; open/close; generic ready; catalog ready; capture marker; item add/rename/remove; raw PTP event bytes; queue/download completion; local commit; first display; retry/cancel; app lifecycle.

Logs must be bounded in memory and exportable. A log timestamp is not the camera's shutter timestamp. Keep camera EXIF times separate from app monotonic measurements.

## V-00 — SDK, build, and installation

**Level:** SDK inspection + compiler + physical app launch. **Tasks:** P-010, P-020.

1. Record toolchain, deployment target, Swift language mode, default isolation/strict concurrency settings, and signing configuration.
2. Verify relevant current API declarations, delegate requirements, authorization/privacy behavior, and availability in Apple's docs and installed SDK. Save source links/notes.
3. Build the probe for the physical iPad. Record the exact command or Xcode scheme/destination and the result.
4. Launch without a camera: app remains stable, shows browsing state, and allows bounded log export.
5. Verify start/stop idempotency and capture markers; confirm source has no camera writes/downloads/deletes in the probe.

**Pass:** successful build/install/launch with a usable diagnostic screen and no unresolved required API assumptions. Simulator launch is not a substitute for installation evidence.

## V-01 — Card-reader visibility control / G1

**Level:** Physical hardware. **Task:** P-030.

1. Put a small known set of expendable JPEG/RAW files on the card by taking normal photographs. Note their filenames without altering the card.
2. With camera disconnected, select USB CARD READER. Turn off camera, connect directly to unlocked iPad, then power on following manufacturer guidance.
3. Launch/start probe and allow applicable system authorization. Keep other camera-import/tether apps inactive during the run.
4. Observe discovery, transport/device information, session open result, file enumeration, catalog readiness, and any errors.
5. Compare reported filenames to the known files. Record the observation duration even if a callback never arrives.
6. Stop safely, disconnect when idle, and confirm removal/close behavior. Repeat one connection cycle.

**Pass:** camera discovered and session/catalog access demonstrated, with known files identified and clean reconnect observations. The camera may not shoot in this mode; do not interpret that as a failure of tether AUTO.

## V-02 — Physical-shutter observation / part of G2

**Level:** Physical hardware. **Task:** P-040. **Prerequisite:** G1.

1. Disconnect safely. Set USB TETHER SHOOTING AUTO and RAW+JPEG; record quality, card slots, auto-power-off and USB power settings. Use single-shot drive mode initially.
2. Reconnect and capture all session/catalog events. Do not require a catalog-complete callback before logging other events.
3. Mark an observation window in the app, then take one physical-shutter photo of a distinct test subject. Wait and record what arrives.
4. Repeat for three distinct exposures, spaced well apart. Record whether the camera can continue shooting and whether its busy indicator persists.
5. Note JPEG/RAW items, exact/temporary filenames, renames, sizes, PTP bytes, and any mismatch between shutter count and object count. One RAW+JPEG exposure may legitimately create two objects.

**Pass:** physical-shutter exposures correlate with newly accessible JPEG objects or a separately documented and tested equivalent. PTP events alone are diagnostic evidence, not a passing file-access result. Do not guess an opcode's meaning from hex resemblance.

**If inconclusive:** record what was observed and stop. A file can exist without a generic didAdd event; a PTP event can occur without a retrievable JPEG. Those require different investigations.

## V-03 — RAW retention and pairing / part of G2

**Level:** Physical card inspection. **Task:** P-040.

1. Finish V-02 and let camera activity complete. Disconnect/shut down safely.
2. Inspect the test captures on the camera and, where necessary, via a card reader/computer to verify actual RAW files and sizes. Do not modify/delete them.
3. Compare image content, filenames, timestamps, folders, and card/slot context to the app's observed items.
4. Record whether RAW and JPEG were both saved, where, and whether names match the app. Record observed versus inferred pairs explicitly.
5. Verify a normal untethered capture after returning to normal operation, using the manufacturer's mode/disconnect guidance.

**Pass:** the test RAWs are demonstrably retained on SD and the app's preview association can be explained without unsupported assumptions. If RAW was only in a volatile buffer or host transfer path, fail this safety gate and stop. RAW+JPEG mode selection alone is not evidence.

## V-04 — First JPEG download/display / G3

**Level:** Physical hardware + local file inspection. **Task:** P-050. **Prerequisite:** G2.

1. Run the implementation that downloads only identified JPEGs through the verified API and saves atomically.
2. Take ten single exposures, waiting for each transfer/display to finish before the next.
3. Check exact filename, byte count, successful decoding, image content, local path, and display update for every exposure.
4. Record event → transfer start → transfer complete → first display timing.
5. Reinspect camera/card data; confirm no delete-after-download behavior and RAW retention.
6. Inject zero-byte/truncated/download-error outcomes through test doubles; verify they never appear as successful previews.

**Pass:** ten matching automatic previews, no loss/duplicates in this series, valid local files, and camera originals retained. This does not establish burst or long-session reliability.

## V-05 — Disconnect, access, and lifecycle recovery

**Level:** Automated fault simulation first; physical idle/reconnect tests afterward. **Task:** P-070.

| Case | Expected result |
| --- | --- |
| Disconnect while idle | Clear disconnected state; existing images/selections remain |
| Simulated mid-transfer disconnect | Transfer marked interrupted; partial file not treated as success |
| Late completion from old connection | Generation check rejects stale mutation |
| Reconnect | New session opens; reconciliation does not duplicate completed captures |
| Authorization denied/restricted | Clear actionable state; no infinite retries |
| App background/lock | Document observed suspension; do not claim background acquisition |
| Return to foreground | Explicit session revalidation/reconnect as needed |
| Low storage/write failure | Visible error, no overwrite, no falsely persisted selection/success |
| Download/session errors | Bounded retries with error code and retry state |
| Multiple removal/close callbacks | Idempotent teardown, no crash |

Recheck card contents after any approved physical fault test. **Pass:** correct state transitions, preserved durable data, no stale writes or silent data loss. Document unrecoverable camera-buffer captures rather than hiding them.

## V-06 — Identity, reconciliation, and pairing

**Level:** Unit/fake event tests plus real observed traces. **Tasks:** P-060, P-070.

Exercise initial catalog versus new capture; duplicate add callbacks; repeated basenames across folders/cards; reused handles after reconnect; RAW before JPEG; JPEG before RAW; missing RAW object; temporary filename then rename; unknown type; delayed old events; reconnect with available/unavailable pending object.

**Pass:** stable capture IDs, no accidental overwrite/collapse, no loss of selections on rename, honest observed/inferred/unresolved pairing, and no filename-only identity. Every deduplication assumption has a test and documented scope.

## V-07 — Review interactions

**Level:** UI tests + owner's physical-iPad review. **Task:** P-080.

1. Capture several images; newest successful capture is visible while follow-latest is ON.
2. Swipe/select an older image and zoom; another new capture must not steal review focus.
3. Resume Live/newest explicitly; newest capture appears and zoom resets predictably.
4. Verify pinch and double-tap use the downloaded JPEG's useful detail, not only an enlarged thumbnail.
5. Scroll filmstrip while ingestion proceeds; verify stable row identities and no flicker/selection jumps.
6. Check portrait/landscape and accessible control labels. Failed transfers leave the last successful preview visible with an honest error state.

**Pass:** owner can inspect older images and return to shooting without losing context. Confirm or revise D-007 explicitly.

## V-08 — Persistence, selection, and export

**Level:** Unit/storage tests + end-to-end owner check. **Tasks:** P-060, P-090.

1. Select multiple captures, including nonadjacent ones; verify selected and capture counts.
2. Navigate, ingest another capture, disconnect/reconnect, and relaunch. Selections and local previews must remain.
3. Simulate process interruption around asset/manifest writes; recover or surface a repairable state without silently losing selected captures.
4. Export zero selections and a normal set. Confirm deterministic capture order and exact observed filenames.
5. Test observed RAW pairs, inferred RAW candidates, unresolved pairs, duplicate basenames, and mixed-case extensions. No inferred .RAF is silently presented as observed; ambiguities are warned about.
6. Compare an exported sample against actual camera RAW files and the owner's manual Lightroom lookup. This validates the handoff, not automatic catalog integration.

**Pass:** durable selections, honest and stable exports, no silent deduplication of distinct selected captures, and reported persistence failures.

## V-09 — Capacity, latency, and reliability baseline

**Level:** Local/simulated stress plus separately labeled hardware soak. **Task:** P-100.

- Test 50, 250, and 1,000+ realistic capture records/assets. State whether each dataset is synthetic, replayed, or actually tethered.
- Measure peak/steady memory, decoded-cache cost, disk usage, selection-write latency, queue depth, failures, and p50/p95 event-to-display latency. Use supported profiling tools on the real app where available.
- Scroll/review/zoom during ingestion, trigger memory warnings where supported, and test low storage through safe simulation.
- Verify decoded bitmap memory is bounded by the active viewing window rather than all images. Persisted metadata may scale with count; explain that separately.
- Agree the physical-camera soak duration/count/cadence with the owner. Do not require 1,000 real shutter actuations merely to validate a 1,000-record filmstrip, and do not claim physical 1,000-capture reliability from a fake dataset.

**Pass:** evidence shows bounded rendering memory, no known selection loss/overwrites, and explicit measured limits. Agree numeric responsiveness/reliability targets after baseline measurements; record them in DECISIONS. Report failed cases, not only averages.

## Failure interpretation guide

| Observation | Investigate next | Avoid concluding |
| --- | --- | --- |
| No discovery in either USB mode | Data cable, direct connection, unlock, power setting, authorization; separate Photos import control if useful | “Fujifilm PTP unsupported” without transport evidence |
| Card-reader works, tether does not | Mode-specific session/protocol behavior and errors | Generic import success guarantees tethering |
| Session opens but no catalog-ready | Observe/log events independently; compare mode behavior | Every useful event requires complete catalog |
| PTP event but no file | Supported documented event/object retrieval path | Any hex event proves a downloadable JPEG exists |
| Files but no RAW on card | Camera storage semantics; stop safety gate | AUTO automatically protects RAWs |
| JPEG visible, additional shots stall | Camera buffer/transfer requirements with RAW+JPEG | Downloading JPEG only is always sustainable |
| Names change or repeat | Provenance, generation, folders, pairing metadata | Basename is a universal unique ID |

Do not try random vendor opcodes or storage destination writes to make a test pass. Record evidence and request direction.

## Evidence records

Application run records: **none yet**. Add Markdown records below or, once needed, link to Markdown files under a tests/evidence directory. Redacted raw logs may be fenced text inside those Markdown records.

### RUN-YYYYMMDD-NN — Template

- Date / operator / test IDs:
- Result: PASS / FAIL / INCONCLUSIVE / NOT RUN
- Evidence level: compiler / simulated / physical hardware / card inspection
- Source commit and build identifier:
- Xcode/SDK/Swift/isolation/deployment settings:
- iPadOS and camera firmware:
- Cable/topology, USB power and connection mode:
- Card slots, JPEG size/quality, RAW+JPEG setting:
- Setup and exact actions:
- Expected observation:
- Actual observation, counts, durations and errors:
- Log excerpts / local evidence links:
- Card-retention check and filename pairing evidence:
- Limitations and redactions:
- Gate passed or still blocked:
- Next action and related decision/work-item IDs:

Do not fill this template with illustrative success logs and later treat it as a performed run.
