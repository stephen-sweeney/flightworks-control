# Flightworks Thermal: High-Level Design (ThermalLaw Jurisdiction)

**Document:** HLD-FT-THERMAL-2026-001  
**Version:** 2.0  
**Date:** February 2026  
**Author:** Stephen Sweeney, Flightworks Aerial LLC  
**Status:** Specified (Future Jurisdiction — development after FlightLaw foundation)  
**Classification:** Public

---

## Document Purpose

This High-Level Design (HLD) specifies **Flightworks Thermal**â€”the ThermalLaw jurisdiction that extends FlightLaw for thermal inspection operations. The MVP scope is **post-hail roof assessment using visible imagery as primary signal, with thermal as secondary**. ThermalLaw is the first jurisdiction to demonstrate governed AI processing of probabilistic ML outputs through deterministic post-processing.

**ThermalLaw = FlightLaw + Thermal-Specific Governance**

**Scope:**
- ThermalLaw jurisdiction specification
- Roof damage detection (RGB-primary, thermal-secondary)
- Deterministic processing of probabilistic ML outputs
- Operator approval workflow
- Documentation Pack export
- Session replay capability

**Out of Scope (Future Phases):**
- Advanced thermal-only workflows (moisture, insulation)
- Multi-domain thermal applications
- Cloud-based processing

---

## Architectural Philosophy

### Extending FlightLaw

ThermalLaw **inherits** all FlightLaw guarantees:
- âœ… Laws 3, 4, 7, 8 enforcement
- âœ… Tamper-evident audit trail
- âœ… Deterministic state transitions
- âœ… Operator authority (Law 8)

ThermalLaw **adds** domain-specific governance:
- Thermal sensor state management
- ML inference pipeline with deterministic post-processing
- Anomaly classification and flagging
- Inspection-specific approval workflows

### The Determinism Boundary

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                    STOCHASTIC ZONE                           â”‚
â”‚  (Non-deterministic, probabilistic)                          â”‚
â”‚                                                              â”‚
â”‚  â€¢ Thermal sensor radiometric data (noise, calibration)     â”‚
â”‚  â€¢ RGB camera imagery (lighting, compression artifacts)     â”‚
â”‚  â€¢ ML model inference (probabilistic outputs)               â”‚
â”‚  â€¢ Bounding boxes with confidence scores                    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                            â”‚
                            â”‚ ThermalMLOutput / RoofMLOutput
                            â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                  THERMALLAW REDUCER                          â”‚
â”‚              (Deterministic Processing)                      â”‚
â”‚                                                              â”‚
â”‚  func reduce(state: ThermalState,                           â”‚
â”‚              action: ThermalAction) -> ThermalState {        â”‚
â”‚                                                              â”‚
â”‚    // Apply fixed, auditable thresholds                     â”‚
â”‚    switch action {                                           â”‚
â”‚    case .inferenceCompleted(let output):                    â”‚
â”‚      let candidates = classifyCandidates(                   â”‚
â”‚        output: output,                                       â”‚
â”‚        thresholds: state.thresholds  // Compile-time config â”‚
â”‚      )                                                       â”‚
â”‚      return state.withProposedCandidates(candidates)        â”‚
â”‚                                                              â”‚
â”‚    case .approveCandidate(let id):                          â”‚
â”‚      // Law 8: Operator approval required                   â”‚
â”‚      return state.withFlaggedAnomaly(id)                    â”‚
â”‚    }                                                         â”‚
â”‚  }                                                           â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                            â”‚
                            â”‚ RoofCandidate / ThermalAnomaly
                            â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                 DETERMINISTIC OUTPUT                         â”‚
â”‚                                                              â”‚
â”‚  â€¢ GPS-locked candidate location                            â”‚
â”‚  â€¢ Severity classification (Minor/Moderate/Significant)     â”‚
â”‚  â€¢ Image references (frame IDs, crops)                      â”‚
â”‚  â€¢ Audit log entry with hash                                â”‚
â”‚  â€¢ Operator approval requirement (Law 8)                    â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

