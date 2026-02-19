# TL Review Report: BL-UC7-FIRE-2026-001

**Backlog:** BL-UC7-FIRE-2026-001 — Overnight Wildfire Perimeter Monitoring & Hotspot Triage (FireLaw / UC-7)
**Reviewer:** Tech Lead, Flightworks Control
**Date:** 2026-02-18
**Status:** DRAFT — awaiting AIC approval
**Repo snapshot at review:** Phase 0 structure in place; `Core/` directories empty; SwiftVectorCore NOT yet integrated

---

## Repo Map (Actual vs. Assumed)

| Backlog Assumes | Actual State at Review |
|---|---|
| FlightLaw Phase 0 Reducer exists | ❌ MISSING — `Core/` was empty at review time |
| FlightLaw Orchestrator exists | ❌ MISSING |
| SwiftVectorCore package integrated | ❌ MISSING — no SPM dependency in xcodeproj |
| FlightLaw Laws 2, 3, 4, 7, 8 implemented | ❌ MISSING — no Swift files for any laws |
| Audit trail (hash chain) exists | ❌ MISSING |
| `State`/`Action` protocols available for conformance | ❌ MISSING |

> **Note:** SP0-1 (SwiftVectorCore SPM integration) and SP0-2 (State Layer) were completed after this review. The above reflects the state at the time of the TL review that produced this report.

---

## A1: Readiness Summary

**Can Sprint 1 Start? NO**

### Blockers

- **BLOCKER:** FlightLaw Phase 0 (CLAUDE.md Commits 2–5) is 0% complete at review time. FireLaw types (S-01) can be authored speculatively, but cannot be compiled or tested against the required `State`/`Action` protocols because SwiftVectorCore is not integrated.
- **BLOCKER:** SwiftVectorCore package is not added to the Xcode project. No protocol (`State`, `Action`, `Reducer`, `Clock`, `UUIDGenerator`, `AuditEvent`, `EventLog`) is available for conformance.
- **BLOCKER:** S-02 (FireReducer) explicitly requires FlightLaw Reducer to exist for composition — Sprint 1 as proposed (S-01 + S-02 + T-03.4) cannot finish without it.
- **BLOCKER (AIC):** AIC-Q1 (ground-stop latency target) must be resolved before S-06 acceptance criteria can be authored. Resolve now so S-06 isn't rewritten mid-sprint.
- **BLOCKER (AIC):** AIC-Q4 (hard vs. soft coverage guarantee) must be resolved before S-04 acceptance criteria are authoritative.

### What CAN Start Now

- T-01.3 (Law evaluation ordering ADR) — design/architecture work, no code required
- T-03.4 (escalation spike ADR) — design/architecture work, no code required
- S-10 kickoff (design spike) — wireframes, no code required
- Sprint 0 foundational work (see A3)

---

## A2: Dependency Graph

```
SwiftVectorCore (SPM) ← MUST EXIST FIRST
         │
         ▼
[Sprint 0 — FlightLaw Phase 0]
FlightState / FlightAction / SupportingTypes
         │
         ▼
FlightReducer (Laws 3,4,7,8 pure functions)
         │
         ▼
FlightOrchestrator + AuditTrail (hash chain)
         │
  ┌──────┴──────────────────┐
  │                         │
  ▼                         ▼
S-01                     S-09 (SOP template types)
(FireState, FireAction,
 all nested types)
  │
  ▼
S-02 ← requires FlightReducer for composition
(FireReducer + determinism proof)
  │
  ├──────────────────┐
  ▼                  ▼
S-03 (escalation)  S-04 (sector freshness)
  │                  │
  └──────┬───────────┘
         ▼
       S-05 (lease lifecycle)
         │
    ┌────┴────┐
    ▼         ▼
  S-06      S-07
(ground-   (degraded
  stop)      comms)
    │         │
    └────┬────┘
         ▼
       S-08 (evidence package)
```

**Key parallel track:** S-10 (design spike) can run alongside S-01 and S-02.

---

## A3: Missing Prerequisite Work (Sprint 0 Tasks)

