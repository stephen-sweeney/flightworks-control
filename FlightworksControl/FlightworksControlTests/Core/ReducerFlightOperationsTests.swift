//
//  ReducerFlightOperationsTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Suites:
//    • FlightReducerFlightControlTests — takeoff, land, returnToLaunch

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

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

    @Test("land: rejected when takingOff")
    func landRejectedWhenTakingOff() {
        let state = makeArmedIdleState().with(flightMode: .takingOff)
        let result = FlightReducer().reduce(state: state, action: .land(correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("land: rejected when already landing")
    func landRejectedWhenAlreadyLanding() {
        let state = makeArmedIdleState().with(flightMode: .landing)
        let result = FlightReducer().reduce(state: state, action: .land(correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("land: rejected when returningToLaunch")
    func landRejectedWhenReturningToLaunch() {
        let state = makeArmedIdleState().with(flightMode: .returningToLaunch)
        let result = FlightReducer().reduce(state: state, action: .land(correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("land: rejected when in manual mode")
    func landRejectedWhenManual() {
        let state = makeArmedIdleState().with(flightMode: .manual)
        let result = FlightReducer().reduce(state: state, action: .land(correlationID: testID))
        #expect(result.applied == false)
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