---

## ThermalLaw Jurisdiction

### Business Guarantee

> **"No critical roof damage will be missed or hallucinated. Every flagged anomaly has explicit operator approval and is deterministically reproducible."**

### Composed Laws

```
ThermalLaw = FlightLaw âˆ˜ ThermalGovernance

where:
  FlightLaw = Law 3 âˆ˜ Law 4 âˆ˜ Law 7 âˆ˜ Law 8
  ThermalGovernance = {
    Candidate Classification Rules,
    Severity Banding Logic,
    Approval Workflow,
    Export Requirements
  }
```

### MVP Scope

**Primary Detection:** Visible imagery (RGB, zoom camera)  
**Secondary Detection:** Thermal imagery (follow-on moisture cues)  
**Platform:** PX4/MAVLink-compatible aircraft (Skydio X10 for field testing)  
**Deployment:** Onboard inference, edge-first architecture

**Workflow:** Observe â†’ Infer â†’ Explain â†’ Approve â†’ Flag â†’ Export â†’ Replay

---

## Domain Model

### ThermalState Extension

```swift
extension AppState {
    var thermal: ThermalState {
        get { /* ... */ }
        set { /* ... */ }
    }
}

struct ThermalState: State {
    // Session management
    var sessionID: SessionID?
    var sessionType: InspectionType
    var sessionStartTime: Timestamp?
    
    // Capture state
    var capturedFrames: [FrameMetadata]
    var roofZones: [RoofZone: CaptureStatus]
    
    // ML inference state
    var mlModel: ModelState
    var inferenceQueue: [InferenceTask]
    
    // Candidate management
    var proposedCandidates: [RoofCandidate]  // Proposed by AI
    var flaggedAnomalies: [RoofAnomaly]      // Approved by operator
    
    // Configuration
    var thresholds: ClassificationThresholds
    var severityBands: SeverityBandConfig
    
    // Export state
    var exportStatus: ExportStatus?
}

enum InspectionType {
    case postHailRoof
    case thermalMoisture      // Future
    case thermalInsulation    // Future
    case electricalInfrared   // Future
    case solarPanelArray      // Future
}

struct RoofCandidate {
    var id: CandidateID
    var timestamp: Timestamp
    var position: Position
    var roofZone: RoofZone
    var imageRefs: [ImageReference]
    var mlConfidence: Double  // Preserved for audit
    var severityBand: SeverityBand
    var proposalReason: String
}

struct RoofAnomaly {
    var candidateID: CandidateID
    var flaggedAt: Timestamp
    var approvedBy: OperatorID
    var operatorNotes: String?
    var candidate: RoofCandidate  // Immutable original
}

enum RoofZone {
    case field          // Main flat/pitched areas
    case edge           // Perimeter/eaves
    case ridge          // Ridge lines
    case valley         // Valley areas
    case penetration    // Vents, chimneys, skylights
}

enum SeverityBand {
    case minor          // Confidence 0.5-0.7, small area
    case moderate       // Confidence 0.7-0.85, medium area
    case significant    // Confidence >0.85, large area
}

struct ClassificationThresholds {
    let minimumConfidence: Double = 0.5
    let highConfidenceThreshold: Double = 0.85
    let moderateConfidenceThreshold: Double = 0.7
    let minAreaPixels: Int = 100
    let maxCandidatesPerZone: Int = 50  // Bounded workload
}
```

---

## ThermalAction Extensions

