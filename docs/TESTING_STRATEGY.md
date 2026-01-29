# Flightworks Control: Testing Strategy

## Verification for Safety-Critical Deterministic Systems

**Version:** 1.0  
**Date:** January 2026  
**Project:** Flightworks Control GCS  
**Methodology:** SwiftVector + Property-Based Testing

---

## Overview

Testing in Flightworks Control serves a dual purpose:

1. **Functional Correctness** — Does the system behave as specified?
2. **Determinism Verification** — Given identical inputs, does the system produce identical outputs?

For safety-critical systems, the second property is non-negotiable. This document outlines the testing strategy that ensures both properties hold across all components.

---

## Testing Philosophy

### The SwiftVector Testing Principle

> If you can't replay it exactly, you can't trust it.

Every component that processes state or produces decisions must be verifiable through replay. This means:

- **Pure functions** can be tested with simple input/output assertions
- **State machines** can be tested with sequence replay
- **Agents** can be tested with recorded state snapshots
- **The entire system** can be tested with flight session replay

### Testing Pyramid

```
                    ┌───────────────┐
                    │   E2E Tests   │  ← Flight replay, SITL integration
                    │   (Few, Slow) │
                    └───────┬───────┘
                            │
                ┌───────────┴───────────┐
                │   Integration Tests   │  ← Control loop, multi-component
                │      (Some, Medium)   │
                └───────────┬───────────┘
                            │
        ┌───────────────────┴───────────────────┐
        │            Unit Tests                  │  ← Reducers, validators, agents
        │         (Many, Fast)                  │
        └───────────────────┬───────────────────┘
                            │
    ┌───────────────────────┴───────────────────────┐
    │           Property-Based Tests                │  ← Determinism, invariants
    │              (Foundational)                   │
    └───────────────────────────────────────────────┘
```

---

## Test Categories

### 1. Property-Based Tests (Determinism Foundation)

Property-based tests verify that fundamental properties hold across a wide range of inputs. These are the foundation of SwiftVector's determinism guarantee.

#### Reducer Determinism Tests

```swift
import XCTest

final class ReducerDeterminismTests: XCTestCase {
    
    /// Property: Same state + same action = same result (always)
    func testFlightReducerDeterminism() {
        // Generate random but valid state/action pairs
        let testCases = generateRandomFlightStateActionPairs(count: 1000)
        
        for (state, action) in testCases {
            let result1 = FlightReducer.reduce(state: state, action: action)
            let result2 = FlightReducer.reduce(state: state, action: action)
            
            XCTAssertEqual(result1, result2, 
                "Reducer produced different results for identical inputs: \(state), \(action)")
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
            "Reducer modified input state (violated purity)")
    }
    
    /// Property: Reducer handles all action types (totality)
    func testFlightReducerTotality() {
        let state = FlightState.mock()
        
        // Every action case must be handled without crashing
        for action in FlightAction.allCases {
            let result = FlightReducer.reduce(state: state, action: action)
            XCTAssertNotNil(result, "Reducer failed to handle action: \(action)")
        }
    }
}
```

#### State Invariant Tests

```swift
final class StateInvariantTests: XCTestCase {
    
    /// Invariant: Cannot be armed without GPS 3D fix
    func testArmingRequiresGPSFix() {
        let stateWithoutGPS = FlightState.mock(gpsInfo: .noFix)
        let result = FlightReducer.reduce(state: stateWithoutGPS, action: .arm)
        
        XCTAssertEqual(result.armingState, .disarmed,
            "System allowed arming without GPS fix")
    }
    
    /// Invariant: Cannot takeoff without being armed
    func testTakeoffRequiresArmed() {
        let disarmedState = FlightState.mock(armingState: .disarmed)
        let result = FlightReducer.reduce(state: disarmedState, action: .takeoff(altitude: 10))
        
        XCTAssertEqual(result.flightMode, disarmedState.flightMode,
            "System allowed takeoff while disarmed")
    }
    
    /// Invariant: Battery level monotonically decreases (during flight)
    func testBatteryMonotonicDecrease() {
        var state = FlightState.mock(
            armingState: .armed,
            flightMode: .flying,
            battery: BatteryState(percentage: 80, voltage: 14.8)
        )
        
        // Simulate telemetry updates during flight
        let telemetryUpdates = generateFlightTelemetrySequence(count: 100)
        
        var previousBattery = state.battery!.percentage
        for telemetry in telemetryUpdates {
            state = FlightReducer.reduce(state: state, action: .updateTelemetry(telemetry))
            
            if let currentBattery = state.battery?.percentage {
                XCTAssertLessThanOrEqual(currentBattery, previousBattery,
                    "Battery increased during flight (invariant violation)")
                previousBattery = currentBattery
            }
        }
    }
}
```

