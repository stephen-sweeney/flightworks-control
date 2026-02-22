//
//  FlightAction.swift
//  FlightworksControl
//
//  Created by Flightworks Aerial on 2026-02-21.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  FlightLaw composition: Laws 3, 4, 7, 8
//
//  FlightAction is the complete typed vocabulary of state transitions for a
//  single GCS–vehicle session. Every case carries a `correlationID: UUID`
//  embedded as an associated value — this satisfies SwiftVectorCore.Action's
//  `correlationID` requirement without a stored property outside the enum.
//
//  SwiftVector invariants enforced here:
//    ✓ Enum (value type) with typed associated values
//    ✓ Equatable, Codable, Sendable — synthesised by Swift
//    ✓ Conforms to SwiftVectorCore.Action
//    ✓ correlationID: UUID embedded per-case; NEVER constructed via UUID()
//      here — the Orchestrator provides it from its injected UUIDGenerator
//    ✓ No Date(), UUID(), or .random() inside this file
//
//  Source attribution (ui / telemetry / agent / system / relay) is recorded
//  at the Orchestrator/AuditEvent level via agentID, NOT as an associated
//  value on FlightAction cases. This prevents duplication with the audit
//  infrastructure already provided by SwiftVectorCore.

import Foundation
import SwiftVectorCore

// MARK: - FlightAction

/// The typed vocabulary of all state changes for a FlightworksControl session.
///
/// **Determinism contract:** Every case stores a `correlationID: UUID` injected
/// by the Orchestrator via its `UUIDGenerator` dependency. No case constructs
/// a `UUID()` directly — doing so would break replay determinism (Law 3).
///
/// **Law composition:**
/// - Law 3 (Observation): Every dispatched action is logged with pre/post
///   state hashes via `AuditEvent`. `correlationID` links distributed traces.
/// - Law 4 (Resource): `telemetryReceived` and `sensorCalibrationUpdated`
///   are the primary inputs for battery/thermal circuit-breaker evaluation.
/// - Law 7 (Spatial): `setGeofence`, `clearGeofence`, `takeoff`, and
///   `setFlightMode` trigger boundary re-validation in `FlightReducer`.
/// - Law 8 (Authority): `arm` and `takeoff` are HIGH-RISK actions. The
///   Orchestrator presents them to the Steward approval queue before dispatch.
///
/// **Deferred to Phase 1:**
/// - `case mission(MissionAction)` — requires MAVSDK integration
/// - `case relay(RelayAction)` — requires Edge Relay (Phase 1)
enum FlightAction: Action {

    // MARK: Connection

    /// Initiate a connection to the vehicle via the Edge Relay.
    /// The Reducer transitions `connectionStatus` to `.connecting`.
    case connect(config: ConnectionConfig, correlationID: UUID)

    /// Explicitly close the GCS–vehicle link.
    /// The Reducer transitions `connectionStatus` to `.disconnected` and
    /// clears all flight-data fields (position, attitude, battery, gpsInfo).
    case disconnect(correlationID: UUID)

    /// Report a change in link quality detected by the Edge Relay.
    ///
    /// This action is dispatched by the Telemetry subsystem (Phase 1+), not
    /// by operator input. Source attribution is `agent` or `telemetry`.
    case connectionStatusChanged(status: ConnectionStatus, correlationID: UUID)

    // MARK: Telemetry (Law 3 + Law 4 inputs)

    /// Deliver a sensor snapshot from the Edge Relay.
    ///
    /// **SVC candidate: Law 3 (Observation)** — telemetry delivery is the
    /// primary input to the audit backbone's observation stream.
    ///
    /// The Reducer propagates fields into `FlightState` (position, attitude,
    /// battery, gpsInfo) and Law 4 evaluates battery thresholds.
    case telemetryReceived(data: TelemetryData, correlationID: UUID)

    /// Report updated IMU and compass calibration status from the vehicle.
    ///
    /// Sets `FlightState.imuCalibrated` and `FlightState.compassCalibrated`.
    /// Dispatched by the Telemetry subsystem when the vehicle's preflight
    /// calibration state changes. Required arming preconditions per PRD FR-2.2
    /// and FR-2.3.
    case sensorCalibrationUpdated(
        imuCalibrated: Bool,
        compassCalibrated: Bool,
        correlationID: UUID
    )

    // MARK: Arming (Law 8 — HIGH-RISK)

    /// Arm the vehicle motors.
    ///
    /// **Law 8:** HIGH-RISK. The Orchestrator presents this to the Steward
    /// approval queue before dispatching to `FlightReducer`.
    ///
    /// **Preconditions evaluated by `FlightReducer.canArm()`:**
    /// - `gpsInfo.fixType == .fix3D`    (PRD FR-2.1)
    /// - `imuCalibrated == true`         (PRD FR-2.2)
    /// - `compassCalibrated == true`     (PRD FR-2.3)
    /// - `battery.percentage >= 20`      (CLAUDE.md Safety Interlock)
    /// - `connectionStatus == .connected`
    ///
    /// If any precondition fails, `FlightReducer` returns `.rejected(...)` and
    /// state is unchanged.
    case arm(correlationID: UUID)

