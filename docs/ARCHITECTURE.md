# Flightworks Suite Architecture

## Overview

Flightworks Control implements the SwiftVector architectural patternâ€”deterministic control around stochastic systems. This document describes the core architecture, design decisions, and extension patterns for edge AI integration.

**Key Architectural Principles:**

1. **State is truth** â€” All system state is explicit, typed, and immutable
2. **Actions are proposals** â€” Nothing changes state directly; all changes are validated
3. **Reducers are authority** â€” Only pure functions can produce new state
4. **Agents propose, don't command** â€” AI provides recommendations, operators decide
5. **Everything is auditable** â€” Full logging enables replay and incident investigation

---

## Jurisdiction Architecture

The Flightworks Suite uses a **jurisdiction model** where mission-specific applications inherit universal safety guarantees from FlightLaw while adding domain-specific governance.

### Jurisdiction Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│              SWIFTVECTOR CODEX                              │
│         (Constitutional Framework)                          │
│  Laws 0-10: Boundary, Context, Delegation, Observation,    │
│  Resource, Sovereignty, Persistence, Spatial, Authority,    │
│  Lifecycle, Protocol                                        │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              FLIGHTLAW (Universal Safety Kernel)            │
│  • Law 3 (Observation): Telemetry, pre-flight validation   │
│  • Law 4 (Resource): Battery, thermal limits               │
│  • Law 7 (Spatial): Geofencing, altitude limits            │
│  • Law 8 (Authority): Risk-tiered operator approval        │
│  • Audit trail with SHA256 hash chain                      │
│  • Deterministic replay capability                         │
└─────────────────────────────────────────────────────────────┘
         │                              │
         ▼                              ▼
┌──────────────────┐          ┌──────────────────┐
│   THERMALLAW     │          │    SURVEYLAW     │
│                  │          │                  │
│ • RGB/Thermal    │          │ • RTK precision  │
│   detection      │          │   enforcement    │
│ • Roof damage    │          │ • Grid adherence │
│   classification │          │   validation     │
│ • Severity bands │          │ • GSD compliance │
│ • Operator       │          │   verification   │
│   approval       │          │ • Gap detection  │
│                  │          │ • Overlap calc.  │
│ Platform: M4T    │          │ Platform: M4E    │
│ Use: Inspection  │          │ Use: Surveying   │
└──────────────────┘          └──────────────────┘
```

### Jurisdiction Composition Principle

**FlightLaw provides universal guarantees:**
- ✅ Battery reserve enforcement (RTL at 20%)
- ✅ Geofence violation prevention
- ✅ Pre-flight readiness validation
- ✅ Tamper-evident audit trail
- ✅ Deterministic replay

**Domain jurisdictions extend FlightLaw:**
- **ThermalLaw** = FlightLaw + thermal-specific governance
  - Inherits all FlightLaw safety constraints
  - Adds: Candidate classification, severity banding, approval workflow
  
- **SurveyLaw** = FlightLaw + survey-specific governance
  - Inherits all FlightLaw safety constraints
  - Adds: RTK precision requirements, grid validation, GSD enforcement

**Business Guarantees:**
- ThermalLaw: *"No critical damage will be missed or hallucinated"*
- SurveyLaw: *"100% adherence to engineering-grade spatial grids"*

### Jurisdiction Benefits

| Benefit | Description |
|---------|-------------|
| **Code Reuse** | Safety logic written once in FlightLaw, inherited everywhere |
| **Consistency** | Identical safety behavior across all jurisdictions |
| **Modularity** | Add new jurisdictions without modifying FlightLaw |
| **Certifiability** | Prove safety properties once, apply to all jurisdictions |

---


## Core Pattern: SwiftVector

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                      Orchestrator                           â”‚
â”‚                 (Coordinates control loop)                  â”‚
â”‚          â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”                â”‚
â”‚          â”‚  â€¢ Maintains current state      â”‚                â”‚
â”‚          â”‚  â€¢ Validates action proposals   â”‚                â”‚
â”‚          â”‚  â€¢ Dispatches to reducers       â”‚                â”‚
â”‚          â”‚  â€¢ Triggers side effects        â”‚                â”‚
â”‚          â”‚  â€¢ Maintains audit log          â”‚                â”‚
â”‚          â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜                â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                              â”‚
         â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
         â–¼                    â–¼                    â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”      â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”      â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚    State    â”‚â—€â”€â”€â”€â”€â”€â”‚   Reducer   â”‚â—€â”€â”€â”€â”€â”€â”‚   Action    â”‚
â”‚ (Immutable) â”‚      â”‚(Pure Func)  â”‚      â”‚  (Typed)    â”‚
â”‚             â”‚      â”‚             â”‚      â”‚             â”‚
â”‚ â€¢ Equatable â”‚      â”‚ â€¢ No side   â”‚      â”‚ â€¢ Enum with â”‚
â”‚ â€¢ Codable   â”‚      â”‚   effects   â”‚      â”‚   assoc.    â”‚
â”‚ â€¢ Sendable  â”‚      â”‚ â€¢ Total     â”‚      â”‚   values    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜      â”‚ â€¢ Safe      â”‚      â”‚ â€¢ Codable   â”‚
         â”‚           â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜      â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â”‚                                       â–²
         â”‚         â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
         â–¼         â”‚
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                         Agents                              â”‚
â”‚              (Observe state, propose actions)               â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚    Risk     â”‚  â”‚   Battery   â”‚  â”‚      Thermal        â”‚  â”‚
â”‚  â”‚  Assessment â”‚  â”‚  Prediction â”‚  â”‚  Anomaly Detection  â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### State

State is the single source of truth. All state is:

- **Immutable** â€” State objects are never modified, only replaced
- **Typed** â€” Swift structs with explicit types
- **Codable** â€” Serializable for persistence and replay
- **Equatable** â€” Comparable for change detection
- **Sendable** â€” Safe to pass across concurrency boundaries

```swift
struct FlightState: Equatable, Codable, Sendable {
    // Connection
    let connectionStatus: ConnectionStatus
    
