# Flightworks Control Architecture

> Version 3.1 — February 2026
> Previous: v3.0 (Two-language stack, Edge Relay)
> Changes: Expanded jurisdiction hierarchy (FireLaw, ISRLaw), Law composition table, governance pressure progression, multi-asset state scaling note

## Overview

Flightworks Control implements the SwiftVector architectural pattern — deterministic control around stochastic systems. The system uses a **two-language stack**: Swift for governance, operator interface, and deterministic state management; Rust for protocol handling, transport audit, and edge relay. Both languages provide compile-time safety guarantees, no garbage collection, and deterministic behavior — proving that the SwiftVector thesis is about *principles*, not a single language.

**Key Architectural Principles:**

1. **State is truth** — All system state is explicit, typed, and immutable
2. **Actions are proposals** — Nothing changes state directly; all changes are validated
3. **Reducers are authority** — Only pure functions can produce new state
4. **Agents propose, don't command** — AI provides recommendations, operators decide
5. **Everything is auditable** — Full logging enables replay and incident investigation
6. **Determinism spans languages** — Cross-language audit trails prove governance integrity

---

## Two-Language Stack

### Why Two Languages?

Swift and Rust are philosophical siblings for safety-critical edge systems. Both provide memory safety without garbage collection, strong type systems, and deterministic behavior. Each excels in different domains:

| Concern | Language | Rationale |
|---------|----------|-----------|
| Governance & state management | Swift | SwiftUI integration, @MainActor safety, Codable audit trails |
| Operator interface | Swift | Native iPadOS, SwiftUI declarative UI |
| Protocol handling | Rust | Zero-copy parsing, `no_std` capability, MAVLink ecosystem |
| Transport audit | Rust | JSONL logging, message allowlisting, replay engine |
| Determinism verification | Both | Cross-language audit trail correspondence proves thesis |

### Language Boundary

```
+---------------------------------------------------------------+
|                     iPad Application (Swift)                   |
|                                                                |
|  +------------------+  +------------------+  +---------------+ |
|  | FlightOrchestrator|  | FlightReducer   |  | SafetyValidator| |
|  | (State mgmt)     |  | (Pure functions) |  | (Interlocks)  | |
|  +--------+---------+  +------------------+  +---------------+ |
|           |                                                    |
|  +--------v---------+                                          |
|  | RelayConnection   |  <-- Swift UDP client (NWConnection)    |
|  | TelemetryMapper   |  <-- MAVLink JSON -> FlightAction       |
|  +--------+---------+                                          |
+-----------|----------------------------------------------------|
            | UDP (localhost or network)
            | JSON-encoded MAVLink messages
+-----------v----------------------------------------------------|
|                   Edge Relay (Rust)                             |
|                                                                |
|  +------------------+  +------------------+  +---------------+ |
|  | UDP Relay        |  | MAVLink Decoder  |  | Msg Allowlist | |
|  | (Bidirectional)  |  | (mavlink crate)  |  | (Config-driven)| |
|  +------------------+  +--------+---------+  +---------------+ |
|                                 |                              |
|  +------------------+  +--------v---------+  +---------------+ |
|  | JSONL Audit Log  |  | Replay Engine    |  | CLI Interface | |
|  | (SHA256 chained) |  | (Deterministic)  |  | (clap crate)  | |
|  +------------------+  +------------------+  +---------------+ |
+----------------------------------------------------------------+
            | UDP
            v
    +----------------+
    | PX4 Autopilot  |
    | (SITL or HW)   |
    | MAVLink v2      |
    +----------------+
```

### Cross-Language Determinism Proof

The architectural thesis — that deterministic governance works across language boundaries — is proven through audit trail correspondence:

```
Golden MAVLink Recording (fixtures/test_flight_001.mavlink)
    |
    v
Rust Edge Relay               Swift Governance Layer
    |                              |
    v                              v
JSONL Audit Trail             Action Log (SHA256 chained)
    |                              |
    +--------- ASSERT 1:1 --------+
               correspondence
```

For every MAVLink message the Rust relay logs, there must be a corresponding FlightAction in the Swift audit trail. Same sequence, same timestamps (within tolerance), same semantic content. This IS the cross-language determinism test.

---

## Jurisdiction Architecture

