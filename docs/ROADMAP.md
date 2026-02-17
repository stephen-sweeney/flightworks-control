# Flightworks Suite: Product Roadmap

## Jurisdiction-Based Architecture for Governed Drone Operations

The Flightworks Suite demonstrates deterministic AI control through a jurisdiction-based architecture. **FlightLaw** provides universal safety guarantees, extended by mission-specific jurisdictions (**ThermalLaw** for inspection, **SurveyLaw** for mapping) that inherit base safety while adding domain-specific governance.

---

## Suite Architecture

```
FlightLaw (Universal Safety Kernel)
    │
    ├─→ ThermalLaw (Thermal Inspection)
    │   • Post-hail roof assessment
    │   • Governed AI detection
    │   • Future jurisdiction (timeline TBD)
    │
    └─→ SurveyLaw (Precision Mapping)
        • RTK precision surveying
        • Engineering-grade accuracy
        • Future jurisdiction (timeline TBD)
```

**Current Focus:** FlightLaw foundation (Swift) + Edge Relay (Rust) — the two-language deterministic stack

---

## Strategic Context

### Target Market

Flightworks Control targets **public safety, defense, and critical infrastructure** — sectors affected by the U.S. ban on Chinese-manufactured drones. This excludes DJI platforms and focuses development on U.S.-manufactured alternatives operating the MAVLink protocol.

### Platform Strategy

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **GCS** | Swift/SwiftUI (iPad) | Operator interface, SwiftVector governance, FlightLaw enforcement |
| **Edge Relay** | Rust | MAVLink proxy, transport-layer audit, frame recording/replay |
| **Protocol** | MAVLink v2 (UDP) | Open standard, PX4-compatible, vendor-neutral |
| **Simulation** | PX4 SITL | Development and testing without hardware |
| **Field Testing** | Skydio X10 | U.S.-manufactured, MAVLink-compatible, public safety market |

### Development Philosophy

**SITL-first:** Develop maximally against PX4 simulation. Rent hardware for field validation only when software is ready. This minimizes capital risk while proving the architecture.

**Two-language determinism:** Swift and Rust are philosophical siblings — both provide compile-time safety, no garbage collection, and deterministic behavior. The boundary between them (UDP + JSONL) is itself auditable, creating a cross-language determinism proof that strengthens the SwiftVector thesis.

### Alignment with Broader Opportunities

This architecture — governed autonomy for safety-critical drone operations using systems languages on the edge — aligns with multiple strategic pathways including DoD SBIR/STTR priorities (trusted autonomy), university research partnerships, and commercial drone services for government customers.

---

## Product Vision

The Flightworks Suite demonstrates that **governed AI is competitive AI**. By providing deterministic, auditable control systems, we enable:

**FlightLaw (Universal Safety Kernel):**
- Battery reserve enforcement
- Geofence violation prevention
- Pre-flight readiness validation
- Tamper-evident audit trail
- Deterministic replay capability

**Edge Relay (Transport-Layer Governance):**
- MAVLink protocol parsing and validation
- Message allowlisting and filtering
- Transport-layer audit logging (JSONL)
- Frame recording and deterministic replay
- Clean boundary between drone protocol and GCS logic

**ThermalLaw (Thermal Inspection Jurisdiction):** *Future*
- Post-hail roof damage assessment
- RGB-primary detection (thermal secondary)
- Governed candidate approval workflow
- Documentation Pack export
- Session replay verification

**SurveyLaw (Precision Mapping Jurisdiction):** *Future*
- RTK precision surveying (2cm accuracy)
- Grid adherence validation
- GSD compliance verification
- Gap detection and overlap analysis

---

## North Star Metrics

### FlightLaw (Universal Safety)

| Metric | Target | Verification |
|--------|--------|--------------|
| Determinism rate | 100% | Property-based tests (10,000 iterations) |
| Audit replay accuracy | 100% state hash match | End-to-end replay tests |
| FlightLaw enforcement | 100% violation prevention | Compliance test suite |
| Law evaluation latency | <5ms (median) | Performance profiling |

### Edge Relay (Transport Governance)

| Metric | Target | Verification |
|--------|--------|--------------|
| Frame forwarding latency | <1ms (p99) | Benchmark suite |
| Audit log completeness | 100% of frames logged | Replay comparison |
| Cross-language determinism | Identical audit trails | Swift ↔ Rust replay test |
| Zero clippy warnings | 0 | CI pipeline |

---

## What This Prototype Is NOT (Scope Boundaries)

