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
    │   • DJI Challenge MVP (Feb-Jun 2026)
    │
    └─→ SurveyLaw (Precision Mapping)
        • RTK precision surveying
        • Engineering-grade accuracy
        • Future development (Q3 2026+)
```

**Current Focus:** ThermalLaw MVP for DJI Drone Onboard AI Challenge 2026


---


## Product Vision

The Flightworks Suite demonstrates that **governed AI is competitive AI**. By providing deterministic, auditable control systems, we enable:

**FlightLaw (Universal Safety Kernel):**
- Battery reserve enforcement
- Geofence violation prevention  
- Pre-flight readiness validation
- Tamper-evident audit trail
- Deterministic replay capability

**ThermalLaw (Thermal Inspection Jurisdiction):**
- Post-hail roof damage assessment
- RGB-primary detection (thermal secondary)
- Governed candidate approval workflow
- Documentation Pack export
- Session replay verification
- **Target:** DJI Drone Onboard AI Challenge 2026

**SurveyLaw (Precision Mapping Jurisdiction):**
- RTK precision surveying (2cm accuracy)
- Grid adherence validation
- GSD compliance verification
- Gap detection and overlap analysis
- **Target:** Civil engineering market (Q3 2026+)



## North Star Metrics

### FlightLaw (Universal Safety)

| Metric | Target | Verification |
|--------|--------|--------------|
| Determinism rate | 100% | Property-based tests (10,000 iterations) |
| Audit replay accuracy | 100% state hash match | End-to-end replay tests |
| FlightLaw enforcement | 100% violation prevention | Compliance test suite |
| Law evaluation latency | <5ms (median) | Performance profiling |

### ThermalLaw (DJI Challenge)

| Metric | Target | Verification |
|--------|--------|--------------|
| End-to-end demo reliability | 100% | Evaluation readiness |
| Candidate proposal recall | >90% | vs manual review |
| False positive rate | <15% | Field validation |
| Operator approval rate | >70% | User acceptance |
| Export generation success | 100% | Reliability testing |

### SurveyLaw (Precision Mapping)

| Metric | Target | Verification |
|--------|--------|--------------|
| Horizontal accuracy (RTK) | <2cm (95% CEP) | Field testing with ground control |
| Grid coverage | >95% | Mission completion analysis |
| GSD compliance | >98% | Altitude verification |
| Gap detection accuracy | 100% (>1m²) | QC validation |


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

### Phase 0: FlightLaw Foundation (February 2026)

**Focus:** Universal safety kernel  
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

### Phase 1: ThermalLaw MVP - Foundation (March 2026)

**Focus:** DJI Challenge end-to-end workflow  
**Target:** Observation → Capture → Queue → Approval → Export

| Deliverable | Status | Description |
|-------------|--------|-------------|
| Session management | ⏳ | Start/end, metadata tracking |
| Frame capture | ⏳ | RGB imagery with GPS metadata |
| Candidate queue UI | ⏳ | Operator review interface |
| Approve/reject actions | ⏳ | Law 8 enforcement |
| Export stub (JSON) | ⏳ | Basic data export |
| Tier 0 baseline | ⏳ | Rule-based candidate finder |

**Success Criteria:**
- Complete inspection session workflow
- Candidates appear in queue
- Operator approval enforced
- JSON export functional

**DJI Challenge Milestone:** End-to-end skeleton operational

---

### Phase 2: ThermalLaw MVP - ML Integration (April 2026)

**Focus:** Onboard ML inference with deterministic post-processing  
**Target:** CoreML model, severity banding, roof zone assignment

| Deliverable | Status | Description |
|-------------|--------|-------------|
| CoreML model integration | ⏳ | Lightweight MobileNet-based model |
| Tier 1 ML proposals | ⏳ | Onboard inference <100ms |
| Deterministic thresholding | ⏳ | Fixed confidence bands |
| Severity banding logic | ⏳ | Minor/Moderate/Significant classification |
| Roof zone assignment | ⏳ | Field/Edge/Ridge/Valley/Penetration |
| Grid deviation tracking | ⏳ | Position tolerance validation |

**Success Criteria:**
- ML inference runs <100ms
- Candidates match deterministic rules
- Severity bands assigned correctly
- Bounded workload (max candidates/zone)

**DJI Challenge Milestone:** Onboard AI operational

---

### Phase 3: ThermalLaw MVP - Export & Polish (May 2026)

**Focus:** Documentation Pack generation and UX refinement  
**Target:** Professional client deliverable

| Deliverable | Status | Description |
|-------------|--------|-------------|
| PDF report generation | ⏳ | Summary + flagged anomalies + coverage |
| Image annotation | ⏳ | Bounding boxes, metadata overlays |
| Coverage map visualization | ⏳ | Roof zone completion tracking |
| UX polish | ⏳ | Approval flow, notifications, feedback |
| Operator training materials | ⏳ | Workflow documentation |

**Success Criteria:**
- PDF export in <30s
- Professional report quality
- Operator workflow smooth
- Coverage tracking accurate

**DJI Challenge Milestone:** MVP feature-complete

---

### Phase 4: ThermalLaw MVP - Replay & Verification (June 2026)

**Focus:** Session replay and determinism verification  
**Target:** DJI Challenge submission readiness

| Deliverable | Status | Description |
|-------------|--------|-------------|
| Replay engine | ⏳ | Identical outputs from audit log |
| Integrity verifier | ⏳ | Hash chain validation |
| Determinism test suite | ⏳ | 100% reproducibility |
| Demo scenarios | ⏳ | Repeatable evaluation demos |
| Challenge submission | ⏳ | Documentation package |

**Success Criteria:**
- Replay produces identical outputs
- Audit log integrity verified
- Demo runs reliably (10/10 successes)
- Documentation complete

**DJI Challenge Milestone:** Submission ready

---

### Phase 5: SurveyLaw Specification (Q3 2026)

**Focus:** Precision mapping jurisdiction architecture  
**Target:** RTK precision, grid generation, GSD compliance

| Deliverable | Status | Description |
|-------------|--------|-------------|
| SurveyLaw HLD + PRD | ✅ | Architecture documented |
| Grid generation algorithm | 📋 | Deterministic parallel line generation |
| RTK precision enforcement | 📋 | 2cm horizontal accuracy requirement |
| GSD compliance validation | 📋 | Altitude + capture verification |
| Gap detection | 📋 | Coverage hole identification |
| Overlap analysis | 📋 | Image overlap calculation |

**Success Criteria:**
- SurveyLaw architecture complete
- Grid generation deterministic
- RTK requirements defined
- Ready for implementation

---

### Phase 6: SurveyLaw Implementation (Q4 2026)

**Focus:** Engineering-grade surveying capability  
**Target:** Civil engineering market entry

| Deliverable | Status | Description |
|-------------|--------|-------------|
| RTK GPS integration | 📋 | D-RTK 2 Mobile Station |
| Mission grid UI | 📋 | Interactive grid planning |
| Real-time GSD monitoring | 📋 | Compliance validation during flight |
| Post-flight QC report | 📋 | Gap detection, overlap analysis |
| Survey Package export | 📋 | CAD/GIS compatible deliverables |

**Success Criteria:**
- RTK fix acquisition <60s
- Position accuracy <2cm (engineering tier)
- GSD compliance >98%
- Survey package export functional

---

## Future Jurisdictions

### Potential Extensions

**SearchLaw (Search & Rescue):**
- Grid search pattern generation
- Coverage optimization
- Thermal/visible fusion for target detection
- Multi-platform coordination

**DeliveryLaw (Package Delivery):**
- Route optimization with safety constraints
- Precision landing validation
- Payload state monitoring
- Delivery confirmation

**InfrastructureLaw (Asset Inspection):**
- Structure-following flight paths
- Defect classification
- Change detection across inspections
- Regulatory compliance documentation


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
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    Operator Interface                        â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚  Map View   â”‚  â”‚  Telemetry  â”‚  â”‚  Decision Support   â”‚  â”‚
â”‚  â”‚             â”‚  â”‚   Display   â”‚  â”‚  (Recommendations)  â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
          â”‚                â”‚                   â”‚
          â–¼                â–¼                   â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚              SwiftVector Decision Layer                      â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”‚
â”‚  â”‚  Pure Functions â€¢ Deterministic â€¢ Auditable         â”‚    â”‚
â”‚  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚    â”‚
â”‚  â”‚  â”‚   Risk    â”‚ â”‚  Battery  â”‚ â”‚     Geofence      â”‚  â”‚    â”‚
â”‚  â”‚  â”‚  Evaluatorâ”‚ â”‚  Modeler  â”‚ â”‚     Validator     â”‚  â”‚    â”‚
â”‚  â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜ â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚    â”‚
â”‚  â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚    â”‚
â”‚  â”‚  â”‚           Thermal Anomaly Agent               â”‚  â”‚    â”‚
â”‚  â”‚  â”‚         (Core ML + Deterministic Post)        â”‚  â”‚    â”‚
â”‚  â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚    â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
          â”‚                â”‚                   â”‚
          â–¼                â–¼                   â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                   Telemetry Layer                            â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”    â”‚
â”‚  â”‚  MAVSDK-Swift â€¢ Combine Streams â€¢ Error Recovery    â”‚    â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
          â”‚
          â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                   PX4 SITL / Hardware                        â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
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
| 1.0 | â€” | Initial product roadmap |
| 2.0 | â€” | Added deployment strategy, risk assessment |
| 3.0 | â€” | SwiftVector integration, Phase 5, architectural principles |
| 4.0 | January 2026 | Unified engineering/product roadmap; thermal inspection extension; updated timelines |

---

## Related Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) â€” Detailed system design
- [SWIFTVECTOR.md](SWIFTVECTOR.md) â€” SwiftVector principles
- [DEVELOPMENT_PLAN.md](docs/DEVELOPMENT_PLAN.md) â€” AI-assisted development workflow
- [TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md) â€” Verification approach
- [THERMAL_INSPECTION_EXTENSION.md](docs/THERMAL_INSPECTION_EXTENSION.md) â€” Thermal anomaly detection spec
- [CONTRIBUTING.md](CONTRIBUTING.md) â€” Contribution guidelines

---

## Suite Documentation

### Architecture & Requirements

| Document | Purpose |
|----------|---------|
| [Flightworks-Suite-Overview.md](docs/Flightworks-Suite-Overview.md) | Master suite architecture |
| [ARCHITECTURE.md](ARCHITECTURE.md) | SwiftVector implementation patterns |
| **FlightLaw (Core)** | |
| [HLD-FlightworksCore.md](docs/HLD-FlightworksCore.md) | Universal safety kernel architecture |
| [PRD-FlightworksCore.md](docs/PRD-FlightworksCore.md) | FlightLaw requirements |
| **ThermalLaw (Inspection)** | |
| [HLD-FlightworksThermal.md](docs/HLD-FlightworksThermal.md) | Thermal inspection architecture |
| [PRD-FlightworksThermal.md](docs/PRD-FlightworksThermal.md) | ThermalLaw requirements |
| [DJI-Challenge-Submission.md](DJI_Challenge_Submission.md) | Competition submission (v0.3) |
| **SurveyLaw (Mapping)** | |
| [HLD-FlightworksSurvey.md](docs/HLD-FlightworksSurvey.md) | Precision mapping architecture |
| [PRD-FlightworksSurvey.md](docs/PRD-FlightworksSurvey.md) | SurveyLaw requirements |

### Development & Testing

| Document | Purpose |
|----------|---------|
| [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) | AI-assisted development workflow |
| [TESTING_STRATEGY.md](TESTING_STRATEGY.md) | Verification approach |
| [SwiftVector-Codex.md](SwiftVector-Codex.md) | Constitutional framework |

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Initial | Original Flightworks Control monolithic roadmap |
| 2.0 | Feb 2026 | **Jurisdiction-based architecture restructuring** |
|  |  | • Split into FlightLaw + ThermalLaw + SurveyLaw |
|  |  | • DJI Challenge focus (ThermalLaw MVP Phases 1-4) |
|  |  | • SurveyLaw specification and implementation phases |
|  |  | • Updated to reflect completed HLD/PRD documentation |

