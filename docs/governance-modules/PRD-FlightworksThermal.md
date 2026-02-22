# Flightworks Thermal: Product Requirements Document (ThermalLaw)

**Document:** PRD-FT-THERMAL-2026-001  
**Version:** 2.0  
**Date:** February 2026  
**Author:** Stephen Sweeney, Flightworks Aerial LLC  
**Status:** Specified (Future Jurisdiction — development after FlightLaw foundation)  
**Classification:** Public

---

## Executive Summary

Flightworks Thermal is a governed AI inspection application for **post-hail roof assessment**. Built on the FlightLaw safety kernel, it demonstrates how probabilistic ML outputs can be processed deterministically to create a trustworthy, auditable inspection workflow.

### Core Value Proposition

> **"Fast, repeatable, and trustworthy roof damage documentation. AI proposes candidates, operators approve, system ensures nothing is missed or hallucinated."**

**Key Differentiators:**
- **RGB-Primary Detection:** Visible imagery as main signal (thermal secondary for moisture)
- **Governed Autonomy:** AI proposes, operator approves, every decision auditable
- **Documentation Pack:** Client-ready export (PDF + JSON + imagery)
- **Session Replay:** Deterministic verification of identical outputs
- **Edge-First:** All processing onboard aircraft, no cloud dependency

### Strategic Alignment

| Strategic Goal | Flightworks Thermal Approach |
|----------------|------------------------------|
| **Commercial Value** | Real commercial workflow (Flightworks Aerial services) |
| **Governed AI** | Deterministic post-processing of probabilistic ML outputs |
| **Edge-First** | Onboard inference, no cloud dependency |
| **Certifiability** | Session replay proves reproducibility |

---

## Product Vision

### The Problem: Post-Hail Roof Inspections

**Market Context:**
- Colorado hailstorms create surge demand for roof assessments
- Insurers require documented evidence of damage
- Operators face: inconsistent coverage, ambiguous patterns, callback risk

**Current Solutions Fall Short:**
- Manual inspection: slow, incomplete coverage
- AI-only approaches: trust vacuum, no audit trail
- Cloud-dependent: connectivity issues, latency

### The Solution: Governed Onboard Workflow

**7-Step Process:**
1. **Observe** - Standardized capture (grid + edges + penetrations + ridges)
2. **Infer** - Onboard ML proposes damage candidates
3. **Explain** - Show crop + context + confidence + severity
4. **Approve** - Operator explicitly confirms/rejects each candidate
5. **Flag** - Approved candidates become flagged anomalies
6. **Export** - Generate Documentation Pack (PDF + JSON + images)
7. **Replay** - Verify session determinism (QA/audit)

---

## Target Users

### Primary: Flightworks Aerial Operators

**Persona:** Licensed remote pilot conducting post-hail roof inspections

**Goals:**
- Complete thorough inspection in <20 minutes
- Capture all visible damage without false positives
- Generate client-ready documentation same-day
- Defend findings if challenged

**Constraints:**
- Battery limited (25-30 min flight time)
- Weather window (after hail, before next storm)
- Insurance documentation requirements
- Need to cover multiple jobs per day

### Secondary: Inspection Clients

**Persona:** Property owner, insurance adjuster

**Goals:**
- Understand extent of damage
- Get documentation for insurance claim
- Trust the assessment methodology

**Needs:**
- Clear, annotated imagery
- Severity classifications
- Professional report format

---

## Use Cases

### UC-1: Post-Hail Roof Assessment

**Goal:** Document visible roof damage from hail event

**Preconditions:**
- Aircraft armed and ready
- Inspection session configured (post-hail roof type)
- Roof zones defined (field, edge, ridge, valley, penetration)

**Flow:**
1. Operator launches Flightworks Thermal app
2. System starts inspection session (session ID generated)
3. Operator flies systematic pattern (grid coverage)
4. For each captured frame:
   - System runs onboard ML inference
   - If damage candidate detected:
     - System applies deterministic thresholds
     - Candidate added to review queue
     - Operator notified (visual + haptic)
5. Operator reviews queue during/after flight:
   - Views candidate card (image crop, severity, zone)
   - Approves with optional notes OR rejects with reason
6. Session ends, operator lands aircraft
7. System generates Documentation Pack
8. Operator delivers PDF report to client