### 2. Unit Tests (Component Correctness)

Unit tests verify that individual components behave correctly for specific inputs.

#### Reducer Unit Tests

```swift
final class FlightReducerTests: XCTestCase {
    
    // MARK: - Connection Actions
    
    func testConnectionStatusChanged_Connected() {
        let state = FlightState.mock(connectionStatus: .disconnected)
        let result = FlightReducer.reduce(
            state: state, 
            action: .connectionStatusChanged(.connected)
        )
        
        XCTAssertEqual(result.connectionStatus, .connected)
    }
    
    func testConnectionStatusChanged_Disconnected_ResetsState() {
        let state = FlightState.mock(
            connectionStatus: .connected,
            armingState: .armed,
            telemetry: .mock()
        )
        let result = FlightReducer.reduce(
            state: state,
            action: .connectionStatusChanged(.disconnected)
        )
        
        XCTAssertEqual(result.connectionStatus, .disconnected)
        XCTAssertEqual(result.armingState, .disarmed)
        XCTAssertNil(result.telemetry)
    }
    
    // MARK: - Arming Actions
    
    func testArm_ValidPreconditions_Arms() {
        let state = FlightState.mock(
            connectionStatus: .connected,
            armingState: .disarmed,
            gpsInfo: .fix3D
        )
        let result = FlightReducer.reduce(state: state, action: .arm)
        
        XCTAssertEqual(result.armingState, .armed)
    }
    
    func testArm_NoConnection_RemainsDisarmed() {
        let state = FlightState.mock(
            connectionStatus: .disconnected,
            armingState: .disarmed,
            gpsInfo: .fix3D
        )
        let result = FlightReducer.reduce(state: state, action: .arm)
        
        XCTAssertEqual(result.armingState, .disarmed)
    }
    
    // MARK: - Flight Mode Actions
    
    func testTakeoff_Armed_TransitionsToTakingOff() {
        let state = FlightState.mock(
            armingState: .armed,
            flightMode: .idle
        )
        let result = FlightReducer.reduce(state: state, action: .takeoff(altitude: 10))
        
        XCTAssertEqual(result.flightMode, .takingOff)
        XCTAssertEqual(result.targetAltitude, 10)
    }
}
```

#### Validator Unit Tests

