# SwiftVector in Flightworks Control

## What is SwiftVector?

SwiftVector is an architectural pattern for building reliable systems around AI components. The core insight:

> **State, not prompts, must be the authority.**

AI models are stochastic—they produce variable outputs. Applications must be deterministic—the same inputs should produce the same behavior. SwiftVector bridges this gap by placing deterministic control around stochastic intelligence.

This isn't about limiting AI capability. It's about channeling that capability through structures that humans can verify, audit, and trust.

---

## The Core Loop

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  State  │────▶│  Agent  │────▶│ Action  │────▶│ Reducer │────▶│New State│
│ (Truth) │     │(Propose)│     │ (Typed) │     │ (Pure)  │     │ (Truth) │
└─────────┘     └─────────┘     └─────────┘     └─────────┘     └─────────┘
     ▲                                                               │
     └───────────────────────────────────────────────────────────────┘
```

1. **State** represents complete system truth
2. **Agents** observe state and propose actions
3. **Actions** are typed descriptions of proposed changes
4. **Reducers** validate and apply actions deterministically
5. **New State** becomes the source of truth

The loop is unidirectional. State flows one way. There are no shortcuts.

---

## Key Principles

### 1. State is Truth

All system state is explicit, typed, and immutable. There is no hidden state. Every component sees the same truth.

```swift
struct FlightState: Equatable, Codable, Sendable {
    let connectionStatus: ConnectionStatus
    let position: Position?
    let altitude: Double
    let battery: BatteryState
    let flightMode: FlightMode
    let gpsInfo: GPSInfo?
    let thermalState: ThermalState?  // Extension point
    let timestamp: Date
}
```

**Why immutable?**
- No race conditions—immutable data is thread-safe by definition
- Change detection is trivial—just compare with `==`
- Time travel is possible—previous states are preserved
- Debugging is easier—state at any point is inspectable

### 2. Actions are Proposals

Nothing changes state directly. All changes are proposed as typed actions that can be validated, logged, and potentially rejected.

```swift
enum FlightAction: Equatable, Codable, Sendable {
    case arm
    case disarm
    case takeoff(altitude: Double)
    case land
    case returnToLaunch
    case updateTelemetry(TelemetryData)
    case thermal(ThermalAction)  // Composed actions
}
```

**Why typed enums?**
- Compiler enforces exhaustive handling
- Serialization enables audit trails
- Testing is straightforward—actions are just data
- Documentation is automatic—the enum is the API

### 3. Reducers are Authority

Only reducers can produce new state. Reducers are pure functions—deterministic, side-effect-free, and testable.

```swift
struct FlightReducer {
    /// Pure function: (State, Action) → State
    static func reduce(state: FlightState, action: FlightAction) -> FlightState {
        switch action {
        case .arm:
            guard canArm(state) else { return state }  // Invalid → unchanged
            return state.with(armingState: .armed)
            
        case .takeoff(let altitude):
            guard canTakeoff(state) else { return state }
            return state.with(flightMode: .takingOff, targetAltitude: altitude)
            
        // ... all cases handled
        }
    }
    
    // Preconditions are also pure functions
    private static func canArm(_ state: FlightState) -> Bool {
        state.connectionStatus == .connected &&
        state.gpsInfo?.fixType == .fix3D &&
        state.battery.percentage > 20
    }
}
```

**Why pure functions?**
- Testable without mocks—just call with inputs, check outputs
- Deterministic—essential for certification
- Replayable—same actions always produce same state
- Reasoneable—easier to understand system behavior

### 4. Agents Propose, Don't Command

AI agents follow the same pattern. They observe state and propose actions, but they cannot:

- ❌ Mutate state directly
- ❌ Bypass the reducer
- ❌ Override safety validation
- ❌ Execute without logging
- ❌ Hide their reasoning

They can:

- ✅ Observe complete state
- ✅ Propose any valid action type
- ✅ Provide confidence scores
- ✅ Explain their reasoning
- ✅ Request operator attention

```swift
protocol Agent: Actor {
    func observe(state: FlightState) async
    func propose() async -> [AgentProposal]
}

