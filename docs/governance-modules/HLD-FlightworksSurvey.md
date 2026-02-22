# Flightworks Survey: High-Level Design (SurveyLaw Jurisdiction)

**Document:** HLD-FS-SURVEY-2026-001  
**Version:** 1.0  
**Date:** February 2026  
**Author:** Stephen Sweeney, Flightworks Aerial LLC  
**Status:** Specification (Future Phase)  
**Classification:** Public

---

## Document Purpose

This High-Level Design (HLD) specifies **Flightworks Survey**—the SurveyLaw jurisdiction that extends FlightLaw for precision mapping and photogrammetry operations. This demonstrates how the jurisdiction model applies to engineering-grade spatial accuracy requirements.

**SurveyLaw = FlightLaw + Survey-Specific Governance**

**Scope:**
- SurveyLaw jurisdiction specification
- RTK GPS precision enforcement
- Grid generation and adherence validation
- Ground Sample Distance (GSD) calculations
- Photogrammetry capture requirements
- Engineering-grade quality assurance

**Out of Scope (Future Enhancements):**
- Point cloud processing
- 3D reconstruction algorithms
- Multi-platform coordination
- Cloud-based processing workflows

---

## Architectural Philosophy

### Extending FlightLaw

SurveyLaw **inherits** all FlightLaw guarantees:
- ✅ Laws 3, 4, 7, 8 enforcement
- ✅ Tamper-evident audit trail
- ✅ Deterministic state transitions
- ✅ Operator authority (Law 8)

SurveyLaw **adds** domain-specific governance:
- RTK GPS precision requirements
- Grid geometric validation
- GSD compliance verification
- Capture completeness tracking
- Survey-grade quality gates

### The Geometric Constraint Engine

```
┌──────────────────────────────────────────────────────────────┐
│                    STOCHASTIC ZONE                           │
│  (Environmental disturbances, sensor noise)                  │
│                                                              │
│  • Wind gusts and atmospheric turbulence                     │
│  • GPS signal quality variations                            │
│  • IMU drift and sensor noise                               │
│  • Gimbal stabilization delays                              │
│  • Navigation Agent proposes corrective maneuvers            │
└──────────────────────────────────────────────────────────────┘
                            │
                            │ NavigationProposal
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                   SURVEYLAW REDUCER                          │
│              (Geometric Validation)                          │
│                                                              │
│  func reduce(state: SurveyState,                            │
│              action: SurveyAction) -> SurveyState {          │
│                                                              │
│    // Apply Law 7 (Spatial) with survey precision           │
│    let deviation = calculateDeviation(                      │
│      proposed: action.position,                             │
│      planned: state.missionGrid                             │
│    )                                                         │
│                                                              │
│    if deviation > TOLERANCE_GRID_ADHERENCE {                │
│      return state.rejectAction(                             │
│        reason: "Exceeds grid tolerance: \(deviation)m"      │
│      )                                                       │
│    }                                                         │
│                                                              │
│    // Verify GSD compliance                                 │
│    let gsd = calculateGSD(                                   │
│      altitude: action.altitude,                             │
│      sensorParams: state.cameraParams                       │
│    )                                                         │
│                                                              │
│    if gsd > state.maxGSD {                                  │
│      return state.rejectAction(                             │
│        reason: "GSD \(gsd)cm exceeds max \(state.maxGSD)cm" │
│      )                                                       │
│    }                                                         │
│                                                              │
│    return state.withValidatedPosition(action.position)      │
│  }                                                           │
└──────────────────────────────────────────────────────────────┘
                            │
                            │ ValidatedCapture
                            ▼
┌──────────────────────────────────────────────────────────────┐
│                 DETERMINISTIC OUTPUT                         │
│                                                              │
│  • Grid-locked capture position (RTK-verified)              │
│  • GSD compliance verified                                  │
│  • Overlap percentages calculated                           │
│  • Capture completeness tracked                             │
│  • Audit log with spatial metadata                          │
└──────────────────────────────────────────────────────────────┘
```

---

## SurveyLaw Jurisdiction

### Business Guarantee

> **"100% adherence to engineering-grade spatial grids. Every capture meets specified GSD, overlap, and accuracy requirements with deterministic verification."**

### Composed Laws

