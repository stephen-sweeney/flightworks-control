# Flightworks Core: High-Level Design (FlightLaw Baseline)

**Document:** HLD-FC-CORE-2026-001  
**Version:** 1.0  
**Date:** February 2026  
**Author:** Stephen Sweeney, Flightworks Aerial LLC  
**Status:** Active Development  
**Classification:** Public

---

## Document Purpose

This High-Level Design (HLD) specifies **Flightworks Core**—the baseline safety kernel (FlightLaw) that provides universal drone operation guarantees. Flightworks Core is **not** a standalone application; it is the **foundation layer** upon which mission-specific jurisdictions (ThermalLaw, SurveyLaw) are built.

**Scope of This Document:**
- FlightLaw jurisdiction specification (Laws 3, 4, 7, 8)
- Core safety infrastructure shared across all jurisdictions
- SwiftVector enforcement architecture
- Audit trail and replay mechanisms
- DJI PSDK integration layer
- **Excludes:** Mission-specific logic (thermal detection, survey grids, etc.)

---

## Architectural Philosophy

### The Constitutional Foundation

Flightworks Core implements the **SwiftVector Codex**—a constitutional framework where:

> **"AI proposes, humans decide, Laws enforce"**

Every aspect of the architecture flows from three immutable principles:

#### Pillar 1: State as Authority

> Truth lives in State, not in language.

Authority resides in deterministic state machines, not in natural language prompts or probabilistic inference. The system's truth is explicit, typed, and immutable.

**Architectural Implication:**
- All system state is captured in typed, immutable structs
- No hidden state, no mutable singletons, no global variables
- State transitions are the **only** source of truth

#### Pillar 2: The Reducer Pattern

> (CurrentState, Action) → NewState | Rejection

All state mutations pass through pure-function Reducers. Invalid actions are rejected with explicit cause, creating a complete audit trail.

**Architectural Implication:**
- The Reducer is the **single point** of state transition
- Reducers are testable in isolation
- Deterministic by design, auditable by construction

#### Pillar 3: Actor Isolation

> Governance state is protected by the compiler.

Swift Actors enforce that concurrent agent operations cannot corrupt safety logic. The Reducer alone has authority to mutate the source of truth.

**Architectural Implication:**
- Thread safety is not a convention—it is **enforced by the type system**
- Race conditions on governance state are compile-time errors

---

## FlightLaw Jurisdiction

### Composed Laws

FlightLaw is the composition of four Laws from the SwiftVector Codex:

```
FlightLaw = Law 3 ∘ Law 4 ∘ Law 7 ∘ Law 8
```

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLIGHTLAW JURISDICTION                       │
│                   (Universal Safety Kernel)                     │
│                                                                 │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐   │
│  │    Law 3       │  │    Law 4       │  │    Law 7       │   │
│  │  Observation   │  │   Resource     │  │   Spatial      │   │
│  │                │  │                │  │                │   │
│  │ • Telemetry    │  │ • Battery      │  │ • Geofence     │   │
│  │ • Pre-flight   │  │ • Thermal      │  │ • Altitude     │   │
│  │ • Audit log    │  │ • RTL trigger  │  │ • No-fly zones │   │
│  └────────────────┘  └────────────────┘  └────────────────┘   │
│                                                                 │
│  ┌────────────────┐                                            │
│  │    Law 8       │                                            │
│  │   Authority    │                                            │
│  │                │                                            │
│  │ • Approval     │                                            │
│  │ • Risk tiers   │                                            │
│  │ • Operator     │                                            │
│  │   override     │                                            │
│  └────────────────┘                                            │
└─────────────────────────────────────────────────────────────────┘
```

### Law Specifications

#### Law 3: Observation

**Governance Domain:** Telemetry logging, pre-flight validation, audit trail

**Authority Mechanism:** 
- Pre-flight readiness gates prevent arming with failed checks
- Deterministic logging captures all state transitions
- Telemetry must be logged at ≥10Hz during flight

**State Requirements:**
```swift
struct ObservationState {
    var telemetryRate: Frequency       // Must be ≥10Hz when armed
    var lastTelemetryTime: Timestamp   // Staleness detection
    var preFlightChecks: [Check: Status]
    var auditLog: AuditTrail           // SHA256 hash chain
}
```

**Enforcement Rules:**
1. Cannot arm if GPS satellite count < 8
2. Cannot arm if IMU not calibrated
3. Cannot arm if any critical pre-flight check failed
4. Must log telemetry at ≥10Hz during flight
5. Audit log must be append-only with hash chain

**Example Implementation:**
```swift
struct ObservationLaw {
    static let minimumTelemetryRate: TimeInterval = 0.1 // 10Hz
    static let minimumGPSSatellites: Int = 8
    