The following tasks must complete before Sprint 1 begins. None are in the FireLaw backlog — they belong to FlightLaw Phase 0.

### SP0-1 — Add SwiftVectorCore as SPM dependency to Xcode project
- **Deliverable:** `project.pbxproj` updated; build succeeds with `import SwiftVectorCore`
- **Exit criteria:** `xcodebuild build` produces zero errors with SwiftVectorCore imported
- **Effort:** S | **Owner:** TL/DEV
- **Status:** ✅ COMPLETE

### SP0-2 — FlightState, SupportingTypes, MissionState, ThermalState (CLAUDE.md Commit 2)
- **Deliverable:** `FlightState.swift`, `SupportingTypes.swift`, `MissionState.swift`, `ThermalState.swift` in `Core/State/`
- **Exit criteria:** All types conform to `State`, `Equatable`, `Codable`, `Sendable`; Codable round-trip tests pass; zero strict-concurrency warnings
- **Effort:** M | **Owner:** DEV
- **Status:** ✅ COMPLETE (52/52 tests passing)

### SP0-3 — FlightAction enum (CLAUDE.md Commit 3)
- **Deliverable:** `FlightAction.swift` in `Core/Actions/`
- **Exit criteria:** All Phase 0 action cases represented; conforms to `Action`, `Equatable`, `Codable`, `Sendable`
- **Effort:** S | **Owner:** DEV

### SP0-4 — FlightReducer with Laws 3, 4, 7, 8 (CLAUDE.md Commit 4)
- **Deliverable:** `FlightReducer.swift` in `Core/Reducers/`; pure function; safety interlock tests at 100% coverage
- **Exit criteria:** Determinism tests pass (same inputs → same outputs); `canArm`/`canTakeoff` guards implemented; zero strict-concurrency warnings
- **Effort:** L | **Owner:** DEV + TL review

### SP0-5 — FlightOrchestrator with audit trail (CLAUDE.md Commit 5)
- **Deliverable:** `FlightOrchestrator.swift`; `dispatch()`, `replay()` methods; SHA-256 hash chain on each action
- **Exit criteria:** Full dispatch cycle integration test passes; `replay()` produces identical final state hash; Clock injected (no direct `Date()`)
- **Effort:** M | **Owner:** DEV

### SP0-6 — CI green: xcodebuild build + test (CLAUDE.md Overall Phase 0 Acceptance)
- **Deliverable:** CI pipeline green; safety interlock tests at 100%; 80%+ overall coverage
- **Exit criteria:** `xcodebuild test` succeeds with coverage report; no `Date()`/`UUID()` raw calls in Reducer
- **Effort:** S | **Owner:** TL

### SP0-7 — Architecture Decision Record: FireLaw composition model
- **Deliverable:** ADR documenting how FireReducer wraps/composes FlightReducer
- **Exit criteria:** Design reviewed by TL; approved by AIC; documented before S-02 implementation begins
- **Effort:** S | **Owner:** TL
- **Note:** This is T-01.3 from the backlog but must be done in Sprint 0 — before type authoring (S-01) — because the composition model affects FireState shape (e.g., does FireState embed FlightState? Or is it a separate struct passed alongside?)

> SP0-1 through SP0-6 map directly to CLAUDE.md Phase 0 Definition of Done commits 1–6. They are not optional prerequisites — they are the contractual precondition for ALL FireLaw work.

---

## A4: Architecture Alignment Notes

### Aligned with Current Architecture

| Item | Status |
|---|---|
| FireReducer as pure function | ✅ Matches SwiftVector Codex and `swiftvector-invariants.md` |
| Law 6 detection immutability | ✅ Consistent with reducer-only state mutation |
| LeaseAllocator as pure function (priority queue, not optimization solver) | ✅ Correct; optimization solvers are non-deterministic |
| Clock injection for escalation timeouts | ✅ Required by `swiftvector-invariants.md`; backlog correctly calls for injected clock in T-03.2 |
| AuditTrail hash chain inheritance | ✅ FireLaw extends FlightLaw audit trail; architecturally sound |
| No direct `Date()` / `UUID()` in reducers | ✅ Backlog explicitly prohibits this; property tests will catch violations |

