//
//  OrchestratorTestFixtures.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Shared fakes and constants for all OrchestratorTests files.
//  Internal visibility so all files in the test target can access them.

import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - Deterministic Fakes

/// A Clock that returns a fixed, controllable date.
/// Satisfies the SwiftVector invariant: no `Date()` in orchestrator.
final class FixedClock: Clock, @unchecked Sendable {
    private(set) var current: Date
    init(_ date: Date = Date(timeIntervalSince1970: 1_000_000)) {
        current = date
    }
    func now() -> Date { current }
    func advance(by seconds: TimeInterval) { current = current.addingTimeInterval(seconds) }
}

/// A UUIDGenerator that returns sequential, deterministic UUIDs.
/// Format: "00000000-0000-0000-0000-000000000NNN" where NNN is the call count.
final class SequentialUUIDGenerator: UUIDGenerator, @unchecked Sendable {
    private var counter: UInt64 = 0
    func next() -> UUID {
        counter += 1
        let hex = String(format: "%012X", counter)
        return UUID(uuidString: "00000000-0000-0000-0000-\(hex)")!
    }
}

// MARK: - Shared Constants

let fixedTimestamp = Date(timeIntervalSince1970: 1_000_000)
let dispatchAgentID = "TestHarness"
