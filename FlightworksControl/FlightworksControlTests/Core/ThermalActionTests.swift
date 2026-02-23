//
//  ThermalActionTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Tests for the ThermalAction type (SP0-3 Action Layer).
//
//  Suites:
//    • ThermalActionTests — Codable, Equatable, correlationID, actionDescription, case coverage

import Foundation
import Testing
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - ThermalAction Tests

@Suite("ThermalAction")
struct ThermalActionTests {

    // MARK: Codable Round-Trip

    @Test("Codable round-trip: enableDetection")
    func codableEnableDetection() throws {
        let original = ThermalAction.enableDetection(correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ThermalAction.self, from: data)
        #expect(decoded == original)
    }

    @Test("Codable round-trip: disableDetection")
    func codableDisableDetection() throws {
        let original = ThermalAction.disableDetection(correlationID: actionIDa)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ThermalAction.self, from: data)
        #expect(decoded == original)
    }

    // MARK: Equatable

    @Test("Equatable: same case + same correlationID → equal")
    func equalitySameCaseSameID() {
        let a = ThermalAction.enableDetection(correlationID: actionIDa)
        let b = ThermalAction.enableDetection(correlationID: actionIDa)
        #expect(a == b)
    }

    @Test("Equatable: same case + different correlationID → not equal")
    func inequalitySameCaseDifferentID() {
        let a = ThermalAction.enableDetection(correlationID: actionIDa)
        let b = ThermalAction.enableDetection(correlationID: actionIDb)
        #expect(a != b)
    }

    @Test("Equatable: enableDetection vs disableDetection → not equal")
    func inequalityDifferentCases() {
        let a = ThermalAction.enableDetection(correlationID: actionIDa)
        let b = ThermalAction.disableDetection(correlationID: actionIDa)
        #expect(a != b)
    }

    // MARK: correlationID Extraction

    @Test("correlationID: extracted from every case")
    func correlationIDAllCases() {
        for action in allThermalActions {
            #expect(action.correlationID == actionIDa,
                    "Expected actionIDa for \(action.actionDescription)")
        }
    }

    @Test("correlationID: enableDetection returns embedded UUID")
    func correlationIDEnableDetection() {
        let action = ThermalAction.enableDetection(correlationID: actionIDb)
        #expect(action.correlationID == actionIDb)
    }

    // MARK: actionDescription

    @Test("actionDescription: non-empty for every case")
    func actionDescriptionNonEmpty() {
        for action in allThermalActions {
            #expect(!action.actionDescription.isEmpty)
        }
    }

    @Test("actionDescription: enableDetection returns 'enableDetection'")
    func actionDescriptionEnable() {
        #expect(ThermalAction.enableDetection(correlationID: actionIDa).actionDescription == "enableDetection")
    }

    @Test("actionDescription: disableDetection returns 'disableDetection'")
    func actionDescriptionDisable() {
        #expect(ThermalAction.disableDetection(correlationID: actionIDa).actionDescription == "disableDetection")
    }

    // MARK: Case Coverage

    @Test("Case coverage: allThermalActions contains 2 distinct cases")
    func allCasesCount() {
        #expect(allThermalActions.count == 2)
    }
}
