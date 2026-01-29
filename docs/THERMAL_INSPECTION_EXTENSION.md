# Thermal Inspection Extension

## Deterministic Anomaly Detection for Aerial Thermal Imaging

**Version:** 1.0  
**Date:** January 2026  
**Project:** Flightworks Control GCS  
**Integration:** Flightworks Aerial LLC Inspection Services

---

## Executive Summary

This document specifies the thermal anomaly detection extension for Flightworks Control. The extension demonstrates how probabilistic machine learning outputs can be processed deterministically within the SwiftVector architecture, enabling reliable AI-assisted thermal inspection workflows.

**Key Innovation:** Converting stochastic ML inference into deterministic, auditable decision proposals that preserve operator authority while providing actionable intelligence during inspection flights.

---

## Business Context

### Flightworks Aerial Integration

Flightworks Aerial LLC provides aerial thermal inspection services for:

- **Roof inspections** — Moisture intrusion, insulation defects, membrane failures
- **Electrical infrastructure** — Hotspots in panels, transformers, connections
- **Solar panel arrays** — Cell defects, bypass diode failures, connection issues
- **Building envelope** — Air leakage, thermal bridging, HVAC inefficiencies

The thermal anomaly detection extension transforms Flightworks Control from a general-purpose GCS into a specialized tool that directly supports these commercial services.

### Value Proposition

| Stakeholder | Benefit |
|-------------|---------|
| **Pilot/Operator** | Real-time anomaly alerts reduce missed defects |
| **Inspector** | Automated flagging speeds post-flight analysis |
| **Client** | More comprehensive reports, faster turnaround |
| **Flightworks Aerial** | Differentiated service, higher value delivery |

---

## Technical Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                      Thermal Camera Feed                             │
│                    (FLIR, DJI Thermal, etc.)                        │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Frame Capture & Preprocessing                     │
│              (Normalization, radiometric calibration)               │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Core ML Inference                               │
│                 (On-device, deterministic mode)                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Input: Thermal frame tensor                                 │    │
│  │  Output: Anomaly probability, bounding box, temperature     │    │
│  └─────────────────────────────────────────────────────────────┘    │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│               Deterministic Post-Processing                          │
│                    (SwiftVector Layer)                               │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  • Fixed threshold classification                            │    │
│  │  • Confidence banding                                        │    │
│  │  • Anomaly typing                                            │    │
│  │  • Action proposal generation                                │    │
│  └─────────────────────────────────────────────────────────────┘    │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    ThermalAnomalyAgent                               │
│              (Proposes actions to Orchestrator)                      │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │  Observes: FlightState + ThermalState                        │    │
│  │  Proposes: ThermalAction (flagAnomaly, adjustFlight, etc.)  │    │
│  │  Explains: Human-readable reasoning chain                    │    │
│  └─────────────────────────────────────────────────────────────┘    │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Orchestrator                                    │
│           (Validates proposals, updates state, logs)                │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Operator Interface                                │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────────────┐    │
│  │ Anomaly Alert │  │ Thermal View  │  │  Explanation Panel    │    │
│  │    Banner     │  │   Overlay     │  │  (Why flagged?)       │    │
│  └───────────────┘  └───────────────┘  └───────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

### SwiftVector Integration

The thermal extension follows SwiftVector principles strictly:

| Principle | Implementation |
|-----------|----------------|
| **State is Truth** | `ThermalState` captures current frame analysis |
| **Actions are Proposals** | `ThermalAction` enum for all thermal operations |
| **Reducers are Authority** | `ThermalReducer` validates and applies actions |
| **Agents Propose** | `ThermalAnomalyAgent` observes and recommends |
| **Everything is Auditable** | Full logging of ML outputs and classifications |

---

## Data Models

### ThermalState