```
SurveyLaw = FlightLaw ∘ SurveyGovernance

where:
  FlightLaw = Law 3 ∘ Law 4 ∘ Law 7 ∘ Law 8
  SurveyGovernance = {
    RTK Precision Requirements,
    Grid Geometric Validation,
    GSD Compliance Rules,
    Capture Quality Gates
  }
```

### Target Applications

**Primary Use Cases:**
- Topographic surveys (2cm horizontal accuracy)
- Construction progress monitoring
- Volume calculations (earthwork, stockpiles)
- As-built verification
- Infrastructure inspection with precise geometry

**Platform:** DJI Matrice 4E (or M4T in photogrammetry mode)

---

## Domain Model

### SurveyState Extension

```swift
extension AppState {
    var survey: SurveyState {
        get { /* ... */ }
        set { /* ... */ }
    }
}

struct SurveyState: State {
    // Mission configuration
    var surveyMission: SurveyMission?
    var missionGrid: MissionGrid?
    
    // RTK GPS state
    var rtkStatus: RTKStatus
    var positionAccuracy: PositionAccuracy?
    
    // Capture state
    var capturePoints: [CapturePoint]
    var captureCompleteness: GridCompleteness
    
    // Camera configuration
    var cameraParams: CameraParameters
    var gimbalAngle: Angle
    
    // Quality metrics
    var gsdActual: [GSDMeasurement]
    var overlapActual: [OverlapMeasurement]
    
    // Export state
    var surveyPackage: SurveyPackage?
}

struct SurveyMission {
    var id: MissionID
    var type: SurveyType
    var areaOfInterest: Polygon
    var requiredGSD: Distance          // e.g., 2cm
    var overlapFront: Percentage       // e.g., 80%
    var overlapSide: Percentage        // e.g., 70%
    var accuracyRequirement: AccuracyTier
}

enum SurveyType {
    case orthophoto
    case oblique
    case corridor
    case volumetric
    case facade
}

enum AccuracyTier {
    case engineering      // RTK required, 2cm horizontal
    case mapping          // GPS acceptable, 5cm horizontal
    case inspection       // GPS acceptable, 10cm horizontal
}

struct MissionGrid {
    var waypoints: [Waypoint]
    var flightLines: [FlightLine]
    var gridGeometry: GridGeometry
    var turnPoints: [Position]
}

struct FlightLine {
    var id: LineID
    var startPoint: Position
    var endPoint: Position
    var capturePoints: [Position]
    var heading: Angle
}

enum GridGeometry {
    case parallel(spacing: Distance, angle: Angle)
    case crosshatch(primaryAngle: Angle, secondaryAngle: Angle)
    case circular(center: Position, radius: Distance)
}

struct RTKStatus {
    var fixType: RTKFixType
    var satelliteCount: Int
    var hdop: Double
    var vdop: Double
    var age: TimeInterval          // Age of correction data
}

enum RTKFixType {
    case noFix
    case autonomous               // Standard GPS
    case dgps                     // SBAS corrections
    case rtkFloat                 // RTK convergingsurvey
    case rtkFixed                 // RTK converged (cm accuracy)
}

struct PositionAccuracy {
    var horizontal: Distance      // CEP (Circular Error Probable)
    var vertical: Distance
    var confidence: Double        // e.g., 95%
}

struct CapturePoint {
    var id: CaptureID
    var position: Position
    var altitude: Altitude
    var timestamp: Timestamp
    var rtkFix: RTKFixType
    var accuracy: PositionAccuracy
    var gsd: Distance
    var gimbalAngle: Angle
    var imageRef: ImageReference
    var gridDeviation: Distance   // Distance from planned position
}

struct GridCompleteness {
    var totalPoints: Int
    var capturedPoints: Int
    var missedPoints: [Position]
    var coveragePercentage: Double
    var gapsIdentified: [GridGap]
}

struct GridGap {
    var location: Position
    var size: Area
    var severity: GapSeverity
}

enum GapSeverity {
    case minor        // <5% of total area
    case moderate     // 5-10% of total area
    case critical     // >10% of total area
}
```

---

## SurveyAction Extensions

