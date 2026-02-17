# Flightworks Control: Development Plan

## AI-Assisted Development with Human-in-Command Discipline

**Version:** 3.0  
**Date:** February 2026  
**Project:** Flightworks Control GCS  
**Methodology:** SwiftVector + Agency Paradox

---

## Executive Summary

This plan outlines the development of Flightworks Control, a Ground Control Station built in Swift/SwiftUI with a Rust Edge Relay for MAVLink transport. The development process itself demonstrates the principles documented in the SwiftVector papers — deterministic architecture, human-in-command governance, and systems languages on the edge.

The project is a two-language stack: Swift for governance and operator interface, Rust for protocol handling and transport-layer audit. Both languages provide compile-time safety, no garbage collection, and deterministic behavior — proving that the SwiftVector thesis is about *principles*, not a single language.

**The meta-opportunity:** The development process is as valuable as the product. Every phase generates technical writing artifacts that promote SwiftVector, validate the Agency Paradox methodology, and build professional portfolio value. The addition of Rust expands the writing surface to "Systems Languages on the Edge."

---

## Development Philosophy

### Practicing What We Preach

The SwiftVector papers describe how to build reliable AI systems. Flightworks Control builds one — using AI assistance — while documenting how the principles hold up in practice.

This creates authenticity: "Here's the theory. Here's the system we built using it. Here's what we learned."

### SITL-First Development

All development targets PX4 Software-In-The-Loop simulation. Hardware (Skydio X10 rental) is introduced only after software verification is complete. This:
- Eliminates hardware capital risk
- Enables repeatable test scenarios
- Produces deterministic replay fixtures
- Allows unlimited iteration without flight constraints

### The AI-Assisted Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                  You (Agent in Command)                         │
│         Architecture • Safety • Scope • Authority               │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
      ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
      │   Claude    │ │   Cursor    │ │   Xcode /   │
      │  (Strategy  │ │  (Code Gen  │ │  Rust       │
      │  & Review)  │ │  & Refactor)│ │  Analyzer   │
      └─────────────┘ └─────────────┘ └─────────────┘
              │               │               │
              └───────────────┼───────────────┘
                              ▼
      ┌─────────────────────────────────────────────────────────┐
      │              Verification Loop                           │
      │    Spec → Test → Implement → Verify → Review            │
      └─────────────────────────────────────────────────────────┘
                              │
                              ▼
      ┌─────────────────────────────────────────────────────────┐
      │              Deterministic Codebase                      │
      │         Auditable • Testable • Replayable               │
      └─────────────────────────────────────────────────────────┘
