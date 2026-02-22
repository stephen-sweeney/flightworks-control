# Flightworks ISR: High-Level Design (ISRLaw Jurisdiction)

**Document:** HLD-FI-ISR-2026-001  
**Version:** 0.1 (Draft)  
**Date:** February 2026  
**Author:** Stephen Sweeney, Flightworks Aerial LLC  
**Status:** Architecture Draft  
**Classification:** Public

---

## Document Purpose

This High-Level Design (HLD) specifies **Flightworks ISR**—the ISRLaw jurisdiction for distributed swarm Intelligence, Surveillance, and Reconnaissance operations in contested environments. ISRLaw is the most demanding jurisdiction in the Flightworks Suite, designed for military, law enforcement, and defense applications where adversarial threats, communications denial, and multi-asset coordination are primary operating conditions—not edge cases.

**ISRLaw = FlightLaw + Contested Operations Governance**

**Scope:**
- ISRLaw jurisdiction specification (Law composition and extensions)
- Pre-loaded authority model (autonomy grants for comms-denied operations)
- Partition-tolerant task governance (distributed consensus without GCS)
- Emissions control (EMCON) governance
- Adversarial threat model (GPS denial, comms jamming, spoofing)
- Swarm membership and health governance
- Evidence and chain-of-custody audit

**Out of Scope:**
- Specific weapons integration or lethal autonomy decisions
- Classified operational procedures or TTPs
- Electronic warfare countermeasures (platform-specific)
- Specific radio/mesh hardware selection

---

## Architectural Philosophy

### The Fundamental Inversion

FireLaw assumes communications degradation is a **failure state** to recover from. When comms degrade, authority contracts. The system becomes more conservative, waits for reconnection, and falls back to FlightLaw as a safety floor.

ISRLaw inverts this assumption.

In contested environments, communications denial is not a failure—it is the **expected operating condition**. An adversary will jam your datalinks. GPS will be spoofed or denied. Your mesh network will be partitioned. If the system requires constant GCS connectivity to make decisions, it is operationally useless in the environments where it is most needed.

**The ISRLaw authority model is therefore pre-loaded, not reactive.**

| Jurisdiction | Authority Model | Comms Loss Response |
|:------------|:---------------|:-------------------|
| ThermalLaw | Real-time operator approval | N/A (operator present) |
| SurveyLaw | Real-time operator approval | N/A (operator present) |
| FireLaw | Escalation tiers, contracts when degraded | Reduce authority → conservative mode → RTL |
| **ISRLaw** | **Pre-loaded mission authority envelope** | **Continue within pre-authorized bounds** |

This is not a departure from the Agency Paradox. It is its most disciplined application. The human grants authority *before* the mission, defining exactly what the swarm may do autonomously when it cannot ask. The pre-mission briefing is the governance event. The autonomy envelope is the Law.

> **"AI proposes, humans decide"** still holds—the humans decided at T-minus, not T-zero.

### Why ISRLaw Matters to the Codex

FireLaw proved the Codex scales to multi-asset operations with degraded comms. ISRLaw proves the Codex operates when there is **no expectation of comms at all**.

This is the hardest governance problem in autonomous systems: how do you maintain deterministic, auditable, lawful behavior when the authority that normally governs the system is unreachable by design?

The SwiftVector answer: you define the Laws completely before launch, you pre-load the authority envelope, and you require the system to operate within those bounds—no more, no less—until reconnection or mission termination. Every decision made autonomously is still governed by the same Reducer, the same Laws, the same audit trail. The only difference is that the human approved the *envelope* rather than each individual action.

### The Determinism Boundary

```
┌──────────────────────────────────────────────────────────────────┐
│                    STOCHASTIC ZONE                                │
│  (Non-deterministic, contested, adversarial)                     │
│                                                                  │
│  • Sensor inputs (EO/IR, radar, SIGINT — noisy, degraded)       │
│  • GPS position (denied, spoofed, or degraded)                   │
│  • Comms channel availability (jammed, intermittent)             │
│  • Adversary behavior (unpredictable by definition)              │
│  • Weather and terrain effects on sensors/comms                  │
│  • Electronic warfare environment (unknown threats)              │
│  • ML detection/classification outputs (probabilistic)           │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│              ▼ DETERMINISM BOUNDARY ▼                             │
│        (ISRLaw governance applies here)                          │
├──────────────────────────────────────────────────────────────────┤
│                    DETERMINISTIC ZONE                             │
│  (Same inputs → same outputs, auditable, replayable)             │
│                                                                  │
│  • Detection classification: confidence → threat band            │
│  • Task allocation: fleet state → assignments (deterministic)    │
│  • EMCON mode transitions: threat level → comms posture          │
│  • Authority enforcement: action → envelope check → permit/deny  │
│  • Navigation fallback: GPS state → nav mode selection           │
│  • Partition behavior: membership → local authority scope        │
│  • Audit entries: every transition → SHA256 hash chain           │
└──────────────────────────────────────────────────────────────────┘
```

### Business Guarantee

> **"Every autonomous decision made under comms denial was pre-authorized by the mission commander, executed within deterministic bounds, and recorded in a tamper-evident audit trail that can be replayed for operational review, legal accountability, and lessons learned."**

---

## Composed Laws

ISRLaw is the most comprehensive jurisdiction in the Flightworks Suite, composing **eight** Laws from the SwiftVector Codex—more than any other jurisdiction:

