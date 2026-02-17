# Edge Relay Technical Specification

## Rust MAVLink Telemetry Relay for Flightworks Control

**Version:** 1.0  
**Date:** February 2026  
**Author:** Stephen Sweeney  
**Status:** Proposed  
**Location:** `Tools/EdgeRelay/`

---

## 1. Purpose

The Edge Relay is a Rust binary that sits between the MAVLink wire (UDP from PX4 SITL or flight hardware) and the Swift GCS application. It solves a specific architectural problem: the Swift layer should focus on deterministic state management, UI rendering, and operator interaction—not on raw protocol parsing, noisy link handling, or wire-level policy enforcement.

The relay is **optional infrastructure**. The Swift `DroneConnectionManager` consumes standard UDP MAVLink frames regardless of whether they arrive direct-from-source or through the relay. The relay is additive—it improves observability, testability, and robustness without creating a hard dependency.

### Why Rust

This component handles untrusted wire data at the boundary of the system. The requirements—zero-copy parsing, memory safety without garbage collection, deterministic resource cleanup, high-throughput with low latency—are precisely where Rust's ownership model provides guarantees that matter. Swift's ARC is excellent for application-level state management but introduces reference counting overhead that is unnecessary for a stateless forwarding pipeline. Rust's borrow checker ensures memory safety at compile time with zero runtime cost.

This is not a language preference decision. It is a layer-appropriate tooling decision: **the same principle that argues against Python for safety-critical edge systems argues *for* Rust at the wire level**.

### SwiftVector Alignment

The Edge Relay extends the determinism boundary across a language boundary. It enforces:
- **Deterministic filtering:** Allowlist is fixed configuration, not learned
- **Auditable decisions:** Every frame produces a logged event (forwarded, dropped, or downsampled) with a reason
- **Reproducible behavior:** Replay mode emits identical frames from identical logs
- **Fail-safe defaults:** Unknown message IDs are dropped (deny-by-default), not forwarded

---

## 2. Scope

### In Scope (Phase 1)

- UDP MAVLink v2 ingestion (single source)
- Message ID decoding from MAVLink v2 header (no full CRC validation in Phase 1)
- Hardcoded allowlist for Phase 1 message types
- UDP forwarding to single Swift GCS consumer
- JSONL audit event stream (file-based)
- Raw frame recording (binary log)
- Deterministic replay mode (read log → emit at original cadence)
- Integration with PX4 SITL quickstart scripts
- Comprehensive unit and integration tests

### Out of Scope (Phase 1)

- Serial transport (deferred to hardware integration phase)
- Full MAVLink CRC validation and message deserialization
- Configurable policy files (TOML/YAML)—hardcoded allowlist is sufficient
- Multi-consumer forwarding
- Rate limiting / downsampling (Phase 3 enhancement)
- Encryption or authentication
- Multi-vehicle support
- FFI or shared memory integration with Swift (UDP is the contract)

### Future Scope (Phase 3+)

- Policy file (TOML) driving routing, downsampling, and rate limiting
- Multiple forwarding destinations
- Per-message-type rate limiting
- Serial MAVLink transport
- Metrics endpoint (Prometheus-compatible counters)
- Multi-vehicle relay with per-sysid routing

---

## 3. Architecture

### Data Flow