    // Flight data
    let telemetry: TelemetryData?
    let flightMode: FlightMode
    let armingState: ArmingState
    let position: Position?
    let attitude: Attitude?
    let battery: BatteryState?
    let gpsInfo: GPSInfo?
    
    // Mission
    let activeMission: Mission?
    let activeGeofence: Geofence?
    
    // Extension point for thermal inspection
    let thermalState: ThermalState?
    
    // Metadata
    let timestamp: Date
}
```

**State Composition Pattern:**

For complex applications, state can be composed from domain-specific substates:

```swift
struct AppState: Equatable, Codable, Sendable {
    let flight: FlightState
    let mission: MissionState
    let thermal: ThermalState?
    let system: SystemState
}
```

### Actions

Actions describe proposed state changes. All actions are:

- **Typed** â€” Enum cases with associated values
- **Codable** â€” Serializable for audit trail
- **Equatable** â€” Comparable for testing
- **Sendable** â€” Safe for concurrent dispatch

```swift
enum FlightAction: Equatable, Codable, Sendable {
    // Connection
    case connect(connectionConfig: ConnectionConfig)
    case disconnect
    case connectionStatusChanged(ConnectionStatus)
    
    // Telemetry
    case telemetryReceived(TelemetryData)
    
    // Arming
    case arm
    case disarm
    
    // Flight control
    case takeoff(altitude: Double)
    case land
    case returnToLaunch
    case setFlightMode(FlightMode)
    
    // Mission
    case loadMission(Mission)
    case startMission
    case pauseMission
    case clearMission
    
    // Composed actions from other domains
    case thermal(ThermalAction)
    case mission(MissionAction)
}
```

**Action Composition Pattern:**

Domain-specific actions can be nested within a root action type:

```swift
// Domain-specific actions
enum ThermalAction: Equatable, Codable, Sendable {
    case frameReceived(ThermalFrameMetadata)
    case inferenceCompleted(ThermalInferenceResult)
    case anomalyFlagged(anomalyId: UUID)
    // ...
}

// Composed into root action
enum AppAction: Equatable, Codable, Sendable {
    case flight(FlightAction)
    case thermal(ThermalAction)
    case mission(MissionAction)
}
```

### Reducers

Reducers apply actions to state. All reducers are:

- **Pure functions** â€” No side effects
- **Deterministic** â€” Same inputs always produce same outputs
- **Total** â€” Handle all action types
- **Safe** â€” Invalid actions return unchanged state

```swift
struct FlightReducer {
    