```swift
enum AppAction {
    case survey(SurveyAction)
    // ... other actions
}

enum SurveyAction {
    // Mission management
    case loadSurveyMission(SurveyMission)
    case generateGrid(AOI: Polygon, parameters: GridParameters)
    case validateGrid(MissionGrid)
    case startSurvey
    case pauseSurvey
    case resumeSurvey
    case completeSurvey
    
    // RTK management
    case updateRTKStatus(RTKStatus)
    case waitForRTKFix
    case rtkFixAcquired(PositionAccuracy)
    case rtkFixLost
    
    // Capture
    case approachCapturePoint(Position)
    case captureImage(metadata: CaptureMetadata)
    case captureCompleted(CapturePoint)
    case detectGridDeviation(deviation: Distance)
    
    // Quality validation
    case validateGSD(measured: Distance, required: Distance)
    case validateOverlap(measured: Percentage, required: Percentage)
    case identifyGaps
    
    // Export
    case generateSurveyPackage
    case exportCompleted(SurveyPackage)
}

struct GridParameters {
    var targetGSD: Distance
    var overlapFront: Percentage
    var overlapSide: Percentage
    var flightAltitude: Altitude?    // Optional, calculated if nil
    var flightSpeed: Speed?
    var captureInterval: TimeInterval?
}

struct CaptureMetadata {
    var position: Position
    var altitude: Altitude
    var rtkFix: RTKFixType
    var accuracy: PositionAccuracy
    var gimbalAngle: Angle
    var cameraSettings: CameraSettings
}
```

---

## SurveyLaw Reducer

```swift
struct SurveyReducer {
    
    func reduce(state: SurveyState,
               action: SurveyAction) -> SurveyState {
        
        switch action {
            
        case .loadSurveyMission(let mission):
            return SurveyState(
                surveyMission: mission,
                rtkStatus: .noFix,
                cameraParams: CameraParameters.forM4E,
                capturePoints: [],
                captureCompleteness: .initial
            )
            
        case .generateGrid(let aoi, let params):
            // Deterministic grid generation
            let grid = GridGenerator.generate(
                aoi: aoi,
                parameters: params,
                cameraParams: state.cameraParams
            )
            
            var newState = state
            newState.missionGrid = grid
            return newState
            
        case .rtkFixAcquired(let accuracy):
            guard state.surveyMission?.accuracyRequirement == .engineering else {
                // RTK not required for this mission
                return state
            }
            
            guard accuracy.horizontal <= Distance(meters: 0.02) else {
                // RTK fix not sufficient for engineering accuracy
                return state  // Remain in waiting state
            }
            
            var newState = state
            newState.positionAccuracy = accuracy
            return newState
            
        case .captureImage(let metadata):
            // Validate position against grid
            guard let grid = state.missionGrid else {
                return state  // No grid loaded
            }
            
            let nearestPlanned = grid.findNearestCapturePoint(
                to: metadata.position
            )
            
            let deviation = metadata.position.distance(to: nearestPlanned)
            
            // Grid adherence validation
            if deviation > state.gridToleranceMeters {
                // Log rejection but don't crash
                return state.withRejection(
                    reason: "Grid deviation \(deviation)m exceeds tolerance"
                )
            }
            
            // GSD validation
            let actualGSD = calculateGSD(
                altitude: metadata.altitude,
                cameraParams: state.cameraParams
            )
            
            guard let mission = state.surveyMission else {
                return state
            }
            
            if actualGSD > mission.requiredGSD {
                return state.withRejection(
                    reason: "GSD \(actualGSD.cm)cm exceeds required \(mission.requiredGSD.cm)cm"
                )
            }
            
            // RTK requirement validation
            if mission.accuracyRequirement == .engineering {
                guard metadata.rtkFix == .rtkFixed else {
                    return state.withRejection(
                        reason: "Engineering accuracy requires RTK fix, got \(metadata.rtkFix)"
                    )
                }
            }
            
            // All validations passed - record capture
            let capturePoint = CapturePoint(
                position: metadata.position,
                altitude: metadata.altitude,
                rtkFix: metadata.rtkFix,
                accuracy: metadata.accuracy,
                gsd: actualGSD,
                gimbalAngle: metadata.gimbalAngle,
                gridDeviation: deviation
            )
            
            var newState = state
            newState.capturePoints.append(capturePoint)
            newState.captureCompleteness = calculateCompleteness(
                planned: grid.capturePoints,
                actual: newState.capturePoints
            )
            
            return newState
            
        case .identifyGaps:
            guard let grid = state.missionGrid else {
                return state
            }
            
            let gaps = GapDetector.findGaps(
                planned: grid.capturePoints,
                actual: state.capturePoints,
                tolerance: state.gridToleranceMeters
            )
            
            var newState = state
            newState.captureCompleteness.gapsIdentified = gaps
            return newState
            
        default:
            return state
        }
    }
    
    // MARK: - Deterministic Calculations
    
    static func calculateGSD(
        altitude: Altitude,
        cameraParams: CameraParameters
    ) -> Distance {
        // Ground Sample Distance = (Altitude × Sensor Width) / (Focal Length × Image Width)
        let altitudeMeters = altitude.agl
        let sensorWidthMM = cameraParams.sensorWidth
        let focalLengthMM = cameraParams.focalLength
        let imageWidthPixels = cameraParams.imageWidth
        
        let gsdCM = (altitudeMeters * sensorWidthMM * 100) / 
                    (focalLengthMM * Double(imageWidthPixels))
        
        return Distance(centimeters: gsdCM)
    }
    
    static func calculateCompleteness(
        planned: [Position],
        actual: [CapturePoint]
    ) -> GridCompleteness {
        
        let tolerance = Distance(meters: 2.0)  // Position matching tolerance
        
        var captured = 0
        var missed: [Position] = []
        
        for plannedPoint in planned {
            let hasMatch = actual.contains { capturePoint in
                capturePoint.position.distance(to: plannedPoint) <= tolerance
            }
            
            if hasMatch {
                captured += 1
            } else {
                missed.append(plannedPoint)
            }
        }
        
        let percentage = (Double(captured) / Double(planned.count)) * 100
        
        return GridCompleteness(
            totalPoints: planned.count,
            capturedPoints: captured,
            missedPoints: missed,
            coveragePercentage: percentage,
            gapsIdentified: []  // Filled by separate gap detection
        )
    }
}
```

