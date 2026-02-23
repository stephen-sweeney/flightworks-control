//
//  ReducerTestFixtures.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-21.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Shared fixtures for all ReducerLayer test files.
//  Internal visibility so all files in the test target can access them.

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - Shared Fixture Helpers

let testID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!

/// A FlightState that satisfies ALL canArm() preconditions.
/// Used as the baseline for interlock tests that disable one precondition at a time.
func makeReadyToArmState() -> FlightState {
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
func makeArmedFlyingState() -> FlightState {
    makeReadyToArmState().with(flightMode: .flying, armingState: .armed)
}

/// A FlightState with motors armed and vehicle on ground (idle).
func makeArmedIdleState() -> FlightState {
    makeReadyToArmState().with(flightMode: .idle, armingState: .armed)
}