**Success Criteria:**
- All roof zones covered (â‰¥85% coverage per zone)
- Candidates proposed within 500ms of detection
- Operator approval/rejection <5s per candidate
- Documentation Pack generated in <30s
- Client receives professional report same day

---

### UC-2: Session Replay for Quality Assurance

**Goal:** Verify inspection completeness and methodology

**Actors:** QA reviewer, insurance adjuster (dispute scenario)

**Flow:**
1. Reviewer loads session audit log
2. System replays session from start:
   - Shows flight path
   - Shows captured frames
   - Shows ML inference outputs
   - Shows operator approval decisions
3. Reviewer verifies:
   - Coverage completeness
   - Candidate proposal consistency
   - Operator decision rationale
4. System confirms: identical state hashes â†’ deterministic replay

**Success Criteria:**
- Replay produces identical candidate count
- Replay shows complete decision trail
- Audit log integrity verified (hash chain)

---

## Functional Requirements

### FR-1: Session Management

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-1.1 | Session shall start with unique session ID | P0 | Unit test |
| FR-1.2 | Session type shall be configurable (post-hail, thermal-moisture, etc.) | P0 | Config test |
| FR-1.3 | Session metadata shall include aircraft, operator, timestamps | P0 | Schema test |
| FR-1.4 | Session shall track roof zone coverage | P0 | Integration test |
| FR-1.5 | Session shall end only after operator confirmation | P0 | UI test |

---

### FR-2: Capture Management

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-2.1 | Frame capture shall record metadata (GPS, timestamp, gimbal angle) | P0 | Integration test |
| FR-2.2 | Roof zones shall be assigned based on position + heading | P0 | Geometry test |
| FR-2.3 | Coverage tracking shall update per zone | P0 | State test |
| FR-2.4 | Operator shall be notified of incomplete coverage | P1 | UI test |

---

### FR-3: ML Inference

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-3.1 | Inference shall run on-device (edge-first, no cloud dependency) | P0 | Deployment test |
| FR-3.2 | Inference latency shall be <100ms per frame | P0 | Performance test |
| FR-3.3 | Model version shall be logged in session metadata | P0 | Audit test |
| FR-3.4 | Inference failures shall be logged, not crash app | P0 | Fault injection test |

---

### FR-4: Deterministic Post-Processing

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-4.1 | Confidence threshold filtering shall be deterministic | P0 | Property test: 1000 iterations |
| FR-4.2 | Severity banding shall be deterministic | P0 | Unit test: boundary values |
| FR-4.3 | Roof zone assignment shall be deterministic | P0 | Unit test: geometry |
| FR-4.4 | Candidate count shall be bounded per zone (<50) | P0 | Unit test: workload limit |
| FR-4.5 | Classification thresholds shall be compile-time constants | P0 | Static analysis |

**Severity Banding Rules (Deterministic):**

| Confidence | Area (pixels) | Severity Band |
|------------|---------------|---------------|
| â‰¥0.85 | Any | Significant |
| 0.70-0.84 | â‰¥200 | Moderate |
| 0.70-0.84 | <200 | Minor |
| 0.50-0.69 | â‰¥500 | Moderate |
| 0.50-0.69 | <500 | Minor |
| <0.50 | Any | Rejected |

---

### FR-5: Candidate Management

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-5.1 | Candidates shall be queued for operator review | P0 | State test |
| FR-5.2 | Candidate cards shall show: crop, severity, zone, confidence | P0 | UI test |
| FR-5.3 | Operator approval shall create flagged anomaly | P0 | Integration test |
| FR-5.4 | Operator rejection shall remove from queue | P0 | Integration test |
| FR-5.5 | Operator notes shall be optional but preserved | P0 | State test |

---

### FR-6: Approval Workflow (Law 8 Integration)

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-6.1 | No candidate shall become flagged without approval | P0 | Invariant test |
| FR-6.2 | Approval action shall require operator authentication | P0 | Security test |
| FR-6.3 | Approval latency shall be <100ms | P0 | Performance test |
| FR-6.4 | Rejection shall include reason (typed enum) | P1 | State test |
| FR-6.5 | Bulk approval shall not be permitted | P0 | UI test |

---

### FR-7: Documentation Pack Export

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-7.1 | Export shall generate: PDF report + JSON data + images | P0 | Export test |
| FR-7.2 | PDF shall include: summary, flagged anomalies, coverage map | P0 | PDF validation |
| FR-7.3 | JSON shall follow schema (see HLD) | P0 | Schema test |
| FR-7.4 | Images shall be annotated with bounding boxes | P1 | Image processing test |
| FR-7.5 | Export shall complete in <30 seconds | P0 | Performance test |

