//
//  ReducerMissionTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Suites:
//    • FlightReducerMissionTests — loadMission, startMission, pauseMission, clearMission

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - FlightReducer: Mission

@Suite("FlightReducer: Mission", .serialized)
struct FlightReducerMissionTests {

    @Test("loadMission: accepted when geofence active")
    func loadMissionAcceptedWithGeofence() {
        let mission = Mission(
            id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
            name: "TestMission",
            waypoints: []
        )
        let result = FlightReducer().reduce(
            state: makeReadyToArmState(),
            action: .loadMission(mission: mission, correlationID: testID)
        )
        #expect(result.applied == true)
        #expect(result.newState.activeMission?.name == "TestMission")
    }

    @Test("loadMission: rejected when no geofence (Law 7)")
    func loadMissionRejectedWithoutGeofence() {
        let state = makeReadyToArmState().with(activeGeofence: .some(nil))
        let mission = Mission(
            id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!,
            name: "BadMission",
            waypoints: []
        )
        let result = FlightReducer().reduce(state: state, action: .loadMission(mission: mission, correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("geofence"))
    }

    @Test("startMission: accepted when armed and mission loaded")
    func startMissionAccepted() {
        let mission = Mission(
            id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!,
            name: "Survey",
            waypoints: []
        )
        let state = makeArmedIdleState().with(activeMission: .some(mission))
        let result = FlightReducer().reduce(state: state, action: .startMission(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.flightMode == .flying)
    }

    @Test("startMission: rejected when disarmed")
    func startMissionRejectedWhenDisarmed() {
        let mission = Mission(
            id: UUID(uuidString: "DDDDDDDD-DDDD-DDDD-DDDD-DDDDDDDDDDDD")!,
            name: "Survey",
            waypoints: []
        )
        let state = makeReadyToArmState().with(activeMission: .some(mission))
        let result = FlightReducer().reduce(state: state, action: .startMission(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("not armed"))
    }

    @Test("startMission: rejected when no mission loaded")
    func startMissionRejectedWhenNoMission() {
        let result = FlightReducer().reduce(state: makeArmedIdleState(), action: .startMission(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("mission"))
    }

    @Test("pauseMission: accepted when flying with active mission")
    func pauseMissionAccepted() {
        let mission = Mission(
            id: UUID(uuidString: "EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE")!,
            name: "InFlight",
            waypoints: []
        )
        let state = makeArmedFlyingState().with(activeMission: .some(mission))
        let result = FlightReducer().reduce(state: state, action: .pauseMission(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.flightMode == .hovering)
    }

    @Test("pauseMission: rejected when no mission")
    func pauseMissionRejectedWhenNoMission() {
        let result = FlightReducer().reduce(state: makeArmedFlyingState(), action: .pauseMission(correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("pauseMission: rejected when not flying")
    func pauseMissionRejectedWhenNotFlying() {
        let mission = Mission(
            id: UUID(uuidString: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")!,
            name: "Idle",
            waypoints: []
        )
        let state = makeArmedIdleState().with(activeMission: .some(mission))
        let result = FlightReducer().reduce(state: state, action: .pauseMission(correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("clearMission: accepted when mission loaded")
    func clearMissionAccepted() {
        let mission = Mission(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "ClearMe",
            waypoints: []
        )
        let state = makeReadyToArmState().with(activeMission: .some(mission))
        let result = FlightReducer().reduce(state: state, action: .clearMission(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.activeMission == nil)
    }

    @Test("clearMission: rejected when no mission")
    func clearMissionRejectedWhenNone() {
        let result = FlightReducer().reduce(state: makeReadyToArmState(), action: .clearMission(correlationID: testID))
        #expect(result.applied == false)
    }
}
