# Flightworks Fire: High-Level Design (FireLaw Jurisdiction)

**Document:** HLD-FF-FIRE-2026-001  
**Version:** 0.1 (Draft)  
**Date:** February 2026  
**Author:** Stephen Sweeney, Flightworks Aerial LLC  
**Status:** Architecture Draft  
**Classification:** Public

---

## Document Purpose

This High-Level Design (HLD) specifies **Flightworks Fire**—the FireLaw jurisdiction that extends FlightLaw for wildfire perimeter monitoring and hotspot triage operations. FireLaw is the first jurisdiction to exercise **multi-asset governance**, **extended autonomous operations**, and **escalation-tier authority**—capabilities that ThermalLaw and SurveyLaw do not require.

**FireLaw = FlightLaw + Fire-Specific Governance**

**Scope:**
- FireLaw jurisdiction specification (Law composition and extensions)
- Escalation-tier authority model (overnight autonomy governance)
- Multi-asset delegation and task lease governance
- Degraded mode behaviors (comms loss, sensor degradation)
- Sector-based coverage governance
- Evidence package and after-action audit
- Airspace deconfliction governance (manned aircraft integration)

**Out of Scope:**
- Swarm coordination algorithms (ISRLaw / future jurisdiction)
- Hardware-specific dock integration details
- Thermal ML model architecture (sensor pipeline is bought, governance is built)
- ICS/dispatch system integration protocols (Phase 2+)

---

## Architectural Philosophy

### Why FireLaw Matters to the Codex

ThermalLaw proves SwiftVector governs a **single asset performing inspection with operator present**. That is a necessary but insufficient demonstration of the architecture's power.

FireLaw proves SwiftVector governs **multiple assets performing autonomous monitoring with operator absent or degraded**. This is the hard problem—the one where deterministic governance justifies its architectural cost.

The overnight wildfire perimeter scenario creates governance pressure that no other jurisdiction exercises:

| Governance Pressure | ThermalLaw | SurveyLaw | FireLaw |
|---------------------|:----------:|:---------:|:-------:|
| Multi-asset coordination | — | — | ✓ |
| Extended autonomous ops (hours) | — | — | ✓ |
| Operator absent or degraded | — | — | ✓ |
| Dynamic mission re-planning | — | — | ✓ |
| Escalation to external authority (IC) | — | — | ✓ |
| Manned aircraft deconfliction | — | — | ✓ |
| Degraded comms governance | Minimal | Minimal | Critical |
| Law 2 (Delegation) required | — | — | ✓ |
| Law 6 (Persistence) required | — | — | ✓ |

FireLaw is the jurisdiction that proves the Codex scales.

### The Determinism Boundary

```
┌──────────────────────────────────────────────────────────────────┐
│                    STOCHASTIC ZONE                                │
│  (Non-deterministic, probabilistic)                              │
│                                                                  │
│  • Thermal sensor radiometric data (noise, calibration, smoke)   │
│  • Wind model predictions (speed, direction, gust probability)   │
│  • ML hotspot detection (probabilistic confidence scores)        │
│  • Fire behavior modeling (spread rate estimation)               │
│  • Comms link quality (signal propagation, interference)         │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│              ▼ DETERMINISM BOUNDARY ▼                             │
│         (FireLaw governance applies here)                        │
├──────────────────────────────────────────────────────────────────┤
│                    DETERMINISTIC ZONE                             │
│  (Same inputs → same outputs, auditable, replayable)             │
│                                                                  │
│  • Hotspot classification: confidence → severity band            │
│  • Escalation tier assignment: inputs → tier (deterministic)     │
│  • Sector coverage freshness: scan time → freshness state        │
│  • Task lease allocation: resource state → assignment            │
│  • Degraded mode transitions: link state → autonomy envelope     │
│  • Authority requirements: tier → who must approve               │
│  • Audit entries: every transition → SHA256 hash chain           │
└──────────────────────────────────────────────────────────────────┘
```

### Business Guarantee

> **"Every hotspot detection, every escalation decision, every task assignment, and every coverage gap is deterministically reproducible, auditable, and attributable. The system never pretends certainty it does not have."**

---

## Composed Laws

FireLaw is the most comprehensive jurisdiction in the Flightworks Suite, composing seven Laws from the SwiftVector Codex:

```
FireLaw = FlightLaw ∘ FireGovernance

where:
  FlightLaw        = Law 3 ∘ Law 4 ∘ Law 7 ∘ Law 8
  FireGovernance   = Law 2 ∘ Law 6 ∘ FireEscalation ∘ FireCoverage ∘ FireDeconfliction

  Full composition = Law 2 ∘ Law 3 ∘ Law 4 ∘ Law 6 ∘ Law 7 ∘ Law 8
                     + FireEscalation + FireCoverage + FireDeconfliction
```

### Law Composition Detail