---

## Grid Generation

### Deterministic Grid Algorithm

```swift
struct GridGenerator {
    
    static func generate(
        aoi: Polygon,
        parameters: GridParameters,
        cameraParams: CameraParameters
    ) -> MissionGrid {
        
        // 1. Calculate required altitude for target GSD
        let altitude = calculateAltitudeForGSD(
            targetGSD: parameters.targetGSD,
            cameraParams: cameraParams
        )
        
        // 2. Calculate image footprint at altitude
        let footprint = calculateFootprint(
            altitude: altitude,
            cameraParams: cameraParams
        )
        
        // 3. Calculate flight line spacing for side overlap
        let lineSpacing = footprint.width * (1.0 - parameters.overlapSide)
        
        // 4. Calculate capture point spacing for front overlap
        let pointSpacing = footprint.length * (1.0 - parameters.overlapFront)
        
        // 5. Generate parallel flight lines covering AOI
        let flightLines = generateParallelLines(
            aoi: aoi,
            spacing: lineSpacing,
            angle: 0.0  // Default north-south, configurable
        )
        
        // 6. Generate capture points along flight lines
        var waypoints: [Waypoint] = []
        var capturePoints: [Position] = []
        
        for line in flightLines {
            let linePoints = generateCapturePoints(
                line: line,
                spacing: pointSpacing
            )
            
            waypoints.append(contentsOf: linePoints.map { pos in
                Waypoint(
                    position: pos,
                    altitude: altitude,
                    action: .captureImage
                )
            })
            
            capturePoints.append(contentsOf: linePoints)
        }
        
        return MissionGrid(
            waypoints: waypoints,
            flightLines: flightLines,
            gridGeometry: .parallel(spacing: lineSpacing, angle: 0.0),
            turnPoints: calculateTurnPoints(flightLines: flightLines)
        )
    }
    
    static func calculateAltitudeForGSD(
        targetGSD: Distance,
        cameraParams: CameraParameters
    ) -> Altitude {
        // Invert GSD formula to solve for altitude
        let altitudeMeters = (targetGSD.centimeters * cameraParams.focalLength * 
                             Double(cameraParams.imageWidth)) / 
                            (cameraParams.sensorWidth * 100)
        
        return Altitude(agl: altitudeMeters)
    }
    
    static func calculateFootprint(
        altitude: Altitude,
        cameraParams: CameraParameters
    ) -> ImageFootprint {
        let altitudeMeters = altitude.agl
        
        let width = (altitudeMeters * cameraParams.sensorWidth) / 
                    cameraParams.focalLength
        let length = (altitudeMeters * cameraParams.sensorHeight) / 
                     cameraParams.focalLength
        
        return ImageFootprint(width: width, length: length)
    }
}

struct ImageFootprint {
    var width: Distance   // Cross-track
    var length: Distance  // Along-track
}

struct CameraParameters {
    var sensorWidth: Double      // mm
    var sensorHeight: Double     // mm
    var focalLength: Double      // mm
    var imageWidth: Int          // pixels
    var imageHeight: Int         // pixels
    
    static let forM4E = CameraParameters(
        sensorWidth: 13.2,
        sensorHeight: 8.8,
        focalLength: 8.4,
        imageWidth: 5280,
        imageHeight: 3956
    )
}
```

