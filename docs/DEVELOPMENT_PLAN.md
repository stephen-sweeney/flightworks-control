# Flightworks Control: Development Plan

## AI-Assisted Development with Human-in-Command Discipline

**Version:** 2.0  
**Date:** January 2026  
**Project:** Flightworks Control GCS  
**Methodology:** SwiftVector + Agency Paradox

---

## Executive Summary

This plan outlines the development of Flightworks Control, an open-source Ground Control Station built in Swift/SwiftUI. The development process itself demonstrates the principles documented in the SwiftVector papers—deterministic architecture, human-in-command governance, and Swift-native edge computing.

**The meta-opportunity:** The development process is as valuable as the product. Every phase generates technical writing artifacts that promote SwiftVector, validate the Agency Paradox methodology, and build academic/professional portfolio value.

---

## Development Philosophy

### Practicing What We Preach

The SwiftVector papers describe how to build reliable AI systems. Flightworks Control builds one—using AI assistance—while documenting how the principles hold up in practice.

This creates authenticity: "Here's the theory. Here's the system we built using it. Here's what we learned."

### The AI-Assisted Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                  You (Agent in Command)                     │
│         Architecture • Safety • Scope • Authority           │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
      ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
      │   Claude    │ │   Cursor    │ │   Xcode     │
      │  (Strategy  │ │  (Code Gen  │ │Intelligence │
      │  & Review)  │ │  & Refactor)│ │  (Inline)   │
      └─────────────┘ └─────────────┘ └─────────────┘
              │               │               │
              └───────────────┼───────────────┘
                              ▼
      ┌─────────────────────────────────────────────────────┐
      │              Verification Loop                       │
      │    Spec → Test → Implement → Verify → Review        │
      └─────────────────────────────────────────────────────┘
                              │
                              ▼
      ┌─────────────────────────────────────────────────────┐
      │              Deterministic Codebase                  │
      │         Auditable • Testable • Replayable           │
      └─────────────────────────────────────────────────────┘
```

### Tool Roles

| Tool | Primary Use | Agency Paradox Role |
|------|-------------|---------------------|
| **Claude** | Architecture decisions, code review, documentation, strategic planning | Strategic advisor—proposes, you decide |
| **Cursor** | Code generation, refactoring, test writing, boilerplate | Labor execution within defined scope |
| **Xcode Intelligence** | Inline completion, quick fixes, API discovery | Tactical assistance during implementation |
| **You** | Specification, architecture authority, safety review, final approval | Pilot in Command—always |

---

## Project Structure

### Repository Organization

```
flightworks-control/
├── README.md
├── CONTRIBUTING.md
├── LICENSE (MIT)
├── CHANGELOG.md
│
├── docs/
│   ├── ROADMAP.md
│   ├── ARCHITECTURE.md
│   ├── SWIFTVECTOR.md
│   ├── DEVELOPMENT_PLAN.md          ← This document
│   ├── TESTING_STRATEGY.md
│   ├── THERMAL_INSPECTION_EXTENSION.md
│   └── articles/                    ← Technical writing outputs
│       ├── 01-building-deterministic-gcs.md
│       ├── 02-realtime-telemetry-swift.md
│       └── ...
│
├── FlightworksControl/              ← Main application
│   ├── App/
│   │   └── FlightworksControlApp.swift
│   │
│   ├── Core/                        ← SwiftVector implementation
│   │   ├── State/
│   │   │   ├── FlightState.swift
│   │   │   ├── MissionState.swift
│   │   │   ├── ThermalState.swift   ← Extension point
│   │   │   └── SystemState.swift
│   │   ├── Actions/
│   │   │   ├── FlightAction.swift
│   │   │   ├── MissionAction.swift
│   │   │   ├── ThermalAction.swift  ← Extension point
│   │   │   └── Action.swift
│   │   ├── Reducers/
│   │   │   ├── FlightReducer.swift
│   │   │   ├── MissionReducer.swift
│   │   │   ├── ThermalReducer.swift ← Extension point
│   │   │   └── Reducer.swift
│   │   └── Orchestrator/
│   │       └── FlightOrchestrator.swift
│   │
│   ├── Telemetry/                   ← MAVLink integration
│   │   ├── MAVLinkConnection.swift
│   │   ├── TelemetryStream.swift
│   │   └── DroneConnectionManager.swift
│   │
│   ├── UI/                          ← SwiftUI views
│   │   ├── Components/
│   │   │   ├── TelemetryDisplay.swift
│   │   │   ├── AircraftPuck.swift
│   │   │   ├── StatusIndicator.swift
│   │   │   └── ActionButton.swift
│   │   ├── Screens/
│   │   │   ├── FlightScreen.swift
│   │   │   ├── MissionPlanningScreen.swift
│   │   │   └── DebriefScreen.swift
│   │   └── Map/
│   │       ├── FlightMapView.swift
│   │       └── MapAnnotations.swift
│   │
│   ├── Safety/                      ← Safety-critical logic
│   │   ├── SafetyValidator.swift
│   │   ├── GeofenceValidator.swift
│   │   ├── BatteryMonitor.swift
│   │   └── StateInterlocks.swift
│   │
│   └── Agents/                      ← AI decision support (Phase 5)
│       ├── AgentProtocol.swift
│       ├── RiskAssessmentAgent.swift
│       ├── BatteryPredictionAgent.swift
│       └── ThermalAnomalyAgent.swift
│
├── FlightworksControlTests/
│   ├── Core/
│   │   ├── ReducerDeterminismTests.swift
│   │   ├── StateTests.swift
│   │   └── OrchestratorTests.swift
│   ├── Safety/
│   │   ├── ValidatorTests.swift
│   │   └── InterlockTests.swift
│   ├── Agents/
│   │   └── AgentDeterminismTests.swift
│   └── Integration/
│       └── ControlLoopTests.swift
│
└── Tools/
    ├── PX4-SITL/                    ← Simulation setup
    └── Scripts/
