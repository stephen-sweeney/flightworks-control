//
//  FlightState.swift
//  FlightworksControl
//
//  Created by Flightworks Aerial on 2026-02-18.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  FlightLaw composition: Laws 3, 4, 7, 8
//
//  FlightState is the single source of truth for all GCS-observable vehicle
//  state. It is immutable — every field is `let`. Updates are produced
//  exclusively by FlightReducer, which returns a new instance via `.with()`.
//
//  SwiftVector invariants enforced here:
//    ✓ Struct (value type), not class
//    ✓ All properties are `let`
//    ✓ Equatable, Codable, Sendable — synthesised by Swift
//    ✓ Conforms to SwiftVectorCore.State (provides stateHash() via default impl)
//    ✓ No Date(), UUID(), or .random() inside this file

import Foundation
import SwiftVectorCore

// MARK: - FlightState

/// The complete, auditable state of a single GCS–vehicle session.
///
/// **Determinism guarantee:** `stateHash()` (from `SwiftVectorCore.State`)
/// produces an identical SHA-256 hex string for identical property values,
/// enabling replay verification and tamper-evident audit trails (Law 3).
///
/// **Immutability:** `FlightReducer` produces new `FlightState` instances via
/// the `.with()` extension. The original state is never mutated.
///
/// **Safety envelope:** Law 7 (Spatial) evaluates `activeGeofence` and
/// `position` to validate movement actions. Law 4 (Resource) monitors
/// `battery.percentage` to enforce RTL and halt thresholds.
///
/// **Arming preconditions (Law 3 / PRD FR-2.x):**
/// `FlightReducer.canArm()` evaluates all of the following before accepting
/// a `.arm` action:
///   - `gpsInfo.fixType == .fix3D` (PRD FR-2.1: satellite count ≥8 implied by fix3D)
///   - `imuCalibrated == true`    (PRD FR-2.2)
///   - `compassCalibrated == true` (PRD FR-2.3)
///   - `battery.percentage >= 20`  (CLAUDE.md Safety Interlock)
///   - `activeGeofence != nil || geofenceCheckWaived` (Law 7)
struct FlightState: State {

    // MARK: Connection

    /// Current GCS–vehicle link state.
    /// Only `.arm`, `.takeoff`, `.land`, and flight-control actions are valid
    /// when this is `.connected`.
    let connectionStatus: ConnectionStatus

    // MARK: Telemetry

    /// The most recent aggregated sensor snapshot from the Edge Relay.
    /// `nil` until the first telemetry frame is received after connection.
    let telemetry: TelemetryData?

    // MARK: Flight Data

    /// Active flight control mode.
    /// Law 7: mode transitions that change the safety envelope are re-validated
    /// against `activeGeofence` before acceptance.
    let flightMode: FlightMode

    /// Motor arming state.
    /// Law 8: `.arm` is HIGH-RISK and requires Steward confirmation before
    /// FlightReducer accepts it.
    let armingState: ArmingState

    /// Latest known vehicle position (WGS-84).
    /// Derived from the most recent `telemetry` snapshot for convenience.
    let position: Position?

    /// Latest known vehicle attitude (Euler angles).
    let attitude: Attitude?

    /// Latest known battery status.
    /// Law 4: FlightReducer evaluates `battery.percentage` against the
    /// configured RTL threshold on every telemetry update.
    let battery: BatteryState?

    /// Latest known GPS receiver status.
    /// Law 8: `.fix3D` is a hard precondition for accepting an `.arm` action.
    let gpsInfo: GPSInfo?

    // MARK: Sensor Calibration (Law 3 / PRD FR-2.2, FR-2.3)

    /// Whether the Inertial Measurement Unit (IMU) has completed calibration.
    ///
    /// **PRD FR-2.2 (P0):** IMU must be calibrated to arm.
    /// `FlightReducer.canArm()` evaluates this field as a hard precondition.
    /// Set to `true` by a `FlightAction.sensorCalibrationUpdated` action
    /// carrying IMU status from the Edge Relay; never set inside a Reducer
    /// via direct sensor polling.
    let imuCalibrated: Bool

