# Flightworks Survey: Product Requirements Document (SurveyLaw)

**Document:** PRD-FS-SURVEY-2026-001  
**Version:** 1.0  
**Date:** February 2026  
**Author:** Stephen Sweeney, Flightworks Aerial LLC  
**Status:** Specification (Future Phase)  
**Classification:** Public

---

## Executive Summary

Flightworks Survey is a governed precision mapping application for **engineering-grade photogrammetry and surveying**. Built on the FlightLaw safety kernel, it demonstrates how deterministic geometric validation can ensure survey-grade quality with mathematical proof.

### Core Value Proposition

> **"Engineering-grade spatial accuracy with deterministic verification. Every capture meets specified GSD, overlap, and precision requirements—provably."**

**Key Differentiators:**
- **RTK Precision Enforcement:** 2cm horizontal accuracy requirement
- **Grid Adherence Validation:** Geometric constraints enforced by reducer
- **GSD Compliance:** Deterministic altitude and capture verification
- **Quality Assurance:** Gap detection, overlap calculation, coverage verification
- **Audit Trail:** Complete spatial metadata for every capture

---

## Product Vision

### The Problem: Engineering Surveying Requirements

**Market Context:**
- Construction, mining, and civil engineering require cm-accuracy surveys
- Traditional surveying is slow and labor-intensive
- UAV photogrammetry offers speed but quality varies
- Regulatory compliance requires documented accuracy

**Current Solutions Fall Short:**
- Consumer drones: insufficient accuracy (<10cm)
- Professional systems: proprietary, expensive, limited audit trails
- Manual QA: time-consuming, subjective, error-prone

### The Solution: Deterministic Survey Governance

**Quality Assurance Through Architecture:**
- RTK GPS precision requirement (configurable by accuracy tier)
- Grid generation with deterministic geometry
- Real-time GSD compliance verification
- Post-flight gap detection and overlap analysis
- Complete audit trail with spatial metadata

---

## Target Users

### Primary: Engineering Survey Teams

**Persona:** Licensed surveyor conducting site surveys

**Goals:**
- Achieve 2cm horizontal accuracy (engineering tier)
- Complete coverage with no gaps
- Meet photogrammetry standards (overlap, GSD)
- Generate deliverables for CAD/GIS integration

**Constraints:**
- Regulatory compliance (ASPRS accuracy standards)
- Client specifications (accuracy, format, metadata)
- Weather windows (optimal lighting conditions)
- RTK base station setup and calibration

### Secondary: Construction Project Managers

**Persona:** Project manager tracking construction progress

**Goals:**
- Weekly/monthly progress documentation
- Volume calculations (cut/fill, stockpiles)
- As-built verification
- Change order documentation

**Needs:**
- Consistent methodology (reproducible measurements)
- Fast turnaround (<24 hours)
- Integration with project management tools

---

## Use Cases

### UC-1: Engineering Topographic Survey

**Goal:** Produce 2cm-accuracy topographic survey for civil engineering

**Preconditions:**
- RTK base station configured
- Survey area defined (AOI polygon)
- Accuracy tier: Engineering (RTK required)
- Target GSD: 2cm

**Flow:**
1. Operator defines AOI on map
2. System generates mission grid:
   - Calculates altitude for 2cm GSD
   - Generates parallel flight lines with 70% side overlap
   - Generates capture points with 80% front overlap
3. Operator reviews grid, approves mission
4. System verifies RTK fix before allowing start
5. Aircraft executes mission:
   - Navigates to each capture point
   - Validates position deviation <2m from planned
   - Validates GSD within tolerance
   - Validates RTK fix quality
   - Captures image if all validations pass
6. System tracks coverage in real-time
7. Post-flight gap detection identifies missed areas
8. Operator reviews quality report
9. System exports Survey Package

**Success Criteria:**
- >95% grid coverage
- 100% of captures meet GSD requirement
- 100% of captures have RTK fix
- All overlaps >75%
- Zero critical gaps