    static func evaluate(action: FlightAction, 
                        state: FlightState) -> LawEvaluation {
        // Pre-flight validation for arm request
        if case .requestArm = action {
            guard let gps = state.gpsInfo else {
                return .violation(reason: "GPS unavailable")
            }
            
            if gps.satelliteCount < minimumGPSSatellites {
                return .violation(
                    reason: "Insufficient GPS: \(gps.satelliteCount) satellites"
                )
            }
            
            if !state.imuCalibrated {
                return .violation(reason: "IMU not calibrated")
            }
        }
        
        return .compliant
    }
}
```

---

#### Law 4: Resource

**Governance Domain:** Battery management, thermal limits, power constraints

**Authority Mechanism:**
- Automatic RTL trigger at battery threshold
- Critical battery blocks arming
- Thermal monitoring with graceful degradation

**State Requirements:**
```swift
struct ResourceState {
    var battery: BatteryState          // Percentage, voltage, temperature
    var thermalSensors: [ThermalReading]
    var powerConsumption: PowerMetrics
}

struct BatteryState {
    var percentage: Double             // 0.0 - 100.0
    var voltage: Voltage
    var temperature: Temperature
    var cycleCount: Int
    var health: HealthStatus
}
```

**Enforcement Rules:**
1. RTL threshold: 20% (configurable, but ≥15%)
2. Critical battery: 10% (cannot arm below this)
3. Manifold 3 thermal limit: 50°C (graceful degradation)
4. Power budget enforcement for payload operations

**Example Implementation:**
```swift
struct ResourceLaw {
    static let rtlThreshold: Double = 20.0
    static let criticalThreshold: Double = 10.0
    static let maxManifoldTemp: Double = 50.0
    
    static func evaluate(action: FlightAction,
                        state: FlightState) -> LawEvaluation {
        // Block arming with critical battery
        if case .requestArm = action {
            if state.battery.percentage <= criticalThreshold {
                return .violation(
                    reason: "Critical battery: \(state.battery.percentage)%"
                )
            }
        }
        
        // Force RTL at threshold (during flight)
        if state.isArmed && 
           state.battery.percentage <= rtlThreshold {
            return .triggerAction(.returnToLaunch)
        }
        
        // Thermal monitoring
        if let manifoldTemp = state.thermalSensors["manifold3"],
           manifoldTemp > maxManifoldTemp {
            return .warning(
                reason: "Manifold 3 thermal limit approached: \(manifoldTemp)°C",
                suggestion: .degradePerformance
            )
        }
        
        return .compliant
    }
}
```

---

#### Law 7: Spatial

**Governance Domain:** Geofencing, altitude limits, no-fly zones

**Authority Mechanism:**
- Geofence violations prevent arming
- Altitude ceiling enforcement
- No-fly zone database integration

**State Requirements:**
```swift
struct SpatialState {
    var currentPosition: Position?
    var geofence: Geofence?
    var altitudeCeiling: Distance      // AGL (Above Ground Level)
    var noFlyZones: [NoFlyZone]
}

struct Geofence {
    var type: GeofenceType             // .circle, .polygon
    var boundary: GeometryType
    var action: ViolationAction        // .prevent, .warn, .rtl
}