    /// Pure function: (State, Action) -> State
    static func reduce(state: FlightState, action: FlightAction) -> FlightState {
        switch action {
            
        case .connectionStatusChanged(let status):
            return state.with(connectionStatus: status)
            
        case .telemetryReceived(let telemetry):
            return state.with(
                telemetry: telemetry,
                position: telemetry.position,
                attitude: telemetry.attitude,
                battery: telemetry.battery,
                gpsInfo: telemetry.gpsInfo,
                timestamp: telemetry.timestamp
            )
            
        case .arm:
            // Precondition check - invalid action returns unchanged state
            guard canArm(state: state) else { return state }
            return state.with(armingState: .armed)
            
        case .disarm:
            guard canDisarm(state: state) else { return state }
            return state.with(armingState: .disarmed)
            
        case .takeoff(let altitude):
            guard canTakeoff(state: state) else { return state }
            return state.with(
                flightMode: .takingOff,
                targetAltitude: altitude
            )
            
        case .land:
            guard canLand(state: state) else { return state }
            return state.with(flightMode: .landing)
            
        case .returnToLaunch:
            return state.with(flightMode: .returningToLaunch)
            
        case .setFlightMode(let mode):
            guard canSetFlightMode(mode, state: state) else { return state }
            return state.with(flightMode: mode)
            
        case .thermal(let thermalAction):
            // Delegate to domain-specific reducer
            let newThermalState = ThermalReducer.reduce(
                state: state.thermalState ?? .initial,
                action: thermalAction
            )
            return state.with(thermalState: newThermalState)
            
        // ... other cases
        }
    }
    
    // MARK: - Precondition Checks (Pure Functions)
    
    private static func canArm(state: FlightState) -> Bool {
        state.connectionStatus == .connected &&
        state.armingState == .disarmed &&
        state.gpsInfo?.fixType == .fix3D &&
        (state.battery?.percentage ?? 0) > 20
    }
    
    private static func canDisarm(state: FlightState) -> Bool {
        state.armingState == .armed &&
        state.flightMode != .flying
    }
    
    private static func canTakeoff(state: FlightState) -> Bool {
        state.armingState == .armed &&
        state.flightMode == .idle
    }
    
    private static func canLand(state: FlightState) -> Bool {
        state.flightMode == .flying ||
        state.flightMode == .hovering
    }
    
    private static func canSetFlightMode(_ mode: FlightMode, state: FlightState) -> Bool {
        // Mode transition rules
        switch (state.flightMode, mode) {
        case (.takingOff, _): return false  // Cannot change during takeoff
        case (.landing, _): return false     // Cannot change during landing
        default: return true
        }
    }
}
```

**Reducer Composition Pattern:**

Complex reducers can delegate to domain-specific reducers:

```swift
struct AppReducer {
    static func reduce(state: AppState, action: AppAction) -> AppState {
        switch action {
        case .flight(let flightAction):
            return state.with(
                flight: FlightReducer.reduce(state: state.flight, action: flightAction)
            )
        case .thermal(let thermalAction):
            return state.with(
                thermal: ThermalReducer.reduce(state: state.thermal, action: thermalAction)
            )
        case .mission(let missionAction):
            return state.with(
                mission: MissionReducer.reduce(state: state.mission, action: missionAction)
            )
        }
    }
}
```

### Orchestrator

The Orchestrator coordinates the control loop:

```swift
@MainActor
final class FlightOrchestrator: ObservableObject {
    
    // MARK: - Published State
    
    @Published private(set) var state: FlightState
    
    // MARK: - Audit Trail
    
    private var actionLog: [LoggedAction] = []
    
    struct LoggedAction: Codable {
        let id: UUID
        let timestamp: Date
        let action: FlightAction
        let previousStateHash: String
        let newStateHash: String
        let source: ActionSource
    }
    
    enum ActionSource: String, Codable {
        case ui
        case telemetry
        case agent
        case system
    }
    
    // MARK: - Initialization
    
    init(initialState: FlightState = .initial) {
        self.state = initialState
    }
    
    // MARK: - Action Dispatch
    