---

### UC-2: Construction Progress Monitoring

**Goal:** Document monthly construction progress for volume calculations

**Preconditions:**
- Survey area defined (consistent month-to-month)
- Accuracy tier: Mapping (GPS acceptable)
- Target GSD: 5cm

**Flow:**
1. Operator loads saved mission from previous month
2. System regenerates grid (same geometry)
3. Aircraft executes mission with GPS (no RTK required)
4. System validates GSD compliance
5. Post-flight overlap analysis
6. Export Survey Package
7. Deliverable: Time-series orthophotos for change detection

**Success Criteria:**
- Consistent capture positions (±2m) month-to-month
- GSD variation <10%
- Overlap consistency for reliable mosaicing

---

## Functional Requirements

### FR-1: Mission Grid Generation

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-1.1 | Grid generation shall be deterministic (same inputs → same grid) | P0 | Property test: 1000 iterations |
| FR-1.2 | GSD calculation shall follow standard formula | P0 | Unit test: known camera params |
| FR-1.3 | Altitude calculation shall achieve target GSD | P0 | Unit test: inverse calculation |
| FR-1.4 | Overlap percentages shall be configurable (60-90%) | P0 | Config test |
| FR-1.5 | Grid shall cover 100% of AOI | P0 | Geometry test |

---

### FR-2: RTK Precision Management

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-2.1 | Engineering tier shall require RTK fixed | P0 | State test |
| FR-2.2 | RTK fix quality shall be monitored continuously | P0 | Integration test |
| FR-2.3 | RTK loss during mission shall trigger pause | P0 | Integration test |
| FR-2.4 | Position accuracy shall be logged per capture | P0 | Audit test |
| FR-2.5 | Horizontal accuracy shall be ≤2cm (engineering tier) | P0 | Field test |

**Accuracy Tiers:**

| Tier | RTK Required | Horizontal Accuracy | Typical Use Case |
|------|--------------|---------------------|------------------|
| Engineering | Yes (fixed) | ≤2cm | Civil engineering, cadastral |
| Mapping | No (DGPS acceptable) | ≤5cm | Construction progress, mining |
| Inspection | No (GPS acceptable) | ≤10cm | Infrastructure inspection |

---

### FR-3: Grid Adherence Validation

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-3.1 | Position deviation from planned shall be calculated | P0 | Geometry test |
| FR-3.2 | Captures >2m from planned position shall be rejected | P0 | Unit test |
| FR-3.3 | Grid tolerance shall be configurable | P1 | Config test |
| FR-3.4 | Deviation shall be logged in capture metadata | P0 | Audit test |

---

### FR-4: GSD Compliance

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-4.1 | GSD shall be calculated per capture | P0 | Unit test |
| FR-4.2 | Captures exceeding max GSD shall be rejected | P0 | Unit test |
| FR-4.3 | GSD tolerance shall be ±10% of target | P0 | Boundary test |
| FR-4.4 | GSD calculation shall use actual altitude | P0 | Integration test |

**GSD Formula:**
```
GSD (cm) = (Altitude (m) × Sensor Width (mm) × 100) / (Focal Length (mm) × Image Width (px))
```

---

### FR-5: Capture Quality Validation

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-5.1 | All validations shall pass before capture | P0 | Integration test |
| FR-5.2 | Failed captures shall be logged with reason | P0 | Audit test |
| FR-5.3 | Capture completeness shall be tracked in real-time | P0 | State test |
| FR-5.4 | Operator shall be notified of validation failures | P0 | UI test |

**Validation Chain:**
1. Position within grid tolerance
2. GSD within tolerance
3. RTK fix (if required by tier)
4. Camera ready
5. Gimbal stabilized

---

### FR-6: Gap Detection

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-6.1 | Gap detection shall run post-flight | P0 | Integration test |
| FR-6.2 | Gaps shall be classified by severity | P0 | Unit test |
| FR-6.3 | Critical gaps (>10% area) shall require operator review | P0 | UI test |
| FR-6.4 | Gap locations shall be visualized on map | P0 | UI test |