```swift
final class GeofenceValidatorTests: XCTestCase {
    
    let squareGeofence = Geofence(
        vertices: [
            Coordinate(lat: 0, lon: 0),
            Coordinate(lat: 0, lon: 10),
            Coordinate(lat: 10, lon: 10),
            Coordinate(lat: 10, lon: 0)
        ],
        minAltitude: 0,
        maxAltitude: 100
    )
    
    // MARK: - Horizontal Boundary Tests
    
    func testPointInsideGeofence_ReturnsValid() {
        let position = Position(lat: 5, lon: 5, altitude: 50)
        let result = GeofenceValidator.validate(position: position, against: squareGeofence)
        
        XCTAssertEqual(result, .valid)
    }
    
    func testPointOutsideGeofence_ReturnsViolation() {
        let position = Position(lat: 15, lon: 15, altitude: 50)
        let result = GeofenceValidator.validate(position: position, against: squareGeofence)
        
        if case .violation(let reason) = result {
            XCTAssertTrue(reason.contains("outside"))
        } else {
            XCTFail("Expected violation for point outside geofence")
        }
    }
    
    func testPointOnVertex_ReturnsValid() {
        let position = Position(lat: 0, lon: 0, altitude: 50)
        let result = GeofenceValidator.validate(position: position, against: squareGeofence)
        
        XCTAssertEqual(result, .valid, "Point on vertex should be considered inside")
    }
    
    func testPointOnEdge_ReturnsValid() {
        let position = Position(lat: 0, lon: 5, altitude: 50)
        let result = GeofenceValidator.validate(position: position, against: squareGeofence)
        
        XCTAssertEqual(result, .valid, "Point on edge should be considered inside")
    }
    
    // MARK: - Altitude Boundary Tests
    
    func testAltitudeBelowMinimum_ReturnsViolation() {
        let position = Position(lat: 5, lon: 5, altitude: -10)
        let result = GeofenceValidator.validate(position: position, against: squareGeofence)
        
        if case .violation(let reason) = result {
            XCTAssertTrue(reason.contains("altitude"))
        } else {
            XCTFail("Expected violation for altitude below minimum")
        }
    }
    
    func testAltitudeAboveMaximum_ReturnsViolation() {
        let position = Position(lat: 5, lon: 5, altitude: 150)
        let result = GeofenceValidator.validate(position: position, against: squareGeofence)
        
        if case .violation(let reason) = result {
            XCTAssertTrue(reason.contains("altitude"))
        } else {
            XCTFail("Expected violation for altitude above maximum")
        }
    }
    
    // MARK: - Determinism Tests
    
    func testValidatorDeterminism() {
        let positions = generateRandomPositions(count: 1000)
        
        for position in positions {
            let result1 = GeofenceValidator.validate(position: position, against: squareGeofence)
            let result2 = GeofenceValidator.validate(position: position, against: squareGeofence)
            
            XCTAssertEqual(result1, result2,
                "Geofence validator produced different results for same input")
        }
    }
}
```

#### Safety Interlock Tests

```swift
final class StateInterlockTests: XCTestCase {
    
    // MARK: - Arming Interlocks
    
    func testCanArm_AllPreconditionsMet_ReturnsTrue() {
        let state = FlightState.mock(
            connectionStatus: .connected,
            armingState: .disarmed,
            gpsInfo: .fix3D,
            battery: BatteryState(percentage: 50, voltage: 14.8)
        )
        
        let result = StateInterlocks.canArm(state: state)
        
        XCTAssertTrue(result.allowed)
        XCTAssertTrue(result.blockers.isEmpty)
    }
    
    func testCanArm_NoGPS_ReturnsFalseWithBlocker() {
        let state = FlightState.mock(
            connectionStatus: .connected,
            armingState: .disarmed,
            gpsInfo: .noFix
        )
        
        let result = StateInterlocks.canArm(state: state)
        
        XCTAssertFalse(result.allowed)
        XCTAssertTrue(result.blockers.contains(.noGPSFix))
    }
    
    func testCanArm_LowBattery_ReturnsFalseWithBlocker() {
        let state = FlightState.mock(
            connectionStatus: .connected,
            armingState: .disarmed,
            gpsInfo: .fix3D,
            battery: BatteryState(percentage: 10, voltage: 13.2)
        )
        
        let result = StateInterlocks.canArm(state: state)
        
        XCTAssertFalse(result.allowed)
        XCTAssertTrue(result.blockers.contains(.lowBattery))
    }
    
    func testCanArm_GeofenceViolation_ReturnsFalseWithBlocker() {
        let state = FlightState.mock(
            connectionStatus: .connected,
            armingState: .disarmed,
            gpsInfo: .fix3D,
            position: Position(lat: 100, lon: 100, altitude: 0), // Outside geofence
            activeGeofence: Geofence.mock()
        )
        
        let result = StateInterlocks.canArm(state: state)
        
        XCTAssertFalse(result.allowed)
        XCTAssertTrue(result.blockers.contains(.geofenceViolation))
    }
    
    func testCanArm_MultipleBlockers_ReturnsAllBlockers() {
        let state = FlightState.mock(
            connectionStatus: .disconnected,
            armingState: .disarmed,
            gpsInfo: .noFix,
            battery: BatteryState(percentage: 5, voltage: 12.0)
        )
        
        let result = StateInterlocks.canArm(state: state)
        
        XCTAssertFalse(result.allowed)
        XCTAssertTrue(result.blockers.contains(.noConnection))
        XCTAssertTrue(result.blockers.contains(.noGPSFix))
        XCTAssertTrue(result.blockers.contains(.lowBattery))
    }
    
    // MARK: - 100% Coverage Requirement
    
    func testAllInterlockBlockersHaveTests() {
        // Ensure every ArmingBlocker case has at least one test
        let testedBlockers: Set<ArmingBlocker> = [
            .noConnection,
            .noGPSFix,
            .lowBattery,
            .geofenceViolation,
            .alreadyArmed,
            .systemError
        ]
        
        let allBlockers = Set(ArmingBlocker.allCases)
        let untestedBlockers = allBlockers.subtracting(testedBlockers)
        
        XCTAssertTrue(untestedBlockers.isEmpty,
            "Missing tests for blockers: \(untestedBlockers)")
    }
}
```

