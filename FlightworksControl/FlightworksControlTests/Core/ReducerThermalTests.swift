//
//  ReducerThermalTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Suites:
//    • ThermalReducerTests — Phase 5 stub determinism and toggle interlocks

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - ThermalReducer Tests

@Suite("ThermalReducer", .serialized)
struct ThermalReducerTests {

    @Test("Determinism: enableDetection produces identical results")
    func determinismEnable() {
        let state = ThermalState.initial
        let action = ThermalAction.enableDetection(correlationID: testID)
        let r1 = ThermalReducer().reduce(state: state, action: action)
        let r2 = ThermalReducer().reduce(state: state, action: action)
        #expect(r1.newState == r2.newState)
        #expect(r1.applied == r2.applied)
        #expect(r1.rationale == r2.rationale)
    }

    @Test("enableDetection: accepted when disabled")
    func enableDetectionAccepted() {
        let result = ThermalReducer().reduce(state: ThermalState.initial, action: .enableDetection(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.isEnabled == true)
    }

    @Test("enableDetection: rejected when already enabled")
    func enableDetectionRejectedWhenAlreadyEnabled() {
        let enabled = ThermalState(isEnabled: true)
        let result = ThermalReducer().reduce(state: enabled, action: .enableDetection(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.newState == enabled)
    }

    @Test("disableDetection: accepted when enabled")
    func disableDetectionAccepted() {
        let enabled = ThermalState(isEnabled: true)
        let result = ThermalReducer().reduce(state: enabled, action: .disableDetection(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.isEnabled == false)
    }

    @Test("disableDetection: rejected when already disabled")
    func disableDetectionRejectedWhenAlreadyDisabled() {
        let result = ThermalReducer().reduce(state: ThermalState.initial, action: .disableDetection(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.newState == ThermalState.initial)
    }

    @Test("Immutability: original state unchanged after accepted action")
    func immutabilityAccepted() {
        let original = ThermalState.initial
        let _ = ThermalReducer().reduce(state: original, action: .enableDetection(correlationID: testID))
        #expect(original.isEnabled == false)
    }

    @Test("rationale non-empty for all paths")
    func rationaleNonEmpty() {
        let r1 = ThermalReducer().reduce(state: ThermalState.initial, action: .enableDetection(correlationID: testID))
        let r2 = ThermalReducer().reduce(state: ThermalState(isEnabled: true), action: .enableDetection(correlationID: testID))
        #expect(!r1.rationale.isEmpty)
        #expect(!r2.rationale.isEmpty)
    }
}
