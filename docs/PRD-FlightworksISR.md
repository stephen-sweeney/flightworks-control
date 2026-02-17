# Flightworks ISR: Product Requirements Document (ISRLaw Jurisdiction)

**Document:** PRD-FI-ISR-2026-001  
**Version:** 0.1 (Draft)  
**Date:** February 2026  
**Author:** Stephen Sweeney, Flightworks Aerial LLC  
**Status:** Architecture Draft  
**Classification:** Public

---

## Executive Summary

Flightworks ISR is a governed AI ground control station for **distributed swarm Intelligence, Surveillance, and Reconnaissance operations in contested environments**. ISRLaw is the most demanding jurisdiction in the Flightworks Suite, designed for military, law enforcement, and defense applications where adversarial threats, communications denial, and multi-asset coordination are primary operating conditions — not edge cases.

ISRLaw inverts the assumption that governs all other jurisdictions: communications denial is not a failure state to recover from — it is the **expected operating condition**. The authority model is therefore pre-loaded before launch, not negotiated in real-time.

### Core Value Proposition

> **"Every autonomous decision made under comms denial was pre-authorized by the mission commander, executed within deterministic bounds, and recorded in a tamper-evident audit trail that can be replayed for operational review, legal accountability, and lessons learned."**

**Key Differentiators:**
- **Pre-Loaded Authority:** Mission commander defines the autonomy envelope at T-minus; the swarm operates within it at T-zero
- **Partition Tolerance:** Swarm continues governed operations when the mesh network fragments
- **EMCON Governance:** Law 0 treats RF emissions as boundary violations — same enforcement model as filesystem containment
- **GPS-Denied Navigation:** Deterministic fallback ladder from GPS through INS through visual odometry
- **Classification-Aware:** Law 5 enforces data classification at the state transition level, not as an access control bolt-on
- **Evidence and Chain of Custody:** Complete audit trail maintained independently on each drone, reconciled on merge

### Strategic Alignment

| Strategic Goal | Flightworks ISR Approach |
|----------------|--------------------------|
| **Defense Market** | Directly serves military/LE swarm ISR requirements |
| **Codex Thesis** | Proves deterministic governance under maximum adversarial pressure |
| **Drone Command Alignment** | Architecture maps to Drone Command's operational needs |
| **Competitive Differentiation** | Governed autonomy vs. black-box autonomy in contested environments |

---

## Product Vision

### The Problem: Autonomous ISR in Contested Environments

**Operational Context:**
- Military and law enforcement ISR missions require persistent surveillance of areas where human operators cannot be present
- Adversaries will jam datalinks, spoof GPS, and attempt to deny or degrade UAS operations
- Current swarm systems either require continuous connectivity (operationally useless under jamming) or operate as fully autonomous black boxes (unauditable, untrusted, uncertifiable)
- Coalition operations require classification-aware data handling that most systems treat as an afterthought

**Current Solutions Fall Short:**
- GCS-dependent swarms: Operationally brittle — lose comms, lose the mission
- Fully autonomous AI: No governance, no audit trail, no legal accountability
- Single-asset ISR: Cannot cover meaningful areas, single point of failure
- Cloud-dependent processing: Latency and connectivity incompatible with contested ops

### The Solution: Pre-Loaded Governed Autonomy

**ISRLaw governs a swarm that operates within a pre-authorized autonomy envelope when communications are denied.** The mission commander defines exactly what the swarm may do autonomously — what sectors to scan, what task types are authorized, what EMCON posture to maintain, what triggers abort. The swarm then executes within those bounds, with every decision governed by the same Reducer, same Laws, same audit trail as if the commander were watching in real-time.

**The Agency Paradox holds:** AI proposes, humans decide. The humans decided at T-minus. The autonomy envelope is the Law.

**Mission Phases:**
1. **Brief** — Commander defines AO, authority envelope, EMCON schedule, abort criteria, classification rules
2. **Launch** — Swarm departs, establishes mesh, transits to AO
3. **Autonomous** — Swarm operates within pre-loaded authority (comms denied expected)
4. **Reconnect** — GCS contact restored, commander reviews autonomous decisions
5. **Debrief** — Evidence package generated, authority compliance verified, replay confirmed

