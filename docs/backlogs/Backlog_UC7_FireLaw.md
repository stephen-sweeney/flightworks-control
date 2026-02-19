# Backlog: UC-7 — Overnight Wildfire Perimeter Monitoring & Hotspot Triage (FireLaw)

**Backlog ID:** BL-UC7-FIRE-2026-001  
**Generated:** 2026-02-18  
**PM Agent:** Senior PM (Safety-Critical GCS)  
**Status:** DRAFT — Requires AIC approval before sprint planning  
**Input Documents:** OUCB §6 UC-7, HLD-FlightworksFire, Domain Notes: Perimeter Wildfire Management, PRD-FlightworksCore (FlightLaw baseline), ARCHITECTURE.md, ROADMAP.md

---

## 0) Scope & Assumptions

### In Scope

- FireLaw jurisdiction governance logic (pure Swift, no hardware dependency)
- Escalation-tier authority model (4-tier: Routine → Elevated → Critical → Emergency)
- Sector-based coverage governance with freshness decay
- Task lease model (Law 2 delegation for multi-asset operations)
- Detection persistence (Law 6 immutability for committed hotspot facts)
- Airspace deconfliction state machine (AirspaceMode transitions including ground-stop)
- Degraded-mode governance (comms loss → authority contraction → FlightLaw fallback)
- Operator presence model (.active / .monitoring / .dormant / .unreachable)
- SOP template loading and threshold configuration
- Evidence package generation (perimeter report, authority report, coverage report, detection log)
- SITL simulation scenarios for all governance paths
- FireReducer determinism verification (property-based tests, 10,000 iterations)

### Out of Scope

- Physical dock-and-launch integration (simulated as events in SITL)
- Thermal ML model training or architecture (sensor pipeline is bought; governance is built)
- ICS dispatch system integration (Phase 2+ per HLD-FlightworksFire)
- Hardware-specific mesh networking or radio configuration
- ISRLaw swarm consensus (future jurisdiction; FireLaw uses centralized GCS authority)
- Cloud connectivity features (edge-first constraint)
- Production UI polish (this backlog covers governance logic + design spikes; full UI is a subsequent backlog)

### Hard Constraints

| Constraint | Source | Implication |
|---|---|---|
| FlightLaw must be complete before FireLaw implementation begins | ROADMAP Phase 0 dependency | All FireLaw stories assume FlightLaw Reducer, Orchestrator, and audit trail exist |
| Edge-first / zero cloud dependency | OUCB §7.4, product doctrine | All governance runs on iPad + Edge Relay; no server calls during operations |
| Deterministic governance | SwiftVector Codex | FireReducer must be a pure function. Same inputs → same escalation tier, same lease allocation, same coverage prediction |
| iPad (iOS) primary platform | ROADMAP platform constraint | SwiftUI, Swift concurrency (actors), CoreLocation |
| Simulation-first development | ROADMAP "Hardware Gate" | All stories must be verifiable in SITL before hardware integration |
| BVLOS + night operations authorization assumed | Domain Notes §7.2, §7.4 | GCS enforces authorization constraints but does not obtain them |

### Key Assumptions (⚠)

| ID | Assumption | Risk if Wrong | Validation Method |
|---|---|---|---|
| A-1 | Escalation tier thresholds (ROUTINE/ELEVATED/CRITICAL/EMERGENCY) from HLD are operationally valid | Tier triggers may be too sensitive (alert fatigue) or too conservative (missed escalations) | Tabletop exercise with fire SME; historical incident data calibration |
| A-2 | 3–6 drone fleet size is the operational target for overnight perimeter monitoring | Architecture may under/over-scale if actual fleet sizes differ | Fire agency interviews; Drone Command fleet data |
| A-3 | Dock-and-launch battery swap can be modeled as a discrete event (DroneID departs → DroneID returns with new battery level) without dock hardware details | Swap timing, failure modes, and positioning may introduce governance edge cases not captured by event model | SITL scenario stress testing with randomized swap failures |
| A-4 | The IC notification path is an out-of-band channel (radio, push notification, phone call) — the GCS records the notification event but does not deliver it digitally to the IC's device | If digital IC notification is required, a new integration dependency exists | AIC decision + fire agency workflow validation |
| A-5 | Operator presence transitions (.active → .monitoring → .dormant) are self-reported by the operator, not inferred from inactivity | If inactivity-based detection is needed, idle timer logic and thresholds must be designed | UX research with fire UAS supervisors |
| A-6 | Manned aircraft deconfliction relies on procedural notification (radio call → operator enters ground-stop command), not automatic ADS-B ingestion | If ADS-B auto-ingestion is required, a hardware and data pipeline dependency is introduced | AIC decision based on target deployment environment |
| A-7 | Coverage freshness thresholds from HLD CoveragePolicy (critical=120s, high=300s, standard=600s, low=900s) are reasonable starting points | Thresholds may need fire-behavior-dependent adjustment (wind speed multiplier) | SME calibration session; SITL scenario testing |

### Open Questions (❓)

| ID | Question | Blocking? | Proposed Resolution Path |
|---|---|---|---|
| OQ-1 | What is the acceptable latency from ground-stop command to all-drones-clear? Is 30 seconds a defensible target? | **Yes** — blocks S-06 acceptance criteria | AIC decision informed by Domain Notes §7.3 and fire aviation safety standards |
| OQ-2 | Should escalation timeout auto-promotion (ELEVATED→CRITICAL after SLA expiry) be configurable per-SOP or hardcoded? | No — default to configurable, but needs AIC confirmation | AIC preference check |
| OQ-3 | What GeoOps export format(s) must the evidence package support? GeoJSON? Shapefile? GeoPackage? Geospatial PDF? | No — deferred to evidence package epic | GISS workflow interview |
| OQ-4 | How does the FireReducer handle simultaneous CRITICAL escalations in multiple sectors? Serial queue? Priority ranking? | **Yes** — blocks S-03 edge case design | Engineering spike (T-03.4) |
| OQ-5 | Is the "minimum fresh coverage guarantee" (70% from HLD CoveragePolicy) a hard constraint (triggers EMERGENCY if breached) or a soft target? | **Yes** — blocks S-04 acceptance criteria | AIC decision |

### 🚨 AIC QUESTIONS (must-answer to proceed)

These are blocking decisions that only the Agent-In-Command can make. Without answers, the marked stories remain in BLOCKED status.

| AIC-Q ID | Question | Blocks | Recommended Default | Rationale |
|---|---|---|---|---|
| **AIC-Q1** | Is the ground-stop latency target ≤30 seconds from command receipt to all drones below 200ft AGL? | S-06, T-06.* | Yes, 30s | Domain Notes §7.3 identifies this as life-safety; 30s provides margin over typical manned aircraft approach speeds |
| **AIC-Q2** | Should we conduct a formal tabletop exercise with a fire operations SME before committing to the escalation tier model? | E-02 (all stories), Sprint 1 scope | Yes, schedule before Sprint 2 | OUCB §8.3 and Domain Notes §9.2 both recommend this as the first validation step |
| **AIC-Q3** | Is the IC notification channel out-of-band only (A-4), or must the GCS deliver digital notifications? | S-03, evidence package design | Out-of-band only for MVP; log the event, do not deliver it | Reduces integration risk; fire agencies already have radio/phone escalation protocols |
| **AIC-Q4** | Is 70% minimum-fresh-coverage a hard EMERGENCY trigger or a soft metric? (OQ-5) | S-04, S-03 | Hard trigger — breaching 70% with operator dormant → EMERGENCY | Conservative default protects credibility; can relax later with operational data |
| **AIC-Q5** | Confirm: FireLaw governance development is gated on FlightLaw Phase 0 + Phase 1 completion, targeting earliest start in Phase 4 (post field-test)? | All epics — timeline | Yes | ROADMAP shows FlightLaw + Edge Relay as prerequisites; FireLaw is architecture-phase (P2) |

