# Flightworks Control Architecture

## Overview

Flightworks Control implements the SwiftVector architectural pattern—deterministic control around stochastic systems. This document describes the core architecture, design decisions, and extension patterns for edge AI integration.

**Key Architectural Principles:**

1. **State is truth** — All system state is explicit, typed, and immutable
2. **Actions are proposals** — Nothing changes state directly; all changes are validated
3. **Reducers are authority** — Only pure functions can produce new state
4. **Agents propose, don't command** — AI provides recommendations, operators decide
5. **Everything is auditable** — Full logging enables replay and incident investigation

---

## Core Pattern: SwiftVector

```
┌─────────────────────────────────────────────────────────────┐
│                      Orchestrator                           │
│                 (Coordinates control loop)                  │
│          ┌─────────────────────────────────┐                │
│          │  • Maintains current state      │                │
│          │  • Validates action proposals   │                │
│          │  • Dispatches to reducers       │                │
│          │  • Triggers side effects        │                │
│          │  • Maintains audit log          │                │
│          └─────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         ▼                    ▼                    ▼
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│    State    │◀─────│   Reducer   │◀─────│   Action    │
│ (Immutable) │      │(Pure Func)  │      │  (Typed)    │
│             │      │             │      │             │
│ • Equatable │      │ • No side   │      │ • Enum with │
│ • Codable   │      │   effects   │      │   assoc.    │
│ • Sendable  │      │ • Total     │      │   values    │
└─────────────┘      │ • Safe      │      │ • Codable   │
         │           └─────────────┘      └─────────────┘
         │                                       ▲
         │         ┌─────────────────────────────┘
         ▼         │
┌─────────────────────────────────────────────────────────────┐
│                         Agents                              │
│              (Observe state, propose actions)               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │    Risk     │  │   Battery   │  │      Thermal        │  │
│  │  Assessment │  │  Prediction │  │  Anomaly Detection  │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### State

State is the single source of truth. All state is:

- **Immutable** — State objects are never modified, only replaced
- **Typed** — Swift structs with explicit types
- **Codable** — Serializable for persistence and replay
- **Equatable** — Comparable for change detection
- **Sendable** — Safe to pass across concurrency boundaries

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

- **Typed** — Enum cases with associated values
- **Codable** — Serializable for audit trail
- **Equatable** — Comparable for testing
- **Sendable** — Safe for concurrent dispatch

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

- **Pure functions** — No side effects
- **Deterministic** — Same inputs always produce same outputs
- **Total** — Handle all action types
- **Safe** — Invalid actions return unchanged state

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
┌─────────────────────────────────────────────────────────────────────┐
│                              App                                     │
├─────────────────────────────────────────────────────────────────────┤
│                              UI Layer                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │  Map View   │  │  Telemetry  │  │   Mission   │  │   Thermal   │ │
│  │             │  │   Display   │  │   Planning  │  │   Overlay   │ │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘ │
├─────────┼────────────────┼────────────────┼────────────────┼────────┤
│         └────────────────┴────────────────┴────────────────┘        │
│                                   │                                  │
│                                   ▼                                  │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                        Orchestrator                            │  │
│  │              (State management, action dispatch)               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                   │                                  │
├───────────────────────────────────┼──────────────────────────────────┤
│                    Decision Layer │                                  │
│         ┌─────────────────────────┼─────────────────────────┐       │
│         ▼                         ▼                         ▼       │
│  ┌─────────────┐          ┌─────────────┐          ┌─────────────┐  │
│  │   Flight    │          │   Mission   │          │   Thermal   │  │
│  │   Reducer   │          │   Reducer   │          │   Reducer   │  │
│  └─────────────┘          └─────────────┘          └─────────────┘  │
│         │                         │                         │       │
│         ▼                         ▼                         ▼       │
│  ┌─────────────┐          ┌─────────────┐          ┌─────────────┐  │
│  │   Safety    │          │  Geofence   │          │   Thermal   │  │
│  │  Validator  │          │  Validator  │          │    Agent    │  │
│  └─────────────┘          └─────────────┘          └─────────────┘  │
│                                                                      │
├─────────────────────────────────────────────────────────────────────┤
│                           Telemetry Layer                            │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                   DroneConnectionManager                       │  │
│  │              (MAVLink, MAVSDK-Swift - Phase 1+)               │  │
│  └───────────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                   ThermalCameraManager                         │  │
│  │                (FLIR SDK, DJI SDK - Phase 5)                  │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
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
       │
       ▼
┌─────────────────────┐
│  Type Validation    │ ← Compile-time (Swift type system)
│  • Enum exhaustive  │
│  • Associated types │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  State Validation   │ ← Runtime (precondition checks in reducer)
│  • Preconditions    │
│  • Mode transitions │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Safety Validation  │ ← Runtime (SafetyValidator)
│  • Geofence checks  │
│  • Battery limits   │
│  • Airspace rules   │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Action Applied     │
│  • State updated    │
│  • Audit logged     │
│  • Effects triggered│
└─────────────────────┘
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

1. **Default to safest action** — When in doubt, don't act
2. **Alert operator** — Clear visual and audio notification
3. **Log decision reasoning** — Full context for post-incident review
4. **Never fail silently** — All failures are observable

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

- ❌ Mutate state directly
- ❌ Bypass reducer
- ❌ Override safety validation
- ❌ Execute without logging
- ❌ Access external resources during proposal

Agents **can**:

- ✅ Observe complete state snapshot
- ✅ Propose any valid action type
- ✅ Provide confidence scores
- ✅ Explain reasoning
- ✅ Request operator attention

---

## Edge AI Extension Architecture

### The Determinism Boundary

Edge AI integration presents a challenge: ML models produce probabilistic outputs, but safety-critical systems require deterministic behavior. SwiftVector solves this by establishing a clear **determinism boundary**:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    STOCHASTIC ZONE                                   │
│                  (Probabilistic, variable)                          │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                    ML Model Inference                          │  │
│  │  • Neural network forward pass                                 │  │
│  │  • Probabilistic outputs                                       │  │
│  │  • May vary slightly between runs (GPU non-determinism)       │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                ▼
════════════════════════════════════════════════════════════════════════
                      DETERMINISM BOUNDARY
               (Fixed thresholds, explicit rules)
════════════════════════════════════════════════════════════════════════
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    DETERMINISTIC ZONE                                │
│                  (Reproducible, auditable)                          │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │              Deterministic Post-Processing                     │  │
│  │  • Fixed threshold classification                              │  │
│  │  • Explicit confidence banding                                 │  │
│  │  • Rule-based type assignment                                  │  │
│  │  • Typed action proposal generation                            │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                │                                     │
│                                ▼                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                    SwiftVector Layer                           │  │
│  │  • Reducer validates and applies                               │  │
│  │  • Full audit trail                                            │  │
│  │  • Deterministic replay                                        │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
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
    
    /// Pure function: ML output → Classification
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
    
    /// Pure function: temperature characteristics → anomaly type
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
├── App/
│   └── FlightworksControlApp.swift
│
├── Core/                           ← SwiftVector implementation
│   ├── State/
│   │   ├── FlightState.swift
│   │   ├── MissionState.swift
│   │   ├── ThermalState.swift      ← Extension state
│   │   └── SystemState.swift
│   ├── Actions/
│   │   ├── FlightAction.swift
│   │   ├── MissionAction.swift
│   │   ├── ThermalAction.swift     ← Extension actions
│   │   └── Action.swift            ← Protocol
│   ├── Reducers/
│   │   ├── FlightReducer.swift
│   │   ├── MissionReducer.swift
│   │   ├── ThermalReducer.swift    ← Extension reducer
│   │   └── Reducer.swift           ← Protocol
│   └── Orchestrator/
│       └── FlightOrchestrator.swift
│
├── Telemetry/                      ← MAVLink integration
│   ├── MAVLinkConnection.swift
│   ├── TelemetryStream.swift
│   └── DroneConnectionManager.swift
│
├── UI/                             ← SwiftUI views
│   ├── Components/
│   ├── Screens/
│   ├── Map/
│   └── Thermal/                    ← Extension UI
│
├── Safety/                         ← Validation and interlocks
│   ├── SafetyValidator.swift
│   ├── GeofenceValidator.swift
│   ├── BatteryMonitor.swift
│   └── StateInterlocks.swift
│
├── Agents/                         ← AI decision support
│   ├── AgentProtocol.swift
│   ├── RiskAssessmentAgent.swift
│   ├── BatteryPredictionAgent.swift
│   └── ThermalAnomalyAgent.swift   ← Extension agent
│
└── ML/                             ← Machine learning
    ├── ThermalModel.mlmodel
    ├── DeterministicMLConfig.swift
    └── ThermalClassifier.swift     ← Deterministic post-processing
```

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
├── Orchestrator
├── State updates
└── UI rendering

Background Actors
├── TelemetryStream (dedicated)
├── MLInference (dedicated)
└── Agents (pooled)
```

---

## Testing Architecture

### Determinism Verification

```swift
// Property: Same inputs → Same outputs (always)
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

- [SwiftVector Whitepaper](https://agentincommand.ai/swiftvector) — Deterministic control architecture
- [Swift at the Edge](https://agentincommand.ai/swift-at-the-edge) — On-device AI manifesto
- [The Agency Paradox](https://agentincommand.ai/agency-paradox) — Human command over AI systems
- [THERMAL_INSPECTION_EXTENSION.md](THERMAL_INSPECTION_EXTENSION.md) — Thermal feature specification

---

## Related Documentation

- [ROADMAP.md](ROADMAP.md) — Product roadmap
- [SWIFTVECTOR.md](SWIFTVECTOR.md) — SwiftVector principles
- [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) — Development workflow
- [TESTING_STRATEGY.md](TESTING_STRATEGY.md) — Testing approach
