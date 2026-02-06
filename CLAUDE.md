# CLAUDE.md: Source of Truth for Flightworks Control Development

**Version:** 1.0 (January 28, 2026)

This file defines the repo structure, invariants, commands, and definitions of done for AI-assisted development of Flightworks Control. All agents must reference this to ensure deterministic, auditable changes aligned with SwiftVector principles.

## Project Overview

**Flightworks Control** is an open-source Ground Control Station (GCS) built on SwiftVector architecture, demonstrating deterministic AI control for unmanned aircraft systems.

- **Primary Platform:** macOS 14.0+ / iOS 17.0+
- **Language:** Swift 5.9+ (Swift 6 ready)
- **UI Framework:** SwiftUI
- **Architecture:** SwiftVector (State → Action → Reducer)
- **Repository:** https://github.com/stephen-sweeney/flightworks-control

## Current Module Map

### FlightworksControl (Main App)
```
FlightworksControl/
├── App/
│   └── FlightworksControlApp.swift
├── Core/                          ← SwiftVector implementation
│   ├── State/
│   │   ├── FlightState.swift
│   │   ├── MissionState.swift
│   │   ├── ThermalState.swift     ← Phase 5 extension point
│   │   └── SupportingTypes.swift  ← Position, Attitude, Battery, GPS, etc.
│   ├── Actions/
│   │   ├── FlightAction.swift
│   │   ├── MissionAction.swift
│   │   └── ThermalAction.swift    ← Phase 5 extension point
│   ├── Reducers/
│   │   ├── FlightReducer.swift
│   │   ├── MissionReducer.swift
│   │   └── ThermalReducer.swift   ← Phase 5 extension point
│   └── Orchestrator/
│       └── FlightOrchestrator.swift
├── Telemetry/                     ← Phase 1+
├── UI/                            ← Phase 1+
├── Safety/                        ← Phase 2+
└── Agents/                        ← Phase 5
```

