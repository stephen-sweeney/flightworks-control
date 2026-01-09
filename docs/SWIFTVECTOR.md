# SwiftVector in Flightworks Control

## What is SwiftVector?

SwiftVector is an architectural pattern for building reliable systems around AI components. The core insight:

> **State, not prompts, must be the authority.**

AI models are stochastic—they produce variable outputs. Applications must be deterministic—the same inputs should produce the same behavior. SwiftVector bridges this gap by placing deterministic control around stochastic intelligence.

## The Core Loop

```
State → Agent → Action → Reducer → New State
```

1. **State** represents complete system truth
2. **Agents** observe state and propose actions
3. **Actions** are typed descriptions of proposed changes
4. **Reducers** validate and apply actions deterministically
5. **New State** becomes the source of truth

## Key Principles

### 1. State is Truth

All system state is explicit, typed, and immutable. There is no hidden state. Every component sees the same truth.

```swift
struct FlightState: Equatable, Codable, Sendable {
    let position: Position?
    let altitude: Double
    let battery: BatteryState
    let flightMode: FlightMode
    // ... complete state
}
```

### 2. Actions are Proposals

Nothing changes state directly. All changes are proposed as typed actions that can be validated, logged, and potentially rejected.

```swift
enum FlightAction: Equatable, Codable {
    case arm
    case takeoff(altitude: Double)
    case moveTo(position: Position)
    case land
}
```

### 3. Reducers are Authority

Only reducers can produce new state. Reducers are pure functions—deterministic, side-effect-free, and testable.

```swift
func reduce(state: FlightState, action: FlightAction) -> FlightState {
    // Validate preconditions
    // Apply change
    // Return new immutable state
}
```

### 4. Agents Propose, Don't Command

When AI agents are introduced (Phase 5), they follow the same pattern. Agents observe state and propose actions, but they cannot:
- Mutate state directly
- Bypass the reducer
- Override safety validation
- Execute without logging

### 5. Everything is Auditable

Every state transition is logged with:
- Timestamp
- Previous state
- Action proposed
- New state
- Source of action (UI, telemetry, agent)

This enables deterministic replay and incident investigation.

## Why This Matters for GCS

Ground Control Stations are safety-critical. They must be:
- **Predictable** — Operators need to trust system behavior
- **Auditable** — Incidents must be reconstructable
- **Certifiable** — Regulatory approval requires determinism
- **Reliable** — Failures must be handled gracefully

SwiftVector provides the architectural foundation for all of these requirements.

## Implementation in Flightworks Control

### State Types

Located in `Core/State/`:
- `FlightState.swift` — Core flight data
- `MissionState.swift` — Mission planning
- `SystemState.swift` — App-level state

### Action Types

Located in `Core/Actions/`:
- `FlightAction.swift` — Flight control actions
- `MissionAction.swift` — Mission planning actions
- `Action.swift` — Protocol and common types

### Reducers

Located in `Core/Reducers/`:
- `FlightReducer.swift` — Flight state transitions
- `MissionReducer.swift` — Mission state transitions
- `Reducer.swift` — Protocol definition

### Orchestrator

Located in `Core/Orchestrator/`:
- `FlightOrchestrator.swift` — Coordinates the control loop

## Learn More

- [SwiftVector Whitepaper](https://agentincommand.ai/swiftvector) — Full technical specification
- [Swift at the Edge](https://agentincommand.ai/swift-at-the-edge) — Why Swift for on-device AI
- [The Agency Paradox](https://agentincommand.ai/agency-paradox) — Human command over AI systems
- [Architecture Documentation](ARCHITECTURE.md) — Detailed system design