The Flightworks Suite uses a **jurisdiction model** where mission-specific applications inherit universal safety guarantees from FlightLaw while adding domain-specific governance.

### Jurisdiction Hierarchy

```
                        SwiftVector Codex (Laws 0-10)
                                |
                        FlightLaw (Laws 3, 4, 7, 8)
                        [Safety Floor — Always Active]
                                |
          +---------------------+---------------------+
          |                     |                     |
     ThermalLaw            SurveyLaw             FireLaw
     Laws: 3,4,7,8        Laws: 3,4,7,8        Laws: 2,3,4,6,7,8
     [Single asset]        [Single asset]        [Multi-asset]
     [Operator present]    [Operator present]    [Operator degraded]
     [Real-time auth]      [Real-time auth]      [Escalation tiers]
     Status: Deferred      Status: Future        Status: Architecture
                                                      |
                                                      | extends
                                                      v
                                                  ISRLaw
                                                  Laws: 0,2,3,4,5,6,7,8
                                                  [Multi-asset swarm]
                                                  [Comms denied by design]
                                                  [Authority pre-loaded]
                                                  [Contested environment]
                                                  [Partition tolerant]
                                                  Status: Architecture
```

**The progression tells a story:**
- ThermalLaw/SurveyLaw: "Governed AI assists an operator doing a job."
- FireLaw: "Governed AI operates when the operator can't be everywhere."
- ISRLaw: "Governed AI operates when no human can be present at all."

At every level, the Codex holds. The Laws compose. The Reducer enforces. The audit proves.

> **Current Focus:** FlightLaw foundation (Phase 0) + Rust Edge Relay (Phase 1), running in parallel. All other jurisdictions inherit FlightLaw safety guarantees when implemented.

### Jurisdiction Composition Principle

**FlightLaw provides universal guarantees (Laws 3, 4, 7, 8):**
- Battery reserve enforcement (RTL at 20%)
- Geofence violation prevention
- Pre-flight readiness validation
- Tamper-evident audit trail
- Deterministic replay

**Domain jurisdictions extend FlightLaw by composing additional Laws:**

| Jurisdiction | Base | Added Laws | Key Governance Innovation |
|:------------|:-----|:-----------|:-------------------------|
| **ThermalLaw** | FlightLaw | — | Deterministic ML post-processing, operator approval workflow |
| **SurveyLaw** | FlightLaw | — | Precision enforcement as pure function validation |
| **FireLaw** | FlightLaw | Law 2 (Delegation), Law 6 (Persistence) | Multi-asset task leases, escalation tiers, degraded comms governance |
| **ISRLaw** | FlightLaw | Law 0 (Boundary), Law 2, Law 5 (Sovereignty), Law 6 | Pre-loaded authority envelopes, EMCON governance, partition-tolerant swarm |

**Governance Pressure Progression:**

| Capability | Thermal | Survey | Fire | ISR |
|:-----------|:-------:|:------:|:----:|:---:|
| Multi-asset coordination | — | — | Yes | Yes |
| Extended autonomous ops | — | — | Yes | Yes |
| Operator absent/degraded | — | — | Yes | Yes |
| Pre-loaded authority (comms-denied) | — | — | — | Yes |
| Partition-tolerant governance | — | — | — | Yes |
| EMCON / emissions control | — | — | — | Yes |
| Adversarial threat model | — | — | — | Yes |

This progression proves the Codex scales: the same SwiftVector pattern (State → Action → Reducer → Audit) governs a single-asset inspection and a comms-denied swarm. The Reducer is always a pure function. The audit trail is always a SHA256 hash chain. No Law is modified when new jurisdictions are added.

**Business Guarantees:**
- ThermalLaw: *"No critical damage will be missed or hallucinated"*
- SurveyLaw: *"100% adherence to engineering-grade spatial grids"*
- FireLaw: *"Every hotspot detection, escalation decision, and coverage gap is deterministically reproducible and auditable"*
- ISRLaw: *"Every autonomous decision under comms denial was pre-authorized, executed within deterministic bounds, and recorded in a tamper-evident audit trail"*

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
+-------------------------------------------------------------+
|                      Orchestrator                            |
|                 (Coordinates control loop)                   |
|          +----------------------------------+                |
|          |  * Maintains current state       |                |
|          |  * Validates action proposals    |                |
|          |  * Dispatches to reducers        |                |
|          |  * Triggers side effects         |                |
|          |  * Maintains audit log           |                |
|          +----------------------------------+                |
+-------------------------------------------------------------+
                              |
         +--------------------+--------------------+
         v                    v                    v