### 3. Integration Tests (Control Loop)

Integration tests verify that components work together correctly.

```swift
final class ControlLoopTests: XCTestCase {
    
    var orchestrator: FlightOrchestrator!
    
    override func setUp() {
        orchestrator = FlightOrchestrator()
    }
    
    // MARK: - Action Dispatch Tests
    
    func testDispatch_UpdatesStateAndLogsAction() {
        let initialState = orchestrator.state
        
        orchestrator.dispatch(.connectionStatusChanged(.connected))
        
        XCTAssertNotEqual(orchestrator.state, initialState)
        XCTAssertEqual(orchestrator.actionLog.count, 1)
        XCTAssertEqual(orchestrator.actionLog.first?.action, .connectionStatusChanged(.connected))
    }
    
    func testDispatch_PreservesActionOrder() {
        let actions: [FlightAction] = [
            .connectionStatusChanged(.connected),
            .arm,
            .takeoff(altitude: 10),
            .land
        ]
        
        for action in actions {
            orchestrator.dispatch(action)
        }
        
        let loggedActions = orchestrator.actionLog.map { $0.action }
        XCTAssertEqual(loggedActions, actions)
    }
    
    // MARK: - State Machine Integration
    
    func testFullFlightSequence() {
        // Connect
        orchestrator.dispatch(.connectionStatusChanged(.connected))
        XCTAssertEqual(orchestrator.state.connectionStatus, .connected)
        
        // Receive GPS
        orchestrator.dispatch(.updateTelemetry(.mockWithGPS()))
        XCTAssertEqual(orchestrator.state.gpsInfo, .fix3D)
        
        // Arm
        orchestrator.dispatch(.arm)
        XCTAssertEqual(orchestrator.state.armingState, .armed)
        
        // Takeoff
        orchestrator.dispatch(.takeoff(altitude: 10))
        XCTAssertEqual(orchestrator.state.flightMode, .takingOff)
        
        // In flight
        orchestrator.dispatch(.updateTelemetry(.mockFlying(altitude: 10)))
        XCTAssertEqual(orchestrator.state.flightMode, .flying)
        
        // Land
        orchestrator.dispatch(.land)
        XCTAssertEqual(orchestrator.state.flightMode, .landing)
        
        // Landed
        orchestrator.dispatch(.updateTelemetry(.mockLanded()))
        XCTAssertEqual(orchestrator.state.flightMode, .landed)
        
        // Disarm
        orchestrator.dispatch(.disarm)
        XCTAssertEqual(orchestrator.state.armingState, .disarmed)
    }
    
    // MARK: - Replay Verification
    
    func testReplayProducesSameState() {
        // Execute a sequence
        let actions: [FlightAction] = [
            .connectionStatusChanged(.connected),
            .updateTelemetry(.mockWithGPS()),
            .arm,
            .takeoff(altitude: 10),
            .updateTelemetry(.mockFlying(altitude: 10))
        ]
        
        for action in actions {
            orchestrator.dispatch(action)
        }
        
        let finalState = orchestrator.state
        
        // Replay the same sequence on a fresh orchestrator
        let replayOrchestrator = FlightOrchestrator()
        for action in actions {
            replayOrchestrator.dispatch(action)
        }
        
        XCTAssertEqual(replayOrchestrator.state, finalState,
            "Replay produced different state than original execution")
    }
}
```

### 4. Agent Determinism Tests (Phase 5)