```
                    ┌─────────────────────────┐
                    │      PX4 SITL or        │
                    │    Flight Hardware       │
                    └────────────┬────────────┘
                                 │
                                 │ UDP :14540 (MAVLink v2)
                                 ▼
┌────────────────────────────────────────────────────────────────┐
│                      EDGE RELAY (Rust)                         │
│                                                                │
│  ┌──────────────┐    ┌──────────────┐    ┌─────────────────┐  │
│  │  UDP Listener │───▶│  Classifier  │───▶│  Router         │  │
│  │  (async)      │    │              │    │                 │  │
│  │  • recv frame │    │  • decode    │    │  • if allowed:  │  │
│  │  • timestamp  │    │    msg_id    │    │    forward +    │  │
│  │               │    │  • check     │    │    log          │  │
│  │               │    │    allowlist │    │  • if denied:   │  │
│  │               │    │  • classify  │    │    drop + log   │  │
│  └──────────────┘    └──────────────┘    └────────┬────────┘  │
│                                                    │           │
│                           ┌────────────────────────┤           │
│                           │                        │           │
│                           ▼                        ▼           │
│                  ┌─────────────────┐     ┌──────────────────┐ │
│                  │  Audit Logger   │     │  UDP Forwarder   │ │
│                  │                 │     │                  │ │
│                  │  • JSONL events │     │  • forward to    │ │
│                  │  • raw frame    │     │    Swift GCS     │ │
│                  │    recording    │     │    (:14550)      │ │
│                  └─────────────────┘     └──────────────────┘ │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Replay Engine (alternative to UDP Listener)             │  │
│  │  • reads recorded log                                    │  │
│  │  • emits frames at original timestamps                   │  │
│  │  • produces identical audit trail                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
                                 │
                                 │ UDP :14550 (MAVLink v2, filtered)
                                 ▼
                    ┌─────────────────────────┐
                    │    Swift GCS            │
                    │  (DroneConnection       │
                    │   Manager)              │
                    └─────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Failure Mode |
|-----------|----------------|--------------|
| **UDP Listener** | Receive raw bytes, timestamp on arrival | Log error, continue listening |
| **Classifier** | Decode MAVLink v2 header, extract msg_id, check allowlist | Unknown/malformed → drop + log |
| **Router** | Forward allowed frames, drop denied frames | Forward failure → log, do not block |
| **Audit Logger** | Write JSONL events + raw frame log | File write failure → stderr warning, continue |
| **UDP Forwarder** | Send filtered frames to Swift GCS | Send failure → log, do not block pipeline |
| **Replay Engine** | Read recorded log, emit at original cadence | File read failure → exit with error |

### Design Principles

1. **Non-blocking pipeline:** No component blocks another. Frame drops are acceptable; frame corruption is not.
2. **Deny-by-default:** Only explicitly allowlisted message IDs are forwarded. Everything else is dropped and logged.
3. **Stateless forwarding:** The relay holds no application state. It is a filter, not a state machine. State management belongs in the Swift layer.
4. **Audit everything:** Every frame that enters the relay produces exactly one log event with a disposition (forwarded, dropped) and a reason.
5. **Fail open to operator:** If the relay fails entirely, the Swift GCS can connect directly to the MAVLink source. The relay never becomes a single point of failure.

---

## 4. Interfaces

### 4.1 Inputs

**Primary: UDP MAVLink v2 frames**
- Default listen address: `0.0.0.0:14540`
- Configurable via CLI: `--listen 0.0.0.0:14540`
- Expected format: MAVLink v2 binary frames (magic byte `0xFD`)
- MAVLink v1 frames (magic byte `0xFE`) are logged and dropped

**Alternative: Recorded log file (replay mode)**
- CLI: `--replay path/to/recording.mavraw`
- Format: Binary frame log with timestamps (see §5.2)

### 4.2 Outputs

**UDP MAVLink frames (to Swift GCS)**
- Default forward address: `127.0.0.1:14550`
- Configurable via CLI: `--forward 127.0.0.1:14550`
- Format: Identical MAVLink v2 binary frames (byte-for-byte passthrough of allowed frames)

**JSONL Audit Event Stream (file)**
- Default path: `./logs/audit_{timestamp}.jsonl`
- Configurable via CLI: `--audit-log ./logs/`
- One JSON object per line, one event per frame received

**Raw Frame Recording (file)**
- Default path: `./logs/recording_{timestamp}.mavraw`
- Configurable via CLI: `--record ./logs/`
- Binary format: `[u64 timestamp_us][u16 frame_len][bytes frame]` per entry

### 4.3 CLI Interface

```
edge-relay [OPTIONS]

