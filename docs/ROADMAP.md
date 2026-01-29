# Flightworks Control: Product Roadmap

## Operator-First Flight UI for U.S.-Made Systems

Flightworks Control is an operator-centric Ground Control Station (GCS) prototype built in Swift/SwiftUI. The goal is to create a reference interface that demonstrates flight-UI intuition, human-factors thinking, operator workflow empathy, and product-level decision-making—all powered by deterministic AI architecture.

---

## Product Vision

Unmanned aircraft operators need clarity, speed, and confidence. The GCS must reduce cognitive load to optimize safety and efficiency during inspection, public safety, and BVLOS-oriented tasks.

**Flightworks Control demonstrates:**

- A modern, intuitive, SwiftUI-based flight interface
- Clear visual hierarchy for critical telemetry
- Accessible mission planning and execution
- Operator-friendly safety cues and state transitions
- A foundation for autonomy-enabling workflows
- Deterministic, auditable decision-making (SwiftVector integration)
- Edge AI capabilities for thermal inspection workflows

---

## North Star Metrics

| Metric | Target | Rationale |
|--------|--------|-----------|
| Mean Time to Establish Situational Awareness (MTTSA) | -15% vs legacy GCS | Time to locate aircraft position and flight status post-connection |
| Decision Confidence Score | >90% operator confidence | Operator trust in AI-assisted recommendations |
| System Determinism Rate | 100% reproducible outputs | Given identical inputs, identical recommendations |

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

## Phase Roadmap

### Phase 0: Foundation ✅ In Progress

**Timeline:** Weeks 1-2  
**T-Shirt Size:** M (Medium)  
**Primary Beneficiary:** Technical UAV Developer

**Problem Solved:** Establish the architectural foundation that makes all subsequent phases possible. Without a solid SwiftVector implementation, determinism claims are hollow.

| Deliverable | Status | SwiftVector Application |
|-------------|--------|------------------------|
| Repository structure and documentation | ⬜ | Project organization enables auditability |
| Xcode project with SwiftUI app | ⬜ | Swift-native foundation |
| Core State/Action/Reducer protocols | ⬜ | Core SwiftVector pattern |
| FlightState, FlightAction, FlightReducer | ⬜ | Deterministic state transitions |
| Orchestrator with action logging | ⬜ | Audit trail foundation |
| Unit tests for reducer determinism | ⬜ | Verifiable determinism |
| CI/CD pipeline (GitHub Actions) | ⬜ | Automated verification |
| Thermal telemetry stubs in FlightState | ⬜ | Extension point for Phase 5+ |

**Success Criteria:**
- Build compiles and runs
- Tests pass with 80%+ coverage
- Architecture documented
- Ready for Phase 1 development

**Technical Writing Opportunity:** "Building a Deterministic GCS: SwiftVector Foundation"

---

### Phase 1: Core Flight Interface

**Timeline:** Weeks 3-6  
**T-Shirt Size:** L (Large)  
**Primary Beneficiary:** Public Safety Operator

**Problem Solved:** Reduces cognitive load by placing essential telemetry at center of operator's view. Instantly conveys spatial awareness and direction of travel. Eliminates confusion during critical pre-flight sequences.

| Deliverable | Status | SwiftVector Application |
|-------------|--------|------------------------|
| MAVLink connection manager (simulated) | ⬜ | Deterministic connection state machine |
| Telemetry data stream (Combine) | ⬜ | Reactive streams with backpressure |
| Telemetry display UI (alt, speed, battery, GPS) | ⬜ | State-driven UI updates |
| Map view with aircraft puck | ⬜ | Position state visualization |
| State machine visualization | ⬜ | Explicit state transitions |
| Telemetry recording for replay | ⬜ | Deterministic replay foundation |
| PX4 SITL integration | ⬜ | Real MAVLink validation |
| Thermal data placeholder in telemetry | ⬜ | Extension point validation |

**Success Criteria:**
- Connect to PX4 SITL
- Display real-time telemetry
- Track aircraft on map
- Record and replay telemetry
- 80% test coverage maintained

**Technical Writing Opportunities:**
- "Real-Time Telemetry in Swift: Combine Streams for Safety-Critical Data"
- "Human-in-Command: AI-Assisted Development of a GCS"

---

### Phase 2: Mission Planning

**Timeline:** Weeks 7-10  
**T-Shirt Size:** M (Medium)  
**Primary Beneficiary:** Inspection Pilot

**Problem Solved:** Simplifies complex coordinate entry into tactile interaction. Defines basic no-fly boundaries. Ensures aircraft cannot transition to unsafe states.

| Deliverable | Status | SwiftVector Application |
|-------------|--------|------------------------|
| Waypoint data model | ⬜ | Immutable mission state |
| Mission state and actions | ⬜ | MissionReducer with explicit transitions |
| Tap-to-set waypoint UI | ⬜ | Actions proposed through orchestrator |
| Geofence definition | ⬜ | Boundary state representation |
| Geofence validation (pure functions) | ⬜ | Deterministic violation detection |
| Safety interlocks | ⬜ | Explicit rule engine with traceable logic |
| Mission upload to vehicle | ⬜ | Action-based upload with verification |