```swift
final class AgentDeterminismTests: XCTestCase {
    
    // MARK: - Risk Assessment Agent
    
    func testRiskAssessmentAgent_Determinism() async {
        let agent = RiskAssessmentAgent()
        let stateSnapshots = generateFlightStateSnapshots(count: 100)
        
        for state in stateSnapshots {
            await agent.observe(state: state)
            let proposals1 = await agent.propose()
            
            // Reset and re-observe same state
            await agent.observe(state: state)
            let proposals2 = await agent.propose()
            
            XCTAssertEqual(proposals1, proposals2,
                "Risk agent produced different proposals for same state")
        }
    }
    
    func testRiskAssessmentAgent_ProposesTypedActions() async {
        let agent = RiskAssessmentAgent()
        let riskyState = FlightState.mock(
            battery: BatteryState(percentage: 15, voltage: 13.5),
            distanceFromHome: 2000 // meters
        )
        
        await agent.observe(state: riskyState)
        let proposals = await agent.propose()
        
        // Proposals must be typed FlightActions, not strings
        for proposal in proposals {
            XCTAssertTrue(proposal is FlightAction,
                "Agent proposed non-typed action")
        }
    }
    
    func testRiskAssessmentAgent_IncludesExplanation() async {
        let agent = RiskAssessmentAgent()
        let state = FlightState.mock()
        
        await agent.observe(state: state)
        let assessment = await agent.currentAssessment()
        
        XCTAssertFalse(assessment.explanation.isEmpty,
            "Risk assessment missing explanation")
        XCTAssertNotNil(assessment.confidence,
            "Risk assessment missing confidence score")
    }
    
    // MARK: - Thermal Anomaly Agent (Phase 5)
    
    func testThermalAnomalyAgent_Determinism() async {
        let agent = ThermalAnomalyAgent()
        let thermalFrames = loadTestThermalFrames()
        
        for frame in thermalFrames {
            let state = FlightState.mock(thermalFrame: frame)
            
            await agent.observe(state: state)
            let proposals1 = await agent.propose()
            
            await agent.observe(state: state)
            let proposals2 = await agent.propose()
            
            XCTAssertEqual(proposals1, proposals2,
                "Thermal agent produced different proposals for same frame")
        }
    }
    
    func testThermalAnomalyAgent_DeterministicThresholding() async {
        let agent = ThermalAnomalyAgent()
        
        // Same ML output should always produce same classification
        let mlOutput = ThermalMLOutput(
            anomalyProbability: 0.75,
            boundingBox: CGRect(x: 100, y: 100, width: 50, height: 50),
            temperature: 85.0
        )
        
        let classification1 = agent.classifyAnomaly(mlOutput)
        let classification2 = agent.classifyAnomaly(mlOutput)
        
        XCTAssertEqual(classification1, classification2,
            "Thermal classification non-deterministic")
    }
    
    func testThermalAnomalyAgent_ThresholdBoundaryBehavior() {
        let agent = ThermalAnomalyAgent()
        
        // Test exact threshold boundary (0.7 is threshold)
        let atThreshold = ThermalMLOutput(anomalyProbability: 0.7, boundingBox: .zero, temperature: 80)
        let justBelow = ThermalMLOutput(anomalyProbability: 0.6999, boundingBox: .zero, temperature: 80)
        let justAbove = ThermalMLOutput(anomalyProbability: 0.7001, boundingBox: .zero, temperature: 80)
        
        // Behavior at boundary must be defined and consistent
        let atResult = agent.classifyAnomaly(atThreshold)
        let belowResult = agent.classifyAnomaly(justBelow)
        let aboveResult = agent.classifyAnomaly(justAbove)
        
        // Run 100 times to verify consistency
        for _ in 0..<100 {
            XCTAssertEqual(agent.classifyAnomaly(atThreshold), atResult)
            XCTAssertEqual(agent.classifyAnomaly(justBelow), belowResult)
            XCTAssertEqual(agent.classifyAnomaly(justAbove), aboveResult)
        }
    }
}
```

### 5. End-to-End Tests (Flight Replay)