OPTIONS:
    --listen <ADDR>        UDP listen address [default: 0.0.0.0:14540]
    --forward <ADDR>       UDP forward address [default: 127.0.0.1:14550]
    --audit-log <DIR>      Audit log directory [default: ./logs/]
    --record <DIR>         Recording output directory [default: ./logs/]
    --no-record            Disable raw frame recording
    --replay <FILE>        Replay mode: read from recorded file instead of UDP
    --replay-speed <MULT>  Replay speed multiplier [default: 1.0]
    --verbose              Verbose logging to stderr
    --version              Print version
    --help                 Print help
```

---

## 5. Data Formats

### 5.1 JSONL Audit Event

Every received frame produces exactly one audit event:

```json
{
  "ts": "2026-02-11T14:30:00.123456Z",
  "seq": 42,
  "msg_id": 0,
  "msg_name": "HEARTBEAT",
  "sysid": 1,
  "compid": 1,
  "disposition": "forwarded",
  "reason": "allowlisted",
  "frame_len": 17
}
```

```json
{
  "ts": "2026-02-11T14:30:00.234567Z",
  "seq": 43,
  "msg_id": 111,
  "msg_name": "TIMESYNC",
  "sysid": 1,
  "compid": 1,
  "disposition": "dropped",
  "reason": "not_in_allowlist",
  "frame_len": 22
}
```

```json
{
  "ts": "2026-02-11T14:30:00.345678Z",
  "seq": 44,
  "msg_id": null,
  "msg_name": null,
  "sysid": null,
  "compid": null,
  "disposition": "dropped",
  "reason": "malformed_header",
  "frame_len": 3
}
```

**Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `ts` | string (ISO 8601) | Relay-local timestamp at frame receipt |
| `seq` | u64 | Monotonically increasing relay sequence number |
| `msg_id` | u32 or null | MAVLink message ID (null if header decode failed) |
| `msg_name` | string or null | Human-readable message name (null if unknown) |
| `sysid` | u8 or null | MAVLink system ID |
| `compid` | u8 or null | MAVLink component ID |
| `disposition` | string | `"forwarded"` or `"dropped"` |
| `reason` | string | `"allowlisted"`, `"not_in_allowlist"`, `"malformed_header"`, `"mavlink_v1"` |
| `frame_len` | u16 | Total byte length of received frame |

### 5.2 Raw Frame Recording Format

Binary format, no framing protocol overhead:

```
[u64 little-endian: timestamp_microseconds_since_epoch]
[u16 little-endian: frame_byte_length]
[bytes: raw MAVLink frame]
... repeat ...
```

This format enables:
- Deterministic replay at original cadence
- Offline analysis with external tools
- Corpus building for integration test fixtures

### 5.3 Counters (stdout on exit or SIGINT)

```json
{
  "runtime_seconds": 120.5,
  "frames_received": 14230,
  "frames_forwarded": 11840,
  "frames_dropped": 2390,
  "bytes_received": 341520,
  "bytes_forwarded": 284160,
  "drop_reasons": {
    "not_in_allowlist": 2350,
    "malformed_header": 12,
    "mavlink_v1": 28
  }
}
```

---

## 6. Phase 1 Allowlist

Hardcoded message types for Phase 1. This set provides the telemetry needed for the Swift GCS Phase 1 deliverables (telemetry display, map view, connection management).

| MAVLink Message | ID | Purpose | Phase 1 Need |
|----------------|----|---------|--------------|
| HEARTBEAT | 0 | Connection liveness, flight mode | Connection state machine |
| SYS_STATUS | 1 | Battery voltage, CPU load, sensor health | Battery display, system status |
| GPS_RAW_INT | 24 | Raw GPS fix data, satellite count | GPS fix quality indicator |
| ATTITUDE | 30 | Roll, pitch, yaw | Aircraft puck orientation |
| GLOBAL_POSITION_INT | 33 | Lat, lon, alt (fused) | Map position, altitude display |
| RC_CHANNELS | 65 | RC channel values | RC link status |
| VFR_HUD | 74 | Airspeed, groundspeed, heading, throttle, alt, climb | Primary flight display |
| BATTERY_STATUS | 147 | Detailed battery information | Battery monitoring |
| HOME_POSITION | 242 | Home location | Map home marker |
| STATUSTEXT | 253 | Text messages from autopilot | Status/warning display |
| COMMAND_ACK | 77 | Command acknowledgments | Command confirmation |

**Rationale for deny-by-default:** PX4 SITL emits dozens of message types. Many (TIMESYNC, PING, DEBUG, etc.) are noise for the GCS use case. By forwarding only what the Swift app needs, we reduce the backpressure load on `TelemetryStream` and make the audit log more useful.

---

## 7. Testing Strategy

### 7.1 Unit Tests

| Test | Validates |
|------|-----------|
| `test_decode_heartbeat_header` | MAVLink v2 header parsing extracts correct msg_id, sysid, compid |
| `test_decode_malformed_frame` | Frames shorter than minimum header length produce `malformed_header` |
| `test_decode_mavlink_v1` | Magic byte `0xFE` produces `mavlink_v1` classification |
| `test_allowlist_accept` | Known allowed msg_id → `forwarded` disposition |
| `test_allowlist_deny` | Unknown msg_id → `dropped` with `not_in_allowlist` reason |
| `test_audit_event_serialization` | Audit events round-trip through JSON correctly |
| `test_recording_format` | Written frames can be read back with correct timestamps |
| `test_replay_ordering` | Replayed frames emit in timestamp order |
| `test_counters_accuracy` | Final counters match sum of audit events |
| `test_deterministic_replay` | Same recording → same audit trail (byte-for-byte JSONL match) |

### 7.2 Integration Tests

| Test | Validates |
|------|-----------|
| `test_sitl_round_trip` | PX4 SITL → relay → received frames include HEARTBEAT within 2 seconds |
| `test_record_and_replay` | Record 10 seconds from SITL, replay, verify identical forwarded frames |
| `test_swift_gcs_receives` | Relay forwards frames that Swift `DroneConnectionManager` can parse |
| `test_relay_bypass` | Swift GCS connects directly to SITL without relay (regression guard) |

### 7.3 Determinism Verification

The relay's determinism claim is testable:

1. Record a telemetry session from SITL
2. Replay the recording through the relay
3. Compare the audit JSONL output (excluding timestamps) with the original session's audit log
4. **They must be identical.** Same input frames → same dispositions, same reasons, same sequence.

This test should run in CI on every commit to `Tools/EdgeRelay/`.

---

## 8. Project Structure

```
Tools/EdgeRelay/
├── Cargo.toml
├── README.md
├── src/
│   ├── main.rs              ← CLI entry point, argument parsing
│   ├── listener.rs          ← UDP listener (async)
│   ├── classifier.rs        ← MAVLink header decode + allowlist check
│   ├── router.rs            ← Forward/drop decision + dispatch
│   ├── forwarder.rs         ← UDP send to Swift GCS
│   ├── audit.rs             ← JSONL event writer
│   ├── recorder.rs          ← Raw frame binary writer
│   ├── replay.rs            ← Replay engine (read log, emit at cadence)
│   ├── counters.rs          ← Runtime statistics
│   └── mavlink_header.rs    ← MAVLink v2 header struct + decode
├── tests/
│   ├── unit/
│   │   ├── classifier_tests.rs
│   │   ├── audit_tests.rs
│   │   ├── recorder_tests.rs
│   │   └── replay_tests.rs
│   ├── integration/
│   │   ├── sitl_round_trip.rs
│   │   └── record_replay.rs
│   └── fixtures/
│       ├── heartbeat.mavraw       ← Single HEARTBEAT frame
│       ├── mixed_messages.mavraw  ← Mix of allowed + denied
│       └── malformed.mavraw       ← Invalid frames
├── scripts/
│   ├── sitl-quickstart.sh         ← Launch SITL + relay + instructions
│   └── record-session.sh          ← Record from SITL for test fixtures
└── docs/
    └── INTEGRATION_NOTES.md       ← How Swift GCS connects through relay