---

## 1) Product Slice Strategy (Thin Vertical Slices)

FireLaw is complex. Shipping it as a monolith would take 6+ months and defer all feedback. Instead, we slice vertically so that each slice is independently testable in SITL, demonstrable to fire SMEs, and extends the FlightLaw foundation without breaking it.

### Slice 1 (MVP): "Single-Drone Overnight Monitor"

**Goal:** Prove the escalation tier model and coverage freshness governance work with a single drone scanning a sectorized perimeter. No multi-asset delegation. No dock-swap. Operator presence model active.

**What ships:**
- FireState, FireAction, FireReducer (core types)
- SOP template loading with configurable thresholds
- Sector definition and priority assignment
- Sector freshness tracking with decay
- Hotspot detection commitment (Law 6 persistence)
- 4-tier escalation function (pure, deterministic)
- Escalation timeout auto-promotion ladder
- Operator presence state machine
- SITL scenarios: overnight single-drone, detection in each tier, operator dormant timeout cascade
- Evidence: complete audit trail with hash chain

**Why this first:** Validates the hardest conceptual innovation (escalation model) without the distributed-systems complexity of multi-asset. A fire SME can review the escalation scenarios and give feedback before we invest in fleet governance.

**Acceptance gate:** FireReducer property test passes 10,000 iterations. Tabletop scenario with fire SME does not invalidate the tier model.

### Slice 2: "Fleet Governance + Task Leases"

**Goal:** Extend to 3–6 drones with Law 2 task lease delegation, battery-swap scheduling, and predictive gap management.

**What ships:**
- FleetState and lease lifecycle (grant / renew / revoke / transfer / expire)
- LeaseAllocator (pure function: fleet state + task pool → assignments)
- Battery swap event handling (simulated dock events)
- Predictive coverage gap management
- Lease handoff during swap (Drone A → Drone B audit continuity)
- SITL scenarios: fleet of 4 with staggered battery swaps, lease revocation for priority re-tasking, simultaneous swap + detection

**Acceptance gate:** 8-hour SITL run with 4 drones, randomized battery depletion, and injected detections produces valid audit trail with zero coverage gaps exceeding policy thresholds.

### Slice 3: "Airspace Deconfliction + Degraded Modes + Evidence Package"

**Goal:** Handle the dangerous edge cases — manned aircraft ground-stop, comms degradation cascade, full partition fallback — and produce the after-action deliverables fire agencies need.

**What ships:**
- AirspaceMode state machine (normal → mannedAircraftActive → groundStop)
- Ground-stop response: all drones below altitude ceiling within latency target
- DegradedModeState transitions (nominal → reducedBandwidth → intermittent → droneIsolated → gcsIsolated → fullPartition)
- Conservative mode activation on unacknowledged EMERGENCY
- Evidence package export (perimeter report, authority report, coverage report, detection log)
- GeoOps-compatible export format(s)
- SITL scenarios: ground-stop during active scan, progressive comms failure, full partition with onboard FlightLaw fallback

**Acceptance gate:** Ground-stop scenario clears all drones within AIC-Q1 latency target. Comms failure cascade produces correct degraded mode at each stage. Evidence package passes format validation for target export standard.

---

## 2) Epics

### E-01: FireLaw Core Types & Reducer

**Goal:** Establish the foundational state, action, and reducer types for the FireLaw jurisdiction so that all subsequent governance logic has a typed, testable substrate.

**User/Value Statement:** As the *engineering team*, I need the FireState/FireAction/FireReducer types implemented and property-tested so that all FireLaw governance stories can build on a verified deterministic foundation.

**Dependencies:**
- FlightLaw Orchestrator and Reducer (Phase 0) — must exist for FireLaw to extend
- SwiftVectorCore package (State/Action/Reducer protocols)

**Definition of Done:**
- [ ] `FireState` struct compiles, conforms to `State`, `Equatable`, `Codable`, `Sendable`
- [ ] `FireAction` enum compiles, conforms to `Action`, covers complete registry from HLD Appendix A
- [ ] `FireReducer` is a pure function: `(FireState, FireAction) → FireState`
- [ ] Property-based test: 10,000 random action sequences produce identical state from identical inputs
- [ ] FlightLaw laws (3, 4, 7, 8) are composed into FireReducer evaluation chain
- [ ] Code compiles with zero warnings under strict concurrency checking

**Risks:**
1. FireState complexity may exceed Swift struct copy performance budget → mitigation: benchmark early, consider copy-on-write wrappers for large collections
2. Action registry from HLD may be incomplete once implementation begins → mitigation: treat HLD as draft, add actions via PR with AIC review
3. Composing FlightLaw + FireLaw reducers may surface ordering dependencies → mitigation: design spike on Law evaluation order (T-01.3)

**Notes:**
- Source: HLD-FlightworksFire §Domain Model, §Appendix A (FireLaw Actions)
- ⚠ A-7 applies: CoveragePolicy thresholds are initial values pending SME calibration

---

### E-02: Escalation Tier Governance

**Goal:** Implement the deterministic 4-tier escalation model that governs what the system may do autonomously versus what requires human approval at each severity level, including timeout-based auto-promotion.

**User/Value Statement:** As a *Fire UAS Supervisor* starting a night shift, I need to trust that the system will wake me for genuinely important detections and let me sleep through routine operations, with mathematically provable escalation behavior.

**Dependencies:**
- E-01 (FireLaw core types)
- FlightLaw Law 8 (Authority) implementation

**Definition of Done:**
- [ ] Escalation function is pure: `f(detection, sector, weather, fleet, operatorPresence) → EscalationTier`
- [ ] All four tiers (ROUTINE, ELEVATED, CRITICAL, EMERGENCY) have correct trigger conditions per HLD
- [ ] Timeout ladder works: ELEVATED→CRITICAL→EMERGENCY with SOP-configurable windows
- [ ] Conservative mode activates on unacknowledged EMERGENCY
- [ ] Every escalation evaluation is logged to audit trail with inputs and result
- [ ] SITL test suite covers: each tier individually, timeout promotion chain, compound triggers (weather + detection + coverage), operator presence transitions

**Risks:**
1. Alert fatigue: thresholds too sensitive → mitigation: AIC-Q2 tabletop with fire SME before Sprint 2
2. Escalation function complexity may make the Reducer hard to reason about → mitigation: extract escalation as a separate pure function called by Reducer
3. Simultaneous multi-sector escalations (OQ-4) may create ordering ambiguity → mitigation: engineering spike

**Notes:**
- Source: HLD-FlightworksFire §FireLaw Escalation Model, §Tier Definitions
- Source: Domain Notes §6.2 (overnight patrol delegation), §3.3 (LCES safety)
- ⚠ A-1 applies: tier thresholds need field calibration
- ❓ OQ-2 applies: timeout configurability decision

---

### E-03: Sector Coverage & Freshness Governance

**Goal:** Implement the sector-based coverage model where information freshness decays over time and the system predicts and prevents coverage gaps through deterministic re-tasking.

**User/Value Statement:** As a *Fire UAS Supervisor*, I need the GCS to guarantee that the head of the fire is never unmonitored for more than 15 minutes, the flanks for more than 30 minutes, and the heel for more than 60 minutes — and to escalate before a gap occurs, not after.

**Dependencies:**
- E-01 (FireLaw core types — SectorState, CoverageMap, CoveragePolicy)
- FlightLaw Law 7 (Spatial) for geofence validation of sector boundaries

