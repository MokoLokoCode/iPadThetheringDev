# Validation

Procedures have stable IDs (`V-NNN`). PROGRESS.md evidence cites these.

## Hardware setup

| Item | Requirement |
| --- | --- |
| Camera | Model from README.md, battery ≥ 50%, card inserted, tethering mode enabled |
| iPad | Model from README.md, ≥ 2 GB free, Low Power Mode off |
| Cable | The exact cable/adapter from README.md |
| Environment | Well-lit surface so test shots are distinguishable |

## Safety checks (run before every session)

- [ ] Camera card contains no irreplaceable images (tests may write/delete).
- [ ] iPad session directory is empty or backed up.
- [ ] Cable is undamaged; connectors seat fully.

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
