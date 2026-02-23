//
//  ReducerDeterminismTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-21.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Determinism + canArm() safety interlock tests for FlightReducer.
//
//  Suites:
//    • FlightReducerDeterminismTests  — pure function determinism and immutability
//    • FlightReducerArmingInterlockTests — every canArm() precondition in isolation
//      (CLAUDE.md: safety interlocks at 100% coverage)

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - FlightReducer: Determinism + Immutability

@Suite("FlightReducer: Determinism", .serialized)
struct FlightReducerDeterminismTests {

    @Test("[FlightReducer/Determinism] Arm accepted: identical result")
    func determinism_armAccepted_producesIdenticalResult() {
        // Diagnostic: break comparisons into granular checks to pinpoint where a crash occurs
        // without changing reducer behavior. If a crash happens, the last printed line or
        // failed expectation will indicate whether the issue is in the reducer path or in
        // Equatable for FlightState or nested types (e.g., force-unwraps or transient fields).
        let state = makeReadyToArmState()
        #expect(FlightReducer.canArm(state: state) == true)
        let action = FlightAction.arm(correlationID: testID)

        let r1 = FlightReducer().reduce(state: state, action: action)
        let r2 = FlightReducer().reduce(state: state, action: action)

        // Ensure we reached this point without trapping inside the reducer
        print("[Diag] Arm accepted r1.applied:", r1.applied, "r2.applied:", r2.applied)

        // Applied flag should match deterministically
        #expect(r1.applied == r2.applied)

        // Compare critical subfields first to avoid deep Equatable traps
        #expect(r1.newState.armingState == r2.newState.armingState)
        #expect(r1.newState.flightMode == r2.newState.flightMode)
        #expect(r1.newState.connectionStatus == r2.newState.connectionStatus)

        // If subfields match, full state should also match unless Equatable includes
        // transient fields (e.g., timestamps). If this line fails/crashes, investigate
        // FlightState Equatable and reducer side-effects (like lastUpdated updates).
        #expect(r1.newState == r2.newState)

        // Rationale should be present for both results
        #expect(!r1.rationale.isEmpty)
        #expect(!r2.rationale.isEmpty)
    }

    @Test("[FlightReducer/Determinism] Arm rejected: identical result")
    func determinism_armRejected_producesIdenticalResult() {
        let state = FlightState.initial
        let action = FlightAction.arm(correlationID: testID)
        let r1 = FlightReducer().reduce(state: state, action: action)
        let r2 = FlightReducer().reduce(state: state, action: action)
        #expect(r1.newState == r2.newState)
        #expect(r1.applied == r2.applied)
        #expect(!r1.rationale.isEmpty)
        #expect(!r2.rationale.isEmpty)
        #expect(r1.rationale == r2.rationale)
    }

    @Test("Determinism: telemetryReceived produces identical result")
    func determinismTelemetry() {
        let telemetry = TelemetryData(
            position: nil, attitude: nil, battery: nil, gpsInfo: nil,
            timestamp: Date(timeIntervalSince1970: 100)
        )
        let action = FlightAction.telemetryReceived(data: telemetry, correlationID: testID)
        let r1 = FlightReducer().reduce(state: FlightState.initial, action: action)
        let r2 = FlightReducer().reduce(state: FlightState.initial, action: action)
        #expect(r1.newState == r2.newState)
        #expect(r1.applied == r2.applied)
    }

    @Test("Immutability: original state unchanged after accepted action")
    func immutabilityAccepted() {
        let original = makeReadyToArmState()
        let originalHash = original.stateHash()
        let _ = FlightReducer().reduce(state: original, action: .arm(correlationID: testID))
        #expect(original.stateHash() == originalHash)
    }

    @Test("Immutability: original state unchanged after rejected action")
    func immutabilityRejected() {
        let original = FlightState.initial
        let originalHash = original.stateHash()
        let _ = FlightReducer().reduce(state: original, action: .arm(correlationID: testID))
        #expect(original.stateHash() == originalHash)
    }

    @Test("Rejected actions return unchanged state")
    func rejectedActionReturnsUnchangedState() {
        let state = FlightState.initial
        let result = FlightReducer().reduce(state: state, action: .arm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.newState == state)
    }

    @Test("All accepted paths produce non-empty rationale")
    func acceptedRationaleNonEmpty() {
        let result = FlightReducer().reduce(state: makeReadyToArmState(), action: .arm(correlationID: testID))
        #expect(result.applied == true)
        #expect(!result.rationale.isEmpty)
    }

    @Test("All rejected paths produce non-empty rationale")
    func rejectedRationaleNonEmpty() {
        let result = FlightReducer().reduce(state: FlightState.initial, action: .arm(correlationID: testID))
        #expect(result.applied == false)
        #expect(!result.rationale.isEmpty)
    }

    @Test("accepted result has applied == true and new state differs")
    func acceptedResultCorrect() {
        let ready = makeReadyToArmState()
        let result = FlightReducer().reduce(state: ready, action: .arm(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState != ready)
        #expect(result.newState.armingState == .armed)
    }

    @Test("rejected result has applied == false and new state equals original")
    func rejectedResultCorrect() {
        let original = FlightState.initial
        let result = FlightReducer().reduce(state: original, action: .arm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.newState == original)
    }
}

// MARK: - FlightReducer: canArm() Safety Interlocks (100% coverage required)

@Suite("FlightReducer: canArm Interlocks", .serialized)
struct FlightReducerArmingInterlockTests {