```
┌─────────────────────────────────────────────────────────────────────┐
│                    FIRELAW JURISDICTION                              │
│              (Wildfire Perimeter Monitoring)                         │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  INHERITED FROM FLIGHTLAW (Universal Safety Kernel)           │  │
│  │                                                                │  │
│  │  Law 3 (Observation)  │ Law 4 (Resource)  │ Law 7 (Spatial)   │  │
│  │  • Telemetry          │ • Battery mgmt    │ • Geofence        │  │
│  │  • Pre-flight         │ • RTL triggers    │ • Altitude bands  │  │
│  │  • Audit logging      │ • Fleet endurance │ • TFR compliance  │  │
│  │                       │                   │ • No-fly zones    │  │
│  │                                                                │  │
│  │  Law 8 (Authority)                                             │  │
│  │  • Risk-tiered approval                                        │  │
│  │  • Operator authority chain                                    │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  NEW IN FIRELAW (Fire-Specific Governance)                    │  │
│  │                                                                │  │
│  │  Law 2 (Delegation)        │ Law 6 (Persistence)              │  │
│  │  • Task lease authority    │ • Perimeter state integrity      │  │
│  │  • Drone→drone handoff     │ • Detection history immutability │  │
│  │  • Permission inheritance  │ • Sector assignment persistence  │  │
│  │  • Partition recovery      │ • Evidence chain protection      │  │
│  │                                                                │  │
│  │  FireEscalation            │ FireCoverage                     │  │
│  │  • 4-tier severity model   │ • Sector freshness tracking     │  │
│  │  • Deterministic triggers  │ • Coverage gap prediction       │  │
│  │  • IC notification rules   │ • Re-tasking governance         │  │
│  │  • Authority mapping       │ • Swap scheduling               │  │
│  │                                                                │  │
│  │  FireDeconfliction                                             │  │
│  │  • Manned aircraft response                                    │  │
│  │  • Altitude band management                                    │  │
│  │  • Temporal airspace reservations                              │  │
│  │  • TFR dynamic compliance                                      │  │
│  └────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### Why Law 2 and Law 6

**Law 2 (Delegation)** is required because FireLaw governs multiple autonomous agents that must hand off tasks without operator intervention. When Drone A's battery triggers RTL, its sector scan task must transfer to Drone B. Law 2 ensures this delegation cannot escalate authority—Drone B inherits exactly the permissions Drone A held, no more. The task lease is the delegation mechanism: bounded in time, bounded in scope, revocable by the GCS.

**Law 6 (Persistence)** is required because fire perimeter state is safety-critical world knowledge that must not be corrupted. A sector marked as "scanned at 02:17, no detections" cannot be retroactively reclassified by a sensor recalibration or a late-arriving inference result. Law 6 locks perimeter facts at the moment they're established. If new information contradicts prior state, it creates a *new* detection event—it does not mutate the historical record. This is essential for after-action review and liability.

---

## Domain Model

### FireState

```swift
struct FireState: State {
    // === Incident Context ===
    let incidentID: IncidentID
    let incidentName: String
    let sopTemplate: SOPTemplate              // "Overnight Perimeter v1"
    let activeSince: Timestamp
    
    // === Perimeter ===
    let perimeter: PerimeterState             // The fire boundary
    let sectors: [SectorID: SectorState]      // Sector decomposition
    
    // === Detections ===
    let detections: [DetectionID: HotspotDetection]  // All detections (Law 6: immutable once committed)
    let triageQueue: TriageQueue              // Ranked pending detections
    
    // === Fleet ===
    let fleet: FleetState                     // All assets + readiness
    let taskLeases: [LeaseID: TaskLease]      // Active task assignments (Law 2)
    let taskPool: [UnassignedTask]            // Tasks awaiting assignment
    
    // === Coverage ===
    let coverageMap: CoverageMap              // Per-sector freshness
    let coveragePolicy: CoveragePolicy        // Freshness thresholds, priority weights
    
    // === Authority ===
    let escalationState: EscalationState      // Current tier, pending notifications
    let authorityChain: AuthorityChain        // IC → UAS Supervisor → Remote Pilot
    let operatorPresence: OperatorPresence    // .active, .monitoring, .dormant
    
    // === Airspace ===
    let airspaceState: AirspaceState          // TFR, manned aircraft, deconfliction mode
    
    // === Comms ===
    let commsHealth: CommsHealthState         // Per-drone link quality, mesh topology
    let degradedMode: DegradedModeState       // Current autonomy envelope
    
    // === Environment ===
    let weatherContext: WeatherContext         // Wind, humidity, temperature (inputs to escalation)
    
    // === Audit ===
    let auditTrail: AuditTrail               // SHA256 hash chain (Law 3)
}
```

### Key Domain Types

```swift
// === Sector Governance ===

struct SectorState: State {
    let sectorID: SectorID
    let boundary: GeoBoundary                 // Polygon defining sector
    let priority: SectorPriority              // .critical, .high, .standard, .low
    let priorityReason: PriorityReason        // Why this priority (wind, WUI, slope, structures)
    let lastScanCompleted: Timestamp?
    let freshness: FreshnessState             // .fresh, .aging, .stale, .unknown
    let assignedDrone: DroneID?
    let activeLease: LeaseID?
    let detectionCount: Int
    let lastDetectionTime: Timestamp?
}

