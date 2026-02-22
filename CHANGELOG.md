# Changelog

All notable changes to Flightworks Control will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added — Phase 0: FlightLaw Foundation (SP0-1 through SP0-6)

#### SP0-1: Project Infrastructure
- Xcode project created with directory structure per CLAUDE.md module map
- SwiftVectorCore integrated as remote SPM dependency (`https://github.com/stephen-sweeney/SwiftVector` @ `0.1.0`)
- iOS deployment target: 26.2; Swift 5.9+; SwiftUI app entry point
- `Package.resolved` committed to pin SwiftVectorCore `0.1.0`

#### SP0-2: State Layer
- `FlightState` — immutable struct conforming to `SwiftVectorCore.State` (Equatable, Codable, Sendable, SHA-256 `stateHash()`)
- `SupportingTypes` — Position (WGS-84), Attitude (Euler), BatteryState, GPSInfo, TelemetryData, ConnectionStatus, ArmingState, FlightMode, GPSFixType, Mission, Waypoint, Geofence, ConnectionConfig
- `MissionState` — Phase 1 stub
- `ThermalState` — Phase 5 extension point stub
- `FlightState.with()` — optional-of-optional pattern for immutable field updates
- `FlightState.initial` — epoch-sentinel `lastUpdated`; all calibration flags `false`
- Arming precondition fields: `imuCalibrated`, `compassCalibrated` (PRD FR-2.2, FR-2.3)
- `StateLayerTests` — Codable round-trip, Equatable, `.with()` immutability, `stateHash()` determinism

#### SP0-3: Action Layer
- `FlightAction` — 17-case enum conforming to `SwiftVectorCore.Action` (Equatable, Codable, Sendable, `correlationID`, `actionDescription`)
- Cases: connect, disconnect, connectionStatusChanged, telemetryReceived, sensorCalibrationUpdated, arm, disarm, takeoff, land, returnToLaunch, setFlightMode, loadMission, startMission, pauseMission, clearMission, setGeofence, clearGeofence
- `ThermalAction` — Phase 5 stub (enableDetection, disableDetection)
- `ActionLayerTests` — Codable round-trip, Equatable, `correlationID` extraction, `actionDescription` coverage

#### SP0-4: Reducer Layer
- `FlightReducer` — pure function conforming to `SwiftVectorCore.Reducer`; handles all 17 `FlightAction` cases
- Safety interlocks (100% test coverage): GPS 3D fix required to arm; battery ≥ 20% to arm; IMU + compass calibration required to arm; geofence required to arm (Law 7); disarmed required to takeoff; mode changes blocked during takeoff/landing
- `canArm()`, `canTakeoff()`, `canChangeMode()` — pure helper predicates
- `ThermalReducer` — Phase 5 stub
- `ReducerLayerTests` — 9 serialised `@Suite` structs covering all action cases and interlock combinations

#### SP0-5: Orchestrator Layer
- `FlightOrchestrator` (`actor`) — runtime boundary between UI/agents and `FlightReducer`
- `dispatch(_:agentID:)` — sole state-change entry point; runs reducer, appends hash-chained `AuditEvent` to `EventLog<FlightAction>`, yields new state to `AsyncStream`
- Hash chain: each `AuditEvent.previousEntryHash = auditLog.lastEntryHash` — tamper-evident
- `replay(log:) -> ReplayResult` — re-executes accepted actions against `FlightState.initial`, verifies final state hash
- `stateStream() -> AsyncStream<FlightState>` — reactive state for SwiftUI observation
- `Clock` + `UUIDGenerator` injected — zero `Date()` or `UUID()` calls in actor body
- `OrchestratorTests` — 4 serialised suites: dispatch, audit trail, replay, full connect→arm integration cycle

#### SP0-6: CI/CD
- `.github/workflows/ci.yml` — GitHub Actions CI on `macos-15` / Xcode 16.2 / iOS 18.2 simulator
  - Overrides `IPHONEOS_DEPLOYMENT_TARGET=18.2` for CI (project targets iOS 26.2 locally; GitHub runners only carry iOS 18.x SDK)
  - Steps: checkout, Xcode 16.2 selection, SPM cache (keyed on `Package.resolved`), resolve, build, test (`-enableCodeCoverage YES`, `-parallel-testing-enabled NO`), coverage report (text + JSON), `.xcresult` and `coverage.json` artifact upload (14-day retention), mandatory non-determinism scan
  - Non-determinism scan: fails workflow on any direct `Date()`, `UUID()`, or `.random` in production Swift source (excluding `// deterministic:` exceptions)
  - Concurrency: `cancel-in-progress: true` for push/PR triggers on `main`
- `.githooks/pre-commit` — local mirror of CI non-determinism scan; activate with `git config core.hooksPath .githooks`
- `README.md` — CI badge, corrected build/test commands, pre-commit hook activation instructions

### Added — Previous Documentation
- Thermal inspection extension specification
- Comprehensive testing strategy
- AI-assisted development plan
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
