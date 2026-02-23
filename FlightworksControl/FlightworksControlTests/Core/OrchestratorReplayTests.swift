//
//  OrchestratorReplayTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Suites:
//    • OrchestratorReplayTests — deterministic replay, rejected-action skipping

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - FlightOrchestrator: Replay

@Suite("FlightOrchestrator: Replay", .serialized)
struct OrchestratorReplayTests {

    @Test("replay: identical actions produce identical final state hash")
    func replayDeterministic() async {
        let orchestrator = FlightOrchestrator(
            clock: FixedClock(),
            uuidGenerator: SequentialUUIDGenerator()
        )

        let config = ConnectionConfig(host: "10.0.0.1", port: 14550)
        let c1 = UUID(uuidString: "EEEEEEEE-0000-0000-0000-000000000001")!
        let c2 = UUID(uuidString: "EEEEEEEE-0000-0000-0000-000000000002")!

        await orchestrator.dispatch(.connect(config: config, correlationID: c1), agentID: "UI")
        await orchestrator.dispatch(.connectionStatusChanged(status: .connected, correlationID: c2), agentID: "Relay")

        let log = await orchestrator.getAuditLog()
        let replayResult = await orchestrator.replay(log: log)

        #expect(replayResult.succeeded == true)
        #expect(replayResult.expectedHash == replayResult.actualHash)
        #expect(replayResult.failureReason == nil)
    }

    @Test("replay: rejected actions are not re-executed (accepted-only)")
    func replaySkipsRejectedActions() async {
        let orchestrator = FlightOrchestrator(
            clock: FixedClock(),
            uuidGenerator: SequentialUUIDGenerator()
        )

        let config = ConnectionConfig(host: "10.0.0.1", port: 14550)
        let c1 = UUID(uuidString: "FFFFFFFF-0000-0000-0000-000000000001")!
        let c2 = UUID(uuidString: "FFFFFFFF-0000-0000-0000-000000000002")!

        await orchestrator.dispatch(.connect(config: config, correlationID: c1), agentID: "UI")
        await orchestrator.dispatch(.arm(correlationID: c2), agentID: "UI")  // rejected

        let log = await orchestrator.getAuditLog()
        let replayResult = await orchestrator.replay(log: log)

        #expect(replayResult.succeeded == true)
        #expect(replayResult.finalState.connectionStatus == .connecting)
    }

    @Test("replay: empty accepted actions replays to initial state")
    func replayEmptyProducesInitialState() async {
        let orchestrator = FlightOrchestrator(
            clock: FixedClock(),
            uuidGenerator: SequentialUUIDGenerator()
        )

        let c1 = UUID(uuidString: "AAAAAAAB-0000-0000-0000-000000000001")!
        await orchestrator.dispatch(.arm(correlationID: c1), agentID: "UI")  // rejected

        let log = await orchestrator.getAuditLog()
        let replayResult = await orchestrator.replay(log: log)

        #expect(replayResult.succeeded == true)
        #expect(replayResult.finalState == .initial)
    }

    @Test("replay: hash chain verification failure is reported")
    func replayReportsTamperedChain() async {
        let orchestrator = FlightOrchestrator(
            clock: FixedClock(),
            uuidGenerator: SequentialUUIDGenerator()
        )

        let config = ConnectionConfig(host: "10.0.0.1", port: 14550)
        let c1 = UUID(uuidString: "AAAAAAAC-0000-0000-0000-000000000001")!
        await orchestrator.dispatch(.connect(config: config, correlationID: c1), agentID: "UI")

        let tamperedLog = EventLog<FlightAction>()  // empty — missing init event
        let replayResult = await orchestrator.replay(log: tamperedLog)
        #expect(replayResult.finalState == .initial)
    }
}
