//
//  FlightReducer.swift
//  FlightworksControl
//
//  Created by Flightworks Aerial on 2026-02-21.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  FlightLaw composition: Laws 3, 4, 7, 8
//
//  FlightReducer is the deterministic boundary for all GCS state transitions.
//  It is a pure function: same (FlightState, FlightAction) always produces
//  the same ReducerResult<FlightState>.
//
//  SwiftVector invariants enforced here:
//    ✓ Struct (value type), conforms to SwiftVectorCore.Reducer
//    ✓ Pure function — no side effects, no I/O
//    ✓ No Date(), UUID(), or .random() inside this file
//    ✓ Invalid actions return .rejected with unchanged state
//    ✓ Every FlightAction case is handled (exhaustive switch)
//    ✓ All precondition checks are pure static functions
//
//  Law composition:
//    Law 3 (Observation): canArm() enforces GPS fix, IMU and compass
//      calibration as arming preconditions (PRD FR-2.1, FR-2.2, FR-2.3).
//    Law 4 (Resource): canArm() enforces battery ≥ 20% threshold.
//      telemetryReceived propagates battery updates for continuous monitoring.
//    Law 7 (Spatial): canArm() requires activeGeofence or waiver.
//      setGeofence/clearGeofence manage the spatial safety envelope.
//      loadMission validates waypoints are within geofence (structural check;
//      detailed coordinate validation is deferred to SafetyValidator Phase 2).
//    Law 8 (Authority): .arm, .takeoff, .clearGeofence are HIGH-RISK.
//      The Orchestrator presents them to the Steward approval queue BEFORE
//      dispatching here. FlightReducer still enforces preconditions as a
//      defence-in-depth layer.

import Foundation
import SwiftVectorCore

// MARK: - FlightReducer

/// Pure function that validates and applies `FlightAction` to `FlightState`.
///
/// **Determinism contract:** This struct contains no stored properties and
/// all methods are pure functions. The same `(state, action)` pair always
/// produces an identical `ReducerResult`. No `Date()`, `UUID()`, or `.random()`
/// are called anywhere in this file.
///
/// **Safety interlocks (CLAUDE.md + PRD):**
/// - Cannot arm without GPS 3D fix (PRD FR-2.1)
/// - Cannot arm with IMU uncalibrated (PRD FR-2.2)
/// - Cannot arm with compass uncalibrated (PRD FR-2.3)
/// - Cannot arm with battery < 20% (CLAUDE.md Safety Interlock)
/// - Cannot arm without active geofence (Law 7)
/// - Cannot takeoff while disarmed
/// - Cannot change flight mode during takeoff or landing (CLAUDE.md Invariant)
///
/// **100% interlock coverage requirement:** Every precondition in this file
/// must have a corresponding test in `ReducerLayerTests.swift`.
struct FlightReducer: Reducer {

    typealias S = FlightState
    typealias A = FlightAction

    // MARK: - reduce(state:action:)

