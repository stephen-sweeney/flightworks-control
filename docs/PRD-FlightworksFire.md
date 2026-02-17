# Flightworks Fire: Product Requirements Document (FireLaw Jurisdiction)

**Document:** PRD-FF-FIRE-2026-001  
**Version:** 0.1 (Draft)  
**Date:** February 2026  
**Author:** Stephen Sweeney, Flightworks Aerial LLC  
**Status:** Architecture Draft  
**Classification:** Public

---

## Executive Summary

Flightworks Fire is a governed AI ground control station for **wildfire perimeter monitoring and hotspot triage**, built on the FlightLaw safety kernel. FireLaw is the first Flightworks jurisdiction to exercise multi-asset governance, extended autonomous operations, and escalation-tier authority — capabilities required when operators cannot maintain continuous situational awareness across a distributed fleet operating through the night.

### Core Value Proposition

> **"Every hotspot detection, every escalation decision, every task assignment, and every coverage gap is deterministically reproducible, auditable, and attributable. The system never pretends certainty it does not have."**

**Key Differentiators:**
- **Multi-Asset Governance:** Deterministic task lease model for fleet-wide coordination
- **Escalation Tiers:** Risk-proportional authority from autonomous to wake-the-IC
- **Degraded Mode Governance:** Authority contracts when communications degrade — never expands
- **Overnight Autonomy:** Pre-configured SOP templates govern extended unattended operations
- **Evidence-First:** After-action audit trail is the primary product, not a diagnostic afterthought
- **Edge-First:** All governance logic runs on the GCS — no cloud dependency

### Strategic Alignment

| Strategic Goal | Flightworks Fire Approach |
|----------------|--------------------------|
| **Codex Scalability** | First jurisdiction proving multi-asset, operator-degraded governance |
| **Defense Market** | Direct pathway to ISRLaw contested operations via Law 2/Law 6 validation |
| **Public Safety** | Addresses critical gap in overnight wildfire monitoring capability |
| **Certifiability** | Deterministic escalation and replay prove governance under pressure |

---

## Product Vision

### The Problem: Overnight Wildfire Monitoring

**Operational Context:**
- Active wildfire perimeters require continuous monitoring, especially overnight when ground crews withdraw
- Wind shifts during early morning hours create the highest risk of perimeter escape
- Current approaches rely on manned aircraft (expensive, crew-limited) or satellite passes (infrequent, low resolution)
- Small UAS can fill this gap — but only if they can operate with minimal human supervision for hours

**Current Solutions Fall Short:**
- Manual piloting: Operator fatigue limits effective monitoring to short windows
- Simple waypoint automation: No situational awareness, no response to changing conditions
- Cloud-dependent AI: Connectivity unreliable in remote fire environments
- Single-drone systems: Cannot maintain coverage across a meaningful perimeter

### The Solution: Governed Multi-Asset Monitoring

**FireLaw governs a fleet of drones performing continuous perimeter monitoring with deterministic escalation when conditions change.** The operator sets the mission parameters (perimeter, sector priorities, escalation thresholds) via an SOP template, then the system maintains coverage autonomously — escalating to the operator or Incident Commander only when governance requires human judgment.

**Operational Phases:**
1. **Setup** — Operator defines perimeter, sectors, priorities, and SOP thresholds
2. **Launch** — Fleet deploys to assigned sectors via task leases
3. **Monitor** — Continuous thermal scanning with deterministic hotspot classification
4. **Escalate** — Detections trigger risk-proportional escalation (Routine → Emergency)
5. **Sustain** — Battery swaps and task handoffs maintain coverage through the night
6. **Debrief** — Evidence package generated for after-action review

---

## Target Users

### Primary: UAS Program Manager / Remote Pilot

**Persona:** Certified remote pilot managing overnight UAS perimeter monitoring for a fire agency or contracted service

**Goals:**
- Maintain continuous thermal coverage of the fire perimeter through the night
- Receive timely escalation when conditions change (new hotspots, perimeter breach)
- Sleep during routine operations while trusting the system to wake them for critical events
- Produce a complete after-action evidence package for the Incident Commander

**Constraints:**
- Monitoring multiple sectors with limited fleet (3–8 drones)
- Battery swaps require dock access or ground crew coordination
- Communications may degrade in remote terrain
- Must comply with TFR and manned aircraft deconfliction requirements

### Secondary: Incident Commander (IC)

**Persona:** Fire operations leader responsible for overall incident management