```

### Tool Roles

| Tool | Primary Use | Agency Paradox Role |
|------|-------------|---------------------|
| **Claude** | Architecture decisions, code review, documentation, strategic planning | Strategic advisor — proposes, you decide |
| **Cursor** | Code generation (Swift & Rust), refactoring, test writing, boilerplate | Labor execution within defined scope |
| **Xcode Intelligence** | Swift inline completion, quick fixes, API discovery | Tactical assistance during Swift implementation |
| **Rust Analyzer** | Rust inline completion, borrow checker guidance, type resolution | Tactical assistance during Rust implementation |
| **cargo clippy** | Rust linting and idiom enforcement | Automated quality gate |
| **You** | Specification, architecture authority, safety review, final approval | Pilot in Command — always |

### AI Tool Usage for Rust (Agency Paradox Discipline)

The same governance principles apply to Rust development, with one critical addition: **ownership, borrowing, and lifetimes must be understood, not delegated.** These are the *point* of using Rust.

**Use AI for:**
- Explaining compiler errors after you've read and thought about them
- Checking whether your approach is idiomatic (after you've written the code)
- Generating test fixture data (known-good MAVLink frame bytes)
- Boilerplate (Cargo.toml dependencies, CI workflow YAML)

**Do not use AI for:**
- Writing MAVLink decode functions (you need to understand byte manipulation)
- "Fixing" borrow checker errors without understanding them (the error IS the lesson)
- Ownership-related code patterns (write them wrong, understand, then fix)

---

## Requirements Traceability

All development tasks derive from:
- [PRD-FlightworksCore.md](docs/PRD-FlightworksCore.md) — What to build (FlightLaw)
- [HLD-FlightworksCore.md](docs/HLD-FlightworksCore.md) — How to build it (FlightLaw)
- [ROADMAP.md](ROADMAP.md) — Phase structure and success criteria
- [RUST_LEARNING_PLAN.md](RUST_LEARNING_PLAN.md) — Edge Relay development guide

Future jurisdiction development will trace to:
- PRD/HLD-FlightworksThermal.md (ThermalLaw)
- PRD/HLD-FlightworksSurvey.md (SurveyLaw)

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
│   ├── SwiftVector-Codex.md
│   ├── Flightworks-Suite-Overview.md
│   ├── HLD-FlightworksCore.md
│   ├── PRD-FlightworksCore.md
│   ├── HLD-FlightworksThermal.md    ← Future jurisdiction
│   ├── PRD-FlightworksThermal.md    ← Future jurisdiction
│   ├── HLD-FlightworksSurvey.md     ← Future jurisdiction
│   ├── PRD-FlightworksSurvey.md     ← Future jurisdiction
│   └── articles/                    ← Technical writing outputs
│       ├── 01-building-deterministic-gcs.md
│       ├── 02-systems-languages-on-the-edge.md
│       └── ...
│
├── FlightworksControl/              ← Swift/SwiftUI application (iPad)
│   ├── App/
│   │   └── FlightworksControlApp.swift
│   │
│   ├── Core/                        ← SwiftVector implementation
│   │   ├── State/
│   │   │   ├── FlightState.swift
│   │   │   ├── MissionState.swift
│   │   │   └── SystemState.swift
│   │   ├── Actions/
│   │   │   ├── FlightAction.swift
│   │   │   ├── MissionAction.swift
│   │   │   └── Action.swift
│   │   ├── Reducers/
│   │   │   ├── FlightReducer.swift
│   │   │   ├── MissionReducer.swift
│   │   │   └── Reducer.swift
│   │   └── Orchestrator/
│   │       └── FlightOrchestrator.swift
│   │
│   ├── Telemetry/                   ← Relay integration
│   │   ├── RelayConnection.swift    ← UDP client receiving from Edge Relay
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
│   └── Agents/                      ← AI decision support (future)
│       └── AgentProtocol.swift
│
├── FlightworksControlTests/
│   ├── Core/
│   │   ├── ReducerDeterminismTests.swift
│   │   ├── StateTests.swift
│   │   └── OrchestratorTests.swift
│   ├── Safety/
│   │   ├── ValidatorTests.swift
│   │   └── InterlockTests.swift
│   └── Integration/
│       ├── ControlLoopTests.swift
│       └── CrossLanguageDeterminismTests.swift
│
├── Tools/
│   ├── EdgeRelay/                   ← Rust MAVLink relay
│   │   ├── Cargo.toml
│   │   ├── README.md
│   │   ├── src/
│   │   │   ├── main.rs
│   │   │   ├── relay.rs            ← UDP forwarding core
│   │   │   ├── mavlink.rs          ← MAVLink v2 header decode
│   │   │   ├── allowlist.rs        ← Message ID filtering
│   │   │   ├── audit.rs            ← JSONL audit logger
│   │   │   ├── recorder.rs         ← Binary frame recording
│   │   │   └── replay.rs           ← Deterministic playback
│   │   ├── tests/
│   │   │   ├── decode_tests.rs
│   │   │   ├── replay_tests.rs
│   │   │   └── fixtures/           ← Golden MAVLink recordings
│   │   └── docs/
│   │       └── INTEGRATION_NOTES.md
│   │
│   ├── PX4-SITL/                    ← Simulation setup
│   │   └── sitl-quickstart.sh
│   └── Scripts/
│       └── full-pipeline.sh         ← PX4 SITL → Relay → GCS one-command launch
│
└── .github/
    └── workflows/
        ├── swift-ci.yml             ← Xcode build + test
        └── rust-ci.yml              ← cargo fmt, clippy, test, build
```

---

## Phase Implementation Details

### Phase 0: FlightLaw Foundation (Swift)

**Objective:** Establish core SwiftVector patterns and FlightLaw safety kernel

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
| Implement AuditTrail (SHA256 hash chain) | Claude + Cursor | Verify tamper-evidence | AuditTrail.swift |
| Write reducer determinism tests | Cursor | Define test cases | ReducerDeterminismTests.swift |
| Set up Swift CI (GitHub Actions) | Cursor | Specify pipeline | swift-ci.yml |
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

### Phase 1: Edge Relay (Rust, parallel with Phase 0)

**Objective:** Build the Rust MAVLink proxy with transport-layer audit

See [RUST_LEARNING_PLAN.md](RUST_LEARNING_PLAN.md) for detailed weekly build targets. The learning plan IS the implementation plan — each week produces a working increment.

#### Task Breakdown