### Dependencies
- **SwiftVectorCore** (https://github.com/stephen-sweeney/SwiftVector)
  - Provides: State, Action, Reducer protocols
  - Provides: AuditEvent, EventLog (hash chain verification)
  - Provides: Determinism DI (Clock, UUIDGenerator, RandomSource)
  - Integration: Via Swift Package Manager

### FlightworksControlTests
```
FlightworksControlTests/
├── Core/
│   ├── ReducerDeterminismTests.swift
│   ├── StateInvariantTests.swift
│   └── OrchestratorTests.swift
├── Safety/
│   ├── InterlockTests.swift       ← 100% coverage required
│   └── ValidatorTests.swift
└── Integration/
    └── ControlLoopTests.swift
```

## Build/Test Commands

### Prerequisites
- Xcode 15.0+ with iOS 17 / macOS 14 SDKs
- Swift 5.9+ toolchain

### SwiftPM (if using Package.swift)
```bash
swift build
swift test
```

### Xcode Project
```bash
# List schemes
xcodebuild -list -project FlightworksControl.xcodeproj

# Build (macOS)
xcodebuild -project FlightworksControl.xcodeproj \
  -scheme FlightworksControl \
  -configuration Debug \
  -destination 'platform=macOS' \
  build

# Test (macOS)
xcodebuild -project FlightworksControl.xcodeproj \
  -scheme FlightworksControl \
  -configuration Debug \
  -destination 'platform=macOS' \
  test

# Build (iOS Simulator)
xcodebuild -project FlightworksControl.xcodeproj \
  -scheme FlightworksControl \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' \
  build
```

### Agent Verification Policy
- Agents may simulate likely build/test outcomes for planning when local execution is unavailable.
- Agents **must not** claim "tests passing / build green" without real command output.
- When providing code, agents should note: "Verify with `swift test` or `xcodebuild test`"

## Invariants (Enforce in All Changes)

### SwiftVector Core Invariants

1. **Determinism/Replayability**
   - Reducers are pure functions (no side effects)
   - Same (State, Action) → Same Result, always
   - Actions are Codable and include source attribution
   - No direct `Date()`, `UUID()`, or random in reducer logic; use injected dependencies

2. **Agent-Reducer Separation**
   - Agents propose only (observe state, generate action proposals)
   - Reducers authorize (validate preconditions, apply changes)
   - Agents never mutate state directly

3. **Audit Chain**
   - Every state transition logged with timestamp, action, state hashes
   - Hash chains enable tamper-evident replay verification
   - Action source tracked (UI, telemetry, agent, system)

4. **Immutable State**
   - State types are structs conforming to Equatable, Codable, Sendable
   - State is never mutated; reducers return new state instances
   - Use `.with()` pattern for state updates

### GCS-Specific Invariants

5. **Safety Interlocks (Non-Negotiable)**
   - Cannot arm without GPS 3D fix
   - Cannot arm with battery < 20%
   - Cannot arm while geofence violated
   - Cannot takeoff while disarmed
   - Cannot change flight mode during takeoff/landing
   - **100% test coverage required for all interlocks**

6. **Operator Authority**
   - AI agents propose, operators decide
   - No auto-execution of critical actions without explicit confirmation
   - All agent proposals include confidence and explanation

7. **Fail-Safe Defaults**
   - Invalid actions return unchanged state (no crash, no partial mutation)
   - Uncertain inputs → conservative recommendations
   - System failures are visible, never silent

### API Stability

- Match SwiftVectorCore protocol signatures where applicable
- GCS-specific types (FlightState, FlightAction) extend, not replace, core patterns
- Public API changes require documentation updates in same commit

## Phase 0 Definition of Done

### Commit 1: Project Structure + SwiftVectorCore Integration
- [ ] Xcode project created with directory structure per module map
- [ ] SwiftVectorCore added as Swift Package dependency
- [ ] App target builds (empty app is fine)
- [ ] Tests target exists and runs (even if empty)

### Commit 2: State Layer
- [ ] `FlightState.swift` — Immutable struct with all Phase 0 properties
- [ ] `ThermalState.swift` — Stub for Phase 5 extension
- [ ] `SupportingTypes.swift` — Position, Attitude, BatteryState, GPSInfo, ConnectionStatus, FlightMode, ArmingState
- [ ] All types: Equatable, Codable, Sendable
- [ ] `.with()` convenience methods for state updates
- [ ] Unit tests for state equality and coding

### Commit 3: Action Layer
- [ ] `FlightAction.swift` — Enum with all Phase 0 action cases
- [ ] `ThermalAction.swift` — Stub for Phase 5 extension
- [ ] All actions: Equatable, Codable, Sendable
- [ ] Actions support source attribution

### Commit 4: Reducer Layer
- [ ] `FlightReducer.swift` — Pure function handling all FlightAction cases
- [ ] Precondition checks as pure helper functions (canArm, canTakeoff, etc.)
- [ ] Invalid actions return unchanged state
- [ ] **Determinism tests:** Same inputs → same outputs (property-based)
- [ ] **Invariant tests:** Safety rules enforced

### Commit 5: Orchestrator
- [ ] `FlightOrchestrator.swift` — @MainActor, @Published state
- [ ] dispatch() method with audit logging
- [ ] Action log with state hashes for replay verification
- [ ] replay() method for determinism verification
- [ ] Integration test: full dispatch cycle

### Commit 6: CI/CD
- [ ] GitHub Actions workflow for build + test
- [ ] Coverage reporting configured
- [ ] Pre-commit hook script (optional)

### Overall Phase 0 Acceptance
- [ ] `swift build` / `xcodebuild build` succeeds
- [ ] `swift test` / `xcodebuild test` succeeds with 80%+ coverage
- [ ] Safety interlock tests at 100% coverage
- [ ] README updated with build instructions
- [ ] CHANGELOG updated with Phase 0 entry

## Multi-Agent Procedure

### Commit Discipline
- One commit per checklist item
- Each commit includes tests for new/changed code
- Documentation updates in same commit if public API changed
- Commit message format: `[Phase X] Component: Brief description`

### Review Gate
- No merge unless relevant tests pass
- Safety-critical code requires explicit review note

### Context Management
- Keep tasks narrow and scoped
- Reference this CLAUDE.md at start of each session
- When resuming, summarize: current commit target, what's done, what's next

## Risk List

### Technical Risks
| Risk | Mitigation |
|------|------------|
| SwiftVectorCore API changes | Pin to specific version; integration tests |
| MAVSDK-Swift instability (Phase 1+) | Robust error handling; fallback to mock telemetry |
| Xcode/Swift toolchain drift | Record versions in PR notes; use .swift-version |
| Scope creep | Strict phase boundaries; this CLAUDE.md as contract |

### AI-Assisted Development Risks
| Risk | Mitigation |
|------|------------|
| Context rot | Narrow tasks; re-inject CLAUDE.md each session |
| Hallucinated test results | Never claim green without real output |
| Over-invention | Stick to specs in ARCHITECTURE.md and ROADMAP.md |
| Regressions | Run full test suite after changes |

## File Header Template

All Swift files should include:
```swift
//
//  FileName.swift
//  FlightworksControl
//
//  Created by [Author] on [Date].
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
```

## Related Documentation

- [README.md](README.md) — Project overview
- [ROADMAP.md](ROADMAP.md) — Product roadmap with phase details
- [ARCHITECTURE.md](ARCHITECTURE.md) — System design and SwiftVector implementation
- [SWIFTVECTOR.md](SWIFTVECTOR.md) — SwiftVector principles
- [TESTING_STRATEGY.md](TESTING_STRATEGY.md) — Testing approach
- [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) — AI-assisted workflow details
- [THERMAL_INSPECTION_EXTENSION.md](THERMAL_INSPECTION_EXTENSION.md) — Phase 5 thermal spec

---

**This CLAUDE.md is the source of truth for AI-assisted development. Reference it at the start of every session.**