```swift
enum AppAction {
    case thermal(ThermalAction)
    // ... other actions (flight, mission, etc.)
}

enum ThermalAction {
    // Session management
    case startSession(InspectionType)
    case endSession
    
    // Capture
    case frameCapture(FrameMetadata)
    case updateRoofZone(RoofZone, CaptureStatus)
    
    // ML inference
    case runInference(frameID: FrameID)
    case inferenceCompleted(MLOutput)
    case inferenceFailed(FrameID, Error)
    
    // Candidate management
    case proposeCandidate(RoofCandidate)
    case approveCandidate(CandidateID, notes: String?)
    case rejectCandidate(CandidateID, reason: String)
    
    // Configuration
    case updateThresholds(ClassificationThresholds)
    
    // Export
    case exportDocumentationPack(destination: URL)
    case exportCompleted(ExportResult)
}

struct MLOutput {
    var frameID: FrameID
    var detections: [Detection]
    var modelVersion: String
    var inferenceTime: TimeInterval
}

struct Detection {
    var boundingBox: BoundingBox
    var confidence: Double
    var class: DetectionClass
}

enum DetectionClass {
    case hailDamage
    case wear
    case debris
    case defect
    case moistureIndication  // Thermal secondary
}
```

---

## ThermalLaw Reducer

```swift
struct ThermalReducer {
    
    func reduce(state: ThermalState, 
               action: ThermalAction) -> ThermalState {
        switch action {
            
        case .startSession(let type):
            return ThermalState(
                sessionID: UUIDGenerator.generate(),
                sessionType: type,
                sessionStartTime: Clock.now(),
                mlModel: .initialized,
                thresholds: .default,
                severityBands: .default
            )
            
        case .frameCapture(let metadata):
            var newState = state
            newState.capturedFrames.append(metadata)
            return newState
            
        case .inferenceCompleted(let output):
            // Deterministic classification of probabilistic outputs
            let candidates = classifyCandidates(
                output: output,
                thresholds: state.thresholds,
                existingCandidates: state.proposedCandidates
            )
            
            var newState = state
            newState.proposedCandidates.append(contentsOf: candidates)
            return newState
            
        case .approveCandidate(let id, let notes):
            guard let candidate = state.proposedCandidates.first(
                where: { $0.id == id }
            ) else {
                return state  // Invalid candidate ID
            }
            
            let anomaly = RoofAnomaly(
                candidateID: id,
                flaggedAt: Clock.now(),
                approvedBy: state.currentOperator,
                operatorNotes: notes,
                candidate: candidate
            )
            
            var newState = state
            newState.flaggedAnomalies.append(anomaly)
            return newState
            
        case .rejectCandidate(let id, let reason):
            var newState = state
            newState.proposedCandidates.removeAll { $0.id == id }
            // Rejection logged to audit trail by Orchestrator
            return newState
            
        default:
            return state
        }
    }
    
    // MARK: - Deterministic Classification
    
    static func classifyCandidates(
        output: MLOutput,
        thresholds: ClassificationThresholds,
        existingCandidates: [RoofCandidate]
    ) -> [RoofCandidate] {
        
        var candidates: [RoofCandidate] = []
        
        for detection in output.detections {
            // Threshold filtering (deterministic)
            guard detection.confidence >= thresholds.minimumConfidence else {
                continue
            }
            
            // Area filtering
            let area = detection.boundingBox.area
            guard area >= thresholds.minAreaPixels else {
                continue
            }
            
            // Severity banding (deterministic mapping)
            let severityBand = classifySeverity(
                confidence: detection.confidence,
                area: area,
                thresholds: thresholds
            )
            
            // Roof zone determination (from frame metadata)
            let roofZone = determineRoofZone(
                position: output.frameMetadata.position,
                heading: output.frameMetadata.heading
            )
            
            // Bounded workload: check zone candidate limit
            let zoneCount = existingCandidates.filter { 
                $0.roofZone == roofZone 
            }.count
            
            guard zoneCount < thresholds.maxCandidatesPerZone else {
                continue  // Skip to prevent unbounded queue
            }
            
            let candidate = RoofCandidate(
                id: UUIDGenerator.generate(),
                timestamp: Clock.now(),
                position: output.frameMetadata.position,
                roofZone: roofZone,
                imageRefs: [ImageReference(frameID: output.frameID)],
                mlConfidence: detection.confidence,
                severityBand: severityBand,
                proposalReason: "ML detection: \(detection.class)"
            )
            
            candidates.append(candidate)
        }
        
        return candidates
    }
    
    static func classifySeverity(
        confidence: Double,
        area: Int,
        thresholds: ClassificationThresholds
    ) -> SeverityBand {
        // Deterministic severity mapping
        if confidence >= thresholds.highConfidenceThreshold {
            return .significant
        } else if confidence >= thresholds.moderateConfidenceThreshold {
            return .moderate
        } else {
            return .minor
        }
    }
}
```