enum GeofenceType {
    case circle(center: Position, radius: Distance)
    case polygon(vertices: [Position])
}
```

**Enforcement Rules:**
1. Position must be inside geofence to arm
2. Cannot exceed altitude ceiling during flight
3. No-fly zones trigger automatic avoidance or RTL
4. Geofence violations during flight trigger RTL

**Example Implementation:**
```swift
struct SpatialLaw {
    static func evaluate(action: FlightAction,
                        state: FlightState) -> LawEvaluation {
        guard let position = state.position,
              let geofence = state.geofence else {
            return .compliant
        }
        
        // Check geofence containment
        if !geofence.contains(position) {
            if case .requestArm = action {
                return .violation(reason: "Position outside geofence")
            } else if state.isArmed {
                return .triggerAction(.returnToLaunch)
            }
        }
        
        // Check altitude ceiling
        if let altitude = state.altitude,
           altitude.agl > state.altitudeCeiling {
            return .violation(
                reason: "Altitude \(altitude.agl)m exceeds ceiling"
            )
        }
        
        // Check no-fly zones
        for zone in state.noFlyZones {
            if zone.contains(position) {
                return .violation(
                    reason: "Inside no-fly zone: \(zone.identifier)"
                )
            }
        }
        
        return .compliant
    }
}
```

---

#### Law 8: Authority

**Governance Domain:** Operator approval, risk-tiered actions, human override

**Authority Mechanism:**
- High-risk actions suspended until operator approval
- Three-tier risk classification
- Operator can override AI proposals

**State Requirements:**
```swift
struct AuthorityState {
    var pendingApprovals: [PendingAction]
    var approvedActions: [ApprovedAction]
    var operatorOverrides: [Override]
}

struct PendingAction {
    var action: FlightAction
    var riskTier: RiskTier
    var proposedBy: AgentIdentifier
    var timestamp: Timestamp
}

enum RiskTier {
    case low                // Auto-approved
    case medium             // Approval with timeout
    case high               // Explicit approval required
}
```

**Enforcement Rules:**
1. **Low-Risk:** Auto-approved (e.g., telemetry logging)
2. **Medium-Risk:** Approval required, 5-second timeout → auto-deny
3. **High-Risk:** Explicit approval required, no timeout (e.g., disarm mid-flight)

**Risk Classification:**

| Action | Risk Tier | Rationale |
|--------|-----------|-----------|
| Log telemetry | Low | No safety impact |
| Change waypoint | Medium | Mission alteration, reversible |
| Return to launch | Medium | Safety action, but aborts mission |
| Disarm mid-flight | High | Immediate crash risk |
| Override geofence | High | Regulatory violation |

**Example Implementation:**
```swift
struct AuthorityLaw {
    static func evaluate(action: FlightAction,
                        state: FlightState) -> LawEvaluation {
        let riskTier = classifyRisk(action, state: state)
        
        switch riskTier {
        case .low:
            return .compliant
            
        case .medium:
            return .requiresApproval(
                timeout: .seconds(5),
                defaultAction: .deny
            )
            
        case .high:
            return .requiresApproval(
                timeout: nil,  // No timeout
                defaultAction: .deny
            )
        }
    }
    
    static func classifyRisk(_ action: FlightAction,
                            state: FlightState) -> RiskTier {
        switch action {
        case .logTelemetry:
            return .low
            
        case .updateWaypoint, .returnToLaunch:
            return .medium
            
        case .disarm where state.isArmed && state.altitude.agl > 1.0:
            return .high  // Mid-flight disarm
            
        case .overrideGeofence, .overrideAltitudeCeiling:
            return .high
            
        default:
            return .medium  // Conservative default
        }
    }
}
```

---

## System Architecture

### Layer Model

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│  • SwiftUI views (operator interface)                          │
│  • Map visualization                                            │
│  • Telemetry displays                                           │
│  • Approval queue UI                                            │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ORCHESTRATION LAYER                          │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              Orchestrator (Actor)                         │ │
│  │  • Action dispatch                                        │ │
│  │  • FlightLaw enforcement                                  │ │
│  │  • State management                                       │ │
│  │  • Audit logging                                          │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                               │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │           FlightLaw Jurisdiction                          │ │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐    │ │
│  │  │  Law 3   │ │  Law 4   │ │  Law 7   │ │  Law 8   │    │ │
│  │  │Observ.   │ │Resource  │ │ Spatial  │ │Authority │    │ │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘    │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │              Core Reducers                                │ │
│  │  • FlightReducer: Aircraft state transitions              │ │
│  │  • MissionReducer: Mission state transitions              │ │
│  │  • SafetyReducer: Safety interlocks                       │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    INFRASTRUCTURE LAYER                         │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │         SwiftVector Core                                  │ │
│  │  • State protocol                                         │ │
│  │  • Action protocol                                        │ │
│  │  • Reducer protocol                                       │ │
│  │  • Audit trail (SHA256 hash chain)                       │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │         Platform Integration                              │ │
│  │  • DJI PSDK V3 wrapper                                    │ │
│  │  • Telemetry processing                                   │ │
│  │  • Command interface                                      │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## Core State Model

### AppState Structure

```swift
struct AppState: State {
    var flight: FlightState
    var mission: MissionState
    var safety: SafetyState
    var audit: AuditState
    