enum FreshnessState: Equatable {
    case fresh                                // Scanned within policy threshold
    case aging(secondsSinceScan: TimeInterval) // Approaching staleness
    case stale                                // Exceeds freshness policy
    case unknown                              // Never scanned or data unreliable
}

enum SectorPriority: Comparable {
    case critical                             // Windward edge, WUI exposure, active spots
    case high                                 // Known risk factors
    case standard                             // Normal monitoring
    case low                                  // Lee side, low fuel, wet terrain
}

// === Hotspot Detection ===

struct HotspotDetection: State {
    let detectionID: DetectionID
    let timestamp: Timestamp
    let location: GeoCoordinate
    let sectorID: SectorID
    let droneID: DroneID
    
    // Stochastic inputs (recorded but not trusted as truth)
    let rawConfidence: Double                 // ML output [0.0, 1.0]
    let rawTemperature: Temperature?          // Radiometric reading
    let sensorConditions: SensorConditions    // Smoke density, distance, angle
    
    // Deterministic classification (FireLaw governance)
    let severityBand: SeverityBand            // Deterministic mapping from inputs
    let escalationTier: EscalationTier        // What authority is required
    let verificationStatus: VerificationStatus
    
    // Evidence linkage
    let thermalFrameID: FrameID
    let rgbFrameID: FrameID?
    let auditHash: SHA256Hash                 // Law 3: hash at time of detection
}

enum SeverityBand: Comparable {
    case low                                  // Residual heat, cooling signature
    case moderate                             // Active heat, contained within perimeter
    case high                                 // Active heat outside perimeter OR near structures
    case critical                             // Multiple indicators of escape or blowup
}

// === Task Lease Governance (Law 2) ===

struct TaskLease: State {
    let leaseID: LeaseID
    let taskType: FireTaskType
    let assignedDrone: DroneID
    let sectorID: SectorID?
    let grantedAt: Timestamp
    let expiresAt: Timestamp                  // Lease duration (typically 60-120s)
    let renewalCount: Int
    let maxRenewals: Int                      // Prevents indefinite lease holding
    let parentAuthority: AuthorityLevel       // Law 2: inherited from GCS
    let status: LeaseStatus
}

enum FireTaskType {
    case sectorScan(SectorID)                 // Systematic thermal scan
    case hotspotVerify(DetectionID)           // Orbit and verify a detection
    case perimeterUpdate(SegmentID)           // Update perimeter boundary
    case commsRelay(RelayPosition)            // Hold position as mesh node
    case overwatchHold(SectorID)              // Persistent observation of priority sector
    case rtlAndSwap                           // Return for battery swap
}

enum LeaseStatus {
    case active
    case expiring(secondsRemaining: TimeInterval)
    case expired                              // Task returns to pool
    case completed
    case revoked(reason: RevocationReason)    // GCS recalled the lease
}

// === Escalation Governance ===

enum EscalationTier: Comparable {
    case routine                              // Autonomous operation, log only
    case elevated                             // Notify operator, queue for review
    case critical                             // Require operator approval before action
    case emergency                            // Wake IC, present situation summary
}

// === Operator Presence ===

enum OperatorPresence {
    case active                               // Operator at console, <30s response expected
    case monitoring                           // Operator available, <5min response expected
    case dormant                              // Operator asleep/away, >5min response expected
    case unreachable                          // No operator contact confirmed
}

// === Degraded Mode ===

struct DegradedModeState: State {
    let mode: DegradedMode
    let degradedSince: Timestamp?
    let autonomyEnvelope: AutonomyEnvelope    // What the system is allowed to do
    let lastOperatorContact: Timestamp
    let lastGCSHeartbeat: Timestamp
}

