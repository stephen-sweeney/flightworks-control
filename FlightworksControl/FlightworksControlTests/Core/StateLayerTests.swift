//
//  StateLayerTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-18.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  SP0-2 verification: State Layer (FlightState, SupportingTypes, MissionState, ThermalState)
//
//  Coverage requirements (CLAUDE.md Phase 0 DoD — Commit 2):
//    ✓ Codable round-trip for every top-level type
//    ✓ Equatable: equal instances compare equal
//    ✓ Equatable: unequal instances compare unequal
//    ✓ .with() produces a NEW instance (original unchanged)
//    ✓ .with() only changes the specified field
//    ✓ stateHash() is deterministic: same state → same hash
//    ✓ stateHash() is sensitive: different state → different hash
//    ✓ Enum raw-value stability (critical for Codable persistence)
//
//  Framework: Swift Testing (import Testing, @Test, @Suite, #expect)
//  Non-XCTest: No XCTestCase, no XCTAssert*

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - Shared Fixtures

private extension FlightState {

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

private extension TelemetryData {
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

private extension Position {
    static var fixture: Position { Position(latitude: 37.7749, longitude: -122.4194, altitudeMSL: 120.0) }
}

private extension Attitude {
    static var fixture: Attitude { Attitude(rollDeg: 1.5, pitchDeg: -2.0, yawDeg: 270.0) }
}

private extension BatteryState {
    static var fixture: BatteryState { BatteryState(percentage: 82.5, voltageV: 22.2, temperatureC: 35.1) }
}

private extension GPSInfo {
    static var fixture: GPSInfo { GPSInfo(fixType: .fix3D, satelliteCount: 14) }
}

private extension Mission {
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

private extension Geofence {
    static var fixture: Geofence { Geofence(center: .fixture, radiusMetres: 500.0) }
}

// MARK: - FlightState Tests

@Suite("FlightState")
struct FlightStateTests {

    // MARK: Codable

