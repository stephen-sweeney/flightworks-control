# Flightworks Suite: Testing Strategy

## Verification for Safety-Critical Deterministic Systems

**Version:** 2.0  
**Date:** February 2026  
**Project:** Flightworks Suite (Jurisdiction-Based Architecture)  
**Methodology:** SwiftVector + Property-Based Testing + Jurisdiction Testing

---

## Overview

Testing in the Flightworks Suite serves three purposes:

1. **Functional Correctness** — Does the system behave as specified?
2. **Determinism Verification** — Given identical inputs, does the system produce identical outputs?
3. **Jurisdiction Integrity** — Does each jurisdiction correctly inherit and extend FlightLaw guarantees?

For safety-critical systems, properties 2 and 3 are non-negotiable. This document outlines the testing strategy that ensures all three properties hold across FlightLaw and all jurisdictions.

---

## Testing Philosophy

### The SwiftVector Testing Principle

> If you can't replay it exactly, you can't trust it.

Every component that processes state or produces decisions must be verifiable through replay. This means:

- **Pure functions** can be tested with simple input/output assertions
- **State machines** can be tested with sequence replay
- **Agents** can be tested with recorded state snapshots
- **Jurisdictions** can be tested with compliance suites
- **The entire system** can be tested with session replay

### Jurisdiction Testing Principle

> If FlightLaw guarantees hold, they must hold in every jurisdiction—no exceptions.

Each jurisdiction must:
- **Inherit** all FlightLaw safety guarantees (Laws 3, 4, 7, 8)
- **Extend** with domain-specific governance (without conflicts)
- **Verify** compliance through jurisdiction-specific test suites

---

## Testing Pyramid

```
                    ┌───────────────┐
                    │   E2E Tests   │  ← Session replay (ThermalLaw, SurveyLaw)
                    │   (Few, Slow) │     Determinism verification
                    └───────┬───────┘
                            │
                ┌───────────┴───────────┐
                │   Integration Tests   │  ← Jurisdiction composition
                │      (Some, Medium)   │     FlightLaw + ThermalLaw
                └───────────┬───────────┘     Multi-component workflows
                            │
        ┌───────────────────┴───────────────────┐
        │            Unit Tests                  │  ← Reducers, validators
        │         (Many, Fast)                  │     Agents, classifiers
        └───────────────────┬───────────────────┘
                            │
    ┌───────────────────────┴───────────────────────┐
    │           Property-Based Tests                │  ← Determinism
    │              (Foundational)                   │     Invariants
    │                                               │     Jurisdiction compliance
    └───────────────────────────────────────────────┘
```

---

## Test Categories

### 1. Property-Based Tests (Determinism Foundation)

Property-based tests verify that fundamental properties hold across a wide range of inputs. These are the foundation of SwiftVector's determinism guarantee.

#### FlightLaw Reducer Determinism Tests

```swift
import XCTest

final class FlightLawDeterminismTests: XCTestCase {
    
    /// Property: Same state + same action = same result (always)
    func testFlightReducerDeterminism() {
        // Generate random but valid state/action pairs
        let testCases = generateRandomFlightStateActionPairs(count: 10_000)
        
        for (state, action) in testCases {
            let result1 = FlightReducer.reduce(state: state, action: action)
            let result2 = FlightReducer.reduce(state: state, action: action)
            
            XCTAssertEqual(result1, result2, 
                "FlightLaw reducer produced different results: \(state), \(action)")
        }
    }
    
    /// Property: Reducer is a pure function (no side effects)
    func testFlightReducerPurity() {
        let initialState = FlightState.mock()
        let action = FlightAction.arm
        
        // Call reducer multiple times
        _ = FlightReducer.reduce(state: initialState, action: action)
        _ = FlightReducer.reduce(state: initialState, action: action)
        _ = FlightReducer.reduce(state: initialState, action: action)
        
        // Original state must be unchanged (immutability)
        XCTAssertEqual(initialState, FlightState.mock(),
            "FlightLaw reducer modified input state (violated purity)")
    }
    
    /// Property: Reducer handles all action types (totality)
    func testFlightReducerTotality() {
        let state = FlightState.mock()
        
        // Every action case must be handled without crashing
        for action in FlightAction.allCases {
            let result = FlightReducer.reduce(state: state, action: action)
            XCTAssertNotNil(result, "FlightLaw reducer failed to handle: \(action)")
        }
    }
}
```

