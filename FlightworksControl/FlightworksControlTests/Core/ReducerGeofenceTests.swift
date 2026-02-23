//
//  ReducerGeofenceTests.swift
//  FlightworksControlTests
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  Suites:
//    • FlightReducerGeofenceTests — setGeofence, clearGeofence

import Testing
import Foundation
import SwiftVectorCore
@testable import FlightworksControl

// MARK: - FlightReducer: Geofence (Law 7)

@Suite("FlightReducer: Geofence", .serialized)
struct FlightReducerGeofenceTests {

    @Test("setGeofence: accepted with positive radius")
    func setGeofenceAccepted() {
        let geofence = Geofence(
            center: Position(latitude: 37.0, longitude: -122.0, altitudeMSL: 0.0),
            radiusMetres: 300.0
        )
        let result = FlightReducer().reduce(state: FlightState.initial, action: .setGeofence(geofence: geofence, correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.activeGeofence == geofence)
    }

    @Test("setGeofence: rejected with zero radius")
    func setGeofenceRejectedZeroRadius() {
        let geofence = Geofence(
            center: Position(latitude: 37.0, longitude: -122.0, altitudeMSL: 0.0),
            radiusMetres: 0.0
        )
        let result = FlightReducer().reduce(state: FlightState.initial, action: .setGeofence(geofence: geofence, correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("positive"))
    }

    @Test("setGeofence: rejected with negative radius")
    func setGeofenceRejectedNegativeRadius() {
        let geofence = Geofence(
            center: Position(latitude: 37.0, longitude: -122.0, altitudeMSL: 0.0),
            radiusMetres: -100.0
        )
        let result = FlightReducer().reduce(state: FlightState.initial, action: .setGeofence(geofence: geofence, correlationID: testID))
        #expect(result.applied == false)
    }

    @Test("clearGeofence: accepted when geofence is active (Law 8 HIGH-RISK, Orchestrator pre-approves)")
    func clearGeofenceAccepted() {
        let result = FlightReducer().reduce(state: makeReadyToArmState(), action: .clearGeofence(correlationID: testID))
        #expect(result.applied == true)
        #expect(result.newState.activeGeofence == nil)
    }

    @Test("clearGeofence: rejected when no active geofence")
    func clearGeofenceRejectedWhenNone() {
        let result = FlightReducer().reduce(state: FlightState.initial, action: .clearGeofence(correlationID: testID))
        #expect(result.applied == false)
        #expect(result.rationale.contains("geofence"))
    }
}