---

## ThermalLaw Enforcement

```swift
actor ThermalLawEnforcer {
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
        
        // Step 2: Apply ThermalLaw (if applicable)
        guard case .thermal(let thermalAction) = action else {
            return flightResult  // Not a thermal action
        }
        
        return await evaluateThermalLaw(
            action: thermalAction,
            state: state
        )
    }
    
    private func evaluateThermalLaw(
        action: ThermalAction,
        state: AppState
    ) async -> EnforcementResult {
        
        switch action {
        case .approveCandidate(let id, _):
            // Law 8: Operator approval is explicit authority
            // No additional validation needed
            return .permitted(evaluations: [
                LawEvaluation(
                    law: .authority,
                    result: .compliant,
                    reason: "Operator approval exercised"
                )
            ])
            
        case .proposeCandidate:
            // Agent proposals are always permitted
            // Actual flagging requires approval
            return .permitted(evaluations: [])
            
        case .updateThresholds:
            // Threshold changes require session restart
            if state.thermal.sessionID != nil {
                return .rejected(
                    reason: "Cannot change thresholds during active session",
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

## ML Inference Pipeline

### Onboard Inference Architecture

```
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                 Aircraft Camera Payload                       â”‚
â”‚  â€¢ Wide camera (48MP, RGB)                                   â”‚
â”‚  â€¢ Tele camera (48MP, 7x optical zoom)                       â”‚
â”‚  â€¢ Thermal camera (640Ã—512 â†’ 1280Ã—1024)                      â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                            â”‚
                            â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚              Frame Processing (Edge-First Pipeline)       â”‚
â”‚  â€¢ Image normalization                                       â”‚
â”‚  â€¢ Frame metadata extraction (GPS, timestamp, gimbal)       â”‚
â”‚  â€¢ Inference queue management                                â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                            â”‚
                            â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                   ML Model Inference                         â”‚
â”‚  â€¢ Model: CoreML (iPad GCS) or platform-native inference framework             â”‚
â”‚  â€¢ Input: RGB frame (resized to model dims)                 â”‚
â”‚  â€¢ Output: Bounding boxes + confidence scores               â”‚
â”‚  â€¢ Latency target: <100ms per frame                         â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                            â”‚
                            â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚            Deterministic Post-Processing                     â”‚
â”‚  (ThermalReducer.classifyCandidates)                        â”‚
â”‚  â€¢ Threshold filtering                                       â”‚
â”‚  â€¢ Severity banding                                          â”‚
â”‚  â€¢ Roof zone assignment                                      â”‚
â”‚  â€¢ Bounded candidate queue                                   â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
                            â”‚
                            â–¼