```
ISRLaw = FlightLaw ∘ ISRGovernance

where:
  FlightLaw         = Law 3 ∘ Law 4 ∘ Law 7 ∘ Law 8
  ISRGovernance     = Law 0 ∘ Law 2 ∘ Law 5 ∘ Law 6
                      + MissionAuthority + SwarmGovernance
                      + EMCONGovernance + ThreatAdaptation

  Full composition  = Law 0 ∘ Law 2 ∘ Law 3 ∘ Law 4 ∘ Law 5 ∘ Law 6 ∘ Law 7 ∘ Law 8
                      + MissionAuthority + SwarmGovernance
                      + EMCONGovernance + ThreatAdaptation
```

### Law Composition Detail

```
┌─────────────────────────────────────────────────────────────────────┐
│                      ISRLAW JURISDICTION                            │
│            (Distributed Swarm ISR — Contested Environments)         │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  INHERITED FROM FLIGHTLAW (Universal Safety Kernel)           │  │
│  │                                                                │  │
│  │  Law 3 (Observation)  │ Law 4 (Resource)  │ Law 7 (Spatial)   │  │
│  │  • Telemetry          │ • Battery mgmt    │ • Geofence        │  │
│  │  • Pre-flight         │ • RTL triggers    │ • Altitude bands  │  │
│  │  • Audit logging      │ • Fleet endurance │ • AO boundaries   │  │
│  │                       │                   │ • No-fly zones    │  │
│  │                                                                │  │
│  │  Law 8 (Authority)                                             │  │
│  │  • Risk-tiered approval (pre-loaded for ISR)                   │  │
│  │  • Mission commander authority chain                           │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  SHARED WITH FIRELAW                                          │  │
│  │                                                                │  │
│  │  Law 2 (Delegation)        │ Law 6 (Persistence)              │  │
│  │  • Task lease authority    │ • Detection immutability         │  │
│  │  • Drone→drone handoff     │ • Mission state integrity        │  │
│  │  • Permission inheritance  │ • Evidence chain protection      │  │
│  │  • Partition authority     │ • Observation log locking         │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                     │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  NEW IN ISRLAW (Contested Operations Governance)              │  │
│  │                                                                │  │
│  │  Law 0 (Boundary)          │ Law 5 (Sovereignty)              │  │
│  │  • EMCON enforcement       │ • Data classification levels     │  │
│  │  • Network containment     │ • Need-to-know enforcement       │  │
│  │  • RF emission control     │ • Coalition data handling        │  │
│  │  • Cyber attack surface    │ • Exfiltration prevention        │  │
│  │    minimization            │                                  │  │
│  │                                                                │  │
│  │  MissionAuthority          │ SwarmGovernance                  │  │
│  │  • Pre-loaded envelopes    │ • Membership protocol           │  │
│  │  • Autonomous phase rules  │ • Partition tolerance            │  │
│  │  • Reconnect handback      │ • Distributed task allocation   │  │
│  │  • Authority escalation    │ • Deconfliction                 │  │
│  │    on reconnect            │ • Health monitoring             │  │
│  │                                                                │  │
│  │  EMCONGovernance           │ ThreatAdaptation                │  │
│  │  • RF emission levels      │ • GPS denied navigation         │  │
│  │  • Comms posture rules     │ • Spoofing detection            │  │
│  │  • Burst transmission      │ • Threat level transitions      │  │
│  │    scheduling              │ • Adaptive sensor modes         │  │
│  └────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### Why Law 0 and Law 5

**Law 0 (Boundary)** governs containment in the Codex—what systems the agent can reach. In ISRLaw, Law 0 takes on a physical dimension: it governs what **electromagnetic emissions** the swarm produces. In EMCON conditions, transmitting is equivalent to writing to a hostile network—it reveals your position, your capabilities, and your intent. Law 0 enforces that no drone in the swarm can emit RF energy outside the authorized EMCON posture, regardless of what its local task allocation might request. A drone that needs to share a detection but is under EMCON ALPHA (emissions restricted) cannot transmit—the action is rejected by Law 0, just as a filesystem write to an unauthorized path would be rejected in the software domain.

**Law 5 (Sovereignty)** governs data classification and residency. In military ISR, collected intelligence has classification levels. Sensor data from a compartmented collection method cannot be shared with coalition partners who lack the clearance. Law 5 enforces this at the state transition level—an action that would transmit classified data to an unauthorized node is rejected before it executes. This is not an access control list bolt-on; it is a constitutional constraint on what state transitions are representable.

---

## Domain Model

### ISRState

```swift
struct ISRState: State {
    // === Mission Context ===
    let missionID: MissionID
    let missionType: ISRMissionType           // Area search, route recon, persistent overwatch
    let operationName: String
    let missionStart: Timestamp
    let missionEndBound: Timestamp            // Hard stop (fuel/battery/time limit)
    
    // === Authority ===
    let missionAuthority: MissionAuthority    // Pre-loaded authority envelope
    let currentPhase: MissionPhase            // Pre-mission, autonomous, reconnected, RTB
    let commanderID: OperatorID               // Mission commander who authorized
    
    // === Area of Operations ===
    let areaOfOperations: AreaOfOperations    // AO boundary (Law 7)
    let sectors: [SectorID: ISRSectorState]   // Named areas of interest (NAIs)
    let routeLegs: [RouteLeg]?               // If route reconnaissance
    
    // === Swarm ===
    let swarm: SwarmState                     // All member drones
    let taskLeases: [LeaseID: ISRTaskLease]   // Active assignments (Law 2)
    let taskPool: [UnassignedISRTask]         // Tasks awaiting assignment
    let membership: MembershipState           // Who is in the swarm, who is partitioned
    