```

### Dependencies (Cargo.toml)

```toml
[package]
name = "edge-relay"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["full"] }         # async runtime
serde = { version = "1", features = ["derive"] }        # JSON serialization
serde_json = "1"                                         # JSONL output
chrono = { version = "0.4", features = ["serde"] }      # timestamps
clap = { version = "4", features = ["derive"] }         # CLI parsing

[dev-dependencies]
tokio-test = "0.4"
```

**Note:** No `mavlink` crate dependency in Phase 1. We decode only the MAVLink v2 header (10 bytes) ourselves. Full message deserialization is not needed for filtering and forwarding.

---

## 9. Invariants

These properties must hold at all times and are verified by tests:

1. **Every received frame produces exactly one audit event.** No silent drops, no silent forwards.
2. **Forwarded frames are byte-identical to received frames.** The relay does not modify frame content.
3. **Audit sequence numbers are monotonically increasing with no gaps.** If the counter says 42 events, there are exactly 42 lines in the JSONL file.
4. **Replay of a recording produces an identical audit trail** (excluding relay-local timestamps). This is the determinism proof.
5. **The relay never blocks on a downstream failure.** If the Swift GCS is not listening, frames are forwarded into the void and logged as forwarded. The relay does not queue or retry.
6. **Unknown message IDs are always dropped.** The allowlist is the sole authority for forwarding decisions.

---

## 10. Integration with Flightworks Control

### Swift-Side Changes (Minimal)

The Swift `DroneConnectionManager` requires no changes. It already listens on a UDP port for MAVLink frames. The relay simply becomes a configurable upstream source:

```swift
// DroneConnectionManager configuration
enum TelemetrySource {
    case direct(host: String, port: UInt16)    // PX4 SITL direct
    case relay(host: String, port: UInt16)     // Through Edge Relay
}
```

The only new Swift code is an optional debug overlay that can consume the relay's JSONL audit stream to show operators what the relay is filtering—useful for development and debugging, not required for production.

### SITL Quickstart Script

```bash
#!/bin/bash
# scripts/sitl-quickstart.sh
# Launch PX4 SITL → Edge Relay → Swift GCS pipeline