To manage expectations for this R&D reference interface:

- **Not a full-featured GCS:** Lacks comprehensive sensor configuration, payload management, or complex pre-flight checklists
- **Not a replacement for OEM applications:** Does not support proprietary vehicle-specific features or security protocols beyond MAVLink standards
- **Not a BVLOS-compliant flight system:** Does not contain the necessary redundancy, certification, or operational protocols for Beyond Visual Line of Sight flight
- **Not operationally validated:** The UI and logic are not subjected to flight testing or regulatory audits
- **Not designed for hardware diversity beyond PX4 SITL:** Core focus is reliable connectivity and UI design using simulated PX4 data
- **Not cloud-dependent:** All critical decision-making runs locally on-device

---

## Operator Personas

| Persona | Key Needs |
|---------|-----------|
| **Public Safety Operator** | Rapid situational awareness, minimal menus, high-contrast UI, consolidated map + video context |
| **Inspection Pilot** | Quick access to airspace awareness, defined safe flight envelope, precise manual control, stable visual feeds, thermal anomaly alerts |
| **Technical UAV Developer** | Real-time telemetry, repeatable test missions, clear flight state transitions, debug-friendly UI components |
| **Technical Authority / Chief Safety Officer** | Auditability of flight logs, adherence to regulatory constraints, clear records of pre-flight checks |

---

## SwiftVector Integration Philosophy

Flightworks Control serves as a proving ground for SwiftVector patterns in safety-critical contexts.

### Deterministic AI Decision Support

All AI-assisted features (battery reserve calculation, risk assessment, route optimization, thermal anomaly detection) must produce identical outputs given identical inputs. No stochastic elements in the decision pipeline.

### Operator Authority Preservation

AI provides recommendations with confidence levels and reasoning chains. The operator always retains final authority. The system never auto-executes critical actions without explicit confirmation.

### Transparent Reasoning

Every AI recommendation includes a human-readable explanation of the factors considered and weights applied. Operators can audit *why* the system suggested a particular action.

### Fail-Safe Degradation

If AI subsystems fail or produce uncertain outputs, the system gracefully degrades to manual operation with clear operator notification. No silent failures.

---

## Development Roadmap

### Phase 0: FlightLaw Foundation (February–March 2026)

**Focus:** Universal safety kernel — the constitutional infrastructure  
**Language:** Swift  
**Deliverables:** Core State/Action/Reducer, Laws 3/4/7/8, Audit Trail

| Deliverable | Status | Description |
|-------------|--------|-------------|
| SwiftVector Core protocols | ✅ | State, Action, Reducer patterns |
| FlightLaw specification | ✅ | HLD + PRD documents |
| Law 3 (Observation) | 🔄 | Telemetry logging, pre-flight validation |
| Law 4 (Resource) | 🔄 | Battery management, thermal limits |
| Law 7 (Spatial) | 🔄 | Geofencing, altitude limits |
| Law 8 (Authority) | 🔄 | Risk-tiered operator approval |
| Audit trail with SHA256 | 🔄 | Tamper-evident logging |
| Replay engine | 🔄 | Deterministic state reconstruction |

**Success Criteria:**
- All Laws implemented and tested
- Determinism verified (10,000 iterations)
- Audit trail integrity proven
- Ready for jurisdiction extension

---

### Phase 1: Edge Relay (February–March 2026, parallel with Phase 0)

**Focus:** Rust MAVLink proxy with transport-layer audit  
**Language:** Rust  
**Deliverables:** UDP relay, MAVLink parsing, audit logging, frame recording/replay

| Deliverable | Status | Description |
|-------------|--------|-------------|
| UDP echo relay | 🔄 | Baseline forwarder (synchronous) |
| Async migration (tokio) | 📋 | Production-ready async I/O |
| MAVLink v2 header decode | 📋 | Message ID extraction, allowlist filtering |
| JSONL audit logger | 📋 | Transport-layer event log |
| Frame recorder | 📋 | Binary recording format for replay |
| Replay engine | 📋 | Deterministic playback with timing |
| CLI interface (clap) | 📋 | Configuration and operational modes |
| CI pipeline | 📋 | cargo fmt, clippy, test, build |

**Success Criteria:**
- Relay forwards MAVLink frames with <1ms added latency
- Audit log captures 100% of frames
- Replay produces identical audit trails
- Zero clippy warnings
- Integration test: PX4 SITL → Relay → verified output