+--------------+      +--------------+      +--------------+
|    State     |<-----|   Reducer    |<-----|   Action     |
| (Immutable)  |      |(Pure Func)   |      |  (Typed)     |
|              |      |              |      |              |
| * Equatable  |      | * No side    |      | * Enum with  |
| * Codable    |      |   effects    |      |   assoc.     |
| * Sendable   |      | * Total      |      |   values     |
+--------------+      | * Safe       |      | * Codable    |
         |            +--------------+      +--------------+
         |                                       ^
         |         +-----------------------------+
         v         |
+-------------------------------------------------------------+
|                         Agents                               |
|              (Observe state, propose actions)                |
|  +--------------+  +--------------+  +--------------------+ |
|  |    Risk      |  |   Battery    |  |    [Domain]        | |
|  |  Assessment  |  |  Prediction  |  |  Agent (Future)    | |
|  +--------------+  +--------------+  +--------------------+ |
+-------------------------------------------------------------+
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
    let relay: RelayConnectionState  // Edge Relay status
    let system: SystemState
}
```

**Multi-Asset State Scaling:** Future jurisdictions (FireLaw, ISRLaw) extend this pattern to fleet-level state without modifying the core SwiftVector primitives. `FleetState` contains per-drone `FlightState` instances, task lease registries, and coverage maps — all composed through the same immutable-state pattern. The Reducer remains a pure function; it simply operates on a larger state tree. See [HLD-FlightworksFire.md](HLD-FlightworksFire.md) and [HLD-FlightworksISR.md](HLD-FlightworksISR.md) for domain-specific state models.

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
    
    // Telemetry (from Edge Relay via TelemetryMapper)
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
    case mission(MissionAction)
    case relay(RelayAction)  // Edge Relay status changes
}
```

**Action Composition Pattern:**

Domain-specific actions can be nested within a root action type:

```swift
// Relay status actions (from Rust Edge Relay)
enum RelayAction: Equatable, Codable, Sendable {
    case relayConnected(endpoint: String)
    case relayDisconnected(reason: String)
    case heartbeatReceived(systemId: UInt8)
    case messageFiltered(messageId: UInt32, reason: String)
}

// Composed into root action
enum AppAction: Equatable, Codable, Sendable {
    case flight(FlightAction)
    case mission(MissionAction)
    case relay(RelayAction)
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
        case .mission(let missionAction):
            return state.with(
                mission: MissionReducer.reduce(state: state.mission, action: missionAction)
            )
        case .relay(let relayAction):
            return state.with(
                relay: RelayReducer.reduce(state: state.relay, action: relayAction)
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
    
    private var auditTrail: AuditTrail<FlightAction>
    
    struct LoggedAction: Codable {
        let id: UUID
        let timestamp: Date
        let action: FlightAction
        let previousStateHash: String
        let newStateHash: String
        let source: ActionSource
    }
    
    enum ActionSource: String, Codable {
        case ui          // Operator interaction
        case telemetry   // From Edge Relay via TelemetryMapper
        case agent       // AI decision support
        case system      // Internal system events
        case relay       // Edge Relay status changes
    }
    
    // MARK: - Initialization
    
    init(initialState: FlightState = .initial) {
        self.state = initialState
        self.auditTrail = AuditTrail()
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
        auditTrail.append(logEntry)
        
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
        // Commands sent via Edge Relay to PX4
        
        switch action {
        case .arm:
            Task { await relayConnection.sendCommand(.arm) }
            
        case .takeoff(let altitude):
            Task { await relayConnection.sendCommand(.takeoff(altitude: altitude)) }
            
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
    
    func exportAuditTrail() -> Data? {
        auditTrail.export()
    }
}
```

---

## Component Architecture

