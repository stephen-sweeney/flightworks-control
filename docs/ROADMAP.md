# Flightworks Control Roadmap

## Vision

Build an open-source Ground Control Station that demonstrates deterministic AI architecture for safety-critical systems.

## Phases

### Phase 0: Foundation ✅ In Progress

**Timeline:** Weeks 1-2  
**Focus:** Project infrastructure and core SwiftVector patterns

**Deliverables:**
- [ ] Repository structure and documentation
- [ ] Xcode project with SwiftUI app
- [ ] Core State/Action/Reducer protocols
- [ ] FlightState, FlightAction, FlightReducer implementation
- [ ] Orchestrator with action logging
- [ ] Unit tests for reducer determinism
- [ ] CI/CD pipeline (GitHub Actions)

**Success Criteria:**
- Build compiles and runs
- Tests pass
- Architecture documented
- Ready for Phase 1 development

---

### Phase 1: Core Flight Interface

**Timeline:** Weeks 3-6  
**Focus:** Telemetry display and map view

**Deliverables:**
- [ ] MAVLink connection manager
- [ ] Telemetry data stream (Combine)
- [ ] Telemetry display UI (altitude, speed, battery, GPS)
- [ ] Map view with aircraft position
- [ ] State machine visualization
- [ ] Telemetry recording for replay
- [ ] PX4 SITL integration

**Success Criteria:**
- Connect to PX4 SITL
- Display real-time telemetry
- Track aircraft on map
- Record and replay telemetry

---

### Phase 2: Mission Planning

**Timeline:** Weeks 7-10  
**Focus:** Waypoint and geofence functionality

**Deliverables:**
- [ ] Waypoint data model
- [ ] Mission state and actions
- [ ] Tap-to-set waypoint UI
- [ ] Geofence definition
- [ ] Geofence validation
- [ ] Safety interlocks
- [ ] Mission upload to vehicle

**Success Criteria:**
- Plan waypoint missions
- Define geofence boundaries
- Prevent arming on geofence violation
- Upload mission to SITL

**Milestone:** Public GitHub announcement

---

### Phase 3: Autonomy-Aware Enhancements

**Timeline:** Weeks 11-16  
**Focus:** State visualization, battery modeling, traffic

**Deliverables:**
- [ ] State machine visualization UI
- [ ] Battery consumption model
- [ ] Battery reserve warnings
- [ ] Wind estimation integration
- [ ] ADS-B traffic display
- [ ] Deterministic replay system

**Success Criteria:**
- Visualize flight state machine
- Predict battery reserve based on mission
- Display simulated traffic
- Replay any flight exactly

---

### Phase 4: Debrief & Replay

**Timeline:** Weeks 17-20  
**Focus:** Post-flight analysis and audit

**Deliverables:**
- [ ] Flight log data model
- [ ] Flight path replay UI
- [ ] Telemetry graph visualization
- [ ] Mission summary export
- [ ] Action audit trail viewer
- [ ] Decision attribution display

**Success Criteria:**
- Review complete flight path
- Graph telemetry over time
- Export mission reports
- Trace any decision to source

---

### Phase 5: Deterministic Decision Support

**Timeline:** Weeks 21-28  
**Focus:** AI agents within SwiftVector constraints

**Deliverables:**
- [ ] Agent protocol definition
- [ ] Risk assessment agent
- [ ] Risk display UI
- [ ] Route optimization (constrained)
- [ ] Confidence indicator UI
- [ ] Explanation panel
- [ ] Agent testing framework

**Success Criteria:**
- Agents propose within boundaries
- Deterministic recommendations
- Explainable decisions
- Operator retains authority

---

## Future Possibilities

### iOS Companion App
- Subset of functionality for field use
- iPhone/iPad optimized UI

### Multi-Vehicle Support
- Fleet management
- Coordinated missions

### Hardware Integration
- Physical controller support
- External display output

### Advanced AI
- On-device LLM integration (CoreML)
- Natural language mission input

---

## Contributing to the Roadmap

See [CONTRIBUTING.md](../CONTRIBUTING.md) for how to propose changes or new features.

