//
//  MissionState.swift
//  FlightworksControl
//
//  Created by Flightworks Aerial on 2026-02-18.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  FlightLaw composition: Laws 3, 4, 7, 8
//
//  Phase 0 stub — extended in Phase 1 (MAVSDK integration).
//
//  MissionState tracks the lifecycle of an autonomous mission: planning,
//  upload, execution, and completion. In Phase 0 it carries only the
//  minimum surface area required to compile and conform to State. All
//  mission-execution detail is deferred to the Phase 1 MAVSDK integration
//  sprint.
//
//  SwiftVector invariants enforced here:
//    ✓ Struct (value type), not class
//    ✓ All properties are `let`
//    ✓ Equatable, Codable, Sendable — synthesised by Swift
//    ✓ Conforms to SwiftVectorCore.State (provides stateHash() via default impl)
//    ✓ No Date(), UUID(), or .random() inside this file

import Foundation
import SwiftVectorCore

// MARK: - MissionState

/// Mission planning and execution state.
///
/// **Phase 0 stub** — All fields beyond `isPlanning` are deferred to Phase 1
/// when MAVSDK is integrated and mission upload/execution is implemented.
///
/// **Intended Phase 1 expansion:**
/// - `uploadProgress: Double?` — Waypoint upload progress (0.0–1.0)
/// - `currentWaypointIndex: Int?` — Index into the active mission's waypoint list
/// - `executionStatus: MissionExecutionStatus` — `.idle`, `.uploading`, `.executing`, `.paused`, `.complete`, `.failed`
///
/// **FlightLaw composition:**
/// - Law 3: Mission start/stop transitions are audited with pre/post state hashes.
/// - Law 7: Waypoint positions are validated against the active geofence before upload.
/// - Law 8: Mission start is a HIGH-RISK action requiring Steward confirmation.
struct MissionState: State {

    /// Whether the operator is actively constructing a mission plan.
    ///
    /// `true` while the operator is placing waypoints or editing a loaded mission.
    /// Transitions to `false` on upload, cancellation, or mission completion.
    ///
    /// Phase 1: This field will be superseded by a `MissionExecutionStatus` enum
    /// that expresses the full planning → upload → execute → complete lifecycle.
    let isPlanning: Bool
}

// MARK: - Initial State

extension MissionState {

    /// The canonical starting state: no mission is planned or executing.
    static let initial = MissionState(isPlanning: false)
}
