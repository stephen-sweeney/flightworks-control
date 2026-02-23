//
//  ReducerConnectionTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Suites:
//    • FlightReducerConnectionTests — connect, disconnect, connectionStatusChanged

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - FlightReducer: Connection

@Suite("FlightReducer: Connection", .serialized)
struct FlightReducerConnectionTests {

    @Test("connect: accepted when disconnected")
    func connectAcceptedWhenDisconnected() {
        let config = ConnectionConfig(host: "192.168.1.1", port: 14550)
        let result = FlightReducer().reduce(state: FlightState.initial, action: .connect(config: config, correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.connectionStatus == .connecting)
    }

    @Test("connect: accepted when connection was lost")
    func connectAcceptedWhenLost() {
        let state = FlightState.initial.with(connectionStatus: .lost)
        let config = ConnectionConfig(host: "10.0.0.1", port: 14550)
        let result = FlightReducer().reduce(state: state, action: .connect(config: config, correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.connectionStatus == .connecting)
    }

    @Test("connect: rejected when already connected")
    func connectRejectedWhenConnected() {
        let state = FlightState.initial.with(connectionStatus: .connected)
        let config = ConnectionConfig(host: "10.0.0.1", port: 14550)
        let result = FlightReducer().reduce(state: state, action: .connect(config: config, correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("disconnect: accepted when connected; clears flight data")
    func disconnectAcceptedClearsFlyData() {
        let state = makeReadyToArmState().with(
            telemetry: .some(TelemetryData(
                position: Position(latitude: 37.0, longitude: -122.0, altitudeMSL: 50.0),
                attitude: nil, battery: nil, gpsInfo: nil,
                timestamp: Date(timeIntervalSince1970: 0)
            ))
        )
        let result = FlightReducer().reduce(state: state, action: .disconnect(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.connectionStatus == .disconnected)
        #expect(result.newState.telemetry == nil)
        #expect(result.newState.position == nil)
        #expect(result.newState.battery == nil)
        #expect(result.newState.gpsInfo == nil)
    }

    @Test("disconnect: rejected when already disconnected")
    func disconnectRejectedWhenAlreadyDisconnected() {
        let result = FlightReducer().reduce(state: FlightState.initial, action: .disconnect(correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("connectionStatusChanged: always accepted")
    func connectionStatusChangedAlwaysAccepted() {
        for status in [ConnectionStatus.disconnected, .connecting, .connected, .lost] {
            let result = FlightReducer().reduce(
                state: FlightState.initial,
                action: .connectionStatusChanged(status: status, correlationID: testID)
            )
            #expect(result.applied == true)
            #expect(result.newState.connectionStatus == status)
        }
    }
}