**Architecture Decision:** The Edge Relay creates a clean, testable boundary between drone protocol (MAVLink/UDP) and GCS logic (Swift). Both sides are compile-time safe (Rust and Swift), and the boundary itself (UDP frames + JSONL logs) is auditable. This proves the "systems languages on the edge" thesis — deterministic guarantees at every layer.

---

### Phase 2: Telemetry Integration (April 2026)

**Focus:** Connect FlightLaw (Swift) to Edge Relay (Rust) — live data flow  
**Languages:** Swift + Rust  
**Deliverables:** Working telemetry pipeline, SITL end-to-end demo

| Deliverable | Status | Description |
|-------------|--------|-------------|
| DroneConnectionManager | 📋 | Swift UDP client receiving from relay |
| Telemetry → FlightAction mapping | 📋 | MAVLink fields → typed SwiftVector actions |
| FlightState live updates | 📋 | Reducer processes real telemetry |
| Cross-language determinism proof | 📋 | Same recording → identical audits from both sides |
| PX4 SITL quickstart script | 📋 | One-command full pipeline launch |
| Basic operator UI | 📋 | Map + telemetry display + connection status |

**Success Criteria:**
- PX4 SITL → Rust Relay → Swift GCS end-to-end operational
- Telemetry updates at ≥10Hz with <50ms total latency
- FlightLaw validators (geofence, battery) fire on real telemetry
- Cross-language replay test passes (Rust audit = Swift audit)

---

### Phase 3: Mission Planning & Safety Validation (May–June 2026)

**Focus:** Waypoint missions with FlightLaw enforcement  
**Language:** Swift  
**Deliverables:** Mission planner, geofence validation, state interlocks

| Deliverable | Status | Description |
|-------------|--------|-------------|
| Waypoint data model | 📋 | Typed mission representation |
| Mission planning UI | 📋 | Tap-to-set waypoints on map |
| GeofenceValidator | 📋 | Pure function point-in-polygon |
| BatteryMonitor integration | 📋 | Reserve enforcement against mission plan |
| State interlocks | 📋 | Pre-arm validation, mode transition rules |
| Mission upload (MAVLink) | 📋 | Via Edge Relay to PX4 SITL |

**Success Criteria:**
- Geofence rejection is a pure function (deterministic, tested)
- Battery reserve prevents mission start if insufficient
- State interlocks prevent unsafe transitions
- Mission executes in SITL with FlightLaw enforcement active

---

### Phase 4: Replay, Verification & Field Readiness (July–August 2026)

**Focus:** Full system replay and preparation for hardware testing  
**Languages:** Swift + Rust  
**Deliverables:** Session replay, determinism verification, field test plan

| Deliverable | Status | Description |
|-------------|--------|-------------|
| Full session replay | 📋 | Identical outputs from audit log |
| Integrity verifier | 📋 | Hash chain validation (both languages) |
| Determinism test suite | 📋 | 100% reproducibility across 10,000 iterations |
| Demo scenarios | 📋 | Repeatable evaluation demos |
| Field test plan | 📋 | Skydio X10 test matrix and procedures |
| Technical documentation | 📋 | Architecture paper, "Systems Languages on the Edge" |

**Success Criteria:**
- Replay produces identical outputs from both Swift and Rust audit trails
- Demo runs reliably (10/10 successes)
- Documentation complete for external review
- Ready for hardware field testing

**Hardware Gate:** At this point, rent a Skydio X10 for field validation. Contact Pendleton OR testing grounds for controlled environment testing.

---

### Future Phases (Timeline TBD)

**ThermalLaw MVP:**
- Inspection session management
- ML-based anomaly detection (CoreML on iPad)
- Operator approval workflow
- Documentation Pack export
- Specifications exist: HLD-FlightworksThermal.md, PRD-FlightworksThermal.md

**SurveyLaw Implementation:**
- RTK GPS integration
- Deterministic grid generation
- GSD compliance validation
- Post-flight QC reporting
- Specifications exist: HLD-FlightworksSurvey.md, PRD-FlightworksSurvey.md

**Future Jurisdictions:**
- SearchLaw (Search & Rescue)
- InfrastructureLaw (Asset Inspection)

---

## Product Principles

1. **Reduce Cognitive Load:** The UI must be immediately understandable in high-stress situations
2. **Prioritize Safety Cues:** All warnings and cautions must be high-contrast and actionable
3. **Always Maintain Spatial Awareness:** Never remove user's perception of aircraft position
4. **Respect Autonomy Constraints:** UI must clearly reflect boundaries and limitations
5. **Design for Stressful Environments:** High-contrast palettes, large touch targets
6. **Minimize Mode Switching:** Avoid deep menus during active flight
7. **Build for Modularity:** Architecture allows rapid integration of new capabilities
8. **Preserve Operator Authority:** AI assists but never autonomously executes critical actions
9. **Ensure Determinism:** All automated decisions must be reproducible and auditable
10. **Fail Transparently:** System failures are visible and result in safe degradation