---

## Target Users

### Primary: Mission Commander

**Persona:** Military officer or law enforcement tactical commander authorizing and overseeing UAS swarm ISR operations

**Goals:**
- Define mission parameters completely before launch (AO, authority, EMCON, ROE)
- Trust that the swarm will operate within authorized bounds during comms denial
- Review all autonomous decisions upon reconnection
- Use the evidence package for operational reporting and legal accountability

**Constraints:**
- Must pre-authorize sufficient autonomy for the mission to succeed under comms denial
- Cannot over-authorize — pre-loaded authority must be bounded and auditable
- Must comply with rules of engagement and data classification requirements
- May be managing multiple simultaneous ISR missions

### Secondary: UAS Operator / Swarm Supervisor

**Persona:** Trained UAS operator managing swarm launch, transit, and recovery; monitoring when comms available

**Goals:**
- Execute mission briefing (translate commander's intent into system configuration)
- Monitor swarm during connected phases (transit, reconnect)
- Manage swarm recovery and evidence collection
- Troubleshoot degraded operations (individual drone issues, partition events)

**Constraints:**
- May have limited bandwidth for real-time monitoring during autonomous phase
- Must handle partition reconciliation when swarm fragments reconnect
- Hardware and software proficiency under field conditions

### Tertiary: Intelligence Analyst

**Persona:** Post-mission analyst reviewing collected intelligence and operational decisions

**Goals:**
- Access collected detections with imagery, classification, and geolocation
- Understand which detections were made under what conditions (GPS confidence, EMCON state)
- Verify that classification rules were followed (Law 5 compliance)
- Correlate swarm detections with other intelligence sources

**Needs:**
- Structured detection data with confidence and provenance metadata
- Track histories showing entity movement over time
- Clear indication of position confidence (GPS vs. INS-derived vs. estimated)
- Classification-appropriate data handling throughout the evidence chain

### Quaternary: Legal / Compliance Reviewer

**Persona:** Post-mission reviewer verifying that autonomous operations complied with authorization and ROE

**Goals:**
- Prove the swarm never exceeded its pre-loaded authority envelope
- Verify EMCON discipline was maintained (no unauthorized emissions)
- Confirm classification rules were enforced (no unauthorized data sharing)
- Verify abort criteria were correctly evaluated

---

## Use Cases

### UC-1: Pre-Mission Authority Loading

**Goal:** Fully configure the swarm's autonomous authority envelope before launch

**Preconditions:**
- Mission plan approved through chain of command
- Swarm hardware preflight complete
- GCS connected to all swarm members

**Flow:**
1. Commander opens Flightworks ISR, creates new mission
2. Commander/operator defines Area of Operations boundary (Law 7)
3. Commander assigns sectors (Named Areas of Interest) with priorities
4. Commander sets autonomy envelope:
   - Authorized task types (area search, route recon, persistent overwatch)
   - Detection authority level (classify only → classify + track + report + recommend)
   - Swarm re-tasking permission (can drones reallocate tasks among themselves?)
   - Adaptive search permission (can search pattern adapt based on detections?)
   - Maximum range from rally point
   - Altitude band for autonomous operations
5. Commander sets EMCON schedule (transit posture, AO posture, burst windows)
6. Commander defines abort criteria (fleet attrition threshold, duration limit, threat level)
7. Commander configures data classification rules (Law 5)
8. Commander reviews complete mission plan summary
9. Commander authorizes mission (Law 8 HIGH-RISK) — authority locked (Law 6)
10. System hashes mission authority state and logs to audit trail

**Success Criteria:**
- All authority envelope parameters configurable through mission planning interface
- Mission authorization is a single, explicit, auditable action
- Authority cannot be modified by the swarm after launch (only by commander via authenticated command)
- Mission authority hash recorded for replay verification

---

### UC-2: Autonomous Swarm Operations (Comms Denied)

**Goal:** Swarm executes ISR mission within pre-loaded authority during communications denial

**Flow:**
1. Swarm arrives in AO, transitions to autonomous phase
2. EMCON posture applied per schedule (may restrict all emissions)
3. Swarm allocates tasks via lease model (Law 2):
   - Priority sectors scanned first
   - Detections classified deterministically (ML confidence → threat band)
   - Tracks maintained on classified detections (if authorized)
4. If mesh partitions:
   - Each partition elects local leader (lowest DroneID — deterministic)
   - Partitioned drones continue current tasks within local authority
   - Detection data stored locally (Law 6 — immutable)
5. If GPS denied or spoofed:
   - Navigation mode ladder activates (GPS → INS → visual → dead reckoning)
   - Position confidence degrades and is recorded with each detection
   - Spoof detection triggers GPS untrust (INS primary)
6. If abort criterion met: swarm initiates RTB
7. All decisions governed by Reducer, all transitions audited

**Success Criteria:**
- Every autonomous decision traceable to pre-loaded authority envelope
- No action permitted outside authorized envelope (Reducer rejects)
- Detections committed with position confidence appropriate to nav mode
- Partition operations continue within governed bounds
- All autonomous decisions recorded in local audit trail per drone

---

### UC-3: EMCON Compliance (Law 0)

**Goal:** Maintain emissions discipline across all EMCON levels

**Flow:**
1. Mission plan defines EMCON schedule (e.g., ALPHA during transit, BRAVO in AO)
2. During EMCON ALPHA (emissions prohibited):
   - All RF transmission actions rejected by Law 0
   - Detections stored locally, no reporting possible
   - Mesh network silent — drones operate independently
3. During EMCON BRAVO (burst only):
   - Burst transmissions permitted during authorized windows only
   - Payload size limited per policy
   - Priority-ranked: detection summaries before telemetry
4. During EMCON CHARLIE (power-limited):
   - Mesh active at reduced power
   - Full telemetry but limited range
5. EMCON transitions:
   - Scheduled transitions execute automatically (per mission plan)
   - Threat-driven tightening permitted (restriction only, never relaxation)
   - Only commander override (via comms) can relax EMCON level

**Success Criteria:**
- Zero unauthorized emissions at any EMCON level
- Law 0 rejection logged for every blocked transmission attempt
- Burst transmissions only occur during authorized windows
- EMCON level can tighten autonomously but never relax without commander

---

### UC-4: Partition Tolerance and Reconciliation

**Goal:** Swarm continues governed operations during mesh partition and reconciles correctly when partition heals

**Flow:**
1. Mesh network fragments (terrain, jamming, distance)
2. Each partition detects membership change
3. Local leader elected deterministically (lowest DroneID among healthy members)
4. Local leader inherits delegation authority scoped to partition (Law 2)
5. Partitioned drones continue tasks — lease renewals and reallocations within partition
6. Detection data stored locally per drone (Law 6 — immutable, append-only)
7. Partition duration bounded by `maxAutonomousDuration` or local abort criteria
8. When partitions merge:
   - Detection logs merged using timestamp ordering (conflicts preserved, not resolved)
   - Task lease state reconciled (revoke duplicates, reassign)
   - Global leader re-elected
   - Merged state reported to GCS if connected

**Success Criteria:**
- Leader election is deterministic and auditable (no randomness)
- No authority escalation during partition (Law 2 invariant)
- Detection logs from all partitions preserved intact after merge
- Reconciliation produces consistent fleet state
- Complete partition history recorded in evidence package

---

### UC-5: Reconnect and Commander Review

**Goal:** Restore real-time authority and enable commander review of autonomous decisions

**Flow:**
1. GCS contact restored with swarm (or partition)
2. Detection logs synchronized from each drone to GCS
3. Lease state reconciled across any pending partitions
4. System generates autonomous decision summary:
   - Total detections committed (with severity distribution)
   - Task reallocations performed
   - EMCON transitions executed
   - Partition events and leader elections
   - Abort criteria evaluations (even if not triggered)
5. Commander reviews autonomous decisions:
   - Approve or flag individual decisions for follow-up
   - May modify authority envelope for continued operations
   - May issue new tasking based on collected intelligence
6. Real-time authority restored — system transitions from pre-loaded to live governance

**Success Criteria:**
- Detection sync completes without data loss from any drone
- Autonomous decision summary accurately reflects all swarm activity
- Commander can review and annotate individual decisions
- Authority handback is a clean, auditable transition
- No gap in governance during handback process

---

### UC-6: Evidence Package and Authority Compliance

**Goal:** Generate evidence proving the swarm operated within pre-loaded authority throughout the mission

**Preconditions:**
- Mission complete (RTB or terminated)
- All drones recovered or accounted for
- Detection logs synchronized

**Flow:**
1. Operator requests evidence package generation
2. System compiles:
   - **Mission Replay:** Complete state transition history from briefing through debrief
   - **Collection Report:** All detections with location confidence, sensor data, classification, associated tracks
   - **Authority Compliance Report:** Every autonomous decision mapped to authority envelope constraint
   - **EMCON Compliance Report:** Every emission event or rejected emission with EMCON level
   - **Partition Report:** Timeline of partitions, leader elections, local decisions, reconciliation
   - **GPS Integrity Report:** Navigation mode transitions, spoof events, position confidence over time
3. Hash chain verified independently per drone, then across merged trail
4. Package classified per mission data handling rules (Law 5)

**Success Criteria:**
- Authority compliance report confirms zero envelope violations
- EMCON compliance report confirms zero unauthorized emissions
- Hash chain integrity verified across all drones (including partitioned periods)
- Package generation completes within 120 seconds for 4-hour missions
- Package respects classification rules (no data leakage across clearance levels)

---

## Functional Requirements

### FR-1: Mission Authority and Planning

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-1.1 | System shall support autonomous authority envelope definition (authorized tasks, sectors, detection authority, re-tasking permission, altitude band, max range) | P0 | Config test |
| FR-1.2 | Mission authorization shall be a Law 8 HIGH-RISK action with commander authentication | P0 | Invariant test |
| FR-1.3 | Mission authority shall be locked (Law 6) after authorization — swarm cannot self-modify | P0 | Invariant test |
| FR-1.4 | Mission authority state shall be hashed and recorded for replay verification | P0 | Audit test |
| FR-1.5 | EMCON schedule shall support per-phase configuration (ALPHA/BRAVO/CHARLIE/DELTA) | P0 | Config test |
| FR-1.6 | Abort criteria shall be configurable (fleet attrition, duration, threat level) | P0 | Config test |
| FR-1.7 | Data classification rules (Law 5) shall be configurable per mission | P0 | Config test |

---

### FR-2: Swarm Governance

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-2.1 | Swarm membership shall track status (active, degraded, lost, confirmed lost, returned) | P0 | State test |
| FR-2.2 | Leader election shall be deterministic: min(DroneID) among healthy members | P0 | Property test |
| FR-2.3 | Task leases shall be bounded in time and scope, with no authority escalation (Law 2) | P0 | Invariant test |
| FR-2.4 | Swarm re-tasking (if authorized) shall be deterministic given fleet state | P0 | Property test |
| FR-2.5 | Adaptive search (if authorized) shall modify patterns within AO bounds only (Law 7) | P0 | Spatial test |
| FR-2.6 | Member loss shall trigger task redistribution to remaining healthy members | P0 | State test |

---

### FR-3: Partition Tolerance

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-3.1 | Partition detection shall be deterministic based on heartbeat timeout | P0 | Timer test |
| FR-3.2 | Each partition shall elect a local leader independently | P0 | Property test |
| FR-3.3 | Local leader authority shall be scoped to partition membership (Law 2) | P0 | Invariant test |
| FR-3.4 | Detection data shall be stored locally per drone during partition (Law 6) | P0 | Invariant test |
| FR-3.5 | Partition healing shall merge detection logs using timestamp ordering | P0 | Integration test |
| FR-3.6 | Conflicting classifications shall be preserved as separate records, not resolved | P0 | Schema test |
| FR-3.7 | Partition duration shall be bounded by maxAutonomousDuration or local abort criteria | P0 | Timer test |

---

### FR-4: EMCON Governance (Law 0)

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-4.1 | EMCON ALPHA shall reject ALL RF transmission actions | P0 | Invariant test |
| FR-4.2 | EMCON BRAVO shall permit burst transmissions during authorized windows only | P0 | Timer + state test |
| FR-4.3 | EMCON CHARLIE shall enforce transmit power limits | P0 | State test |
| FR-4.4 | EMCON transitions toward restriction shall be autonomously permitted | P0 | State test |
| FR-4.5 | EMCON relaxation shall require commander override or schedule | P0 | Invariant test |
| FR-4.6 | All emission events and rejections shall be logged with EMCON level | P0 | Audit test |

---

### FR-5: Detection and Classification

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-5.1 | Detection commitment shall be immutable once hashed (Law 6) | P0 | Invariant test |
| FR-5.2 | Entity classification shall be deterministic (ML confidence → threat band) | P0 | Property test: 10,000 iterations |
| FR-5.3 | Each detection shall record: location, location confidence, timestamp, sensor type, raw confidence, threat band, classification level, frame IDs, audit hash | P0 | Schema test |
| FR-5.4 | Track creation and maintenance shall follow deterministic association rules | P0 | Algorithm test |
| FR-5.5 | Classification level enforcement (Law 5) shall prevent unauthorized data sharing | P0 | Invariant test |

---

### FR-6: GPS-Denied Navigation Governance

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-6.1 | Navigation mode fallback ladder shall be deterministic (GPS → INS → visual → dead reckoning → RTB) | P0 | State test |
| FR-6.2 | GPS/INS cross-check shall detect spoofing attempts | P0 | Simulation test |
| FR-6.3 | Spoof detection shall trigger GPS untrust — INS becomes primary | P0 | State test |
| FR-6.4 | Position confidence shall be recorded with every detection | P0 | Schema test |
| FR-6.5 | INS drift exceeding mission-critical threshold shall trigger RTB (abort criterion) | P0 | Timer + state test |
| FR-6.6 | Multi-vehicle GPS anomaly correlation shall increase spoof confidence | P1 | Algorithm test |

---

### FR-7: Reconnect and Handback

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-7.1 | Detection log sync shall transfer all locally stored detections to GCS | P0 | Integration test |
| FR-7.2 | Partition reconciliation shall merge state without data loss | P0 | Integration test |
| FR-7.3 | Autonomous decision summary shall be generated for commander review | P0 | Schema test |
| FR-7.4 | Commander review shall support approve/flag/annotate for individual decisions | P1 | UI test |
| FR-7.5 | Authority handback to real-time governance shall be a clean, auditable transition | P0 | State test |
| FR-7.6 | Authority envelope modification (post-reconnect) shall require commander re-authorization | P0 | Invariant test |

---

### FR-8: Evidence Package

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-8.1 | Evidence package shall include: mission replay, collection report, authority compliance report, EMCON compliance report, partition report, GPS integrity report | P0 | Schema test |
| FR-8.2 | Authority compliance report shall map every autonomous decision to envelope constraint | P0 | Replay test |
| FR-8.3 | SHA256 hash chain shall be verifiable per drone and across merged trail | P0 | Integrity test |
| FR-8.4 | Evidence package shall respect classification rules (Law 5) | P0 | Classification test |
| FR-8.5 | Package generation shall complete within 120 seconds for 4-hour missions | P1 | Performance test |
| FR-8.6 | Deterministic replay shall produce identical state for all autonomous decisions | P0 | Replay test |

---

## Non-Functional Requirements

### NFR-1: Determinism

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-1.1 | Authority envelope enforcement | 100% — zero envelope violations under any conditions | Invariant test |
| NFR-1.2 | Detection classification determinism | 100% identical threat bands | Property test: 10,000 iterations |
| NFR-1.3 | Leader election determinism | 100% identical leader selection given same membership | Property test |
| NFR-1.4 | Task allocation determinism | 100% identical assignments given same state | Property test |
| NFR-1.5 | Replay accuracy | 100% state hash match across full mission | End-to-end replay |

### NFR-2: Performance

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-2.1 | Detection classification latency | <200ms from sensor input to threat band | Performance test |
| NFR-2.2 | Partition detection latency | <heartbeat timeout + 2s | Timer test |
| NFR-2.3 | Leader election latency | <1s from partition detection | State test |
| NFR-2.4 | EMCON transition latency | <500ms from trigger to new emissions posture | State test |
| NFR-2.5 | Navigation mode fallback | <1s from GPS integrity change to new nav mode | State test |
| NFR-2.6 | Evidence package generation | <120s for 4-hour mission | Performance test |

### NFR-3: Reliability

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-3.1 | Mission completion rate (SITL) | >95% of authorized missions | Simulation testing |
| NFR-3.2 | Detection commitment success | 100% (local storage on each drone) | Fault injection |
| NFR-3.3 | Partition reconciliation success | 100% (no data loss on merge) | Simulation testing |
| NFR-3.4 | EMCON compliance | 100% — zero unauthorized emissions | Invariant test |
| NFR-3.5 | Authority compliance | 100% — zero envelope violations | Invariant test |

### NFR-4: Security

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-4.1 | Mission authority tamper resistance | Hash chain detects any modification | Integrity test |
| NFR-4.2 | Classification enforcement | Zero cross-level data leaks | Classification test |
| NFR-4.3 | Spoof detection sensitivity | >90% detection for GPS spoof scenarios | Simulation test |
| NFR-4.4 | Audit trail integrity | Hash chain verified per drone and merged | Integrity test |

---

## Success Metrics

### MVP Success Metrics

| Metric | Target |
|--------|--------|
| End-to-end SITL mission reliability | 100% across 10 consecutive runs |
| Authority compliance verification | 100% — zero envelope violations |
| EMCON compliance verification | 100% — zero unauthorized emissions |
| Partition reconciliation accuracy | 100% — no data loss |
| Deterministic replay match | 100% state hash match |
| Leader election determinism | 100% — same membership → same leader |

### Operational Metrics (Simulation Validation)

| Metric | Target |
|--------|--------|
| AO coverage achieved (4-hour mission) | >80% of authorized sectors |
| Detection classification consistency | 100% deterministic |
| Partition survival (governed operations continue) | 100% of partition events |
| GPS-denied navigation accuracy (INS primary) | Drift within mission-critical threshold |
| Reconnect and handback success | 100% — clean authority transition |

### Technical Metrics

| Metric | Target |
|--------|--------|
| Determinism verification | 100% pass |
| Audit log integrity (per drone) | 100% verified |
| Merged audit log integrity | 100% verified |
| Law 0 invariant (EMCON compliance) | 100% verified |
| Law 2 invariant (no authority escalation) | 100% verified |
| Law 5 invariant (classification enforcement) | 100% verified |
| Law 6 invariant (detection immutability) | 100% verified |

---

## Platform Support

### Primary Platform

| Component | Specification |
|-----------|---------------|
| Aircraft | PX4/MAVLink-compatible UAS with ISR payload |
| Likely platforms | Skydio X10, Shield AI V-BAT, custom PX4-based |
| GCS (tactical) | Ruggedized tablet, iOS 17+ |
| GCS (mobile command) | Vehicle-mounted system |
| GCS (persistent) | Deployable ground station |

### Development Platform

| Component | Specification |
|-----------|---------------|
| SITL simulation | PX4 SITL with synthetic sensor feeds |
| Adversarial testing | Deterministic GPS denial / comms jamming injection |
| Partition testing | Simulated mesh fragmentation at precise moments |
| Replay verification | Full mission deterministic replay |

### Future Enhancements

| Component | Phase | Notes |
|-----------|-------|-------|
| Multi-echelon C2 | Phase 2+ | Brigade → battalion → company → platoon |
| Coalition sharing | Phase 2+ | Multi-partner classification-aware data exchange |
| EW countermeasures | Phase 3+ | Platform-specific threat response |
| Cross-jurisdiction upgrade | Future | FireLaw → ISRLaw runtime transition |

---

## Development Roadmap

### Phase 1: Governance Core (SITL)

**Goal:** ISRLaw state machine with pre-loaded authority, partition tolerance, and EMCON governance — fully testable in simulation

**Deliverables:**
- ISRState domain model implementation
- ISRReducer with authority envelope enforcement
- Mission authority loading and locking (Law 6)
- Task lease lifecycle with partition-scoped delegation (Law 2)
- EMCON state machine with Law 0 emission enforcement
- Leader election protocol (deterministic, min DroneID)
- Audit trail with per-drone SHA256 hash chain
- Partition detection, operation, and reconciliation protocol

**Success Criteria:**
- Authority envelope violations rejected by Reducer (100%)
- EMCON compliance enforced across all emission levels
- Partition scenarios produce governed autonomous operations
- Leader election deterministic under all membership configurations
- All state transitions logged and replayable

---

### Phase 2: Detection and Navigation

**Goal:** Detection pipeline, track management, and GPS-denied navigation governance

**Deliverables:**
- Detection commitment with immutability (Law 6)
- Entity classification with deterministic threat banding
- Track creation, update, and correlation
- GPS integrity monitoring and spoof detection
- Navigation mode fallback ladder
- Position confidence tracking per detection
- Classification level enforcement (Law 5)

**Success Criteria:**
- Detection classification is 100% deterministic
- GPS spoof detection triggers correct nav mode transition
- Position confidence accurately reflects navigation mode
- Classification rules prevent unauthorized data sharing
- Track management produces consistent state under replay

---

### Phase 3: Operator Interface

**Goal:** Mission planning, monitoring, and post-mission review interfaces

**Deliverables:**
- Mission planning interface (AO, sectors, authority envelope, EMCON, abort criteria)
- Mission authorization workflow (Law 8 HIGH-RISK)
- Swarm status monitoring (connected phases)
- Reconnect and handback interface
- Commander review of autonomous decisions
- Detection and track visualization

**Success Criteria:**
- Commander can define complete mission authority in <20 minutes
- Mission authorization is a single, explicit, auditable action
- Autonomous decision summary clear and reviewable
- Authority handback is a clean transition

---

### Phase 4: Evidence and Replay

**Goal:** Evidence package generation, authority compliance verification, and deterministic replay

**Deliverables:**
- Evidence package generator (all six report types)
- Authority compliance verifier
- EMCON compliance verifier
- Deterministic replay engine (per drone and merged)
- Hash chain verification tool (per drone and cross-drone)
- Classification-appropriate evidence export (Law 5)

**Success Criteria:**
- Replay produces identical state hashes for 4-hour missions
- Authority compliance confirmed for all autonomous decisions
- EMCON compliance confirmed (zero unauthorized emissions)
- Hash chain verified per drone and across merged trail
- Evidence package respects classification rules

---

### Phase 5: Simulation Validation

**Goal:** Comprehensive adversarial scenario testing in SITL

**Deliverables:**
- GPS denial scenario suite (spoofing, degradation, denial)
- Comms jamming scenario suite (partial, full, intermittent)
- Partition scenario suite (2-way, multi-way, cascading)
- Compound adversarial scenarios (GPS + comms + attrition simultaneously)
- Fleet attrition scenarios (member loss during mission)
- Operational demonstration for defense stakeholders

**Success Criteria:**
- All adversarial scenarios produce governed, auditable behavior
- No scenario produces authority envelope violation
- Evidence packages generate correctly for all scenarios
- System degrades gracefully under compound adversarial conditions
- Demonstration builds stakeholder confidence

---

## Constraints & Assumptions

### Technical Constraints

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| Onboard compute (per drone) | Local inference and audit storage limits | Lightweight models, efficient log format |
| Mesh network bandwidth | Detection sharing and fleet coordination | Priority-based data sharing, EMCON-aware transmission |
| INS drift over time | Position accuracy degrades without GPS | Visual odometry fallback, drift-aware confidence tracking |
| Battery endurance | Mission duration limits for small UAS | Fleet rotation, rally point staging |

### Business Constraints

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| No active defense contract | No classified requirement validation | Unclassified architecture, gov't-ready design |
| Drone Command alignment pending | Integration specifics TBD | Architecture maps to known Drone Command needs |
| Single developer (initial phases) | Scope management | SITL-first, governance logic before hardware |
| Export control considerations | Technical content distribution | Unclassified design only, ITAR awareness |

### Assumptions

| Assumption | Risk if Invalid | Validation |
|------------|-----------------|------------|
| Pre-loaded authority model sufficient for military ISR | Operators need real-time override during autonomous phase | Military SME review; reconnect override capability |
| Deterministic leader election (min DroneID) acceptable vs. capability-based | Suboptimal leader selection degrades performance | SITL testing with varied fleet compositions |
| Partition reconciliation via timestamp ordering sufficient | Data conflicts unresolvable | Simulation with high-contention partition scenarios |
| Skydio X10 / PX4 platforms available for gov't ISR | Platform unavailable | Architecture is MAVLink-agnostic |

---

## Acceptance Criteria

Flightworks ISR MVP is **ready for simulation validation** when:

1. ✅ End-to-end SITL mission completes (brief → autonomous → reconnect → debrief)
2. ✅ Authority envelope enforcement is 100% — zero violations under any scenario
3. ✅ EMCON compliance is 100% — zero unauthorized emissions
4. ✅ Task lease governance correct (Law 2 invariants hold)
5. ✅ Detection commitment immutable (Law 6 invariants hold)
6. ✅ Classification enforcement active (Law 5 — no unauthorized sharing)
7. ✅ Partition tolerance functional (leader election, local governance, reconciliation)
8. ✅ GPS-denied navigation ladder operates correctly
9. ✅ Evidence package generates with verified hash chain (per drone and merged)
10. ✅ Deterministic replay produces identical state for full mission
11. ✅ Commander can load authority and review autonomous decisions
12. ✅ FlightLaw safety floor active on every drone in all conditions

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [HLD-FlightworksISR.md](./HLD-FlightworksISR.md) | ISRLaw architecture specification |
| [HLD-FlightworksFire.md](./HLD-FlightworksFire.md) | FireLaw jurisdiction (ISRLaw builds on FireLaw patterns) |
| [PRD-FlightworksFire.md](./PRD-FlightworksFire.md) | FireLaw requirements |
| [HLD-FlightworksCore.md](./HLD-FlightworksCore.md) | FlightLaw foundation |
| [PRD-FlightworksCore.md](./PRD-FlightworksCore.md) | FlightLaw requirements |
| [Flightworks-Suite-Overview.md](./Flightworks-Suite-Overview.md) | Suite architecture |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | Feb 2026 | S. Sweeney | Initial ISRLaw PRD — architecture draft |

---

**Document Control**

- **Owner:** Stephen Sweeney, Flightworks Aerial LLC
- **Review Cycle:** As needed during architecture phase
- **Distribution:** Internal, open-source project documentation

---

## Conclusion

Flightworks ISR demonstrates that **governed AI operates in the hardest environments**. By combining:

- **Pre-loaded authority** (human decides at T-minus, Reducer enforces at T-zero)
- **EMCON governance** (Law 0 treats emissions as boundary violations)
- **Partition tolerance** (governed operations continue when the mesh fragments)
- **Classification enforcement** (Law 5 at the state transition level, not bolted on)
- **GPS-denied navigation governance** (deterministic fallback with confidence tracking)
- **Evidence and chain of custody** (per-drone audit trail, reconciled on merge)

...we create an ISR system that is simultaneously:
- **Autonomous enough** for comms-denied contested environments
- **Bounded enough** that every autonomous decision traces to commander authority
- **Resilient enough** to survive jamming, spoofing, partition, and attrition
- **Auditable enough** for post-mission legal and operational accountability

ISRLaw is the ultimate stress test for the SwiftVector Codex. If deterministic governance can hold under GPS denial, comms jamming, mesh partition, and adversarial threat — while every decision remains attributable, auditable, and replayable — the thesis is proven.

**The progression tells a story:**
- ThermalLaw: "Governed AI assists an operator doing a job."
- FireLaw: "Governed AI operates when the operator can't be everywhere."
- ISRLaw: "Governed AI operates when no human can be present at all."

At every level, the Codex holds. The Laws compose. The Reducer enforces. The audit proves.