**Success Criteria:**
- Plan waypoint missions via tap interface
- Define geofence boundaries
- Prevent arming on geofence violation (100% interlock test coverage)
- Upload mission to SITL

**Milestone:** Public GitHub announcement 🎉

**Technical Writing Opportunity:** "Geofence Validation as Pure Functions: Safety-Critical Logic in Swift"

---

### Phase 3: Autonomy-Aware Enhancements

**Timeline:** Weeks 11-16  
**T-Shirt Size:** M-L (Medium-Large)  
**Primary Beneficiary:** Technical UAV Developer & Technical Authority

**Problem Solved:** Provides developers and auditors clear insight into aircraft's internal logical process. Moves beyond simple battery percentage to actionable intelligence. Shows awareness of broader aviation ecosystem.

| Deliverable | Status | SwiftVector Application |
|-------------|--------|------------------------|
| State machine visualization UI | ⬜ | No representation gap—UI reflects actual state |
| Battery consumption model | ⬜ | Deterministic calculation with confidence bounds |
| Battery reserve warnings | ⬜ | Pure function: charge + distance + wind → estimate |
| Wind estimation integration | ⬜ | Sensor fusion as pure functions |
| ADS-B traffic display (simulated) | ⬜ | External state integration |
| Deterministic replay system | ⬜ | Identical calculation pipelines as live |

**Success Criteria:**
- Visualize flight state machine
- Predict battery reserve based on mission parameters
- Display simulated traffic
- Replay any flight with identical outputs

**Technical Writing Opportunities:**
- "Deterministic Replay for Safety-Critical Systems"
- "Battery Reserve Modeling: When AI Meets Physics"

---

### Phase 4: Debrief & Replay

**Timeline:** Weeks 17-20  
**T-Shirt Size:** M (Medium)  
**Primary Beneficiary:** Technical Authority & Inspection Pilot

**Problem Solved:** Allows visual review of entire flight envelope. Converts raw log data into digestible visualization. Ensures data integrity for compliance and audit.

| Deliverable | Status | SwiftVector Application |
|-------------|--------|------------------------|
| Flight log data model | ⬜ | Complete state history preservation |
| Flight path replay UI | ⬜ | Time-travel through state snapshots |
| Telemetry graph visualization | ⬜ | State-derived visualizations |
| Mission summary export (JSON, CSV) | ⬜ | Serializable state enables export |
| Action audit trail viewer | ⬜ | Every action logged with attribution |
| Decision attribution display | ⬜ | Source tracking (UI, telemetry, agent) |

**Success Criteria:**
- Review complete flight path
- Graph telemetry over time
- Export mission reports
- Trace any decision to its source

**Technical Writing Opportunity:** "Audit Trails for AI-Assisted Systems: Who Decided What and Why?"

---

### Phase 5: Deterministic Decision Support

**Timeline:** Weeks 21-28  
**T-Shirt Size:** L (Large)  
**Primary Beneficiary:** All Personas

**Problem Solved:** Augments operator judgment without replacing it. Reduces mission planning cognitive load. Enables appropriate trust calibration through transparency.

| Deliverable | Status | SwiftVector Application |
|-------------|--------|------------------------|
| Agent protocol definition | ⬜ | Agents propose, orchestrator validates |
| Risk assessment agent | ⬜ | Pure function architecture |
| Risk display UI | ⬜ | Confidence indicators |
| Route optimization (constrained) | ⬜ | Respects geofences, airspace, energy |
| Confidence indicator UI | ⬜ | Uncertainty propagation |
| Explanation panel | ⬜ | Traceable reasoning chains |
| Agent testing framework | ⬜ | Property-based determinism tests |
| **Thermal anomaly detection agent** | ⬜ | Core ML integration point |

**SwiftVector Proving Ground:**

This phase is the primary SwiftVector integration point:

- **Pure Function Architecture:** All decision logic implemented as pure functions
- **Deterministic Evaluation:** Identical telemetry → identical assessment
- **Traceable Reasoning:** Every output includes the logical chain
- **Operator Override:** All recommendations are advisory
- **Fail-Safe Defaults:** Uncertain inputs → conservative recommendations

**Thermal Inspection Integration:**

The thermal anomaly detection agent demonstrates deterministic processing of probabilistic ML outputs:

```
Thermal Frame → Core ML Model → Probabilistic Output → Deterministic Thresholding → Typed Action Proposal
```

See [THERMAL_INSPECTION_EXTENSION.md](docs/THERMAL_INSPECTION_EXTENSION.md) for detailed specification.

**Success Criteria:**
- Agents propose within boundaries
- Deterministic recommendations (verified via replay)
- Explainable decisions
- Operator retains authority
- Thermal anomaly detection functional on sample datasets

**Technical Writing Opportunities:**
- "SwiftVector in Practice: Deterministic AI for Safety-Critical Systems" (Major paper)
- "The Explanation Panel: Building Trust in AI Recommendations"
- "Edge AI for Thermal Inspection: Deterministic Processing of ML Outputs"

---

## Future Possibilities

### iOS Companion App
- Subset of functionality for field use
- iPhone/iPad optimized UI