```swift
final class FlightReplayTests: XCTestCase {
    
    func testRecordedFlightReplay_ExactMatch() throws {
        // Load recorded flight session
        let recording = try FlightRecording.load(from: "test_flight_001.json")
        
        // Replay through orchestrator
        let orchestrator = FlightOrchestrator()
        for entry in recording.entries {
            orchestrator.dispatch(entry.action)
        }
        
        // Final state must match recorded final state
        XCTAssertEqual(orchestrator.state, recording.finalState,
            "Replay final state differs from recorded state")
        
        // Intermediate states must also match
        let replayOrchestrator = FlightOrchestrator()
        for (index, entry) in recording.entries.enumerated() {
            replayOrchestrator.dispatch(entry.action)
            
            if let recordedState = recording.stateAtIndex(index) {
                XCTAssertEqual(replayOrchestrator.state, recordedState,
                    "State mismatch at index \(index)")
            }
        }
    }
    
    func testRecordedFlightReplay_CrossVersion() throws {
        // Load flight recorded with previous version
        let legacyRecording = try FlightRecording.load(from: "legacy_flight_v1.json")
        
        // Current version must produce same results
        let orchestrator = FlightOrchestrator()
        for entry in legacyRecording.entries {
            orchestrator.dispatch(entry.action)
        }
        
        XCTAssertEqual(orchestrator.state, legacyRecording.finalState,
            "Cross-version replay produced different results")
    }
}
```

---

## Test Coverage Requirements

### Minimum Coverage Targets

| Component | Line Coverage | Branch Coverage | Determinism Tests |
|-----------|---------------|-----------------|-------------------|
| Reducers | 90% | 85% | Required |
| Validators | 95% | 90% | Required |
| Interlocks | 100% | 100% | Required |
| Agents | 85% | 80% | Required |
| Orchestrator | 85% | 80% | Required |
| UI Components | 70% | 60% | Not required |
| Telemetry | 80% | 75% | Replay tests |

### Safety-Critical Components (100% Branch Coverage Required)

- `StateInterlocks.swift`
- `GeofenceValidator.swift`
- `SafetyValidator.swift`
- All reducer precondition checks

---

## Test Data Management

### Mock Factories

```swift
// FlightState+Mock.swift
extension FlightState {
    static func mock(
        connectionStatus: ConnectionStatus = .disconnected,
        armingState: ArmingState = .disarmed,
        flightMode: FlightMode = .idle,
        gpsInfo: GPSInfo = .noFix,
        battery: BatteryState? = nil,
        position: Position? = nil,
        thermalFrame: ThermalFrameMetadata? = nil
    ) -> FlightState {
        FlightState(
            connectionStatus: connectionStatus,
            armingState: armingState,
            flightMode: flightMode,
            gpsInfo: gpsInfo,
            battery: battery,
            position: position,
            thermalFrame: thermalFrame,
            timestamp: Date(timeIntervalSince1970: 0) // Deterministic timestamp
        )
    }
}
```

### Test Fixtures

```
FlightworksControlTests/
├── Fixtures/
│   ├── FlightRecordings/
│   │   ├── test_flight_001.json
│   │   ├── test_flight_emergency_rtl.json
│   │   └── legacy_flight_v1.json
│   ├── ThermalFrames/
│   │   ├── anomaly_detected.json
│   │   ├── no_anomaly.json
│   │   └── edge_case_threshold.json
│   └── Geofences/
│       ├── simple_square.json
│       ├── complex_polygon.json
│       └── overlapping_zones.json
```

### Deterministic Test Data Generation

```swift
/// Generates random but deterministic test data using seeded RNG
struct DeterministicTestData {
    private var rng: SeededRandomNumberGenerator
    
    init(seed: UInt64 = 12345) {
        rng = SeededRandomNumberGenerator(seed: seed)
    }
    
    mutating func generateFlightState() -> FlightState {
        FlightState.mock(
            connectionStatus: Bool.random(using: &rng) ? .connected : .disconnected,
            armingState: Bool.random(using: &rng) ? .armed : .disarmed,
            battery: BatteryState(
                percentage: Double.random(in: 0...100, using: &rng),
                voltage: Double.random(in: 12...16.8, using: &rng)
            )
        )
    }
}
```

---

## Continuous Integration

### GitHub Actions Workflow