enum DegradedMode {
    case nominal                              // Full comms, full authority
    case reducedBandwidth                     // Telemetry only, no video
    case intermittent                         // Periodic dropouts, leases shortened
    case droneIsolated(DroneID)               // Specific drone lost comms
    case gcsIsolated                          // GCS lost uplink to all drones
    case fullPartition                        // No comms at all
}
```

---

## FireLaw Escalation Model

This is the core governance innovation of FireLaw: **deterministic escalation from sensor inputs to authority requirements**.

### The Escalation Function

```
EscalationTier = f(detection, sector, weather, fleet, operatorPresence)
```

This function is **pure**. Same inputs always produce the same tier. The inputs are typed, the thresholds are configured in the SOP template, and every evaluation is logged.

### Tier Definitions

**Tier 1: ROUTINE** — Autonomous operation, log only.

The system continues its mission without operator involvement. All actions at this tier are pre-authorized by the mission SOP.

Triggers:
- Detections within known perimeter with confidence < moderate threshold
- Sector scans completing normally
- Coverage freshness within policy
- Battery swaps proceeding on schedule
- All drones healthy, all leases active

Authority: None required. Pre-authorized by SOP acceptance at mission start.

**Tier 2: ELEVATED** — Notify operator, queue for review.

The system has detected something that warrants operator awareness but does not require immediate action. The operator can review at their pace.

Triggers:
- New detection outside perimeter, low confidence
- Detection in non-priority sector
- Sector freshness approaching stale in standard-priority sector
- Single drone entering degraded comms
- Weather data suggesting wind shift within 2 hours

Authority: Operator notified. Review expected within operator presence SLA. System continues mission. If operator does not review within SLA, auto-escalates to CRITICAL.

**Tier 3: CRITICAL** — Require operator approval before significant action.

The system has detected a condition that requires human judgment before changing mission behavior. The system presents its recommendation but does not act on it.

Triggers:
- High-confidence detection outside perimeter in priority sector
- Detection suggesting perimeter breach toward WUI (structures)
- Priority sector going stale during high-wind conditions
- Multiple simultaneous detections in different sectors
- Manned aircraft entering operational area (deconfliction mode activation)
- Any detection where system recommends tasking ground resources

Authority: Operator must explicitly approve or reject the recommended action. System presents: detection data, recommended response, confidence assessment, and what happens if no action is taken. Timeout behavior: if operator does not respond within SOP-defined window, escalates to EMERGENCY.

**Tier 4: EMERGENCY** — Wake IC, present situation summary.

Conditions suggest potential for significant fire behavior change that exceeds operator authority or requires incident-level response.

Triggers:
- Multiple high-confidence detections suggesting blowup conditions
- Loss of coverage in critical sector during wind event (coverage + weather compound)
- Operator unreachable for longer than SOP-defined window during CRITICAL event
- Full fleet degradation (all drones in reduced capability)
- System unable to maintain minimum coverage guarantee

Authority: IC notification via configured channel. System presents: complete situation summary, timeline of detections, coverage state, fleet state, recommended actions. System enters conservative mode—maintains current positions, does not re-task without IC or operator direction.

### Escalation as a Pure Function

```swift
struct EscalationEvaluator {
    
    /// Pure function: same inputs → same tier, always.
    /// Every evaluation is logged to the audit trail.
    static func evaluate(
        detection: HotspotDetection?,
        sector: SectorState,
        weather: WeatherContext,
        fleet: FleetState,
        coverage: CoverageMap,
        operatorPresence: OperatorPresence,
        policy: EscalationPolicy              // From SOP template
    ) -> EscalationResult {
        
        var tier: EscalationTier = .routine
        var reasons: [EscalationReason] = []
        
        // --- Detection-driven escalation ---
        if let detection = detection {
            
            // Outside perimeter is always at least elevated
            if detection.location.isOutside(sector.boundary) {
                tier = max(tier, .elevated)
                reasons.append(.detectionOutsidePerimeter)
                
                // High confidence + priority sector = critical
                if detection.severityBand >= .high && sector.priority >= .high {
                    tier = max(tier, .critical)
                    reasons.append(.highSeverityInPrioritySector)
                }
                
                // Toward structures = critical
                if detection.location.isToward(wuiExposure: sector.priorityReason) {
                    tier = max(tier, .critical)
                    reasons.append(.detectionTowardStructures)
                }
            }
        }
        
        // --- Coverage-driven escalation ---
        if sector.freshness == .stale && sector.priority >= .high {
            tier = max(tier, .elevated)
            reasons.append(.prioritySectorStale)
            
            if weather.windSpeed >= policy.highWindThreshold {
                tier = max(tier, .critical)
                reasons.append(.staleSectorDuringHighWind)
            }
        }
        
        // --- Fleet-driven escalation ---
        let healthyDrones = fleet.dronesWithStatus(.healthy)
        if healthyDrones.count < policy.minimumFleetSize {
            tier = max(tier, .critical)
            reasons.append(.fleetBelowMinimum)
        }
        
        // --- Compound escalation to emergency ---
        let criticalReasons = reasons.filter { $0.baseTier >= .critical }
        if criticalReasons.count >= policy.emergencyCompoundThreshold {
            tier = .emergency
            reasons.append(.compoundCriticalConditions)
        }
        
        // --- Operator presence modifier ---
        if tier >= .critical && operatorPresence == .unreachable {
            tier = .emergency
            reasons.append(.operatorUnreachableDuringCritical)
        }
        
        return EscalationResult(
            tier: tier,
            reasons: reasons,
            timestamp: .now,
            inputHash: hashInputs(detection, sector, weather, fleet, coverage, operatorPresence)
        )
    }
}
```

### Escalation Timeout Ladder

When an escalation event is not acknowledged within its tier's SLA, it automatically promotes to the next tier. This prevents a sleeping operator from causing a detection to be silently dropped.

```
ELEVATED (unacknowledged)
    → after operatorPresence.sla expires
    → promotes to CRITICAL

CRITICAL (unacknowledged)  
    → after policy.criticalTimeoutSeconds
    → promotes to EMERGENCY

