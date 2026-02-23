//
//  StateSupportingTypesTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  SupportingTypes, MissionState, and ThermalState tests (SP0-2 verification).
//
//  Suites:
//    • SupportingTypesTests — Codable, Equatable, raw-value stability
//    • MissionStateTests    — Codable, stateHash, Equatable
//    • ThermalStateTests    — Codable, stateHash, Equatable

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

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
    // breaking change to the audit log format.

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
