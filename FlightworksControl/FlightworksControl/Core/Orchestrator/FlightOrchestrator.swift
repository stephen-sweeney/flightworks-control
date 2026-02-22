//
//  FlightOrchestrator.swift
//  FlightworksControl
//
//  Created by Flightworks Aerial on 2026-02-22.
//  Copyright © 2026 Flightworks Aerial LLC. All rights reserved.
//
//  SPDX-License-Identifier: MIT
//
//  FlightLaw composition: All laws (via FlightReducer)
//
//  FlightOrchestrator is the runtime boundary between the GCS UI / agent
//  layer and the deterministic FlightReducer. It:
//    1. Accepts actions from UI or agents via `dispatch(_:agentID:)`
//    2. Passes them through FlightReducer (pure function)
//    3. Records each transition in a tamper-evident hash-chain audit log
//    4. Broadcasts the new state via AsyncStream for SwiftUI observation
//    5. Supports deterministic replay from the audit log via `replay()`
//
//  SwiftVector invariants enforced here:
//    ✓ `actor` — all state mutations are serialised; no data races
//    ✓ Clock and UUIDGenerator are injected — no `Date()` or `UUID()` calls
//    ✓ Hash chain: each AuditEvent.previousEntryHash = previous event's entryHash
//    ✓ Operators cannot bypass the reducer (no direct state mutation)
//    ✓ `dispatch` is the single entry point for all state changes

import Foundation
import SwiftVectorCore

// MARK: - FlightOrchestrator

