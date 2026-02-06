# Changelog

All notable changes to Flightworks Control will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Thermal inspection extension specification ([THERMAL_INSPECTION_EXTENSION.md](docs/THERMAL_INSPECTION_EXTENSION.md))
- Comprehensive testing strategy ([TESTING_STRATEGY.md](docs/TESTING_STRATEGY.md))
- AI-assisted development plan ([DEVELOPMENT_PLAN.md](docs/DEVELOPMENT_PLAN.md))
- Edge AI architecture patterns in documentation

### Changed
- Unified product roadmap combining engineering and product perspectives
- Enhanced architecture documentation with agent integration patterns
- Expanded SwiftVector documentation with edge AI extensions

---

## [0.1.0] - 2026-01-XX

### Added

#### Documentation
- **README.md** — Project overview, vision, and getting started guide
- **ROADMAP.md** — Unified product roadmap with 5 development phases
- **ARCHITECTURE.md** — System design and SwiftVector implementation details
- **SWIFTVECTOR.md** — SwiftVector principles and GCS application
- **DEVELOPMENT_PLAN.md** — AI-assisted development workflow
- **TESTING_STRATEGY.md** — Comprehensive testing approach
- **THERMAL_INSPECTION_EXTENSION.md** — Thermal anomaly detection specification
- **CONTRIBUTING.md** — Contribution guidelines
- **CHANGELOG.md** — This file

#### Core Architecture (Phase 0)
- `FlightState` — Immutable flight state representation
- `FlightAction` — Typed flight control actions
- `FlightReducer` — Deterministic state transitions
- `FlightOrchestrator` — Control loop coordination with audit logging
- State/Action/Reducer protocols for extensibility
- `ThermalState` stub — Extension point for Phase 5

#### Project Infrastructure
- Xcode project structure with SwiftUI app target
- Directory organization (Core/, UI/, Telemetry/, Safety/, Agents/)
- MIT License
- GitHub repository initialization

#### Testing Foundation
- Reducer determinism test suite
- State invariant tests
- Property-based testing patterns
- CI/CD pipeline configuration (GitHub Actions)

### Technical Decisions
- **Platform:** macOS 14.0+ / iOS 17.0+
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Architecture:** SwiftVector (State → Action → Reducer)
- **Concurrency:** Swift actors for thread safety
- **Telemetry:** MAVSDK-Swift (Phase 1+)

---

## Version History Summary

| Version | Date | Milestone |
|---------|------|-----------|
| 0.1.0 | 2026-01-XX | Phase 0 Complete — Foundation |
| 0.2.0 | TBD | Phase 1 Complete — Core Flight Interface |
| 0.3.0 | TBD | Phase 2 Complete — Mission Planning |
| 0.4.0 | TBD | Phase 3 Complete — Autonomy Enhancements |
| 0.5.0 | TBD | Phase 4 Complete — Debrief & Replay |
| 1.0.0 | TBD | Phase 5 Complete — Deterministic Decision Support |

---

## Versioning Strategy

### Version Numbers

- **MAJOR (X.0.0):** Breaking changes to core architecture or API
- **MINOR (0.X.0):** New features, phase completions, backward-compatible changes
- **PATCH (0.0.X):** Bug fixes, documentation updates, minor improvements

### Pre-1.0 Development

During pre-1.0 development:
- Minor version increments indicate phase completions
- Patch versions indicate incremental progress within phases
- Breaking changes may occur between minor versions

### Phase-to-Version Mapping

| Phase | Version | Key Deliverables |
|-------|---------|------------------|
| Phase 0 | 0.1.0 | Architecture foundation, documentation |
| Phase 1 | 0.2.0 | Telemetry display, map view, SITL integration |
| Phase 2 | 0.3.0 | Mission planning, geofence validation |
| Phase 3 | 0.4.0 | Battery modeling, state visualization, replay |
| Phase 4 | 0.5.0 | Debrief tools, audit trail viewer |
| Phase 5 | 1.0.0 | AI agents, thermal detection, full SwiftVector |

## [2.0.0] - 2026-02-05

### Changed - Architecture Restructuring
- Restructured monolithic Flightworks Control into jurisdiction-based suite
- Created FlightLaw (core safety kernel)
- Created ThermalLaw (thermal inspection jurisdiction)
- Created SurveyLaw (precision mapping jurisdiction)

### Added
- Flightworks-Suite-Overview.md - Master architecture document
- HLD-FlightworksCore.md, PRD-FlightworksCore.md
- HLD-FlightworksThermal.md, PRD-FlightworksThermal.md
- HLD-FlightworksSurvey.md, PRD-FlightworksSurvey.md

### Deprecated
- HLD-FlightworksControl.md (replaced by Core + Thermal)
- PRD-FlightworksControl.md (replaced by Core + Thermal)
- THERMAL_INSPECTION_EXTENSION.md (now HLD-FlightworksThermal.md)

### Archived
- Moved v1 monolithic documents to archive/v1-monolithic/
---

## How to Read This Changelog

### Change Categories

- **Added** — New features or capabilities
- **Changed** — Changes to existing functionality
- **Deprecated** — Features that will be removed in future versions
- **Removed** — Features that have been removed
- **Fixed** — Bug fixes
- **Security** — Security-related changes

### Links

- Each version header links to the GitHub comparison view
- Issue and PR numbers link to their respective GitHub pages
- Documentation links point to the relevant files

---

## Contributing to the Changelog

When submitting a PR, please update the `[Unreleased]` section with your changes:

1. Add your change under the appropriate category
2. Use imperative mood ("Add feature" not "Added feature")
3. Include relevant issue/PR numbers
4. Keep entries concise but descriptive

Example:
```markdown
### Added
- Geofence polygon editor with tap-to-add vertices (#42)

### Fixed
- Battery percentage calculation overflow for values > 100% (#38)
```

---

[Unreleased]: https://github.com/stephen-sweeney/flightworks-control/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/stephen-sweeney/flightworks-control/releases/tag/v0.1.0
