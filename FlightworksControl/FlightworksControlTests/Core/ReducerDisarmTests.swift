//
//  ReducerDisarmTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Suites:
//    • FlightReducerDisarmTests — disarm happy path + rejection interlocks

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

    @Test("disarm: rejected when returningToLaunch")
    func disarmRejectedWhenReturningToLaunch() {
        let state = makeArmedIdleState().with(flightMode: .returningToLaunch)
        let result = FlightReducer().reduce(state: state, action: .disarm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("returningToLaunch"))
    }

    @Test("disarm: rejected when in manual mode")
    func disarmRejectedWhenManual() {
        let state = makeArmedIdleState().with(flightMode: .manual)
        let result = FlightReducer().reduce(state: state, action: .disarm(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("manual"))
    }
}