**Goals:**
- Understand current fire perimeter state at any moment
- Receive critical and emergency notifications only when human judgment is required
- Trust that the UAS monitoring system operated within agreed parameters
- Use the after-action evidence package for operational review and reporting

**Needs:**
- Clear, concise situation summaries when escalated
- Confidence that the system will not miss critical detections
- Confidence that the system will not generate false alarms that degrade trust
- Documentation that meets agency reporting requirements

### Tertiary: QA Reviewer / Legal

**Persona:** Post-incident reviewer verifying that operations were conducted properly

**Goals:**
- Reconstruct the complete timeline of detections, decisions, and actions
- Verify that escalation thresholds were applied correctly
- Confirm that operator/IC decisions were recorded with context
- Prove the evidence chain was not tampered with

---

## Use Cases

### UC-1: Overnight Perimeter Monitoring

**Goal:** Maintain continuous thermal coverage of a wildfire perimeter from dusk to dawn

**Preconditions:**
- Incident activated with perimeter defined
- SOP template loaded and approved (Law 8 HIGH-RISK)
- Fleet registered with capabilities confirmed
- Airspace constraints verified (TFR, deconfliction rules)

**Flow:**
1. Operator launches Flightworks Fire, loads SOP template for "Overnight Perimeter v1"
2. Operator draws/imports fire perimeter on map
3. System decomposes perimeter into sectors, suggests priorities based on terrain/structures
4. Operator reviews and adjusts sector priorities (windward, WUI exposure, etc.)
5. Operator authorizes fleet launch (Law 8 HIGH-RISK)
6. System allocates task leases — drones deploy to priority sectors
7. Continuous monitoring loop:
   - Drones scan assigned sectors on thermal
   - Detections classified deterministically (severity band + escalation tier)
   - Routine detections logged, operator notified at next review
   - Elevated/Critical detections escalate per SOP thresholds
   - Coverage gaps predicted and addressed by re-tasking or swap scheduling
8. Operator reviews queued detections during active monitoring periods
9. Battery swaps executed per schedule — task leases transfer between drones
10. Mission continues until terminated by operator or IC

**Success Criteria:**
- ≥70% of sectors remain "fresh" (within freshness policy) at all times
- Critical detections escalate to operator within SOP-defined SLA
- Battery swaps complete without coverage gaps in priority sectors
- Complete audit trail from activation through termination

---

### UC-2: Hotspot Detection and Escalation

**Goal:** Detect new thermal activity and escalate proportionally to severity

**Flow:**
1. Drone detects thermal anomaly during sector scan
2. System commits detection to state (Law 6 — immutable)
3. Deterministic classification:
   - Raw ML confidence → severity band (low/moderate/high/critical)
   - Severity + sector priority + weather + fleet state → escalation tier
4. **Tier 1 (Routine):** Detection logged, no operator notification
5. **Tier 2 (Elevated):** Operator notified, review queued
6. **Tier 3 (Critical):** Operator approval required before response action
7. **Tier 4 (Emergency):** IC notified, system enters conservative mode
8. If operator does not acknowledge within SLA, tier auto-promotes

**Success Criteria:**
- Escalation tier assignment is 100% deterministic (same inputs → same tier)
- Tier timeout ladder functions correctly (Elevated → Critical → Emergency)
- No detection is silently dropped due to operator unavailability
- All escalation decisions recorded with input hash for replay

---

### UC-3: Degraded Communications Response

**Goal:** Maintain safe operations when communications degrade

**Flow:**
1. System detects comms degradation (reduced bandwidth, intermittent, isolated drone, GCS isolated)
2. Deterministic transition to appropriate degraded mode:
   - Reduced bandwidth: Lease durations shortened, video suspended
   - Intermittent: No new assignments, drones complete current lease then hold
   - Drone isolated: Drone completes scan pass, orbits, RTL after timeout
   - GCS isolated: All drones hold, then RTL after policy timeout
3. Authority envelope contracts with each degradation step
4. On reconnection: state reconciled, nominal operations resume
5. Full partition: FireLaw governance suspended, FlightLaw safety floor active

**Success Criteria:**
- Authority never expands during degradation (less info → less authority)
- FlightLaw (battery, geofence) always enforced regardless of comms state
- All degraded mode transitions logged with trigger conditions
- Reconnection and state reconciliation succeed without data loss

---

### UC-4: Task Lease Handoff (Battery Swap)