| Task | AI Tool | Your Role | Output |
|------|---------|-----------|--------|
| Echo relay (synchronous UDP) | **You only** | Write from scratch — no AI | echo-relay binary |
| Async migration (tokio) | Cursor (syntax only) | Understand async ownership | relay.rs |
| MAVLink v2 header decode | **You only** | Understand byte manipulation | mavlink.rs |
| Allowlist filter | Cursor | Specify message IDs | allowlist.rs |
| JSONL audit logger (serde) | Cursor (boilerplate) | Verify serialization correctness | audit.rs |
| Binary frame recorder | **You only** | Understand endianness, Write trait | recorder.rs |
| Replay engine | Cursor | Verify timing accuracy | replay.rs |
| CLI interface (clap) | Cursor | Specify CLI contract | main.rs |
| Determinism integration test | **You only** | This IS the SwiftVector proof | replay_tests.rs |
| Rust CI (GitHub Actions) | Cursor | Specify pipeline | rust-ci.yml |

**Key principle:** The echo relay (Week 1) and MAVLink decode (Week 2) are written without AI assistance. These are where Rust's ownership model is learned. The borrow checker errors are the curriculum.

---

### Phase 2: Telemetry Integration (Swift + Rust)

**Objective:** Connect FlightLaw to Edge Relay — live telemetry pipeline

#### Task Breakdown

| Task | AI Tool | Your Role | Output |
|------|---------|-----------|--------|
| Design DroneConnectionManager state machine | Claude | Approve state diagram | Connection design doc |
| Implement RelayConnection (UDP client) | Cursor | Review error handling | RelayConnection.swift |
| MAVLink → FlightAction mapping | Claude + Cursor | Define mapping rules | TelemetryMapper.swift |
| Implement TelemetryStream (Combine) | Cursor | Verify backpressure handling | TelemetryStream.swift |
| Basic telemetry display UI | Cursor + Xcode | Specify layout | TelemetryDisplay.swift |
| Basic map with aircraft position | Cursor | Specify interactions | FlightMapView.swift |
| Cross-language determinism test | **You** | This proves the thesis | CrossLanguageDeterminismTests.swift |
| PX4 SITL quickstart script | Cursor | Specify pipeline | sitl-quickstart.sh |
| Full pipeline launch script | Cursor | Specify orchestration | full-pipeline.sh |

#### Cross-Language Determinism Test Specification

```markdown
## Specification: CrossLanguageDeterminismTest

### Purpose
Prove that the same MAVLink recording produces identical audit trails
from both the Rust Edge Relay and the Swift GCS.

### Procedure
1. Record a MAVLink session through the Rust relay (golden fixture)
2. Replay through Rust relay → compare audit trail to original
3. Feed same frames to Swift telemetry mapper → compare state sequence
4. Assert: Rust audit events correspond 1:1 to Swift state transitions

### Success Criteria
- 100% frame correspondence (no dropped or added frames)
- Audit trail hash chains match across languages
- Timing-independent (determinism, not performance)

### SwiftVector Alignment
This is the architectural proof that deterministic governance
works across a multi-language boundary. It validates the
"systems languages on the edge" thesis.
```

---

### Phase 3: Mission Planning & Safety Validation (Swift)

**Objective:** Waypoint missions with FlightLaw enforcement

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
8. Run full test suite (Swift: xcodebuild test / Rust: cargo test)
9. Commit with clear message

End of Session:
10. Document decisions made
11. Note any deviations from spec
12. Update task tracking in ROADMAP.md
13. Update CHANGELOG.md if significant
14. Write Rust journal entry (if Rust work was done)
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
- Implementing specified functionality (Swift or Rust)
- Writing tests from test case specifications
- Refactoring within defined scope
- Generating boilerplate
- Quick iterations on UI
- Applying patterns consistently across codebase

**Use Xcode Intelligence when:**
- Swift inline completions during coding
- Quick API discovery
- Simple refactors
- Fix-it suggestions

**Use Rust Analyzer / cargo clippy when:**
- Rust inline completions
- Understanding borrow checker suggestions
- Enforcing idiomatic Rust patterns
- Pre-commit quality gate

### Specification Template

Use this for every significant task:

```markdown
## Specification: [Component Name]

### Purpose
[Single sentence describing what this component does]

### Context
[Why this exists, what it connects to]

### Inputs
[What data/state does this receive — be explicit about types]

### Outputs
[What does this produce — be explicit about types]

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
| 1 | Rust on the Edge: Why Two Languages Are Better Than One | agentincommand.ai, Dev.to | End of Phase 1 |
| 1 | Learning Rust from Swift: What Transfers and What Doesn't | Swift Forums, Rust community | Mid-Phase 1 |
| 2 | Cross-Language Determinism: Proving Safety Across the Stack | Dev.to, Hacker News | End of Phase 2 |
| 2 | Human-in-Command: AI-Assisted Development of a GCS | Dev.to, Hacker News | End of Phase 2 |
| 3 | Geofence Validation as Pure Functions | Dev.to, consider IEEE | End of Phase 3 |
| 4 | Deterministic Replay for Safety-Critical Systems | Dev.to, consider IEEE/AIAA | Mid-Phase 4 |
| 4 | SwiftVector in Practice: Systems Languages on the Edge (major paper) | IEEE/AIAA/arXiv | End of Phase 4 |

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
- Blog post on agentincommand.ai (full version)
- Twitter/X thread (key points)
- LinkedIn post (professional angle)
- README section update (if applicable)
- Documentation update
- Potential conference talk abstract

---

## Announcement Strategy

### Pre-Announcement (Phase 0-1)

- Soft mentions in Swift/UAS/Rust communities
- "Working on something interesting" posts
- Rust journal entries as public learning-in-the-open content
- Build anticipation without overpromising

### GitHub Announcement (End of Phase 2)

**Timing:** When project has working telemetry pipeline (Swift + Rust end-to-end)

**README.md should include:**
- Clear project description with architecture diagram
- Two-language stack explanation
- Getting started instructions (PX4 SITL + Relay + GCS)
- Link to SwiftVector papers
- Contribution guidelines

**Announcement venues:**
- Swift Forums, Rust community (users.rust-lang.org)
- r/swift, r/rust, r/drones, r/aerospace
- Hacker News (Show HN)
- LinkedIn, X/Twitter

### agentincommand.ai Integration

- Project page with vision and architecture
- Development blog / updates
- Links to technical articles
- Repository link
- SwiftVector / Agency Paradox / "Systems Languages on the Edge" paper links

---

## Success Metrics

### Technical Quality

| Metric | Target |
|--------|--------|
| Swift test coverage | >80% |
| Rust test coverage | >80% |
| Swift build success rate | >99% |
| Rust clippy warnings | 0 |
| Determinism tests | 100% pass |
| Safety invariant tests | 100% pass |
| Cross-language determinism | 100% correspondence |

### Visibility

| Metric | 6-Month Target |
|--------|----------------|
| Technical articles published | 5+ |
| Conference submissions | 1-2 |
| Community mentions | 20+ |

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
| MAVLink integration complexity | Edge Relay isolates protocol handling; PX4 SITL for testing |
| Rust learning curve | Scoped to well-defined relay; build genuine understanding over speed |
| Performance issues | Profile early; optimize incrementally |
| SwiftUI limitations | Hybrid UIKit where necessary |
| Scope creep | Strict phase boundaries; specification discipline |
| Cross-language integration friction | Clean UDP + JSONL boundary; integration tests early |

### Schedule Risks

| Risk | Mitigation |
|------|------------|
| AI-assisted development slower than expected | Build buffer into estimates; document learnings |
| Unforeseen complexity | Scope reduction for MVP; defer to later phases |
| Drone Command onboarding reduces available time | Flexible timeline; maintain momentum over speed |

### Strategic Risks

| Risk | Mitigation |
|------|------------|
| Drone Command acquires project; open-source status TBD | Architecture remains valuable regardless; maintain clean IP boundaries |
| Project doesn't gain traction | Focus on quality over marketing; let work speak |
| Similar projects emerge | Differentiate on SwiftVector principles and two-language determinism proof |

---

## Summary

Flightworks Control is not just a GCS — it's a demonstration of SwiftVector principles across two systems languages, a validation of Agency Paradox methodology, and a portfolio piece for professional advancement.

The two-language stack (Swift + Rust) strengthens every claim: determinism isn't just a Swift thing — it's a *systems architecture* thing. The boundary between languages becomes the most powerful proof point.

**The virtuous cycle:**

```
Build → Document → Publish → Attract → Fund → Build more
```

Start with Phase 0 and Phase 1 in parallel. Ship something real in both languages. Prove they work together. Write about it. Repeat.

---

## Related Documentation

- [ROADMAP.md](ROADMAP.md) — Product roadmap and phase details
- [ARCHITECTURE.md](ARCHITECTURE.md) — System design
- [TESTING_STRATEGY.md](TESTING_STRATEGY.md) — Verification approach
- [RUST_LEARNING_PLAN.md](RUST_LEARNING_PLAN.md) — Edge Relay Rust development guide
- [SwiftVector-Codex.md](SwiftVector-Codex.md) — Constitutional framework
- [CONTRIBUTING.md](../CONTRIBUTING.md) — Contribution guidelines