**Definition of Done:**
- [ ] Sector freshness decays deterministically based on elapsed time + wind decay multiplier
- [ ] Freshness states transition correctly: `.fresh` → `.aging` → `.stale` → `.unknown`
- [ ] Predictive gap detection fires re-tasking recommendation before sector goes stale
- [ ] Coverage gap → escalation integration works (stale critical sector during wind event → CRITICAL)
- [ ] Minimum fresh coverage guarantee (AIC-Q4 hard/soft decision) is enforced
- [ ] SITL scenarios: normal decay, wind-accelerated decay, fleet insufficient for coverage policy

**Risks:**
1. Freshness thresholds may not reflect actual fire behavior dynamics → mitigation: wind decay multiplier is configurable in SOP template
2. Predictive gap model may over-trigger re-tasking on small fleets → mitigation: tunable prediction horizon
3. Sector boundary definition UX is non-trivial → mitigation: design spike (S-10)

**Notes:**
- Source: HLD-FlightworksFire §Coverage Governance, §Predictive Gap Management
- Source: Domain Notes §5.1 (SA gap), §6.5 (coverage scalability)
- ⚠ A-7 applies: thresholds are initial values

---

### E-04: Task Lease Delegation (Law 2)

**Goal:** Implement the task lease model that governs how the GCS delegates sector patrol and detection verification tasks to individual drones, including lease lifecycle, handoff, and battery-swap continuity.

**User/Value Statement:** As a *Remote Pilot* monitoring a fleet overnight, I need the system to automatically re-assign patrol tasks when drones swap batteries, without any gap in sector coverage and without any drone exceeding its authorized permissions.

**Dependencies:**
- E-01 (FireLaw core types — TaskLease, FleetState)
- E-03 (Coverage governance — stale sectors generate tasks for the pool)
- FlightLaw Law 2 (Delegation) protocol

**Definition of Done:**
- [ ] Lease lifecycle: grant → renew → expire/revoke/transfer/complete — all transitions logged
- [ ] Law 2 constraint enforced: delegated authority ≤ delegator's authority
- [ ] LeaseAllocator is a pure function: `(FleetState, TaskPool, CoverageMap) → [LeaseGrant]`
- [ ] Battery swap handoff: Drone A lease expires → task returns to pool → Drone B lease granted — audit chain unbroken
- [ ] Lease revocation for priority re-tasking works (critical detection → revoke lower-priority lease)
- [ ] SITL: 4-drone fleet, 8-hour run, staggered swaps, no coverage gap exceeds policy

**Risks:**
1. LeaseAllocator may become a scheduling optimization problem that's hard to keep deterministic → mitigation: use priority queue, not optimization solver
2. Simultaneous swap + detection may create a resource conflict with no valid allocation → mitigation: design explicit "insufficient fleet" escalation path
3. Lease duration tuning (60–120s per HLD) may be too short or too long → mitigation: configurable per SOP

**Notes:**
- Source: HLD-FlightworksFire §Task Lease Governance
- ⚠ A-2 applies: fleet size assumption (3–6 drones)
- ⚠ A-3 applies: dock swap modeled as discrete event

---

### E-05: Airspace Deconfliction & Degraded Modes

**Goal:** Implement the safety-critical state machines for manned aircraft deconfliction (ground-stop response) and progressive communications degradation, ensuring the system fails safe to FlightLaw when higher governance layers become unreachable.

**User/Value Statement:** As an *Air Tactical Group Supervisor (ATGS)* issuing a ground-stop order, I need every UAS to clear the airspace within a defined time window — deterministically, without exception, regardless of what the drones were doing.

**Dependencies:**
- E-01 (FireLaw core types — AirspaceState, DegradedModeState)
- FlightLaw Law 7 (Spatial) — ground-stop dynamically contracts the safety envelope
- E-04 (Task leases — ground-stop revokes all active leases)

**Definition of Done:**
- [ ] AirspaceMode state machine: normal → mannedAircraftActive → mannedAircraftImmediate → groundStop — all transitions deterministic
- [ ] Ground-stop: all drones below altitude ceiling within AIC-Q1 latency target
- [ ] All active leases revoked on ground-stop; tasks returned to pool
- [ ] DegradedMode transitions: nominal → reducedBandwidth → intermittent → droneIsolated → gcsIsolated → fullPartition
- [ ] Full partition: FireLaw governance suspended; each drone falls back to onboard FlightLaw; RTL after policy.partitionTimeout
- [ ] Conservative mode: all drones hold position on unacknowledged EMERGENCY
- [ ] SITL: ground-stop during active fleet scan; progressive comms failure cascade; full partition with FlightLaw fallback

**Risks:**
1. Ground-stop latency target may be unachievable with current MAVLink command latency → mitigation: benchmark in SITL; if >30s, raise to AIC as risk
2. "Full partition" means FireLaw cannot govern — the system honestly acknowledges this. Risk: operators expect continued fire monitoring → mitigation: clear UX messaging about reduced capability
3. ADS-B auto-ingestion (A-6) decision could significantly expand scope → mitigation: AIC decided out-of-band for MVP

**Notes:**
- Source: HLD-FlightworksFire §Airspace Deconfliction Governance, §Degraded Mode Governance
- Source: Domain Notes §3.4 (aerial hazard), §7.1 (TFR compliance), §7.3 (deconfliction)
- 🚨 AIC-Q1 blocks acceptance criteria
- ⚠ A-6 applies: procedural deconfliction for MVP

---

### E-06: Evidence Package & After-Action Audit

**Goal:** Generate the post-incident deliverables that fire agencies need: perimeter progression, detection history, authority/escalation record, and coverage metrics — all linked to a tamper-evident audit trail.

**User/Value Statement:** As an *Incident Commander* reviewing drone operations from the night shift, I need a single evidence package that tells me what the drones saw, what the system escalated, what the operator did about it, and whether the audit trail is intact.

**Dependencies:**
- E-01 (Audit trail with SHA256 hash chain — inherited from FlightLaw)
- E-02 (Escalation events for authority report)
- E-03 (Coverage metrics for coverage report)
- E-04 (Lease history for fleet operations report)

**Definition of Done:**
- [ ] Evidence package contains: perimeter report, authority report, coverage report, detection log
- [ ] All reports link to specific audit trail entries via hash references
- [ ] Replay verification: replay all FireActions through FireReducer → identical final state hash
- [ ] Export in at least one GeoOps-compatible format (❓ OQ-3 — format TBD)
- [ ] Generation completes in <60 seconds for an 8-hour session
- [ ] SITL: generate evidence package from 8-hour multi-drone scenario; verify hash chain integrity

**Risks:**
1. GeoOps format requirements may not be fully known until GISS workflow interview → mitigation: implement GeoJSON as baseline; add formats as validated
2. 8-hour audit trail may be large (>100MB) → mitigation: benchmark; consider compression
3. Evidence package must survive legal scrutiny — hash chain must be independently verifiable → mitigation: document verification procedure; provide standalone verification tool

**Notes:**
- Source: HLD-FlightworksFire §Evidence Package, §What FireLaw Proves About the Codex
- Source: Domain Notes §4.4 (liability and review), §9.1 (after-action evidence package)
- ❓ OQ-3 applies: export format decision

---

## 3) Stories

### Epic E-01: FireLaw Core Types & Reducer

---

#### S-01: FireState & FireAction Type Definitions

**Story ID:** S-01  
**Epic:** E-01  
**Name:** Define FireState struct and FireAction enum with full type coverage  
**Operator Persona:** Engineering team (foundational infrastructure)  
**Priority:** P0 | **Rationale:** Every other FireLaw story depends on these types existing  
**Est. Effort:** M | **Confidence:** High