### Conflicts or Gaps

- **CONFLICT — Composition model unspecified:** S-02 says "FlightLaw law evaluation composed before FireLaw-specific evaluation." Two architecturally different patterns exist: (a) FireReducer calls FlightReducer as a pure function then applies FireLaw — **correct, single source of truth**; (b) FireReducer re-implements FlightLaw law checks inline — **incorrect, duplicates logic**. ADR required (SP0-7).

- **GAP — SwiftVectorCore stability:** `https://github.com/stephen-sweeney/SwiftVector` is an evolving, pre-1.0 package. If its API changes, SP0-1 through SP0-6 may require updates. Single highest-risk external dependency.

- **CONFLICT — S-07 Edge Relay dependency:** S-07 says "onboard detection logging during partition (local storage, sync on reconnect)." This requires an Edge Relay (Phase 1) and an onboard drone SDK. The backlog lists Edge Relay as a dependency for S-07 but doesn't split the story accordingly. **Recommendation:** Split S-07 into S-07a (GCS-side DegradedMode state machine, SITL-testable) and S-07b (reconnection sync, gated on Edge Relay Phase 1).

- **GAP — Static non-determinism scan missing from S-02 AC:** `swiftvector-invariants.md` requires scanning for `Date()`, `UUID()`, and `.random` in all Reducer files. The 10,000-iteration property test is necessary but not sufficient. Add static scan requirement to S-02 acceptance criteria.

---

## A5: Risk Register

### P0 Risks (Sprint-blocking)

| ID | Risk | Mitigation |
|---|---|---|
| R-P0-1 | SwiftVectorCore public repo is unstable or its API doesn't match documentation | SP0-1 must be done first; if API mismatch found, file issues upstream and patch locally; TL must review SwiftVectorCore source before S-01 authoring begins |
| R-P0-2 | FlightLaw Phase 0 not done before FireLaw sprint starts — no Reducer to compose with | AIC-Q5 confirms gating; enforce Sprint 0 completion before Sprint 1 planning; no exceptions |
| R-P0-3 | FireState struct size triggers unexpected Swift struct copy performance issues | Benchmark early in T-02.6; if median >5ms, evaluate copy-on-write wrapper for `FleetState` / `CoverageMap` collections |

### P1 Risks (Sprint-impacting)

| ID | Risk | Mitigation |
|---|---|---|
| R-P1-1 | Escalation tier thresholds are wrong and fire SME rejects the model after Sprint 1 investment | Schedule AIC-Q2 tabletop before Sprint 2 planning (not after); make thresholds SOP-configurable so model can be recalibrated without code change |
| R-P1-2 | OQ-4 (simultaneous multi-sector CRITICAL) is more complex than a single ADR resolves | T-03.4 spike must produce a runnable SITL test case, not just a written decision; simultaneous case must be demonstrated deterministic before S-03 DoD is claimed |
| R-P1-3 | Ground-stop latency target (AIC-Q1, ≤30s) is unachievable with MAVLink over simulated comms | Benchmark in SITL with 4-drone fleet in Sprint 2; if >30s, escalate to AIC with data; do NOT write S-06 AC with a target that hasn't been validated in simulation |
| R-P1-4 | S-07 cannot be completed without Edge Relay (Phase 1) | Split S-07 into S-07a (GCS-side DegradedMode state machine) and S-07b (reconnection sync gated on Edge Relay) |

### P2 Risks (Manageable)

| ID | Risk | Mitigation |
|---|---|---|
| R-P2-1 | GeoOps export format (OQ-3) causes rework on S-08 | Implement GeoJSON baseline; design S-08 with pluggable exporter interface; add formats after GISS interview |
| R-P2-2 | 8-hour audit trail size exceeds 100MB (E-06 concern) | Benchmark in Sprint 3 SITL run; evaluate binary encoding (CBOR) or delta compression for audit events |
| R-P2-3 | Alert fatigue from over-sensitive escalation triggers | AIC-Q2 tabletop + wind decay multiplier configurability; all thresholds in SOP template, not hardcoded |
| R-P2-4 | Evidence package legal scrutiny requires standalone verifier | Design hash chain verification as a standalone CLI utility (not embedded in iOS app only); document verification procedure in README |