    /// Validates and applies a `FlightAction` to produce a new `FlightState`.
    ///
    /// Returns `.accepted` with the updated state if the action is valid,
    /// or `.rejected` with the unchanged state and a diagnostic rationale.
    ///
    /// All cases are handled exhaustively. Invalid or out-of-sequence actions
    /// produce a rejection, never a crash or partial mutation.
    func reduce(state: FlightState, action: FlightAction) -> ReducerResult<FlightState> {
        switch action {

        // MARK: Connection

        case let .connect(config, _):
            guard state.connectionStatus == .disconnected ||
                  state.connectionStatus == .lost else {
                return .rejected(state, rationale: "connect rejected: already \(state.connectionStatus.rawValue)")
            }
            return .accepted(
                state.with(connectionStatus: .connecting),
                rationale: "connecting to \(config.host):\(config.port)"
            )

        case .disconnect:
            guard state.connectionStatus != .disconnected else {
                return .rejected(state, rationale: "disconnect rejected: already disconnected")
            }
            return .accepted(
                state.with(
                    connectionStatus: .disconnected,
                    telemetry: .some(nil),
                    position: .some(nil),
                    attitude: .some(nil),
                    battery: .some(nil),
                    gpsInfo: .some(nil)
                ),
                rationale: "disconnected; flight-data fields cleared"
            )

        case let .connectionStatusChanged(status, _):
            return .accepted(
                state.with(connectionStatus: status),
                rationale: "connectionStatus → \(status.rawValue)"
            )

        // MARK: Telemetry

        case let .telemetryReceived(data, _):
            // Law 4: telemetry delivery propagates battery for threshold monitoring.
            return .accepted(
                state.with(
                    telemetry: .some(data),
                    position: .some(data.position),
                    attitude: .some(data.attitude),
                    battery: .some(data.battery),
                    gpsInfo: .some(data.gpsInfo)
                ),
                rationale: "telemetry updated"
            )

        case let .sensorCalibrationUpdated(imu, compass, _):
            return .accepted(
                state.with(
                    imuCalibrated: imu,
                    compassCalibrated: compass
                ),
                rationale: "calibration updated (imu:\(imu), compass:\(compass))"
            )

        // MARK: Arming (Law 8 — HIGH-RISK; Orchestrator pre-approves)

        case .arm:
            if let rejection = Self.armRejectionRationale(state: state) {
                return .rejected(state, rationale: rejection)
            }
            return .accepted(
                state.with(armingState: .armed),
                rationale: "armed — all preconditions satisfied"
            )

        case .disarm:
            if let rejection = Self.disarmRejectionRationale(state: state) {
                return .rejected(state, rationale: rejection)
            }
            return .accepted(
                state.with(armingState: .disarmed),
                rationale: "disarmed"
            )

        // MARK: Flight Control

        case let .takeoff(altitudeMetres, _):
            guard state.armingState == .armed else {
                return .rejected(state, rationale: "takeoff rejected: vehicle not armed")
            }
            guard state.flightMode == .idle else {
                return .rejected(state, rationale: "takeoff rejected: flightMode is \(state.flightMode.rawValue), expected idle")
            }
            guard altitudeMetres > 0 else {
                return .rejected(state, rationale: "takeoff rejected: altitudeMetres must be positive (got \(altitudeMetres))")
            }
            return .accepted(
                state.with(flightMode: .takingOff),
                rationale: "taking off to \(altitudeMetres)m"
            )

        case .land:
            guard state.flightMode == .flying || state.flightMode == .hovering else {
                return .rejected(state, rationale: "land rejected: flightMode is \(state.flightMode.rawValue), expected flying or hovering")
            }
            return .accepted(
                state.with(flightMode: .landing),
                rationale: "landing at current position"
            )

        case .returnToLaunch:
            guard state.armingState == .armed else {
                return .rejected(state, rationale: "returnToLaunch rejected: vehicle not armed")
            }
            return .accepted(
                state.with(flightMode: .returningToLaunch),
                rationale: "returning to launch"
            )

        case let .setFlightMode(mode, _):
            if let rejection = Self.flightModeRejectionRationale(mode: mode, state: state) {
                return .rejected(state, rationale: rejection)
            }
            return .accepted(
                state.with(flightMode: mode),
                rationale: "flightMode → \(mode.rawValue)"
            )

        // MARK: Mission

        case let .loadMission(mission, _):
            // Law 7: structural validation — coordinate-level geofence intersection
            // is performed by SafetyValidator (Phase 2). Here we enforce that a
            // geofence must be active before accepting a mission.
            guard state.activeGeofence != nil else {
                return .rejected(state, rationale: "loadMission rejected: no active geofence — set a geofence before loading a mission (Law 7)")
            }
            return .accepted(
                state.with(activeMission: .some(mission)),
                rationale: "mission '\(mission.name)' loaded (\(mission.waypoints.count) waypoints)"
            )

        case .startMission:
            guard state.armingState == .armed else {
                return .rejected(state, rationale: "startMission rejected: vehicle not armed")
            }
            guard state.activeMission != nil else {
                return .rejected(state, rationale: "startMission rejected: no mission loaded")
            }
            return .accepted(
                state.with(flightMode: .flying),
                rationale: "mission execution started"
            )

        case .pauseMission:
            guard state.activeMission != nil else {
                return .rejected(state, rationale: "pauseMission rejected: no active mission")
            }
            guard state.flightMode == .flying else {
                return .rejected(state, rationale: "pauseMission rejected: flightMode is \(state.flightMode.rawValue), expected flying")
            }
            return .accepted(
                state.with(flightMode: .hovering),
                rationale: "mission paused — hovering at current position"
            )

        case .clearMission:
            guard state.activeMission != nil else {
                return .rejected(state, rationale: "clearMission rejected: no mission to clear")
            }
            return .accepted(
                state.with(activeMission: .some(nil)),
                rationale: "mission cleared"
            )

        // MARK: Geofence (Law 7)

        case let .setGeofence(geofence, _):
            guard geofence.radiusMetres > 0 else {
                return .rejected(state, rationale: "setGeofence rejected: radiusMetres must be positive (got \(geofence.radiusMetres))")
            }
            return .accepted(
                state.with(activeGeofence: .some(geofence)),
                rationale: "geofence set (r:\(geofence.radiusMetres)m)"
            )

        case .clearGeofence:
            // Law 8: HIGH-RISK — Orchestrator pre-approves this action via Steward.
            // FlightReducer enforces the precondition that a geofence must exist.
            guard state.activeGeofence != nil else {
                return .rejected(state, rationale: "clearGeofence rejected: no active geofence to clear")
            }
            return .accepted(
                state.with(activeGeofence: .some(nil)),
                rationale: "geofence cleared — spatial safety envelope expanded"
            )
        }
    }
}