echo "Starting PX4 SITL..."
# (PX4 SITL launch commands)

echo "Starting Edge Relay..."
cd Tools/EdgeRelay
cargo run -- \
    --listen 0.0.0.0:14540 \
    --forward 127.0.0.1:14550 \
    --audit-log ../../logs/ \
    --record ../../logs/ \
    --verbose &

echo "Edge Relay forwarding :14540 → :14550"
echo "Audit logs: logs/"
echo "Launch Flightworks Control and connect to 127.0.0.1:14550"
```

### Cross-Layer Audit Correlation

The relay's JSONL audit events and the Swift orchestrator's action log can be correlated by timestamp to produce a full-stack trace:

```
[Relay]  ts=14:30:00.123  HEARTBEAT forwarded
[Swift]  ts=14:30:00.125  FlightAction.updateTelemetry(heartbeat)
[Swift]  ts=14:30:00.125  FlightState.connectionStatus → .connected
```

This correlation is a Phase 4 deliverable (Debrief & Replay) but the logging format is established in Phase 1.

---

## 11. Success Criteria

Phase 1 Edge Relay is complete when:

1. `cargo test` passes all unit tests
2. Integration test demonstrates SITL → relay → Swift GCS round trip
3. Recording + replay produces identical audit trail (determinism proof)
4. `sitl-quickstart.sh` works for a new developer with only `cargo` and PX4 SITL installed
5. README.md documents all CLI options, data formats, and integration steps
6. JSONL audit format is documented and stable (breaking changes require version bump)
7. CI job runs on every commit to `Tools/EdgeRelay/`

---

## 12. Relationship to "Rust on the Edge" Article

This specification and its implementation provide the primary source material for the companion essay "Rust on the Edge: Determinism Across Language Boundaries." Key observations to document during implementation:

- Where Rust's ownership model catches bugs that Swift's ARC would not (and vice versa)
- The experience of defining a clean contract between two compile-time-safe languages
- How the deny-by-default allowlist pattern maps to the SwiftVector determinism boundary
- The testing story: how Rust's `cargo test` and Swift's XCTest validate the same invariant from opposite sides of a UDP socket
- Performance characteristics: what Rust's zero-cost abstractions actually cost (or save) at the relay layer

---

## Document History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | February 2026 | Initial specification |