```
+-----------------------------------------------------------------------+
|                              App                                      |
+-----------------------------------------------------------------------+
|                              UI Layer                                 |
|  +--------------+  +--------------+  +--------------+                 |
|  |  Map View    |  |  Telemetry   |  |   Mission    |                 |
|  |              |  |   Display    |  |   Planning   |                 |
|  +--------------+  +--------------+  +--------------+                 |
+------|------------------|------------------|--------------------------|
|      v                  v                  v                          |
|  +---------------------------------------------------------------+   |
|  |                        Orchestrator                            |   |
|  |              (State management, action dispatch)               |   |
|  +---------------------------------------------------------------+   |
|                                  |                                    |
+----------------------------------|------------------------------------|
|                    Decision Layer |                                   |
|         +------------------------+------------------------+          |
|         v                        v                        v          |
|  +--------------+          +--------------+          +--------------+ |
|  |   Flight     |          |   Mission    |          |   Relay      | |
|  |   Reducer    |          |   Reducer    |          |   Reducer    | |
|  +--------------+          +--------------+          +--------------+ |
|         |                        |                        |          |
|         v                        v                        v          |
|  +--------------+          +--------------+          +--------------+ |
|  |   Safety     |          |  Geofence    |          |   Relay      | |
|  |  Validator   |          |  Validator   |          |  Connection  | |
|  +--------------+          +--------------+          +--------------+ |
|                                                                      |
+----------------------------------------------------------------------+
|                           Telemetry Layer                            |
|  +---------------------------------------------------------------+  |
|  |                  RelayConnection (Swift)                        |  |
|  |           (NWConnection UDP client to Edge Relay)              |  |
|  +---------------------------------------------------------------+  |
|  +---------------------------------------------------------------+  |
|  |                  TelemetryMapper (Swift)                        |  |
|  |       (JSON MAVLink messages -> typed FlightAction values)     |  |
|  +---------------------------------------------------------------+  |
+----------------------------------------------------------------------+
            | UDP (JSON-encoded MAVLink)
            v
+----------------------------------------------------------------------+
|                        Edge Relay (Rust)                              |
|  +------------------+  +------------------+  +--------------------+  |
|  | UDP Relay        |  | MAVLink Decoder  |  | Message Allowlist  |  |
|  | (Bidirectional)  |  | (mavlink crate)  |  | (TOML config)     |  |
|  +------------------+  +------------------+  +--------------------+  |
|  +------------------+  +------------------+  +--------------------+  |
|  | JSONL Audit Log  |  | Replay Engine    |  | CLI (clap)         |  |
|  | (SHA256 chained) |  | (Deterministic)  |  | relay/record/replay|  |
|  +------------------+  +------------------+  +--------------------+  |
+----------------------------------------------------------------------+
            | UDP (raw MAVLink v2)
            v
    +----------------+
    | PX4 Autopilot  |
    | (SITL or HW)   |
    +----------------+
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

### Why Two Languages?

| Benefit | Explanation |
|---------|-------------|
| **Right tool for domain** | Swift excels at UI/governance, Rust at protocol/transport |
| **Compile-time safety** | Both enforce memory safety without GC |
| **Determinism proof** | Cross-language audit correspondence proves architectural thesis |
| **Industry alignment** | Rust increasingly standard for safety-critical systems |
| **Edge capability** | Rust's `no_std` enables future embedded deployment |

### Why Edge Relay Instead of Direct SDK?

| Benefit | Explanation |
|---------|-------------|
| **Platform independence** | Works with any MAVLink autopilot (PX4, ArduPilot) |
| **Transport audit** | Every MAVLink message logged before reaching governance layer |
| **Message filtering** | Allowlist prevents unexpected messages from reaching Swift |
| **Replay capability** | Record raw MAVLink streams for deterministic replay |
| **Testability** | Replay recorded flights through Swift without hardware |
| **No vendor lock-in** | No proprietary SDK dependencies |

---

## Safety Architecture

### Validation Layers

```
Action Proposed
       |
       v
+---------------------+
|  Type Validation     |  <-- Compile-time (Swift type system)
|  * Enum exhaustive   |
|  * Associated types  |
+---------------------+
           |
           v
+---------------------+
|  State Validation    |  <-- Runtime (precondition checks in reducer)
|  * Preconditions     |
|  * Mode transitions  |
+---------------------+
           |
           v
+---------------------+
|  Safety Validation   |  <-- Runtime (SafetyValidator)
|  * Geofence checks   |
|  * Battery limits    |
|  * Airspace rules    |
+---------------------+
           |
           v
+---------------------+
|  Action Applied      |
|  * State updated     |
|  * Audit logged      |
|  * Effects triggered |
+---------------------+
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