    func dispatch(_ action: FlightAction, source: ActionSource = .ui) {
        let previousState = state
        let newState = FlightReducer.reduce(state: state, action: action)
        
        // Log action with state hashes for verification
        let logEntry = LoggedAction(
            id: UUID(),
            timestamp: Date(),
            action: action,
            previousStateHash: previousState.stableHash,
            newStateHash: newState.stableHash,
            source: source
        )
        actionLog.append(logEntry)
        
        // Update state (triggers UI updates via @Published)
        state = newState
        
        // Trigger side effects if state changed
        if previousState != newState {
            handleStateTransition(from: previousState, to: newState, action: action)
        }
    }
    
    // MARK: - Side Effects
    
    private func handleStateTransition(
        from previousState: FlightState,
        to newState: FlightState,
        action: FlightAction
    ) {
        // Side effects are handled here, outside the pure reducer
        // Examples: sending MAVLink commands, triggering notifications
        
        switch action {
        case .arm:
            // Send arm command to vehicle
            Task { await sendArmCommand() }
            
        case .takeoff(let altitude):
            // Send takeoff command to vehicle
            Task { await sendTakeoffCommand(altitude: altitude) }
            
        default:
            break
        }
    }
    
    // MARK: - Replay Support
    
    func replay(actions: [FlightAction]) -> FlightState {
        var replayState = FlightState.initial
        for action in actions {
            replayState = FlightReducer.reduce(state: replayState, action: action)
        }
        return replayState
    }
    
    func exportActionLog() -> Data? {
        try? JSONEncoder().encode(actionLog)
    }
}
```

---

## Component Architecture

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                              App                                     â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                              UI Layer                                â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â” â”‚
â”‚  â”‚  Map View   â”‚  â”‚  Telemetry  â”‚  â”‚   Mission   â”‚  â”‚   Thermal   â”‚ â”‚
â”‚  â”‚             â”‚  â”‚   Display   â”‚  â”‚   Planning  â”‚  â”‚   Overlay   â”‚ â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜  â””â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”˜ â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚         â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”´â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜        â”‚
â”‚                                   â”‚                                  â”‚
â”‚                                   â–¼                                  â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚                        Orchestrator                            â”‚  â”‚
â”‚  â”‚              (State management, action dispatch)               â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â”‚                                   â”‚                                  â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                    Decision Layer â”‚                                  â”‚
â”‚         â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¼â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”       â”‚
â”‚         â–¼                         â–¼                         â–¼       â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”          â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”          â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚   Flight    â”‚          â”‚   Mission   â”‚          â”‚   Thermal   â”‚  â”‚
â”‚  â”‚   Reducer   â”‚          â”‚   Reducer   â”‚          â”‚   Reducer   â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜          â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜          â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â”‚         â”‚                         â”‚                         â”‚       â”‚
â”‚         â–¼                         â–¼                         â–¼       â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”          â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”          â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚   Safety    â”‚          â”‚  Geofence   â”‚          â”‚   Thermal   â”‚  â”‚
â”‚  â”‚  Validator  â”‚          â”‚  Validator  â”‚          â”‚    Agent    â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜          â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜          â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â”‚                                                                      â”‚
â”œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¤
â”‚                           Telemetry Layer                            â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚                   DroneConnectionManager                       â”‚  â”‚
â”‚  â”‚              (MAVLink, MAVSDK-Swift - Phase 1+)               â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚                   ThermalCameraManager                         â”‚  â”‚
â”‚  â”‚                (FLIR SDK, DJI SDK - Phase 5)                  â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

## Design Decisions

### Why Immutable State?

| Benefit | Explanation |
|---------|-------------|
| **Thread safety** | Immutable data is inherently safe to share across threads |
| **Change detection** | Simple equality comparison (`==`) determines if state changed |
| **Time travel** | Previous states are preserved, enabling replay and debugging |
| **Predictability** | No hidden mutations; state changes are explicit |

### Why Typed Actions?

| Benefit | Explanation |
|---------|-------------|
| **Exhaustive handling** | Compiler ensures all action cases are handled |
| **Serialization** | Actions can be logged, persisted, and replayed |
| **Testing** | Actions are data; easily constructed in tests |
| **Documentation** | Action enum is self-documenting API |

### Why Pure Reducers?

| Benefit | Explanation |
|---------|-------------|
| **Testability** | No mocks needed; just call function with inputs |
| **Determinism** | Essential for certification and audit |
| **Replay** | Same actions always replay to same state |
| **Reasoning** | Easier to understand system behavior |

### Why Actor-Based Orchestration?

| Benefit | Explanation |
|---------|-------------|
| **Concurrency safety** | Swift actors prevent data races |
| **Main actor UI** | State changes automatically on main thread |
| **Isolation** | Clear boundaries between components |
| **Future-proof** | Ready for multi-agent scenarios |

---

## Safety Architecture

### Validation Layers

```
Action Proposed
       â”‚
       â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Type Validation    â”‚ â† Compile-time (Swift type system)