    // === Detections ===
    let detections: [DetectionID: ISRDetection]  // All observations (Law 6: immutable)
    let trackingState: TrackingState          // Active tracks being maintained
    
    // === EMCON ===
    let emconState: EMCONState                // Current emissions posture
    let commsSchedule: CommsSchedule?         // Burst transmission windows
    
    // === Threat ===
    let threatLevel: ThreatLevel              // Current assessed threat
    let gpsState: GPSIntegrityState           // Healthy, degraded, denied, spoofed
    let navMode: NavigationMode               // GPS, INS, visual, terrain-referenced
    
    // === Classification (Law 5) ===
    let classificationLevel: ClassificationLevel
    let dataHandlingRules: DataHandlingPolicy
    let coalitionSharing: CoalitionSharingRules?
    
    // === Audit ===
    let auditTrail: AuditTrail               // SHA256 hash chain (Law 3)
}
```

### Key Domain Types

```swift
// === Mission Authority (The Pre-Loaded Envelope) ===

struct MissionAuthority: State {
    let authorizedBy: OperatorID              // Mission commander
    let authorizedAt: Timestamp               // When authority was granted
    let briefingHash: SHA256Hash              // Hash of the mission briefing state
    
    /// What the swarm may do autonomously when comms-denied
    let autonomousEnvelope: AutonomousEnvelope
    
    /// What triggers automatic mission abort
    let abortCriteria: [AbortCriterion]
    
    /// Maximum duration of autonomous operations
    let maxAutonomousDuration: TimeInterval
    
    /// Rules of engagement for the ISR mission
    let roe: RulesOfEngagement
}

struct AutonomousEnvelope: State {
    /// Task types the swarm may execute without real-time approval
    let authorizedTasks: Set<ISRTaskCategory>
    
    /// Maximum distance any drone may operate from rally point
    let maxRangeFromRally: Distance
    
    /// Sectors pre-authorized for collection
    let authorizedSectors: Set<SectorID>
    
    /// Altitude bounds for autonomous operations
    let altitudeBand: ClosedRange<Feet>
    
    /// What to do with detections (report, track, classify only)
    let detectionAuthority: DetectionAuthority
    
    /// Re-tasking authority: can drones reallocate among themselves?
    let swarmRetaskingPermitted: Bool
    
    /// Can the swarm modify its search pattern based on detections?
    let adaptiveSearchPermitted: Bool
}

enum DetectionAuthority {
    case classifyOnly                         // Detect and classify, no tracking
    case classifyAndTrack                     // Maintain track on detections
    case classifyTrackReport                  // Report via burst comms if available
    case classifyTrackReportRecommend         // Recommend response actions
}

// === Mission Phases ===

enum MissionPhase {
    case preMission                           // Authority being loaded, preflight
    case launch                               // Departing, establishing formation
    case transitToAO                          // En route to area of operations
    case autonomous                           // Operating within pre-loaded authority
    case reconnected                          // GCS contact restored, handback in progress
    case missionComplete                      // All tasks complete or time expired
    case returnToBase                         // RTB, debrief pending
    case abort(AbortReason)                   // Mission aborted, RTB immediate
}

// === EMCON Governance ===

enum EMCONLevel: Comparable {
    case alpha                                // Emissions restricted — no RF transmission
    case bravo                                // Minimal emissions — burst only, scheduled
    case charlie                              // Reduced emissions — mesh active, power limited
    case delta                                // Normal emissions — full mesh, full power
}

struct EMCONState: State {
    let level: EMCONLevel
    let setBy: EMCONAuthority                 // Mission plan, threat response, or manual
    let effectiveSince: Timestamp
    let nextBurstWindow: Timestamp?           // When burst transmission is next authorized
    let burstDuration: TimeInterval?          // How long the burst window lasts
}

// === GPS Integrity (Adversarial Environment) ===

enum GPSIntegrityState {
    case healthy(fixType: GPSFixType)         // Normal GPS operation
    case degraded(accuracy: Distance)         // Reduced accuracy, still usable
    case denied                               // No GPS signal available
    case suspectedSpoof(evidence: SpoofEvidence) // Position data inconsistent with INS
}

struct SpoofEvidence: State {
    let insMismatch: Distance                 // Divergence between GPS and INS position
    let clockAnomaly: Bool                    // GPS timing inconsistent
    let signalStrengthAnomaly: Bool           // Unexpectedly strong/uniform signal
    let multipleVehicleCorrelation: Bool      // Multiple drones see same anomaly
}

enum NavigationMode {
    case gps                                  // Primary GPS navigation
    case gpsWithINSValidation                 // GPS cross-checked against INS
    case insPrimary                           // INS primary, GPS untrusted
    case visualOdometry                       // Camera-based navigation
    case terrainReferenced                    // DTED/terrain matching
    case deadReckoning                        // Last resort — INS only, no correction
}

// === Task Lease (Law 2 — Contested Extension) ===

struct ISRTaskLease: State {
    let leaseID: LeaseID
    let taskType: ISRTaskType
    let assignedDrone: DroneID
    let sectorID: SectorID?
    let grantedAt: Timestamp
    let expiresAt: Timestamp
    let renewalCount: Int
    let maxRenewals: Int
    
    /// Authority inherited from mission envelope (Law 2)
    let grantedAuthority: AutonomousEnvelope
    
    /// Who granted: GCS or peer drone during partition?
    let grantSource: LeaseGrantSource
    
    /// Classification of data this task may collect (Law 5)
    let collectionClassification: ClassificationLevel
    
    let status: LeaseStatus
}

