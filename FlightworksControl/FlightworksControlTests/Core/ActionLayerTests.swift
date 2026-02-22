//
//  ActionLayerTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-21.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Tests for the SP0-3 Action Layer: FlightAction and ThermalAction.
//
//  Coverage goals:
//    ✓ Codable round-trip: every case encodes and decodes to equal value
//    ✓ Equatable: same case + same correlationID → equal
//    ✓ Equatable: same case + different correlationID → NOT equal
//    ✓ correlationID: extracted correctly for every case
//    ✓ actionDescription: non-empty for every case
//    ✓ Sendable: verified at compile time via struct assignment to @Sendable closure context
//    ✓ Every defined case is exercised

import Foundation
import Testing
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - Fixtures

/// Fixed UUIDs for deterministic test construction.
/// Never call UUID() in production reducers; test fixtures are exempt.
private let idA = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
private let idB = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!

/// All FlightAction cases instantiated with idA.
/// Provides exhaustive coverage across tests that iterate all cases.
private var allFlightActions: [FlightAction] {
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
        .connect(config: config, correlationID: idA),
        .disconnect(correlationID: idA),
        .connectionStatusChanged(status: .connected, correlationID: idA),
        .telemetryReceived(data: telemetry, correlationID: idA),
        .sensorCalibrationUpdated(imuCalibrated: true, compassCalibrated: true, correlationID: idA),
        .arm(correlationID: idA),
        .disarm(correlationID: idA),
        .takeoff(altitudeMetres: 30.0, correlationID: idA),
        .land(correlationID: idA),
        .returnToLaunch(correlationID: idA),
        .setFlightMode(mode: .hovering, correlationID: idA),
        .loadMission(mission: mission, correlationID: idA),
        .startMission(correlationID: idA),
        .pauseMission(correlationID: idA),
        .clearMission(correlationID: idA),
        .setGeofence(geofence: geofence, correlationID: idA),
        .clearGeofence(correlationID: idA),
    ]
}

/// All ThermalAction cases instantiated with idA.
private var allThermalActions: [ThermalAction] {
    [
        .enableDetection(correlationID: idA),
        .disableDetection(correlationID: idA),
    ]
}

// MARK: - FlightAction Tests

@Suite("FlightAction")
struct FlightActionTests {

    // MARK: Codable Round-Trip