- Mutate state directly
- Bypass reducer
- Override safety validation
- Execute without logging
- Access external resources during proposal

Agents **can**:

- Observe complete state snapshot
- Propose any valid action type
- Provide confidence scores
- Explain reasoning
- Request operator attention

---

## Edge AI Extension Architecture

### The Determinism Boundary

Edge AI integration presents a challenge: ML models produce probabilistic outputs, but safety-critical systems require deterministic behavior. SwiftVector solves this by establishing a clear **determinism boundary**:

```
+---------------------------------------------------------------+
|                    STOCHASTIC ZONE                             |
|                  (Probabilistic, variable)                     |
|  +----------------------------------------------------------+ |
|  |                    ML Model Inference                      | |
|  |  * Neural network forward pass                            | |
|  |  * Probabilistic outputs                                  | |
|  |  * May vary slightly between runs (GPU non-determinism)   | |
|  +----------------------------------------------------------+ |
+---------------------------------------------------------------+
                                |
                                v
================================================================
                      DETERMINISM BOUNDARY
               (Fixed thresholds, explicit rules)
================================================================
                                |
                                v
+---------------------------------------------------------------+
|                    DETERMINISTIC ZONE                          |
|                  (Reproducible, auditable)                     |
|  +----------------------------------------------------------+ |
|  |              Deterministic Post-Processing                 | |
|  |  * Fixed threshold classification                         | |
|  |  * Explicit confidence banding                            | |
|  |  * Rule-based type assignment                             | |
|  |  * Typed action proposal generation                       | |
|  +----------------------------------------------------------+ |
|                                |                               |
|                                v                               |
|  +----------------------------------------------------------+ |
|  |                    SwiftVector Layer                        | |
|  |  * Reducer validates and applies                          | |
|  |  * Full audit trail                                       | |
|  |  * Deterministic replay                                   | |
|  +----------------------------------------------------------+ |
+---------------------------------------------------------------+
```

### Extension Pattern for ML Applications

This pattern applies to any edge AI integration (future ThermalLaw, SurveyLaw, etc.):

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

## Rust Edge Relay Architecture

### Module Structure

```
Tools/EdgeRelay/
  Cargo.toml
  src/
    main.rs              -- CLI entry point (clap)
    relay.rs             -- UDP bidirectional relay
    mavlink.rs           -- MAVLink v2 decode/encode (mavlink crate)
    allowlist.rs         -- Message type allowlist (TOML config)
    audit.rs             -- JSONL audit log with SHA256 hash chain
    recorder.rs          -- Raw MAVLink stream recording
    replay.rs            -- Deterministic replay from recordings
  tests/
    relay_tests.rs
    mavlink_tests.rs
    audit_tests.rs
    replay_tests.rs
  fixtures/
    test_heartbeat.mavlink
    test_flight_001.mavlink
```

### Audit Log Format (JSONL)

Each line is a self-contained JSON object with a SHA256 hash chain:

```json
{"seq":0,"ts":"2026-02-16T12:00:00.000Z","msg_id":0,"msg_name":"HEARTBEAT","system_id":1,"component_id":1,"payload":{"type":2,"autopilot":12,"base_mode":81},"hash":"a1b2c3...","prev_hash":"0000..."}
{"seq":1,"ts":"2026-02-16T12:00:00.050Z","msg_id":33,"msg_name":"GLOBAL_POSITION_INT","system_id":1,"component_id":1,"payload":{"lat":397749000,"lon":-1049841000,"alt":1500000},"hash":"d4e5f6...","prev_hash":"a1b2c3..."}
```

### Message Allowlist

Configuration-driven filtering prevents unexpected messages from reaching the governance layer:

```toml
# allowlist.toml
[allowed_messages]
heartbeat = true           # msg_id 0
global_position_int = true # msg_id 33
attitude = true            # msg_id 30
battery_status = true      # msg_id 147
gps_raw_int = true         # msg_id 24
mission_current = true     # msg_id 42
sys_status = true          # msg_id 1

[blocked_messages]
# Explicitly blocked (logged but not forwarded)
debug = true               # msg_id 253
debug_vect = true          # msg_id 250
```

### CLI Interface

