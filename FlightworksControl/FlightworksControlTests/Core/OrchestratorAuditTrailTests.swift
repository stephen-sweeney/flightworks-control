//
//  OrchestratorAuditTrailTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Suites:
//    • OrchestratorAuditTrailTests — init event, hash chain links, verify(), timestamps

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - FlightOrchestrator: Audit Trail / Hash Chain

@Suite("FlightOrchestrator: Audit Trail", .serialized)
struct OrchestratorAuditTrailTests {

    @Test("auditLog: first entry is always initialization event")
    func auditLogFirstEntryIsInitialization() async {
        let clock = FixedClock()
        let uuidGen = SequentialUUIDGenerator()
        let orchestrator = FlightOrchestrator(clock: clock, uuidGenerator: uuidGen)

        let log = await orchestrator.getAuditLog()
        #expect(log.count == 1)
        let firstEvent = log.first
        #expect(firstEvent != nil)
        if case .initialization = firstEvent?.eventType {
            // expected
        } else {
            Issue.record("Expected initialization eventType, got \(String(describing: firstEvent?.eventType))")
        }
    }

    @Test("auditLog: initialization event records initial state hash")
    func auditLogInitializationRecordsHash() async {
        let orchestrator = FlightOrchestrator()
        let log = await orchestrator.getAuditLog()
        let initEvent = log.first
        #expect(initEvent?.stateHashAfter == FlightState.initial.stateHash())
    }

    @Test("auditLog: hash chain verifies cleanly after multiple dispatches")
    func auditLogHashChainVerifies() async {
        let orchestrator = FlightOrchestrator(
            clock: FixedClock(),
            uuidGenerator: SequentialUUIDGenerator()
        )

        let config = ConnectionConfig(host: "10.0.0.1", port: 14550)
        let ids = (1...4).map { UUID(uuidString: "BBBBBBBB-0000-0000-0000-\(String(format: "%012X", $0))")! }

        await orchestrator.dispatch(.connect(config: config, correlationID: ids[0]), agentID: "UI")
        await orchestrator.dispatch(.arm(correlationID: ids[1]), agentID: "UI")
        await orchestrator.dispatch(.connectionStatusChanged(status: .connected, correlationID: ids[2]), agentID: "Telemetry")
        await orchestrator.dispatch(.arm(correlationID: ids[3]), agentID: "UI")

        let log = await orchestrator.getAuditLog()
        let verification = log.verify()
        #expect(verification.isValid == true)
        #expect(verification.brokenAtIndex == nil)
        #expect(verification.failureReason == nil)
    }

    @Test("auditLog: previousEntryHash links each entry to the prior one")
    func auditLogPreviousHashLinks() async {
        let orchestrator = FlightOrchestrator(
            clock: FixedClock(),
            uuidGenerator: SequentialUUIDGenerator()
        )

        let config = ConnectionConfig(host: "10.0.0.1", port: 14550)
        let id1 = UUID(uuidString: "CCCCCCCC-0000-0000-0000-000000000001")!
        let id2 = UUID(uuidString: "CCCCCCCC-0000-0000-0000-000000000002")!

        await orchestrator.dispatch(.connect(config: config, correlationID: id1), agentID: "UI")
        await orchestrator.dispatch(.arm(correlationID: id2), agentID: "UI")

        let log = await orchestrator.getAuditLog()
        #expect(log.count == 3)
        let e0 = log.entries[0]
        let e1 = log.entries[1]
        let e2 = log.entries[2]

        #expect(e1.previousEntryHash == e0.entryHash)
        #expect(e2.previousEntryHash == e1.entryHash)
    }

    @Test("auditLog: timestamps come from injected Clock (not Date())")
    func auditLogTimestampsFromClock() async {
        let fixedDate = Date(timeIntervalSince1970: 500_000)
        let clock = FixedClock(fixedDate)
        let orchestrator = FlightOrchestrator(clock: clock, uuidGenerator: SequentialUUIDGenerator())

        let corrID = UUID(uuidString: "DDDDDDDD-0000-0000-0000-000000000001")!
        await orchestrator.dispatch(.arm(correlationID: corrID), agentID: "UI")

        let log = await orchestrator.getAuditLog()
        for entry in log {
            #expect(entry.timestamp == fixedDate)
        }
    }
}
