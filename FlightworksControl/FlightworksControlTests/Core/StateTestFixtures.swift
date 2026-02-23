//
//  StateTestFixtures.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Shared fixtures for StateLayerTests files.
//  Internal visibility so all files in the test target can access them.

import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - Shared State Fixtures

extension FlightState {
    /// A fully-populated FlightState for use across test suites.
    /// All optional fields are set so Codable round-trips cover every property.
    static var fixture: FlightState {
        FlightState(
            connectionStatus: .connected,
            telemetry: .fixture,
            flightMode: .flying,
            armingState: .armed,
            position: .fixture,
            attitude: .fixture,
            battery: .fixture,
            gpsInfo: .fixture,
            imuCalibrated: true,
            compassCalibrated: true,
            activeMission: .fixture,
            activeGeofence: .fixture,
            lastUpdated: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }
}

extension TelemetryData {
    static var fixture: TelemetryData {
        TelemetryData(
            position: .fixture,
            attitude: .fixture,
            battery: .fixture,
            gpsInfo: .fixture,
            timestamp: Date(timeIntervalSince1970: 1_700_000_000)
        )
    }
}

extension Position {
    static var fixture: Position { Position(latitude: 37.7749, longitude: -122.4194, altitudeMSL: 120.0) }
}

extension Attitude {
    static var fixture: Attitude { Attitude(rollDeg: 1.5, pitchDeg: -2.0, yawDeg: 270.0) }
}

extension BatteryState {
    static var fixture: BatteryState { BatteryState(percentage: 82.5, voltageV: 22.2, temperatureC: 35.1) }
}

extension GPSInfo {
    static var fixture: GPSInfo { GPSInfo(fixType: .fix3D, satelliteCount: 14) }
}

extension Mission {
    static var fixture: Mission {
        Mission(
            id: UUID(uuidString: "12345678-1234-1234-1234-123456789012")!,
            name: "Survey Alpha",
            waypoints: [
                Waypoint(position: .fixture, altitudeMSL: 120.0),
                Waypoint(position: Position(latitude: 37.776, longitude: -122.420, altitudeMSL: 120.0), altitudeMSL: 120.0)
            ]
        )
    }
}

extension Geofence {
    static var fixture: Geofence { Geofence(center: .fixture, radiusMetres: 500.0) }
}