**Problem Statement:** FireLaw governance cannot be implemented without a typed state model and action registry. The HLD specifies the domain model but it has not been translated into compilable Swift types.

**In Scope:**
- `FireState` struct conforming to `State`, `Equatable`, `Codable`, `Sendable`
- `FireAction` enum conforming to `Action` — complete registry from HLD Appendix A
- All nested types: `SectorState`, `HotspotDetection`, `TaskLease`, `FleetState`, `EscalationState`, `AirspaceState`, `DegradedModeState`, `CoverageMap`, `CoveragePolicy`, `AuthorityChain`, `OperatorPresence`, `CommsHealthState`, `WeatherContext`, `SOPTemplate`
- Compile-time validation: zero warnings under strict concurrency checking

**Out of Scope:**
- Reducer logic (S-02)
- UI types or view models
- Persistence layer (on-disk serialization beyond Codable conformance)

**Acceptance Criteria:**

```gherkin
Given the FireLaw Swift package
When all source files compile under strict concurrency checking
Then zero warnings and zero errors are produced

Given a FireState instance is created with valid initial values
When it is encoded to JSON and decoded back
Then the decoded instance is equal to the original (Codable round-trip)

Given a FireAction.commitDetection action
When the detection ID, location, confidence, and timestamp are provided
Then the action type captures all fields required by Law 6 persistence
```

**Test Notes:**
- Manual: code review confirms 1:1 correspondence between HLD domain model and Swift types
- Automation: Codable round-trip tests for every top-level type; Equatable conformance tests; Sendable compile-time check

**Telemetry/Evidence:** Compilation log (zero warnings); test report with type coverage metrics

**Jurisdiction Tags:** FireLaw, FlightLaw (composition)

**Dependencies:** SwiftVectorCore package (State/Action protocols), FlightLaw base types

**AIC Questions:** None

**Source References:**
- HLD-FlightworksFire §Domain Model (FireState, Key Domain Types)
- HLD-FlightworksFire §Appendix A: FireLaw Actions (Complete Registry)

---

#### S-02: FireReducer Implementation & Determinism Verification

**Story ID:** S-02  
**Epic:** E-01  
**Name:** Implement FireReducer as a pure function with property-based determinism proof  
**Operator Persona:** Engineering team / Safety investigator (replay verification depends on this)  
**Priority:** P0 | **Rationale:** The Reducer IS the governance layer. Without verified determinism, no FireLaw claim holds.  
**Est. Effort:** L | **Confidence:** Medium

**Problem Statement:** The FireReducer must compose FlightLaw base governance (Laws 3, 4, 7, 8) with FireLaw extensions (Laws 2, 6) and the escalation/coverage/deconfliction logic — all as a single pure function. This is the highest-complexity Reducer in the Flightworks Suite and requires rigorous determinism proof.

**In Scope:**
- `FireReducer: (FireState, FireAction) → FireState` implementation
- FlightLaw law evaluation composed before FireLaw-specific evaluation
- Escalation function integration (called within Reducer, result stored in state)
- Coverage freshness update on relevant actions (scan complete, time advance)
- Task lease lifecycle state transitions
- Audit trail entry generation for every action (hash chain continuation)
- Property-based test: 10,000 random action sequences, verify identical final state

**Out of Scope:**
- Orchestrator integration (async action dispatch — separate story)
- Side effects (notification delivery, drone commands — Reducer is pure)
- UI binding

**Acceptance Criteria:**

```gherkin
Given a FireState S and a FireAction A
When FireReducer(S, A) is called twice with identical inputs
Then the outputs are identical (determinism)

Given a sequence of 10,000 randomly generated FireActions
When applied to an initial FireState
Then replaying the same sequence produces an identical final state hash

Given a FireAction that violates FlightLaw (e.g., geofence breach)
When evaluated by FireReducer
Then the action is rejected with a typed rejection reason
And the rejection is recorded in the audit trail

Given a FireAction.commitDetection with valid inputs
When processed by FireReducer  
Then the detection is immutable in subsequent state (Law 6)
And any attempt to mutate it via a future action is rejected
```

**Test Notes:**
- Automation: property-based tests using swift-testing or SwiftCheck; randomized action sequence generator; state hash comparison
- Manual: code review of Reducer for side-effect-free implementation (no I/O, no Date.now, no random)
- Performance: benchmark Reducer evaluation latency — target <5ms median per action

**Telemetry/Evidence:** Property test report (10,000 iterations, pass/fail); performance benchmark CSV; audit trail from test run (verifiable via replay)

**Jurisdiction Tags:** FireLaw, FlightLaw (composed)

**Dependencies:** S-01 (types must exist), FlightLaw Reducer (Phase 0 must be complete)

**AIC Questions:** None — but flag: if FlightLaw Phase 0 Reducer design changes, this story must be re-evaluated

**Source References:**
- HLD-FlightworksFire §Architectural Philosophy ("FireReducer is a pure function despite governing a complex multi-asset system")
- PRD-FlightworksCore §FR-1 (SwiftVector Core Architecture — determinism requirement)
- HLD-FlightworksFire §What FireLaw Proves About the Codex (points 1–5)

---

### Epic E-02: Escalation Tier Governance

---

#### S-03: Deterministic Escalation Function with Timeout Ladder

**Story ID:** S-03  
**Epic:** E-02  
**Name:** Implement the 4-tier escalation function and timeout auto-promotion chain  
**Operator Persona:** Fire UAS Supervisor (dormant overnight, trusting the tier model to wake them only when necessary)  
**Priority:** P0 | **Rationale:** The escalation model is the core governance innovation of FireLaw. It is the feature that fire agencies are buying. If it doesn't work, nothing else matters.  
**Est. Effort:** L | **Confidence:** Medium

**Problem Statement:** When the system detects a thermal anomaly at 2 AM while the UAS Supervisor is asleep, the response must be proportionate, deterministic, and auditable. The escalation function must evaluate detection severity, sector priority, weather context, fleet health, and operator presence — and produce the correct tier every time. If the operator doesn't acknowledge within the SLA, the tier must auto-promote. If no one acknowledges the EMERGENCY, the system must enter conservative mode.

**In Scope:**
- Pure escalation function: `f(detection, sector, weather, fleet, operatorPresence) → EscalationTier`
- Tier trigger conditions per HLD §Tier Definitions (ROUTINE, ELEVATED, CRITICAL, EMERGENCY)
- Timeout auto-promotion: ELEVATED → CRITICAL → EMERGENCY (SOP-configurable windows)
- Conservative mode activation on unacknowledged EMERGENCY (all drones hold position)
- Operator presence state machine: `.active` / `.monitoring` / `.dormant` / `.unreachable`
- Operator heartbeat mechanism (presence confirmed by periodic interaction)
- Compound trigger support (weather + detection + coverage degradation = escalated tier)
- Every escalation evaluation logged with full inputs and result

**Out of Scope:**
- IC notification delivery mechanism (A-4: out-of-band for MVP; event logged)
- Notification UI design (design spike S-10)
- Escalation threshold calibration with historical data (post-SME-tabletop)

**Acceptance Criteria:**