```

---

## Phase Implementation Details

### Phase 0: Foundation (Current)

**Objective:** Establish project infrastructure and core SwiftVector patterns

#### Task Breakdown

| Task | AI Tool | Your Role | Output |
|------|---------|-----------|--------|
| Create Xcode project with SwiftUI | Cursor | Specify structure, review | Project skeleton |
| Implement base State protocol | Cursor | Define state shape, review | State.swift |
| Implement FlightState | Cursor | Define flight state properties | FlightState.swift |
| Implement Action protocol | Cursor | Define action taxonomy | Action.swift |
| Implement FlightAction enum | Cursor | Specify all action cases | FlightAction.swift |
| Implement Reducer protocol | Claude + Cursor | Specify reducer contract | Reducer.swift |
| Implement FlightReducer | Claude + Cursor | Verify determinism logic | FlightReducer.swift |
| Implement Orchestrator | Claude + Cursor | Architecture review | FlightOrchestrator.swift |
| Add ThermalState stub | Cursor | Define extension point | ThermalState.swift |
| Write reducer determinism tests | Cursor | Define test cases | ReducerDeterminismTests.swift |
| Set up CI/CD (GitHub Actions) | Cursor | Specify pipeline | .github/workflows/ |
| Write CHANGELOG initial entry | You | Document Phase 0 | CHANGELOG.md |

#### Specification Example: FlightReducer

Before engaging AI for implementation:

```markdown
## Specification: FlightReducer

### Purpose
Apply FlightActions to FlightState deterministically.

### Inputs
- Current FlightState (immutable)
- FlightAction to apply

### Outputs
- New FlightState (immutable)

### Constraints
- Pure function: no side effects
- Deterministic: same inputs → same outputs
- Total: handles all action types
- Safe: invalid actions return unchanged state

### Action Types to Handle
- .updateTelemetry(TelemetryData)
- .changeFlightMode(FlightMode)
- .arm
- .disarm
- .takeoff(altitude: Double)
- .land
- .returnToLaunch
- .connectionStatusChanged(ConnectionStatus)

### Invariants to Preserve
- Cannot arm if GPS fix < 3D
- Cannot takeoff if not armed
- Cannot change mode during takeoff/landing sequence
- Battery level only decreases (unless charging state)