EMERGENCY (unacknowledged)
    → system enters CONSERVATIVE MODE
    → all drones hold current positions
    → continuous notification to IC + backup contacts
    → audit log records: "Emergency unacknowledged, conservative mode activated"
```

This timeout ladder is itself deterministic—the SLA values are set in the SOP template at mission start and do not change during the mission.

---

## Task Lease Governance (Law 2 Implementation)

### The Lease Model

Task leases are the mechanism by which FireLaw governs multi-asset operations while preserving the Agency Paradox. The GCS does not *command* drones to perform tasks. It *leases* task authority to drones under constrained terms.

```
GCS (holds mission authority from operator)
  │
  ├── Lease: "Scan Sector 3" → Drone A (90s, renewable, revocable)
  ├── Lease: "Verify Detection #17" → Drone B (120s, non-renewable)
  ├── Lease: "Comms Relay Position" → Drone C (180s, renewable)
  └── Pool: [Scan Sector 5, Scan Sector 7] (unassigned, awaiting resources)
```

### Law 2 Constraints on Leases

Law 2 (Delegation) requires that delegated authority cannot exceed the delegator's authority. In FireLaw, this manifests as:

1. **No authority escalation through leases.** A drone cannot acquire authority its lease does not grant. A drone leased for "Scan Sector 3" cannot decide to "Verify Detection" without a new lease.

2. **Lease expiration returns authority to the pool.** When a lease expires without renewal, the task returns to the unassigned pool. The drone does not keep working on the task—it enters a holding state and awaits re-tasking.

3. **Revocation is immediate and unconditional.** The GCS can revoke any lease at any time. This is the mechanism for re-prioritization—if a critical detection occurs, existing leases on lower-priority tasks can be revoked and reassigned.

4. **Handoff preserves audit continuity.** When Drone A's lease on Sector 3 expires and Drone B takes over, the audit trail records: Lease L1 (Drone A, Sector 3) → expired → Task returned to pool → Lease L2 (Drone B, Sector 3) granted. There is no gap in accountability.

### Lease Allocation

Lease allocation is deterministic given the current state. The allocator considers:

```swift
struct LeaseAllocator {
    
    /// Pure function: given fleet state and task pool, produce assignments.
    /// Allocation priority:
    ///   1. Coverage gaps in critical sectors (freshness-driven)
    ///   2. Pending verifications (detection-driven)
    ///   3. Coverage gaps in standard sectors
    ///   4. Comms relay needs
    ///   5. Overwatch holds
    static func allocate(
        taskPool: [UnassignedTask],
        fleet: FleetState,
        coverage: CoverageMap,
        policy: AllocationPolicy
    ) -> [LeaseGrant] {
        // Sorted by priority, matched to available drones
        // by proximity, endurance, sensor fit, and risk
    }
}
```

---

## Degraded Mode Governance

### The Degraded Mode Envelope

When communications degrade, the system's autonomy envelope contracts. This is a constitutional principle: **less information → less authority**, never more.

```
┌─────────────────────────────────────────────────────────────────┐
│  COMMS STATE              │  AUTONOMY ENVELOPE                  │
├───────────────────────────┼─────────────────────────────────────┤
│  nominal                  │  Full mission authority.             │
│                           │  All escalation tiers active.       │
│                           │  Task re-allocation enabled.        │
├───────────────────────────┼─────────────────────────────────────┤
│  reducedBandwidth         │  Telemetry-only mode.               │
│                           │  Video relay suspended.             │
│                           │  Lease durations shortened.         │
│                           │  New detections queued, not acted.  │
├───────────────────────────┼─────────────────────────────────────┤
│  intermittent             │  Lease durations halved.            │
│                           │  No new task assignments.           │
│                           │  Drones complete current lease      │
│                           │  then hold position.                │
│                           │  Escalation: all events → CRITICAL. │
├───────────────────────────┼─────────────────────────────────────┤
│  droneIsolated(id)        │  Isolated drone:                    │
│                           │    Completes current scan pass.     │
│                           │    Orbits at last known position.   │
│                           │    After policy.isolationTimeout:   │
│                           │      RTL via safest corridor.       │
│                           │  Fleet: reassigns isolated drone's  │
│                           │    task to pool immediately.        │
│                           │  Escalation: ELEVATED if non-       │
│                           │    priority sector. CRITICAL if     │
│                           │    priority sector loses coverage.  │
├───────────────────────────┼─────────────────────────────────────┤
│  gcsIsolated              │  All drones:                        │
│                           │    Complete current scan pass.      │
│                           │    Hold positions.                  │
│                           │    After policy.gcsTimeout: RTL.    │
│                           │  No new leases granted.             │
│                           │  No escalation possible (no path).  │
│                           │  Onboard Law 7 (Spatial) + Law 4   │
│                           │    (Resource) remain active—drones  │
│                           │    cannot violate geofence or       │
│                           │    battery limits regardless of     │
│                           │    comms state.                     │
├───────────────────────────┼─────────────────────────────────────┤
│  fullPartition            │  Conservative mode.                 │
│                           │  Each drone operates on onboard     │
│                           │    FlightLaw only.                  │
│                           │  FireLaw governance suspended       │
│                           │    (cannot be enforced without      │
│                           │    fleet state awareness).          │
│                           │  RTL after policy.partitionTimeout. │
│                           │  All onboard detections logged      │
│                           │    locally for post-reconnect sync. │
└───────────────────────────┴─────────────────────────────────────┘
```

### The Critical Insight

In full partition, FireLaw *cannot* govern because it requires fleet-wide state awareness to make allocation and escalation decisions. This is an honest acknowledgment, not a failure. The system falls back to FlightLaw—which operates entirely onboard—and guarantees that each individual drone remains safe even when the higher-order governance layer is unreachable.

**This is the jurisdiction model working as designed.** FlightLaw provides the safety floor. FireLaw provides the mission ceiling. When the ceiling is unreachable, the floor still holds.

---

## Airspace Deconfliction Governance

### Manned Aircraft Integration

Wildfire operations frequently involve manned rotorcraft (medevac, bucket drops, observation) and fixed-wing air tankers. The GCS must respond to manned aircraft presence deterministically.

```swift
enum AirspaceMode {
    case normal                               // Standard altitude bands and corridors
    case mannedAircraftActive(                 // Manned aircraft reported in area
        source: DeconflictionSource,          // ADS-B, radio call, TFR update
        constraint: AirspaceConstraint        // What to restrict
    )
    case mannedAircraftImmediate(              // Manned aircraft in immediate vicinity
        constraint: AirspaceConstraint        // Emergency altitude/position constraint
    )
    case groundStop                           // All UAS grounded until clearance
}

