# Flightworks Suite

**Jurisdiction-Based Architecture for Governed Drone Operations**

An open-source suite demonstrating deterministic AI control through composable jurisdictions. **FlightLaw** provides universal safety guarantees, extended by mission-specific jurisdictions (**ThermalLaw** for inspection, **SurveyLaw** for mapping) built on [SwiftVector](docs/SWIFTVECTOR.md) principles.

[![Build Status](https://github.com/stephen-sweeney/flightworks-control/workflows/Test%20Suite/badge.svg)](https://github.com/stephen-sweeney/flightworks-control/actions)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20iOS-lightgrey)](https://github.com/stephen-sweeney/flightworks-control)
[![Swift](https://img.shields.io/badge/swift-5.9+-orange)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Status](https://img.shields.io/badge/status-ThermalLaw%20MVP-yellow)](docs/ROADMAP.md)

---

## Vision

**Governed AI is competitive AI.** The Flightworks Suite demonstrates that deterministic, auditable control systems enable:

- **Safety-critical certification** through mathematical proof of behavior
- **Operator trust** through transparent reasoning and replay capability
- **Regulatory compliance** through tamper-evident audit trails
- **Market differentiation** through unique architectural guarantees

### The Jurisdiction Model

```
┌─────────────────────────────────────────────────────────────┐
│              SWIFTVECTOR CODEX                              │
│         (Constitutional Framework)                          │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              FLIGHTLAW (Universal Safety Kernel)            │
│  • Law 3: Observation (Telemetry, pre-flight)              │
│  • Law 4: Resource (Battery, thermal limits)               │
│  • Law 7: Spatial (Geofencing, altitude)                   │
│  • Law 8: Authority (Operator approval)                    │
│  • Audit trail with SHA256 hash chain                      │
└─────────────────────────────────────────────────────────────┘
         │                              │
         ▼                              ▼
┌──────────────────┐          ┌──────────────────┐
│   THERMALLAW     │          │    SURVEYLAW     │
│  (Inspection)    │          │   (Mapping)      │
│                  │          │                  │
│ • Post-hail roof │          │ • RTK precision  │
│   assessment     │          │   (2cm accuracy) │
│ • RGB detection  │          │ • Grid adherence │
│ • Governed AI    │          │ • GSD compliance │
│ • DJI Challenge  │          │ • Gap detection  │
│   2026           │          │ • Civil eng.     │
└──────────────────┘          └──────────────────┘
```

**Architecture Principle:** Domain jurisdictions inherit FlightLaw safety guarantees while adding mission-specific governance—no conflicts, no compromises.

---

## Current Focus: ThermalLaw MVP (DJI Challenge 2026)

### Business Guarantee

> **"No critical damage will be missed or hallucinated."**

**Workflow:** Observe → Infer → Explain → Approve → Flag → Export → Replay

| Component | Status | Description |
|-----------|--------|-------------|
| **FlightLaw Core** | ✅ Specified | Universal safety kernel (HLD + PRD) |
| **ThermalLaw Spec** | ✅ Specified | Thermal inspection architecture (HLD + PRD) |
| **Phase 1** | ⏳ Mar 2026 | Session management, capture, approval workflow |
| **Phase 2** | 📋 Apr 2026 | CoreML integration, deterministic classification |
| **Phase 3** | 📋 May 2026 | PDF export, coverage tracking, UX polish |
| **Phase 4** | 📋 Jun 2026 | Session replay, determinism verification |

**Platform:** DJI Matrice 4T (RGB + Thermal)  
**Competition:** [DJI Drone Onboard AI Challenge 2026](https://developer.dji.com/challenge-2026)

---

## Features

### FlightLaw (Universal Safety Kernel)

- [x] SwiftVector architecture specification
- [x] State/Action/Reducer protocols
- [x] Law 3 (Observation) specification
- [x] Law 4 (Resource) specification
- [x] Law 7 (Spatial) specification
- [x] Law 8 (Authority) specification
- [x] Audit trail with SHA256 hash chain
- [x] Deterministic replay capability

### ThermalLaw (Thermal Inspection)

**Phase 1 - Foundation (Mar 2026):**
- [ ] Session management (start/end, metadata)
- [ ] Frame capture with GPS metadata
- [ ] Candidate queue UI
- [ ] Operator approval/rejection (Law 8)
- [ ] JSON export stub

**Phase 2 - ML Integration (Apr 2026):**
- [ ] CoreML model integration
- [ ] Onboard inference (<100ms)
- [ ] Deterministic severity banding
- [ ] Roof zone assignment
- [ ] Bounded workload enforcement

**Phase 3 - Export & Polish (May 2026):**
- [ ] PDF report generation
- [ ] Image annotation
- [ ] Coverage map visualization
- [ ] Operator workflow UX

**Phase 4 - Replay & Verification (Jun 2026):**
- [ ] Session replay engine
- [ ] Audit log integrity verification
- [ ] Demo scenarios
- [ ] DJI Challenge submission

### SurveyLaw (Precision Mapping)

- [x] SurveyLaw architecture specification
- [x] RTK precision requirements
- [x] Grid generation algorithms
- [x] GSD compliance rules
- [ ] Implementation (Q3 2026+)

---

## Architecture

### Jurisdiction Composition

```
┌─────────────────────────────────────────────────────────────┐
│                    Operator Interface                       │
│         Thermal Queue • Coverage Map • Approval UI          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  THERMALLAW REDUCER                         │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Deterministic Post-Processing                        │  │
│  │  • Confidence thresholding (≥0.5)                     │  │
│  │  • Severity banding (Minor/Moderate/Significant)     │  │
│  │  • Roof zone assignment                              │  │
│  │  • Bounded candidates per zone (<50)                 │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   FLIGHTLAW ENFORCER                        │
│  • Battery reserve (20% RTL threshold)                     │
│  • Geofence violations (100% prevention)                   │
│  • Pre-flight readiness gates                              │
│  • Operator authority (risk-tiered approval)               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Telemetry + ML Layer                      │
│         MAVLink Stream • CoreML Inference • GPS             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   DJI Matrice 4T                            │
│              RGB Camera • Thermal Sensor                    │
└─────────────────────────────────────────────────────────────┘
```

For detailed architecture, see [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Getting Started

### Requirements

- macOS 14.0+ (Sonoma) or iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- DJI Matrice 4T (for field deployment)

### Quick Start

```bash
# Clone the repository
git clone https://github.com/stephen-sweeney/flightworks-control.git
cd flightworks-control

# Open in Xcode
open FlightworksControl.xcodeproj

# Build and run (⌘R)
```

### Running Tests

```bash
# Run all tests
xcodebuild test -scheme FlightworksControl -destination 'platform=macOS'

# Run determinism tests only
xcodebuild test -scheme FlightworksControl -destination 'platform=macOS' \
  -only-testing:FlightworksControlTests/Core/ReducerDeterminismTests
```

---

## Documentation

### Suite Architecture

| Document | Description |
|----------|-------------|
| [Flightworks-Suite-Overview.md](docs/Flightworks-Suite-Overview.md) | Master suite architecture and jurisdiction model |
| [ARCHITECTURE.md](ARCHITECTURE.md) | SwiftVector implementation patterns |
| [ROADMAP.md](ROADMAP.md) | Development roadmap by jurisdiction |

### FlightLaw (Universal Safety Kernel)

| Document | Description |
|----------|-------------|
| [HLD-FlightworksCore.md](docs/HLD-FlightworksCore.md) | FlightLaw technical architecture |
| [PRD-FlightworksCore.md](docs/PRD-FlightworksCore.md) | FlightLaw requirements specification |

### ThermalLaw (Thermal Inspection)

| Document | Description |
|----------|-------------|
| [HLD-FlightworksThermal.md](docs/HLD-FlightworksThermal.md) | ThermalLaw technical architecture |
| [PRD-FlightworksThermal.md](docs/PRD-FlightworksThermal.md) | ThermalLaw requirements specification |
| [DJI-Challenge-Submission.md](DJI_Challenge_Submission.md) | DJI Challenge submission (v0.3) |

### SurveyLaw (Precision Mapping)

| Document | Description |
|----------|-------------|
| [HLD-FlightworksSurvey.md](docs/HLD-FlightworksSurvey.md) | SurveyLaw technical architecture |
| [PRD-FlightworksSurvey.md](docs/PRD-FlightworksSurvey.md) | SurveyLaw requirements specification |

### Development & Testing

| Document | Description |
|----------|-------------|
| [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) | AI-assisted development workflow |
| [TESTING_STRATEGY.md](TESTING_STRATEGY.md) | Verification approach and test strategy |
| [SwiftVector-Codex.md](SwiftVector-Codex.md) | Constitutional framework (Laws 0-10) |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines |
| [CHANGELOG.md](CHANGELOG.md) | Version history |

### Archived Documents

See `archive/v1-monolithic/` for historical v1 documentation:
- HLD-FlightworksControl.md (superseded by FlightLaw + ThermalLaw)
- PRD-FlightworksControl.md (superseded by FlightLaw + ThermalLaw)
- THERMAL_INSPECTION_EXTENSION.md (now HLD-FlightworksThermal.md)

---

## Why Jurisdictions?

The jurisdiction model provides strategic advantages:

### Technical Benefits

| Benefit | Description |
|---------|-------------|
| **Code Reuse** | Safety logic written once in FlightLaw, inherited everywhere |
| **Consistency** | Identical safety behavior across all jurisdictions |
| **Modularity** | Add new jurisdictions without modifying FlightLaw |
| **Testability** | Test FlightLaw once, trust it everywhere |

### Business Benefits

| Benefit | Description |
|---------|-------------|
| **Certifiability** | Prove safety properties once, apply to all jurisdictions |
| **Market Flexibility** | Target multiple markets (inspection, surveying, search & rescue) |
| **Competitive Edge** | Unique architectural guarantees (determinism, audit, replay) |
| **SBIR/STTR Alignment** | Jurisdiction model aligns with DoD trusted autonomy priorities |

---

## Why Open Source?

Safety-critical software demands transparency. When lives depend on system behavior, "trust us" isn't good enough.

**Open source enables:**

- **Verification** — Anyone can audit the code that controls aircraft
- **Auditability** — The deterministic architecture we claim is provable, not promised
- **Community** — Collective expertise improves safety for everyone
- **Trust** — Operators can inspect exactly what their GCS does

SwiftVector's core principle—state as truth, not hidden in prompts—extends to the project itself. The code is the truth. It's open for inspection.

> ⚠️ **Disclaimer:** This is a research and demonstration platform, not certified operational software. Do not use for actual flight operations.

---

## Project Status

### Current Phase: ThermalLaw MVP Development

🎯 **Target:** DJI Drone Onboard AI Challenge 2026 (June submission)

| Phase | Timeline | Status |
|-------|----------|--------|
| Phase 0: FlightLaw Foundation | Feb 2026 | ✅ Specified |
| Phase 1: ThermalLaw Foundation | Mar 2026 | ⏳ Next |
| Phase 2: ML Integration | Apr 2026 | 📋 Planned |
| Phase 3: Export & Polish | May 2026 | 📋 Planned |
| Phase 4: Replay & Verification | Jun 2026 | 📋 Planned |

### Recent Milestones

| Milestone | Date | Status |
|-----------|------|--------|
| Jurisdiction architecture defined | Feb 2026 | ✅ Complete |
| FlightLaw specification (HLD + PRD) | Feb 2026 | ✅ Complete |
| ThermalLaw specification (HLD + PRD) | Feb 2026 | ✅ Complete |
| SurveyLaw specification (HLD + PRD) | Feb 2026 | ✅ Complete |
| Architecture restructuring | Feb 2026 | ✅ Complete |

See [ROADMAP.md](ROADMAP.md) for complete development timeline.

---

## Related Work

Flightworks Suite is part of the [Agent in Command](https://agentincommand.ai) project exploring deterministic AI architectures for safety-critical systems.

### Foundation Papers

| Resource | Description |
|----------|-------------|
| [SwiftVector Whitepaper](https://agentincommand.ai/swiftvector) | Deterministic control architecture for stochastic agent systems |
| [Swift at the Edge](https://agentincommand.ai/swift-at-the-edge) | On-device AI manifesto using Swift |
| [The Agency Paradox](https://agentincommand.ai/agency-paradox) | Human command over AI systems ("AI proposes, humans decide") |

### Technical Writing

Articles documenting jurisdiction development:

- *Building FlightLaw: Universal Safety Kernel for Drone Operations* (Phase 0)
- *ThermalLaw: Governed AI for Post-Hail Roof Assessment* (Phases 1-4)
- *Deterministic ML Post-Processing for Safety-Critical Edge AI* (Phase 2)
- *Session Replay: Mathematical Proof of Determinism* (Phase 4)

---

## Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting pull requests.

### Development Philosophy

This project practices **Human-in-Command** development:

1. **Specification first** — Clear HLD/PRD before implementation
2. **Tests alongside code** — Verify behavior as we build
3. **Architecture review** — All changes evaluated against SwiftVector principles
4. **Jurisdiction integrity** — FlightLaw changes require extra scrutiny

### Current Contribution Opportunities

- 🛠️ FlightLaw Core implementation
- 🔥 ThermalLaw MVP development (DJI Challenge)
- 🧪 Determinism test suite expansion
- 📖 Documentation improvements
- 💡 New jurisdiction proposals (SearchLaw, DeliveryLaw, etc.)

---

## License

MIT License — See [LICENSE](LICENSE) for details.

This project is open source to enable verification and community contribution. Commercial use is permitted under MIT terms.

---

## Author

**Stephen Sweeney**  
Founder, [Flightworks Aerial LLC](https://flightworksaerial.com)  
[Agent in Command](https://agentincommand.ai)

Building trustworthy autonomous systems through deterministic architecture, transparent development, and jurisdiction-based governance.

---

## Acknowledgments

- [PX4 Autopilot](https://px4.io/) — Open source flight control
- [MAVSDK](https://mavsdk.mavlink.io/) — MAVLink SDK
- [DJI Developer](https://developer.dji.com/) — Matrice 4T platform
- The Swift and SwiftUI communities

---

<p align="center">
  <i>Proving that governed AI is competitive AI — one jurisdiction at a time.</i>
</p>