```gherkin
Given a low-confidence detection in a non-priority sector with operator active
When the escalation function evaluates the inputs
Then the result is ROUTINE
And the evaluation is logged with all input values and the result

Given a high-confidence detection outside the perimeter in a priority sector
When the escalation function evaluates with operator dormant
Then the result is CRITICAL
And the evaluation is logged

Given an ELEVATED escalation that is unacknowledged
When the operator presence SLA expires (e.g., 5 minutes for .monitoring)
Then the tier auto-promotes to CRITICAL
And the promotion is logged with "timeout" as the trigger

Given a CRITICAL escalation that is unacknowledged
When the critical timeout expires (SOP-configurable)
Then the tier auto-promotes to EMERGENCY
And the IC notification event is logged (delivery is out-of-band)

Given an EMERGENCY that remains unacknowledged after the emergency timeout
When conservative mode activates
Then all drones hold current positions
And no new leases are granted
And the audit trail records "conservative mode activated — emergency unacknowledged"

Given identical escalation inputs applied twice
When the escalation function runs
Then it produces identical tier results (determinism)
```

**Test Notes:**
- Automation: exhaustive tier boundary tests (every combination of sector priority × operator presence × detection confidence); property-based test with randomized compound inputs; timeout simulation tests with injected clock
- Manual: tabletop walkthrough with fire SME (AIC-Q2) reviewing each tier definition
- Edge case: simultaneous CRITICAL in two sectors (OQ-4) — if unresolved, test that both are logged and the operator sees both

**Telemetry/Evidence:** Escalation evaluation log entries with full input hashes; timeout promotion audit trail entries; conservative mode activation record

**Jurisdiction Tags:** FireLaw, FlightLaw Law 8 (Authority)

**Dependencies:** S-01, S-02 (types and Reducer), FlightLaw Law 8 implementation

**AIC Questions:**
- AIC-Q2: Tabletop exercise scheduling — recommend before Sprint 2 starts
- AIC-Q3: IC notification channel — out-of-band only for MVP?
- ❓ OQ-2: Timeout configurability per SOP — recommended default: yes, configurable
- ❓ OQ-4: Simultaneous multi-sector CRITICAL handling — needs engineering spike

**Source References:**
- HLD-FlightworksFire §FireLaw Escalation Model (escalation function, tier definitions, timeout ladder)
- HLD-FlightworksFire §Operational Phases (Phase 4: Overnight Steady State)
- Domain Notes §6.2 (overnight patrol, sleeping crews)
- Domain Notes §3.3 (LCES safety)
- OUCB §6 UC-7 (scenario description, governance architecture)

---

### Epic E-03: Sector Coverage & Freshness Governance

---

#### S-04: Sector Freshness Decay & Predictive Gap Detection

**Story ID:** S-04  
**Epic:** E-03  
**Name:** Implement sector freshness tracking with time-decay, wind multiplier, and predictive gap alerts  
**Operator Persona:** Fire UAS Supervisor (needs confidence that the head of the fire is never unmonitored beyond policy threshold)  
**Priority:** P1 | **Rationale:** Coverage governance enables autonomous operation. Without it, a human must manually track which sectors need scanning — defeating the purpose of overnight autonomy. Ranked P1 because it's exercised primarily by the task allocator (E-04) which depends on it.  
**Est. Effort:** M | **Confidence:** Medium

**Problem Statement:** A sector scanned 10 minutes ago provides less certainty than one scanned 2 minutes ago, and the decay rate depends on fire conditions (wind accelerates uncertainty). The system must track this decay, predict when sectors will go stale, and generate re-tasking recommendations before gaps occur — not after.

**In Scope:**
- Freshness state transitions: `.fresh` → `.aging` → `.stale` → `.unknown` (thresholds from CoveragePolicy, configurable per SOP)
- Wind decay multiplier application (multiply freshness decay rate during wind events)
- Predictive gap detection: given drone positions, scan rates, battery projections, and lease expirations — predict which sectors will go stale and when
- Integration with escalation (stale critical sector during wind event → CRITICAL escalation)
- Minimum fresh coverage guarantee enforcement (AIC-Q4)

**Out of Scope:**
- Task allocation response to gaps (E-04 / S-05)
- Sector boundary definition UX (design spike S-10)
- Fire behavior modeling (we track freshness, not fire spread prediction)

**Acceptance Criteria:**

```gherkin
Given a critical sector scanned 120 seconds ago with no wind modifier
When the freshness model evaluates
Then the sector is `.fresh`

Given the same sector at 121 seconds
When the freshness model evaluates
Then the sector transitions to `.aging`

Given a critical sector at 100 seconds with wind decay multiplier 1.5x
When the freshness model evaluates (effective age = 150s > 120s threshold)
Then the sector is `.aging`

Given fleet positions and battery projections
When the predictive gap model identifies that Sector 3 (critical) will go stale in 45 seconds and no drone can reach it in time
Then a re-tasking recommendation is generated
And the recommendation enters the escalation model

Given fresh coverage drops below the minimum guarantee (e.g., 70%)
When the coverage model evaluates with operator dormant
Then an EMERGENCY escalation is triggered (if AIC-Q4 = hard trigger)
```

**Test Notes:**
- Automation: time-step simulation with deterministic clock; property tests for freshness monotonicity (freshness never increases without a scan event); wind multiplier boundary tests
- Manual: review decay curves with fire SME for operational realism

**Telemetry/Evidence:** Sector freshness log (per-evaluation entries); coverage percentage over time series; gap prediction events in audit trail

**Jurisdiction Tags:** FireLaw, FlightLaw Law 7 (sector boundaries validated as geofences)

**Dependencies:** S-01 (SectorState, CoveragePolicy types), S-02 (Reducer processes freshness updates), S-03 (escalation integration)

**AIC Questions:** AIC-Q4 (hard vs. soft coverage guarantee)

**Source References:**
- HLD-FlightworksFire §Coverage Governance (freshness model, predictive gap management, CoveragePolicy)
- Domain Notes §5.1 (SA gap — "the fire as it is, not as it was 12 hours ago")
- Domain Notes §6.5 (coverage gap management)

---

### Epic E-04: Task Lease Delegation (Law 2)

---

#### S-05: Task Lease Lifecycle & Battery Swap Handoff

**Story ID:** S-05  
**Epic:** E-04  
**Name:** Implement task lease grant/renew/revoke/transfer/expire lifecycle with battery-swap handoff continuity  
**Operator Persona:** Remote Pilot (monitoring fleet overnight, expects seamless handoff when drones swap batteries)  
**Priority:** P1 | **Rationale:** Multi-asset delegation is what makes FireLaw operationally useful for overnight coverage. Without lease handoff, every battery swap requires manual re-tasking.  
**Est. Effort:** L | **Confidence:** Medium

**Problem Statement:** When Drone A's battery reaches the RTL threshold during a sector patrol, its task must transfer to Drone B without coverage gap, without authority escalation, and with unbroken audit continuity. The lease model must enforce Law 2: the receiving drone inherits exactly the permissions the departing drone held, no more.

**In Scope:**
- Full lease lifecycle: `grant` → `renew` → `expire` / `revoke` / `transfer` / `complete`
- Law 2 enforcement: delegated authority ≤ delegator authority
- LeaseAllocator pure function: `(FleetState, TaskPool, CoverageMap) → [LeaseGrant]`
- Battery swap sequence: (1) Drone A lease marked `expiring`, (2) task returned to pool on expire, (3) Drone B allocated from pool, (4) new lease granted with audit link to prior lease
- Lease revocation for priority re-tasking (critical detection → revoke lower-priority scan lease)
- Maximum renewal count enforcement (prevents indefinite lease holding)

**Out of Scope:**
- Dock hardware integration (swap is a simulated event: drone departs, drone returns)
- Drone selection algorithm optimization (LeaseAllocator uses priority queue, not solver)

**Acceptance Criteria:**