struct AirspaceConstraint {
    let maxAltitudeAGL: Feet                  // Reduced ceiling
    let exclusionZones: [GeoPolygon]          // Areas to vacate
    let effectiveUntil: Timestamp?            // Auto-reverts if time-limited
}
```

### Deconfliction as Law 7 Extension

Manned aircraft deconfliction extends Law 7 (Spatial) by dynamically modifying the safety envelope. When a manned aircraft is detected:

1. **AirspaceMode transitions** to `.mannedAircraftActive` or `.mannedAircraftImmediate`.
2. **Law 7 safety envelope contracts** based on the constraint.
3. **Any drone currently outside the new envelope** receives an immediate re-routing action.
4. **All active leases are re-evaluated** against the new envelope. Leases that cannot be fulfilled within the contracted airspace are revoked and returned to pool.
5. **Escalation: CRITICAL.** Manned aircraft presence is always at least CRITICAL because it represents an external authority (Air Boss / Air Tactical Group Supervisor) that supersedes UAS operations.

This transition is deterministic: same ADS-B input or radio call → same airspace constraint → same drone behaviors. Auditable and replayable.

---

## Coverage Governance

### Sector Freshness Model

FireLaw's coverage governance treats information as perishable. A sector scanned 10 minutes ago provides less certainty than one scanned 2 minutes ago, and the rate of decay depends on fire conditions.

```swift
struct CoveragePolicy {
    /// Freshness thresholds by sector priority
    let freshThreshold: [SectorPriority: TimeInterval]
    // Example: .critical = 120s, .high = 300s, .standard = 600s, .low = 900s
    
    /// When freshness drops below this, trigger re-scan task
    let staleThreshold: [SectorPriority: TimeInterval]
    
    /// Weather modifier: multiply freshness decay rate during high wind
    let windDecayMultiplier: Double           // e.g., 1.5x during wind events
    