    @Test("canArm: accepted when all preconditions satisfied")
    func canArmAllPreconditionsMet() {
        let ready = makeReadyToArmState()
        #expect(FlightReducer.canArm(state: ready) == true)
        let result = FlightReducer().reduce(state: ready, action: .arm(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.armingState == .armed)
    }

    @Test("canArm: rejected when not connected (Law 3 / connection precondition)")
    func canArmRejectsWhenDisconnected() {
        let state = makeReadyToArmState().with(connectionStatus: .disconnected)
        #expect(FlightReducer.canArm(state: state) == false)
        let result = FlightReducer().reduce(state: state, action: .arm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("not connected"))
    }

    @Test("canArm: rejected when connecting (not yet connected)")
    func canArmRejectsWhenConnecting() {
        let state = makeReadyToArmState().with(connectionStatus: .connecting)
        #expect(FlightReducer.canArm(state: state) == false)
        let result = FlightReducer().reduce(state: state, action: .arm(correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("canArm: rejected when connection lost")
    func canArmRejectsWhenConnectionLost() {
        let state = makeReadyToArmState().with(connectionStatus: .lost)
        #expect(FlightReducer.canArm(state: state) == false)
    }

    @Test("canArm: rejected when already armed")
    func canArmRejectsWhenAlreadyArmed() {
        let state = makeReadyToArmState().with(armingState: .armed)
        #expect(FlightReducer.canArm(state: state) == false)
        let result = FlightReducer().reduce(state: state, action: .arm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("already"))
    }

    @Test("canArm: rejected when GPS fix is noFix (PRD FR-2.1)")
    func canArmRejectsWhenGPSNoFix() {
        let state = makeReadyToArmState().with(
            gpsInfo: .some(GPSInfo(fixType: .noFix, satelliteCount: 0))
        )
        #expect(FlightReducer.canArm(state: state) == false)
        let result = FlightReducer().reduce(state: state, action: .arm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("GPS"))
    }

    @Test("canArm: rejected when GPS fix is 2D (PRD FR-2.1)")
    func canArmRejectsWhenGPS2D() {
        let state = makeReadyToArmState().with(
            gpsInfo: .some(GPSInfo(fixType: .fix2D, satelliteCount: 5))
        )
        #expect(FlightReducer.canArm(state: state) == false)
        let result = FlightReducer().reduce(state: state, action: .arm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("GPS"))
    }

    @Test("canArm: rejected when GPS info is nil (PRD FR-2.1)")
    func canArmRejectsWhenGPSNil() {
        let state = makeReadyToArmState().with(gpsInfo: .some(nil))
        #expect(FlightReducer.canArm(state: state) == false)
    }

    @Test("canArm: rejected when IMU not calibrated (PRD FR-2.2)")
    func canArmRejectsWhenIMUUncalibrated() {
        let state = makeReadyToArmState().with(imuCalibrated: false)
        #expect(FlightReducer.canArm(state: state) == false)
        let result = FlightReducer().reduce(state: state, action: .arm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("IMU"))
    }

    @Test("canArm: rejected when compass not calibrated (PRD FR-2.3)")
    func canArmRejectsWhenCompassUncalibrated() {
        let state = makeReadyToArmState().with(compassCalibrated: false)
        #expect(FlightReducer.canArm(state: state) == false)
        let result = FlightReducer().reduce(state: state, action: .arm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("compass"))
    }

    @Test("canArm: exactly 20% battery is accepted (threshold is ≥ 20)")
    func canArmAt20PercentBatteryAccepted() {
        let state = makeReadyToArmState().with(
            battery: .some(BatteryState(percentage: 20.0, voltageV: 11.8, temperatureC: 25.0))
        )
        #expect(FlightReducer.canArm(state: state) == true)
    }

    @Test("canArm: rejected when battery below 20% (CLAUDE.md Safety Interlock)")
    func canArmRejectsWhenBatteryLow() {
        let state = makeReadyToArmState().with(
            battery: .some(BatteryState(percentage: 19.9, voltageV: 11.5, temperatureC: 25.0))
        )
        #expect(FlightReducer.canArm(state: state) == false)
        let result = FlightReducer().reduce(state: state, action: .arm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("battery") || result.rationale.contains("Battery"))
    }

    @Test("canArm: rejected when battery is nil (CLAUDE.md Safety Interlock)")
    func canArmRejectsWhenBatteryNil() {
        let state = makeReadyToArmState().with(battery: .some(nil))
        #expect(FlightReducer.canArm(state: state) == false)
    }

    @Test("canArm: rejected when no active geofence (Law 7)")
    func canArmRejectsWhenNoGeofence() {
        let state = makeReadyToArmState().with(activeGeofence: .some(nil))
        #expect(FlightReducer.canArm(state: state) == false)
        let result = FlightReducer().reduce(state: state, action: .arm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("geofence"))
    }
}