    /// Disarm the vehicle motors.
    ///
    /// Only valid when `flightMode == .idle` (vehicle on ground). Disarming
    /// in flight is rejected by `FlightReducer` as an unsafe state transition.
    case disarm(correlationID: UUID)

    // MARK: Flight Control

    /// Command the vehicle to ascend to the specified altitude above home.
    ///
    /// **Law 8:** HIGH-RISK. Requires Steward confirmation.
    /// **Precondition:** `armingState == .armed`.
    ///
    /// - Parameter altitudeMetres: Target altitude above the takeoff point in
    ///   metres. Must be positive; `FlightReducer` rejects zero or negative values.
    case takeoff(altitudeMetres: Double, correlationID: UUID)

    /// Command the vehicle to descend and land at the current position.
    case land(correlationID: UUID)

    /// Command the vehicle to return to its recorded home position and land.
    ///
    /// **Law 7:** The return path is evaluated against the active geofence.
    case returnToLaunch(correlationID: UUID)

    /// Switch the active flight control mode.
    ///
    /// **Law 7:** Mode transitions that alter the safety envelope are
    /// re-validated against `activeGeofence` before acceptance.
    /// **Invariant (CLAUDE.md):** Mode changes during takeoff or landing are
    /// rejected by `FlightReducer`.
    case setFlightMode(mode: FlightMode, correlationID: UUID)

    // MARK: Mission

    /// Load a mission plan into the GCS. Does not start execution.
    ///
    /// **Law 7:** All waypoint positions are validated against the active
    /// geofence before the mission is accepted into state.
    case loadMission(mission: Mission, correlationID: UUID)

    /// Begin executing the loaded mission.
    ///
    /// **Precondition:** `armingState == .armed` and `activeMission != nil`.
    case startMission(correlationID: UUID)

    /// Pause mission execution at the current waypoint.
    case pauseMission(correlationID: UUID)

    /// Remove the active mission from state without executing it.
    case clearMission(correlationID: UUID)

    // MARK: Geofence (Law 7)

    /// Activate a geofence boundary for this session.
    ///
    /// **SVC candidate: Law 7 (Spatial)** — geofence activation is a spatial
    /// law primitive applicable across all GCS jurisdictions.
    ///
    /// Once set, all movement actions are validated against this boundary.
    case setGeofence(geofence: Geofence, correlationID: UUID)

    /// Remove the active geofence.
    ///
    /// **Law 8:** Removing the geofence is a HIGH-RISK action — it expands
    /// the spatial safety envelope. Requires Steward confirmation.
    case clearGeofence(correlationID: UUID)
}

// MARK: - Action Protocol Conformance

extension FlightAction {

    /// A brief human-readable description of this action for audit logs.
    ///
    /// Used by `AuditEvent` to produce legible audit trail entries without
    /// requiring callers to decode `Codable` payloads. Descriptions are
    /// intentionally terse — full payload is available via `Codable`.
    var actionDescription: String {
        switch self {
        case .connect:                    return "connect"
        case .disconnect:                 return "disconnect"
        case let .connectionStatusChanged(status, _):
            return "connectionStatusChanged(\(status.rawValue))"
        case .telemetryReceived:          return "telemetryReceived"
        case let .sensorCalibrationUpdated(imu, compass, _):
            return "sensorCalibrationUpdated(imu:\(imu), compass:\(compass))"
        case .arm:                        return "arm"
        case .disarm:                     return "disarm"
        case let .takeoff(alt, _):        return "takeoff(\(alt)m)"
        case .land:                       return "land"
        case .returnToLaunch:             return "returnToLaunch"
        case let .setFlightMode(mode, _): return "setFlightMode(\(mode.rawValue))"
        case let .loadMission(mission, _):return "loadMission(\(mission.name))"
        case .startMission:               return "startMission"
        case .pauseMission:               return "pauseMission"
        case .clearMission:               return "clearMission"
        case let .setGeofence(geo, _):
            return "setGeofence(r:\(geo.radiusMetres)m)"
        case .clearGeofence:              return "clearGeofence"
        }
    }

    /// The correlation UUID embedded in this action's associated values.
    ///
    /// `SwiftVectorCore.Action` requires this property. It is satisfied by
    /// extracting the UUID stored in each case's associated values — there is
    /// no separate stored property.
    ///
    /// The Orchestrator constructs all `FlightAction` values and supplies the
    /// UUID from its injected `UUIDGenerator`. Call sites must never pass
    /// `UUID()` directly.
    var correlationID: UUID {
        switch self {
        case let .connect(_, id):                       return id
        case let .disconnect(id):                       return id
        case let .connectionStatusChanged(_, id):       return id
        case let .telemetryReceived(_, id):             return id
        case let .sensorCalibrationUpdated(_, _, id):   return id
        case let .arm(id):                              return id
        case let .disarm(id):                           return id
        case let .takeoff(_, id):                       return id
        case let .land(id):                             return id
        case let .returnToLaunch(id):                   return id
        case let .setFlightMode(_, id):                 return id
        case let .loadMission(_, id):                   return id
        case let .startMission(id):                     return id
        case let .pauseMission(id):                     return id
        case let .clearMission(id):                     return id
        case let .setGeofence(_, id):                   return id
        case let .clearGeofence(id):                    return id
        }
    }
}
