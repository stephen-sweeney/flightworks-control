//
//  ThermalState.swift
//  FlightworksControl
//
//  Created by Flightworks Aerial on 2026-02-18.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  FlightLaw composition: ThermalLaw (Phase 5 — ThermalInspection)
//
//  ⚠️  Phase 5 extension point — DO NOT POPULATE UNTIL PHASE 5.
//
//  This stub exists so the module map in CLAUDE.md compiles from Phase 0
//  forward. ThermalLaw is the jurisdiction that will govern thermal anomaly
//  detection, hotspot classification, and radiometric data handling. It
//  composes into FlightLaw once Phase 5 begins.
//
//  See: THERMAL_INSPECTION_EXTENSION.md for the full Phase 5 specification.
//
//  SwiftVector invariants enforced here:
//    ✓ Struct (value type), not class
//    ✓ All properties are `let`
//    ✓ Equatable, Codable, Sendable — synthesised by Swift
//    ✓ Conforms to SwiftVectorCore.State (provides stateHash() via default impl)
//    ✓ No Date(), UUID(), or .random() inside this file

import Foundation
import SwiftVectorCore

// MARK: - ThermalState

/// Thermal anomaly detection and radiometric inspection state.
///
/// **Phase 5 extension point** — Do not add fields until Phase 5
/// (ThermalLaw / ThermalInspection) begins. The stub conformance ensures the
/// module map compiles and the type is addressable by the Orchestrator from
/// Phase 0 forward.
///
/// **Intended Phase 5 expansion:**
/// - `detectedHotspots: [ThermalHotspot]` — Classified anomalies with GPS position, temperature, severity
/// - `radiometricMode: RadiometricMode` — `.disabled`, `.monitoring`, `.classifying`
/// - `cameraTemperatureC: Double?` — Radiometric camera sensor temperature for calibration
/// - `lastScanTimestamp: Date?` — Injected via Clock; never constructed as `Date()`
///
/// **ThermalLaw composition (Phase 5):**
/// - Law 3: Every detected anomaly is logged as an immutable audit event.
/// - Law 4: Thermal camera power draw is tracked as a resource token; excessive
///          thermal load may trigger circuit-breaker degraded mode.
/// - Law 6 (Detection): Hotspot classification is a pure, deterministic function
///          of radiometric pixel data — no side effects, full replay verifiability.
/// - Law 7: Hotspot GPS positions are validated against the active geofence before
///          storage in state.
///
/// **SVC candidate (Phase 5):**
/// `ThermalHotspot` and `RadiometricMode` are candidates for extraction into
/// SwiftVectorCore as Law 6 (Detection) primitives once ThermalLaw is formalised.
struct ThermalState: State {

    /// Whether thermal detection is active.
    ///
    /// `false` in all Phase 0–4 sessions. Phase 5 transitions this to `true`
    /// when a ThermalAction.enableDetection action is accepted by ThermalReducer.
    let isEnabled: Bool
}

// MARK: - Initial State

extension ThermalState {

    /// The canonical starting state: thermal detection is disabled.
    static let initial = ThermalState(isEnabled: false)
}