```swift
/// Immutable state representing current thermal analysis
struct ThermalState: Equatable, Codable, Sendable {
    /// Current thermal frame metadata (not raw pixels)
    let currentFrame: ThermalFrameMetadata?
    
    /// Most recent ML inference output
    let lastInference: ThermalInferenceResult?
    
    /// Classified anomalies in current frame
    let detectedAnomalies: [ThermalAnomaly]
    
    /// Cumulative anomalies flagged this session
    let sessionAnomalies: [FlaggedAnomaly]
    
    /// Agent status
    let agentStatus: ThermalAgentStatus
    
    /// Timestamp for deterministic replay
    let timestamp: Date
}

struct ThermalFrameMetadata: Equatable, Codable, Sendable {
    let frameId: UUID
    let captureTimestamp: Date
    let cameraModel: String
    let resolution: CGSize
    let temperatureRange: ClosedRange<Double>  // Celsius
    let ambientTemperature: Double?
    let emissivity: Double
    let position: Position?  // GPS position when captured
    let attitude: Attitude?  // Aircraft attitude when captured
}

struct ThermalInferenceResult: Equatable, Codable, Sendable {
    let frameId: UUID
    let inferenceTimestamp: Date
    let modelVersion: String
    let rawOutputs: [ThermalMLOutput]
    let inferenceTimeMs: Double
}

struct ThermalMLOutput: Equatable, Codable, Sendable {
    let anomalyProbability: Double  // 0.0 - 1.0
    let boundingBox: CGRect         // Normalized coordinates
    let peakTemperature: Double     // Celsius
    let meanTemperature: Double     // Celsius within bbox
    let temperatureDelta: Double    // Difference from surroundings
}
```

### ThermalAnomaly

```swift
/// Classified anomaly after deterministic post-processing
struct ThermalAnomaly: Equatable, Codable, Sendable, Identifiable {
    let id: UUID
    let frameId: UUID
    let classification: AnomalyClassification
    let confidence: ConfidenceLevel
    let boundingBox: CGRect
    let temperatures: TemperatureData
    let position: Position?
    let explanation: String
}

enum AnomalyClassification: String, Codable, Sendable, CaseIterable {
    case thermal_hotspot       // Generic elevated temperature
    case moisture_intrusion    // Roof/building moisture pattern
    case insulation_defect     // Missing or damaged insulation
    case electrical_hotspot    // Electrical component overheating
    case solar_cell_defect     // PV cell underperformance
    case air_leakage           // Building envelope breach
    case unknown               // Detected but unclassified
}

enum ConfidenceLevel: String, Codable, Sendable, CaseIterable {
    case high      // >= 0.85 probability
    case medium    // >= 0.70 probability
    case low       // >= 0.50 probability
    case uncertain // < 0.50 (typically not flagged)
}

struct TemperatureData: Equatable, Codable, Sendable {
    let peak: Double
    let mean: Double
    let delta: Double       // Difference from surrounding area
    let ambient: Double?    // Ambient reference if available
}

struct FlaggedAnomaly: Equatable, Codable, Sendable, Identifiable {
    let id: UUID
    let anomaly: ThermalAnomaly
    let flaggedAt: Date
    let operatorConfirmed: Bool?
    let notes: String?
}
```

### ThermalAction

```swift
/// All possible thermal-related state changes
enum ThermalAction: Equatable, Codable, Sendable {
    // Frame processing
    case frameReceived(ThermalFrameMetadata)
    case inferenceCompleted(ThermalInferenceResult)
    
    // Anomaly management
    case anomalyDetected(ThermalAnomaly)
    case anomalyFlagged(anomalyId: UUID)
    case anomalyDismissed(anomalyId: UUID, reason: DismissalReason)
    case anomalyConfirmed(anomalyId: UUID, notes: String?)
    
    // Agent control
    case agentEnabled
    case agentDisabled
    case agentThresholdUpdated(newThreshold: Double)
    
    // Session management
    case sessionStarted(inspectionType: InspectionType)
    case sessionEnded
    case sessionAnomaliesExported(path: URL)
}

enum DismissalReason: String, Codable, Sendable {
    case false_positive
    case duplicate
    case not_relevant
    case operator_override
}

enum InspectionType: String, Codable, Sendable {
    case roof_inspection
    case electrical_inspection
    case solar_inspection
    case building_envelope
    case general
}
```

