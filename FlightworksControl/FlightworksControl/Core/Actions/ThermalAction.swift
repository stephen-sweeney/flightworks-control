//
//  ThermalAction.swift
//  FlightworksControl
//
//  Created by Flightworks Aerial on 2026-02-21.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  FlightLaw composition: ThermalLaw (Phase 5 — ThermalInspection)
//
//  ⚠️  Phase 5 extension point — DO NOT POPULATE UNTIL PHASE 5.
//
//  ThermalAction is the stub typed vocabulary for ThermalLaw. It provides
//  the minimum needed to satisfy the module map in CLAUDE.md and to let
//  the compiler verify Action protocol conformance from Phase 0 forward.
//
//  See: THERMAL_INSPECTION_EXTENSION.md for the full Phase 5 specification.
//
//  SwiftVector invariants enforced here:
//    ✓ Enum (value type) with typed associated values
//    ✓ Equatable, Codable, Sendable — synthesised by Swift
//    ✓ Conforms to SwiftVectorCore.Action
//    ✓ correlationID: UUID embedded per-case; NEVER constructed via UUID()
//    ✓ No Date(), UUID(), or .random() inside this file

import Foundation
import SwiftVectorCore

// MARK: - ThermalAction

/// Thermal anomaly detection action vocabulary.
///
/// **Phase 5 extension point** — Do not add cases until Phase 5
/// (ThermalLaw / ThermalInspection) begins. The two-case stub ensures
/// the module map compiles and Action conformance is addressable from
/// Phase 0 forward.
///
/// **Intended Phase 5 expansion:**
/// - `case thermalFrameReceived(frame: ThermalFrame, correlationID: UUID)` — radiometric frame delivery
/// - `case hotspotDetected(hotspot: ThermalHotspot, correlationID: UUID)` — Law 6 detection output
/// - `case setRadiometricMode(mode: RadiometricMode, correlationID: UUID)` — mode control
///
/// **ThermalLaw composition (Phase 5):**
/// - Law 3: Every detected anomaly is logged as an immutable audit event.
/// - Law 6 (Detection): Hotspot detection is a pure, deterministic function
///          of radiometric pixel data consumed by ThermalReducer.
/// - Law 7: Hotspot GPS positions validated against active geofence.
enum ThermalAction: Action {

    /// Enable radiometric thermal detection.
    ///
    /// **Phase 5:** ThermalReducer transitions `ThermalState.isEnabled` to `true`.
    case enableDetection(correlationID: UUID)

    /// Disable radiometric thermal detection.
    ///
    /// **Phase 5:** ThermalReducer transitions `ThermalState.isEnabled` to `false`
    /// and clears any accumulated hotspot data from state.
    case disableDetection(correlationID: UUID)
}

// MARK: - Action Protocol Conformance

extension ThermalAction {

    /// A brief human-readable description of this action for audit logs.
    var actionDescription: String {
        switch self {
        case .enableDetection:  return "enableDetection"
        case .disableDetection: return "disableDetection"
        }
    }

    /// The correlation UUID embedded in this action's associated values.
    var correlationID: UUID {
        switch self {
        case let .enableDetection(id):  return id
        case let .disableDetection(id): return id
        }
    }
}
