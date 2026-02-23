//
//  OrchestratorReplayIntegrationTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Replay and full-cycle integration tests for FlightOrchestrator.
//
//  Suites:
//    • OrchestratorReplayTests       — deterministic replay, rejected-action skipping
//    • OrchestratorIntegrationTests  — full connect→calibrate→arm cycle, stateStream

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

// MARK: - FlightOrchestrator: Integration (Full Dispatch Cycle)

@Suite("FlightOrchestrator: Integration", .serialized)
struct OrchestratorIntegrationTests {

    @Test("Integration: connect → calibrate → setGeofence → arm sequence")
    func fullDispatchCycleConnectArm() async {
        let clock = FixedClock()
        let uuidGen = SequentialUUIDGenerator()
        let orchestrator = FlightOrchestrator(clock: clock, uuidGenerator: uuidGen)

        let config = ConnectionConfig(host: "192.168.1.100", port: 14550)
        let geofence = Geofence(
            center: Position(latitude: 37.7749, longitude: -122.4194, altitudeMSL: 0.0),
            radiusMetres: 300.0
        )
        let battery = BatteryState(percentage: 80.0, voltageV: 12.3, temperatureC: 24.0)
        let gpsInfo = GPSInfo(fixType: .fix3D, satelliteCount: 10)

        var idx = 1
        func nextID() -> UUID {
            defer { idx += 1 }
            return UUID(uuidString: "11111111-0000-0000-0000-\(String(format: "%012X", idx))")!
        }

        let r1 = await orchestrator.dispatch(.connect(config: config, correlationID: nextID()), agentID: "UI")
        #expect(r1.applied == true)

        let r2 = await orchestrator.dispatch(.connectionStatusChanged(status: .connected, correlationID: nextID()), agentID: "Relay")
        #expect(r2.applied == true)

        let r3 = await orchestrator.dispatch(.sensorCalibrationUpdated(imuCalibrated: true, compassCalibrated: true, correlationID: nextID()), agentID: "Relay")
        #expect(r3.applied == true)

        let telemetry = TelemetryData(
            position: nil, attitude: nil,
            battery: battery, gpsInfo: gpsInfo,
            timestamp: clock.now()
        )
        let r4 = await orchestrator.dispatch(.telemetryReceived(data: telemetry, correlationID: nextID()), agentID: "Relay")
        #expect(r4.applied == true)

        let r5 = await orchestrator.dispatch(.setGeofence(geofence: geofence, correlationID: nextID()), agentID: "UI")
        #expect(r5.applied == true)

        let r6 = await orchestrator.dispatch(.arm(correlationID: nextID()), agentID: "UI")
        #expect(r6.applied == true)

        let finalState = await orchestrator.currentState()
        #expect(finalState.armingState == .armed)
        #expect(finalState.connectionStatus == .connected)
        #expect(finalState.imuCalibrated == true)
        #expect(finalState.compassCalibrated == true)
        #expect(finalState.activeGeofence != nil)

        let log = await orchestrator.getAuditLog()
        #expect(log.count == 7)  // 1 init + 6 dispatches
        #expect(log.verify().isValid == true)
    }

    @Test("Integration: replay of full sequence produces same final state hash")
    func fullDispatchCycleReplay() async {
        let clock = FixedClock()
        let uuidGen = SequentialUUIDGenerator()
        let orchestrator = FlightOrchestrator(clock: clock, uuidGenerator: uuidGen)

        let config = ConnectionConfig(host: "10.0.0.1", port: 14550)
        let c1 = UUID(uuidString: "22222222-0000-0000-0000-000000000001")!
        let c2 = UUID(uuidString: "22222222-0000-0000-0000-000000000002")!

        await orchestrator.dispatch(.connect(config: config, correlationID: c1), agentID: "UI")
        await orchestrator.dispatch(.connectionStatusChanged(status: .connected, correlationID: c2), agentID: "Relay")

        let log = await orchestrator.getAuditLog()
        let replayResult = await orchestrator.replay(log: log)

        #expect(replayResult.succeeded == true)
        #expect(replayResult.actualHash == replayResult.expectedHash)
        #expect(replayResult.failureReason == nil)
    }

    @Test("Integration: stateStream yields state after each dispatch")
    func stateStreamYieldsUpdates() async {
        let orchestrator = FlightOrchestrator()
        let stream = orchestrator.stateStream()

        var iterator = stream.makeAsyncIterator()

        let initial = await iterator.next()
        #expect(initial?.connectionStatus == .disconnected)

        let config = ConnectionConfig(host: "10.0.0.1", port: 14550)
        let corrID = UUID(uuidString: "33333333-0000-0000-0000-000000000001")!
        await orchestrator.dispatch(.connect(config: config, correlationID: corrID), agentID: "UI")

        let afterConnect = await iterator.next()
        #expect(afterConnect?.connectionStatus == .connecting)
    }
}