---

## ThermalReducer

```swift
/// Pure function that applies ThermalActions to ThermalState
struct ThermalReducer {
    
    /// Deterministic state transition
    static func reduce(state: ThermalState, action: ThermalAction) -> ThermalState {
        switch action {
            
        case .frameReceived(let metadata):
            return state.with(
                currentFrame: metadata,
                timestamp: metadata.captureTimestamp
            )
            
        case .inferenceCompleted(let result):
            // Apply deterministic classification to ML outputs
            let anomalies = classifyAnomalies(
                outputs: result.rawOutputs,
                frameId: result.frameId,
                position: state.currentFrame?.position,
                threshold: state.agentStatus.threshold
            )
            return state.with(
                lastInference: result,
                detectedAnomalies: anomalies,
                timestamp: result.inferenceTimestamp
            )
            
        case .anomalyDetected(let anomaly):
            var updated = state.detectedAnomalies
            if !updated.contains(where: { $0.id == anomaly.id }) {
                updated.append(anomaly)
            }
            return state.with(detectedAnomalies: updated)
            
        case .anomalyFlagged(let anomalyId):
            guard let anomaly = state.detectedAnomalies.first(where: { $0.id == anomalyId }) else {
                return state // Invalid action, no change
            }
            let flagged = FlaggedAnomaly(
                id: UUID(),
                anomaly: anomaly,
                flaggedAt: Date(),
                operatorConfirmed: nil,
                notes: nil
            )
            return state.with(
                sessionAnomalies: state.sessionAnomalies + [flagged]
            )
            
        case .anomalyDismissed(let anomalyId, _):
            return state.with(
                detectedAnomalies: state.detectedAnomalies.filter { $0.id != anomalyId }
            )
            
        case .anomalyConfirmed(let anomalyId, let notes):
            var updated = state.sessionAnomalies
            if let index = updated.firstIndex(where: { $0.anomaly.id == anomalyId }) {
                updated[index] = updated[index].with(
                    operatorConfirmed: true,
                    notes: notes
                )
            }
            return state.with(sessionAnomalies: updated)
            
        case .agentEnabled:
            return state.with(agentStatus: state.agentStatus.with(enabled: true))
            
        case .agentDisabled:
            return state.with(agentStatus: state.agentStatus.with(enabled: false))
            
        case .agentThresholdUpdated(let newThreshold):
            return state.with(
                agentStatus: state.agentStatus.with(threshold: newThreshold)
            )
            
        case .sessionStarted(let inspectionType):
            return ThermalState(
                currentFrame: nil,
                lastInference: nil,
                detectedAnomalies: [],
                sessionAnomalies: [],
                agentStatus: ThermalAgentStatus(
                    enabled: true,
                    threshold: defaultThreshold(for: inspectionType),
                    inspectionType: inspectionType
                ),
                timestamp: Date()
            )
            
        case .sessionEnded:
            return state.with(
                agentStatus: state.agentStatus.with(enabled: false)
            )
            
        case .sessionAnomaliesExported:
            return state // Export is a side effect, state unchanged
        }
    }
    
    // MARK: - Deterministic Classification
    
    /// Converts probabilistic ML outputs to discrete classifications
    /// This is the critical determinism boundary
    private static func classifyAnomalies(
        outputs: [ThermalMLOutput],
        frameId: UUID,
        position: Position?,
        threshold: Double
    ) -> [ThermalAnomaly] {
        
        outputs.compactMap { output in
            // Deterministic threshold check
            guard output.anomalyProbability >= threshold else {
                return nil
            }
            
            let confidence = classifyConfidence(probability: output.anomalyProbability)
            let classification = classifyType(
                temperature: output.peakTemperature,
                delta: output.temperatureDelta
            )
            
            return ThermalAnomaly(
                id: UUID(),
                frameId: frameId,
                classification: classification,
                confidence: confidence,
                boundingBox: output.boundingBox,
                temperatures: TemperatureData(
                    peak: output.peakTemperature,
                    mean: output.meanTemperature,
                    delta: output.temperatureDelta,
                    ambient: nil
                ),
                position: position,
                explanation: generateExplanation(
                    classification: classification,
                    confidence: confidence,
                    temperatures: output
                )
            )
        }
    }
    
    /// Deterministic confidence banding
    private static func classifyConfidence(probability: Double) -> ConfidenceLevel {
        switch probability {
        case 0.85...:  return .high
        case 0.70..<0.85: return .medium
        case 0.50..<0.70: return .low
        default: return .uncertain
        }
    }
    
    /// Deterministic type classification based on temperature characteristics
    private static func classifyType(
        temperature: Double,
        delta: Double
    ) -> AnomalyClassification {
        // Simple heuristic classification
        // In production, this could use additional ML or rule engine
        switch (temperature, delta) {
        case (80..., 30...):
            return .electrical_hotspot
        case (40..., 10...):
            return .insulation_defect
        case (..<30, 5...):
            return .moisture_intrusion
        default:
            return .thermal_hotspot
        }
    }
    
    /// Generate human-readable explanation
    private static func generateExplanation(
        classification: AnomalyClassification,
        confidence: ConfidenceLevel,
        temperatures: ThermalMLOutput
    ) -> String {
        let confidenceText = switch confidence {
        case .high: "High confidence"
        case .medium: "Medium confidence"
        case .low: "Low confidence"
        case .uncertain: "Uncertain"
        }
        
        let typeText = switch classification {
        case .electrical_hotspot:
            "electrical hotspot detected"
        case .moisture_intrusion:
            "potential moisture intrusion pattern"
        case .insulation_defect:
            "possible insulation defect"
        case .solar_cell_defect:
            "solar cell anomaly"
        case .air_leakage:
            "air leakage indicator"
        case .thermal_hotspot:
            "thermal anomaly"
        case .unknown:
            "unclassified anomaly"
        }
        
        return "\(confidenceText) \(typeText). " +
               "Peak temp: \(String(format: "%.1f", temperatures.peakTemperature))°C, " +
               "Delta: +\(String(format: "%.1f", temperatures.temperatureDelta))°C above surroundings."
    }
    
    /// Default threshold by inspection type
    private static func defaultThreshold(for type: InspectionType) -> Double {
        switch type {
        case .electrical_inspection: return 0.60  // More sensitive
        case .roof_inspection: return 0.70
        case .solar_inspection: return 0.65
        case .building_envelope: return 0.70
        case .general: return 0.70
        }
    }
}
```

