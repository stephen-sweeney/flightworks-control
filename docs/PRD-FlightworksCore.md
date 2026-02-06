# Flightworks Core: Product Requirements Document (FlightLaw Baseline)

**Document:** PRD-FC-CORE-2026-001  
**Version:** 1.0  
**Date:** February 2026  
**Author:** Stephen Sweeney, Flightworks Aerial LLC  
**Status:** Active Development  
**Classification:** Public

---

## Executive Summary

Flightworks Core provides the **FlightLaw safety kernel**—the universal foundation upon which all mission-specific drone applications in the Flightworks Suite are built. This is not a standalone product; it is the **constitutional infrastructure** that ensures deterministic, auditable, and safe drone operations across thermal inspection (ThermalLaw), precision mapping (SurveyLaw), and future jurisdictions.

### Core Value Proposition

> "The only drone control foundation where you can mathematically prove what happened, why it happened, and that it will happen the same way again."

**Key Differentiators:**
- **Constitutional Guarantees:** FlightLaw enforcement is architectural, not aspirational
- **Deterministic Replay:** Every session can be reconstructed exactly
- **Tamper-Evident Audit:** SHA256 hash chain proves data integrity
- **Composable Safety:** Jurisdictions inherit FlightLaw guarantees automatically

---

## Product Vision

### The Problem

Current drone software architectures create certification barriers:

1. **Stochastic Behavior:** Same inputs → different outputs = uncertifiable
2. **Opaque Decision-Making:** No audit trail when things go wrong
3. **Safety as Afterthought:** Safety checks bolted on, not built in
4. **Jurisdiction Silos:** Thermal inspection and mapping share no code

### The Solution

FlightLaw implements the SwiftVector Codex as a **reusable safety kernel**.

---

## Use Cases

### UC-1: Universal Pre-Flight Validation

**Actor:** Any Flightworks Suite application  
**Goal:** Ensure aircraft readiness before arming

**Success Criteria:**
- 100% prevention of arming with failed checks
- Clear explanation of rejection reason
- Audit trail captures rejection

### UC-2: Battery Reserve Enforcement

**Actor:** Any Flightworks Suite application  
**Goal:** Prevent battery depletion mid-flight

**Success Criteria:**
- 100% RTL trigger at threshold
- Operator override available (Law 8)
- Audit trail captures automatic action

### UC-3: Geofence Violation Prevention

**Actor:** Any Flightworks Suite application  
**Goal:** Keep aircraft within legal boundaries

**Success Criteria:**
- 100% prevention of geofence violations
- No flight beyond boundary under any circumstances
- Audit trail captures all boundary interactions

### UC-4: High-Risk Action Approval

**Actor:** ThermalLaw application  
**Goal:** Require operator approval for disarm during flight

**Success Criteria:**
- No high-risk actions execute without approval
- Clear presentation of risk to operator
- Operator retains final authority
- Audit trail captures decision chain

### UC-5: Session Replay for Incident Analysis

**Actor:** Safety investigator  
**Goal:** Reconstruct exactly what happened during flight incident

**Success Criteria:**
- 100% replay accuracy (identical state hashes)
- Complete audit trail (no missing actions)
- Tamper-evident hash chain verified
- Incident cause determinable from replay

---

## Functional Requirements

### FR-1: SwiftVector Core Architecture

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-1.1 | All state shall be immutable structs conforming to State protocol | P0 | Compiler verification |
| FR-1.2 | All state mutations shall occur through pure-function Reducers | P0 | Architecture review |
| FR-1.3 | Reducers shall be deterministic | P0 | Property-based test: 10,000 iterations |
| FR-1.4 | Actions shall be typed enums | P0 | Compiler verification |
| FR-1.5 | State shall conform to Equatable, Codable, Sendable | P0 | Compiler verification |

### FR-2: Law 3 (Observation)

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-2.1 | GPS satellite count must be ≥8 to arm | P0 | Unit test |
| FR-2.2 | IMU must be calibrated to arm | P0 | Unit test |
| FR-2.3 | Compass must be calibrated to arm | P0 | Unit test |
| FR-2.4 | Telemetry must be logged at ≥10Hz during armed state | P0 | Integration test |
| FR-2.5 | Telemetry staleness (>1s gap) shall trigger warning | P1 | Unit test |

### FR-3: Law 4 (Resource)

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-3.1 | Battery below 10% shall prevent arming | P0 | Unit test |
| FR-3.2 | Battery at 20% during flight shall trigger RTL | P0 | Integration test |
| FR-3.3 | RTL threshold shall be configurable (≥15%, ≤30%) | P1 | Configuration test |
| FR-3.4 | Manifold 3 temperature >50°C shall trigger warning | P1 | Unit test |
| FR-3.5 | Manifold 3 temperature >60°C shall trigger degradation | P1 | Integration test |

### FR-4: Law 7 (Spatial)

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-4.1 | Position outside geofence shall prevent arming | P0 | Unit test |
| FR-4.2 | Position outside geofence during flight shall trigger RTL | P0 | Integration test |
| FR-4.3 | Altitude above ceiling shall prevent ascent | P0 | Unit test |
| FR-4.4 | Geofence shall support circle and polygon types | P0 | Geometry test |
| FR-4.5 | No-fly zones shall trigger avoidance or RTL | P1 | Integration test |