### Multi-Vehicle Support
- Fleet management
- Coordinated missions

### Hardware Integration
- Physical controller support
- External display output

### Advanced AI
- On-device LLM integration (CoreML)
- Natural language mission input

### Thermal Inspection Suite
- Real-time anomaly detection during flight
- Automated inspection report generation
- Integration with Flightworks Aerial thermal services

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
┌─────────────────────────────────────────────────────────────┐
│                    Operator Interface                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Map View   │  │  Telemetry  │  │  Decision Support   │  │
│  │             │  │   Display   │  │  (Recommendations)  │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
└─────────┼────────────────┼───────────────────┼──────────────┘
          │                │                   │
          ▼                ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│              SwiftVector Decision Layer                      │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Pure Functions • Deterministic • Auditable         │    │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────────────┐  │    │
│  │  │   Risk    │ │  Battery  │ │     Geofence      │  │    │
│  │  │  Evaluator│ │  Modeler  │ │     Validator     │  │    │
│  │  └───────────┘ └───────────┘ └───────────────────┘  │    │
│  │  ┌───────────────────────────────────────────────┐  │    │
│  │  │           Thermal Anomaly Agent               │  │    │
│  │  │         (Core ML + Deterministic Post)        │  │    │
│  │  └───────────────────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
          │                │                   │
          ▼                ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                   Telemetry Layer                            │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  MAVSDK-Swift • Combine Streams • Error Recovery    │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                   PX4 SITL / Hardware                        │
└─────────────────────────────────────────────────────────────┘
```

### Key Architectural Decisions

| Decision | Rationale | SwiftVector Alignment |
|----------|-----------|----------------------|
| Local-first processing | No cloud dependency for critical decisions | Determinism, latency |
| Pure function decision logic | Reproducible outputs, testable | Core SwiftVector pattern |
| Explicit state machines | No hidden state, auditable transitions | Transparency |
| Combine-based telemetry | Swift-native reactive streams | Swift ecosystem |
| Separation of calculation and presentation | Decision logic testable independent of UI | Modularity |
| Core ML for thermal processing | On-device inference, no network dependency | Edge AI manifesto |

---

## Risk Assessment & Mitigation

| Risk Factor | Impact | Mitigation Strategy |
|-------------|--------|---------------------|
| MAVSDK-Swift Instability | **High** | Robust error handling; exponential backoff retry |
| Real-time Map Latency | **Medium** | Minimal annotations; throttled Main Thread updates |
| Simulator Fidelity | **Low** | Focus on core MAVLink functionality |
| Decision Support Trust | **Medium** | Clear confidence indicators; explanation panels |
| Determinism Verification | **Medium** | Property-based testing; replay verification |
| Thermal ML Accuracy | **Medium** | Conservative thresholds; operator confirmation required |

---

## Deployment Strategy (Hypothetical GTM)

| Phase | Audience | Features | Validation Focus |
|-------|----------|----------|------------------|
| **Alpha** | Technical UAV Developers | Phase 1 | Data stream stability |
| **Beta** | Public Safety Operators | Phase 1-2 | MTTSA validation |
| **Beta 2** | Technical Authority | Phase 3-4 | Audit trail completeness |
| **Launch** | OEM partners / Enterprise | Phase 1-5 | Full SwiftVector integration |

---

## SwiftVector Learnings (Living Document)

This section documents insights discovered through applying SwiftVector patterns to the GCS domain:

### Pattern Refinements

1. **Time-Bounded Determinism:** In real-time systems, determinism must include temporal bounds. Variable-time decisions are effectively non-deterministic.

2. **Sensor Fusion as Pure Functions:** Combining telemetry streams (GPS, IMU, barometer, thermal) can be expressed as pure functions over sensor snapshots.

3. **Confidence Propagation:** Uncertainty in inputs should propagate through the decision chain, resulting in uncertainty bounds rather than false precision.

4. **Graceful Degradation Hierarchy:** Explicit degradation modes with clear operator communication when subsystems fail.

5. **ML Output Normalization:** Probabilistic ML outputs require deterministic post-processing to produce consistent typed actions.

### Applicability to Other Domains

These patterns extend to other safety-critical Swift applications:
- Medical device monitoring
- Industrial control systems
- Autonomous vehicle subsystems
- Financial trading systems

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | — | Initial product roadmap |
| 2.0 | — | Added deployment strategy, risk assessment |
| 3.0 | — | SwiftVector integration, Phase 5, architectural principles |
| 4.0 | January 2026 | Unified engineering/product roadmap; thermal inspection extension; updated timelines |

---

## Related Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) — Detailed system design
- [SWIFTVECTOR.md](SWIFTVECTOR.md) — SwiftVector principles
- [DEVELOPMENT_PLAN.md](docs/DEVELOPMENT_PLAN.md) — AI-assisted development workflow
- [TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md) — Verification approach
- [THERMAL_INSPECTION_EXTENSION.md](docs/THERMAL_INSPECTION_EXTENSION.md) — Thermal anomaly detection spec
- [CONTRIBUTING.md](CONTRIBUTING.md) — Contribution guidelines