---

## ThermalAnomalyAgent

```swift
/// Agent that observes thermal state and proposes actions
actor ThermalAnomalyAgent: Agent {
    
    private var currentState: ThermalState?
    private var flightState: FlightState?
    
    // MARK: - Agent Protocol
    
    func observe(state: FlightState) async {
        self.flightState = state
        // ThermalState would be part of or linked to FlightState
        self.currentState = state.thermalState
    }
    
    func propose() async -> [any Action] {
        guard let thermal = currentState,
              thermal.agentStatus.enabled else {
            return []
        }
        
        var proposals: [ThermalAction] = []
        
        // Propose flagging high-confidence anomalies
        for anomaly in thermal.detectedAnomalies {
            if anomaly.confidence == .high {
                // Check if not already flagged
                let alreadyFlagged = thermal.sessionAnomalies.contains {
                    $0.anomaly.id == anomaly.id
                }
                if !alreadyFlagged {
                    proposals.append(.anomalyFlagged(anomalyId: anomaly.id))
                }
            }
        }
        
        return proposals
    }
    
    // MARK: - Assessment
    
    func currentAssessment() async -> ThermalAssessment {
        guard let thermal = currentState else {
            return ThermalAssessment.inactive
        }
        
        let anomalyCount = thermal.detectedAnomalies.count
        let highConfidenceCount = thermal.detectedAnomalies.filter { 
            $0.confidence == .high 
        }.count
        
        return ThermalAssessment(
            status: thermal.agentStatus.enabled ? .active : .inactive,
            currentFrameAnomalies: anomalyCount,
            highConfidenceAnomalies: highConfidenceCount,
            sessionTotalFlagged: thermal.sessionAnomalies.count,
            explanation: generateAssessmentExplanation(
                anomalyCount: anomalyCount,
                highConfidence: highConfidenceCount
            ),
            confidence: calculateOverallConfidence(thermal.detectedAnomalies)
        )
    }
    
    // MARK: - Private Helpers
    
    private func generateAssessmentExplanation(
        anomalyCount: Int,
        highConfidence: Int
    ) -> String {
        if anomalyCount == 0 {
            return "No thermal anomalies detected in current frame."
        } else if highConfidence > 0 {
            return "Detected \(anomalyCount) potential anomalies, " +
                   "\(highConfidence) with high confidence requiring attention."
        } else {
            return "Detected \(anomalyCount) potential anomalies, " +
                   "none meeting high confidence threshold."
        }
    }
    
    private func calculateOverallConfidence(
        _ anomalies: [ThermalAnomaly]
    ) -> Double {
        guard !anomalies.isEmpty else { return 1.0 }
        
        // Return highest confidence among detected anomalies
        let maxConfidence = anomalies.map { anomaly in
            switch anomaly.confidence {
            case .high: return 0.90
            case .medium: return 0.75
            case .low: return 0.60
            case .uncertain: return 0.40
            }
        }.max() ?? 0.0
        
        return maxConfidence
    }
}

struct ThermalAssessment: Equatable, Sendable {
    enum Status: String, Sendable {
        case active
        case inactive
        case error
    }
    
    let status: Status
    let currentFrameAnomalies: Int
    let highConfidenceAnomalies: Int
    let sessionTotalFlagged: Int
    let explanation: String
    let confidence: Double
    
    static let inactive = ThermalAssessment(
        status: .inactive,
        currentFrameAnomalies: 0,
        highConfidenceAnomalies: 0,
        sessionTotalFlagged: 0,
        explanation: "Thermal anomaly detection is not active.",
        confidence: 1.0
    )
}
```