---

## A6: Ticket-by-Ticket Feedback

### S-01: FireState & FireAction Type Definitions

**Verdict: KEEP — but ADD preconditions**

- Acceptance criteria are clear and testable ✅
- AC for `FireAction.commitDetection` correctly specifies Law 6 fields ✅
- **CHANGE:** Add explicit requirement that all `Date` fields use a `Clock`-provided value — not `Date()`. The Codable round-trip test will pass either way; the determinism requirement will not.
- **CHANGE:** T-01.3 (Law evaluation ordering ADR) must be done BEFORE T-01.1 begins, not alongside it. The composition model affects FireState shape (does FireState embed FlightState? Or is it a separate struct?). This is an ordering error in the task breakdown.
- **ADD AC:** "SwiftVectorCore builds and its protocols are importable before any FireState implementation begins."

---

### S-02: FireReducer Implementation & Determinism Verification

**Verdict: KEEP — but SPLIT into S-02a and S-02b**

- Property test (10,000 iterations) is well-specified ✅
- Law 6 immutability AC is correct and testable ✅
- **SPLIT recommended:** S-02a = FireReducer skeleton with FlightLaw composition + Law 6 (M effort); S-02b = 10,000-iteration property test + performance benchmark (S effort)
- **CHANGE AC:** Add static scan requirement — "No direct `Date()`, `UUID()`, or `.random` calls in `FireReducer.swift` or any file it imports (verified by grep scan per `swiftvector-invariants.md`)"
- **AMBIGUOUS AC:** "FlightLaw laws (3, 4, 7, 8) are composed into FireReducer evaluation chain" — not testable without specifying which laws apply to which FireActions. ADR from T-01.3 must enumerate this mapping before S-02 starts.
- **CHANGE:** T-02.4 (FireActionGenerator) must explicitly state it uses an injected `RandomSource` — not `Swift.random()` — to maintain determinism of the test harness itself.

---

### S-03: Deterministic Escalation Function with Timeout Ladder

**Verdict: KEEP for Sprint 2 — BLOCKED for Sprint 1**

- Escalation function signature is well-defined ✅
- Conservative mode AC is clear and testable ✅
- **BLOCKED:** Depends on S-01 and S-02; cannot enter Sprint 1
- **BLOCKED:** OQ-4 (simultaneous multi-sector CRITICAL) blocks S-03 edge cases; T-03.4 spike produces the ADR in Sprint 1, but S-03 implementation waits for Sprint 2
- **CHANGE (AIC-Q3 interaction):** IC notification log entry must be typed/structured, not free text — e.g., `{ type: "ICNotificationLogged", tier: .emergency, reason: String, operatorID: String, timestamp: Clock.now() }`
- **AMBIGUOUS AC:** "operator presence SLA expires (e.g., 5 minutes for .monitoring)" — the "e.g." is non-authoritative. The AC must say "when the SLA from the loaded SOPTemplate expires."

---

### S-04: Sector Freshness Decay & Predictive Gap Detection

**Verdict: KEEP — but gate on AIC-Q4**

- Freshness state transition ACs (fresh → aging at 121s) are specific and testable ✅
- Wind multiplier AC is correct ✅
- **BLOCKED:** AIC-Q4 must be resolved before the "minimum fresh coverage guarantee" AC is authoritative. Conditionality makes it untestable.
- **ADD AC:** "Freshness state transitions are monotonically non-increasing without a scan event (property test: given time advancing, freshness.rawValue never increases between scan events)."
- **CHANGE:** Predictive gap detection must be specified as a pure function — given a fixed snapshot of fleet positions, battery projections, and lease expirations, it produces the same prediction deterministically.

---

### S-05: Task Lease Lifecycle & Battery Swap Handoff

**Verdict: KEEP**

