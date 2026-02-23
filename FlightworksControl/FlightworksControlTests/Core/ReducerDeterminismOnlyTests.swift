//
//  ReducerDeterminismOnlyTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Suites:
//    • FlightReducerDeterminismTests — pure function determinism and immutability

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - FlightReducer: Determinism + Immutability

@Suite("FlightReducer: Determinism", .serialized)
struct FlightReducerDeterminismTests {

    @Test("[FlightReducer/Determinism] Arm accepted: identical result")
    func determinism_armAccepted_producesIdenticalResult() {
        let state = makeReadyToArmState()
        #expect(FlightReducer.canArm(state: state) == true)
        let action = FlightAction.arm(correlationID: testID)

        let r1 = FlightReducer().reduce(state: state, action: action)
        let r2 = FlightReducer().reduce(state: state, action: action)

        print("[Diag] Arm accepted r1.applied:", r1.applied, "r2.applied:", r2.applied)

        #expect(r1.applied == r2.applied)
        #expect(r1.newState.armingState == r2.newState.armingState)
        #expect(r1.newState.flightMode == r2.newState.flightMode)
        #expect(r1.newState.connectionStatus == r2.newState.connectionStatus)
        #expect(r1.newState == r2.newState)
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