### Test Cases Required
- Each action type with valid preconditions → state changes
- Each action type with invalid preconditions → state unchanged
- State machine transition coverage
- Determinism verification: same input pair → identical output
```

**This specification goes to Cursor/Claude before any code is written.**

---

### Phase 1: Core Flight Interface

**Objective:** Implement MVP telemetry display and map view

#### Task Breakdown

| Task | AI Tool | Your Role | Output |
|------|---------|-----------|--------|
| Design MAVLink connection state machine | Claude | Approve state diagram | Connection design doc |
| Implement DroneConnectionManager | Cursor | Review error handling | DroneConnectionManager.swift |
| Design telemetry data model | Claude | Define data shape | TelemetryData design |
| Implement TelemetryStream (Combine) | Cursor | Verify backpressure handling | TelemetryStream.swift |
| Implement TelemetryDisplay UI | Cursor + Xcode | Specify layout, review a11y | TelemetryDisplay.swift |
| Implement FlightMapView | Cursor | Specify interactions | FlightMapView.swift |
| Implement AircraftPuck | Cursor | Specify visual design | AircraftPuck.swift |
| Implement StateIndicator | Cursor | Define state visualizations | StateIndicator.swift |
| Add thermal telemetry placeholder | Cursor | Validate extension point | TelemetryData extension |
| Implement TelemetryRecorder | Cursor | Specify format | TelemetryRecorder.swift |
| PX4 SITL integration testing | You + Cursor | Test scenarios | Integration tests |

#### Key Technical Decisions

**Telemetry Stream Architecture:**
```swift
// Combine-based telemetry with deterministic state updates
telemetryPublisher
    .receive(on: DispatchQueue.main)
    .map { FlightAction.updateTelemetry($0) }
    .sink { [weak orchestrator] action in
        orchestrator?.dispatch(action)
    }
```

**Thermal Extension Point:**
```swift
struct TelemetryData: Equatable, Codable, Sendable {
    let position: Position?
    let attitude: Attitude?
    let battery: BatteryState?
    let gpsInfo: GPSInfo?
    let timestamp: Date
    
    // Phase 5 extension point
    let thermalFrame: ThermalFrameMetadata?
}
```

---

### Phase 2: Mission Planning

**Objective:** Implement waypoint and geofence functionality

#### Task Breakdown

| Task | AI Tool | Your Role | Output |
|------|---------|-----------|--------|
| Design Waypoint data model | Claude | Define structure | Waypoint.swift design |
| Implement MissionState | Cursor | Specify state shape | MissionState.swift |
| Implement MissionAction enum | Cursor | Define action cases | MissionAction.swift |
| Implement MissionReducer | Cursor | Verify determinism | MissionReducer.swift |
| Implement tap-to-set waypoint UI | Cursor + Xcode | Specify UX flow | WaypointEditor.swift |
| Design Geofence data model | Claude | Define polygon representation | Geofence.swift design |
| Implement GeofenceValidator | Cursor | Specify validation rules | GeofenceValidator.swift |
| Implement StateInterlocks | Claude + Cursor | Define interlock logic | StateInterlocks.swift |
| Implement MissionUploader | Cursor | Specify MAVLink commands | MissionUploader.swift |
| Write interlock tests (100% coverage) | Cursor | Define all test cases | InterlockTests.swift |

#### Geofence Validation Specification

```markdown
## Specification: GeofenceValidator

### Purpose
Determine if a position violates geofence boundaries.

### Inputs
- Position (latitude, longitude, altitude)
- Geofence (polygon vertices, min/max altitude)

### Outputs
- ValidationResult: .valid | .violation(reason: String)

### Algorithm
- Point-in-polygon using ray casting (deterministic)
- Altitude bounds check
- No floating-point tolerance issues (use Decimal or fixed precision)

### Constraints
- Pure function: no side effects
- Deterministic: boundary cases handled consistently
- Performance: O(n) where n = polygon vertices

### Test Cases
- Point clearly inside → valid
- Point clearly outside → violation
- Point on vertex → defined behavior (inside)
- Point on edge → defined behavior (inside)
- Altitude below minimum → violation
- Altitude above maximum → violation
- Complex polygon (concave) → correct classification
```

---

## Daily Development Practice

### Workflow

```
Morning:
1. Review previous session's work
2. Identify today's task(s) from phase breakdown
3. Write specification for each task (Agency Paradox discipline)

Development:
4. Create failing test(s) for task
5. Engage AI (Cursor/Claude) with specification
6. Review generated code against spec
7. Iterate until spec is met
8. Run full test suite
9. Commit with clear message

