//
//  SupportingTypes.swift
//  FlightworksControl
//
//  Created by Flightworks Aerial on 2026-02-18.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  FlightLaw composition: Laws 3, 4, 7, 8
//
//  SVC Candidate Notes:
//  Several types below are generic enough to belong in SwiftVectorCore as
//  Law-level primitives. Each is annotated with its candidate law:
//    - Position, Attitude, GPSInfo, GPSFixType → Law 7 (Spatial)
//    - BatteryState → Law 4 (Resource / circuit breaker)
//    - TelemetryData → Law 3 (Audit / observation backbone)
//  These should be extracted upstream when SwiftVectorCore formalises those laws.

import Foundation

// MARK: - Connection

/// The GCS–vehicle link state.
///
/// Drives UI indication and guards all flight-control actions: no action other
/// than `.connect` is valid while disconnected.
enum ConnectionStatus: String, Equatable, Codable, Sendable {
    case disconnected
    case connecting
    case connected
    /// Link was established but subsequently lost without an explicit disconnect.
    case lost
}

// MARK: - Arming

/// Whether the vehicle's motors are armed.
///
/// Law 3 audit: every transition is logged with the full pre/post state hash.
/// Law 8 authority: `.arm` is a HIGH-RISK action requiring Steward confirmation.
enum ArmingState: String, Equatable, Codable, Sendable {
    case disarmed
    case armed
}

// MARK: - Flight Mode

/// The active flight control mode.
///
/// Law 7 spatial: mode transitions that change the safety envelope
/// (e.g. entering `.returningToLaunch`) must re-validate geofence policy.
enum FlightMode: String, Equatable, Codable, Sendable {
    /// Vehicle on ground, motors may or may not be armed.
    case idle
    /// Ascending to the requested altitude after takeoff command.
    case takingOff
    /// In controlled flight under GCS or mission authority.
    case flying
    /// Stationary hold at current position and altitude.
    case hovering
    /// Descending for landing; motor disarm follows touchdown.
    case landing
    /// Autonomous return to the home point.
    case returningToLaunch
    /// Direct RC input (manual override); autonomous authority suspended.
    case manual
}

// MARK: - GPS

/// GPS fix quality.
///
/// SVC candidate: Law 7 (Spatial) — the safety envelope validator needs
/// `.fix3D` as a hard arming precondition regardless of jurisdiction.
enum GPSFixType: String, Equatable, Codable, Sendable {
    /// No satellite fix.
    case noFix
    /// Two-dimensional fix (altitude unreliable).
    case fix2D
    /// Full three-dimensional fix. Required for arming (Law 8).
    case fix3D
}

/// GPS receiver status snapshot.
///
/// SVC candidate: Law 7 (Spatial).
struct GPSInfo: Equatable, Codable, Sendable {
    let fixType: GPSFixType
    let satelliteCount: Int
}

// MARK: - Position

/// A WGS-84 geographic position.
///
/// SVC candidate: Law 7 (Spatial) — geofence validation, sector boundary
/// checking, and ground-stop envelope contraction all operate on this type.
struct Position: Equatable, Codable, Sendable {
    /// Decimal degrees, positive north. Range: −90…90.
    let latitude: Double
    /// Decimal degrees, positive east. Range: −180…180.
    let longitude: Double
    /// Metres above mean sea level (MSL).
    let altitudeMSL: Double
}

// MARK: - Attitude

/// Vehicle orientation expressed as Euler angles.
///
/// SVC candidate: Law 7 (Spatial) — attitude limits are part of the
/// spatial safety envelope (e.g. max pitch/roll thresholds).
struct Attitude: Equatable, Codable, Sendable {
    /// Roll angle in degrees. Positive = right wing down.
    let rollDeg: Double
    /// Pitch angle in degrees. Positive = nose up.
    let pitchDeg: Double
    /// Yaw (heading) in degrees true. Range: 0…360.
    let yawDeg: Double
}

// MARK: - Battery

/// Battery status snapshot.
///
/// SVC candidate: Law 4 (Resource / circuit breaker) — the circuit breaker
/// law evaluates `percentage` against configurable thresholds to force
/// degraded operation or RTL regardless of jurisdiction.
struct BatteryState: Equatable, Codable, Sendable {
    /// State of charge in percent. Range: 0.0…100.0.
    let percentage: Double
    /// Pack voltage in volts.
    let voltageV: Double
    /// Pack temperature in degrees Celsius.
    let temperatureC: Double
}

// MARK: - Telemetry

/// An aggregated sensor snapshot delivered by the Edge Relay.
///
/// SVC candidate: Law 3 (Audit / observation backbone) — the telemetry type
/// is the primary observation input for the audit backbone. Timestamp is
/// supplied by the Edge Relay and carried verbatim into state; it is never
/// constructed inside a Reducer.
///
/// All optional fields reflect genuine sensor availability (e.g. GPS may be
/// absent indoors). Absence is a valid and meaningful state.
struct TelemetryData: Equatable, Codable, Sendable {
    let position: Position?
    let attitude: Attitude?
    let battery: BatteryState?
    let gpsInfo: GPSInfo?
    /// Timestamp of the sensor snapshot, set by the Edge Relay.
    /// Never use `Date()` here — this value comes from the injected Clock
    /// via the Orchestrator's dispatch path.
    let timestamp: Date
}

// MARK: - Mission

/// A single mission waypoint.
struct Waypoint: Equatable, Codable, Sendable {
    let position: Position
    /// Target altitude in metres MSL at this waypoint.
    let altitudeMSL: Double
}

/// A named sequence of waypoints forming an autonomous mission.
///
/// `id` is assigned by the Orchestrator using the injected UUIDGenerator —
/// never with a direct `UUID()` call inside the Reducer.
struct Mission: Equatable, Codable, Sendable {
    let id: UUID
    let name: String
    let waypoints: [Waypoint]
}

// MARK: - Geofence

/// A circular geographic boundary.
///
/// SVC candidate: Law 7 (Spatial) — the spatial law owns geofence evaluation.
/// FlightworksControl stores it in state; Law 7 validates actions against it.
struct Geofence: Equatable, Codable, Sendable {
    let center: Position
    /// Radius in metres. Movements outside this circle are rejected by Law 7.
    let radiusMetres: Double
}

// MARK: - Connection Configuration

/// Parameters for establishing a link to the Edge Relay.
struct ConnectionConfig: Equatable, Codable, Sendable {
    let host: String
    let port: UInt16
}
