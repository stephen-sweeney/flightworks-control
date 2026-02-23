//
//  ReducerTelemetryTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Suites:
//    • FlightReducerTelemetryTests — telemetryReceived, sensorCalibrationUpdated

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

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

    @Test("telemetryReceived: propagates non-nil attitude to state")
    func telemetryReceivedPropagatesAttitude() {
        let attitude = Attitude(rollDeg: 5.0, pitchDeg: -3.0, yawDeg: 180.0)
        let telemetry = TelemetryData(
            position: nil,
            attitude: attitude,
            battery: nil,
            gpsInfo: nil,
            timestamp: Date(timeIntervalSince1970: 600)
        )
        let result = FlightReducer().reduce(
            state: FlightState.initial,
            action: .telemetryReceived(data: telemetry, correlationID: testID)
        )
        #expect(result.applied == true)
        #expect(result.newState.attitude == attitude)
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
