//
//  OrchestratorDispatchTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  dispatch() and audit trail tests for FlightOrchestrator.
//
//  Suites:
//    • OrchestratorDispatchTests   — accepted/rejected dispatch, audit log growth, agentID
//    • OrchestratorAuditTrailTests — init event, hash chain links, verify(), timestamps

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - FlightOrchestrator: dispatch tests

@Suite("FlightOrchestrator: dispatch", .serialized)
struct OrchestratorDispatchTests {

    // MARK: Accepted dispatch

    @Test("dispatch: accepted action updates state")
    func dispatchAcceptedUpdatesState() async {
        let clock = FixedClock()
        let uuidGen = SequentialUUIDGenerator()
        let orchestrator = FlightOrchestrator(
            clock: clock,
            uuidGenerator: uuidGen
        )

        let config = ConnectionConfig(host: "10.0.0.1", port: 14550)
        let corrID = UUID(uuidString: "AAAAAAA0-0000-0000-0000-000000000001")!
        let result = await orchestrator.dispatch(
            .connect(config: config, correlationID: corrID),
            agentID: dispatchAgentID
        )

        #expect(result.applied == true)
        let state = await orchestrator.currentState()
        #expect(state.connectionStatus == .connecting)
    }

    @Test("dispatch: rejected action leaves state unchanged")
    func dispatchRejectedLeavesStateUnchanged() async {
        let orchestrator = FlightOrchestrator()
        // arm on initial state → rejected (not connected)
        let corrID = UUID(uuidString: "AAAAAAA0-0000-0000-0000-000000000002")!
        let result = await orchestrator.dispatch(
            .arm(correlationID: corrID),
            agentID: dispatchAgentID
        )

        #expect(result.applied == false)
        let state = await orchestrator.currentState()
        #expect(state == .initial)
    }

    @Test("dispatch: returns ReducerResult with rationale")
    func dispatchReturnsReducerResult() async {
        let orchestrator = FlightOrchestrator()
        let corrID = UUID(uuidString: "AAAAAAA0-0000-0000-0000-000000000003")!
        let result = await orchestrator.dispatch(
            .arm(correlationID: corrID),
            agentID: dispatchAgentID
        )

        #expect(!result.rationale.isEmpty)
        #expect(result.applied == false)
    }

    // MARK: Audit log growth

    @Test("dispatch: audit log grows by 1 per call")
    func dispatchAuditLogGrowsByOne() async {
        let orchestrator = FlightOrchestrator()
        let logBefore = await orchestrator.getAuditLog()
        let countBefore = logBefore.count  // starts at 1 (initialization entry)

        let corrID = UUID(uuidString: "AAAAAAA0-0000-0000-0000-000000000004")!
        await orchestrator.dispatch(
            .arm(correlationID: corrID),
            agentID: dispatchAgentID
        )

        let logAfter = await orchestrator.getAuditLog()
        #expect(logAfter.count == countBefore + 1)
    }

    @Test("dispatch: multiple dispatches accumulate in audit log")
    func dispatchMultipleAccumulate() async {
        let orchestrator = FlightOrchestrator()
        let config = ConnectionConfig(host: "192.168.1.1", port: 14550)

        for i in 1...5 {
            let corrID = UUID(uuidString: "AAAAAAA0-0000-0000-0000-\(String(format: "%012X", i))")!
            await orchestrator.dispatch(
                .connect(config: config, correlationID: corrID),
                agentID: dispatchAgentID
            )
        }

        let log = await orchestrator.getAuditLog()
        // 1 init + 5 dispatches (first accepted, rest rejected — "already connecting")
        #expect(log.count == 6)
    }

    // MARK: Agent ID attribution

    @Test("dispatch: agentID is recorded in accepted event")
    func dispatchAgentIDInAcceptedEvent() async {
        let orchestrator = FlightOrchestrator()
        let config = ConnectionConfig(host: "10.0.0.1", port: 14550)
        let corrID = UUID(uuidString: "AAAAAAA0-0000-0000-0000-000000000005")!

        await orchestrator.dispatch(
            .connect(config: config, correlationID: corrID),
            agentID: "FlightUI"
        )

        let log = await orchestrator.getAuditLog()
        let actions = log.acceptedActions()
        #expect(actions.last?.agentID == "FlightUI")
    }

    @Test("dispatch: agentID is recorded in rejected event")
    func dispatchAgentIDInRejectedEvent() async {
        let orchestrator = FlightOrchestrator()
        let corrID = UUID(uuidString: "AAAAAAA0-0000-0000-0000-000000000006")!

        await orchestrator.dispatch(
            .arm(correlationID: corrID),
            agentID: "ThermalAgent"
        )

        let log = await orchestrator.getAuditLog()
        let rejections = log.rejectedActions()
        #expect(rejections.last?.agentID == "ThermalAgent")
    }
}

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