---

## User Interface Components

### Anomaly Alert Banner

```swift
struct AnomalyAlertBanner: View {
    let anomaly: ThermalAnomaly
    let onFlag: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Severity indicator
            Circle()
                .fill(severityColor)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(anomaly.classification.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(anomaly.explanation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Confidence badge
            ConfidenceBadge(level: anomaly.confidence)
            
            // Action buttons
            Button(action: onFlag) {
                Image(systemName: "flag.fill")
                    .foregroundColor(.orange)
            }
            .buttonStyle(.bordered)
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(alertBackground)
        .cornerRadius(12)
    }
    
    private var severityColor: Color {
        switch anomaly.confidence {
        case .high: return .red
        case .medium: return .orange
        case .low: return .yellow
        case .uncertain: return .gray
        }
    }
    
    private var alertBackground: Color {
        switch anomaly.confidence {
        case .high: return Color.red.opacity(0.1)
        case .medium: return Color.orange.opacity(0.1)
        case .low: return Color.yellow.opacity(0.1)
        case .uncertain: return Color.gray.opacity(0.1)
        }
    }
}
```

### Thermal Overlay View

```swift
struct ThermalOverlayView: View {
    let anomalies: [ThermalAnomaly]
    let frameSize: CGSize
    let onAnomalyTapped: (ThermalAnomaly) -> Void
    
    var body: some View {
        ZStack {
            ForEach(anomalies) { anomaly in
                AnomalyBoundingBox(
                    anomaly: anomaly,
                    frameSize: frameSize
                )
                .onTapGesture {
                    onAnomalyTapped(anomaly)
                }
            }
        }
    }
}

struct AnomalyBoundingBox: View {
    let anomaly: ThermalAnomaly
    let frameSize: CGSize
    
    var body: some View {
        let rect = denormalizedRect
        
        Rectangle()
            .stroke(borderColor, lineWidth: 2)
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
            .overlay(
                Text(anomaly.classification.shortName)
                    .font(.caption2)
                    .padding(4)
                    .background(borderColor.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .position(x: rect.minX + 30, y: rect.minY - 10)
            )
    }
    
    private var denormalizedRect: CGRect {
        CGRect(
            x: anomaly.boundingBox.origin.x * frameSize.width,
            y: anomaly.boundingBox.origin.y * frameSize.height,
            width: anomaly.boundingBox.width * frameSize.width,
            height: anomaly.boundingBox.height * frameSize.height
        )
    }
    
    private var borderColor: Color {
        switch anomaly.confidence {
        case .high: return .red
        case .medium: return .orange
        case .low: return .yellow
        case .uncertain: return .gray
        }
    }
}
```