â”‚  â€¢ Enum exhaustive  â”‚
â”‚  â€¢ Associated types â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
           â”‚
           â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  State Validation   â”‚ â† Runtime (precondition checks in reducer)
â”‚  â€¢ Preconditions    â”‚
â”‚  â€¢ Mode transitions â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
           â”‚
           â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Safety Validation  â”‚ â† Runtime (SafetyValidator)
â”‚  â€¢ Geofence checks  â”‚
â”‚  â€¢ Battery limits   â”‚
â”‚  â€¢ Airspace rules   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”¬â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
           â”‚
           â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚  Action Applied     â”‚
â”‚  â€¢ State updated    â”‚
â”‚  â€¢ Audit logged     â”‚
â”‚  â€¢ Effects triggeredâ”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Safety Invariants

These invariants must always hold:

| Invariant | Enforcement |
|-----------|-------------|
| Cannot arm without GPS 3D fix | `canArm()` precondition |
| Cannot takeoff without armed state | `canTakeoff()` precondition |
| Cannot enter mission mode without valid mission | `canStartMission()` precondition |
| Geofence violations prevent arming | `SafetyValidator.canArm()` |
| Low battery triggers RTL warning | `BatteryMonitor.checkThresholds()` |
| Cannot change mode during takeoff/landing | `canSetFlightMode()` precondition |

### Fail-Safe Behavior

When the system encounters uncertainty:

1. **Default to safest action** â€” When in doubt, don't act
2. **Alert operator** â€” Clear visual and audio notification
3. **Log decision reasoning** â€” Full context for post-incident review
4. **Never fail silently** â€” All failures are observable

```swift
enum SafetyResponse: Equatable {
    case allow
    case deny(reason: String, severity: Severity)
    case warn(message: String, allowOverride: Bool)
    
    enum Severity: String {
        case critical   // Immediate danger
        case warning    // Potential issue
        case advisory   // Informational
    }
}
```

---

## Agent Integration

### Agent Protocol

Agents observe state and propose actions within strict boundaries:

```swift
/// Protocol for AI decision support agents
protocol Agent: Actor {
    /// Agent identifier for logging
    var id: String { get }
    
    /// Observe current state (called by orchestrator)
    func observe(state: FlightState) async
    
    /// Propose actions based on observed state
    func propose() async -> [AgentProposal]
    
    /// Current assessment/status for UI display
    func currentAssessment() async -> AgentAssessment
}

struct AgentProposal: Equatable, Sendable {
    let action: FlightAction
    let confidence: Double          // 0.0 - 1.0
    let explanation: String         // Human-readable reasoning
    let priority: Priority
    
    enum Priority: Int, Comparable {
        case low = 0
        case medium = 1
        case high = 2
        case critical = 3
    }
}

struct AgentAssessment: Equatable, Sendable {
    let status: Status
    let summary: String
    let confidence: Double
    let details: [String: String]
    
    enum Status: String {
        case nominal
        case advisory
        case warning
        case critical
    }
}
```

### Agent Execution Flow

```swift
// Orchestrator coordinates agent execution
extension FlightOrchestrator {
    
    func processAgentProposals() async {
        for agent in registeredAgents {
            // Agent observes current state
            await agent.observe(state: state)
            
            // Agent proposes actions
            let proposals = await agent.propose()
            
            for proposal in proposals {
                // Safety validation
                let safetyResult = safetyValidator.validate(
                    action: proposal.action,
                    state: state
                )
                
                switch safetyResult {
                case .allow:
                    // Log agent proposal before dispatch
                    logAgentProposal(proposal, from: agent)
                    dispatch(proposal.action, source: .agent)
                    
                case .deny(let reason, _):
                    logRejectedProposal(proposal, from: agent, reason: reason)
                    
                case .warn(let message, let allowOverride):
                    // Present to operator for decision
                    await presentWarningToOperator(
                        proposal: proposal,
                        warning: message,
                        allowOverride: allowOverride
                    )
                }
            }
        }
    }
}
```