- All lease lifecycle AC transitions are specific and testable ✅
- Law 2 authority constraint AC is correct ✅
- LeaseAllocator determinism AC is explicit ✅
- **CHANGE:** AC for max renewals says "max renewals = 5" — this must come from SOPTemplate (S-09 dependency), not be hardcoded.
- **ADD AC:** "LeaseAllocator result is stable under repeated calls with identical inputs (no non-deterministic sort instability in the priority queue)." Swift's sort is not guaranteed stable across all collection types; verify explicitly.

---

### S-06: Ground-Stop Response State Machine

**Verdict: KEEP — BLOCKED on AIC-Q1**

- AirspaceMode state machine transitions are clearly specified ✅
- Post-ground-stop action rejection AC is correct ✅
- **BLOCKED:** The latency AC ("≤ AIC-Q1 target e.g. 30s") is not authoritative until AIC-Q1 is resolved. Remove "e.g." once AIC resolves this — it is a life-safety AC.
- **NOTE:** "Ground-stop button must be a single-tap, maximum-contrast, zero-confirmation action" — this is a UI constraint belonging in S-10, not S-06. Move to S-10 or create a linked UI story.
- **ADD AC:** "FireReducer rejects any ground-stop-clear command issued by anyone other than the authorized operator role (Law 8 check)." Ground-stop clearance is as safety-critical as ground-stop itself.

---

### S-07: Degraded Communications Cascade & FlightLaw Fallback

**Verdict: SPLIT into S-07a and S-07b**

- **S-07a:** GCS-side DegradedMode state machine (no hardware, SITL-testable) — KEEP for Sprint 3
- **S-07b:** Reconnection sync (requires Edge Relay) — DEFER to Phase 1 epic
- **BLOCKER:** "Onboard detection logs are synchronized to GCS state" requires Edge Relay (Phase 1) and an onboard drone SDK. Cannot be verified in SITL without it.
- **CHANGE:** All ACs about DegradedMode transitions → S-07a; reconnection sync ACs → S-07b
- **ADD to S-07a:** "DegradedMode state is deterministic given the same comms health inputs — property test confirms identical outputs from identical inputs."

---

### S-08: Evidence Package Generation & Replay Verification

**Verdict: KEEP — P2 sequencing correct**

- Hash chain replay verification AC is clear and authoritative ✅
- Generation time target (<60s) is specific ✅
- **CHANGE:** "At least one export format (GeoJSON baseline)" — define the GeoJSON schema or link to a spec. "GeoJSON" without a schema is ambiguous.
- **ADD AC:** "The evidence package contains a machine-readable format version field so future format upgrades are identifiable."
- **AMBIGUOUS AC:** "Any hash mismatch is flagged as a tamper indication" — the verification function must return a typed result (`VerificationResult.valid` / `.tampered(reason:)`), not just log a message.

---

### S-09: SOP Template Configuration & Threshold Loading

**Verdict: KEEP — move to Sprint 1**

- Cross-cutting enabler: S-03, S-04, S-05 all reference SOP-configurable values. Without S-09, these stories use hardcoded values in their ACs.
- Effort is S (small) — should be in Sprint 1 alongside S-01.
- Law 8 authorization requirement (UAS PM or IC must confirm template load) is well-specified ✅
- **ADD AC:** "SOPTemplate conforms to Codable; a valid template round-trips through JSON encoding with no loss of precision for threshold values."
- **CHANGE:** "Template immutability after mission authorization" — define which FireAction or state transition locks the template. Without this definition the AC is ambiguous.

---

### S-10: Design Spike — FireLaw Operator Experience

**Verdict: KEEP — start in Sprint 1, complete in Sprint 2**

- Design spike scope is well-bounded ✅
- Ground-stop single-tap constraint is operationally correct ✅
- **ADD:** Require the design spike to include a wireframe for the DegradedMode status indicator (S-07 dependency; operators must see comms health clearly)
- **AMBIGUOUS AC:** "Each wireframe maps to at least one governance story" — define this as a traceability table in the deliverable, not a reviewer assertion.

---

## A7: Recommended Sprint 1 Plan

**Sprint 1 Prerequisite:** Sprint 0 (SP0-1 through SP0-6) must be COMPLETE before Sprint 1 begins.