```
edge-relay relay --listen 0.0.0.0:14550 --forward 127.0.0.1:14540 --audit flight.jsonl
edge-relay record --listen 0.0.0.0:14550 --output flight.mavlink
edge-relay replay --input flight.mavlink --forward 127.0.0.1:14550 --speed 1.0
edge-relay verify --audit flight.jsonl  # Verify hash chain integrity
```

---

## File Organization

```
FlightworksControl/
+-- App/
|   +-- FlightworksControlApp.swift
|
+-- Core/                           <-- SwiftVector implementation
|   +-- State/
|   |   +-- FlightState.swift
|   |   +-- MissionState.swift
|   |   +-- RelayConnectionState.swift
|   |   +-- SystemState.swift
|   +-- Actions/
|   |   +-- FlightAction.swift
|   |   +-- MissionAction.swift
|   |   +-- RelayAction.swift
|   |   +-- Action.swift            <-- Protocol
|   +-- Reducers/
|   |   +-- FlightReducer.swift
|   |   +-- MissionReducer.swift
|   |   +-- RelayReducer.swift
|   |   +-- Reducer.swift           <-- Protocol
|   +-- Orchestrator/
|   |   +-- FlightOrchestrator.swift
|   +-- Audit/
|       +-- AuditTrail.swift        <-- SHA256 hash chain
|       +-- DeterminismVerifier.swift
|
+-- Telemetry/                      <-- Edge Relay integration
|   +-- RelayConnection.swift       <-- NWConnection UDP client
|   +-- TelemetryMapper.swift       <-- JSON MAVLink -> FlightAction
|   +-- DroneConnectionManager.swift
|
+-- UI/                             <-- SwiftUI views
|   +-- Components/
|   +-- Screens/
|   +-- Map/
|
+-- Safety/                         <-- Validation and interlocks
|   +-- SafetyValidator.swift
|   +-- GeofenceValidator.swift
|   +-- BatteryMonitor.swift
|   +-- StateInterlocks.swift
|
+-- Agents/                         <-- AI decision support
    +-- AgentProtocol.swift
    +-- RiskAssessmentAgent.swift
    +-- BatteryPredictionAgent.swift

Tools/
+-- EdgeRelay/                      <-- Rust Edge Relay
    +-- Cargo.toml
    +-- src/
    |   +-- main.rs
    |   +-- relay.rs
    |   +-- mavlink.rs
    |   +-- allowlist.rs
    |   +-- audit.rs
    |   +-- recorder.rs
    |   +-- replay.rs
    +-- tests/
    +-- fixtures/
```

---

## Performance Considerations

### Real-Time Requirements

| Component | Latency Target | Rationale |
|-----------|----------------|-----------|
| Edge Relay forwarding | < 5ms | Transparent to autopilot |
| Telemetry processing | < 50ms | Situational awareness |
| UI updates | < 16ms | 60fps rendering |
| State transition | < 10ms | Responsive control |
| Audit log write | < 1ms | Non-blocking append |

### Memory Management

- State snapshots use copy-on-write semantics
- Audit trail implements circular buffer for bounded memory
- Edge Relay uses zero-copy MAVLink parsing where possible
- Telemetry frames processed in streaming fashion

### Threading Model

```
Main Actor (UI Thread)         -- Swift
+-- Orchestrator
+-- State updates
+-- UI rendering

Background Actors              -- Swift
+-- RelayConnection (dedicated NWConnection)
+-- Agents (pooled)

Rust Threads                   -- Edge Relay
+-- UDP relay (tokio async)
+-- Audit writer (dedicated)
+-- MAVLink decoder (inline with relay)
```

---

## Testing Architecture

### Determinism Verification

```swift
// Property: Same inputs -> Same outputs (always)
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

### Cross-Language Determinism

```swift
// Property: Rust audit trail and Swift action log correspond 1:1
func testCrossLanguageDeterminism() {
    // 1. Replay golden MAVLink recording through Rust Edge Relay
    let rustAudit = loadRustAuditTrail("test_flight_001.jsonl")
    
    // 2. Replay same recording through full stack
    let swiftLog = orchestrator.exportAuditTrail()
    
    // 3. Assert 1:1 correspondence
    XCTAssertEqual(rustAudit.count, swiftLog.count)
    for (rustEntry, swiftEntry) in zip(rustAudit, swiftLog) {
        XCTAssertEqual(rustEntry.messageId, swiftEntry.action.mavlinkId)
        XCTAssertEqual(
            rustEntry.timestamp,
            swiftEntry.timestamp,
            accuracy: 0.010  // 10ms tolerance for cross-process timing
        )
    }
}
```

### Rust Edge Relay Tests

```rust
#[test]
fn test_audit_hash_chain_integrity() {
    let entries = replay_and_audit("fixtures/test_flight_001.mavlink");
    
    for window in entries.windows(2) {
        assert_eq!(window[1].prev_hash, window[0].hash);
    }
}

