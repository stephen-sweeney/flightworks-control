//
//  ActionTestFixtures.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Shared fixtures for ActionLayerTests files.
//  Internal visibility so all files in the test target can access them.

import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - Shared Action Fixtures

/// Fixed UUIDs for deterministic test construction.
/// Never call UUID() in production reducers; test fixtures are exempt.
let actionIDa = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
let actionIDb = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!

/// All FlightAction cases instantiated with actionIDa.
/// Provides exhaustive coverage across tests that iterate all cases.
var allFlightActions: [FlightAction] {
    let config = ConnectionConfig(host: "192.168.1.1", port: 14550)
    let telemetry = TelemetryData(
        position: nil,
        attitude: nil,
        battery: nil,
        gpsInfo: nil,
        timestamp: Date(timeIntervalSince1970: 0)
    )
    let waypoint = Waypoint(
        position: Position(latitude: 37.7749, longitude: -122.4194, altitudeMSL: 100.0),
        altitudeMSL: 100.0
    )
    let mission = Mission(
        id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
        name: "TestMission",
        waypoints: [waypoint]
    )
    let geofence = Geofence(
        center: Position(latitude: 37.7749, longitude: -122.4194, altitudeMSL: 0.0),
        radiusMetres: 500.0
    )
    return [
        .connect(config: config, correlationID: actionIDa),
        .disconnect(correlationID: actionIDa),
        .connectionStatusChanged(status: .connected, correlationID: actionIDa),
        .telemetryReceived(data: telemetry, correlationID: actionIDa),
        .sensorCalibrationUpdated(imuCalibrated: true, compassCalibrated: true, correlationID: actionIDa),
        .arm(correlationID: actionIDa),
        .disarm(correlationID: actionIDa),
        .takeoff(altitudeMetres: 30.0, correlationID: actionIDa),
        .land(correlationID: actionIDa),
        .returnToLaunch(correlationID: actionIDa),
        .setFlightMode(mode: .hovering, correlationID: actionIDa),
        .loadMission(mission: mission, correlationID: actionIDa),
        .startMission(correlationID: actionIDa),
        .pauseMission(correlationID: actionIDa),
        .clearMission(correlationID: actionIDa),
        .setGeofence(geofence: geofence, correlationID: actionIDa),
        .clearGeofence(correlationID: actionIDa),
    ]
}

/// All ThermalAction cases instantiated with actionIDa.
var allThermalActions: [ThermalAction] {
    [
        .enableDetection(correlationID: actionIDa),
        .disableDetection(correlationID: actionIDa),
    ]
}