    /// Minimum coverage guarantee: system must maintain this % of sectors fresh
    let minimumFreshCoverage: Double          // e.g., 0.7 = 70% of sectors fresh
}
```

### Predictive Gap Management

The GCS does not wait for sectors to go stale before acting. It predicts coverage gaps based on:

- Current drone positions and scan rates
- Battery endurance projections
- Swap scheduling (dock or field team availability)
- Lease expiration times

When the coverage model predicts that a priority sector will go stale before a drone can reach it, it pre-emptively generates a re-tasking recommendation. This recommendation enters the escalation model like any other event—if it's routine (standard sector, ample fleet), it executes autonomously. If it's significant (critical sector, limited fleet), it escalates for operator review.

---

## Persistence Governance (Law 6 Implementation)

### What Cannot Be Mutated

Law 6 protects the following fire state from retroactive modification:

1. **Committed detections.** Once a `HotspotDetection` is committed to state with an audit hash, its fields are immutable. New sensor data about the same location creates a *new* detection, linked to the prior one, but never overwrites it.

2. **Perimeter snapshots.** The fire perimeter is versioned. Each update creates a new perimeter version; prior versions are preserved for timeline reconstruction.

3. **Escalation decisions.** Once an escalation tier is assigned and logged, it cannot be downgraded retroactively. An escalation that was CRITICAL at 02:17 remains CRITICAL in the audit trail, even if subsequent data suggests the detection was a false positive.

4. **Lease grants and revocations.** The complete lease history is immutable—who was assigned what task, when, and why.

### Why This Matters for Fire

After-action review in wildfire incidents is legally significant. Fire agencies, insurance entities, and sometimes courts need to reconstruct exactly what happened, when, and what decisions were made based on what information was available at the time. Law 6 guarantees that the audit record cannot be modified to reflect hindsight.

---

## Evidence Package

### Outputs

FireLaw produces a comprehensive after-action evidence package:

**Timeline Replay:**
Every state transition from incident activation to mission end. SOP acceptance, launch authorizations, all escalation events, all operator decisions, all automated actions. Deterministically replayable—feeding the same inputs produces the same outputs.

**Detection Report:**
Each hotspot detection with: GPS coordinates, timestamp, thermal imagery, RGB imagery (if available), raw confidence, deterministic severity band, escalation tier, verification status, follow-up actions taken, and operator decisions.

**Coverage Report:**
Per-sector scan history showing freshness over time, gaps, and the decisions that led to any gap (drone swap, re-tasking, comms loss).

**Fleet Report:**
Per-drone operational history: tasks assigned, leases held, battery consumption, comms quality, degraded mode transitions, RTL events.

**System Health Report:**
Comms outages, GPS degradation, sensor anomalies, failsafe activations, and any transitions between degraded modes.

**Authority Report:**
Every escalation event with: trigger conditions, tier assignment, notification sent, operator response (or timeout), and resulting action. This is the document that answers "who knew what, when, and what did they do about it."

### Evidence Integrity

All evidence is linked to the SHA256 hash chain established by Law 3. The evidence package includes the hash chain itself, enabling independent verification that no entries were added, removed, or modified after the fact.

---

## Operational Phases Mapped to Governance

### Phase 1: Pre-Incident Setup

**Governance:** SOP template defines all thresholds, escalation policies, coverage policies, and authority chains. This is where the deterministic parameters are locked.

**Law 8 action:** Loading an SOP template is a HIGH-RISK action requiring explicit authorization from the UAS Program Manager or IC.

### Phase 2: Incident Spin-Up (First 10 Minutes)

**Governance:** Operator draws/imports perimeter, assigns sector priorities, confirms airspace constraints. Each action is an `Action` proposal validated by the `FireReducer`.

**Key actions:**
- `SetPerimeter(boundary)` — validated against Law 7 (must be within operational area)
- `AssignSectorPriority(sectorID, priority, reason)` — logged with justification
- `ConfirmAirspace(tfr, deconflictionRules)` — validated against Law 7
- `AuthorizeLaunch(droneIDs, sopTemplateID)` — Law 8 HIGH-RISK, requires explicit approval

### Phase 3: Launch & Distributed Tasking

**Governance:** Task leases begin. Law 2 governs delegation. Coverage tracking begins.

**Key actions:**
- `GrantLease(droneID, task, duration)` — Law 2 validated
- `RenewLease(leaseID)` — only if current, within max renewals
- `RevokeLease(leaseID, reason)` — immediate, returns task to pool
- `CommitDetection(detection)` — Law 6 locks the detection

### Phase 4: Overnight Steady State

**Governance:** Escalation model is primary. Coverage governance runs continuously. Degraded mode transitions are automatic.

This is where the system earns trust. Every decision is governed, every detection is escalated appropriately, every coverage gap is predicted and addressed.

### Phase 5: Shift Change & Sustainment

**Governance:** Battery swap scheduling is a coverage governance problem. Predictive gap management ensures swaps happen before sectors go stale.

**Key actions:**
- `ScheduleSwap(droneID, dockID, estimatedReturn)` — validated against coverage model
- `TransferLease(fromDrone, toDrone, leaseID)` — Law 2: handoff preserves audit chain

### Phase 6: Post-Incident

**Governance:** Evidence package generation. Replay verification.

**Key action:**
- `GenerateEvidencePackage(incidentID)` — produces all reports described above
- `VerifyReplay(incidentID)` — replays all actions, confirms hash chain integrity

---

## What FireLaw Proves About the Codex

FireLaw is the most demanding jurisdiction in the Flightworks Suite. If SwiftVector can govern overnight autonomous wildfire operations with multiple assets, degraded comms, dynamic airspace, and sleeping operators—it can govern anything.

Specifically, FireLaw demonstrates:

1. **Law composition scales.** Adding Law 2 and Law 6 to the FlightLaw base is clean and principled. No existing Laws were modified.

2. **The Reducer pattern handles complexity.** The `FireReducer` is a pure function despite governing a complex multi-asset system. Same inputs → same outputs, even for escalation decisions with compound triggers.

3. **The Agency Paradox holds under pressure.** At 2 AM with an operator asleep, the system still does not make decisions it is not authorized to make. It escalates, notifies, and recommends—but the tier thresholds that govern its autonomy were set by humans at mission start.

4. **Degraded mode is a governance feature, not a bug.** When comms fail, authority contracts. The system does not try to be heroic. It falls back to the safety floor (FlightLaw) and waits for the governance layer to be restored.

5. **Evidence is a first-class product.** The audit trail is not a diagnostic afterthought—it is the primary output that fire agencies are paying for.

---

## Platform Considerations

### Target Hardware

FireLaw is platform-agnostic by design. The jurisdiction governs through the GCS regardless of the aircraft beneath it.

**Likely initial platforms:**
- Skydio X10 (post-DJI ban, likely government fleet standard)
- PX4/MAVLink compatible aircraft (open ecosystem)
- Custom platforms via MAVLink or vendor SDK

**GCS platform:**
- iPad (field-portable, proven in Flightworks Suite)
- Mac (command post / IC integration)
- Future: ruggedized tablets for fire line deployment

### Simulation-First Development

FireLaw can be developed entirely in SITL (Software In The Loop) simulation before any hardware integration. The governance layer—escalation, leases, coverage, degraded modes—is pure logic that does not depend on physical sensors. This enables:

- Full escalation scenario testing with synthetic detections
- Coverage gap simulation with configurable fleet sizes
- Degraded mode testing with simulated comms failures
- Replay verification of complex multi-asset scenarios
- Demonstration to fire agencies without live flights

---

## Appendix A: FireLaw Actions (Complete Registry)

```swift
enum FireAction: Action {
    // === Incident Management ===
    case activateIncident(IncidentID, SOPTemplate)
    case setPerimeter(GeoBoundary)
    case updatePerimeter(version: Int, GeoBoundary)
    case assignSectorPriority(SectorID, SectorPriority, PriorityReason)
    
