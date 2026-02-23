//
//  ReducerFlightControlTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-21.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Disarm, flight control, and setFlightMode interlock tests for FlightReducer.
//
//  Suites:
//    • FlightReducerDisarmTests       — disarm happy path + rejection interlocks
//    • FlightReducerFlightControlTests — takeoff, land, returnToLaunch
//    • FlightReducerFlightModeTests   — setFlightMode transitions and interlocks

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - FlightReducer: Disarm Interlocks

@Suite("FlightReducer: Disarm", .serialized)
struct FlightReducerDisarmTests {

    @Test("disarm: accepted when armed and idle")
    func disarmAcceptedWhenArmedIdle() {
        let result = FlightReducer().reduce(state: makeArmedIdleState(), action: .disarm(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.armingState == .disarmed)
    }

    @Test("disarm: accepted when armed and hovering")
    func disarmAcceptedWhenArmedHovering() {
        let state = makeArmedIdleState().with(flightMode: .hovering)
        let result = FlightReducer().reduce(state: state, action: .disarm(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.armingState == .disarmed)
    }

    @Test("disarm: rejected when not armed")
    func disarmRejectedWhenDisarmed() {
        let result = FlightReducer().reduce(state: FlightState.initial, action: .disarm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("not armed"))
    }

    @Test("disarm: rejected when flying (unsafe in-flight disarm)")
    func disarmRejectedWhenFlying() {
        let result = FlightReducer().reduce(state: makeArmedFlyingState(), action: .disarm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("flying"))
    }

    @Test("disarm: rejected when takingOff")
    func disarmRejectedWhenTakingOff() {
        let state = makeArmedIdleState().with(flightMode: .takingOff)
        let result = FlightReducer().reduce(state: state, action: .disarm(correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("disarm: rejected when landing")
    func disarmRejectedWhenLanding() {
        let state = makeArmedIdleState().with(flightMode: .landing)
        let result = FlightReducer().reduce(state: state, action: .disarm(correlationID: testID))
        #expect(result.applied == false)
    }
}

// MARK: - FlightReducer: Flight Control

@Suite("FlightReducer: Flight Control", .serialized)
struct FlightReducerFlightControlTests {

    @Test("takeoff: accepted when armed and idle with positive altitude")
    func takeoffAccepted() {
        let result = FlightReducer().reduce(state: makeArmedIdleState(), action: .takeoff(altitudeMetres: 30.0, correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.flightMode == .takingOff)
    }

    @Test("takeoff: rejected when disarmed")
    func takeoffRejectedWhenDisarmed() {
        let result = FlightReducer().reduce(state: makeReadyToArmState(), action: .takeoff(altitudeMetres: 30.0, correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("not armed"))
    }

    @Test("takeoff: rejected when not idle (already flying)")
    func takeoffRejectedWhenFlying() {
        let result = FlightReducer().reduce(state: makeArmedFlyingState(), action: .takeoff(altitudeMetres: 30.0, correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("idle"))
    }

    @Test("takeoff: rejected when altitudeMetres is zero")
    func takeoffRejectedZeroAltitude() {
        let result = FlightReducer().reduce(state: makeArmedIdleState(), action: .takeoff(altitudeMetres: 0.0, correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("positive"))
    }

    @Test("takeoff: rejected when altitudeMetres is negative")
    func takeoffRejectedNegativeAltitude() {
        let result = FlightReducer().reduce(state: makeArmedIdleState(), action: .takeoff(altitudeMetres: -5.0, correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("land: accepted when flying")
    func landAcceptedWhenFlying() {
        let result = FlightReducer().reduce(state: makeArmedFlyingState(), action: .land(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.flightMode == .landing)
    }

    @Test("land: accepted when hovering")
    func landAcceptedWhenHovering() {
        let state = makeArmedFlyingState().with(flightMode: .hovering)
        let result = FlightReducer().reduce(state: state, action: .land(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.flightMode == .landing)
    }

    @Test("land: rejected when idle (not airborne)")
    func landRejectedWhenIdle() {
        let result = FlightReducer().reduce(state: makeArmedIdleState(), action: .land(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("flying") || result.rationale.contains("hovering"))
    }

    @Test("returnToLaunch: accepted when armed")
    func returnToLaunchAccepted() {
        let result = FlightReducer().reduce(state: makeArmedFlyingState(), action: .returnToLaunch(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.flightMode == .returningToLaunch)
    }

    @Test("returnToLaunch: rejected when disarmed")
    func returnToLaunchRejectedWhenDisarmed() {
        let result = FlightReducer().reduce(state: makeReadyToArmState(), action: .returnToLaunch(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("not armed"))
    }
}

// MARK: - FlightReducer: setFlightMode Interlocks

@Suite("FlightReducer: setFlightMode Interlocks", .serialized)
struct FlightReducerFlightModeTests {

    @Test("setFlightMode: accepted when idle → hovering")
    func setFlightModeIdleToHovering() {
        let state = makeArmedIdleState()
        // Precondition: verify fixture is in the expected shape before calling the reducer
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