enum LeaseGrantSource {
    case gcs                                  // Normal: GCS allocated the task
    case swarmLeader(DroneID)                 // Partition: designated leader allocated
    case selfAssigned(justification: SelfAssignmentJustification)  // Last resort
}

enum SelfAssignmentJustification {
    case lastSurvivingMember                  // Only drone in partition
    case leaderUnreachable                    // Cannot contact swarm leader
    case abortCriterionPending                // Self-assigning RTB due to abort trigger
}

// === ISR Task Types ===

enum ISRTaskType {
    case areaScan(SectorID)                   // Systematic coverage of NAI
    case routeRecon(RouteLeg)                 // Follow route, collect along path
    case persistentOverwatch(SectorID)        // Hold and observe
    case trackTarget(TrackID)                 // Maintain track on detected entity
    case commsRelay(RelayPosition)            // Act as mesh relay node
    case decoy(DecoyPattern)                  // Draw attention / simulate presence
    case battleDamageAssessment(TargetID)     // Post-strike assessment
    case rtb                                  // Return to base
}

// === ISR Detection ===

struct ISRDetection: State {
    let detectionID: DetectionID
    let timestamp: Timestamp
    let location: GeoCoordinate               // Best estimate (may be INS-derived)
    let locationConfidence: LocationConfidence // How good is the position?
    let sectorID: SectorID
    let droneID: DroneID
    
    // Stochastic inputs
    let sensorType: SensorType                // EO, IR, radar, SIGINT
    let rawConfidence: Double                 // ML classification confidence
    let sensorConditions: ISRSensorConditions // Weather, range, aspect angle
    
    // Deterministic classification
    let entityClass: EntityClassification     // Vehicle, person, structure, unknown
    let threatBand: ThreatBand                // Deterministic mapping
    let priority: DetectionPriority
    
    // Classification (Law 5)
    let classificationLevel: ClassificationLevel
    let collectionMethod: CollectionMethod     // Drives classification rules
    
    // Evidence
    let frameIDs: [FrameID]                   // Sensor imagery
    let auditHash: SHA256Hash
    
    // Tracking linkage
    let linkedTrackID: TrackID?               // If associated with an active track
}

enum LocationConfidence {
    case gpsFixed                             // GPS healthy, high confidence
    case gpsDegraded(accuracy: Distance)      // GPS available but degraded
    case insDerived(driftEstimate: Distance)  // GPS denied, position from INS
    case estimated(uncertainty: Distance)     // Low confidence estimate
}

// === Threat Level ===

enum ThreatLevel: Comparable {
    case green                                // No known threats in AO
    case yellow                               // Possible threat indicators
    case orange                               // Confirmed threat, not engaged
    case red                                  // Active threat, EW/kinetic
}

// === Classification (Law 5) ===

enum ClassificationLevel: Comparable {
    case unclassified
    case fouo                                 // For Official Use Only
    case confidential
    case secret
    case topSecret
}
```

---

## Pre-Loaded Authority Model

### The Mission Briefing as Governance Event

In ThermalLaw and SurveyLaw, the operator governs in real-time: each detection requires approval, each mission parameter can be adjusted on the fly. This works because the operator is present and connected.

In ISRLaw, the **mission briefing is the governance event**. Before launch, the mission commander:

1. Defines the Area of Operations (Law 7 boundary)
2. Assigns sectors and priorities (Named Areas of Interest)
3. Sets the autonomy envelope (what tasks are pre-authorized)
4. Establishes EMCON posture (expected comms environment)
5. Defines abort criteria (what triggers automatic RTB)
6. Sets rules of engagement (detection authority level)
7. Configures data handling rules (Law 5 classification)
8. Approves the mission plan (Law 8 — HIGH-RISK authorization)

Every one of these decisions is recorded in the `MissionAuthority` struct, hashed, and locked into state by Law 6 (Persistence). Once the swarm launches, the mission authority cannot be modified by the swarm itself. It can only be modified by the mission commander via an authenticated command when comms are available.

### The Authority Lifecycle

```
PRE-MISSION                    AUTONOMOUS PHASE                RECONNECT
─────────────────────────────────────────────────────────────────────────
                                                                
Commander defines          Swarm operates within            Commander reviews
  authority envelope  →      pre-authorized bounds  →        autonomous decisions
Commander approves         Every decision checked            Commander can:
  mission plan               against envelope                 - Modify envelope
Mission authority          Decisions outside envelope         - Issue new tasking
  locked (Law 6)             are REJECTED by Reducer          - Recall swarm
Swarm launches             All decisions audited              - Approve/reject
                           No authority escalation              queued actions
                             possible (Law 2)                Handback complete
```

### What "Pre-Authorized" Means Precisely

Pre-authorization is not blanket autonomy. It is a **bounded envelope** with deterministic constraints.

The swarm operating autonomously under ISRLaw CAN:
- Scan authorized sectors using authorized sensor modes
- Classify detections using onboard ML + deterministic post-processing
- Track detections if `detectionAuthority >= .classifyAndTrack`
- Reallocate tasks among swarm members if `swarmRetaskingPermitted == true`
- Adapt search patterns if `adaptiveSearchPermitted == true`
- Report via burst comms during authorized windows
- Navigate using fallback nav modes when GPS is denied
- RTB when abort criteria are met

The swarm operating autonomously under ISRLaw CANNOT:
- Operate outside the AO boundary (Law 7 — always enforced)
- Exceed the authorized altitude band
- Scan sectors not in `authorizedSectors`
- Transmit outside authorized EMCON windows (Law 0)
- Share classified data with unauthorized nodes (Law 5)
- Extend its own authority envelope (Law 2)
- Modify abort criteria
- Exceed `maxAutonomousDuration`
- Self-authorize task categories not in `authorizedTasks`

Every "CAN" is still governed by the Reducer. Every "CANNOT" is enforced by Law rejection. The envelope is the Law.

---

## Swarm Governance

### Membership Protocol

ISRLaw must govern a swarm whose membership can change during operations—drones are lost to attrition, comms failures, or mechanical issues. The membership protocol provides deterministic answers to: "Who is in the swarm, and who has authority over what?"

```swift
struct MembershipState: State {
    let members: [DroneID: MemberStatus]
    let leader: DroneID?                      // Current swarm leader (if designated)
    let leaderElectionHistory: [LeaderElection] // Audit trail of leadership changes
    let partitions: [PartitionID: Partition]   // Known network partitions
}