#### ThermalLaw Reducer Determinism Tests

```swift
final class ThermalLawDeterminismTests: XCTestCase {
    
    /// Property: Severity banding is deterministic
    func testSeverityBandingDeterminism() {
        let testCases = generateRandomMLOutputs(count: 10_000)
        
        for mlOutput in testCases {
            let result1 = ThermalClassifier.classify(mlOutput)
            let result2 = ThermalClassifier.classify(mlOutput)
            
            XCTAssertEqual(result1, result2,
                "Severity banding produced different results for: \(mlOutput)")
        }
    }
    
    /// Property: Candidate classification is deterministic
    func testCandidateClassificationDeterminism() {
        let testCases = generateRandomCandidates(count: 10_000)
        
        for candidate in testCases {
            let state = ThermalState.mock(captureState: .active)
            let action = ThermalAction.proposeCandidate(candidate)
            
            let result1 = ThermalReducer.reduce(state: state, action: action)
            let result2 = ThermalReducer.reduce(state: state, action: action)
            
            XCTAssertEqual(result1, result2,
                "Candidate classification non-deterministic: \(candidate)")
        }
    }
    
    /// Property: Bounded workload enforcement
    func testBoundedWorkloadEnforcement() {
        var state = ThermalState.mock()
        
        // Try to add more than max candidates per zone
        for i in 0..<100 {
            let candidate = RoofCandidate.mock(roofZone: .field)
            state = ThermalReducer.reduce(
                state: state,
                action: .proposeCandidate(candidate)
            )
        }
        
        // Should never exceed max candidates per zone
        let fieldCandidates = state.proposedCandidates.filter { 
            $0.roofZone == .field 
        }
        
        XCTAssertLessThanOrEqual(fieldCandidates.count, 50,
            "Bounded workload violated: \(fieldCandidates.count) candidates")
    }
}
```

---

### 2. FlightLaw Compliance Tests (Law Enforcement)

These tests verify that FlightLaw (Laws 3, 4, 7, 8) is correctly enforced.

#### Law 3: Observation (Telemetry & Readiness)

```swift
final class Law3ObservationTests: XCTestCase {
    
    func testPreFlightValidationRequired() {
        let state = FlightState.mock(
            gpsInfo: .noFix,
            battery: BatteryState(percentage: 100, voltage: 16.8)
        )
        
        let result = FlightReducer.reduce(state: state, action: .arm)
        
        XCTAssertEqual(result.armingState, .disarmed,
            "Law 3 violated: armed without GPS fix")
    }
    
    func testTelemetryLoggingEnforced() {
        let orchestrator = FlightOrchestrator()
        orchestrator.dispatch(.telemetryReceived(TelemetryData.mock()))
        
        XCTAssertGreaterThan(orchestrator.auditLog.count, 0,
            "Law 3 violated: telemetry not logged")
    }
}
```

#### Law 4: Resource (Battery & Thermal Limits)

```swift
final class Law4ResourceTests: XCTestCase {
    
    func testBatteryReserveEnforcement() {
        let state = FlightState.mock(
            flightMode: .flying,
            battery: BatteryState(percentage: 19, voltage: 14.4)
        )
        
        let result = FlightReducer.reduce(state: state, action: .updateBattery(19))
        
        XCTAssertEqual(result.flightMode, .returningToLaunch,
            "Law 4 violated: did not enforce RTL at 20% threshold")
    }
    
    func testThermalLimitMonitoring() {
        // Manifold 3 thermal limit: 50°C
        let state = SystemState.mock(cpuTemp: 52.0)
        
        let result = SystemReducer.reduce(state: state, action: .thermalUpdate(52.0))
        
        XCTAssertEqual(result.systemStatus, .degraded,
            "Law 4 violated: did not degrade at thermal limit")
    }
}
```

#### Law 7: Spatial (Geofencing & Altitude)