    /// Whether the compass (magnetometer) has completed calibration.
    ///
    /// **PRD FR-2.3 (P0):** Compass must be calibrated to arm.
    /// `FlightReducer.canArm()` evaluates this field as a hard precondition.
    /// Set to `true` by a `FlightAction.sensorCalibrationUpdated` action.
    let compassCalibrated: Bool

    // MARK: Mission

    /// The currently loaded and/or executing mission.
    let activeMission: Mission?

    /// The active geofence boundary.
    /// Law 7: all movement actions are validated against this boundary.
    let activeGeofence: Geofence?

    // MARK: Metadata

    /// Wall-clock timestamp of the most recent state transition.
    /// Set by the Orchestrator from its injected `Clock` — never `Date()`.
    let lastUpdated: Date
}

// MARK: - Initial State

extension FlightState {

    /// The canonical starting state for a new GCS session.
    ///
    /// `lastUpdated` is set to the Unix epoch as a deterministic sentinel.
    /// The Orchestrator replaces it on the first dispatched action using the
    /// injected `Clock`.
    ///
    /// Calibration flags default to `false` — the vehicle is assumed uncalibrated
    /// until the Edge Relay reports otherwise via a `sensorCalibrationUpdated` action.
    static let initial = FlightState(
        connectionStatus: .disconnected,
        telemetry: nil,
        flightMode: .idle,
        armingState: .disarmed,
        position: nil,
        attitude: nil,
        battery: nil,
        gpsInfo: nil,
        imuCalibrated: false,
        compassCalibrated: false,
        activeMission: nil,
        activeGeofence: nil,
        lastUpdated: Date(timeIntervalSince1970: 0) // deterministic: epoch sentinel
    )
}

// MARK: - Immutable Update (.with)

extension FlightState {

    /// Returns a new `FlightState` with specified fields replaced.
    ///
    /// All unspecified fields retain their current values. This is the only
    /// correct way to produce a modified state — never mutate fields directly.
    ///
    /// Optional-of-optional parameters (e.g. `telemetry: TelemetryData??`)
    /// allow callers to explicitly set a field to `nil`:
    /// ```swift
    /// // Set telemetry to nil
    /// state.with(telemetry: .some(nil))
    ///
    /// // Leave telemetry unchanged
    /// state.with(telemetry: nil)
    /// ```
    func with(
        connectionStatus: ConnectionStatus? = nil,
        telemetry: TelemetryData?? = nil,
        flightMode: FlightMode? = nil,
        armingState: ArmingState? = nil,
        position: Position?? = nil,
        attitude: Attitude?? = nil,
        battery: BatteryState?? = nil,
        gpsInfo: GPSInfo?? = nil,
        imuCalibrated: Bool? = nil,
        compassCalibrated: Bool? = nil,
        activeMission: Mission?? = nil,
        activeGeofence: Geofence?? = nil,
        lastUpdated: Date? = nil
    ) -> FlightState {
        FlightState(
            connectionStatus: connectionStatus ?? self.connectionStatus,
            telemetry: telemetry ?? self.telemetry,
            flightMode: flightMode ?? self.flightMode,
            armingState: armingState ?? self.armingState,
            position: position ?? self.position,
            attitude: attitude ?? self.attitude,
            battery: battery ?? self.battery,
            gpsInfo: gpsInfo ?? self.gpsInfo,
            imuCalibrated: imuCalibrated ?? self.imuCalibrated,
            compassCalibrated: compassCalibrated ?? self.compassCalibrated,
            activeMission: activeMission ?? self.activeMission,
            activeGeofence: activeGeofence ?? self.activeGeofence,
            lastUpdated: lastUpdated ?? self.lastUpdated
        )
    }
}
