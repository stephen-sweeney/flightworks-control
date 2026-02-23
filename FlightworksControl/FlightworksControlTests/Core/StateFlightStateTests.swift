//
//  StateFlightStateTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  FlightState tests (SP0-2 verification).
//
//  Suites:
//    • FlightStateTests — Codable, Equatable, .with(), stateHash(), calibration fields

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

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
        #expect(original.telemetry != nil)
        let modified = original.with(telemetry: .some(nil))
        #expect(modified.telemetry == nil)
        #expect(modified.flightMode == original.flightMode)
    }

    @Test(".with(telemetry: nil) leaves telemetry unchanged")
    func withNilLeavesOptionalFieldUnchanged() {
        let original = FlightState.fixture
        let modified = original.with(telemetry: nil)
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
        let calibrated = FlightState.fixture
        let data = try JSONEncoder().encode(calibrated)
        let decoded = try JSONDecoder().decode(FlightState.self, from: data)
        #expect(decoded.imuCalibrated == true)
        #expect(decoded.compassCalibrated == true)
        #expect(decoded == calibrated)

        let uncalibrated = FlightState.initial
        let data2 = try JSONEncoder().encode(uncalibrated)
        let decoded2 = try JSONDecoder().decode(FlightState.self, from: data2)
        #expect(decoded2.imuCalibrated == false)
        #expect(decoded2.compassCalibrated == false)
    }

    @Test(".with(imuCalibrated:) only changes imuCalibrated")
    func withOnlyChangesImuCalibrated() {
        let original = FlightState.fixture
        let modified = original.with(imuCalibrated: false)
        #expect(modified.imuCalibrated == false)
        #expect(modified.compassCalibrated == original.compassCalibrated)
        #expect(modified.flightMode == original.flightMode)
        #expect(modified.armingState == original.armingState)
        #expect(modified.connectionStatus == original.connectionStatus)
    }

    @Test(".with(compassCalibrated:) only changes compassCalibrated")
    func withOnlyChangesCompassCalibrated() {
        let original = FlightState.fixture
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