---

## SurveyLaw Enforcement

```swift
actor SurveyLawEnforcer {
    private let flightEnforcer = FlightLawEnforcer()
    
    func evaluate(action: AppAction,
                 state: AppState) async -> EnforcementResult {
        
        // Step 1: Apply FlightLaw (universal safety)
        let flightResult = await flightEnforcer.evaluate(
            action: action,
            state: state
        )
        
        guard case .permitted = flightResult else {
            return flightResult  // FlightLaw takes precedence
        }
        
        // Step 2: Apply SurveyLaw (if applicable)
        guard case .survey(let surveyAction) = action else {
            return flightResult
        }
        
        return await evaluateSurveyLaw(
            action: surveyAction,
            state: state
        )
    }
    
    private func evaluateSurveyLaw(
        action: SurveyAction,
        state: AppState
    ) async -> EnforcementResult {
        
        switch action {
            
        case .startSurvey:
            // Verify RTK fix if engineering accuracy required
            if state.survey.surveyMission?.accuracyRequirement == .engineering {
                guard state.survey.rtkStatus.fixType == .rtkFixed else {
                    return .rejected(
                        reason: "Engineering accuracy requires RTK fix (current: \(state.survey.rtkStatus.fixType))",
                        evaluations: []
                    )
                }
                
                guard let accuracy = state.survey.positionAccuracy,
                      accuracy.horizontal <= Distance(meters: 0.02) else {
                    return .rejected(
                        reason: "Horizontal accuracy insufficient for engineering survey",
                        evaluations: []
                    )
                }
            }
            
            // Verify grid loaded
            guard state.survey.missionGrid != nil else {
                return .rejected(
                    reason: "No mission grid loaded",
                    evaluations: []
                )
            }
            
            return .permitted(evaluations: [])
            
        case .captureImage(let metadata):
            // Grid adherence check performed by reducer
            // Law enforcement just validates preconditions
            
            guard state.survey.surveyMission != nil else {
                return .rejected(
                    reason: "No active survey mission",
                    evaluations: []
                )
            }
            
            return .permitted(evaluations: [])
            
        default:
            return .permitted(evaluations: [])
        }
    }
}
```

---

## Quality Assurance

### Gap Detection

```swift
struct GapDetector {
    
    static func findGaps(
        planned: [Position],
        actual: [CapturePoint],
        tolerance: Distance
    ) -> [GridGap] {
        
        var gaps: [GridGap] = []
        
        // Find uncaptured planned positions
        let uncaptured = planned.filter { plannedPos in
            !actual.contains { capture in
                capture.position.distance(to: plannedPos) <= tolerance
            }
        }
        
        if uncaptured.isEmpty {
            return []
        }
        
        // Cluster nearby uncaptured points into gaps
        let clusters = clusterPositions(uncaptured, maxDistance: tolerance)
        
        for cluster in clusters {
            let area = calculateConvexHullArea(cluster)
            let center = calculateCentroid(cluster)
            
            let severity: GapSeverity
            if cluster.count < 3 {
                severity = .minor
            } else if cluster.count < 10 {
                severity = .moderate
            } else {
                severity = .critical
            }
            
            gaps.append(GridGap(
                location: center,
                size: area,
                severity: severity
            ))
        }
        
        return gaps.sorted { $0.severity.rawValue > $1.severity.rawValue }
    }
}
```

### Overlap Verification