**PDF Report Structure:**
1. Cover page (session metadata, operator, date)
2. Executive summary (anomaly count by severity)
3. Coverage map (roof zones with completion %)
4. Flagged anomalies (one per page: image, metadata, notes)
5. Methodology appendix (ML model version, thresholds)

---

### FR-8: Session Replay

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-8.1 | Replay shall produce identical candidate count | P0 | Replay test |
| FR-8.2 | Replay shall produce identical severity assignments | P0 | Replay test |
| FR-8.3 | Replay shall verify audit log integrity | P0 | Integrity test |
| FR-8.4 | Replay shall detect non-determinism | P0 | Failure test |
| FR-8.5 | Replay time shall be <session duration / 10 | P1 | Performance test |

---

## Non-Functional Requirements

### NFR-1: Determinism

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-1.1 | Classification determinism | 100% identical outputs | Property test: 10,000 iterations |
| NFR-1.2 | Severity banding determinism | 100% identical bands | Boundary test |
| NFR-1.3 | Replay accuracy | 100% state hash match | End-to-end replay |

### NFR-2: Performance

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-2.1 | Frame processing rate | â‰¥10 FPS | Load test |
| NFR-2.2 | ML inference latency | <100ms | Performance profiling |
| NFR-2.3 | Candidate proposal latency | <500ms end-to-end | Integration test |
| NFR-2.4 | Approval action response | <100ms | UI responsiveness test |
| NFR-2.5 | Export generation | <30s for 200-frame session | Performance test |

### NFR-3: Usability

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-3.1 | Operator training time | <2 hours to proficiency | User testing |
| NFR-3.2 | Candidate review time | <5s per candidate (median) | User testing |
| NFR-3.3 | Coverage awareness | Operator knows zone completion at glance | UI testing |

### NFR-4: Reliability

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-4.1 | Inspection completion rate | >95% of started sessions | Field testing |
| NFR-4.2 | ML inference failures | <1% of frames | Error monitoring |
| NFR-4.3 | Export success rate | 100% (failures recoverable) | Resilience testing |

---

## Success Metrics

### MVP Success Metrics

| Metric | Target |
|--------|--------|
| End-to-end demo reliability | 100% success in evaluation |
| Session replay verification | 100% determinism |
| Candidate proposal recall | >90% (vs manual review) |
| False positive rate | <15% |
| Operator approval rate | >70% of candidates |
| Export generation success | 100% |

### Business Metrics (Flightworks Aerial)

| Metric | 3-Month | 6-Month |
|--------|---------|---------|
| Inspections completed | 20 | 100 |
| Documentation Pack deliveries | 20 | 100 |
| Client satisfaction (survey) | >80% | >85% |
| Callback rate | <5% | <3% |

### Technical Metrics

| Metric | Target |
|--------|--------|
| Determinism verification | 100% pass |
| Audit log integrity | 100% verified |
| Replay accuracy | 100% state match |
| Inference latency | <100ms (p95) |
| Coverage completeness | >85% per zone |

---

## Platform Support

### Primary Platform

| Component | Specification |
|-----------|---------------|
| Aircraft | PX4/MAVLink-compatible (Skydio X10 for field testing) |
| Cameras | RGB + thermal capable payload (platform-dependent) |
| Operator Interface | iPad Pro (M2+), iOS 17+ |
| Inference | CoreML on iPad GCS (edge-first) |

### Optional Enhancements

| Component | Phase | Notes |
|-----------|-------|-------|
| Edge compute module | Phase B | Higher throughput, larger models |
| Cloud export | Phase C | Fleet reporting, archive |
| iPhone companion | Future | Field reference app |

---

## Development Roadmap

### Phase 1: Foundation (February 2026)

**Goal:** End-to-end workflow skeleton

**Deliverables:**
- Session management (start/end)
- Frame capture with metadata
- Candidate queue UI
- Approve/reject actions
- Export stub (JSON only)
- Tier 0 baseline (rule-based candidate finder)

**Success Criteria:**
- Can complete inspection session
- Candidates appear in queue
- Operator can approve/reject
- JSON export works

---

### Phase 2: ML Integration (March 2026)

**Goal:** Onboard ML inference

**Deliverables:**
- CoreML model integration
- Tier 1 ML proposals
- Deterministic post-processing
- Severity banding logic
- Roof zone assignment