struct AgentProposal {
    let action: FlightAction
    let confidence: Double
    let explanation: String
}
```

### 5. Everything is Auditable

Every state transition is logged with:

- Timestamp
- Previous state (or hash)
- Action proposed
- New state (or hash)
- Source of action (UI, telemetry, agent)
- Agent explanation (if applicable)

```swift
struct AuditEntry: Codable {
    let id: UUID
    let timestamp: Date
    let action: FlightAction
    let previousStateHash: String
    let newStateHash: String
    let source: ActionSource
    let agentExplanation: String?
}
```

This enables:
- **Deterministic replay** — Reproduce any session exactly
- **Incident investigation** — Understand what happened and why
- **Regulatory compliance** — Prove system behavior
- **Continuous improvement** — Learn from real operations

---

## Why This Matters for GCS

Ground Control Stations are safety-critical. They must be:

| Requirement | SwiftVector Solution |
|-------------|---------------------|
| **Predictable** | Deterministic reducers guarantee consistent behavior |
| **Auditable** | Complete action log enables incident reconstruction |
| **Certifiable** | Pure functions can be formally verified |
| **Reliable** | Invalid actions are rejected, not crashed |
| **Transparent** | Agent reasoning is always visible |

Traditional approaches fail these requirements:

| Approach | Problem |
|----------|---------|
| Direct state mutation | Race conditions, hidden state, untraceable changes |
| String-based commands | No type safety, incomplete handling, runtime errors |
| Stateful AI agents | Non-deterministic, opaque reasoning, unauditable |
| Cloud-dependent AI | Latency, connectivity dependency, privacy concerns |

---

## Extensions for Edge AI

### The Determinism Challenge

Machine learning models are inherently probabilistic. The same input can produce slightly different outputs due to:
- Floating-point non-determinism
- GPU parallel execution order
- Model quantization effects

For safety-critical systems, this is unacceptable. We need deterministic behavior.

### The Determinism Boundary

SwiftVector solves this by establishing a clear boundary between stochastic and deterministic zones:

```
┌─────────────────────────────────────────────────┐
│            STOCHASTIC ZONE                       │
│                                                  │
│  ┌──────────────────────────────────────────┐   │
│  │         ML Model Inference                │   │
│  │   • Probabilistic outputs                 │   │
│  │   • May vary between runs                 │   │
│  │   • Confidence scores, not decisions      │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
                       │
                       ▼
═══════════════════════════════════════════════════
              DETERMINISM BOUNDARY
         (Fixed thresholds, explicit rules)
═══════════════════════════════════════════════════
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│           DETERMINISTIC ZONE                     │
│                                                  │
│  ┌──────────────────────────────────────────┐   │
│  │      Post-Processing (Pure Functions)     │   │
│  │   • Fixed threshold classification        │   │
│  │   • Explicit confidence banding           │   │
│  │   • Typed action generation               │   │
│  └──────────────────────────────────────────┘   │
│                       │                          │
│                       ▼                          │
│  ┌──────────────────────────────────────────┐   │
│  │          SwiftVector Layer                │   │
│  │   • Reducer validation                    │   │
│  │   • State transition                      │   │
│  │   • Audit logging                         │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

### Implementation Pattern

```swift
/// ML output (probabilistic)
struct ThermalMLOutput {
    let anomalyProbability: Double  // 0.0 - 1.0
    let boundingBox: CGRect
    let temperature: Double
}

/// Deterministic classification
struct ThermalClassifier {
    // Fixed thresholds (not learned, not variable)
    static let highConfidence = 0.85
    static let mediumConfidence = 0.70
    static let detectionThreshold = 0.50
    
    /// Pure function: MLOutput → Classification
    static func classify(_ output: ThermalMLOutput) -> AnomalyClassification? {
        guard output.anomalyProbability >= detectionThreshold else {
            return nil
        }
        
        let confidence: ConfidenceLevel = switch output.anomalyProbability {
            case highConfidence...: .high
            case mediumConfidence..<highConfidence: .medium
            default: .low
        }
        
        return AnomalyClassification(
            confidence: confidence,
            boundingBox: output.boundingBox,
            temperature: output.temperature
        )
    }
}

/// Typed action generation
extension ThermalAnomalyAgent {
    func generateAction(_ classification: AnomalyClassification) -> ThermalAction {
        .anomalyDetected(ThermalAnomaly(
            classification: classification,
            explanation: "Thermal anomaly detected with \(classification.confidence) confidence"
        ))
    }
}
```