    // === Launch & Fleet ===
    case authorizeLaunch([DroneID], SOPTemplateID)
    case registerDrone(DroneID, DroneCapabilities)
    case removeDrone(DroneID, RemovalReason)
    
    // === Task Leases (Law 2) ===
    case grantLease(DroneID, FireTaskType, duration: TimeInterval)
    case renewLease(LeaseID)
    case revokeLease(LeaseID, RevocationReason)
    case transferLease(LeaseID, fromDrone: DroneID, toDrone: DroneID)
    case expireLease(LeaseID)
    
    // === Detections ===
    case commitDetection(HotspotDetection)
    case requestVerification(DetectionID)
    case confirmDetection(DetectionID, OperatorID)
    case dismissDetection(DetectionID, OperatorID, reason: String)
    
    // === Escalation ===
    case evaluateEscalation(EscalationInputs)
    case acknowledgeEscalation(EscalationID, OperatorID)
    case timeoutEscalation(EscalationID)
    case enterConservativeMode(reason: ConservativeModeReason)
    
    // === Airspace ===
    case updateAirspaceMode(AirspaceMode)
    case confirmDeconfliction(OperatorID)
    
    // === Comms & Degraded Mode ===
    case updateCommsHealth(DroneID, LinkQuality)
    case transitionDegradedMode(DegradedMode)
    case restoreNominal
    
    // === Coverage ===
    case updateSectorFreshness(SectorID, FreshnessState)
    case recordScanComplete(SectorID, DroneID, Timestamp)
    
    // === Swap & Sustainment ===
    case scheduleSwap(DroneID, DockID, estimatedReturn: Timestamp)
    case completeSwap(DroneID, newBatteryLevel: Double)
    
    // === Evidence ===
    case generateEvidencePackage(IncidentID)
    case verifyReplay(IncidentID)
    
    // === Operator ===
    case updateOperatorPresence(OperatorPresence)
    case operatorHeartbeat(OperatorID, Timestamp)
}
```

---

## Appendix B: Relationship to Other Jurisdictions

```
                    SwiftVector Codex
                         │
                    FlightLaw (Laws 3, 4, 7, 8)
                         │
          ┌──────────────┼──────────────┐
          │              │              │
     ThermalLaw     SurveyLaw      FireLaw
     (single asset, (single asset, (multi-asset,
      inspection,    precision,     autonomous,
      operator       operator       operator
      present)       present)       degraded)
                                       │
                                       │ future extension
                                       ▼
                                   ISRLaw
                                   (swarm,
                                    contested,
                                    multi-domain)
```

FireLaw is the bridge between the single-asset jurisdictions (ThermalLaw, SurveyLaw) and the full swarm jurisdiction (ISRLaw) that Drone Command will require. Proving Law 2 delegation and degraded mode governance in the fire domain de-risks the entire path to ISRLaw.

---

**Document Status:** Architecture Draft — awaiting domain validation (fire chief conversation) and Drone Command alignment review.

**Next Steps:**
1. Domain validation with fire operations SME
2. Escalation threshold calibration with operational data
3. SITL simulation scenario development
4. PRD development (FireLaw requirements specification)
5. GCS wireframe design (operator experience)

---

**License:** CC BY 4.0  
**Author:** Stephen Sweeney, Flightworks Aerial LLC  
**Contact:** stephen@flightworksaerial.com