### FR-5: Law 8 (Authority)

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-5.1 | Low-risk actions shall be auto-approved | P0 | Unit test |
| FR-5.2 | Medium-risk actions shall require approval with timeout | P0 | Unit test |
| FR-5.3 | High-risk actions shall require explicit approval | P0 | Unit test |
| FR-5.4 | Operator shall be able to override AI proposals | P0 | Integration test |
| FR-5.5 | Risk classification shall be deterministic | P0 | Unit test |

### FR-6: Audit Trail

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-6.1 | Every action shall be logged with state hashes | P0 | Audit test |
| FR-6.2 | Audit log shall use SHA256 hash chain | P0 | Integrity test |
| FR-6.3 | Audit log shall be append-only | P0 | Security test |
| FR-6.4 | Replay shall produce identical final state | P0 | Replay test |
| FR-6.5 | Replay shall detect non-deterministic behavior | P0 | Failure test |

### FR-7: Platform Integration

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-7.1 | Telemetry stream from DJI aircraft at ≥10Hz | P0 | Integration test |
| FR-7.2 | Flight commands via PSDK | P0 | Integration test |
| FR-7.3 | Battery state updates at ≥1Hz | P0 | Integration test |
| FR-7.4 | GPS position updates at ≥10Hz | P0 | Integration test |
| FR-7.5 | Platform adapter shall isolate PSDK from core | P0 | Architecture review |

### FR-8: Orchestrator

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-8.1 | State shall be protected by Swift Actor | P0 | Compiler verification |
| FR-8.2 | Action dispatch shall be async/await | P0 | Compiler verification |
| FR-8.3 | Concurrent actions shall maintain consistency | P0 | Concurrency test |
| FR-8.4 | State queries shall be isolated from mutations | P0 | Architecture review |
| FR-8.5 | Orchestrator shall enforce Law evaluation before Reducer | P0 | Integration test |

### FR-9: Extension Points for Jurisdictions

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-9.1 | Jurisdictions shall extend AppState | P0 | Architecture review |
| FR-9.2 | Jurisdictions shall add domain-specific actions | P0 | Architecture review |
| FR-9.3 | Jurisdictions shall compose FlightLaw + domain Laws | P0 | Integration test |
| FR-9.4 | FlightLaw violations shall take precedence | P0 | Unit test |
| FR-9.5 | Audit logs shall include FlightLaw evaluations | P0 | Audit test |

---

## Non-Functional Requirements

### NFR-1: Determinism

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-1.1 | Reducer determinism | 100% | Property-based test: 10,000 iterations |
| NFR-1.2 | Replay accuracy | 100% state hash match | End-to-end replay test |
| NFR-1.3 | Hash chain integrity | 0 breaks | Tamper detection test |
| NFR-1.4 | Time source isolation | 0 direct Date() calls | Static analysis |
| NFR-1.5 | UUID source isolation | 0 direct UUID() calls | Static analysis |

### NFR-2: Performance

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-2.1 | Telemetry processing | ≥10Hz sustained | Load test |
| NFR-2.2 | State transition latency | <10ms median, <50ms p99 | Performance profiling |
| NFR-2.3 | Law evaluation latency | <5ms per Law | Unit test timing |
| NFR-2.4 | Audit log append | <5ms | Performance test |
| NFR-2.5 | Memory usage (core) | <100MB | Memory profiler |

### NFR-3: Reliability

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-3.1 | MTBF | >100 flight hours | Field testing |
| NFR-3.2 | Graceful degradation | No crashes | Fault injection |
| NFR-3.3 | Battery enforcement | 100% RTL trigger | Integration test |
| NFR-3.4 | Geofence enforcement | 100% prevention | Boundary test |
| NFR-3.5 | Actor isolation | 0 race conditions | Concurrency fuzzing |

### NFR-4: Security

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-4.1 | Audit tamper evidence | 100% detection | Integrity test |
| NFR-4.2 | State isolation | No external mutation | Architecture review |
| NFR-4.3 | Action validation | 100% type safety | Compiler verification |
| NFR-4.4 | Replay verification | Non-determinism detection | Replay test |

### NFR-5: Testability

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-5.1 | Unit test coverage | >90% | Coverage report |
| NFR-5.2 | Property-based tests | All Reducers | Test suite review |
| NFR-5.3 | Integration tests | All Law compositions | Test suite review |
| NFR-5.4 | Replay tests | All audit logs | Test suite review |
| NFR-5.5 | Mock/stub availability | All external deps | Test infrastructure |

---

## Success Metrics

### Technical Metrics

| Metric | Target |
|--------|--------|
| Determinism verification | 100% pass rate |
| Audit replay accuracy | 100% state hash match |
| FlightLaw enforcement | 100% violation prevention |
| Law evaluation latency | <5ms median |
| Memory footprint | <100MB |

### Adoption Metrics (Internal)

| Metric | 6-Month | 12-Month |
|--------|---------|----------|
| Jurisdictions using FlightLaw | 2 | 3+ |
| Shared code percentage | >80% | >85% |
| Safety incident rate | 0 | 0 |

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [Flightworks-Suite-Overview.md](./Flightworks-Suite-Overview.md) | Suite architecture |
| [HLD-FlightworksCore.md](./HLD-FlightworksCore.md) | FlightLaw architecture |
| [SwiftVector-Codex.md](./SwiftVector-Codex.md) | Constitutional framework |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Feb 2026 | S. Sweeney | Initial FlightLaw PRD |

---

**Document Control**

- **Owner:** Stephen Sweeney, Flightworks Aerial LLC
- **Review Cycle:** Monthly
- **Distribution:** Internal, open source, research partners