```swift
final class Law7SpatialTests: XCTestCase {
    
    func testGeofenceViolationPrevention() {
        let geofence = Geofence(center: Position(lat: 39.0, lon: -105.0), radius: 100)
        let state = FlightState.mock(activeGeofence: geofence)
        
        let outsidePosition = Position(lat: 39.1, lon: -105.1)
        let action = FlightAction.setWaypoint(outsidePosition)
        
        let result = FlightReducer.reduce(state: state, action: action)
        
        XCTAssertNil(result.nextWaypoint,
            "Law 7 violated: waypoint outside geofence accepted")
    }
    
    func testAltitudeLimitEnforcement() {
        let state = FlightState.mock(altitudeLimit: Altitude(agl: 120))
        let action = FlightAction.takeoff(altitude: 150)
        
        let result = FlightReducer.reduce(state: state, action: action)
        
        XCTAssertNotEqual(result.targetAltitude, 150,
            "Law 7 violated: altitude limit exceeded")
    }
}
```

#### Law 8: Authority (Operator Approval)

```swift
final class Law8AuthorityTests: XCTestCase {
    
    func testHighRiskActionsRequireApproval() {
        let state = AppState.mock()
        let action = AppAction.flight(.arm)
        
        let evaluator = FlightLawEnforcer()
        let result = evaluator.evaluate(action: action, state: state)
        
        switch result {
        case .requiresApproval(let risk):
            XCTAssertTrue(risk == .high || risk == .medium,
                "Law 8 violated: arming should require approval")
        default:
            XCTFail("Law 8 violated: arming permitted without approval")
        }
    }
    
    func testThermalLawApprovalWorkflow() {
        let state = ThermalState.mock(
            proposedCandidates: [RoofCandidate.mock()]
        )
        
        // Attempt to flag without approval
        let result = ThermalReducer.reduce(
            state: state,
            action: .flagCandidate(candidateID: "test-1")
        )
        
        // Should reject (no approval action)
        XCTAssertEqual(state.flaggedAnomalies.count, 0,
            "Law 8 violated: flagged candidate without approval")
    }
}
```

---

### 3. Jurisdiction Inheritance Tests

These tests verify that jurisdictions correctly inherit FlightLaw guarantees.

```swift
final class JurisdictionInheritanceTests: XCTestCase {
    
    /// Test: ThermalLaw inherits Law 3 (Observation)
    func testThermalLawInheritsObservation() {
        let state = AppState.mock(
            flight: FlightState.mock(gpsInfo: .noFix),
            thermal: ThermalState.mock()
        )
        
        let enforcer = ThermalLawEnforcer()
        let result = enforcer.evaluate(
            action: .thermal(.startSession),
            state: state
        )
        
        XCTAssertEqual(result, .rejected,
            "ThermalLaw did not inherit Law 3: started without GPS")
    }
    
    /// Test: ThermalLaw inherits Law 4 (Resource)
    func testThermalLawInheritsBatteryReserve() {
        let state = AppState.mock(
            flight: FlightState.mock(battery: BatteryState(percentage: 19)),
            thermal: ThermalState.mock(sessionActive: true)
        )
        
        let enforcer = ThermalLawEnforcer()
        let result = enforcer.evaluate(
            action: .thermal(.captureImage),
            state: state
        )
        
        XCTAssertEqual(result, .rejected,
            "ThermalLaw did not inherit Law 4: capture at low battery")
    }
    
    /// Test: ThermalLaw inherits Law 7 (Spatial)
    func testThermalLawInheritsGeofence() {
        let geofence = Geofence(center: Position(lat: 39.0, lon: -105.0), radius: 100)
        let outsidePosition = Position(lat: 39.1, lon: -105.1)
        
        let state = AppState.mock(
            flight: FlightState.mock(activeGeofence: geofence),
            thermal: ThermalState.mock()
        )
        
        let enforcer = ThermalLawEnforcer()
        let result = enforcer.evaluate(
            action: .thermal(.captureImage(metadata: CaptureMetadata(position: outsidePosition))),
            state: state
        )
        
        XCTAssertEqual(result, .rejected,
            "ThermalLaw did not inherit Law 7: capture outside geofence")
    }
    
    /// Test: ThermalLaw inherits Law 8 (Authority)
    func testThermalLawEnforcesApprovalWorkflow() {
        let state = ThermalState.mock(
            proposedCandidates: [RoofCandidate.mock(id: "test-1")]
        )
        
        // Attempt to flag without explicit approval
        let result = ThermalReducer.reduce(
            state: state,
            action: .flagCandidate(candidateID: "test-1")
        )
        
        XCTAssertEqual(result.flaggedAnomalies.count, 0,
            "ThermalLaw did not enforce Law 8: auto-flagging occurred")
    }
}
```