/// Runtime boundary for GCS state management.
///
/// **Thread safety:** `actor` isolation ensures all `state` mutations and
/// audit-log appends are serialised. Callers from SwiftUI `@MainActor`
/// contexts must `await dispatch(...)`.
///
/// **Audit chain:** Every `dispatch` call appends an `AuditEvent` to
/// `auditLog`. Each event records the state hashes before and after the
/// transition, the correlation ID, and the previous event's `entryHash`,
/// forming a tamper-evident chain. The chain can be verified offline with
/// `auditLog.verify()`.
///
/// **Replay:** `replay(log:)` re-executes every accepted action from a
/// provided `EventLog` against a fresh `FlightState.initial`, then verifies
/// the final state hash matches the log's `currentStateHash`. A mismatch
/// indicates either non-determinism in the reducer or a tampered log.
///
/// **Non-determinism:** No `Date()` or `UUID()` are called inside this actor.
/// All timestamps come from the injected `Clock`; all IDs from the injected
/// `UUIDGenerator`. Tests inject deterministic fakes to achieve full replay.
actor FlightOrchestrator {

    // MARK: - Stored State

    /// The current, authoritative GCS state. Mutated only by `dispatch`.
    private(set) var state: FlightState

    // MARK: - Dependencies

    private let reducer: FlightReducer
    private let clock: any Clock
    private let uuidGenerator: any UUIDGenerator

    // MARK: - Audit Trail

    /// Hash-chained log of every state transition since initialisation.
    ///
    /// The first entry is always an `initialization` event recording the
    /// initial state hash. Subsequent entries are `accepted` or `rejected`
    /// transitions with `previousEntryHash` set to the preceding entry's
    /// `entryHash`, forming a tamper-evident chain.
    private(set) var auditLog: EventLog<FlightAction>

    // MARK: - State Broadcasting

    /// AsyncStream that yields the latest `FlightState` after every `dispatch`.
    ///
    /// SwiftUI views subscribe with `for await state in orchestrator.stateStream()`.
    private let stream: AsyncStream<FlightState>
    private let continuation: AsyncStream<FlightState>.Continuation

    // MARK: - Initialiser

    /// Creates a `FlightOrchestrator` with the given initial state and dependencies.
    ///
    /// - Parameters:
    ///   - initialState: The starting state (defaults to `FlightState.initial`).
    ///   - reducer: The pure reducer function (defaults to `FlightReducer()`).
    ///   - clock: Provides wall-clock timestamps for audit events.
    ///   - uuidGenerator: Provides unique IDs for audit events.
    init(
        initialState: FlightState = .initial,
        reducer: FlightReducer = FlightReducer(),
        clock: any Clock = SystemClock(),
        uuidGenerator: any UUIDGenerator = SystemUUIDGenerator()
    ) {
        (stream, continuation) = AsyncStream.makeStream()
        self.state = initialState
        self.reducer = reducer
        self.clock = clock
        self.uuidGenerator = uuidGenerator
        self.auditLog = EventLog()

        // Record the initialization event as the first hash-chain entry.
        auditLog.append(.initialization(
            id: uuidGenerator.next(),
            timestamp: clock.now(),
            initialStateHash: initialState.stateHash()
        ))

        // Yield the initial state so subscribers receive it immediately.
        continuation.yield(initialState)
    }

    // MARK: - Public Interface

    /// Returns the AsyncStream of state updates for UI subscription.
    nonisolated func stateStream() -> AsyncStream<FlightState> {
        stream
    }

    /// Dispatches a `FlightAction` through the reducer and records the
    /// transition in the audit log.
    ///
    /// This is the **only** way state can change. The reducer is a pure function;
    /// the result is either `.accepted` (state changes) or `.rejected` (state
    /// unchanged). Both outcomes are logged.
    ///
    /// - Parameters:
    ///   - action: The action to dispatch.
    ///   - agentID: The source of the action (e.g. `"UI"`, `"ThermalAgent"`,
    ///     `"TestHarness"`). Used for source attribution in the audit log.
    /// - Returns: The `ReducerResult` so callers can inspect `applied` and
    ///   `rationale` without re-reading the audit log.
    @discardableResult
    func dispatch(_ action: FlightAction, agentID: String) -> ReducerResult<FlightState> {
        let hashBefore = state.stateHash()
        let result = reducer.reduce(state: state, action: action)
        state = result.newState
        let hashAfter = state.stateHash()
        let previousHash = auditLog.lastEntryHash

        if result.applied {
            auditLog.append(.accepted(
                id: uuidGenerator.next(),
                timestamp: clock.now(),
                action: action,
                agentID: agentID,
                stateHashBefore: hashBefore,
                stateHashAfter: hashAfter,
                rationale: result.rationale,
                previousEntryHash: previousHash
            ))
        } else {
            auditLog.append(.rejected(
                id: uuidGenerator.next(),
                timestamp: clock.now(),
                action: action,
                agentID: agentID,
                stateHash: hashBefore,
                rationale: result.rationale,
                previousEntryHash: previousHash
            ))
        }

        continuation.yield(state)
        return result
    }

    /// Returns the current state snapshot (synchronous read within actor).
    ///
    /// Use this from within the actor or from tests. UI code should prefer
    /// `stateStream()` to receive updates reactively.
    func currentState() -> FlightState {
        state
    }

    /// Returns a copy of the current audit log.
    ///
    /// The returned log is a value-type snapshot; it will not reflect future
    /// dispatches. Use `auditLog.verify()` to validate the hash chain.
    func getAuditLog() -> EventLog<FlightAction> {
        auditLog
    }

    // MARK: - Replay

    /// Replays all accepted actions from `log` against a fresh
    /// `FlightState.initial` and verifies the final state hash.
    ///
    /// This method proves the reducer is deterministic: if the same sequence of
    /// accepted actions always produces the same final state, the system is
    /// replayable and tamper-evident.
    ///
    /// - Parameter log: The `EventLog` to replay. Typically the log returned by
    ///   `getAuditLog()` from a previous session.
    /// - Returns: A `ReplayResult` describing whether replay succeeded and
    ///   what the final state was.
    func replay(log: EventLog<FlightAction>) -> ReplayResult {
        // First verify the hash chain itself is intact.
        let chainVerification = log.verify()
        guard chainVerification.isValid else {
            return ReplayResult(
                succeeded: false,
                finalState: .initial,
                expectedHash: log.currentStateHash ?? "",
                actualHash: FlightState.initial.stateHash(),
                failureReason: "hash chain verification failed: \(chainVerification.failureReason ?? "unknown")"
            )
        }

        // Re-execute all accepted actions from the log against a clean initial state.
        let acceptedActions = log.acceptedActions()
        var replayState = FlightState.initial

        for (action, _) in acceptedActions {
            let result = reducer.reduce(state: replayState, action: action)
            replayState = result.newState
        }

        let actualHash = replayState.stateHash()
        let expectedHash = log.currentStateHash ?? replayState.stateHash()
        let succeeded = actualHash == expectedHash

        return ReplayResult(
            succeeded: succeeded,
            finalState: replayState,
            expectedHash: expectedHash,
            actualHash: actualHash,
            failureReason: succeeded ? nil : "state hash mismatch after replay"
        )
    }

    deinit {
        continuation.finish()
    }
}

// MARK: - ReplayResult

/// The outcome of a `FlightOrchestrator.replay(log:)` call.
///
/// A `succeeded == true` result means the reducer is deterministic over the
/// replayed action sequence: the same inputs always produce the same final
/// state hash.
struct ReplayResult: Equatable, Sendable {

    /// Whether replay produced a state hash matching the log's `currentStateHash`.
    let succeeded: Bool

    /// The final `FlightState` produced by replaying all accepted actions.
    let finalState: FlightState

    /// The state hash the log expected at the end of replay.
    let expectedHash: String

    /// The state hash actually produced by replay.
    let actualHash: String

    /// Human-readable description of the failure, or `nil` if replay succeeded.
    let failureReason: String?
}