    // State hash for tamper detection
    var stateHash: SHA256Hash {
        SHA256.hash(data: self.canonicalEncoding)
    }
}
```

### FlightState

```swift
struct FlightState {
    // Aircraft status
    var armingStatus: ArmingStatus
    var flightMode: FlightMode
    
    // Position and attitude
    var position: Position?
    var altitude: Altitude?
    var velocity: Velocity?
    var attitude: Attitude?
    
    // Sensors
    var gpsInfo: GPSInfo?
    var imuCalibrated: Bool
    var compassCalibrated: Bool
    
    // Resources
    var battery: BatteryState
    var thermalSensors: [String: Temperature]
    
    // Telemetry
    var lastTelemetryUpdate: Timestamp
    var telemetryRate: Frequency
}

enum ArmingStatus {
    case disarmed
    case armingRequested
    case armed
    case disarmingRequested
}

enum FlightMode {
    case manual
    case assisted
    case autonomous
    case returnToLaunch
    case emergency
}
```

### MissionState

```swift
struct MissionState {
    var currentMission: Mission?
    var waypoints: [Waypoint]
    var currentWaypointIndex: Int?
    var geofence: Geofence?
    var altitudeCeiling: Distance
    var noFlyZones: [NoFlyZone]
}

struct Mission {
    var identifier: MissionID
    var name: String
    var type: MissionType
    var createdAt: Timestamp
    var estimatedDuration: TimeInterval
    var safetyParameters: SafetyParameters
}

struct SafetyParameters {
    var batteryRTLThreshold: Double
    var maxWindSpeed: Speed
    var maxDistance: Distance
}
```

### SafetyState

```swift
struct SafetyState {
    var preFlightChecks: [Check: CheckStatus]
    var activeLaws: [Law]
    var violations: [LawViolation]
    var warnings: [Warning]
    var pendingApprovals: [PendingApproval]
}

struct Check {
    var identifier: String
    var category: CheckCategory
    var isCritical: Bool
}

enum CheckCategory {
    case gps
    case imu
    case compass
    case battery
    case motors
    case communication
}

struct LawViolation {
    var law: Law
    var reason: String
    var timestamp: Timestamp
    var action: FlightAction
    var state: AppState  // State at time of violation
}
```

### AuditState

```swift
struct AuditState {
    var entries: [AuditEntry]
    var hashChain: [SHA256Hash]
    var sessionID: SessionID
    var startTime: Timestamp
}

struct AuditEntry {
    var sequenceNumber: Int
    var timestamp: Timestamp
    var action: FlightAction
    var stateBefore: AppState
    var stateAfter: AppState
    var lawEvaluations: [LawEvaluation]
    var previousHash: SHA256Hash
    var entryHash: SHA256Hash
}
```

---

## Core Actions

```swift
enum AppAction: Action {
    case flight(FlightAction)
    case mission(MissionAction)
    case safety(SafetyAction)
    case system(SystemAction)
}

enum FlightAction {
    case requestArm
    case confirmArm
    case requestDisarm
    case updatePosition(Position)
    case updateAltitude(Altitude)
    case updateBattery(BatteryState)
    case updateTelemetry(TelemetryData)
    case returnToLaunch
    case emergencyLand
}

enum MissionAction {
    case loadMission(Mission)
    case startMission
    case pauseMission
    case resumeMission
    case abortMission
    case updateWaypoint(Waypoint, at: Int)
    case advanceToNextWaypoint
}

enum SafetyAction {
    case runPreFlightChecks
    case approveAction(ActionID)
    case denyAction(ActionID)
    case acknowledgeWarning(WarningID)
    case overrideLaw(Law, reason: String)  // High-risk, requires approval
}