**Goal:** Transfer sector monitoring responsibility during battery swap without coverage gaps

**Flow:**
1. Coverage model predicts Drone A will need swap in ~10 minutes
2. System schedules swap: identifies replacement Drone B, pre-stages if possible
3. Drone B receives lease for Drone A's sector
4. Drone A's lease expires, task returns to pool → immediately assigned to Drone B
5. Drone A RTLs for battery swap
6. Drone B begins sector scan, coverage freshness maintained
7. Audit trail records: Lease L1 (Drone A) → expired → Lease L2 (Drone B) granted

**Success Criteria:**
- No authority escalation through lease transfer (Law 2)
- Priority sector freshness maintained through swap
- Complete audit chain from lease grant through transfer
- Lease expiration correctly returns task to pool

---

### UC-5: After-Action Evidence Package

**Goal:** Generate comprehensive evidence package for post-incident review

**Flow:**
1. Operator or IC requests evidence package generation
2. System compiles:
   - Timeline replay (every state transition, activation through termination)
   - Detection report (all hotspots with GPS, imagery, severity, escalation, operator decisions)
   - Coverage report (per-sector freshness over time, gaps, causes)
   - Fleet report (per-drone tasks, battery, comms quality, degraded mode transitions)
   - Authority report (every escalation with triggers, tier, notification, response)
   - System health report (comms outages, GPS degradation, failsafe activations)
3. Evidence integrity verified via SHA256 hash chain
4. Package exported for agency review

**Success Criteria:**
- Package generation completes within 60 seconds for a 12-hour mission
- Hash chain integrity verified (no entries added, removed, or modified)
- Deterministic replay of any detection produces identical tier assignment
- All operator/IC decisions attributed with timestamp and context

---

## Functional Requirements

### FR-1: Incident and SOP Management

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-1.1 | System shall support SOP template loading with configurable escalation thresholds, coverage policies, and authority chains | P0 | Config test |
| FR-1.2 | SOP template acceptance shall be a Law 8 HIGH-RISK action requiring explicit authorization | P0 | Invariant test |
| FR-1.3 | Incident activation shall generate unique incident ID and initialize perimeter state | P0 | Unit test |
| FR-1.4 | Perimeter definition shall support draw-on-map and GeoJSON import | P0 | Integration test |
| FR-1.5 | Sector decomposition shall be automatic with operator override for priorities | P1 | UI test |

---

### FR-2: Fleet and Task Lease Management

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-2.1 | Task leases shall be bounded in time, scope, and renewals | P0 | Unit test |
| FR-2.2 | Lease expiration shall return task to unassigned pool | P0 | State test |
| FR-2.3 | Lease revocation shall be immediate and unconditional | P0 | State test |
| FR-2.4 | Lease transfer (drone→drone) shall preserve audit continuity | P0 | Integration test |
| FR-2.5 | Delegated authority shall never exceed delegator's authority (Law 2) | P0 | Invariant test |
| FR-2.6 | Lease allocation shall be deterministic given current state | P0 | Property test |
| FR-2.7 | Fleet registration shall track drone capabilities and readiness | P0 | Unit test |

---

### FR-3: Hotspot Detection and Classification

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-3.1 | Detection commitment shall be immutable once hashed (Law 6) | P0 | Invariant test |
| FR-3.2 | Severity band classification shall be deterministic | P0 | Property test: 10,000 iterations |
| FR-3.3 | Each detection shall record: GPS, timestamp, thermal frame, RGB frame (if available), raw confidence, severity band, escalation tier | P0 | Schema test |
| FR-3.4 | Detection verification workflow shall support operator confirm/dismiss with reason | P0 | Integration test |
| FR-3.5 | New information about a prior detection shall create a new linked detection, not mutate the original | P0 | Invariant test |

---

### FR-4: Escalation Governance

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-4.1 | Escalation tier assignment shall be a pure function of (detection, sector, weather, fleet, operator presence) | P0 | Property test |
| FR-4.2 | Tier thresholds shall be defined in SOP template and locked at mission start | P0 | Config test |
| FR-4.3 | Unacknowledged escalations shall auto-promote per timeout ladder | P0 | Timer test |
| FR-4.4 | Emergency tier shall trigger IC notification and conservative mode | P0 | Integration test |
| FR-4.5 | Every escalation evaluation shall be logged with input hash for replay | P0 | Audit test |
| FR-4.6 | Compound escalation (multiple critical conditions) shall trigger emergency | P0 | State test |