enum MemberStatus {
    case active(lastHeartbeat: Timestamp)
    case degraded(reason: DegradedReason, lastHeartbeat: Timestamp)
    case lost(lastContact: Timestamp)          // No heartbeat within timeout
    case confirmed_lost(evidence: LossEvidence) // Confirmed attrition
    case returned(reconnectedAt: Timestamp)    // Was lost, now back
}
```

### Partition Tolerance

When the mesh network partitions—whether from terrain, jamming, or distance—each partition must be able to operate independently while maintaining governance guarantees.

**Partition governance rules:**

1. **Each partition elects a local leader.** Election is deterministic: lowest DroneID among healthy members. No randomness, no negotiation.

2. **The local leader inherits delegation authority (Law 2)** scoped to its partition. It can reallocate tasks among partition members but cannot expand the authority envelope.

3. **Partitioned drones continue their current tasks** until lease expiration. The local leader can renew or reallocate leases within the partition.

4. **Detection data is stored locally** on each drone during partition (Law 6 — immutable). When the partition heals, detection logs are merged using timestamp ordering. Conflicts (same target, different classifications) are preserved as separate records, not resolved—humans resolve conflicts during debrief.

5. **Partition duration is bounded.** If a partition persists beyond `maxAutonomousDuration` or local abort criteria are met, the partition independently initiates RTB.

6. **Partition healing triggers a reconciliation phase.** When partitions merge, the reconciliation protocol:
   - Merges detection logs (Law 6: no mutations, append-only)
   - Reconciles task lease state (revoke duplicates, reassign)
   - Re-elects global leader
   - Reports merged state to GCS if connected

### The Leader Election Guarantee

Leader election must be deterministic and partition-safe. ISRLaw uses a simple, provable rule:

```
Leader = min(DroneID) where status == .active in current partition
```

No voting. No consensus rounds. No Byzantine fault tolerance complexity. The lowest-numbered healthy drone leads. If that drone is lost, the next lowest takes over. This is auditable, replayable, and predictable.

The tradeoff is that "best drone for leadership" is not considered—only "unambiguous, deterministic selection." In safety-critical systems, unambiguous beats optimal.

---

## EMCON Governance (Law 0 Implementation)

### Emissions as Boundary Violations

Law 0 governs boundaries—what the system may reach. In the software domain, this means filesystem and network access. In the RF domain, it means electromagnetic emissions.

An RF transmission in EMCON ALPHA is equivalent to a filesystem write to a forbidden path. The action is **rejected by Law 0**, not by convention, not by best practice—by the Reducer refusing to transition state.

```swift
struct EMCONReducer {
    
    /// Law 0 enforcement: emissions must comply with current EMCON level
    static func validateEmission(
        state: ISRState,
        proposed: EmissionAction
    ) -> LawEvaluation {
        
        switch state.emconState.level {
        case .alpha:
            // No emissions permitted. ALL transmission actions rejected.
            return .rejected(
                law: .boundary,
                reason: "EMCON ALPHA active: all RF emissions prohibited",
                proposedAction: proposed
            )
            
        case .bravo:
            // Burst only, during authorized windows
            guard case .burstTransmit(let payload) = proposed else {
                return .rejected(
                    law: .boundary,
                    reason: "EMCON BRAVO: only burst transmissions permitted"
                )
            }
            guard isWithinBurstWindow(state.emconState) else {
                return .rejected(
                    law: .boundary,
                    reason: "EMCON BRAVO: outside authorized burst window"
                )
            }
            guard payload.size <= state.emconState.maxBurstSize else {
                return .rejected(
                    law: .boundary,
                    reason: "EMCON BRAVO: payload exceeds burst size limit"
                )
            }
            return .permitted(evaluations: [])
            
        case .charlie:
            // Mesh active but power-limited
            guard proposed.transmitPower <= state.emconState.maxPower else {
                return .rejected(
                    law: .boundary,
                    reason: "EMCON CHARLIE: transmit power exceeds limit"
                )
            }
            return .permitted(evaluations: [])
            
        case .delta:
            // Normal operations, all emissions permitted
            return .permitted(evaluations: [])
        }
    }
}
```

### EMCON Transitions

EMCON level transitions can be triggered by:
- **Mission plan:** Pre-scheduled EMCON windows (e.g., "EMCON ALPHA during transit, BRAVO in AO")
- **Threat response:** Threat level change triggers EMCON tightening
- **Commander override:** Real-time command (when comms available)

EMCON transitions are **always toward restriction by default.** A drone that detects a potential threat indicator can tighten its own EMCON level (within mission plan bounds) but cannot relax it. Only the mission plan schedule or commander override can relax EMCON. This prevents a compromised or malfunctioning drone from breaking emissions discipline.

---

## GPS Denied Navigation Governance

### The Navigation Mode Ladder

GPS denial is expected in contested environments. ISRLaw governs the fallback sequence deterministically:

```
GPS Healthy
  │  GPS fix quality drops below threshold
  ▼