### Agent Constraints

Agents can reason freely but **cannot**:

- âŒ Mutate state directly
- âŒ Bypass reducer
- âŒ Override safety validation
- âŒ Execute without logging
- âŒ Access external resources during proposal

Agents **can**:

- âœ… Observe complete state snapshot
- âœ… Propose any valid action type
- âœ… Provide confidence scores
- âœ… Explain reasoning
- âœ… Request operator attention

---

## Edge AI Extension Architecture

### The Determinism Boundary

Edge AI integration presents a challenge: ML models produce probabilistic outputs, but safety-critical systems require deterministic behavior. SwiftVector solves this by establishing a clear **determinism boundary**:

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    STOCHASTIC ZONE                                   â”‚
â”‚                  (Probabilistic, variable)                          â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚                    ML Model Inference                          â”‚  â”‚
â”‚  â”‚  â€¢ Neural network forward pass                                 â”‚  â”‚
â”‚  â”‚  â€¢ Probabilistic outputs                                       â”‚  â”‚
â”‚  â”‚  â€¢ May vary slightly between runs (GPU non-determinism)       â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                                â”‚
                                â–¼
â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
                      DETERMINISM BOUNDARY
               (Fixed thresholds, explicit rules)
â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
                                â”‚
                                â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    DETERMINISTIC ZONE                                â”‚
â”‚                  (Reproducible, auditable)                          â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚              Deterministic Post-Processing                     â”‚  â”‚
â”‚  â”‚  â€¢ Fixed threshold classification                              â”‚  â”‚
â”‚  â”‚  â€¢ Explicit confidence banding                                 â”‚  â”‚
â”‚  â”‚  â€¢ Rule-based type assignment                                  â”‚  â”‚
â”‚  â”‚  â€¢ Typed action proposal generation                            â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â”‚                                â”‚                                     â”‚
â”‚                                â–¼                                     â”‚
â”‚  â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”  â”‚
â”‚  â”‚                    SwiftVector Layer                           â”‚  â”‚
â”‚  â”‚  â€¢ Reducer validates and applies                               â”‚  â”‚
â”‚  â”‚  â€¢ Full audit trail                                            â”‚  â”‚
â”‚  â”‚  â€¢ Deterministic replay                                        â”‚  â”‚
â”‚  â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜  â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Core ML Determinism Configuration

To maximize ML inference determinism:

```swift
/// Configure Core ML for deterministic inference
func createDeterministicMLConfig() -> MLModelConfiguration {
    let config = MLModelConfiguration()
    
    // CPU and Neural Engine are more deterministic than GPU
    // GPU parallel execution can introduce subtle variations
    config.computeUnits = .cpuAndNeuralEngine
    
    return config
}
```

### Thermal Inspection Integration Example

The thermal inspection extension demonstrates this pattern:

```swift
/// Deterministic classification of ML outputs
struct ThermalClassifier {
    
    // Fixed thresholds (not learned, not variable)
    static let highConfidenceThreshold = 0.85
    static let mediumConfidenceThreshold = 0.70
    static let detectionThreshold = 0.50
    
    /// Pure function: ML output â†’ Classification
    static func classify(_ output: ThermalMLOutput) -> ThermalClassification? {
        // Below detection threshold: no classification
        guard output.anomalyProbability >= detectionThreshold else {
            return nil
        }
        
        // Deterministic confidence banding
        let confidence: ConfidenceLevel = switch output.anomalyProbability {
            case highConfidenceThreshold...: .high
            case mediumConfidenceThreshold..<highConfidenceThreshold: .medium
            default: .low
        }
        
        // Deterministic type assignment based on temperature
        let anomalyType = classifyType(
            temperature: output.peakTemperature,
            delta: output.temperatureDelta
        )
        
        return ThermalClassification(
            type: anomalyType,
            confidence: confidence,
            boundingBox: output.boundingBox,
            explanation: generateExplanation(output, anomalyType, confidence)
        )
    }
    
    /// Pure function: temperature characteristics â†’ anomaly type
    private static func classifyType(
        temperature: Double,
        delta: Double
    ) -> AnomalyType {
        switch (temperature, delta) {
        case (80..., 30...): return .electricalHotspot
        case (40..., 10...): return .insulationDefect
        case (..<30, 5...):  return .moistureIntrusion
        default:             return .thermalAnomaly
        }
    }
}
```