```gherkin
Given Drone A holds a lease for "Scan Sector 3" 
When Drone A's battery triggers RTL
Then the lease expires
And the task "Scan Sector 3" returns to the unassigned pool
And the audit trail records: Lease L1 expired → task returned

Given "Scan Sector 3" is in the unassigned pool and Drone B is available
When the LeaseAllocator runs
Then Drone B receives a new lease for "Scan Sector 3"
And the new lease's audit entry links to the prior lease (L1)
And Drone B's authority level does not exceed the GCS delegation level (Law 2)

Given Drone C holds a "Scan Sector 7" lease (standard priority)
When a CRITICAL detection occurs requiring hotspot verification
Then Drone C's lease is revoked
And Drone C is re-assigned to "Verify Detection #42" via new lease
And the revocation reason is recorded in the audit trail

Given a lease has been renewed 5 times (max renewals = 5)
When a renewal is requested
Then the renewal is rejected
And the lease expires normally
And the task returns to the pool

Given identical FleetState, TaskPool, and CoverageMap inputs
When LeaseAllocator runs twice
Then the lease grant outputs are identical (determinism)
```

**Test Notes:**
- Automation: lease lifecycle state machine tests (every valid transition); Law 2 authority constraint tests (attempt to escalate via lease → rejected); 8-hour SITL run with randomized battery depletion and swap events
- Manual: review lease handoff audit trail for continuity (no gaps, no authority escalation)

**Telemetry/Evidence:** Lease lifecycle audit entries; LeaseAllocator decision log; coverage gap analysis during swap windows

**Jurisdiction Tags:** FireLaw, FlightLaw Law 2 (Delegation)

**Dependencies:** S-01, S-02, S-04 (coverage gaps generate tasks for the pool)

**AIC Questions:** None

**Source References:**
- HLD-FlightworksFire §Task Lease Governance (lease model, Law 2 constraints, LeaseAllocator)
- HLD-FlightworksFire §Operational Phases (Phase 5: Shift Change & Sustainment)
- OUCB §6 UC-7 ("drones operate autonomously through the night, swapping batteries at dock stations, handing off sectors")

---

### Epic E-05: Airspace Deconfliction & Degraded Modes

---

#### S-06: Ground-Stop Response State Machine

**Story ID:** S-06  
**Epic:** E-05  
**Name:** Implement AirspaceMode state machine with ground-stop latency guarantee  
**Operator Persona:** ATGS / Air Boss (external authority issuing ground-stop order; expects immediate UAS compliance)  
**Priority:** P1 | **Rationale:** Ground-stop non-compliance is a life-safety-of-flight issue — it can cause manned aircraft to be grounded, directly impacting fire suppression. This is the highest-consequence failure mode in FireLaw.  
**Est. Effort:** M | **Confidence:** Low (depends on AIC-Q1 latency target and MAVLink command latency benchmarks)

**Problem Statement:** When the ATGS orders a ground-stop, every UAS must clear the operational altitude within a defined time window. The GCS must transition through AirspaceMode states deterministically, revoke all active task leases, and command all drones to descend — regardless of what they were doing. No exceptions. No overrides.

**In Scope:**
- AirspaceMode state machine: `normal` → `mannedAircraftActive` → `mannedAircraftImmediate` → `groundStop`
- Ground-stop trigger: operator inputs ground-stop command (procedural, per A-6)
- On ground-stop: (1) all active leases revoked, (2) all drones commanded to descend below altitude ceiling, (3) audit trail records ground-stop event with timestamp
- Latency measurement: time from ground-stop action to last drone below ceiling
- Law 7 safety envelope dynamic contraction on mannedAircraftActive/Immediate

**Out of Scope:**
- ADS-B auto-ingestion (A-6: procedural for MVP)
- Ground-stop UX design (design spike S-10 — but: the ground-stop button must be a single-tap, maximum-contrast, zero-confirmation action)

**Acceptance Criteria:**

```gherkin
Given 4 drones at various altitudes performing sector scans
When the operator inputs a ground-stop command
Then all active leases are immediately revoked
And all drones are commanded to descend below the altitude ceiling
And the time from command to last-drone-clear is ≤ AIC-Q1 target (e.g., 30s)
And the audit trail records the ground-stop event, all lease revocations, and all descent commands with timestamps

Given a ground-stop is active
When any action that would launch or re-task a drone is proposed
Then the action is rejected by the FireReducer
And the rejection reason is "ground-stop active"

Given a ground-stop has been resolved by the ATGS
When the operator inputs a ground-stop-clear command
Then AirspaceMode transitions back to normal
And lease allocation resumes
And the audit trail records the clearance event
```

**Test Notes:**
- Automation: SITL scenario with 4 drones at varied altitudes; measure ground-stop-to-clear latency; verify lease revocation completeness
- Manual: review ground-stop audit trail for timing accuracy
- **Critical benchmark:** MAVLink command latency to all 4 drones — if >30s in SITL, raise to AIC as risk

**Telemetry/Evidence:** Ground-stop event timestamp; per-drone descent command timestamps; per-drone altitude-below-ceiling timestamps; total latency measurement

**Jurisdiction Tags:** FireLaw, FlightLaw Law 7 (dynamic safety envelope)

**Dependencies:** S-01, S-02, S-05 (lease revocation mechanism)

**AIC Questions:** 🚨 AIC-Q1 (latency target) — BLOCKING

**Source References:**
- HLD-FlightworksFire §Airspace Deconfliction Governance (AirspaceMode, deconfliction as Law 7 extension)
- Domain Notes §7.3 (manned aircraft deconfliction — "respond to ground-stop orders within seconds")
- Domain Notes §3.4 (aerial hazard)
- OUCB §6 UC-7 ("manned aircraft deconfliction — air tankers at dawn")

---

#### S-07: Degraded Communications Cascade & FlightLaw Fallback

**Story ID:** S-07  
**Epic:** E-05  
**Name:** Implement DegradedMode state transitions from nominal through full partition with FlightLaw fallback  
**Operator Persona:** Remote Pilot (needs clear system state indication when comms degrade) / System (autonomous fallback behavior)  
**Priority:** P1 | **Rationale:** Comms failure during overnight autonomous operations is not a theoretical edge case — it is an expected condition. The system must fail safe, not fail silent.  
**Est. Effort:** M | **Confidence:** Medium

**Problem Statement:** Communications between the GCS and drone fleet can degrade progressively: reduced bandwidth, intermittent dropouts, individual drone isolation, GCS isolation, full partition. At each stage, the system's autonomy envelope must contract deterministically. In full partition, FireLaw governance suspends entirely and each drone operates on onboard FlightLaw only.

**In Scope:**
- DegradedMode transitions: `nominal` → `reducedBandwidth` → `intermittent` → `droneIsolated` → `gcsIsolated` → `fullPartition`
- Per-mode autonomy envelope: what actions are permitted at each degradation level
- Lease duration shortening during intermittent comms
- Full partition: FireLaw suspended, drones on FlightLaw only, RTL after partitionTimeout
- Onboard detection logging during partition (local storage, sync on reconnect)
- Escalation integration: comms degradation is an escalation input

**Out of Scope:**
- Mesh network topology management (hardware-specific)
- Automatic reconnection protocols (transport layer, handled by Edge Relay)

**Acceptance Criteria:**

```gherkin
Given all drones have healthy comms links
When the system evaluates comms health
Then DegradedMode is `.nominal`

Given Drone B's link quality drops below the intermittent threshold
When the system evaluates
Then DegradedMode transitions to `.droneIsolated(DroneB)`
And Drone B's active lease is shortened to minimum duration
And an ELEVATED escalation is generated

Given GCS loses uplink to all drones
When gcsIsolated timeout expires without recovery
Then DegradedMode transitions to `.fullPartition`
And FireLaw governance is suspended (no new lease allocations, no escalation evaluations)
And each drone operates on onboard FlightLaw
And each drone triggers RTL after partitionTimeout
And the audit trail records the partition event and the fallback decision

Given comms are restored after a partition
When drones reconnect
Then onboard detection logs are synchronized to GCS state
And new detections are committed via Law 6 (immutable, timestamped at detection time)
And the audit trail records the reconnection and sync events
```