GPS + INS Cross-Check
  │  Mismatch between GPS and INS exceeds spoof threshold
  ▼
INS Primary (GPS Untrusted)
  │  INS drift exceeds position confidence threshold
  ▼
Visual Odometry / Terrain Referenced
  │  Conditions prevent visual nav (night, smoke, featureless terrain)
  ▼
Dead Reckoning (INS Only)
  │  Drift exceeds mission-critical threshold
  ▼
RTB via safest corridor (abort criterion met)
```

### Spoof Detection

GPS spoofing is a specific adversarial threat. ISRLaw implements spoof detection as a **deterministic cross-check**:

```swift
struct GPSSpoofDetector {
    
    /// Pure function: cross-check GPS against INS and fleet data
    static func evaluate(
        gpsPosition: GeoCoordinate,
        insPosition: GeoCoordinate,
        insConfidence: Distance,
        fleetPositions: [DroneID: GeoCoordinate]?, // Other drones' reported positions
        policy: SpoofPolicy
    ) -> GPSIntegrityState {
        
        let mismatch = gpsPosition.distance(to: insPosition)
        
        // Single-vehicle check
        if mismatch > policy.spoofThreshold {
            var evidence = SpoofEvidence(
                insMismatch: mismatch,
                clockAnomaly: false, // Checked separately
                signalStrengthAnomaly: false, // Checked separately
                multipleVehicleCorrelation: false
            )
            
            // Multi-vehicle correlation (if fleet data available)
            if let fleet = fleetPositions {
                let anomalousCount = fleet.values.filter { pos in
                    // Are other drones also seeing GPS/INS mismatch?
                    // This would be populated from their health reports
                    true // Simplified — real implementation checks fleet health
                }.count
                
                if anomalousCount > policy.correlationThreshold {
                    evidence.multipleVehicleCorrelation = true
                }
            }
            
            return .suspectedSpoof(evidence: evidence)
        }
        
        if mismatch > policy.degradedThreshold {
            return .degraded(accuracy: mismatch)
        }
        
        return .healthy(fixType: .fix3D)
    }
}
```

---

## Data Classification Governance (Law 5 Implementation)

### Classification as State Constraint

Law 5 enforces that data cannot flow to unauthorized recipients. In ISRLaw, this manifests at multiple levels:

1. **Collection classification.** Different sensors produce data at different classification levels. An EO camera collecting imagery of a public road produces UNCLASSIFIED data. A SIGINT sensor collecting communications produces data classified by the collection method, not the content.

2. **Sharing constraints.** In coalition operations, not all partners have the same clearances. Law 5 prevents a drone from sharing SECRET-classified detections via a mesh link that includes coalition nodes cleared only to CONFIDENTIAL.

3. **Storage constraints.** Classified data must reside on appropriately cleared storage. Law 5 prevents classified detections from being logged to uncleared storage media.

```swift
struct ClassificationReducer {
    