---

### 4. Session Replay Tests

Session replay is the ultimate determinism verification.

#### ThermalLaw Session Replay

```swift
final class ThermalSessionReplayTests: XCTestCase {
    
    func testSessionReplayProducesSameOutputs() {
        // Record a session
        let session = recordThermalSession()
        
        // Replay session 100 times
        for iteration in 0..<100 {
            let replayedSession = replaySession(session.auditLog)
            
            // Verify identical outputs
            XCTAssertEqual(
                replayedSession.proposedCandidates.count,
                session.proposedCandidates.count,
                "Replay iteration \(iteration): different candidate count"
            )
            
            XCTAssertEqual(
                replayedSession.proposedCandidates.map(\.id),
                session.proposedCandidates.map(\.id),
                "Replay iteration \(iteration): different candidate IDs"
            )
            
            XCTAssertEqual(
                replayedSession.flaggedAnomalies.count,
                session.flaggedAnomalies.count,
                "Replay iteration \(iteration): different flagged count"
            )
            
            // Verify hash chain integrity
            XCTAssertEqual(
                replayedSession.finalStateHash,
                session.finalStateHash,
                "Replay iteration \(iteration): state hash mismatch"
            )
        }
    }
    
    func testReplayWithDifferentMLModel() {
        let session = recordThermalSession(modelVersion: "v1.0")
        
        // Replay with different model version should be detected
        do {
            let _ = try replaySession(
                session.auditLog,
                modelVersion: "v2.0"
            )
            XCTFail("Replay should fail with different model version")
        } catch ReplayError.modelVersionMismatch {
            // Expected
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
```

---

### 5. Performance Tests

Performance tests ensure real-time requirements are met.

```swift
final class PerformanceTests: XCTestCase {
    
    func testMLInferenceLatency() {
        let model = ThermalMLModel.load()
        let frames = generateTestFrames(count: 100)
        
        measure {
            for frame in frames {
                let _ = model.predict(frame)
            }
        }
        
        // Target: <100ms per frame (p95)
        XCTAssertLessThan(averageInferenceTime, 0.100,
            "ML inference exceeds 100ms target")
    }
    
    func testCandidateProposalLatency() {
        let state = ThermalState.mock()
        let mlOutput = ThermalMLOutput.mock()
        
        measure {
            let _ = ThermalReducer.reduce(
                state: state,
                action: .inferenceCompleted(mlOutput)
            )
        }
        
        // Target: <500ms end-to-end
        XCTAssertLessThan(averageProposalTime, 0.500,
            "Candidate proposal exceeds 500ms target")
    }
    
    func testExportGenerationTime() {
        let session = ThermalSession.mock(
            capturedFrames: 200,
            flaggedAnomalies: 15
        )
        
        measure {
            let _ = session.generateDocumentationPack()
        }
        
        // Target: <30s
        XCTAssertLessThan(averageExportTime, 30.0,
            "Export generation exceeds 30s target")
    }
}
```

---

## Test Coverage Requirements

### Coverage Targets

| Component | Unit Test | Integration | Property-Based | Target |
|-----------|-----------|-------------|----------------|--------|
| **FlightLaw Reducers** | ✅ Required | ✅ Required | ✅ Required | 100% |
| **FlightLaw Enforcers** | ✅ Required | ✅ Required | ✅ Required | 100% |
| **ThermalLaw Reducers** | ✅ Required | ✅ Required | ✅ Required | 100% |
| **ThermalLaw Classifiers** | ✅ Required | - | ✅ Required | 100% |
| **SurveyLaw Reducers** | ✅ Required | ✅ Required | ✅ Required | 100% |
| **UI Components** | ✅ Required | - | - | >80% |
| **Agents** | ✅ Required | ✅ Required | - | >90% |