End of Session:
10. Document decisions made
11. Note any deviations from spec
12. Update task tracking in ROADMAP.md
13. Update CHANGELOG.md if significant
```

### When to Use Each Tool

**Use Claude (conversation) when:**
- Designing architecture or data models
- Reviewing code for safety implications
- Discussing tradeoffs and alternatives
- Writing documentation
- Planning technical articles
- Debugging complex issues
- Questioning whether an approach is right

**Use Cursor when:**
- Implementing specified functionality
- Writing tests from test case specifications
- Refactoring within defined scope
- Generating boilerplate
- Quick iterations on UI
- Applying patterns consistently across codebase

**Use Xcode Intelligence when:**
- Inline completions during coding
- Quick API discovery
- Simple refactors
- Fix-it suggestions

### Specification Template

Use this for every significant task:

```markdown
## Specification: [Component Name]

### Purpose
[Single sentence describing what this component does]

### Context
[Why this exists, what it connects to]

### Inputs
[What data/state does this receive - be explicit about types]

### Outputs
[What does this produce - be explicit about types]

### Constraints
- [Non-negotiable requirement 1]
- [Non-negotiable requirement 2]
- ...

### Invariants
[What must remain true before and after]

### Algorithm/Logic
[If applicable, describe the approach]

### Test Cases
1. [Happy path scenario]
2. [Edge case 1]
3. [Edge case 2]
4. [Error/invalid input case]

### Anti-Patterns to Avoid
- [Thing that would be wrong]
- [Other thing that would be wrong]

### SwiftVector Alignment
[How this component adheres to SwiftVector principles]