    /// Law 5 enforcement: data sharing must comply with classification rules
    static func validateSharing(
        state: ISRState,
        detection: ISRDetection,
        recipient: NodeID,
        recipientClearance: ClassificationLevel
    ) -> LawEvaluation {
        
        guard detection.classificationLevel <= recipientClearance else {
            return .rejected(
                law: .sovereignty,
                reason: "Detection classified \(detection.classificationLevel) "
                      + "exceeds recipient clearance \(recipientClearance)",
                proposedAction: .shareDetection(detection.detectionID, recipient)
            )
        }
        
        // Check coalition sharing rules if applicable
        if let rules = state.coalitionSharing {
            guard rules.isShareable(
                detection: detection,
                recipient: recipient
            ) else {
                return .rejected(
                    law: .sovereignty,
                    reason: "Coalition sharing rules prohibit this transfer"
                )
            }
        }
        
        return .permitted(evaluations: [])
    }
}
```

---

## Evidence and Chain of Custody

### The Debrief Problem

In ISR operations, the collected intelligence and the decision record are the primary products—more so even than in fire operations. Every detection, every classification decision, every re-tasking, every EMCON transition, and every autonomous decision must be reconstructable.

The challenge unique to ISRLaw: much of this evidence was generated **without GCS oversight**, during comms-denied autonomous operations. The audit trail must prove that the swarm operated within its pre-loaded authority, even though no human was watching.

### Evidence Package

ISRLaw's evidence package extends the audit trail concept with military-specific requirements:

**Mission Replay:**
Complete state transition history from briefing through debrief. Pre-loaded authority envelope, all autonomous decisions, all Law evaluations (permits and rejections), all detections, all task allocations.

**Collection Report:**
Each detection with: location (with confidence), timestamp, sensor type, raw classification confidence, deterministic threat band, imagery references, classification level, and associated track if any.

**Authority Compliance Report:**
For every autonomous decision, the report shows: what authority was invoked, what envelope constraint was checked, and the result. This is the document that proves the swarm never exceeded its pre-loaded authority.

**EMCON Compliance Report:**
Every emission event (or rejected emission), with EMCON level at time of event. Proves emissions discipline was maintained.

**Partition Report:**
Timeline of network partitions: when they occurred, which drones were in each partition, what local leadership decisions were made, and how detection logs were reconciled on merge.

**GPS Integrity Report:**
Navigation mode transitions, spoof detection events, position confidence over time. Critical for assessing the reliability of detection geolocations.

All evidence is bound to the SHA256 hash chain. The hash chain is maintained independently on each drone during partition and reconciled on merge. This enables independent verification that no drone's audit trail was tampered with, even during autonomous operations.

---

## Operational Phases Mapped to Governance

### Phase 1: Mission Briefing (T-minus)

**Governance:** This is the primary governance event. All authority is established here.

**Key actions (all Law 8 HIGH-RISK, commander approval required):**
- `LoadMissionPlan(plan)` — defines AO, sectors, routes
- `SetAuthorityEnvelope(envelope)` — pre-loads autonomous authority
- `SetEMCONSchedule(schedule)` — defines emissions posture
- `SetAbortCriteria(criteria)` — defines automatic RTB triggers
- `SetClassificationRules(rules)` — Law 5 configuration
- `AuthorizeMission(missionID, commanderID)` — final approval, locks authority (Law 6)

### Phase 2: Launch & Transit

**Governance:** Swarm establishes formation, mesh network initializes, transit EMCON applies.

**Key actions:**
- `LaunchSwarm(droneIDs)` — depart, establish mesh
- `TransitionPhase(.transitToAO)` — enter transit posture
- `SetEMCON(level)` — per mission plan schedule

### Phase 3: Autonomous Operations (The Core)

**Governance:** Pre-loaded authority governs. Every decision checked against envelope. Escalation to commander only possible during burst windows (if EMCON permits).

**Key actions:**
- `CommitDetection(detection)` — Law 6 locks detection
- `ClassifyDetection(detectionID, classification)` — deterministic post-processing
- `GrantLease(droneID, task, duration)` — Law 2, within envelope
- `ElectLeader(partitionID, droneID)` — deterministic, lowest ID
- `TransitionNavMode(mode)` — GPS fallback ladder
- `TransitionEMCON(level)` — per schedule or threat response (restriction only)
- `BurstTransmit(payload)` — Law 0 validated, window checked
- `TriggerAbort(criterion)` — abort criterion met, initiate RTB

### Phase 4: Reconnect & Handback

**Governance:** When GCS contact is restored, authority transitions back to real-time governance.

**Key actions:**
- `ReportReconnect(droneID)` — announce connectivity restored
- `SyncDetectionLog(droneID, detections)` — merge autonomous detections
- `ReconcileLeases(partitionID)` — resolve duplicate/conflicting leases
- `TransitionPhase(.reconnected)` — enter handback mode
- `CommanderReview(autonomousActions)` — commander reviews all autonomous decisions
- `ResumeRealTimeAuthority` — authority model reverts to real-time approval

### Phase 5: RTB & Debrief

**Governance:** Evidence package generation. Replay verification.

**Key actions:**
- `TransitionPhase(.returnToBase)` — initiate RTB
- `GenerateEvidencePackage(missionID)` — full debrief package
- `VerifyAuthorityCompliance(missionID)` — prove envelope was never exceeded
- `VerifyReplay(missionID)` — deterministic replay of all decisions

---

## What ISRLaw Proves About the Codex

ISRLaw is the ultimate stress test for SwiftVector. If the Codex can govern autonomous swarm operations in GPS-denied, comms-jammed, adversarial environments where no human is watching—it has proven its thesis.

1. **Pre-loaded authority is still governed authority.** The human decides at T-minus, the Reducer enforces at T-zero. The Agency Paradox holds even when the Steward is unreachable.

2. **Law 0 scales to physical boundaries.** Containment means something different when the boundary is electromagnetic emissions rather than filesystem paths. The Law is the same; the implementation is domain-specific. This is exactly the Codex extensibility model.

3. **Law 5 enables coalition operations.** Classification-aware data handling is a Reducer constraint, not an access control bolt-on. This enables trusted multi-partner operations under a single governance framework.

4. **Partition tolerance is a governance feature.** The swarm doesn't merely survive partitions—it operates within governed bounds during them. Leader election is deterministic. Task allocation continues. Evidence is preserved. Reconciliation is auditable.

5. **The jurisdiction hierarchy holds.**

```
FlightLaw (safety floor — always active, even on isolated drones)
    └── FireLaw (multi-asset, degraded comms, authority contracts)
            └── ISRLaw (multi-asset, comms denied by design, authority pre-loaded)
```

Each jurisdiction extends the one before it. ISRLaw doesn't replace FireLaw's degraded mode model—it builds on top of it. The same drone running ISRLaw still has FlightLaw enforcing battery limits and geofence compliance, even when every other governance layer is operating autonomously.

---

## Relationship to Drone Command

ISRLaw is the jurisdiction that directly serves the Drone Command mission. The GCS architecture, swarm governance model, task lease protocol, and evidence system designed here map to the capabilities Drone Command needs for military and law enforcement swarm operations.

**What transfers directly:**
- Task lease model with partition tolerance
- Pre-loaded authority envelope architecture  
- EMCON governance for tactical operations
- GPS-denied navigation governance
- Evidence and chain-of-custody system
- Deterministic leader election protocol

**What Drone Command extends beyond ISRLaw:**
- Hardware-specific integration (Skydio X10, custom platforms)
- Specific EW countermeasures and threat responses
- Weapons system integration governance (separate jurisdiction)
- Classified operational procedure implementation
- Multi-echelon command hierarchy (brigade → battalion → company → platoon)

ISRLaw provides the governance architecture. Drone Command provides the operational implementation.

---

## Platform Considerations

### Target Hardware

ISRLaw is platform-agnostic. The governance layer operates on the GCS regardless of aircraft.

**Likely platforms:**
- Skydio X10 (post-DJI ban, government standard)
- Shield AI V-BAT (VTOL fixed-wing ISR)
- Custom PX4-based platforms
- Any MAVLink-compatible UAS

**GCS deployment:**
- Ruggedized tablet (tactical edge)
- Vehicle-mounted system (mobile command)
- Deployable ground station (persistent ops)
- Simulation (SITL) for all governance testing

### Simulation-First Development

Like FireLaw, ISRLaw's governance layer is pure logic that can be fully tested in simulation. The adversarial scenarios (GPS denial, comms jamming, partition events) are actually *easier* to test in simulation than in the field—you can deterministically inject failures at precise moments and verify the governance response.

---

## Appendix A: ISRLaw Actions (Complete Registry)

```swift
enum ISRAction: Action {
    // === Mission Authority ===
    case loadMissionPlan(MissionPlan)
    case setAuthorityEnvelope(AutonomousEnvelope)
    case setEMCONSchedule(EMCONSchedule)
    case setAbortCriteria([AbortCriterion])
    case setClassificationRules(DataHandlingPolicy)
    case authorizeMission(MissionID, OperatorID)
    case modifyEnvelope(AutonomousEnvelope, OperatorID)  // Reconnect only
    