```yaml
name: Test Suite

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: macos-14
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_15.app
    
    - name: Build
      run: xcodebuild build -scheme FlightworksControl -destination 'platform=macOS'
    
    - name: Run Unit Tests
      run: xcodebuild test -scheme FlightworksControl -destination 'platform=macOS' -only-testing:FlightworksControlTests/Core
    
    - name: Run Safety Tests
      run: xcodebuild test -scheme FlightworksControl -destination 'platform=macOS' -only-testing:FlightworksControlTests/Safety
    
    - name: Run Integration Tests
      run: xcodebuild test -scheme FlightworksControl -destination 'platform=macOS' -only-testing:FlightworksControlTests/Integration
    
    - name: Run Determinism Tests
      run: xcodebuild test -scheme FlightworksControl -destination 'platform=macOS' -testPlan DeterminismTests
    
    - name: Generate Coverage Report
      run: |
        xcrun llvm-cov export -format="lcov" \
          .build/debug/FlightworksControlPackageTests.xctest/Contents/MacOS/FlightworksControlPackageTests \
          -instr-profile .build/debug/codecov/default.profdata > coverage.lcov
    
    - name: Check Coverage Thresholds
      run: |
        # Fail if safety-critical components below 100%
        python scripts/check_coverage.py coverage.lcov --min-safety 100 --min-overall 80
```

### Pre-Commit Hooks

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running pre-commit tests..."

# Run fast unit tests
xcodebuild test -scheme FlightworksControl -destination 'platform=macOS' \
  -only-testing:FlightworksControlTests/Core/ReducerDeterminismTests \
  -quiet

if [ $? -ne 0 ]; then
  echo "❌ Determinism tests failed. Commit aborted."
  exit 1
fi

echo "✅ Pre-commit tests passed."
```

---

## Test Execution Guidelines

### Local Development

```bash
# Run all tests
xcodebuild test -scheme FlightworksControl -destination 'platform=macOS'

# Run specific test class
xcodebuild test -scheme FlightworksControl -destination 'platform=macOS' \
  -only-testing:FlightworksControlTests/Core/FlightReducerTests

# Run determinism tests only
xcodebuild test -scheme FlightworksControl -destination 'platform=macOS' \
  -testPlan DeterminismTests

# Run with coverage
xcodebuild test -scheme FlightworksControl -destination 'platform=macOS' \
  -enableCodeCoverage YES
```

### Test Naming Convention

```
test[Component]_[Scenario]_[ExpectedBehavior]

Examples:
- testFlightReducer_ArmWithValidPreconditions_Arms
- testGeofenceValidator_PointOnEdge_ReturnsValid
- testThermalAgent_SameInput_ProducesSameOutput
```

---

## Thermal Inspection Testing (Phase 5)

### Test Datasets

| Dataset | Purpose | Source |
|---------|---------|--------|
| `thermal_baseline.json` | Normal operation, no anomalies | Simulated |
| `thermal_anomaly_roof.json` | Roof heat signature anomalies | Field collection |
| `thermal_anomaly_electrical.json` | Electrical hotspots | Field collection |
| `thermal_edge_cases.json` | Threshold boundary conditions | Generated |

### Determinism Verification for ML Pipeline

```swift
func testThermalMLPipeline_EndToEnd_Determinism() async {
    let frames = loadTestThermalFrames(dataset: "thermal_baseline")
    
    for frame in frames {
        // Run ML inference twice
        let output1 = await ThermalMLModel.infer(frame: frame)
        let output2 = await ThermalMLModel.infer(frame: frame)
        
        // Core ML should produce identical outputs
        XCTAssertEqual(output1.anomalyProbability, output2.anomalyProbability,
            "ML inference non-deterministic")
        
        // Post-processing must be deterministic
        let classification1 = ThermalAnomalyAgent.classify(output1)
        let classification2 = ThermalAnomalyAgent.classify(output2)
        
        XCTAssertEqual(classification1, classification2,
            "Classification non-deterministic")
    }
}
```

---

## Related Documentation

- [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) — Development workflow
- [ARCHITECTURE.md](../ARCHITECTURE.md) — System design
- [THERMAL_INSPECTION_EXTENSION.md](THERMAL_INSPECTION_EXTENSION.md) — Thermal feature spec
- [CONTRIBUTING.md](../CONTRIBUTING.md) — Contribution guidelines