**Success Criteria:**
- ML inference runs <100ms
- Candidates match deterministic rules
- Severity bands assigned correctly

---

### Phase 3: Export & Polish (April 2026)

**Goal:** Documentation Pack export

**Deliverables:**
- PDF report generation
- Image annotation
- Coverage map visualization
- UX polish (approval flow, notifications)

**Success Criteria:**
- PDF export in <30s
- Professional report quality
- Operator workflow smooth

---

### Phase 4: Replay & Verification (May 2026)

**Goal:** Session replay capability

**Deliverables:**
- Replay engine
- Integrity verifier
- Determinism tests
- Demo scenarios

**Success Criteria:**
- Replay produces identical outputs
- Audit log verifies
- Demo runs reliably

---

### Phase 5: Field Validation

**Goal:** Real-world operational readiness

**Deliverables:**
- Hardware integration testing (Skydio X10 or similar)
- Final UX polish
- Field demonstration scenarios
- Operational documentation package

**Success Criteria:**
- Demo reliability 100%
- Technical documentation complete
- Field operators confident in workflow

---

## Constraints & Assumptions

### Technical Constraints

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| iPad compute limits | Model complexity | Lightweight MobileNet-based CoreML models |
| Battery life (25-30 min) | Coverage per flight | Systematic flight planning |
| No cloud connectivity | All processing onboard | Edge-first architecture |
| CoreML constraints | Model format | ONNX → CoreML conversion pipeline |

### Business Constraints

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| Single developer (Phase 1-3) | Scope management | MVP focus, phased delivery |
| Hail season timing (spring) | Field testing window | Early prototyping with existing data |

### Assumptions

| Assumption | Risk if Invalid | Validation |
|------------|-----------------|------------|
| RGB sufficient for hail detection | Detection quality poor | Prototype with real hail imagery |
| CoreML adequate for iPad inference | Performance inadequate | Benchmark early |
| Operators accept approval workflow | UX friction | User testing |
| Documentation Pack meets client needs | Client dissatisfaction | Sample report review |

---

## Acceptance Criteria

Flightworks Thermal MVP is **ready for field validation** when:

1. âœ… End-to-end workflow complete (Observe â†’ Export)
2. âœ… Onboard ML inference running (<100ms)
3. âœ… Deterministic post-processing verified (100% consistency)
4. âœ… Approval workflow enforced (no auto-flagging)
5. âœ… Documentation Pack export works (<30s)
6. âœ… Session replay verified (100% determinism)
7. âœ… Demo scenario runs reliably (10 consecutive successes)
8. âœ… Coverage tracking functional (>85% per zone)
9. âœ… PDF report professional quality
10. âœ… Audit log integrity verified (hash chain)

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [Flightworks-Suite-Overview.md](./Flightworks-Suite-Overview.md) | Suite architecture |
| [HLD-FlightworksThermal.md](./HLD-FlightworksThermal.md) | ThermalLaw architecture |
| [HLD-FlightworksCore.md](./HLD-FlightworksCore.md) | FlightLaw foundation |
| [PRD-FlightworksCore.md](./PRD-FlightworksCore.md) | FlightLaw requirements |
| [HLD-FlightworksFire.md](./HLD-FlightworksFire.md) | FireLaw jurisdiction (sibling) |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 2.0 | Feb 2026 | S. Sweeney | Strategic update: DJI references removed, platform-agnostic, aligned with five-jurisdiction model |
| 1.0 | Feb 2026 | S. Sweeney | Initial ThermalLaw PRD (DJI Challenge era) |

---

**Document Control**

- **Owner:** Stephen Sweeney, Flightworks Aerial LLC
- **Review Cycle:** Weekly during MVP development
- **Distribution:** Internal, open-source project documentation

---

## Conclusion

Flightworks Thermal demonstrates that **governed AI is competitive AI**. By combining:

- **Fast onboard inference** (competitive performance)
- **Deterministic post-processing** (certifiable behavior)
- **Operator approval** (trust and authority)
- **Session replay** (verification and auditability)

...we create an inspection workflow that is simultaneously:
- **Fast enough** for commercial operations (<20 min per roof)
- **Repeatable enough** for insurance requirements (deterministic outputs)
- **Trustworthy enough** for operator adoption (AI proposes, human decides)

This is the future of drone AI: **not autonomous, but governed**.