    // === Phase Transitions ===
    case transitionPhase(MissionPhase)
    case triggerAbort(AbortCriterion)
    
    // === Swarm Management ===
    case registerMember(DroneID, DroneCapabilities)
    case reportMemberLost(DroneID, LossEvidence?)
    case reportMemberReturned(DroneID)
    case electLeader(PartitionID)
    case reportPartition(PartitionID, members: Set<DroneID>)
    case healPartition(PartitionID)
    case reconcilePartition(PartitionID, mergedState: PartitionMergeResult)
    
    // === Task Leases (Law 2) ===
    case grantLease(DroneID, ISRTaskType, duration: TimeInterval)
    case renewLease(LeaseID)
    case revokeLease(LeaseID, RevocationReason)
    case transferLease(LeaseID, fromDrone: DroneID, toDrone: DroneID)
    case expireLease(LeaseID)
    
    // === Detections (Law 6) ===
    case commitDetection(ISRDetection)
    case classifyDetection(DetectionID, EntityClassification, ThreatBand)
    case linkDetectionToTrack(DetectionID, TrackID)
    case createTrack(TrackID, initialDetection: DetectionID)
    case updateTrack(TrackID, newPosition: GeoCoordinate, confidence: LocationConfidence)
    case dropTrack(TrackID, reason: TrackDropReason)
    
    // === EMCON (Law 0) ===
    case transitionEMCON(EMCONLevel, EMCONAuthority)
    case burstTransmit(BurstPayload)
    case requestBurstWindow                   // Ask for next available window
    
    // === Navigation ===
    case transitionNavMode(NavigationMode)
    case reportGPSIntegrity(GPSIntegrityState)
    case reportSpoofEvidence(SpoofEvidence)
    
    // === Classification (Law 5) ===
    case shareDetection(DetectionID, NodeID)
    case restrictDetection(DetectionID, ClassificationLevel) // Upgrade only
    
    // === Comms ===
    case updateCommsHealth(DroneID, LinkQuality)
    case meshTopologyUpdate(MeshTopology)
    
    // === Evidence ===
    case generateEvidencePackage(MissionID)
    case verifyAuthorityCompliance(MissionID)
    case verifyReplay(MissionID)
    case syncDetectionLog(DroneID, [ISRDetection])
    
    // === Operator (Reconnect Phase) ===
    case commanderReview(MissionID, [AutonomousDecision])
    case resumeRealTimeAuthority
}
```

---

## Appendix B: Full Jurisdiction Hierarchy

```
                        SwiftVector Codex (Laws 0-10)
                                │
                        FlightLaw (Laws 3, 4, 7, 8)
                        [Safety Floor — Always Active]
                                │
          ┌─────────────────────┼─────────────────────┐
          │                     │                     │
     ThermalLaw            SurveyLaw             FireLaw
     Laws: 3,4,7,8        Laws: 3,4,7,8        Laws: 2,3,4,6,7,8
     [Single asset]        [Single asset]        [Multi-asset]
     [Operator present]    [Operator present]    [Operator degraded]
     [Real-time auth]      [Real-time auth]      [Escalation tiers]
                                                      │
                                                      │ extends
                                                      ▼
                                                  ISRLaw
                                                  Laws: 0,2,3,4,5,6,7,8
                                                  [Multi-asset swarm]
                                                  [Comms denied by design]
                                                  [Authority pre-loaded]
                                                  [Contested environment]
                                                  [Partition tolerant]
```

**The progression tells a story:**
- ThermalLaw/SurveyLaw: "Governed AI assists an operator doing a job."
- FireLaw: "Governed AI operates when the operator can't be everywhere."
- ISRLaw: "Governed AI operates when no human can be present at all."

At every level, the Codex holds. The Laws compose. The Reducer enforces. The audit proves.

---

**Document Status:** Architecture Draft — awaiting Drone Command alignment review and operational domain validation.

**Next Steps:**
1. Drone Command team review (when NDA allows)
2. Partition tolerance simulation scenarios
3. EMCON governance edge case analysis
4. GPS-denied navigation architecture detail
5. PRD development (ISRLaw requirements specification)
6. Cross-jurisdiction test: FireLaw → ISRLaw upgrade path

---

**License:** CC BY 4.0  
**Author:** Stephen Sweeney, Flightworks Aerial LLC  
**Contact:** stephen@flightworksaerial.com