â”Œâ”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”
â”‚                  Candidate Queue (UI)                        â”‚
â”‚  â€¢ Operator review                                           â”‚
â”‚  â€¢ Approve/reject with notes                                 â”‚
â”‚  â€¢ Severity band display                                     â”‚
â””â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”˜
```

### Model Tiers (Phased Development)

**Tier 0: Baseline (Deterministic Candidate Finder)**
- Rule-based edge detection + color analysis
- No ML required
- Validates end-to-end workflow
- Deliverable: March 2026

**Tier 1: Onboard ML (Primary MVP)**
- Lightweight CoreML model (MobileNet-based)
- Trained on hail damage dataset
- Inference on iPad GCS (CoreML)
- Deliverable: April 2026

**Tier 2: Enhanced (Edge Compute)**
- Larger model for higher accuracy
- Higher frame rate processing
- Thermal fusion for moisture detection
- Deliverable: When field testing validates Tier 1 approach

---

## Operator Interface

### Candidate Review Queue

```swift
struct CandidateQueueView: View {
    @ObservedObject var viewModel: CandidateQueueViewModel
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Roof Damage Candidates")
                    .font(.headline)
                Spacer()
                Text("\(viewModel.pendingCount) pending")
                    .foregroundColor(.orange)
            }
            
            // Candidate cards
            ScrollView {
                ForEach(viewModel.candidates) { candidate in
                    CandidateCard(
                        candidate: candidate,
                        onApprove: { notes in
                            viewModel.approve(candidate.id, notes: notes)
                        },
                        onReject: { reason in
                            viewModel.reject(candidate.id, reason: reason)
                        }
                    )
                }
            }
        }
    }
}

struct CandidateCard: View {
    let candidate: RoofCandidate
    let onApprove: (String?) -> Void
    let onReject: (String) -> Void
    
    @State private var showingDetail = false
    @State private var notes = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image crop
            AsyncImage(url: candidate.imageRefs.first?.url) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(height: 200)
            