---

### FR-5: Coverage Governance

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-5.1 | Sector freshness shall be tracked per coverage policy (priority-dependent thresholds) | P0 | State test |
| FR-5.2 | Stale sectors shall generate re-scan tasks automatically | P0 | Integration test |
| FR-5.3 | Coverage gap prediction shall consider drone positions, battery, and swap scheduling | P1 | Algorithm test |
| FR-5.4 | Wind decay multiplier shall accelerate freshness aging during high-wind conditions | P1 | Unit test |
| FR-5.5 | Minimum fresh coverage guarantee shall trigger escalation when breached | P0 | State test |

---

### FR-6: Degraded Mode Governance

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-6.1 | Degraded mode transitions shall be deterministic based on comms state | P0 | State test |
| FR-6.2 | Authority shall contract at each degradation step (never expand) | P0 | Invariant test |
| FR-6.3 | Isolated drone shall complete current scan, orbit, then RTL after policy timeout | P0 | Simulation test |
| FR-6.4 | GCS isolation shall halt all new lease grants and trigger fleet hold/RTL sequence | P0 | Simulation test |
| FR-6.5 | Full partition shall suspend FireLaw governance; FlightLaw safety floor remains active | P0 | Invariant test |
| FR-6.6 | All degraded mode transitions shall be logged with trigger conditions | P0 | Audit test |

---

### FR-7: Airspace Deconfliction

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-7.1 | Manned aircraft detection (ADS-B / radio call) shall trigger immediate deconfliction response | P0 | Integration test |
| FR-7.2 | Deconfliction shall use altitude band separation as primary method | P0 | Spatial test |
| FR-7.3 | Deconfliction mode shall be deterministic: same airspace input → same drone behavior | P0 | Property test |
| FR-7.4 | TFR compliance shall be continuously enforced (Law 7) | P0 | Invariant test |

---

### FR-8: Evidence Package

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-8.1 | Evidence package shall include: timeline replay, detection report, coverage report, fleet report, authority report, system health report | P0 | Schema test |
| FR-8.2 | SHA256 hash chain integrity shall be verifiable | P0 | Integrity test |
| FR-8.3 | Deterministic replay shall reproduce identical escalation tier assignments | P0 | Replay test |
| FR-8.4 | Package generation shall complete within 60 seconds for 12-hour missions | P1 | Performance test |

---

## Non-Functional Requirements

### NFR-1: Determinism

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-1.1 | Escalation tier determinism | 100% identical outputs | Property test: 10,000 iterations |
| NFR-1.2 | Severity band determinism | 100% identical bands | Boundary test |
| NFR-1.3 | Task allocation determinism | 100% identical assignments given same state | Property test |
| NFR-1.4 | Replay accuracy | 100% state hash match | End-to-end replay |

### NFR-2: Performance

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-2.1 | Escalation evaluation latency | <500ms from detection to tier assignment | Performance test |
| NFR-2.2 | Lease allocation latency | <1s for fleet re-tasking | Performance test |
| NFR-2.3 | Degraded mode transition | <2s from trigger to new autonomy envelope | State test |
| NFR-2.4 | Coverage freshness update | <1s per sector per scan | Integration test |
| NFR-2.5 | Evidence package generation | <60s for 12-hour mission | Performance test |

### NFR-3: Reliability

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-3.1 | Mission completion rate | >95% of started incidents | Field testing |
| NFR-3.2 | Detection commitment success | 100% (failures create audit entry) | Fault injection |
| NFR-3.3 | Escalation delivery rate | 100% (timeout ladder ensures no silent drops) | Simulation test |
| NFR-3.4 | GCS uptime during mission | >99% | Stress testing |

### NFR-4: Usability

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-4.1 | SOP template setup time | <15 minutes for trained operator | User testing |
| NFR-4.2 | Incident spin-up time | <10 minutes from SOP load to fleet launch | User testing |
| NFR-4.3 | Escalation review time | <30s per detection for operator (median) | User testing |
| NFR-4.4 | Situation summary clarity | IC understands emergency notification within 60s | User testing |

---

## Success Metrics

### MVP Success Metrics

| Metric | Target |
|--------|--------|
| End-to-end SITL scenario reliability | 100% across 10 consecutive runs |
| Escalation determinism verification | 100% replay match |
| Coverage freshness maintenance | ≥70% sectors fresh during 8-hour scenario |
| Degraded mode governance correctness | 100% authority contraction verified |
| Evidence package generation | 100% success with hash chain integrity |