```swift
struct OverlapCalculator {
    
    static func calculateOverlap(
        capturePoints: [CapturePoint],
        flightLines: [FlightLine]
    ) -> [OverlapMeasurement] {
        
        var measurements: [OverlapMeasurement] = []
        
        for line in flightLines {
            let lineCaptures = capturePoints.filter { capture in
                line.capturePoints.contains { planned in
                    capture.position.distance(to: planned) < Distance(meters: 2)
                }
            }
            
            guard lineCaptures.count >= 2 else {
                continue
            }
            
            for i in 0..<(lineCaptures.count - 1) {
                let current = lineCaptures[i]
                let next = lineCaptures[i + 1]
                
                let overlap = calculateImageOverlap(
                    first: current,
                    second: next
                )
                
                measurements.append(overlap)
            }
        }
        
        return measurements
    }
    
    static func calculateImageOverlap(
        first: CapturePoint,
        second: CapturePoint
    ) -> OverlapMeasurement {
        
        let distance = first.position.distance(to: second.position)
        
        // Footprint size at altitude
        let footprint = GridGenerator.calculateFootprint(
            altitude: first.altitude,
            cameraParams: CameraParameters.forM4E
        )
        
        // Overlap calculation
        let overlapDistance = footprint.length - distance
        let overlapPercentage = (overlapDistance / footprint.length) * 100
        
        return OverlapMeasurement(
            position1: first.position,
            position2: second.position,
            overlapPercentage: overlapPercentage,
            meetsRequirement: overlapPercentage >= 75.0  // Typical requirement
        )
    }
}

struct OverlapMeasurement {
    var position1: Position
    var position2: Position
    var overlapPercentage: Double
    var meetsRequirement: Bool
}
```

---

## Survey Package Export

### Export Structure

```
Survey_Package_<MissionID>.zip
├── manifest.json              # Mission metadata, grid parameters
├── report.pdf                 # Quality assurance report
├── positions.csv              # All capture positions with accuracy
├── grid_kml.kml              # Mission grid (Google Earth)
├── images/
│   ├── IMG_0001.jpg (with EXIF GPS)
│   ├── IMG_0002.jpg
│   └── ...
├── audit/
│   └── mission_audit.json     # Complete audit trail
└── qc/
    ├── coverage_map.png       # Visual coverage verification
    ├── gaps_report.json       # Identified gaps
    └── overlap_analysis.csv   # Overlap measurements
```

---

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **DJI Matrice 4E** | ✅ Primary | Mapping/surveying platform |
| **DJI Matrice 4T** | ✅ Supported | Photogrammetry mode |
| **RTK Base Station** | ✅ Required | For engineering accuracy |
| **iPad Pro** | ✅ Primary | Mission planning interface |

---

## Performance Targets

| Metric | Target | Rationale |
|--------|--------|-----------|
| Grid generation | <5s for 500-point grid | Operator workflow |
| RTK fix acquisition | <60s | Industry standard |
| Position validation | <10ms | Real-time capture |
| Gap detection | <10s for 1000-point mission | Post-flight QC |
| Export generation | <60s | Operator workflow |

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [Flightworks-Suite-Overview.md](./Flightworks-Suite-Overview.md) | Suite architecture |
| [HLD-FlightworksCore.md](./HLD-FlightworksCore.md) | FlightLaw foundation |
| [PRD-FlightworksSurvey.md](./PRD-FlightworksSurvey.md) | SurveyLaw requirements |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Feb 2026 | S. Sweeney | Initial SurveyLaw HLD |

---

**Document Control**

- **Owner:** Stephen Sweeney, Flightworks Aerial LLC
- **Review Cycle:** Quarterly or upon architectural changes
- **Distribution:** Internal, research partners

---

## Conclusion

Flightworks Survey (SurveyLaw) demonstrates how the jurisdiction model applies to precision mapping. By extending FlightLaw with survey-specific governance, it provides:

**Engineering-Grade Guarantees:**
- RTK precision enforcement (2cm horizontal)
- Grid adherence validation
- GSD compliance verification
- Capture completeness tracking

**Deterministic Quality Assurance:**
- Gap detection algorithms
- Overlap calculations
- Coverage verification
- All deterministically reproducible

This architecture enables **certifiable survey operations** where every capture meets engineering specifications with mathematical proof.