**Test Notes:**
- Automation: SITL scenario with injected comms failures at each degradation stage; verify correct mode transition at each step; verify FlightLaw-only behavior during partition
- Manual: review reconnection sync for data integrity (no duplicate detections, no lost detections)

**Telemetry/Evidence:** DegradedMode transition log; per-drone link quality metrics; partition event timestamps; reconnection sync audit entries

**Jurisdiction Tags:** FireLaw, FlightLaw (fallback)

**Dependencies:** S-01, S-02, Edge Relay (comms health reporting — Phase 1)

**AIC Questions:** None

**Source References:**
- HLD-FlightworksFire §Degraded Mode Governance (mode table, "the critical insight" — FlightLaw floor holds)
- Domain Notes §3.5 (comms failure hazard)
- OUCB §6 UC-7 ("degraded operator presence")

---

### Epic E-06: Evidence Package & After-Action Audit

---

#### S-08: Evidence Package Generation & Replay Verification

**Story ID:** S-08  
**Epic:** E-06  
**Name:** Generate after-action evidence package with hash-chain verification  
**Operator Persona:** Incident Commander / Safety investigator (reviewing overnight UAS operations the next morning)  
**Priority:** P2 | **Rationale:** Evidence is the primary deliverable that fire agencies pay for. However, it depends on all other governance stories being complete. Rated P2 for sequencing, not importance.  
**Est. Effort:** M | **Confidence:** Medium

**Problem Statement:** After an overnight monitoring session, the IC needs a single evidence package proving what happened. The package must be tamper-evident (SHA256 hash chain), contain all escalation decisions, detection history, coverage metrics, and fleet operations, and be exportable in a format the GISS can ingest.

**In Scope:**
- Evidence package contents: perimeter report, authority report, coverage report, detection log
- Hash chain integrity verification (replay all actions → identical final state hash)
- At least one export format (GeoJSON baseline; additional formats per OQ-3)
- Generation performance target: <60 seconds for 8-hour session

**Out of Scope:**
- PDF report layout and design (future UX story)
- ICS-209 integration (Phase 2+)

**Acceptance Criteria:**

```gherkin
Given a completed 8-hour SITL session with detections, escalations, and lease handoffs
When evidence package generation is triggered
Then the package contains: perimeter report, authority report, coverage report, detection log
And each report entry links to a specific audit trail hash
And generation completes in <60 seconds

Given the evidence package audit trail
When all FireActions are replayed through FireReducer
Then the final state hash matches the recorded final state hash
And any hash mismatch is flagged as a tamper indication
```

**Test Notes:**
- Automation: generate package from 8-hour SITL scenario; verify all four report sections present; verify hash chain integrity; benchmark generation time
- Manual: review evidence package readability with a fire operations SME

**Telemetry/Evidence:** The evidence package IS the telemetry artifact. Meta-evidence: generation time, hash verification result.

**Jurisdiction Tags:** FireLaw, FlightLaw (audit trail inheritance)

**Dependencies:** S-01 through S-07 (all governance stories produce the data the evidence package contains)

**AIC Questions:** ❓ OQ-3 (export format) — non-blocking; GeoJSON as default

**Source References:**
- HLD-FlightworksFire §Evidence Package
- Domain Notes §4.4 (liability and review), §9.1 (after-action evidence package)
- OUCB §7.2 (audit trail integrity — "not a log file, it is evidence")

---

### Cross-Cutting Stories

---

#### S-09: SOP Template Configuration & Threshold Loading

**Story ID:** S-09  
**Epic:** E-01 (cross-cutting, enables E-02 and E-03)  
**Name:** Implement SOP template loading with configurable escalation, coverage, and operational thresholds  
**Operator Persona:** Fire UAS Supervisor (configures mission parameters before the night shift begins)  
**Priority:** P1 | **Rationale:** All governance thresholds come from the SOP template. Without this, escalation tiers and coverage policies use hardcoded values that can't be adapted to incident conditions.  
**Est. Effort:** S | **Confidence:** High

**Problem Statement:** The SOP template ("Overnight Perimeter v1") defines all configurable parameters: escalation tier thresholds, coverage freshness windows, operator presence SLAs, timeout durations, wind decay multipliers, and minimum coverage guarantees. Loading a template is a Law 8 HIGH-RISK action requiring explicit authorization.

**In Scope:**
- SOPTemplate type with all configurable thresholds
- Load action validated by Law 8 (HIGH-RISK, requires UAS Program Manager or IC authorization)
- Template validation (all thresholds within safe ranges)
- Template immutability after mission authorization (cannot change thresholds mid-mission)

**Out of Scope:**
- Template editor UI (manual JSON/config for MVP)
- Template versioning or library management

**Acceptance Criteria:**

```gherkin
Given a valid SOP template JSON file
When the operator loads it and an authorized user confirms
Then all governance thresholds are set from the template
And the load event is recorded in the audit trail as HIGH-RISK authorized

Given a template with an escalation timeout of 0 seconds (invalid)
When validation runs
Then the template is rejected with a specific validation error
And the system retains the previous (or default) configuration

Given a mission is authorized with a loaded SOP template
When an action attempts to modify a threshold mid-mission
Then the action is rejected ("thresholds locked after mission authorization")
```

**Test Notes:**
- Automation: template round-trip (load → verify all fields); boundary validation tests; mid-mission modification rejection
- Manual: review template schema for completeness against HLD CoveragePolicy and EscalationTier definitions

**Telemetry/Evidence:** Template load audit entry with hash of template contents; validation result log

**Jurisdiction Tags:** FireLaw, FlightLaw Law 8

**Dependencies:** S-01 (SOPTemplate type)

**AIC Questions:** None

**Source References:**
- HLD-FlightworksFire §Operational Phases (Phase 1: Pre-Incident Setup — "SOP template defines all thresholds")
- HLD-FlightworksFire §FireLaw Escalation Model ("SLA values are set in the SOP template at mission start")

---

#### S-10: Design Spike — FireLaw Operator Experience

**Story ID:** S-10  
**Epic:** Cross-cutting (informs all epics)  
**Name:** Design spike: FireLaw GCS screens, escalation notification flow, sector map, and ground-stop interaction  
**Operator Persona:** Fire UAS Supervisor / Remote Pilot (high-stress, potentially fatigued, gloved operation, outdoor daylight visibility)  
**Priority:** P1 | **Rationale:** Governance logic without UI is untestable with operators. Design decisions (notification modality, sector visualization, ground-stop button placement) must be made before implementation stories can be fully specified.  
**Est. Effort:** M | **Confidence:** Low (design exploration, inherently uncertain)

**Problem Statement:** FireLaw introduces UI patterns that do not exist in the FlightLaw baseline: multi-drone fleet overview, sector freshness heatmap, escalation notification queue, operator presence toggle, and a single-tap ground-stop button. These screens must be designed under fire-operations constraints: high contrast for smoke/daylight, large touch targets for gloved hands, zero mode-switching during active operations.