### Core ML Configuration

For maximum determinism with Core ML:

```swift
func createDeterministicConfig() -> MLModelConfiguration {
    let config = MLModelConfiguration()
    // CPU and Neural Engine are more deterministic than GPU
    config.computeUnits = .cpuAndNeuralEngine
    return config
}
```

---

## Pattern Variations

### Basic SwiftVector

For simple applications without AI agents:

```
State → Action → Reducer → New State
```

UI and external inputs generate actions directly. No agent layer needed.

### Agent-Enhanced SwiftVector

For applications with AI decision support:

```
State → Agent → Action → Reducer → New State
         ↓
    (Proposals validated by safety layer)
```

Agents propose, but safety validation can reject.

### Multi-Agent SwiftVector

For complex systems with multiple AI components:

```
State → [Agent₁, Agent₂, Agent₃] → [Actions] → Priority Queue → Reducer → New State
                                        ↓
                                  (Conflict resolution)
```

Multiple agents propose; orchestrator resolves conflicts and prioritizes.

### Hierarchical SwiftVector

For systems with nested domains:

```
AppState
├── FlightState → FlightReducer
├── MissionState → MissionReducer
└── ThermalState → ThermalReducer

AppAction
├── .flight(FlightAction)
├── .mission(MissionAction)
└── .thermal(ThermalAction)

AppReducer delegates to domain reducers
```

---

## Comparison with Other Architectures

### SwiftVector vs. Redux

| Aspect | Redux | SwiftVector |
|--------|-------|-------------|
| Origin | JavaScript/Web | Swift/Safety-critical |
| Side effects | Middleware (thunks, sagas) | Orchestrator (post-reduce) |
| AI integration | Not designed for AI | First-class agent support |
| Type safety | Runtime (JS) | Compile-time (Swift) |
| Audit trail | Optional middleware | Built-in requirement |

SwiftVector borrows Redux's unidirectional flow but adds safety-critical requirements and agent architecture.

### SwiftVector vs. TCA (The Composable Architecture)

| Aspect | TCA | SwiftVector |
|--------|-----|-------------|
| Effects | Effect type with dependencies | Orchestrator-managed |
| Testing | Dependency injection | Pure function testing |
| AI agents | Not designed for AI | Core feature |
| Determinism | Not emphasized | Primary goal |

TCA is excellent for general Swift apps. SwiftVector focuses specifically on AI-integrated safety-critical systems.

### SwiftVector vs. Actor Model

| Aspect | Actor Model | SwiftVector |
|--------|-------------|-------------|
| State | Distributed across actors | Centralized, immutable |
| Communication | Message passing | Action dispatch |
| Determinism | Depends on implementation | Guaranteed by design |
| Audit | Requires explicit logging | Built-in |

SwiftVector uses Swift actors for concurrency but maintains centralized state for auditability.

---

## Implementation in Flightworks Control

### State Types

Located in `Core/State/`:

| File | Purpose |
|------|---------|
| `FlightState.swift` | Core flight data (position, attitude, battery) |
| `MissionState.swift` | Mission planning (waypoints, geofence) |
| `ThermalState.swift` | Thermal inspection (frames, anomalies) |
| `SystemState.swift` | App-level state (connection, settings) |

### Action Types

Located in `Core/Actions/`:

| File | Purpose |
|------|---------|
| `FlightAction.swift` | Flight control (arm, takeoff, land) |
| `MissionAction.swift` | Mission planning (add waypoint, validate) |
| `ThermalAction.swift` | Thermal inspection (frame received, anomaly flagged) |
| `Action.swift` | Protocol and composition |

### Reducers

Located in `Core/Reducers/`:

| File | Purpose |
|------|---------|
| `FlightReducer.swift` | Flight state transitions |
| `MissionReducer.swift` | Mission state transitions |
| `ThermalReducer.swift` | Thermal state transitions |
| `Reducer.swift` | Protocol definition |

### Orchestrator

Located in `Core/Orchestrator/`:

| File | Purpose |
|------|---------|
| `FlightOrchestrator.swift` | Coordinates control loop, manages audit log |

### Agents

Located in `Agents/`:

| File | Purpose |
|------|---------|
| `AgentProtocol.swift` | Agent interface definition |
| `RiskAssessmentAgent.swift` | Evaluates flight risk factors |
| `BatteryPredictionAgent.swift` | Predicts battery consumption |
| `ThermalAnomalyAgent.swift` | Detects thermal anomalies |

---

## Learnings from GCS Implementation

Building Flightworks Control has refined our understanding of SwiftVector:

### 1. Time-Bounded Determinism

In real-time systems, determinism must include temporal bounds. A decision that takes variable time is effectively non-deterministic from the operator's perspective.

**Solution:** Set latency budgets for each component; fail-safe if exceeded.

### 2. Sensor Fusion as Pure Functions

Combining multiple telemetry streams (GPS, IMU, barometer, thermal) can be expressed as pure functions over sensor snapshots, enabling reproducible position estimates.

**Solution:** Timestamp all inputs; fusion function takes snapshot, produces result.

### 3. Confidence Propagation

Uncertainty in inputs should propagate through the decision chain, resulting in uncertainty bounds on outputs rather than false precision.

**Solution:** Every classification includes confidence level; UI reflects uncertainty.

### 4. Graceful Degradation Hierarchy

When subsystems fail, the system should have explicit degradation modes, each with clear operator communication.

**Solution:** Define degradation ladder; each level has known capabilities and limitations.

### 5. ML Output Normalization

Probabilistic ML outputs require deterministic post-processing to produce consistent typed actions.

**Solution:** Fixed thresholds at determinism boundary; no learned parameters in post-processing.

---

## Applicability Beyond GCS

SwiftVector patterns apply to other safety-critical Swift applications:

| Domain | State | Actions | Agents |
|--------|-------|---------|--------|
| **Medical devices** | Patient vitals, device status | Alerts, dosage adjustments | Anomaly detection |
| **Industrial control** | Sensor readings, actuator states | Control commands | Predictive maintenance |
| **Autonomous vehicles** | Vehicle state, environment | Navigation commands | Perception, planning |
| **Financial trading** | Portfolio, market data | Trade orders | Risk assessment |

The common thread: systems where AI assists but humans must remain in command, and where behavior must be auditable and reproducible.

---

## Getting Started

### Minimal Example

```swift
// 1. Define State
struct CounterState: Equatable {
    let count: Int
}

// 2. Define Actions
enum CounterAction {
    case increment
    case decrement
    case reset
}

// 3. Define Reducer
struct CounterReducer {
    static func reduce(state: CounterState, action: CounterAction) -> CounterState {
        switch action {
        case .increment: return CounterState(count: state.count + 1)
        case .decrement: return CounterState(count: max(0, state.count - 1))
        case .reset: return CounterState(count: 0)
        }
    }
}

// 4. Use
var state = CounterState(count: 0)
state = CounterReducer.reduce(state: state, action: .increment)  // count: 1
state = CounterReducer.reduce(state: state, action: .increment)  // count: 2
state = CounterReducer.reduce(state: state, action: .decrement)  // count: 1
```

### Adding an Agent

```swift
// 5. Define Agent
actor CounterAdvisorAgent: Agent {
    private var currentState: CounterState?
    
    func observe(state: CounterState) async {
        currentState = state
    }
    
    func propose() async -> [AgentProposal] {
        guard let state = currentState else { return [] }
        
        // Agent proposes reset if count gets too high
        if state.count > 100 {
            return [AgentProposal(
                action: .reset,
                confidence: 0.9,
                explanation: "Count exceeded threshold; recommending reset"
            )]
        }
        return []
    }
}
```

---

## Learn More

- [SwiftVector Whitepaper](https://agentincommand.ai/swiftvector) — Full technical specification
- [Swift at the Edge](https://agentincommand.ai/swift-at-the-edge) — Why Swift for on-device AI
- [The Agency Paradox](https://agentincommand.ai/agency-paradox) — Human command over AI systems
- [ARCHITECTURE.md](ARCHITECTURE.md) — Detailed system design
- [THERMAL_INSPECTION_EXTENSION.md](THERMAL_INSPECTION_EXTENSION.md) — Edge AI example

---

## Related Documentation

- [ROADMAP.md](ROADMAP.md) — Product roadmap
- [ARCHITECTURE.md](ARCHITECTURE.md) — System design
- [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) — Development workflow
- [TESTING_STRATEGY.md](TESTING_STRATEGY.md) — Testing approach
