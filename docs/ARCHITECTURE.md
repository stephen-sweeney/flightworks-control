# Flightworks Control Architecture

## Overview

Flightworks Control implements the SwiftVector architectural pattern—deterministic control around stochastic systems. This document describes the core architecture and design decisions.

## Core Pattern: SwiftVector

```
┌─────────────────────────────────────────────────────────────┐
│                      Orchestrator                           │
│                 (Coordinates control loop)                  │
└─────────────────────────────────────────────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         ▼                    ▼                    ▼
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│    State    │◀─────│   Reducer   │◀─────│   Action    │
│ (Immutable) │      │(Pure Func)  │      │  (Typed)    │
└─────────────┘      └─────────────┘      └─────────────┘
         │                                       ▲
         │                                       │
         ▼                                       │
┌─────────────────────────────────────────────────────────────┐
│                         Agents                              │
│              (Observe state, propose actions)               │
│                    (Future: Phase 5)                        │
└─────────────────────────────────────────────────────────────┘
```

### State

State is the single source of truth. All state is:

- **Immutable** — State objects are never modified, only replaced
- **Typed** — Swift structs with explicit types
- **Codable** — Serializable for persistence and replay
- **Equatable** — Comparable for change detection

```swift
struct FlightState: Equatable, Codable, Sendable {
    let connectionStatus: ConnectionStatus
    let telemetry: TelemetryData?
    let flightMode: FlightMode
    let armingState: ArmingState
    let position: Position?
    let attitude: Attitude?
    let battery: BatteryState?
    let gpsInfo: GPSInfo?
    let timestamp: Date
}
```

### Actions

Actions describe proposed state changes. All actions are:

- **Typed** — Enum cases with associated values
- **Codable** — Serializable for audit trail
- **Equatable** — Comparable for testing

```swift
enum FlightAction: Equatable, Codable, Sendable {
    case connect(connectionConfig: ConnectionConfig)
    case disconnect
    case telemetryReceived(TelemetryData)
    case arm
    case disarm
    case takeoff(altitude: Double)
    case land
    case returnToLaunch
    case setFlightMode(FlightMode)
}
```

### Reducers

Reducers apply actions to state. All reducers are:

- **Pure functions** — No side effects
- **Deterministic** — Same inputs always produce same outputs
- **Total** — Handle all action types
- **Safe** — Invalid actions return unchanged state

```swift
struct FlightReducer {
    static func reduce(state: FlightState, action: FlightAction) -> FlightState {
        switch action {
        case .telemetryReceived(let telemetry):
            return state.with(telemetry: telemetry)
        case .arm:
            guard state.canArm else { return state }
            return state.with(armingState: .armed)
        // ... other cases
        }
    }
}
```

### Orchestrator

The Orchestrator coordinates the control loop:

1. Maintains current state
2. Receives actions from UI, telemetry, or agents
3. Validates actions against current state
4. Dispatches valid actions to reducer
5. Triggers effects after state transitions
6. Maintains audit log

```swift
@MainActor
final class FlightOrchestrator: ObservableObject {
    @Published private(set) var state: FlightState
    private var actionLog: [LoggedAction] = []
    
    func dispatch(_ action: FlightAction) {
        let previousState = state
        let newState = FlightReducer.reduce(state: state, action: action)
        
        actionLog.append(LoggedAction(
            timestamp: Date(),
            action: action,
            previousState: previousState,
            newState: newState
        ))
        
        state = newState
    }
}
```

## Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         App                                 │
├─────────────────────────────────────────────────────────────┤
│                         UI                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Map View   │  │  Telemetry  │  │  Mission Planning   │  │
│  │             │  │   Display   │  │                     │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
├─────────┼────────────────┼───────────────────┼──────────────┤
│         └────────────────┼───────────────────┘              │
│                          ▼                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                   Orchestrator                       │    │
│  │         (State management, action dispatch)         │    │
│  └─────────────────────────────────────────────────────┘    │
│                          │                                  │
├──────────────────────────┼──────────────────────────────────┤
│         ┌────────────────┼────────────────┐                 │
│         ▼                ▼                ▼                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐          │
│  │   Flight    │  │   Mission   │  │   Safety    │          │
│  │   Reducer   │  │   Reducer   │  │  Validator  │          │
│  └─────────────┘  └─────────────┘  └─────────────┘          │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│                      Telemetry                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              DroneConnectionManager                  │    │
│  │         (MAVLink, MAVSDK-Swift - Phase 1+)          │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

## Design Decisions

### Why Immutable State?

1. **Thread safety** — Immutable data is inherently safe to share
2. **Change detection** — Simple equality comparison
3. **Time travel** — Previous states preserved for replay
4. **Debugging** — State at any point is inspectable

### Why Typed Actions?

1. **Exhaustive handling** — Compiler ensures all cases handled
2. **Serialization** — Actions can be logged and replayed
3. **Testing** — Actions are data, easily constructed in tests
4. **Documentation** — Action enum is self-documenting API

### Why Pure Reducers?

1. **Testability** — No mocks needed, just call function
2. **Determinism** — Essential for certification
3. **Replay** — Same actions replay to same state
4. **Reasoning** — Easier to understand behavior

### Why Actor-Based Orchestration?

1. **Concurrency safety** — Swift actors prevent data races
2. **Main actor UI** — State changes on main thread for UI
3. **Isolation** — Clear boundaries between components
4. **Future-proof** — Ready for multi-agent scenarios

## Safety Architecture

### Validation Layers

```
Action Proposed
       │
       ▼
┌─────────────────┐
│ Type Validation │ ← Compile-time (Swift type system)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ State Validation│ ← Runtime (precondition checks in reducer)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│Safety Validation│ ← Runtime (SafetyValidator)
└────────┬────────┘
         │
         ▼
   Action Applied
```

### Safety Invariants

Documented invariants that must always hold:

1. Cannot arm without GPS 3D fix
2. Cannot takeoff without armed state
3. Cannot enter mission mode without valid mission
4. Geofence violations prevent arming
5. Low battery triggers automatic RTL warning

### Fail-Safe Behavior

When uncertain:
- Default to safest action
- Alert operator
- Log decision reasoning
- Never fail silently

## Future: Agent Integration (Phase 5)

Agents will follow strict boundaries:

```swift
protocol Agent {
    func observe(state: FlightState) async
    func propose() async -> [FlightAction]
}

// Agents propose, orchestrator validates and applies
let proposals = await agent.propose()
for action in proposals {
    if safetyValidator.isValid(action, given: state) {
        orchestrator.dispatch(action)
    } else {
        log.warning("Agent proposal rejected: \(action)")
    }
}
```

Agents can reason freely but cannot:
- Mutate state directly
- Bypass reducer
- Override safety validation
- Execute without human awareness

## File Organization

```
FlightworksControl/
├── Core/           ← SwiftVector implementation
│   ├── State/      ← Immutable state types
│   ├── Actions/    ← Action enums
│   ├── Reducers/   ← Pure reducer functions
│   └── Orchestrator/ ← Coordination logic
├── Telemetry/      ← MAVLink integration
├── UI/             ← SwiftUI views
├── Safety/         ← Validation and interlocks
└── Agents/         ← AI decision support (Phase 5)
```

## References

- [SwiftVector Whitepaper](https://agentincommand.ai/swiftvector)
- [Swift at the Edge](https://agentincommand.ai/swift-at-the-edge)
- [The Agency Paradox](https://agentincommand.ai/agency-paradox)