---

## Technical Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Operator Interface (iPad)                     │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────────┐   │
│  │  Map View    │  │  Telemetry   │  │  Decision Support   │   │
│  │              │  │   Display    │  │  (Recommendations)  │   │
│  └──────┬───────┘  └──────┬───────┘  └─────────┬───────────┘   │
│─────────┼──────────────────┼───────────────────┼────────────────│
│         │    SwiftVector Governance Layer (Swift)                │
│  ┌──────┴──────────────────┴───────────────────┴────────────┐   │
│  │  FlightLaw: State → Action → Reducer → New State         │   │
│  │  Laws 3/4/7/8 │ SHA256 Audit │ Deterministic Replay      │   │
│  └──────────────────────────┬───────────────────────────────┘   │
│                             │ UDP (typed telemetry actions)      │
└─────────────────────────────┼───────────────────────────────────┘
                              │
                   ┌──────────┴──────────┐
                   │  LANGUAGE BOUNDARY   │
                   │  (UDP + JSONL Audit) │
                   └──────────┬──────────┘
                              │
┌─────────────────────────────┼───────────────────────────────────┐
│          Edge Relay (Rust)  │                                    │
│  ┌──────────────────────────┴───────────────────────────────┐   │
│  │  MAVLink v2 Parse │ Allowlist │ JSONL Audit │ Recording  │   │
│  └──────────────────────────┬───────────────────────────────┘   │
│                             │ UDP (raw MAVLink)                  │
└─────────────────────────────┼───────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │  PX4 SITL / UAS   │
                    │  (Skydio X10)     │
                    └───────────────────┘