### Extension Pattern for Other ML Applications

This pattern applies to any edge AI integration:

1. **Isolate ML inference** in dedicated component
2. **Define fixed thresholds** for classification boundaries
3. **Implement post-processing as pure functions**
4. **Generate typed actions** from classifications
5. **Route through reducer** for validation and logging

```swift
// Generic pattern for ML-to-Action pipeline
protocol MLActionPipeline {
    associatedtype MLOutput
    associatedtype Classification
    associatedtype Action
    
    /// ML inference (potentially non-deterministic)
    func infer(input: Input) async throws -> MLOutput
    
    /// Deterministic classification (pure function)
    func classify(_ output: MLOutput) -> Classification?
    
    /// Action generation (pure function)
    func generateAction(_ classification: Classification) -> Action
}
```

---

## File Organization

```
FlightworksControl/
â”œâ”€â”€ App/
â”‚   â””â”€â”€ FlightworksControlApp.swift
â”‚
â”œâ”€â”€ Core/                           â† SwiftVector implementation
â”‚   â”œâ”€â”€ State/
â”‚   â”‚   â”œâ”€â”€ FlightState.swift
â”‚   â”‚   â”œâ”€â”€ MissionState.swift
â”‚   â”‚   â”œâ”€â”€ ThermalState.swift      â† Extension state
â”‚   â”‚   â””â”€â”€ SystemState.swift
â”‚   â”œâ”€â”€ Actions/
â”‚   â”‚   â”œâ”€â”€ FlightAction.swift
â”‚   â”‚   â”œâ”€â”€ MissionAction.swift
â”‚   â”‚   â”œâ”€â”€ ThermalAction.swift     â† Extension actions
â”‚   â”‚   â””â”€â”€ Action.swift            â† Protocol
â”‚   â”œâ”€â”€ Reducers/
â”‚   â”‚   â”œâ”€â”€ FlightReducer.swift
â”‚   â”‚   â”œâ”€â”€ MissionReducer.swift
â”‚   â”‚   â”œâ”€â”€ ThermalReducer.swift    â† Extension reducer
â”‚   â”‚   â””â”€â”€ Reducer.swift           â† Protocol
â”‚   â””â”€â”€ Orchestrator/
â”‚       â””â”€â”€ FlightOrchestrator.swift
â”‚
â”œâ”€â”€ Telemetry/                      â† MAVLink integration
â”‚   â”œâ”€â”€ MAVLinkConnection.swift
â”‚   â”œâ”€â”€ TelemetryStream.swift
â”‚   â””â”€â”€ DroneConnectionManager.swift
â”‚
â”œâ”€â”€ UI/                             â† SwiftUI views
â”‚   â”œâ”€â”€ Components/
â”‚   â”œâ”€â”€ Screens/
â”‚   â”œâ”€â”€ Map/
â”‚   â””â”€â”€ Thermal/                    â† Extension UI
â”‚
â”œâ”€â”€ Safety/                         â† Validation and interlocks
â”‚   â”œâ”€â”€ SafetyValidator.swift
â”‚   â”œâ”€â”€ GeofenceValidator.swift
â”‚   â”œâ”€â”€ BatteryMonitor.swift
â”‚   â””â”€â”€ StateInterlocks.swift
â”‚
â”œâ”€â”€ Agents/                         â† AI decision support
â”‚   â”œâ”€â”€ AgentProtocol.swift
â”‚   â”œâ”€â”€ RiskAssessmentAgent.swift
â”‚   â”œâ”€â”€ BatteryPredictionAgent.swift
â”‚   â””â”€â”€ ThermalAnomalyAgent.swift   â† Extension agent
â”‚
â””â”€â”€ ML/                             â† Machine learning
    â”œâ”€â”€ ThermalModel.mlmodel
    â”œâ”€â”€ DeterministicMLConfig.swift
    â””â”€â”€ ThermalClassifier.swift     â† Deterministic post-processing
```
- ~~[THERMAL_INSPECTION_EXTENSION.md](THERMAL_INSPECTION_EXTENSION.md)~~ (See HLD-FlightworksThermal.md)
---