**Sprint 1 Goal:** Lay the typed foundation for FireLaw and prove the escalation architecture is sound — without full Reducer implementation.

| Priority | Story / Task | Type | Rationale |
|---|---|---|---|
| 1 | SP0-7 — FireLaw composition ADR (T-01.3) | Spike | Must resolve before type authoring begins; output unlocks S-01 and S-02 |
| 2 | S-09 — SOP Template Types & Loading | Dev | Small; unblocks S-03, S-04, S-05 from using hardcoded thresholds |
| 3 | S-01 — FireState & FireAction Type Definitions | Dev | Foundation; must exist before any other FireLaw story compiles |
| 4 | T-03.4 — Simultaneous Multi-Sector CRITICAL Spike | Spike | Resolves OQ-4; unblocks S-03 edge case AC |
| 5 | S-10 — Design Spike Kickoff | Design | Parallelizable; fire SME review prep for Sprint 2 |
| DEFER | S-02 — FireReducer | Dev | Cannot complete without FlightLaw Reducer (Sprint 0) AND T-01.3 ADR; schedule Sprint 2 |
| DEFER | S-03 — Escalation Function | Dev | Depends on S-01 and S-02; Sprint 2 |
| DEFER | S-04 — Sector Freshness | Dev | Depends on S-01, S-02; Sprint 2 |

### Sprint 1 Exit Criteria

- [ ] FireLaw composition ADR approved by AIC
- [ ] SOPTemplate type compiles and tests pass
- [ ] FireState + FireAction compile with zero strict-concurrency warnings
- [ ] T-03.4 ADR: simultaneous multi-sector CRITICAL handling documented and reviewed
- [ ] S-10: wireframes for fleet overview, escalation notification, and ground-stop interaction ready for SME review
- [ ] All AIC decisions (AIC-Q1 through AIC-Q5) resolved in writing

---

## AIC Decisions Required

| AIC-Q | Question | Proposed Default | Must Resolve By |
|---|---|---|---|
| AIC-Q1 | Ground-stop latency target | **≤30 seconds** — life-safety; benchmark in Sprint 2 SITL to confirm feasibility | Before Sprint 1 ends |
| AIC-Q2 | Fire SME tabletop exercise | **Yes — schedule before Sprint 2 planning** — escalation tier model risk is too high without field validation | Before Sprint 2 |
| AIC-Q3 | IC notification channel | **Out-of-band only (GCS logs structured typed event)** — not free text | Before Sprint 1 ends |
| AIC-Q4 | 70% minimum coverage — hard or soft trigger? | **Hard EMERGENCY trigger** — conservative; can be relaxed with operational data | Before Sprint 1 ends |
| AIC-Q5 | FireLaw development gate | **Gated on FlightLaw Phase 0 + Phase 1 completion** — types can be authored now; Reducer cannot be completed until FlightLaw Reducer exists | Resolved immediately |
| OQ-2 | Timeout configurability | **Configurable per SOP template** — no hardcoded values in governance logic | Before S-03 starts |
| OQ-4 | Simultaneous multi-sector CRITICAL | **T-03.4 spike must produce an executable SITL test, not just a written ADR** | T-03.4 exit criteria |

---

## Summary of ADD TASKs

| Task | Description |
|---|---|
| SP0-1 | Add SwiftVectorCore SPM dependency ✅ |
| SP0-2 | FlightState / SupportingTypes / MissionState / ThermalState ✅ |
| SP0-3 | FlightAction enum (Phase 0) |
| SP0-4 | FlightReducer (Phase 0, Laws 3/4/7/8) |
| SP0-5 | FlightOrchestrator + audit trail |
| SP0-6 | xcodebuild build + test CI green |
| SP0-7 | FireLaw composition ADR (moved earlier than T-01.3 in backlog) |
| S-07a/S-07b split | Separate GCS-side DegradedMode state machine from Edge Relay-dependent reconnection sync |
| Static scan script | grep for `Date()`/`UUID()`/`.random` in all Reducer files (per `swiftvector-invariants.md`) |

---

*This report is a proposal from the TL agent. No story enters a sprint without AIC approval.*