### Notes
[Anything else relevant]
```

---

## Technical Writing Strategy

### Publication Calendar

| Phase | Article | Target Venue | Timing |
|-------|---------|--------------|--------|
| 0 | Building a Deterministic GCS: SwiftVector Foundation | Dev.to, Medium | End of Phase 0 |
| 1 | Real-Time Telemetry in Swift: Combine for Safety-Critical Data | Swift Forums, iOS Dev Weekly | Mid-Phase 1 |
| 1 | Human-in-Command: AI-Assisted Development of a GCS | Dev.to, Hacker News | End of Phase 1 |
| 2 | Geofence Validation as Pure Functions | Dev.to, consider IEEE | End of Phase 2 |
| 3 | Deterministic Replay for Safety-Critical Systems | Dev.to, consider IEEE/AIAA | Mid-Phase 3 |
| 3 | Battery Reserve Modeling: When AI Meets Physics | UAS publications | End of Phase 3 |
| 4 | Audit Trails for AI-Assisted Systems | IEEE Aerospace consideration | End of Phase 4 |
| 5 | SwiftVector in Practice (major paper) | IEEE/AIAA/arXiv | End of Phase 5 |
| 5 | Edge AI for Thermal Inspection | UAS/Inspection publications | End of Phase 5 |

### Article Template

Each article should follow:

1. **Hook** — Why should the reader care?
2. **Problem** — What challenge are we addressing?
3. **Approach** — How does SwiftVector/Agency Paradox frame the solution?
4. **Implementation** — Show real code from Flightworks Control
5. **Results** — What did we achieve? Metrics if possible
6. **Lessons** — What did we learn? What would we do differently?
7. **Call to Action** — Link to repo, invite contribution, reference papers

### Content Repurposing

Each article generates:
- Blog post (full version)
- Twitter/X thread (key points)
- LinkedIn post (professional angle)
- README section update (if applicable)
- Documentation update
- Potential conference talk abstract

---

## Announcement Strategy

### Pre-Announcement (Phase 0-1)

- Soft mentions in Swift/UAS communities
- "Working on something interesting" posts
- Build anticipation without overpromising

### GitHub Announcement (End of Phase 2)

**Timing:** When project has working mission planning functionality

**README.md should include:**
- Clear project description with screenshots
- Architecture overview with diagram
- Getting started instructions
- Link to SwiftVector papers
- Contribution guidelines

**Announcement venues:**
- Swift Forums
- r/swift, r/drones, r/aerospace
- Hacker News (Show HN)
- LinkedIn
- X/Twitter

### agentincommand.ai Integration

Create project page with:
- Vision and goals
- Development blog/updates
- Links to technical articles
- Repository link
- SwiftVector/Agency Paradox paper links

---

## Success Metrics

### Project Health

| Metric | 6-Month Target | 12-Month Target |
|--------|----------------|-----------------|
| GitHub stars | 100 | 500 |
| Contributors | 3 | 10 |
| Forks | 20 | 100 |
| Open issues (healthy activity) | 10+ | 30+ |
| Documentation coverage | 80% | 95% |

### Technical Quality

| Metric | Target |
|--------|--------|
| Test coverage | >80% |
| Build success rate | >99% |
| Determinism tests | 100% pass |
| Safety invariant tests | 100% pass |

### Visibility

| Metric | 6-Month Target |
|--------|----------------|
| Technical articles published | 5+ |
| Conference submissions | 1-2 |
| Community mentions | 20+ |
| Newsletter features | 2+ |

### Business Development

| Metric | Target |
|--------|--------|
| SBIR topics identified | 3+ |
| University contacts established | 2+ |
| STTR partnership discussions | 1+ |

---

## Risk Mitigation

### Technical Risks

| Risk | Mitigation |
|------|------------|
| MAVSDK-Swift instability | Fallback to direct MAVLink parsing; robust error handling |
| Performance issues | Profile early; optimize incrementally |
| SwiftUI limitations | Hybrid UIKit where necessary |
| Scope creep | Strict phase boundaries; specification discipline |
| Thermal ML integration complexity | Start with simple threshold models; iterate |

### Schedule Risks

| Risk | Mitigation |
|------|------------|
| AI-assisted development slower than expected | Build buffer into estimates; document learnings |
| Unforeseen complexity | Scope reduction for MVP; defer to later phases |
| Parallel commitments (drone acquisition, certs) | Flexible timeline; maintain momentum over speed |

### Visibility Risks

| Risk | Mitigation |
|------|------------|
| Project doesn't gain traction | Focus on quality over marketing; let work speak |
| Criticism of approach | Engage constructively; document limitations honestly |
| Similar projects emerge | Differentiate on SwiftVector principles; collaborate |

---

## Integration with Flightworks Aerial

### Thermal Inspection Synergy

The thermal anomaly detection capability (Phase 5) directly supports Flightworks Aerial's commercial inspection services:

1. **Development validates commercial use case** — Building the agent proves the concept
2. **Commercial use generates training data** — Real inspections improve the model
3. **Open source builds credibility** — Transparency supports enterprise sales
4. **Grant funding potential** — Novel approach attracts SBIR/STTR interest

### Timeline Alignment

| Flightworks Aerial Milestone | GCS Development Phase |
|------------------------------|----------------------|
| Drone acquisition | Phase 0-1 |
| Thermography certification | Phase 1-2 |
| First commercial inspections | Phase 2-3 |
| Thermal anomaly agent development | Phase 5 |
| Integrated thermal inspection workflow | Post-Phase 5 |

---

## Next Steps (This Week)

1. **Finalize documentation suite** — Complete TESTING_STRATEGY.md, THERMAL_INSPECTION_EXTENSION.md
2. **Create GitHub repository** with initial structure
3. **Set up Xcode project** with SwiftUI app target
4. **Implement State/Action/Reducer** protocols (Phase 0 core)
5. **Write first test** for reducer determinism
6. **Draft Article #1** outline ("Building a Deterministic GCS")

---

## Summary

Flightworks Control is not just a GCS—it's a demonstration of SwiftVector principles, a validation of Agency Paradox methodology, and a portfolio piece for academic and professional advancement.

The development process generates technical writing. The technical writing builds visibility. The visibility attracts collaborators and opportunities. The opportunities fund continued development.

**The virtuous cycle:**

```
Build → Document → Publish → Attract → Fund → Build more
```

Start with Phase 0. Ship something real. Write about it. Repeat.

---

## Related Documentation

- [ROADMAP.md](ROADMAP.md) — Product roadmap and phase details
- [ARCHITECTURE.md](ARCHITECTURE.md) — System design
- [TESTING_STRATEGY.md](TESTING_STRATEGY.md) — Verification approach
- [THERMAL_INSPECTION_EXTENSION.md](THERMAL_INSPECTION_EXTENSION.md) — Thermal feature spec
- [CONTRIBUTING.md](../CONTRIBUTING.md) — Contribution guidelines
