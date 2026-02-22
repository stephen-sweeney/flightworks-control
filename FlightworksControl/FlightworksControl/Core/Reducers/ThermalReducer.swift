//
//  ThermalReducer.swift
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
//  This stub exists so the module map in CLAUDE.md compiles from Phase 0
//  forward. ThermalReducer will govern thermal anomaly detection, hotspot
//  classification, and radiometric data handling once Phase 5 begins.
//
//  SwiftVector invariants enforced here:
//    ✓ Struct (value type), conforms to SwiftVectorCore.Reducer
//    ✓ Pure function — no side effects, no I/O
//    ✓ No Date(), UUID(), or .random() inside this file
//    ✓ All ThermalAction cases handled (exhaustive switch)

import Foundation
import SwiftVectorCore

// MARK: - ThermalReducer

/// Pure function that validates and applies `ThermalAction` to `ThermalState`.
///
/// **Phase 5 extension point** — Only `enableDetection` and `disableDetection`
/// are handled here. Phase 5 will add ThermalFrame ingestion, hotspot
/// classification, and geofence-validated hotspot storage.
struct ThermalReducer: Reducer {

    typealias S = ThermalState
    typealias A = ThermalAction

    func reduce(state: ThermalState, action: ThermalAction) -> ReducerResult<ThermalState> {
        switch action {

        case .enableDetection:
            guard !state.isEnabled else {
                return .rejected(state, rationale: "enableDetection rejected: thermal detection already enabled")
            }
            return .accepted(
                ThermalState(isEnabled: true),
                rationale: "thermal detection enabled"
            )

        case .disableDetection:
            guard state.isEnabled else {
                return .rejected(state, rationale: "disableDetection rejected: thermal detection already disabled")
            }
            return .accepted(
                ThermalState(isEnabled: false),
                rationale: "thermal detection disabled"
            )
        }
    }
}
