//
//  ReducerFlightModeTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Suites:
//    • FlightReducerFlightModeTests — setFlightMode transitions and interlocks

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - FlightReducer: setFlightMode Interlocks

@Suite("FlightReducer: setFlightMode Interlocks", .serialized)
struct FlightReducerFlightModeTests {

    @Test("setFlightMode: accepted when idle → hovering")
    func setFlightModeIdleToHovering() {
        let state = makeArmedIdleState()
        #expect(state.flightMode == .idle)
        #expect(state.armingState == .armed)
        let result = FlightReducer().reduce(state: state, action: .setFlightMode(mode: .hovering, correlationID: testID))
        print("[Diag] setFlightMode idle→hovering applied:", result.applied, "mode:", result.newState.flightMode.rawValue)
        #expect(result.applied == true)
        #expect(result.newState.flightMode == .hovering)
    }

    @Test("setFlightMode: accepted when flying → manual")
    func setFlightModeFlyingToManual() {
        let result = FlightReducer().reduce(state: makeArmedFlyingState(), action: .setFlightMode(mode: .manual, correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.flightMode == .manual)
    }

    @Test("setFlightMode: rejected during takeoff (CLAUDE.md Invariant)")
    func setFlightModeRejectedDuringTakeoff() {
        let state = makeArmedIdleState().with(flightMode: .takingOff)
        let result = FlightReducer().reduce(state: state, action: .setFlightMode(mode: .flying, correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("takeoff"))
    }

    @Test("setFlightMode: rejected during landing (CLAUDE.md Invariant)")
    func setFlightModeRejectedDuringLanding() {
        let state = makeArmedFlyingState().with(flightMode: .landing)
        let result = FlightReducer().reduce(state: state, action: .setFlightMode(mode: .flying, correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("landing"))
    }

    @Test("setFlightMode: rejected when attempting to set takingOff directly")
    func setFlightModeRejectedDirectTakingOff() {
        let result = FlightReducer().reduce(state: makeArmedIdleState(), action: .setFlightMode(mode: .takingOff, correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("takeoff"))
    }

    @Test("setFlightMode: rejected when attempting to set landing directly")
    func setFlightModeRejectedDirectLanding() {
        let result = FlightReducer().reduce(state: makeArmedFlyingState(), action: .setFlightMode(mode: .landing, correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("land"))
    }
}
