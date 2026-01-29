# Flightworks Control

**Deterministic Ground Control for Safety-Critical Autonomous Systems**

An open-source Ground Control Station built on [SwiftVector](docs/SWIFTVECTOR.md) principles—demonstrating how to wrap deterministic control architecture around AI decision support for unmanned aircraft operations.

[![Build Status](https://github.com/stephen-sweeney/flightworks-control/workflows/Test%20Suite/badge.svg)](https://github.com/stephen-sweeney/flightworks-control/actions)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20iOS-lightgrey)](https://github.com/stephen-sweeney/flightworks-control)
[![Swift](https://img.shields.io/badge/swift-5.9+-orange)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)
[![Status](https://img.shields.io/badge/status-Phase%200%20In%20Progress-yellow)](docs/ROADMAP.md)

---

## Vision

Unmanned aircraft operators need clarity, speed, and confidence. Current ground control systems either lack modern UI/UX or rely on unpredictable AI that cannot be certified for safety-critical operations.

**Flightworks Control demonstrates a different approach:**

| Challenge | Our Solution |
|-----------|--------------|
| AI unpredictability | Deterministic decision pipelines with identical outputs for identical inputs |
| Operator trust | Transparent reasoning—every recommendation explains *why* |
| Certification barriers | Auditable state transitions, replayable sessions |
| Cloud dependency | All critical processing runs locally on-device |
| Cognitive overload | Operator-first UI design that prioritizes situational awareness |

### The SwiftVector Approach

```
State → Agent → Action → Reducer → New State
         ↓
    (Proposes)    (Validates & Applies)
```

- **State** is immutable and represents complete system truth
- **Agents** observe state and propose typed actions (never execute directly)
- **Reducers** validate proposals and apply changes deterministically
- **Everything** is logged, auditable, and replayable

This architecture ensures that given the same inputs, the system produces the same outputs—every time. No hidden state. No stochastic surprises.

---

## Features

### Current (Phase 0)

- [x] SwiftVector architecture foundation
- [x] State/Action/Reducer pattern implementation
- [x] Orchestrator with action logging
- [x] Determinism verification test suite
- [x] Project documentation

### Coming Soon

- [ ] **Phase 1:** Real-time telemetry display, map view with aircraft tracking
- [ ] **Phase 2:** Mission planning with waypoints, geofence validation
- [ ] **Phase 3:** Battery modeling, state machine visualization, ADS-B display
- [ ] **Phase 4:** Flight replay, audit trail viewer, mission export
- [ ] **Phase 5:** AI decision support agents, risk assessment, route optimization

### Preview: Thermal Inspection Extension

Flightworks Control includes an upcoming thermal anomaly detection extension that demonstrates deterministic processing of ML outputs:

```
Thermal Frame → Core ML → Probabilistic Output → Deterministic Classification → Operator Alert
```

This extension supports [Flightworks Aerial LLC](https://flightworksaerial.com) commercial inspection services for roofs, electrical infrastructure, solar arrays, and building envelopes.

See [THERMAL_INSPECTION_EXTENSION.md](docs/THERMAL_INSPECTION_EXTENSION.md) for technical specification.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Operator Interface                        │
│         Map View • Telemetry Display • Decision Support      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              SwiftVector Decision Layer                      │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Pure Functions • Deterministic • Auditable         │    │
│  └─────────────────────────────────────────────────────┘    │
│     Risk Evaluator │ Battery Modeler │ Geofence Validator   │
│                    │ Thermal Agent (Phase 5)                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Telemetry Layer                            │
│            MAVSDK-Swift • Combine Streams                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   PX4 SITL / Hardware                        │
└─────────────────────────────────────────────────────────────┘
```

For detailed architecture documentation, see [ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## Getting Started

### Requirements

- macOS 14.0+ (Sonoma) or iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

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

### Simulator Integration

PX4 SITL integration is planned for Phase 1. Currently, the application displays simulated telemetry data for UI development and architecture validation.

---

## Documentation

| Document | Description |
|----------|-------------|
| [ROADMAP.md](docs/ROADMAP.md) | Product roadmap with phase details, timelines, and success criteria |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System design, component architecture, and design decisions |
| [SWIFTVECTOR.md](docs/SWIFTVECTOR.md) | SwiftVector principles and their application in this project |
| [DEVELOPMENT_PLAN.md](docs/DEVELOPMENT_PLAN.md) | AI-assisted development workflow and task breakdowns |
| [TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md) | Testing approach, coverage requirements, and CI/CD |
| [THERMAL_INSPECTION_EXTENSION.md](docs/THERMAL_INSPECTION_EXTENSION.md) | Thermal anomaly detection specification |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guidelines |
| [CHANGELOG.md](CHANGELOG.md) | Version history |

---

## Why Open Source?

Safety-critical software demands transparency. When lives depend on system behavior, "trust us" isn't good enough.

**Open source enables:**

- **Verification** — Anyone can audit the code that controls aircraft
- **Auditability** — The deterministic architecture we claim is provable, not just promised
- **Community** — Collective expertise improves safety for everyone
- **Trust** — Operators can inspect exactly what their GCS does

SwiftVector's core principle—state as truth, not hidden in prompts—extends to the project itself. The code is the truth. It's open for inspection.

> ⚠️ **Disclaimer:** This is a research and demonstration platform, not certified operational software. Do not use for actual flight operations.

---

## Project Status

🚧 **Phase 0: Foundation** — In Progress

The project is establishing its architectural foundation. Core SwiftVector patterns are being implemented and validated through comprehensive testing.

### Milestones

| Milestone | Target | Status |
|-----------|--------|--------|
| Architecture documentation complete | Week 2 | ✅ Complete |
| Core State/Action/Reducer implemented | Week 2 | 🔄 In Progress |
| Determinism test suite passing | Week 2 | ⏳ Planned |
| Phase 0 complete | Week 2 | ⏳ Planned |
| Public announcement | End of Phase 2 | ⏳ Planned |

See [ROADMAP.md](docs/ROADMAP.md) for the complete development timeline.

---

## Related Work

Flightworks Control is part of the [Agent in Command](https://agentincommand.ai) project exploring deterministic AI architectures for safety-critical systems.

### Papers & Resources

| Resource | Description |
|----------|-------------|
| [SwiftVector Whitepaper](https://agentincommand.ai/swiftvector) | Deterministic control architecture for stochastic agent systems |
| [Swift at the Edge](https://agentincommand.ai/swift-at-the-edge) | A manifesto for on-device AI using Swift |
| [The Agency Paradox](https://agentincommand.ai/agency-paradox) | Maintaining human command over AI systems |

### Technical Writing

As development progresses, technical articles documenting lessons learned will be published:

- *Building a Deterministic GCS: SwiftVector Foundation* (Phase 0)
- *Real-Time Telemetry in Swift: Combine Streams for Safety-Critical Data* (Phase 1)
- *Geofence Validation as Pure Functions* (Phase 2)
- *SwiftVector in Practice: Deterministic AI for Safety-Critical Systems* (Phase 5)

---

## Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting pull requests.

### Development Philosophy

This project practices **Human-in-Command** development:

1. **Specification first** — Clear specs before implementation
2. **Tests alongside code** — Verify behavior as we build
3. **Architecture review** — All changes evaluated against SwiftVector principles
4. **Safety-critical approval** — Explicit review for safety-related code

### Areas for Contribution

- 🐛 Bug reports and fixes
- 📖 Documentation improvements
- 🧪 Test coverage expansion
- 🎨 UI/UX enhancements
- 💡 Feature proposals (via Issues)

---

## License

MIT License — See [LICENSE](LICENSE) for details.

This project is open source to enable verification and community contribution. Commercial use is permitted under MIT terms.

---

## Author

**Stephen Sweeney**  
Founder, [Flightworks Aerial LLC](https://flightworksaerial.com)  
[Agent in Command](https://agentincommand.ai)

Building trustworthy autonomous systems through deterministic architecture and transparent development.

---

## Acknowledgments

- [PX4 Autopilot](https://px4.io/) — Open source flight control
- [MAVSDK](https://mavsdk.mavlink.io/) — MAVLink SDK
- The Swift and SwiftUI communities

---

<p align="center">
  <i>Building trustworthy autonomous systems, one deterministic state transition at a time.</i>
</p>
