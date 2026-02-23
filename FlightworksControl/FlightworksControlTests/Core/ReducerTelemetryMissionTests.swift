//
//  ReducerTelemetryMissionTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-21.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Connection, telemetry, and mission tests for FlightReducer.
//
//  Suites:
//    • FlightReducerConnectionTests — connect, disconnect, connectionStatusChanged
//    • FlightReducerTelemetryTests  — telemetryReceived, sensorCalibrationUpdated
//    • FlightReducerMissionTests    — loadMission, startMission, pauseMission, clearMission

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - FlightReducer: Connection

@Suite("FlightReducer: Connection", .serialized)
struct FlightReducerConnectionTests {

    @Test("connect: accepted when disconnected")
    func connectAcceptedWhenDisconnected() {
        let config = ConnectionConfig(host: "192.168.1.1", port: 14550)
        let result = FlightReducer().reduce(state: FlightState.initial, action: .connect(config: config, correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.connectionStatus == .connecting)
    }

    @Test("connect: accepted when connection was lost")
    func connectAcceptedWhenLost() {
        let state = FlightState.initial.with(connectionStatus: .lost)
        let config = ConnectionConfig(host: "10.0.0.1", port: 14550)
        let result = FlightReducer().reduce(state: state, action: .connect(config: config, correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.connectionStatus == .connecting)
    }

    @Test("connect: rejected when already connected")
    func connectRejectedWhenConnected() {
        let state = FlightState.initial.with(connectionStatus: .connected)
        let config = ConnectionConfig(host: "10.0.0.1", port: 14550)
        let result = FlightReducer().reduce(state: state, action: .connect(config: config, correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("disconnect: accepted when connected; clears flight data")
    func disconnectAcceptedClearsFlyData() {
        let state = makeReadyToArmState().with(
            telemetry: .some(TelemetryData(
                position: Position(latitude: 37.0, longitude: -122.0, altitudeMSL: 50.0),
                attitude: nil, battery: nil, gpsInfo: nil,
                timestamp: Date(timeIntervalSince1970: 0)
            ))
        )
        let result = FlightReducer().reduce(state: state, action: .disconnect(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.connectionStatus == .disconnected)
        #expect(result.newState.telemetry == nil)
        #expect(result.newState.position == nil)
        #expect(result.newState.battery == nil)
        #expect(result.newState.gpsInfo == nil)
    }

    @Test("disconnect: rejected when already disconnected")
    func disconnectRejectedWhenAlreadyDisconnected() {
        let result = FlightReducer().reduce(state: FlightState.initial, action: .disconnect(correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("connectionStatusChanged: always accepted")
    func connectionStatusChangedAlwaysAccepted() {
        for status in [ConnectionStatus.disconnected, .connecting, .connected, .lost] {
            let result = FlightReducer().reduce(
                state: FlightState.initial,
                action: .connectionStatusChanged(status: status, correlationID: testID)
            )
            #expect(result.applied == true)
            #expect(result.newState.connectionStatus == status)
        }
    }
}

// MARK: - FlightReducer: Telemetry

@Suite("FlightReducer: Telemetry", .serialized)
struct FlightReducerTelemetryTests {

    @Test("telemetryReceived: propagates all fields to state")
    func telemetryReceivedPropagatesFields() {
        let position = Position(latitude: 37.7749, longitude: -122.4194, altitudeMSL: 100.0)
        let battery = BatteryState(percentage: 75.0, voltageV: 12.0, temperatureC: 28.0)
        let gpsInfo = GPSInfo(fixType: .fix3D, satelliteCount: 10)
        let telemetry = TelemetryData(
            position: position,
            attitude: nil,
            battery: battery,
            gpsInfo: gpsInfo,
            timestamp: Date(timeIntervalSince1970: 500)
        )
        let result = FlightReducer().reduce(
            state: FlightState.initial,
            action: .telemetryReceived(data: telemetry, correlationID: testID)
        )
        #expect(result.applied == true)
        #expect(result.newState.position == position)
        #expect(result.newState.battery == battery)
        #expect(result.newState.gpsInfo == gpsInfo)
        #expect(result.newState.telemetry == telemetry)
    }

    @Test("sensorCalibrationUpdated: sets both calibration flags")
    func sensorCalibrationUpdatedSetsFlags() {
        let result = FlightReducer().reduce(
            state: FlightState.initial,
            action: .sensorCalibrationUpdated(imuCalibrated: true, compassCalibrated: true, correlationID: testID)
        )
        #expect(result.applied == true)
        #expect(result.newState.imuCalibrated == true)
        #expect(result.newState.compassCalibrated == true)
    }
}

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