### Explanation Panel

```swift
struct ThermalExplanationPanel: View {
    let assessment: ThermalAssessment
    let selectedAnomaly: ThermalAnomaly?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "thermometer.sun.fill")
                    .foregroundColor(.orange)
                Text("Thermal Analysis")
                    .font(.headline)
                Spacer()
                StatusIndicator(status: assessment.status)
            }
            
            Divider()
            
            // Session summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Session Summary")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    StatBox(
                        title: "Current Frame",
                        value: "\(assessment.currentFrameAnomalies)",
                        subtitle: "anomalies"
                    )
                    StatBox(
                        title: "High Confidence",
                        value: "\(assessment.highConfidenceAnomalies)",
                        subtitle: "require review"
                    )
                    StatBox(
                        title: "Session Total",
                        value: "\(assessment.sessionTotalFlagged)",
                        subtitle: "flagged"
                    )
                }
            }
            
            Divider()
            
            // Explanation
            VStack(alignment: .leading, spacing: 8) {
                Text("Analysis")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(assessment.explanation)
                    .font(.body)
            }
            
            // Selected anomaly details
            if let anomaly = selectedAnomaly {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Selected Anomaly")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    AnomalyDetailView(anomaly: anomaly)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
```

---

## ML Model Specification

### Model Requirements

| Requirement | Specification |
|-------------|---------------|
| Framework | Core ML |
| Input | 640x480 thermal tensor (normalized) |
| Output | Anomaly detections with probabilities |
| Inference Time | < 50ms on Apple Silicon |
| Determinism | Must use CPU or ANE (avoid GPU non-determinism) |

### Determinism Configuration

```swift
/// Core ML configuration for deterministic inference
func createDeterministicMLConfig() -> MLModelConfiguration {
    let config = MLModelConfiguration()
    
    // Force CPU or ANE for determinism
    // GPU can introduce non-determinism due to parallel execution
    config.computeUnits = .cpuAndNeuralEngine
    
    return config
}

/// Wrapper ensuring deterministic ML inference
actor DeterministicThermalModel {
    private let model: ThermalAnomalyDetector
    
    init() throws {
        let config = createDeterministicMLConfig()
        self.model = try ThermalAnomalyDetector(configuration: config)
    }
    
    func infer(frame: CVPixelBuffer) async throws -> [ThermalMLOutput] {
        // Normalize input deterministically
        let normalized = normalizeFrame(frame)
        
        // Run inference
        let prediction = try model.prediction(input: normalized)
        
        // Convert to typed output
        return parseOutputs(prediction)
    }
    
    private func normalizeFrame(_ frame: CVPixelBuffer) -> ThermalAnomalyDetectorInput {
        // Deterministic normalization
        // ... implementation
    }
    
    private func parseOutputs(_ prediction: ThermalAnomalyDetectorOutput) -> [ThermalMLOutput] {
        // Deterministic output parsing
        // ... implementation
    }
}
```

---

## Testing Requirements

### Determinism Tests