enum SystemAction {
    case initialize
    case shutdown
    case exportAuditLog(destination: URL)
    case replaySession(sessionID: SessionID)
}
```

---

## FlightLaw Enforcer

```swift
actor FlightLawEnforcer {
    
    func evaluate(action: AppAction, 
                 state: AppState) -> EnforcementResult {
        var evaluations: [LawEvaluation] = []
        
        // Law 3: Observation
        let law3 = ObservationLaw.evaluate(action: action, state: state)
        evaluations.append(law3)
        if case .violation = law3.result {
            return .rejected(reason: law3.reason, evaluations: evaluations)
        }
        
        // Law 4: Resource
        let law4 = ResourceLaw.evaluate(action: action, state: state)
        evaluations.append(law4)
        if case .violation = law4.result {
            return .rejected(reason: law4.reason, evaluations: evaluations)
        }
        if case .triggerAction(let triggeredAction) = law4.result {
            return .triggersAction(triggeredAction, evaluations: evaluations)
        }
        
        // Law 7: Spatial
        let law7 = SpatialLaw.evaluate(action: action, state: state)
        evaluations.append(law7)
        if case .violation = law7.result {
            return .rejected(reason: law7.reason, evaluations: evaluations)
        }
        
        // Law 8: Authority
        let law8 = AuthorityLaw.evaluate(action: action, state: state)
        evaluations.append(law8)
        if case .requiresApproval = law8.result {
            return .pendingApproval(
                reason: law8.reason,
                evaluations: evaluations
            )
        }
        
        return .permitted(evaluations: evaluations)
    }
}

enum EnforcementResult {
    case permitted(evaluations: [LawEvaluation])
    case rejected(reason: String, evaluations: [LawEvaluation])
    case pendingApproval(reason: String, evaluations: [LawEvaluation])
    case triggersAction(FlightAction, evaluations: [LawEvaluation])
}

struct LawEvaluation {
    var law: Law
    var result: EvaluationResult
    var reason: String?
}

enum EvaluationResult {
    case compliant
    case violation
    case warning
    case requiresApproval(timeout: TimeInterval?, defaultAction: ApprovalDefault)
    case triggerAction(FlightAction)
}
```

---

## Orchestrator

```swift
actor Orchestrator {
    private var state: AppState
    private var auditLog: AuditLog
    private let enforcer: FlightLawEnforcer
    private let reducer: FlightReducer
    
    init(initialState: AppState = .initial) {
        self.state = initialState
        self.auditLog = AuditLog(sessionID: UUID())
        self.enforcer = FlightLawEnforcer()
        self.reducer = FlightReducer()
    }
    
    func dispatch(_ action: AppAction) async -> DispatchResult {
        let stateBefore = state
        
        // Step 1: FlightLaw enforcement
        let enforcementResult = await enforcer.evaluate(
            action: action,
            state: state
        )
        
        switch enforcementResult {
        case .rejected(let reason, let evaluations):
            // Log rejection
            await auditLog.append(
                AuditEntry(
                    action: action,
                    stateBefore: stateBefore,
                    stateAfter: stateBefore,  // No change
                    result: .rejected(reason),
                    lawEvaluations: evaluations
                )
            )
            return .rejected(reason: reason)
            
        case .pendingApproval(let reason, let evaluations):
            // Queue for operator approval
            state = reducer.reduce(
                state: state,
                action: .safety(.queueApproval(action, reason: reason))
            )
            return .pendingApproval(reason: reason)
            
        case .triggersAction(let triggeredAction, let evaluations):
            // Law triggered automatic action (e.g., RTL)
            await dispatch(triggeredAction)
            return .actionTriggered(triggeredAction)
            
        case .permitted(let evaluations):
            // Step 2: Apply Reducer
            let stateAfter = reducer.reduce(state: state, action: action)
            
            // Step 3: Update state
            state = stateAfter
            
            // Step 4: Log to audit trail
            await auditLog.append(
                AuditEntry(
                    action: action,
                    stateBefore: stateBefore,
                    stateAfter: stateAfter,
                    result: .permitted,
                    lawEvaluations: evaluations
                )
            )
            
            return .success(newState: stateAfter)
        }
    }
    
    func getCurrentState() -> AppState {
        state
    }
    
    func exportAuditLog() -> AuditLog {
        auditLog
    }
}

enum DispatchResult {
    case success(newState: AppState)
    case rejected(reason: String)
    case pendingApproval(reason: String)
    case actionTriggered(FlightAction)
}
```

---

## Audit Trail

### Hash Chain Implementation

```swift
struct AuditLog {
    private(set) var entries: [AuditEntry] = []
    let sessionID: SessionID
    let startTime: Timestamp = .now()
    
    mutating func append(_ entry: AuditEntry) {
        let previousHash = entries.last?.entryHash ?? SHA256Hash.genesis
        
        var newEntry = entry
        newEntry.sequenceNumber = entries.count
        newEntry.previousHash = previousHash
        newEntry.entryHash = computeEntryHash(entry, previousHash: previousHash)
        
        entries.append(newEntry)
    }
    