### Operational Metrics (Field Validation)

| Metric | Target |
|--------|--------|
| Mission completion (overnight) | >95% |
| Critical detection escalation latency | Within SOP SLA |
| False escalation rate (Emergency tier) | <5% |
| Coverage gap duration (priority sectors) | <10 minutes cumulative per shift |
| IC satisfaction with evidence package | >80% (survey) |

### Technical Metrics

| Metric | Target |
|--------|--------|
| Determinism verification | 100% pass |
| Audit log integrity | 100% verified |
| Replay accuracy | 100% state match |
| Lease lifecycle correctness | 100% (grant → renew/revoke → expire) |
| Law 2 invariant (no authority escalation) | 100% verified |

---

## Platform Support

### Primary Platform

| Component | Specification |
|-----------|---------------|
| Aircraft | PX4/MAVLink-compatible with thermal payload |
| Likely field platform | Skydio X10 (post-DJI ban, government fleet standard) |
| GCS (field) | iPad Pro (M2+), iOS 17+ |
| GCS (command post) | Mac (IC integration, multi-monitor) |
| Inference | CoreML on GCS (thermal classification) |

### Development Platform

| Component | Specification |
|-----------|---------------|
| SITL simulation | PX4 SITL with synthetic thermal feeds |
| Governance testing | Pure logic — no hardware dependency |
| Degraded mode testing | Simulated comms failures at precise moments |
| Replay verification | Deterministic scenario injection |

### Future Enhancements

| Component | Phase | Notes |
|-----------|-------|-------|
| Ruggedized tablet | Phase 2 | Fire line deployment |
| ICS/dispatch integration | Phase 2+ | CAD system connectivity |
| Dock automation | Phase 2+ | Autonomous battery swap |
| Multi-agency sharing | Phase 3 | Coalition fire response |

---

## Development Roadmap

### Phase 1: Governance Core (SITL)

**Goal:** FireLaw state machine with escalation, leases, and coverage governance — fully testable in simulation

**Deliverables:**
- FireState domain model implementation
- FireReducer with escalation evaluation (pure function)
- Task lease lifecycle (grant, renew, revoke, expire, transfer)
- Sector freshness tracking with coverage policy
- Degraded mode state machine
- SOP template loader with threshold configuration
- Audit trail with SHA256 hash chain

**Success Criteria:**
- Escalation scenarios produce deterministic tier assignments
- Lease lifecycle invariants hold under property testing
- Degraded mode transitions correctly contract authority
- All state transitions logged and replayable

---

### Phase 2: Operator Interface

**Goal:** GCS interface for incident setup, monitoring, and escalation review

**Deliverables:**
- Perimeter draw/import with sector decomposition
- Fleet status and task lease visualization
- Escalation notification and review queue
- Coverage freshness heat map
- Detection card UI (thermal imagery, severity, escalation context)
- SOP template configuration interface

**Success Criteria:**
- Operator can set up incident and launch fleet in <10 minutes
- Escalation notifications visible and actionable
- Coverage state understandable at a glance
- Detection review workflow smooth (<30s per detection)

---

### Phase 3: Multi-Asset Coordination

**Goal:** Fleet-scale task allocation and swap scheduling with real MAVLink integration

**Deliverables:**
- Lease allocator with priority-based scheduling
- Battery swap prediction and pre-staging
- Handoff coordination (lease transfer without coverage gap)
- Airspace deconfliction (ADS-B awareness, altitude band management)
- MAVLink integration for fleet telemetry and tasking

**Success Criteria:**
- Fleet of 3+ drones maintains coverage through swap cycles
- No priority sector goes stale during planned swaps
- Airspace deconfliction triggers correctly on manned aircraft detection
- MAVLink command/telemetry reliable with real PX4 SITL fleet

---

### Phase 4: Evidence and Replay

**Goal:** After-action evidence package and deterministic replay verification

**Deliverables:**
- Evidence package generator (all six report types)
- Deterministic replay engine
- Hash chain verification tool
- Export formats (PDF summary + JSON structured data + imagery archive)

**Success Criteria:**
- Replay produces identical state hashes for 8-hour scenarios
- Evidence package passes independent hash chain verification
- Package generation within 60 seconds
- Reports readable and useful for IC review

---

### Phase 5: Field Validation

**Goal:** Real-world operational readiness with live hardware