#[test]
fn test_replay_determinism() {
    let audit_1 = replay_and_audit("fixtures/test_flight_001.mavlink");
    let audit_2 = replay_and_audit("fixtures/test_flight_001.mavlink");
    
    assert_eq!(audit_1.len(), audit_2.len());
    for (a, b) in audit_1.iter().zip(audit_2.iter()) {
        assert_eq!(a.msg_id, b.msg_id);
        assert_eq!(a.payload, b.payload);
        // Timestamps may differ, but sequence and content must match
    }
}

#[test]
fn test_allowlist_filtering() {
    let config = AllowlistConfig::load("fixtures/test_allowlist.toml");
    let messages = decode_file("fixtures/test_flight_001.mavlink");
    
    let filtered: Vec<_> = messages.iter()
        .filter(|m| config.is_allowed(m.msg_id))
        .collect();
    
    // Only allowed message types pass through
    assert!(filtered.iter().all(|m| config.is_allowed(m.msg_id)));
}
```

See [TESTING_STRATEGY.md](TESTING_STRATEGY.md) for comprehensive testing documentation.

---

## References

- [SwiftVector Whitepaper](https://agentincommand.ai/swiftvector) — Deterministic control architecture
- [Swift at the Edge](https://agentincommand.ai/swift-at-the-edge) — On-device AI manifesto
- [The Agency Paradox](https://agentincommand.ai/agency-paradox) — Human command over AI systems
- [SwiftVector Codex](SwiftVector-Codex.md) — Constitutional framework for governed systems

---

## Related Documentation

- [ROADMAP.md](ROADMAP.md) — Product roadmap
- [SWIFTVECTOR.md](SWIFTVECTOR.md) — SwiftVector principles
- [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) — Development workflow
- [TESTING_STRATEGY.md](TESTING_STRATEGY.md) — Testing approach
- [RUST_LEARNING_PLAN.md](RUST_LEARNING_PLAN.md) — Rust learning curriculum

---

## Suite Documentation

### Architecture Documents

| Document | Purpose |
|----------|---------|
| [Flightworks-Suite-Overview.md](Flightworks-Suite-Overview.md) | Master suite architecture and jurisdiction model |
| [HLD-FlightworksCore.md](HLD-FlightworksCore.md) | FlightLaw technical architecture |
| [PRD-FlightworksCore.md](PRD-FlightworksCore.md) | FlightLaw requirements |
| [HLD-FlightworksThermal.md](HLD-FlightworksThermal.md) | ThermalLaw technical architecture (deferred) |
| [PRD-FlightworksThermal.md](PRD-FlightworksThermal.md) | ThermalLaw requirements (deferred) |
| [HLD-FlightworksSurvey.md](HLD-FlightworksSurvey.md) | SurveyLaw technical architecture (future) |
| [PRD-FlightworksSurvey.md](PRD-FlightworksSurvey.md) | SurveyLaw requirements (future) |
| [HLD-FlightworksFire.md](HLD-FlightworksFire.md) | FireLaw technical architecture (architecture draft) |
| [HLD-FlightworksISR.md](HLD-FlightworksISR.md) | ISRLaw technical architecture (architecture draft) |

### Archived Documents

The following documents have been superseded by the jurisdiction-based architecture:

| Document | Replaced By | Status |
|----------|-------------|--------|
| HLD-FlightworksControl.md | HLD-FlightworksCore.md | Archived v1 |
| PRD-FlightworksControl.md | PRD-FlightworksCore.md | Archived v1 |
| THERMAL_INSPECTION_EXTENSION.md | HLD-FlightworksThermal.md + PRD-FlightworksThermal.md | Archived v1 |

See `archive/v1-monolithic/` for historical reference.