    func verify() -> Bool {
        guard !entries.isEmpty else { return true }
        
        var expectedPreviousHash = SHA256Hash.genesis
        
        for entry in entries {
            // Verify hash chain link
            guard entry.previousHash == expectedPreviousHash else {
                return false
            }
            
            // Verify entry hash
            let computedHash = computeEntryHash(entry, 
                                               previousHash: entry.previousHash)
            guard entry.entryHash == computedHash else {
                return false
            }
            
            expectedPreviousHash = entry.entryHash
        }
        
        return true
    }
    
    private func computeEntryHash(_ entry: AuditEntry, 
                                 previousHash: SHA256Hash) -> SHA256Hash {
        var hasher = SHA256()
        hasher.update(data: previousHash.data)
        hasher.update(data: entry.sequenceNumber.data)
        hasher.update(data: entry.timestamp.data)
        hasher.update(data: entry.action.canonicalEncoding)
        hasher.update(data: entry.stateBefore.stateHash.data)
        hasher.update(data: entry.stateAfter.stateHash.data)
        
        return SHA256Hash(hasher.finalize())
    }
}
```

### Replay Engine

```swift
struct ReplayEngine {
    func replay(auditLog: AuditLog, 
               from initialState: AppState) async throws -> AppState {
        // Verify audit log integrity
        guard auditLog.verify() else {
            throw ReplayError.auditLogCorrupted
        }
        
        var currentState = initialState
        let reducer = FlightReducer()
        
        for entry in auditLog.entries {
            // Apply action to current state
            let newState = reducer.reduce(
                state: currentState,
                action: entry.action
            )
            
            // Verify determinism: replayed state must match logged state
            guard newState.stateHash == entry.stateAfter.stateHash else {
                throw ReplayError.nondeterministicBehavior(
                    sequenceNumber: entry.sequenceNumber,
                    expected: entry.stateAfter.stateHash,
                    actual: newState.stateHash
                )
            }
            
            currentState = newState
        }
        
        return currentState
    }
}

enum ReplayError: Error {
    case auditLogCorrupted
    case nondeterministicBehavior(sequenceNumber: Int, 
                                 expected: SHA256Hash, 
                                 actual: SHA256Hash)
}
```

---

## Extension Points for Jurisdictions

Mission-specific jurisdictions (ThermalLaw, SurveyLaw) extend FlightLaw by:

### 1. Adding Domain-Specific State

```swift
// Example: ThermalLaw extension
extension AppState {
    var thermal: ThermalState {
        get { /* ... */ }
        set { /* ... */ }
    }
}