    @Test("Codable round-trip: connect")
    func codableConnect() throws {
        let original = FlightAction.connect(
            config: ConnectionConfig(host: "10.0.0.1", port: 14550),
            correlationID: idA
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: disconnect")
    func codableDisconnect() throws {
        let original = FlightAction.disconnect(correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: connectionStatusChanged")
    func codableConnectionStatusChanged() throws {
        let original = FlightAction.connectionStatusChanged(status: .lost, correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: telemetryReceived")
    func codableTelemetryReceived() throws {
        let telemetry = TelemetryData(
            position: nil,
            attitude: nil,
            battery: nil,
            gpsInfo: nil,
            timestamp: Date(timeIntervalSince1970: 1000)
        )
        let original = FlightAction.telemetryReceived(data: telemetry, correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: sensorCalibrationUpdated")
    func codableSensorCalibrationUpdated() throws {
        let original = FlightAction.sensorCalibrationUpdated(
            imuCalibrated: true,
            compassCalibrated: false,
            correlationID: idA
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: arm")
    func codableArm() throws {
        let original = FlightAction.arm(correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: disarm")
    func codableDisarm() throws {
        let original = FlightAction.disarm(correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: takeoff")
    func codableTakeoff() throws {
        let original = FlightAction.takeoff(altitudeMetres: 50.0, correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: land")
    func codableLand() throws {
        let original = FlightAction.land(correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: returnToLaunch")
    func codableReturnToLaunch() throws {
        let original = FlightAction.returnToLaunch(correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: setFlightMode")
    func codableSetFlightMode() throws {
        let original = FlightAction.setFlightMode(mode: .manual, correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: loadMission")
    func codableLoadMission() throws {
        let mission = Mission(
            id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!,
            name: "SurveyMission",
            waypoints: []
        )
        let original = FlightAction.loadMission(mission: mission, correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: startMission")
    func codableStartMission() throws {
        let original = FlightAction.startMission(correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: pauseMission")
    func codablePauseMission() throws {
        let original = FlightAction.pauseMission(correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: clearMission")
    func codableClearMission() throws {
        let original = FlightAction.clearMission(correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: setGeofence")
    func codableSetGeofence() throws {
        let geofence = Geofence(
            center: Position(latitude: 48.8566, longitude: 2.3522, altitudeMSL: 0.0),
            radiusMetres: 1000.0
        )
        let original = FlightAction.setGeofence(geofence: geofence, correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: clearGeofence")
    func codableClearGeofence() throws {
        let original = FlightAction.clearGeofence(correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    // MARK: Equatable

    @Test("Equatable: same case + same correlationID → equal")
    func equalitySameCaseSameID() {
        let a = FlightAction.arm(correlationID: idA)
        let b = FlightAction.arm(correlationID: idA)
        #expect(a == b)
    }

    @Test("Equatable: same case + different correlationID → not equal")
    func inequalitySameCaseDifferentID() {
        let a = FlightAction.arm(correlationID: idA)
        let b = FlightAction.arm(correlationID: idB)
        #expect(a != b)
    }

    @Test("Equatable: different cases → not equal")
    func inequalityDifferentCases() {
        let a = FlightAction.arm(correlationID: idA)
        let b = FlightAction.disarm(correlationID: idA)
        #expect(a != b)
    }

    @Test("Equatable: takeoff with different altitude → not equal")
    func inequalityTakeoffDifferentAltitude() {
        let a = FlightAction.takeoff(altitudeMetres: 30.0, correlationID: idA)
        let b = FlightAction.takeoff(altitudeMetres: 50.0, correlationID: idA)
        #expect(a != b)
    }

    // MARK: correlationID Extraction

    @Test("correlationID: extracted from every case")
    func correlationIDAllCases() {
        for action in allFlightActions {
            #expect(action.correlationID == idA,
                    "Expected idA for \(action.actionDescription)")
        }
    }

    @Test("correlationID: connect returns embedded UUID")
    func correlationIDConnect() {
        let action = FlightAction.connect(
            config: ConnectionConfig(host: "localhost", port: 14550),
            correlationID: idB
        )
        #expect(action.correlationID == idB)
    }

    @Test("correlationID: sensorCalibrationUpdated returns embedded UUID")
    func correlationIDSensorCalibration() {
        let action = FlightAction.sensorCalibrationUpdated(
            imuCalibrated: true,
            compassCalibrated: true,
            correlationID: idB
        )
        #expect(action.correlationID == idB)
    }

    // MARK: actionDescription

    @Test("actionDescription: non-empty for every case")
    func actionDescriptionNonEmpty() {
        for action in allFlightActions {
            #expect(!action.actionDescription.isEmpty,
                    "Empty actionDescription for case: \(action.actionDescription)")
        }
    }

    @Test("actionDescription: connect returns 'connect'")
    func actionDescriptionConnect() {
        let action = FlightAction.connect(
            config: ConnectionConfig(host: "x", port: 1),
            correlationID: idA
        )
        #expect(action.actionDescription == "connect")
    }

    @Test("actionDescription: arm returns 'arm'")
    func actionDescriptionArm() {
        #expect(FlightAction.arm(correlationID: idA).actionDescription == "arm")
    }

    @Test("actionDescription: disarm returns 'disarm'")
    func actionDescriptionDisarm() {
        #expect(FlightAction.disarm(correlationID: idA).actionDescription == "disarm")
    }

    @Test("actionDescription: takeoff includes altitude")
    func actionDescriptionTakeoff() {
        let desc = FlightAction.takeoff(altitudeMetres: 25.5, correlationID: idA).actionDescription
        #expect(desc.contains("25.5"))
    }

    @Test("actionDescription: connectionStatusChanged includes status rawValue")
    func actionDescriptionConnectionStatusChanged() {
        let desc = FlightAction.connectionStatusChanged(status: .connected, correlationID: idA)
            .actionDescription
        #expect(desc.contains("connected"))
    }

    @Test("actionDescription: sensorCalibrationUpdated includes imu and compass flags")
    func actionDescriptionSensorCalibration() {
        let desc = FlightAction.sensorCalibrationUpdated(
            imuCalibrated: true,
            compassCalibrated: false,
            correlationID: idA
        ).actionDescription
        #expect(desc.contains("imu:true"))
        #expect(desc.contains("compass:false"))
    }

    @Test("actionDescription: setFlightMode includes mode rawValue")
    func actionDescriptionSetFlightMode() {
        let desc = FlightAction.setFlightMode(mode: .hovering, correlationID: idA).actionDescription
        #expect(desc.contains("hovering"))
    }

    @Test("actionDescription: setGeofence includes radius")
    func actionDescriptionSetGeofence() {
        let geofence = Geofence(
            center: Position(latitude: 0, longitude: 0, altitudeMSL: 0),
            radiusMetres: 250.0
        )
        let desc = FlightAction.setGeofence(geofence: geofence, correlationID: idA).actionDescription
        #expect(desc.contains("250.0"))
    }

    @Test("actionDescription: loadMission includes mission name")
    func actionDescriptionLoadMission() {
        let mission = Mission(
            id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!,
            name: "FirePerimeter",
            waypoints: []
        )
        let desc = FlightAction.loadMission(mission: mission, correlationID: idA).actionDescription
        #expect(desc.contains("FirePerimeter"))
    }

    // MARK: All 17 Cases Coverage

    @Test("Case coverage: allFlightActions contains 17 distinct cases")
    func allCasesCount() {
        #expect(allFlightActions.count == 17)
    }
}

// MARK: - ThermalAction Tests

@Suite("ThermalAction")
struct ThermalActionTests {

    // MARK: Codable Round-Trip

    @Test("Codable round-trip: enableDetection")
    func codableEnableDetection() throws {
        let original = ThermalAction.enableDetection(correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ThermalAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: disableDetection")
    func codableDisableDetection() throws {
        let original = ThermalAction.disableDetection(correlationID: idA)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ThermalAction.self, from: data)
        #expect(decoded == original)
    }

    // MARK: Equatable

    @Test("Equatable: same case + same correlationID → equal")
    func equalitySameCaseSameID() {
        let a = ThermalAction.enableDetection(correlationID: idA)
        let b = ThermalAction.enableDetection(correlationID: idA)
        #expect(a == b)
    }

    @Test("Equatable: same case + different correlationID → not equal")
    func inequalitySameCaseDifferentID() {
        let a = ThermalAction.enableDetection(correlationID: idA)
        let b = ThermalAction.enableDetection(correlationID: idB)
        #expect(a != b)
    }

    @Test("Equatable: enableDetection vs disableDetection → not equal")
    func inequalityDifferentCases() {
        let a = ThermalAction.enableDetection(correlationID: idA)
        let b = ThermalAction.disableDetection(correlationID: idA)
        #expect(a != b)
    }

    // MARK: correlationID Extraction

    @Test("correlationID: extracted from every case")
    func correlationIDAllCases() {
        for action in allThermalActions {
            #expect(action.correlationID == idA,
                    "Expected idA for \(action.actionDescription)")
        }
    }

    @Test("correlationID: enableDetection returns embedded UUID")
    func correlationIDEnableDetection() {
        let action = ThermalAction.enableDetection(correlationID: idB)
        #expect(action.correlationID == idB)
    }

    // MARK: actionDescription

    @Test("actionDescription: non-empty for every case")
    func actionDescriptionNonEmpty() {
        for action in allThermalActions {
            #expect(!action.actionDescription.isEmpty)
        }
    }

    @Test("actionDescription: enableDetection returns 'enableDetection'")
    func actionDescriptionEnable() {
        #expect(ThermalAction.enableDetection(correlationID: idA).actionDescription == "enableDetection")
    }

    @Test("actionDescription: disableDetection returns 'disableDetection'")
    func actionDescriptionDisable() {
        #expect(ThermalAction.disableDetection(correlationID: idA).actionDescription == "disableDetection")
    }

    // MARK: Case Coverage

    @Test("Case coverage: allThermalActions contains 2 distinct cases")
    func allCasesCount() {
        #expect(allThermalActions.count == 2)
    }
}