**Deliverables:**
- Hardware integration testing (Skydio X10 or similar)
- Live thermal detection validation
- Field operator training materials
- Operational readiness demonstration for fire agency stakeholders

**Success Criteria:**
- Complete overnight monitoring scenario with live fleet
- Escalation and evidence systems perform as specified
- Fire agency stakeholders confident in operational capability
- Training materials enable new operator proficiency in <4 hours

---

## Constraints & Assumptions

### Technical Constraints

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| iPad compute limits | Fleet coordination complexity | Lean governance logic, offload visualization |
| MAVLink bandwidth | Telemetry frequency for large fleets | Priority-based telemetry allocation |
| Battery endurance (25–40 min) | Swap frequency during overnight ops | Predictive gap management, dock automation |
| Remote terrain connectivity | GCS ↔ drone link reliability | Degraded mode governance, mesh networking |

### Business Constraints

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| Single developer (initial phases) | Scope management | SITL-first, governance logic before hardware |
| No fire agency partnership yet | Domain validation gap | Faculty contact at CSU Drone Center; seek fire ops SME |
| Hardware rental for field testing | Limited live test windows | Maximize SITL coverage; rent for targeted validation |

### Assumptions

| Assumption | Risk if Invalid | Validation |
|------------|-----------------|------------|
| SOP templates capture sufficient operational variability | Operators cannot configure for their scenarios | SME review of template parameters |
| 3–8 drone fleet sufficient for meaningful perimeter coverage | Inadequate coverage drives false sense of security | Simulation with varied perimeter sizes |
| Escalation tier model appropriate for fire operations | Operators distrust or ignore escalations | Fire chief conversation, operational feedback |
| Skydio X10 or similar available for government fire contracts | Platform unavailable | Architecture is platform-agnostic (MAVLink) |

---

## Acceptance Criteria

Flightworks Fire MVP is **ready for field validation** when:

1. ✅ End-to-end SITL scenario completes (setup → overnight monitoring → debrief)
2. ✅ Escalation tier assignment is 100% deterministic across replay
3. ✅ Task lease lifecycle fully governed (Law 2 invariants hold)
4. ✅ Degraded mode transitions correctly contract authority
5. ✅ Coverage freshness tracking maintains ≥70% sectors fresh in 8-hour scenario
6. ✅ Detection commitment immutable (Law 6 invariants hold)
7. ✅ Evidence package generates with verified hash chain
8. ✅ Operator can set up incident and launch in <10 minutes
9. ✅ Escalation timeout ladder functions (no silent drops)
10. ✅ FlightLaw safety floor active in all degraded modes

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [HLD-FlightworksFire.md](./HLD-FlightworksFire.md) | FireLaw architecture specification |
| [HLD-FlightworksCore.md](./HLD-FlightworksCore.md) | FlightLaw foundation |
| [PRD-FlightworksCore.md](./PRD-FlightworksCore.md) | FlightLaw requirements |
| [Flightworks-Suite-Overview.md](./Flightworks-Suite-Overview.md) | Suite architecture |
| [HLD-FlightworksISR.md](./HLD-FlightworksISR.md) | ISRLaw jurisdiction (builds on FireLaw) |
| [PRD-FlightworksISR.md](./PRD-FlightworksISR.md) | ISRLaw requirements |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | Feb 2026 | S. Sweeney | Initial FireLaw PRD — architecture draft |

---

**Document Control**

- **Owner:** Stephen Sweeney, Flightworks Aerial LLC
- **Review Cycle:** As needed during architecture phase
- **Distribution:** Internal, open-source project documentation

---

## Conclusion

Flightworks Fire demonstrates that **governed AI scales to the hard problems**. By combining:

- **Deterministic escalation** (same inputs → same tier, always)
- **Task lease governance** (Law 2 delegation without authority escalation)
- **Degraded mode discipline** (less information → less authority, never more)
- **Persistence guarantees** (Law 6 immutable detection and escalation records)
- **Evidence-first design** (audit trail is the primary deliverable)

...we create a wildfire monitoring system that is simultaneously:
- **Capable enough** for overnight autonomous operations
- **Disciplined enough** to contract authority when conditions degrade
- **Auditable enough** for post-incident legal and operational review
- **Trustworthy enough** for fire agencies to let the operator sleep

FireLaw is the jurisdiction that proves the SwiftVector Codex scales. If deterministic governance can handle overnight wildfire monitoring with multiple assets, degraded comms, and sleeping operators — it can handle anything simpler.