**In Scope:**
- Wireframes for: (1) fleet overview + sector freshness map, (2) escalation notification with acknowledge/dismiss flow, (3) detection triage card (hotspot crop + metadata), (4) ground-stop button placement and interaction, (5) operator presence toggle (.active / .monitoring / .dormant)
- Interaction flow: escalation arrives → notification → operator acknowledges → reviews detection → approves/rejects → returns to fleet view
- Ground-stop interaction: single tap, maximum contrast, zero confirmation delay (life-safety override)
- Design constraints documented: minimum touch target size (44pt per Apple HIG, increased for gloves), contrast ratio (WCAG AAA for outdoor), information hierarchy

**Out of Scope:**
- Implementation (design artifacts only: wireframes, interaction specs, component inventory)
- Evidence package report layout (separate design spike)
- ICS integration screens (Phase 2+)

**Acceptance Criteria:**

```gherkin
Given the design spike deliverables
When reviewed by engineering and a fire operations SME
Then each wireframe maps to at least one governance story (S-03 through S-08)
And the ground-stop interaction requires ≤1 tap from any screen state
And the escalation notification flow is walkable end-to-end without ambiguity
And the sector freshness visualization is validated as operationally meaningful by the fire SME
```

**Test Notes:**
- Manual: design review with engineering (feasibility), fire SME (operational validity), and AIC (priority alignment)
- No automation — this is a design exploration deliverable

**Telemetry/Evidence:** Wireframe files (Figma or equivalent), interaction flow diagram, design constraints document, SME review notes

**Jurisdiction Tags:** FireLaw (all), FlightLaw (inherits base UI patterns)

**Dependencies:** Domain Notes §9 (GCS design implications), OUCB §7.5 (stress-appropriate interface design)

**AIC Questions:** AIC-Q2 (tabletop with fire SME should include design review)

**Source References:**
- Domain Notes §9.1 (Core GCS Features Implied by Domain — feature-to-governance mapping table)
- Domain Notes §9.2 (Recommended Next Steps — "GCS wireframe design")
- OUCB §7.1 (operator situational awareness — "no modal dialog should obscure aircraft position")
- OUCB §7.5 (stress-appropriate interface design)

---

## 4) Task Breakdown — Top 3 P0 Stories

### S-01 Tasks: FireState & FireAction Type Definitions

| Task ID | Name | Owner | Deliverable | Exit Criteria |
|---|---|---|---|---|
| T-01.1 | Define FireState struct with all nested types | DEV | `FireState.swift` + nested type files | Compiles with zero warnings; conforms to State, Equatable, Codable, Sendable |
| T-01.2 | Define FireAction enum with complete registry | DEV | `FireAction.swift` | All actions from HLD Appendix A represented; conforms to Action protocol |
| T-01.3 | Design spike: Law evaluation ordering in composed Reducer | TL | Architecture decision record (ADR) | Documents FlightLaw-then-FireLaw evaluation order; identifies ordering edge cases; approved by AIC |
| T-01.4 | Write Codable round-trip tests for all top-level types | QA | Test file with ≥1 round-trip test per type | All tests pass; coverage report shows every type tested |
| T-01.5 | Write Sendable/Equatable compile-time verification | QA | Test file with strict concurrency check | Compiles under `-strict-concurrency=complete` |

---

### S-02 Tasks: FireReducer Implementation & Determinism Verification

| Task ID | Name | Owner | Deliverable | Exit Criteria |
|---|---|---|---|---|
| T-02.1 | Implement FireReducer skeleton with FlightLaw composition | DEV | `FireReducer.swift` | Compiles; FlightLaw laws evaluated before FireLaw logic; action dispatch covers all FireAction cases |
| T-02.2 | Implement audit trail entry generation per action | DEV | Audit entry creation within Reducer | Every action processed produces a hash-chained audit entry; hash chain continuity verified |
| T-02.3 | Implement Law 6 persistence enforcement for committed detections | DEV | Detection immutability logic in Reducer | Any action that would mutate a committed detection is rejected with typed reason |
| T-02.4 | Build randomized action sequence generator for property tests | QA/DEV | Test utility: `FireActionGenerator` | Generates syntactically valid FireAction sequences of configurable length; covers all action variants |
| T-02.5 | Run 10,000-iteration determinism property test | QA | Property test report | 10,000 sequences × identical replay = identical final state hash; zero failures; report artifact generated |
| T-02.6 | Benchmark Reducer evaluation latency | TA | Performance benchmark CSV | Median action evaluation <5ms; p99 <20ms; benchmark run on target hardware class |

---

### S-03 Tasks: Deterministic Escalation Function with Timeout Ladder

| Task ID | Name | Owner | Deliverable | Exit Criteria |
|---|---|---|---|---|
| T-03.1 | Implement pure escalation function with tier logic | DEV | `EscalationEvaluator.swift` | Pure function; all tier trigger conditions from HLD implemented; called by FireReducer |
| T-03.2 | Implement timeout auto-promotion ladder | DEV | Timeout logic within Reducer (clock-injected) | ELEVATED→CRITICAL→EMERGENCY promotions fire at correct SOP-configured intervals; all promotions logged |
| T-03.3 | Implement operator presence state machine | DEV | `OperatorPresence` transition logic | All transitions (.active → .monitoring → .dormant → .unreachable) validated; heartbeat mechanism functional |
| T-03.4 | Engineering spike: simultaneous multi-sector CRITICAL handling | TL | ADR documenting resolution for OQ-4 | Documents ordering strategy (priority rank? serial queue? parallel evaluation?); approved by AIC; unblocks acceptance criteria edge case |
| T-03.5 | Write exhaustive tier boundary tests | QA | Test suite covering every tier trigger combination | All sector priority × operator presence × detection confidence × weather context combinations tested; 100% tier determination coverage |
| T-03.6 | Write conservative mode activation test | QA | SITL scenario test | Unacknowledged EMERGENCY → conservative mode → all drones hold → no new leases → audit trail records activation reason |

---

## AIC Decision Checklist (Minimum to Start Sprint 1)

Sprint 1 targets S-01 and S-02 (core types and Reducer) plus T-03.4 (escalation spike). Before sprint planning, the AIC must resolve:

| # | Decision | Options | PM Recommendation | Urgency |
|---|---|---|---|---|
| 1 | **AIC-Q5: Confirm FireLaw development gate** | (a) Gate on FlightLaw Phase 0+1 completion (b) Begin FireLaw types in parallel | **(a)** — types can be designed now but Reducer depends on FlightLaw Reducer existing | Before Sprint 1 |
| 2 | **AIC-Q1: Ground-stop latency target** | (a) ≤30s (b) ≤60s (c) Defer to benchmark | **(a) ≤30s** — life-safety; benchmark in Sprint 2 SITL to validate feasibility | Before S-06 is unblocked |
| 3 | **AIC-Q2: Fire SME tabletop exercise** | (a) Schedule before Sprint 2 (b) Defer to Sprint 3 (c) Skip | **(a) Before Sprint 2** — validates escalation tier model before we build it | Before Sprint 2 planning |
| 4 | **AIC-Q3: IC notification channel** | (a) Out-of-band only (GCS logs event) (b) Digital push notification to IC device | **(a) Out-of-band** for MVP — reduces scope; fire agencies have existing radio protocols | Before S-03 is unblocked |
| 5 | **AIC-Q4: 70% minimum coverage — hard or soft?** | (a) Hard EMERGENCY trigger (b) Soft metric/warning only | **(a) Hard trigger** — conservative default protects credibility; can relax with data | Before S-04 is unblocked |
| 6 | **Sprint 1 scope confirmation** | S-01, S-02, T-03.4 (spike), S-10 kickoff (design) | Recommend all four — types + Reducer + escalation spike + design kickoff in parallel | Before Sprint 1 |

---

*End of Backlog. This document is a proposal from the PM Agent. No story enters a sprint without AIC approval.*