    @Test("Codable round-trip preserves all fields")
    func codableRoundtrip() throws {
        let original = FlightState.fixture
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(FlightState.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip for initial state (all optionals nil)")
    func codableRoundtripInitial() throws {
        let original = FlightState.initial
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(FlightState.self, from: data)
        #expect(decoded == original)
    }

    // MARK: Equatable

    @Test("Equal instances compare as equal")
    func equalityForIdenticalValues() {
        let a = FlightState.fixture
        let b = FlightState.fixture
        #expect(a == b)
    }

    @Test("Instances with different flightMode are not equal")
    func inequalityForDifferentFlightMode() {
        let a = FlightState.fixture
        let b = FlightState.fixture.with(flightMode: .hovering)
        #expect(a != b)
    }

    @Test("Instances with different armingState are not equal")
    func inequalityForDifferentArmingState() {
        let a = FlightState.fixture
        let b = FlightState.fixture.with(armingState: .disarmed)
        #expect(a != b)
    }

    @Test("Instances with different connectionStatus are not equal")
    func inequalityForDifferentConnectionStatus() {
        let a = FlightState.fixture
        let b = FlightState.fixture.with(connectionStatus: .disconnected)
        #expect(a != b)
    }

    // MARK: .with() — Immutability

    @Test(".with() does not mutate the original instance")
    func withDoesNotMutateOriginal() {
        let original = FlightState.fixture
        let originalMode = original.flightMode
        _ = original.with(flightMode: .hovering)
        // Original must be unchanged (struct semantics guarantee this, but we verify explicitly)
        #expect(original.flightMode == originalMode)
    }

    @Test(".with() returns a different value when a field changes")
    func withProducesDistinctValue() {
        let original = FlightState.fixture
        let modified = original.with(flightMode: .hovering)
        #expect(original != modified)
    }

    // MARK: .with() — Field Selectivity

    @Test(".with(flightMode:) only changes flightMode")
    func withOnlyChangesFlightMode() {
        let original = FlightState.fixture
        let modified = original.with(flightMode: .hovering)
        #expect(modified.flightMode == .hovering)
        #expect(modified.connectionStatus == original.connectionStatus)
        #expect(modified.armingState == original.armingState)
        #expect(modified.position == original.position)
        #expect(modified.battery == original.battery)
        #expect(modified.gpsInfo == original.gpsInfo)
        #expect(modified.lastUpdated == original.lastUpdated)
    }

    @Test(".with(armingState:) only changes armingState")
    func withOnlyChangesArmingState() {
        let original = FlightState.fixture
        let modified = original.with(armingState: .disarmed)
        #expect(modified.armingState == .disarmed)
        #expect(modified.flightMode == original.flightMode)
        #expect(modified.connectionStatus == original.connectionStatus)
    }

    @Test(".with(connectionStatus:) only changes connectionStatus")
    func withOnlyChangesConnectionStatus() {
        let original = FlightState.fixture
        let modified = original.with(connectionStatus: .disconnected)
        #expect(modified.connectionStatus == .disconnected)
        #expect(modified.flightMode == original.flightMode)
        #expect(modified.armingState == original.armingState)
    }

    @Test(".with(telemetry: .some(nil)) sets telemetry to nil")
    func withSetsTelemetryToNil() {
        let original = FlightState.fixture
        // original.telemetry is non-nil (from fixture)
        #expect(original.telemetry != nil)
        let modified = original.with(telemetry: .some(nil))
        #expect(modified.telemetry == nil)
        // Other fields unchanged
        #expect(modified.flightMode == original.flightMode)
    }

    @Test(".with(telemetry: nil) leaves telemetry unchanged")
    func withNilLeavesOptionalFieldUnchanged() {
        let original = FlightState.fixture
        let modified = original.with(telemetry: nil) // nil means "don't change"
        #expect(modified.telemetry == original.telemetry)
    }

    @Test(".with(battery: .some(nil)) sets battery to nil")
    func withSetsBatteryToNil() {
        let original = FlightState.fixture
        #expect(original.battery != nil)
        let modified = original.with(battery: .some(nil))
        #expect(modified.battery == nil)
    }

    @Test(".with(activeGeofence: .some(nil)) clears the geofence")
    func withClearsGeofence() {
        let original = FlightState.fixture
        #expect(original.activeGeofence != nil)
        let cleared = original.with(activeGeofence: .some(nil))
        #expect(cleared.activeGeofence == nil)
    }

    @Test(".with(lastUpdated:) only changes lastUpdated")
    func withOnlyChangesLastUpdated() {
        let original = FlightState.fixture
        let newDate = Date(timeIntervalSince1970: 9_999_999)
        let modified = original.with(lastUpdated: newDate)
        #expect(modified.lastUpdated == newDate)
        #expect(modified.flightMode == original.flightMode)
        #expect(modified.armingState == original.armingState)
    }

    // MARK: Sensor Calibration Fields (PRD FR-2.2, FR-2.3)

    @Test("FlightState.initial has imuCalibrated = false (safe default)")
    func initialImuCalibratedIsFalse() {
        #expect(FlightState.initial.imuCalibrated == false)
    }

    @Test("FlightState.initial has compassCalibrated = false (safe default)")
    func initialCompassCalibratedIsFalse() {
        #expect(FlightState.initial.compassCalibrated == false)
    }

    @Test("imuCalibrated and compassCalibrated survive Codable round-trip")
    func calibrationFieldsCodable() throws {
        // Both true
        let calibrated = FlightState.fixture // fixture sets both to true
        let data = try JSONEncoder().encode(calibrated)
        let decoded = try JSONDecoder().decode(FlightState.self, from: data)
        #expect(decoded.imuCalibrated == true)
        #expect(decoded.compassCalibrated == true)
        #expect(decoded == calibrated)

        // Both false (from initial)
        let uncalibrated = FlightState.initial
        let data2 = try JSONEncoder().encode(uncalibrated)
        let decoded2 = try JSONDecoder().decode(FlightState.self, from: data2)
        #expect(decoded2.imuCalibrated == false)
        #expect(decoded2.compassCalibrated == false)
    }

    @Test(".with(imuCalibrated:) only changes imuCalibrated")
    func withOnlyChangesImuCalibrated() {
        let original = FlightState.fixture // imuCalibrated = true
        let modified = original.with(imuCalibrated: false)
        #expect(modified.imuCalibrated == false)
        #expect(modified.compassCalibrated == original.compassCalibrated)
        #expect(modified.flightMode == original.flightMode)
        #expect(modified.armingState == original.armingState)
        #expect(modified.connectionStatus == original.connectionStatus)
    }

    @Test(".with(compassCalibrated:) only changes compassCalibrated")
    func withOnlyChangesCompassCalibrated() {
        let original = FlightState.fixture // compassCalibrated = true
        let modified = original.with(compassCalibrated: false)
        #expect(modified.compassCalibrated == false)
        #expect(modified.imuCalibrated == original.imuCalibrated)
        #expect(modified.flightMode == original.flightMode)
        #expect(modified.armingState == original.armingState)
    }

    @Test("Instances with different imuCalibrated are not equal")
    func inequalityForDifferentImuCalibrated() {
        let calibrated = FlightState.fixture
        let uncalibrated = calibrated.with(imuCalibrated: false)
        #expect(calibrated != uncalibrated)
    }

    @Test("Instances with different compassCalibrated are not equal")
    func inequalityForDifferentCompassCalibrated() {
        let calibrated = FlightState.fixture
        let uncalibrated = calibrated.with(compassCalibrated: false)
        #expect(calibrated != uncalibrated)
    }

    @Test("stateHash() differs when imuCalibrated changes")
    func stateHashDiffersForImuCalibrated() {
        let a = FlightState.fixture
        let b = a.with(imuCalibrated: false)
        #expect(a.stateHash() != b.stateHash())
    }

    @Test("stateHash() differs when compassCalibrated changes")
    func stateHashDiffersForCompassCalibrated() {
        let a = FlightState.fixture
        let b = a.with(compassCalibrated: false)
        #expect(a.stateHash() != b.stateHash())
    }

    // MARK: stateHash()

    @Test("stateHash() produces the same hash for identical state")
    func stateHashIsDeterministic() {
        let state = FlightState.fixture
        let hash1 = state.stateHash()
        let hash2 = state.stateHash()
        #expect(hash1 == hash2)
    }

    @Test("stateHash() produces a 64-character hex string (SHA-256)")
    func stateHashIsExpectedLength() {
        let hash = FlightState.fixture.stateHash()
        #expect(hash.count == 64)
        #expect(hash.allSatisfy { $0.isHexDigit })
    }

    @Test("stateHash() differs when state differs")
    func stateHashDiffersForDifferentState() {
        let a = FlightState.fixture
        let b = a.with(flightMode: .hovering)
        #expect(a.stateHash() != b.stateHash())
    }

    @Test("stateHash() of initial state is deterministic")
    func initialStateHashIsDeterministic() {
        let h1 = FlightState.initial.stateHash()
        let h2 = FlightState.initial.stateHash()
        #expect(h1 == h2)
    }
}

// MARK: - SupportingTypes Tests

@Suite("SupportingTypes")
struct SupportingTypesTests {

    // MARK: Position

    @Test("Position Codable round-trip")
    func positionCodable() throws {
        let p = Position.fixture
        let data = try JSONEncoder().encode(p)
        let decoded = try JSONDecoder().decode(Position.self, from: data)
        #expect(decoded == p)
    }

    // MARK: Attitude

    @Test("Attitude Codable round-trip")
    func attitudeCodable() throws {
        let a = Attitude.fixture
        let data = try JSONEncoder().encode(a)
        let decoded = try JSONDecoder().decode(Attitude.self, from: data)
        #expect(decoded == a)
    }

    // MARK: BatteryState

    @Test("BatteryState Codable round-trip")
    func batteryStateCodable() throws {
        let b = BatteryState.fixture
        let data = try JSONEncoder().encode(b)
        let decoded = try JSONDecoder().decode(BatteryState.self, from: data)
        #expect(decoded == b)
    }

    // MARK: GPSInfo

    @Test("GPSInfo Codable round-trip")
    func gpsInfoCodable() throws {
        let g = GPSInfo.fixture
        let data = try JSONEncoder().encode(g)
        let decoded = try JSONDecoder().decode(GPSInfo.self, from: data)
        #expect(decoded == g)
    }

    // MARK: TelemetryData

    @Test("TelemetryData Codable round-trip (all fields populated)")
    func telemetryDataCodable() throws {
        let t = TelemetryData.fixture
        let data = try JSONEncoder().encode(t)
        let decoded = try JSONDecoder().decode(TelemetryData.self, from: data)
        #expect(decoded == t)
    }

    @Test("TelemetryData Codable round-trip (all optional fields nil)")
    func telemetryDataCodableAllNil() throws {
        let t = TelemetryData(
            position: nil,
            attitude: nil,
            battery: nil,
            gpsInfo: nil,
            timestamp: Date(timeIntervalSince1970: 0)
        )
        let data = try JSONEncoder().encode(t)
        let decoded = try JSONDecoder().decode(TelemetryData.self, from: data)
        #expect(decoded == t)
    }

    // MARK: Mission

    @Test("Mission Codable round-trip")
    func missionCodable() throws {
        let m = Mission.fixture
        let data = try JSONEncoder().encode(m)
        let decoded = try JSONDecoder().decode(Mission.self, from: data)
        #expect(decoded == m)
    }

    @Test("Waypoint Codable round-trip")
    func waypointCodable() throws {
        let w = Waypoint(position: .fixture, altitudeMSL: 100.0)
        let data = try JSONEncoder().encode(w)
        let decoded = try JSONDecoder().decode(Waypoint.self, from: data)
        #expect(decoded == w)
    }

    // MARK: Geofence

    @Test("Geofence Codable round-trip")
    func geofenceCodable() throws {
        let g = Geofence.fixture
        let data = try JSONEncoder().encode(g)
        let decoded = try JSONDecoder().decode(Geofence.self, from: data)
        #expect(decoded == g)
    }

    // MARK: ConnectionConfig

    @Test("ConnectionConfig Codable round-trip")
    func connectionConfigCodable() throws {
        let c = ConnectionConfig(host: "192.168.1.100", port: 14550)
        let data = try JSONEncoder().encode(c)
        let decoded = try JSONDecoder().decode(ConnectionConfig.self, from: data)
        #expect(decoded == c)
    }

    // MARK: Enum Raw Value Stability
    // Raw values are persisted in the audit trail (Codable). Changing them is a
    // breaking change to the audit log format. These tests fail if a raw value
    // is accidentally renamed or reordered.

    @Test("ConnectionStatus raw values are stable")
    func connectionStatusRawValues() {
        #expect(ConnectionStatus.disconnected.rawValue == "disconnected")
        #expect(ConnectionStatus.connecting.rawValue == "connecting")
        #expect(ConnectionStatus.connected.rawValue == "connected")
        #expect(ConnectionStatus.lost.rawValue == "lost")
    }

    @Test("ArmingState raw values are stable")
    func armingStateRawValues() {
        #expect(ArmingState.disarmed.rawValue == "disarmed")
        #expect(ArmingState.armed.rawValue == "armed")
    }

    @Test("FlightMode raw values are stable")
    func flightModeRawValues() {
        #expect(FlightMode.idle.rawValue == "idle")
        #expect(FlightMode.takingOff.rawValue == "takingOff")
        #expect(FlightMode.flying.rawValue == "flying")
        #expect(FlightMode.hovering.rawValue == "hovering")
        #expect(FlightMode.landing.rawValue == "landing")
        #expect(FlightMode.returningToLaunch.rawValue == "returningToLaunch")
        #expect(FlightMode.manual.rawValue == "manual")
    }

    @Test("GPSFixType raw values are stable")
    func gpsFixTypeRawValues() {
        #expect(GPSFixType.noFix.rawValue == "noFix")
        #expect(GPSFixType.fix2D.rawValue == "fix2D")
        #expect(GPSFixType.fix3D.rawValue == "fix3D")
    }

    // MARK: Equatable sanity

    @Test("Identical Position values are equal")
    func positionEquality() {
        let a = Position.fixture
        let b = Position.fixture
        #expect(a == b)
    }

    @Test("Different Position values are not equal")
    func positionInequality() {
        let a = Position.fixture
        let b = Position(latitude: 0, longitude: 0, altitudeMSL: 0)
        #expect(a != b)
    }

    @Test("Identical BatteryState values are equal")
    func batteryStateEquality() {
        #expect(BatteryState.fixture == BatteryState.fixture)
    }
}

// MARK: - MissionState Tests

@Suite("MissionState")
struct MissionStateTests {

    @Test("MissionState.initial is not planning")
    func initialIsNotPlanning() {
        #expect(MissionState.initial.isPlanning == false)
    }

    @Test("MissionState Codable round-trip")
    func codableRoundtrip() throws {
        let original = MissionState(isPlanning: true)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MissionState.self, from: data)
        #expect(decoded == original)
    }

    @Test("MissionState.initial Codable round-trip")
    func initialCodableRoundtrip() throws {
        let original = MissionState.initial
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(MissionState.self, from: data)
        #expect(decoded == original)
    }

    @Test("stateHash() is deterministic for MissionState")
    func stateHashIsDeterministic() {
        let state = MissionState(isPlanning: true)
        #expect(state.stateHash() == state.stateHash())
    }

    @Test("stateHash() differs for different MissionState values")
    func stateHashDiffersForDifferentValues() {
        let planning = MissionState(isPlanning: true)
        let idle = MissionState(isPlanning: false)
        #expect(planning.stateHash() != idle.stateHash())
    }

    @Test("MissionState Equatable: same values are equal")
    func equality() {
        #expect(MissionState(isPlanning: true) == MissionState(isPlanning: true))
    }

    @Test("MissionState Equatable: different values are not equal")
    func inequality() {
        #expect(MissionState(isPlanning: true) != MissionState(isPlanning: false))
    }
}

// MARK: - ThermalState Tests

@Suite("ThermalState")
struct ThermalStateTests {