// MARK: - Precondition Helpers (Pure Static Functions)

extension FlightReducer {

    // MARK: canArm

    /// Returns `true` if all arming preconditions are satisfied.
    ///
    /// This is the single authoritative implementation of the arm guard. Both
    /// `reduce(state:action:)` and `ReducerLayerTests` reference this function
    /// to avoid divergence.
    ///
    /// **Preconditions (Law composition):**
    /// - `connectionStatus == .connected` (basic link requirement)
    /// - `armingState == .disarmed` (not already armed)
    /// - `gpsInfo.fixType == .fix3D` (Law 3 / PRD FR-2.1)
    /// - `imuCalibrated == true` (Law 3 / PRD FR-2.2)
    /// - `compassCalibrated == true` (Law 3 / PRD FR-2.3)
    /// - `battery.percentage >= 20` (Law 4 / CLAUDE.md Safety Interlock)
    /// - `activeGeofence != nil` (Law 7)
    static func canArm(state: FlightState) -> Bool {
        armRejectionRationale(state: state) == nil
    }

    /// Returns a rejection rationale if arming is not permitted, or `nil` if all
    /// preconditions pass. Used internally and exposed for test inspection.
    static func armRejectionRationale(state: FlightState) -> String? {
        guard state.connectionStatus == .connected else {
            return "arm rejected: not connected (status: \(state.connectionStatus.rawValue))"
        }
        guard state.armingState == .disarmed else {
            return "arm rejected: already \(state.armingState.rawValue)"
        }
        guard state.gpsInfo?.fixType == .fix3D else {
            let fix = state.gpsInfo?.fixType.rawValue ?? "nil"
            return "arm rejected: GPS fix insufficient (\(fix)); fix3D required (PRD FR-2.1)"
        }
        guard state.imuCalibrated else {
            return "arm rejected: IMU not calibrated (PRD FR-2.2)"
        }
        guard state.compassCalibrated else {
            return "arm rejected: compass not calibrated (PRD FR-2.3)"
        }
        guard let battery = state.battery, battery.percentage >= 20.0 else {
            let pct = state.battery?.percentage.description ?? "nil"
            return "arm rejected: battery \(pct)% below 20% threshold (CLAUDE.md Safety Interlock)"
        }
        guard state.activeGeofence != nil else {
            return "arm rejected: no active geofence (Law 7)"
        }
        return nil
    }

    // MARK: canDisarm

    /// Returns a rejection rationale if disarming is not permitted, or `nil` if allowed.
    static func disarmRejectionRationale(state: FlightState) -> String? {
        guard state.armingState == .armed else {
            return "disarm rejected: vehicle not armed"
        }
        guard state.flightMode == .idle || state.flightMode == .hovering else {
            return "disarm rejected: cannot disarm while \(state.flightMode.rawValue) (unsafe)"
        }
        return nil
    }

    // MARK: canSetFlightMode

    /// Returns a rejection rationale if the mode transition is not permitted, or `nil` if allowed.
    ///
    /// **CLAUDE.md Invariant:** Mode changes during takeoff or landing are rejected.
    static func flightModeRejectionRationale(mode: FlightMode, state: FlightState) -> String? {
        switch state.flightMode {
        case .takingOff:
            return "setFlightMode rejected: cannot change mode during takeoff"
        case .landing:
            return "setFlightMode rejected: cannot change mode during landing"
        default:
            break
        }
        // Attempting to enter takingOff or landing directly is also rejected
        // (those transitions are owned by .takeoff and .land actions respectively)
        if mode == .takingOff {
            return "setFlightMode rejected: use .takeoff action to enter takingOff mode"
        }
        if mode == .landing {
            return "setFlightMode rejected: use .land action to enter landing mode"
        }
        return nil
    }
}