### Critical Path Coverage

**100% coverage required for:**
- All reducers (state transitions)
- All law enforcers (safety validation)
- All deterministic classifiers (ML post-processing)
- Session replay logic
- Audit trail generation

---

## CI/CD Integration

### GitHub Actions Workflow

```yaml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Property-Based Tests
        run: xcodebuild test -scheme FlightworksControl \
          -only-testing:PropertyBasedTests
      
      - name: Run FlightLaw Compliance Tests
        run: xcodebuild test -scheme FlightworksControl \
          -only-testing:FlightLawComplianceTests
      
      - name: Run Jurisdiction Inheritance Tests
        run: xcodebuild test -scheme FlightworksControl \
          -only-testing:JurisdictionInheritanceTests
      
      - name: Run ThermalLaw Tests
        run: xcodebuild test -scheme FlightworksControl \
          -only-testing:ThermalLawTests
      
      - name: Generate Coverage Report
        run: xcrun llvm-cov report
      
      - name: Verify 100% Coverage (Critical Paths)
        run: ./scripts/verify_critical_coverage.sh
```

---

## Related Documentation

| Document | Purpose |
|----------|---------|
| [ROADMAP.md](ROADMAP.md) | Development phases and milestones |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System design and patterns |
| [HLD-FlightworksCore.md](docs/HLD-FlightworksCore.md) | FlightLaw architecture |
| [HLD-FlightworksThermal.md](docs/HLD-FlightworksThermal.md) | ThermalLaw architecture |
| [PRD-FlightworksThermal.md](docs/PRD-FlightworksThermal.md) | ThermalLaw requirements |

---

## Known Issues

### Xcode 26.2 Beta: iOS Simulator Test Host Crash (February 2026)

**Status:** Open — Xcode toolchain bug, no code-level workaround available.

**Symptom:** All Swift Testing (`@Suite`/`@Test`) tests crash the test host on first
launch with `EXC_BAD_ACCESS (SIGSEGV)` at address `0xfffffffffffffff8`. The crash
occurs in `swift_conformsToProtocolMaybeInstantiateSuperclasses` during generic type
metadata resolution for `ReducerResult<FlightState>`. After the crash, the test host
auto-restarts and all tests pass on the second attempt. However, `xcodebuild` reports
`** TEST FAILED **` due to the initial process exit.

**Environment:**
- Xcode 26.2 (Build 17C52)
- macOS 26.3 (25D125)
- iOS 26.2 Simulator (iPad Pro 13-inch M5 and others)
- Swift Testing framework (Testing Library Version 1501)

**Scope:** Affects ALL test suites — both synchronous reducer tests and async
orchestrator tests. Not specific to any test code or `AsyncStream` usage.

**Root cause:** Swift Runtime race condition in generic type metadata initialization
on iOS Simulator. The crash stack shows `swift_getTypeByMangledName` →
`swift_conformsToProtocol` → SIGSEGV when the runtime first resolves
`ReducerResult<FlightState>` conformance metadata.

**Impact on CI:** GitHub Actions workflows using `xcodebuild test` will report failure
despite all tests being functionally correct. Consider using `-retry-tests-on-failure`
or checking the `.xcresult` bundle for actual test assertions rather than relying on
the exit code.

**TODO:** Re-test when Xcode 26.3 or a later beta is released. If resolved, remove
this section.

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | Feb 2026 | **Jurisdiction-based testing strategy** |
|  |  | • Added jurisdiction inheritance tests |
|  |  | • Added FlightLaw compliance tests |
|  |  | • Updated for ThermalLaw/SurveyLaw |
| 1.0 | Jan 2026 | Initial testing strategy (monolithic) |

---

<p align="center">
  <strong>Flightworks Suite Testing</strong><br>
  Verification for Safety-Critical Deterministic Systems
</p>