            // Metadata
            HStack {
                SeverityBadge(band: candidate.severityBand)
                Text(candidate.roofZone.description)
                    .font(.caption)
                Spacer()
                Text("Confidence: \(Int(candidate.mlConfidence * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Proposal reason
            Text(candidate.proposalReason)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Actions
            HStack {
                Button("Reject") {
                    onReject("Not damage")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Approve") {
                    onApprove(notes.isEmpty ? nil : notes)
                }
                .buttonStyle(.borderedProminent)
            }
            
            // Optional notes
            TextField("Notes (optional)", text: $notes)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}
```

---

## Documentation Pack Export

### Export Structure

```
Documentation_Pack_<SessionID>.zip
â”œâ”€â”€ manifest.json              # Session metadata, summary
â”œâ”€â”€ report.pdf                 # Human-readable report
â”œâ”€â”€ flagged_anomalies.json     # Structured data
â”œâ”€â”€ images/
â”‚   â”œâ”€â”€ candidate_001.jpg
â”‚   â”œâ”€â”€ candidate_002.jpg
â”‚   â””â”€â”€ ...
â””â”€â”€ audit/
    â””â”€â”€ session_audit.json     # Complete audit trail
```

### Manifest Schema

```json
{
  "sessionID": "uuid",
  "inspectionType": "postHailRoof",
  "timestamp": "2026-02-05T14:30:00Z",
  "aircraft": {
    "model": "<aircraft_model>",
    "serialNumber": "...",
    "firmware": "..."
  },
  "summary": {
    "totalFramesCaptured": 245,
    "candidatesProposed": 18,
    "anomaliesFlagged": 7,
    "coverageByZone": {
      "field": 0.95,
      "edge": 0.88,
      "ridge": 0.92,
      "valley": 0.75,
      "penetration": 1.0
    }
  },
  "flaggedAnomalies": [
    {
      "id": "uuid",
      "severityBand": "significant",
      "roofZone": "field",
      "position": { "lat": 39.7392, "lon": -104.9903 },
      "imageRefs": ["candidate_001.jpg"],
      "operatorNotes": "Large impact crater, 2-3 inches",
      "mlConfidence": 0.92
    }
  ],
  "modelInfo": {
    "version": "roof-hail-v1.2",
    "framework": "<inference_framework>",
    "inferenceDevice": "<inference_device>"
  }
}
```

---

## Session Replay

### Replay Requirements

**Inputs:**
1. Session audit log
2. Captured frame metadata
3. ML model version
4. Configuration (thresholds, severity bands)

**Outputs (Must Match):**
1. Proposed candidate count
2. Candidate IDs
3. Severity band assignments
4. Flagged anomaly IDs (given same operator approvals)

### Replay Engine

```swift
struct ThermalReplayEngine {
    
    func replay(
        auditLog: AuditLog,
        frames: [FrameMetadata],
        model: MLModel,
        config: ClassificationThresholds
    ) async throws -> ReplayResult {
        
        var replayedState = ThermalState.initial(config: config)
        let reducer = ThermalReducer()
        
        // Verify audit log integrity
        guard auditLog.verify() else {
            throw ReplayError.corruptedAuditLog
        }
        
        // Replay each action
        for entry in auditLog.entries {
            guard let thermalAction = entry.action.asThermalAction else {
                continue
            }
            
            let newState = reducer.reduce(
                state: replayedState,
                action: thermalAction
            )
            
            // Verify determinism
            if entry.thermalStateAfter != newState {
                throw ReplayError.nondeterministicBehavior(
                    action: thermalAction,
                    expected: entry.thermalStateAfter,
                    actual: newState
                )
            }
            
            replayedState = newState
        }
        
        return ReplayResult(
            finalState: replayedState,
            candidatesProposed: replayedState.proposedCandidates.count,
            anomaliesFlagged: replayedState.flaggedAnomalies.count,
            verified: true
        )
    }
}
```

---

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **PX4/MAVLink Aircraft** | Primary | Any RGB + thermal capable platform |
| **iPad Pro (M2+)** | âœ… Primary | Operator interface |
| **Skydio X10** | Likely field platform | U.S.-manufactured, government market |
| **iPhone 15 Pro** | ðŸ“‹ Future | Field companion |

---

## Performance Targets

| Metric | Target | Priority |
|--------|--------|---------------|
| Frame processing | â‰¥10 FPS | Competitive |
| ML inference latency | <100ms | P0 |
| Candidate proposal latency | <500ms | P0 |
| Approval action response | <100ms | P0 |
| Export generation time | <30s | P1 |
| Replay verification time | <session duration / 10 | P1 |

---

## Related Documents

| Document | Purpose |
|----------|---------|
| [Flightworks-Suite-Overview.md](./Flightworks-Suite-Overview.md) | Suite architecture |
| [HLD-FlightworksCore.md](./HLD-FlightworksCore.md) | FlightLaw foundation |
| [PRD-FlightworksThermal.md](./PRD-FlightworksThermal.md) | ThermalLaw requirements |
| [HLD-FlightworksFire.md](./HLD-FlightworksFire.md) | FireLaw jurisdiction (sibling) |
| [HLD-FlightworksISR.md](./HLD-FlightworksISR.md) | ISRLaw jurisdiction (sibling) |
| [HLD-FlightworksSurvey.md](./HLD-FlightworksSurvey.md) | SurveyLaw jurisdiction (sibling) |

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 2.0 | Feb 2026 | S. Sweeney | Strategic update: DJI references removed, platform-agnostic architecture, aligned with five-jurisdiction model |
| 1.0 | Feb 2026 | S. Sweeney | Initial ThermalLaw HLD (DJI Challenge era) |

---

**Document Control**

- **Owner:** Stephen Sweeney, Flightworks Aerial LLC
- **Review Cycle:** Weekly during MVP development
- **Distribution:** Internal, open-source project documentation

---

## Conclusion

Flightworks Thermal (ThermalLaw) extends FlightLaw with domain-specific governance for thermal inspection. The architecture demonstrates that **probabilistic ML outputs can be processed deterministically** while maintaining operator authority and full auditability.

**Key Innovation:** The determinism boundary cleanly separates:
- **Stochastic:** ML model inference
- **Deterministic:** Classification, severity banding, approval workflow, export

This architecture enables:
1. **Reproducibility:** Same session â†’ same candidates â†’ same flags (given same approvals)
2. **Auditability:** Complete decision trail from capture through flagging
3. **Certifiability:** Deterministic processing of non-deterministic inputs
4. **Operator Trust:** AI proposes, operator decides, system enforces

The result is a **governed AI inspection workflow** that is fast, repeatable, and trustworthyâ€”exactly what the post-hail roof assessment market requires.