**Gap Severity:**
- Minor: <5% of total area, isolated points
- Moderate: 5-10% of area, small clusters
- Critical: >10% of area, large gaps

---

### FR-7: Overlap Analysis

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-7.1 | Overlap shall be calculated between adjacent captures | P0 | Geometry test |
| FR-7.2 | Front overlap target: 80% | P0 | Calculation test |
| FR-7.3 | Side overlap target: 70% | P0 | Calculation test |
| FR-7.4 | Insufficient overlap shall be flagged in QC report | P0 | Report test |

---

### FR-8: Survey Package Export

| ID | Requirement | Priority | Verification |
|----|-------------|----------|--------------|
| FR-8.1 | Export shall include: images, positions CSV, grid KML, QC report | P0 | Export test |
| FR-8.2 | Images shall include EXIF GPS tags | P0 | EXIF test |
| FR-8.3 | Positions CSV shall include RTK fix status and accuracy | P0 | CSV schema test |
| FR-8.4 | QC report shall include: coverage %, gap analysis, overlap stats | P0 | PDF validation |
| FR-8.5 | Export shall complete in <60 seconds | P0 | Performance test |

---

## Non-Functional Requirements

### NFR-1: Determinism

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-1.1 | Grid generation determinism | 100% identical grids | Property test: 10,000 iterations |
| NFR-1.2 | GSD calculation determinism | 100% identical values | Unit test |
| NFR-1.3 | Gap detection determinism | 100% identical gaps | Integration test |
| NFR-1.4 | Overlap calculation determinism | 100% identical overlaps | Integration test |

### NFR-2: Accuracy

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-2.1 | Horizontal accuracy (engineering) | ≤2cm (95% CEP) | RTK field test |
| NFR-2.2 | Vertical accuracy (engineering) | ≤5cm (95% CEP) | RTK field test |
| NFR-2.3 | GSD accuracy | ±10% of target | Altitude verification |

### NFR-3: Performance

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-3.1 | Grid generation | <5s for 500-point grid | Performance test |
| NFR-3.2 | Position validation | <10ms | Real-time test |
| NFR-3.3 | Gap detection | <10s for 1000 points | Performance test |
| NFR-3.4 | Survey package export | <60s | Performance test |

### NFR-4: Coverage

| ID | Requirement | Target | Verification |
|----|-------------|--------|--------------|
| NFR-4.1 | Grid coverage of AOI | 100% | Geometry test |
| NFR-4.2 | Actual capture coverage | >95% | Mission completion test |
| NFR-4.3 | Front overlap | >75% | Overlap analysis |
| NFR-4.4 | Side overlap | >65% | Overlap analysis |

---

## Success Metrics

### Technical Metrics

| Metric | Target |
|--------|--------|
| Grid generation accuracy | 100% AOI coverage |
| RTK fix acquisition rate | >95% of missions |
| Position accuracy (engineering) | <2cm horizontal (95% CEP) |
| GSD compliance | >98% within tolerance |
| Gap detection accuracy | 100% of gaps >1m² identified |
| Overlap calculation accuracy | ±2% of theoretical |

### Business Metrics

| Metric | 6-Month | 12-Month |
|--------|---------|----------|
| Engineering surveys completed | 10 | 50 |
| Mapping surveys completed | 20 | 100 |
| Client acceptance rate | >90% | >95% |
| Repeat business | >70% | >80% |

---

## Platform Support

### Primary Platform

| Component | Specification |
|-----------|---------------|
| Aircraft | DJI Matrice 4E |
| Camera | 20MP, 4/3" CMOS, mechanical shutter |
| GPS | DJI D-RTK 2 Mobile Station |
| Operator Interface | iPad Pro (M2+), iOS 17+ |

### RTK Requirements