```swift
final class ThermalDeterminismTests: XCTestCase {
    
    func testClassificationDeterminism() {
        let outputs = generateRandomMLOutputs(count: 1000)
        
        for output in outputs {
            let result1 = ThermalReducer.classifyAnomalies(
                outputs: [output],
                frameId: UUID(),
                position: nil,
                threshold: 0.7
            )
            let result2 = ThermalReducer.classifyAnomalies(
                outputs: [output],
                frameId: UUID(),
                position: nil,
                threshold: 0.7
            )
            
            // Classification must be identical
            XCTAssertEqual(result1.map(\.classification), result2.map(\.classification))
            XCTAssertEqual(result1.map(\.confidence), result2.map(\.confidence))
        }
    }
    
    func testThresholdBoundaryBehavior() {
        let threshold = 0.7
        
        // Exactly at threshold
        let atThreshold = ThermalMLOutput(
            anomalyProbability: 0.7,
            boundingBox: .zero,
            peakTemperature: 50,
            meanTemperature: 45,
            temperatureDelta: 10
        )
        
        // Just below threshold
        let belowThreshold = ThermalMLOutput(
            anomalyProbability: 0.6999999,
            boundingBox: .zero,
            peakTemperature: 50,
            meanTemperature: 45,
            temperatureDelta: 10
        )
        
        let atResult = ThermalReducer.classifyAnomalies(
            outputs: [atThreshold],
            frameId: UUID(),
            position: nil,
            threshold: threshold
        )
        
        let belowResult = ThermalReducer.classifyAnomalies(
            outputs: [belowThreshold],
            frameId: UUID(),
            position: nil,
            threshold: threshold
        )
        
        // At threshold should be classified
        XCTAssertEqual(atResult.count, 1)
        
        // Below threshold should not be classified
        XCTAssertEqual(belowResult.count, 0)
        
        // Verify consistency over 100 iterations
        for _ in 0..<100 {
            let atResult2 = ThermalReducer.classifyAnomalies(
                outputs: [atThreshold],
                frameId: UUID(),
                position: nil,
                threshold: threshold
            )
            XCTAssertEqual(atResult.count, atResult2.count)
        }
    }
}
```

### Integration Tests

```swift
final class ThermalIntegrationTests: XCTestCase {
    
    func testFullPipeline() async throws {
        let orchestrator = FlightOrchestrator()
        let agent = ThermalAnomalyAgent()
        
        // Start thermal session
        orchestrator.dispatch(.thermal(.sessionStarted(inspectionType: .roof_inspection)))
        
        // Simulate frame received
        let frameMetadata = ThermalFrameMetadata.mock()
        orchestrator.dispatch(.thermal(.frameReceived(frameMetadata)))
        
        // Simulate inference completed with anomaly
        let inferenceResult = ThermalInferenceResult.mockWithAnomaly()
        orchestrator.dispatch(.thermal(.inferenceCompleted(inferenceResult)))
        
        // Verify anomaly detected
        XCTAssertFalse(orchestrator.state.thermalState.detectedAnomalies.isEmpty)
        
        // Agent should propose flagging
        await agent.observe(state: orchestrator.state)
        let proposals = await agent.propose()
        
        XCTAssertFalse(proposals.isEmpty)
    }
}
```

---

## Deployment Considerations

### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Device | iPad Pro (M1) | iPad Pro (M2+) |
| RAM | 8 GB | 16 GB |
| Thermal Camera | FLIR One Pro | DJI Zenmuse H20T |

### Performance Targets

| Metric | Target |
|--------|--------|
| Frame Processing Rate | 10 fps |
| ML Inference Latency | < 50ms |
| UI Update Latency | < 16ms |
| Memory Usage | < 500 MB |

---

## Future Enhancements

### Phase 5+ Roadmap

1. **Custom Model Training** — Train on Flightworks Aerial inspection data
2. **Multi-Frame Tracking** — Track anomalies across frames for confirmation
3. **Automated Report Generation** — Generate inspection reports from flagged anomalies
4. **Historical Comparison** — Compare current inspection to previous visits
5. **Cloud Sync (Optional)** — Sync flagged anomalies for team review

---

## Related Documentation

- [ROADMAP.md](../ROADMAP.md) — Product roadmap
- [ARCHITECTURE.md](../ARCHITECTURE.md) — System design
- [TESTING_STRATEGY.md](TESTING_STRATEGY.md) — Testing approach
- [SWIFTVECTOR.md](../SWIFTVECTOR.md) — SwiftVector principles