struct ThermalState {
    var detections: [ThermalAnomaly]
    var mlModel: ModelState
    var thresholds: TemperatureThresholds
}
```

### 2. Adding Domain-Specific Actions

```swift
enum ThermalAction {
    case runInference(frame: ThermalFrame)
    case flagAnomaly(detection: ThermalDetection)
    case approveAnomaly(id: AnomalyID)
    case updateThresholds(TemperatureThresholds)
}
```

### 3. Adding Domain-Specific Laws

```swift
// ThermalLaw adds additional constraints
struct ThermalLaw {
    static func evaluate(action: ThermalAction,
                        state: AppState) -> LawEvaluation {
        // Temperature threshold enforcement
        // ML confidence validation
        // Operator approval for anomalies
    }
}
```

### 4. Composing with FlightLaw

```swift
// ThermalLaw enforcer composes FlightLaw + ThermalLaw
actor ThermalLawEnforcer {
    private let flightEnforcer = FlightLawEnforcer()
    
    func evaluate(action: AppAction,
                 state: AppState) async -> EnforcementResult {
        // First: Apply FlightLaw
        let flightResult = await flightEnforcer.evaluate(
            action: action,
            state: state
        )
        
        guard case .permitted = flightResult else {
            return flightResult  // FlightLaw rejection takes precedence
        }
        
        // Second: Apply ThermalLaw (if applicable)
        if let thermalAction = action.asThermalAction {
            return await ThermalLaw.evaluate(
                action: thermalAction,
                state: state
            )
        }
        
        return flightResult
    }
}
```

---

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **DJI Matrice 4T** | ✅ Primary | Thermal imaging platform |
| **DJI Matrice 4E** | ✅ Supported | Survey/mapping platform |
| **Manifold 3** | 🔄 Testing | Onboard compute |
| **iOS 17+** | ✅ Primary | iPad operator interface |
| **Ubuntu 20.04** | 🔄 Testing | Manifold 3 deployment |

---

## Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| Telemetry rate | ≥10Hz | Message rate counter |
| State transition latency | <10ms | Reducer timing |
| Audit log write | <5ms | Append operation timing |
| Law evaluation | <5ms | Enforcement timing |
| Memory usage (core) | <100MB | Process monitor |

---

## Security Model

### Threat Mitigation

| Threat | Mitigation |
|--------|------------|
| **Audit log tampering** | SHA256 hash chain, tamper-evident |
| **State corruption** | Actor isolation, immutable state |
| **Unauthorized actions** | FlightLaw enforcement, typed actions |
| **Replay attacks** | Session ID, timestamp validation |

### Security Invariants

1. **State cannot be mutated outside Reducer** — Compiler-enforced via Actor
2. **Actions cannot bypass FlightLaw** — All dispatch goes through Enforcer
3. **Audit log cannot be modified** — Append-only with hash chain
4. **Laws cannot be disabled at runtime** — Compile-time configuration

---

## Testing Strategy

### Determinism Verification

```swift
func testReducerDeterminism() async throws {
    let reducer = FlightReducer()
    let initialState = AppState.mock()
    let action = FlightAction.updateBattery(
        BatteryState(percentage: 75.0)
    )
    
    // Execute 1000 times
    var results: [AppState] = []
    for _ in 0..<1000 {
        let result = reducer.reduce(state: initialState, action: action)
        results.append(result)
    }
    
    // All results must be identical
    let firstHash = results[0].stateHash
    for result in results {
        XCTAssertEqual(result.stateHash, firstHash)
    }
}
```

### FlightLaw Compliance

```swift
func testBatteryLaw() async throws {
    let enforcer = FlightLawEnforcer()
    let criticalBatteryState = AppState.mock(
        battery: BatteryState(percentage: 9.0)
    )
    
    let result = await enforcer.evaluate(
        action: .flight(.requestArm),
        state: criticalBatteryState
    )
    
    guard case .rejected(let reason, _) = result else {
        XCTFail("Expected rejection")
        return
    }
    
    XCTAssertTrue(reason.contains("Critical battery"))
}
```

### Audit Trail Integrity

```swift
func testAuditLogIntegrity() {
    var log = AuditLog(sessionID: UUID())
    
    // Add entries
    for i in 0..<100 {
        log.append(AuditEntry.mock(sequenceNumber: i))
    }
    
    // Verify integrity
    XCTAssertTrue(log.verify())
    
    // Tamper with entry
    log.entries[50].stateAfter = AppState.mock()
    
    // Verification should fail
    XCTAssertFalse(log.verify())
}
```

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [Flightworks-Suite-Overview.md](./Flightworks-Suite-Overview.md) | Suite architecture |
| [PRD-FlightworksCore.md](./PRD-FlightworksCore.md) | Core requirements |
| [SwiftVector-Codex.md](./SwiftVector-Codex.md) | Constitutional framework |
| [HLD-FlightworksThermal.md](./HLD-FlightworksThermal.md) | ThermalLaw extension |
| [HLD-FlightworksSurvey.md](./HLD-FlightworksSurvey.md) | SurveyLaw extension |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Feb 2026 | S. Sweeney | Initial FlightLaw HLD (extracted from Flightworks Control) |

---

**Document Control**

- **Owner:** Stephen Sweeney, Flightworks Aerial LLC
- **Review Cycle:** Monthly or upon architectural changes
- **Distribution:** Internal, open source, research publications

---

## Conclusion

Flightworks Core (FlightLaw) provides the **universal safety kernel** for all drone operations in the Flightworks Suite. By implementing the SwiftVector Codex principles in a platform-specific way, it creates a foundation that is:

- **Deterministic:** Same inputs → same outputs, always
- **Auditable:** Every state transition logged with tamper-evident hash chain
- **Extensible:** Mission-specific jurisdictions compose cleanly with FlightLaw
- **Certifiable:** Architectural proofs of safety properties

This is not a GCS application—it is the **constitutional infrastructure** upon which mission-specific applications are built. ThermalLaw and SurveyLaw inherit these guarantees while adding domain-specific governance.

The result is a suite of applications that share safety logic, audit infrastructure, and deterministic guarantees while serving distinct market needs.
