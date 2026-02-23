//
//  ReducerArmingInterlockTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Suites:
//    • FlightReducerArmingInterlockTests — every canArm() precondition in isolation
//      (CLAUDE.md: safety interlocks at 100% coverage)

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

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
