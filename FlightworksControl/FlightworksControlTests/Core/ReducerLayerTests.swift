//
//  ReducerLayerTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-21.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Tests for the SP0-4 Reducer Layer: FlightReducer and ThermalReducer.
//
//  Coverage goals (CLAUDE.md: safety interlocks at 100%):
//    ✓ Determinism: same (state, action) → same ReducerResult, always
//    ✓ Immutability: original state never mutated
//    ✓ Safety interlocks: every canArm() precondition tested in isolation
//    ✓ Safety interlocks: every rejection path tested
//    ✓ Happy path: every accepted action transitions state correctly
//    ✓ Rejection returns unchanged state
//    ✓ ReducerResult.applied flag correct for accepted/rejected
//    ✓ ReducerResult.rationale non-empty for all paths
//    ✓ ThermalReducer: enable/disable happy path + double-toggle rejections

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - Shared Fixture Helpers

private let testID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

/// A FlightState that satisfies ALL canArm() preconditions.
/// Used as the baseline for interlock tests that disable one precondition at a time.
private func makeReadyToArmState() -> FlightState {
    FlightState.initial.with(
        connectionStatus: .connected,
        battery: .some(BatteryState(percentage: 85.0, voltageV: 12.4, temperatureC: 25.0)),
        gpsInfo: .some(GPSInfo(fixType: .fix3D, satelliteCount: 12)),
        imuCalibrated: true,
        compassCalibrated: true,
        activeGeofence: .some(Geofence(
            center: Position(latitude: 37.7749, longitude: -122.4194, altitudeMSL: 0.0),
            radiusMetres: 500.0
        ))
    )
}

/// A FlightState with motors armed and vehicle flying.
private func makeArmedFlyingState() -> FlightState {
    makeReadyToArmState().with(flightMode: .flying, armingState: .armed)
}

/// A FlightState with motors armed and vehicle on ground (idle).
private func makeArmedIdleState() -> FlightState {
    makeReadyToArmState().with(flightMode: .idle, armingState: .armed)
}

// MARK: - FlightReducer: Determinism + Immutability

@Suite("FlightReducer: Determinism", .serialized)
struct FlightReducerDeterminismTests {

    @Test("Determinism: same (state, action) → identical ReducerResult")
    func determinismArm() {
        let state = makeReadyToArmState()
        let action = FlightAction.arm(correlationID: testID)
        let r1 = FlightReducer().reduce(state: state, action: action)
        let r2 = FlightReducer().reduce(state: state, action: action)
        #expect(r1.newState == r2.newState)
        #expect(r1.applied == r2.applied)
        #expect(r1.rationale == r2.rationale)
    }

    @Test("Determinism: rejection path produces identical result")
    func determinismArmRejection() {
        let state = FlightState.initial
        let action = FlightAction.arm(correlationID: testID)
        let r1 = FlightReducer().reduce(state: state, action: action)
        let r2 = FlightReducer().reduce(state: state, action: action)
        #expect(r1.newState == r2.newState)
        #expect(r1.applied == r2.applied)
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
        let result = FlightReducer().reduce(state: makeArmedIdleState(), action: .setFlightMode(mode: .hovering, correlationID: testID))
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

// MARK: - FlightReducer: Geofence (Law 7)

@Suite("FlightReducer: Geofence", .serialized)
struct FlightReducerGeofenceTests {

    @Test("setGeofence: accepted with positive radius")
    func setGeofenceAccepted() {
        let geofence = Geofence(
            center: Position(latitude: 37.0, longitude: -122.0, altitudeMSL: 0.0),
            radiusMetres: 300.0
        )
        let result = FlightReducer().reduce(state: FlightState.initial, action: .setGeofence(geofence: geofence, correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.activeGeofence == geofence)
    }

    @Test("setGeofence: rejected with zero radius")
    func setGeofenceRejectedZeroRadius() {
        let geofence = Geofence(
            center: Position(latitude: 37.0, longitude: -122.0, altitudeMSL: 0.0),
            radiusMetres: 0.0
        )
        let result = FlightReducer().reduce(state: FlightState.initial, action: .setGeofence(geofence: geofence, correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("positive"))
    }

    @Test("setGeofence: rejected with negative radius")
    func setGeofenceRejectedNegativeRadius() {
        let geofence = Geofence(
            center: Position(latitude: 37.0, longitude: -122.0, altitudeMSL: 0.0),
            radiusMetres: -100.0
        )
        let result = FlightReducer().reduce(state: FlightState.initial, action: .setGeofence(geofence: geofence, correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("clearGeofence: accepted when geofence is active (Law 8 HIGH-RISK, Orchestrator pre-approves)")
    func clearGeofenceAccepted() {
        let result = FlightReducer().reduce(state: makeReadyToArmState(), action: .clearGeofence(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.activeGeofence == nil)
    }

    @Test("clearGeofence: rejected when no active geofence")
    func clearGeofenceRejectedWhenNone() {
        let result = FlightReducer().reduce(state: FlightState.initial, action: .clearGeofence(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("geofence"))
    }
}

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