```

### Key Architectural Decisions

| Decision | Rationale | SwiftVector Alignment |
|----------|-----------|----------------------|
| Local-first processing | No cloud dependency for critical decisions | Determinism, latency |
| Pure function decision logic | Reproducible outputs, testable | Core SwiftVector pattern |
| Explicit state machines | No hidden state, auditable transitions | Transparency |
| Rust Edge Relay | Compile-time safe transport layer, zero-copy MAVLink parsing | Systems languages on the edge |
| Two-language audit trail | Cross-language determinism proof | Strengthens certification thesis |
| Separation of calculation and presentation | Decision logic testable independent of UI | Modularity |
| SITL-first development | Maximize progress without hardware capital | Risk mitigation |

---

## Risk Assessment & Mitigation

| Risk Factor | Impact | Mitigation Strategy |
|-------------|--------|---------------------|
| MAVLink integration complexity | **High** | Edge Relay isolates protocol handling; PX4 SITL for testing |
| Real-time Map Latency | **Medium** | Minimal annotations; throttled Main Thread updates |
| Simulator Fidelity | **Low** | Focus on core MAVLink functionality |
| Decision Support Trust | **Medium** | Clear confidence indicators; explanation panels |
| Determinism Verification | **Medium** | Property-based testing; cross-language replay verification |
| Rust learning curve | **Medium** | Scoped to well-defined relay; build genuine understanding |
| Drone Command acquisition | **Medium** | Architecture remains valuable regardless; open-source status TBD |
| Hardware access | **Low** | SITL-first; rent Skydio X10 for field testing when ready |

---

## Deployment Strategy

| Phase | Audience | Features | Validation Focus |
|-------|----------|----------|------------------|
| **Alpha** | Technical UAV Developers | Phase 0-2 (FlightLaw + Relay + Telemetry) | Data stream stability, determinism proof |
| **Beta** | Public Safety Operators | Phase 3 (Mission Planning) | MTTSA validation, FlightLaw enforcement |
| **Field** | Technical Authority | Phase 4 (Replay + Verification) | Audit trail completeness, replay accuracy |
| **Production** | Enterprise / Government | Future Jurisdictions | Full SwiftVector integration, certification readiness |

---

## SwiftVector Learnings (Living Document)

This section documents insights discovered through applying SwiftVector patterns to the GCS domain:

### Pattern Refinements

1. **Time-Bounded Determinism:** In real-time systems, determinism must include temporal bounds. Variable-time decisions are effectively non-deterministic.

2. **Sensor Fusion as Pure Functions:** Combining telemetry streams (GPS, IMU, barometer, thermal) can be expressed as pure functions over sensor snapshots.

3. **Confidence Propagation:** Uncertainty in inputs should propagate through the decision chain, resulting in uncertainty bounds rather than false precision.

4. **Graceful Degradation Hierarchy:** Explicit degradation modes with clear operator communication when subsystems fail.

5. **ML Output Normalization:** Probabilistic ML outputs require deterministic post-processing to produce consistent typed actions.

6. **Cross-Language Determinism:** When two compile-time-safe languages share an auditable boundary (UDP + JSONL), determinism can be proven across the full stack. The boundary protocol becomes a contract both sides can independently verify.

### Applicability to Other Domains

These patterns extend to other safety-critical systems applications:
- Medical device monitoring
- Industrial control systems
- Autonomous vehicle subsystems
- Financial trading systems
- Defense and public safety autonomy

---

## Related Documentation

### Architecture & Requirements

| Document | Purpose |
|----------|---------|
| [Flightworks-Suite-Overview.md](docs/Flightworks-Suite-Overview.md) | Master suite architecture |
| [ARCHITECTURE.md](ARCHITECTURE.md) | SwiftVector implementation patterns |
| [SwiftVector-Codex.md](SwiftVector-Codex.md) | Constitutional framework |
| **FlightLaw (Core)** | |
| [HLD-FlightworksCore.md](docs/HLD-FlightworksCore.md) | Universal safety kernel architecture |
| [PRD-FlightworksCore.md](docs/PRD-FlightworksCore.md) | FlightLaw requirements |
| **ThermalLaw (Inspection)** — *Future* | |
| [HLD-FlightworksThermal.md](docs/HLD-FlightworksThermal.md) | ThermalLaw architecture |
| [PRD-FlightworksThermal.md](docs/PRD-FlightworksThermal.md) | ThermalLaw requirements |
| **SurveyLaw (Mapping)** — *Future* | |
| [HLD-FlightworksSurvey.md](docs/HLD-FlightworksSurvey.md) | SurveyLaw architecture |
| [PRD-FlightworksSurvey.md](docs/PRD-FlightworksSurvey.md) | SurveyLaw requirements |

### Development & Testing

| Document | Purpose |
|----------|---------|
| [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) | AI-assisted development workflow |
| [TESTING_STRATEGY.md](TESTING_STRATEGY.md) | Verification approach |
| [RUST_LEARNING_PLAN.md](RUST_LEARNING_PLAN.md) | Edge Relay Rust development guide |

### Foundation Papers

| Document | Purpose |
|----------|---------|
| [SwiftVector Codex](SwiftVector-Codex.md) | Constitutional framework for governed autonomy |
| [Swift at the Edge](Swift-at-the-Edge.md) | Manifesto for on-device AI with systems languages |
| [The Agency Paradox](Agency-Paradox.md) | Framework for human command over AI systems |
| [Certify the Boundary](certify-the-boundary.md) | Why deterministic boundaries enable certification |

### Archived

| Document | Notes |
|----------|-------|
| DJI_Challenge_Submission_updated.md | Archived Feb 2026. DJI platforms excluded from target market. Content may be repurposed for ThermalLaw development. |
| DOCUMENT_CONSOLIDATION_STRATEGY.md | Superseded by this roadmap restructure. Useful recommendations absorbed. |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | — | Initial product roadmap |
| 2.0 | — | Added deployment strategy, risk assessment |
| 3.0 | — | SwiftVector integration, Phase 5, architectural principles |
| 4.0 | January 2026 | Unified engineering/product roadmap; thermal inspection extension; updated timelines |
| 5.0 | February 2026 | **Strategic pivot:** DJI Challenge removed; Rust Edge Relay added; PX4/MAVLink primary platform; SITL-first development; jurisdiction phases restructured |

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Initial | Original Flightworks Control monolithic roadmap |
| 2.0 | Feb 2026 | Jurisdiction-based architecture restructuring |
| 3.0 | Feb 2026 | **Strategic realignment** |
| | | • DJI Challenge and DJI platforms removed (Chinese drone ban) |
| | | • Rust Edge Relay added as parallel development track |
| | | • PX4/MAVLink established as primary protocol |
| | | • Skydio X10 identified as field testing platform |
| | | • SITL-first development strategy adopted |
| | | • ThermalLaw and SurveyLaw deferred to future phases |
| | | • Phase structure reorganized: FlightLaw → Edge Relay → Integration → Mission Planning → Verification |