## Performance Considerations

### Real-Time Requirements

| Component | Latency Target | Rationale |
|-----------|----------------|-----------|
| Telemetry processing | < 50ms | Situational awareness |
| UI updates | < 16ms | 60fps rendering |
| ML inference | < 100ms | Real-time detection |
| State transition | < 10ms | Responsive control |

### Memory Management

- State snapshots use copy-on-write semantics
- Action log implements circular buffer for bounded memory
- ML models loaded once at startup
- Thermal frames processed in streaming fashion

### Threading Model

```
Main Actor (UI Thread)
â”œâ”€â”€ Orchestrator
â”œâ”€â”€ State updates
â””â”€â”€ UI rendering

Background Actors
â”œâ”€â”€ TelemetryStream (dedicated)
â”œâ”€â”€ MLInference (dedicated)
â””â”€â”€ Agents (pooled)
```

---

## Testing Architecture

### Determinism Verification

```swift
// Property: Same inputs â†’ Same outputs (always)
func testReducerDeterminism() {
    let testCases = generateRandomStateActionPairs(count: 1000)
    
    for (state, action) in testCases {
        let result1 = FlightReducer.reduce(state: state, action: action)
        let result2 = FlightReducer.reduce(state: state, action: action)
        
        XCTAssertEqual(result1, result2)
    }
}
```

### Replay Verification

```swift
// Property: Replayed actions produce identical final state
func testReplayDeterminism() {
    let recording = loadFlightRecording("test_flight_001")
    
    let replayedState = orchestrator.replay(actions: recording.actions)
    
    XCTAssertEqual(replayedState, recording.finalState)
}
```

See [TESTING_STRATEGY.md](TESTING_STRATEGY.md) for comprehensive testing documentation.

---

## References

- [SwiftVector Whitepaper](https://agentincommand.ai/swiftvector) â€” Deterministic control architecture
- [Swift at the Edge](https://agentincommand.ai/swift-at-the-edge) â€” On-device AI manifesto
- [The Agency Paradox](https://agentincommand.ai/agency-paradox) â€” Human command over AI systems
- [THERMAL_INSPECTION_EXTENSION.md](THERMAL_INSPECTION_EXTENSION.md) â€” Thermal feature specification

---

## Related Documentation

- [ROADMAP.md](ROADMAP.md) â€” Product roadmap
- [SWIFTVECTOR.md](SWIFTVECTOR.md) â€” SwiftVector principles
- [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) â€” Development workflow
- [TESTING_STRATEGY.md](TESTING_STRATEGY.md) â€” Testing approach

---

## Suite Documentation

### Architecture Documents

| Document | Purpose |
|----------|---------|
| [Flightworks-Suite-Overview.md](docs/Flightworks-Suite-Overview.md) | Master suite architecture and jurisdiction model |
| [HLD-FlightworksCore.md](docs/HLD-FlightworksCore.md) | FlightLaw technical architecture |
| [PRD-FlightworksCore.md](docs/PRD-FlightworksCore.md) | FlightLaw requirements |
| [HLD-FlightworksThermal.md](docs/HLD-FlightworksThermal.md) | ThermalLaw technical architecture |
| [PRD-FlightworksThermal.md](docs/PRD-FlightworksThermal.md) | ThermalLaw requirements |
| [HLD-FlightworksSurvey.md](docs/HLD-FlightworksSurvey.md) | SurveyLaw technical architecture |
| [PRD-FlightworksSurvey.md](docs/PRD-FlightworksSurvey.md) | SurveyLaw requirements |

### Archived Documents

The following documents have been superseded by the jurisdiction-based architecture:

| Document | Replaced By | Status |
|----------|-------------|--------|
| HLD-FlightworksControl.md | HLD-FlightworksCore.md + HLD-FlightworksThermal.md | Archived v1 |
| PRD-FlightworksControl.md | PRD-FlightworksCore.md + PRD-FlightworksThermal.md | Archived v1 |
| THERMAL_INSPECTION_EXTENSION.md | HLD-FlightworksThermal.md + PRD-FlightworksThermal.md | Archived v1 |

See `archive/v1-monolithic/` for historical reference.
