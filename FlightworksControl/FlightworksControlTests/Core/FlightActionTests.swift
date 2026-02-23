//
//  FlightActionTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Tests for the FlightAction type (SP0-3 Action Layer).
//
//  Suites:
//    • FlightActionTests — Codable, Equatable, correlationID, actionDescription, case coverage

import Foundation
import Testing
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - FlightAction Tests

@Suite("FlightAction")
struct FlightActionTests {

    // MARK: Codable Round-Trip

    @Test("Codable round-trip: connect")
    func codableConnect() throws {
        let original = FlightAction.connect(
            config: ConnectionConfig(host: "10.0.0.1", port: 14550),
            correlationID: actionIDa
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: disconnect")
    func codableDisconnect() throws {
        let original = FlightAction.disconnect(correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: connectionStatusChanged")
    func codableConnectionStatusChanged() throws {
        let original = FlightAction.connectionStatusChanged(status: .lost, correlationID: actionIDa)
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
        let original = FlightAction.telemetryReceived(data: telemetry, correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: sensorCalibrationUpdated")
    func codableSensorCalibrationUpdated() throws {
        let original = FlightAction.sensorCalibrationUpdated(
            imuCalibrated: true,
            compassCalibrated: false,
            correlationID: actionIDa
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: arm")
    func codableArm() throws {
        let original = FlightAction.arm(correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: disarm")
    func codableDisarm() throws {
        let original = FlightAction.disarm(correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: takeoff")
    func codableTakeoff() throws {
        let original = FlightAction.takeoff(altitudeMetres: 50.0, correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: land")
    func codableLand() throws {
        let original = FlightAction.land(correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: returnToLaunch")
    func codableReturnToLaunch() throws {
        let original = FlightAction.returnToLaunch(correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: setFlightMode")
    func codableSetFlightMode() throws {
        let original = FlightAction.setFlightMode(mode: .manual, correlationID: actionIDa)
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
        let original = FlightAction.loadMission(mission: mission, correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: startMission")
    func codableStartMission() throws {
        let original = FlightAction.startMission(correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: pauseMission")
    func codablePauseMission() throws {
        let original = FlightAction.pauseMission(correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: clearMission")
    func codableClearMission() throws {
        let original = FlightAction.clearMission(correlationID: actionIDa)
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
        let original = FlightAction.setGeofence(geofence: geofence, correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: clearGeofence")
    func codableClearGeofence() throws {
        let original = FlightAction.clearGeofence(correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightAction.self, from: data)
        #expect(decoded == original)
    }

    // MARK: Equatable

    @Test("Equatable: same case + same correlationID → equal")
    func equalitySameCaseSameID() {
        let a = FlightAction.arm(correlationID: actionIDa)
        let b = FlightAction.arm(correlationID: actionIDa)
        #expect(a == b)
    }

    @Test("Equatable: same case + different correlationID → not equal")
    func inequalitySameCaseDifferentID() {
        let a = FlightAction.arm(correlationID: actionIDa)
        let b = FlightAction.arm(correlationID: actionIDb)
        #expect(a != b)
    }

    @Test("Equatable: different cases → not equal")
    func inequalityDifferentCases() {
        let a = FlightAction.arm(correlationID: actionIDa)
        let b = FlightAction.disarm(correlationID: actionIDa)
        #expect(a != b)
    }

    @Test("Equatable: takeoff with different altitude → not equal")
    func inequalityTakeoffDifferentAltitude() {
        let a = FlightAction.takeoff(altitudeMetres: 30.0, correlationID: actionIDa)
        let b = FlightAction.takeoff(altitudeMetres: 50.0, correlationID: actionIDa)
        #expect(a != b)
    }

    // MARK: correlationID Extraction

    @Test("correlationID: extracted from every case")
    func correlationIDAllCases() {
        for action in allFlightActions {
            #expect(action.correlationID == actionIDa,
                    "Expected actionIDa for \(action.actionDescription)")
        }
    }

    @Test("correlationID: connect returns embedded UUID")
    func correlationIDConnect() {
        let action = FlightAction.connect(
            config: ConnectionConfig(host: "localhost", port: 14550),
            correlationID: actionIDb
        )
        #expect(action.correlationID == actionIDb)
    }

    @Test("correlationID: sensorCalibrationUpdated returns embedded UUID")
    func correlationIDSensorCalibration() {
        let action = FlightAction.sensorCalibrationUpdated(
            imuCalibrated: true,
            compassCalibrated: true,
            correlationID: actionIDb
        )
        #expect(action.correlationID == actionIDb)
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
            correlationID: actionIDa
        )
        #expect(action.actionDescription == "connect")
    }

    @Test("actionDescription: arm returns 'arm'")
    func actionDescriptionArm() {
        #expect(FlightAction.arm(correlationID: actionIDa).actionDescription == "arm")
    }

    @Test("actionDescription: disarm returns 'disarm'")
    func actionDescriptionDisarm() {
        #expect(FlightAction.disarm(correlationID: actionIDa).actionDescription == "disarm")
    }

    @Test("actionDescription: takeoff includes altitude")
    func actionDescriptionTakeoff() {
        let desc = FlightAction.takeoff(altitudeMetres: 25.5, correlationID: actionIDa).actionDescription
        #expect(desc.contains("25.5"))
    }

    @Test("actionDescription: connectionStatusChanged includes status rawValue")
    func actionDescriptionConnectionStatusChanged() {
        let desc = FlightAction.connectionStatusChanged(status: .connected, correlationID: actionIDa)
            .actionDescription
        #expect(desc.contains("connected"))
    }

    @Test("actionDescription: sensorCalibrationUpdated includes imu and compass flags")
    func actionDescriptionSensorCalibration() {
        let desc = FlightAction.sensorCalibrationUpdated(
            imuCalibrated: true,
            compassCalibrated: false,
            correlationID: actionIDa
        ).actionDescription
        #expect(desc.contains("imu:true"))
        #expect(desc.contains("compass:false"))
    }

    @Test("actionDescription: setFlightMode includes mode rawValue")
    func actionDescriptionSetFlightMode() {
        let desc = FlightAction.setFlightMode(mode: .hovering, correlationID: actionIDa).actionDescription
        #expect(desc.contains("hovering"))
    }

    @Test("actionDescription: setGeofence includes radius")
    func actionDescriptionSetGeofence() {
        let geofence = Geofence(
            center: Position(latitude: 0, longitude: 0, altitudeMSL: 0),
            radiusMetres: 250.0
        )
        let desc = FlightAction.setGeofence(geofence: geofence, correlationID: actionIDa).actionDescription
        #expect(desc.contains("250.0"))
    }

    @Test("actionDescription: loadMission includes mission name")
    func actionDescriptionLoadMission() {
        let mission = Mission(
            id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!,
            name: "FirePerimeter",
            waypoints: []
        )
        let desc = FlightAction.loadMission(mission: mission, correlationID: actionIDa).actionDescription
        #expect(desc.contains("FirePerimeter"))
    }

    // MARK: All 17 Cases Coverage

    @Test("Case coverage: allFlightActions contains 17 distinct cases")
    func allCasesCount() {
        #expect(allFlightActions.count == 17)
    }
}