    @Test("ThermalState.initial is disabled")
    func initialIsDisabled() {
        #expect(ThermalState.initial.isEnabled == false)
    }

    @Test("ThermalState Codable round-trip")
    func codableRoundtrip() throws {
        let original = ThermalState(isEnabled: true)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ThermalState.self, from: data)
        #expect(decoded == original)
    }

    @Test("ThermalState.initial Codable round-trip")
    func initialCodableRoundtrip() throws {
        let original = ThermalState.initial
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ThermalState.self, from: data)
        #expect(decoded == original)
    }

    @Test("stateHash() is deterministic for ThermalState")
    func stateHashIsDeterministic() {
        let state = ThermalState(isEnabled: true)
        #expect(state.stateHash() == state.stateHash())
    }

    @Test("stateHash() differs for different ThermalState values")
    func stateHashDiffersForDifferentValues() {
        let enabled = ThermalState(isEnabled: true)
        let disabled = ThermalState(isEnabled: false)
        #expect(enabled.stateHash() != disabled.stateHash())
    }

    @Test("ThermalState Equatable: same values are equal")
    func equality() {
        #expect(ThermalState(isEnabled: false) == ThermalState(isEnabled: false))
    }

    @Test("ThermalState Equatable: different values are not equal")
    func inequality() {
        #expect(ThermalState(isEnabled: true) != ThermalState(isEnabled: false))
    }
}