| Accuracy Tier | RTK Config | Base Station |
|---------------|------------|--------------|
| Engineering | D-RTK 2 (fixed) | Required |
| Mapping | SBAS/WAAS | Optional |
| Inspection | Standard GPS | Not required |

---

## Development Roadmap

### Phase 1: Grid Generation (Q3 2026)

**Deliverables:**
- Deterministic grid algorithm
- GSD calculations
- Mission planning UI

**Success Criteria:**
- Grid covers 100% of AOI
- GSD accuracy ±1%

---

### Phase 2: RTK Integration (Q4 2026)

**Deliverables:**
- RTK status monitoring
- Fix quality validation
- Accuracy tier enforcement

**Success Criteria:**
- RTK fix acquired in <60s
- Accuracy meets tier requirements

---

### Phase 3: Quality Assurance (Q1 2027)

**Deliverables:**
- Gap detection
- Overlap analysis
- QC report generation

**Success Criteria:**
- All gaps >1m² detected
- Overlap calculations ±2% accurate

---

### Phase 4: Export & Integration (Q2 2027)

**Deliverables:**
- Survey package export
- CAD/GIS format support
- API for external tools

**Success Criteria:**
- Export completes in <60s
- Formats compatible with industry tools

---

## Constraints & Assumptions

### Technical Constraints

| Constraint | Impact | Mitigation |
|------------|--------|------------|
| RTK base station range (<10km) | Survey area limited | Multiple base stations |
| Weather dependency (wind, light) | Survey window limited | Flexible scheduling |
| Battery life (30 min) | Area per flight limited | Mission segmentation |

### Assumptions

| Assumption | Risk if Invalid | Validation |
|------------|-----------------|------------|
| RTK sufficient for 2cm accuracy | Accuracy inadequate | Field testing with ground control |
| M4E camera adequate for engineering | Image quality poor | Sample data analysis |
| Grid adherence achievable with GPS/IMU | Position drift excessive | Wind testing |

---

## Acceptance Criteria

Flightworks Survey is **ready for deployment** when:

1. ✅ Grid generation deterministic (10,000 iterations identical)
2. ✅ RTK fix acquisition reliable (>95% success rate)
3. ✅ Position accuracy meets engineering tier (<2cm horizontal)
4. ✅ GSD compliance >98%
5. ✅ Gap detection functional (all gaps >1m² found)
6. ✅ Overlap analysis accurate (±2%)
7. ✅ Survey package export complete (<60s)
8. ✅ QC report professional quality
9. ✅ Audit trail complete (all spatial metadata)
10. ✅ Field validation with ground control points

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [Flightworks-Suite-Overview.md](./Flightworks-Suite-Overview.md) | Suite architecture |
| [HLD-FlightworksSurvey.md](./HLD-FlightworksSurvey.md) | SurveyLaw architecture |
| [HLD-FlightworksCore.md](./HLD-FlightworksCore.md) | FlightLaw foundation |
| [PRD-FlightworksCore.md](./PRD-FlightworksCore.md) | FlightLaw requirements |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Feb 2026 | S. Sweeney | Initial SurveyLaw PRD |

---

**Document Control**

- **Owner:** Stephen Sweeney, Flightworks Aerial LLC
- **Review Cycle:** Quarterly
- **Distribution:** Internal, potential survey partners

---

## Conclusion

Flightworks Survey demonstrates that **precision is provable**. By combining:

- **RTK GPS enforcement** (cm-accuracy positioning)
- **Deterministic grid validation** (geometric constraints)
- **GSD compliance verification** (altitude + capture validation)
- **Quality assurance** (gap detection, overlap analysis)

...we create a survey workflow that provides:
- **Engineering-grade accuracy** (2cm horizontal with RTK)
- **Mathematical proof** (deterministic calculations, complete audit)
- **Regulatory compliance** (ASPRS standards, documented methodology)
- **Client trust** (reproducible results, transparent QA)

This is surveying with **architectural guarantees**, not just operator skill.
