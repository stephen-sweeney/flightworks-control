# Flightworks Suite Documentation

**Version:** 2.0.0  
**Last Updated:** February 2026  
**Project Status:** ThermalLaw MVP Development (DJI Challenge 2026)

---

## Welcome

This documentation covers the **Flightworks Suite**, an open-source jurisdiction-based architecture for governed drone operations. **FlightLaw** provides universal safety guarantees, extended by mission-specific jurisdictions (**ThermalLaw**, **SurveyLaw**) built on SwiftVector principles.

Whether you're evaluating the project, contributing code, or learning about jurisdiction-based architecture, you'll find the relevant information organized below.

---

## Quick Links

| I want to... | Go to... |
|--------------|----------|
| Understand the suite architecture | [Flightworks-Suite-Overview.md](Flightworks-Suite-Overview.md) |
| See the development roadmap | [ROADMAP.md](ROADMAP.md) |
| Understand SwiftVector implementation | [ARCHITECTURE.md](ARCHITECTURE.md) |
| Learn about the constitutional framework | [SwiftVector-Codex.md](SwiftVector-Codex.md) |
| Contribute to the project | [CONTRIBUTING.md](../CONTRIBUTING.md) |
| Set up development environment | [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) |
| Understand testing approach | [TESTING_STRATEGY.md](TESTING_STRATEGY.md) |
| See what's changed | [CHANGELOG.md](../CHANGELOG.md) |

---

## Documentation Map

```
flightworks-control/
├── README.md                 ← Suite overview, quick start
├── CONTRIBUTING.md           ← Contribution guidelines
├── CHANGELOG.md              ← Version history
├── LICENSE                   ← MIT License
│
└── docs/
    ├── index.md              ← You are here
    │
    ├── Suite Architecture
    │   ├── Flightworks-Suite-Overview.md     ← Master architecture document
    │   ├── ARCHITECTURE.md                   ← SwiftVector patterns
    │   ├── ROADMAP.md                        ← Development roadmap
    │   └── SwiftVector-Codex.md              ← Constitutional framework
    │
    ├── FlightLaw (Universal Safety Kernel)
    │   ├── HLD-FlightworksCore.md            ← FlightLaw architecture
    │   └── PRD-FlightworksCore.md            ← FlightLaw requirements
    │
    ├── ThermalLaw (Thermal Inspection)
    │   ├── HLD-FlightworksThermal.md         ← ThermalLaw architecture
    │   ├── PRD-FlightworksThermal.md         ← ThermalLaw requirements
    │   └── DJI-Challenge-Submission.md       ← Competition submission
    │
    ├── SurveyLaw (Precision Mapping)
    │   ├── HLD-FlightworksSurvey.md          ← SurveyLaw architecture
    │   └── PRD-FlightworksSurvey.md          ← SurveyLaw requirements
    │
    ├── Development
    │   ├── DEVELOPMENT_PLAN.md               ← AI-assisted workflow
    │   └── TESTING_STRATEGY.md               ← Testing strategy
    │
    └── archive/
        └── v1-monolithic/                    ← Historical documents
            ├── HLD-FlightworksControl.md
            ├── PRD-FlightworksControl.md
            └── THERMAL_INSPECTION_EXTENSION.md
```

---

## Document Overview

### Suite Architecture

| Document | Description | Audience |
|----------|-------------|----------|
| [Flightworks-Suite-Overview.md](Flightworks-Suite-Overview.md) | Master architecture, jurisdiction model | Everyone |
| [ROADMAP.md](ROADMAP.md) | Development roadmap by jurisdiction | Product, Engineering |
| [ARCHITECTURE.md](ARCHITECTURE.md) | SwiftVector implementation patterns | Engineering |
| [SwiftVector-Codex.md](SwiftVector-Codex.md) | Constitutional framework (Laws 0-10) | Engineering, Research |

### FlightLaw (Universal Safety Kernel)

| Document | Description | Audience |
|----------|-------------|----------|
| [HLD-FlightworksCore.md](HLD-FlightworksCore.md) | FlightLaw technical architecture | Engineering |
| [PRD-FlightworksCore.md](PRD-FlightworksCore.md) | FlightLaw requirements specification | Engineering, Product |

**Covers:** Laws 3, 4, 7, 8 • Audit trail • Replay engine • Safety enforcement

### ThermalLaw (Thermal Inspection)

| Document | Description | Audience |
|----------|-------------|----------|
| [HLD-FlightworksThermal.md](HLD-FlightworksThermal.md) | ThermalLaw technical architecture | Engineering |
| [PRD-FlightworksThermal.md](PRD-FlightworksThermal.md) | ThermalLaw requirements specification | Engineering, Product |
| [DJI-Challenge-Submission.md](DJI_Challenge_Submission.md) | DJI Challenge 2026 submission (v0.3) | Competition |

**Covers:** Post-hail roof assessment • RGB detection • Governed AI • ML post-processing • Documentation Pack • Session replay

### SurveyLaw (Precision Mapping)

| Document | Description | Audience |
|----------|-------------|----------|
| [HLD-FlightworksSurvey.md](HLD-FlightworksSurvey.md) | SurveyLaw technical architecture | Engineering |
| [PRD-FlightworksSurvey.md](PRD-FlightworksSurvey.md) | SurveyLaw requirements specification | Engineering, Product |

**Covers:** RTK precision (2cm) • Grid generation • GSD compliance • Gap detection • Overlap analysis

### Development & Quality

| Document | Description | Audience |
|----------|-------------|----------|
| [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) | AI-assisted workflow, task breakdowns | Engineering |
| [TESTING_STRATEGY.md](TESTING_STRATEGY.md) | Testing approach, determinism verification | Engineering, QA |
| [CONTRIBUTING.md](../CONTRIBUTING.md) | Contribution guidelines, code standards | Contributors |
| [CHANGELOG.md](../CHANGELOG.md) | Version history, release notes | Everyone |

---

## Project Timeline

### Current Focus: ThermalLaw MVP (DJI Challenge 2026)

| Phase | Timeline | Status | Focus |
|-------|----------|--------|-------|
| **Phase 0** | Feb 2026 | ✅ Complete | FlightLaw specification |
| **Phase 1** | Mar 2026 | ⏳ Next | ThermalLaw foundation (session, capture, approval) |
| **Phase 2** | Apr 2026 | 📋 Planned | ML integration (CoreML, classification) |
| **Phase 3** | May 2026 | 📋 Planned | Export & polish (PDF, coverage, UX) |
| **Phase 4** | Jun 2026 | 📋 Planned | Replay & verification (determinism proof) |

### Future Jurisdictions

| Phase | Timeline | Status | Focus |
|-------|----------|--------|-------|
| **Phase 5** | Q3 2026 | ✅ Specified | SurveyLaw specification |
| **Phase 6** | Q4 2026 | 📋 Planned | SurveyLaw implementation (RTK, grid, GSD) |

See [ROADMAP.md](ROADMAP.md) for detailed phase descriptions.

---

## Key Concepts

### Jurisdiction-Based Architecture

The Flightworks Suite uses a **jurisdiction model** where mission-specific applications inherit universal safety guarantees:

```
FlightLaw (Universal Safety)
    │
    ├─→ ThermalLaw (Thermal Inspection)
    │   • Inherits Laws 3, 4, 7, 8
    │   • Adds: Candidate classification, severity banding
    │
    └─→ SurveyLaw (Precision Mapping)
        • Inherits Laws 3, 4, 7, 8
        • Adds: RTK precision, grid validation, GSD compliance
```

**Benefits:**
- **Code Reuse:** Safety logic written once, inherited everywhere
- **Consistency:** Identical safety behavior across jurisdictions
- **Modularity:** Add jurisdictions without modifying FlightLaw
- **Certifiability:** Prove safety properties once, apply everywhere

Learn more: [Flightworks-Suite-Overview.md](Flightworks-Suite-Overview.md)

### SwiftVector Architecture

Each jurisdiction implements the SwiftVector pattern:

```
State → Agent → Action → Reducer → New State
```

- **State** is immutable, typed, represents complete system truth
- **Actions** are typed proposals for state changes
- **Reducers** are pure functions that validate and apply actions
- **Agents** observe state and propose actions (never mutate directly)

Learn more: [ARCHITECTURE.md](ARCHITECTURE.md), [SwiftVector-Codex.md](SwiftVector-Codex.md)

### Determinism Boundary

For edge AI integration, SwiftVector establishes a clear boundary:

```
Stochastic Zone          Deterministic Zone
─────────────────────────────────────────────
ML Inference (≥0.5)  →  Confidence Band
Probabilistic Output →  Severity Assignment
Variable Timing      →  Fixed Thresholds
```

This enables **auditable, reproducible** AI-assisted decision support with **mathematical proof** of determinism.

Learn more: [HLD-FlightworksThermal.md](HLD-FlightworksThermal.md#determinism-boundary-architecture)

### Human-in-Command Development

Development follows **Agency Paradox** principles:

- Humans retain authority over architecture and safety decisions
- AI assists with implementation within defined specifications
- All AI contributions are reviewed and verified

**"AI proposes, humans decide, Laws enforce"**

Learn more: [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md)

---

## Jurisdiction Comparison

| Aspect | FlightLaw | ThermalLaw | SurveyLaw |
|--------|-----------|------------|-----------|
| **Purpose** | Universal safety | Thermal inspection | Precision mapping |
| **Platform** | Any MAVLink | DJI M4T | DJI M4E |
| **Status** | ✅ Specified | ⏳ MVP in progress | ✅ Specified |
| **Laws** | 3, 4, 7, 8 | FlightLaw + thermal governance | FlightLaw + survey governance |
| **Key Feature** | Audit trail | Governed AI detection | RTK precision |
| **Business Guarantee** | Safety enforcement | No damage missed/hallucinated | 100% grid adherence |
| **Target Market** | Foundation | Inspection services | Civil engineering |

---

## Related Resources

### Foundation Papers

| Resource | Description |
|----------|-------------|
| [SwiftVector Whitepaper](https://agentincommand.ai/swiftvector) | Deterministic control architecture specification |
| [Swift at the Edge](https://agentincommand.ai/swift-at-the-edge) | Manifesto for on-device AI with Swift |
| [The Agency Paradox](https://agentincommand.ai/agency-paradox) | Framework for human command over AI systems |

### External Documentation

| Resource | Description |
|----------|-------------|
| [PX4 User Guide](https://docs.px4.io/) | PX4 autopilot documentation |
| [MAVSDK Documentation](https://mavsdk.mavlink.io/) | MAVLink SDK reference |
| [DJI Developer](https://developer.dji.com/) | DJI SDK and platform docs |
| [Swift Documentation](https://swift.org/documentation/) | Swift language reference |

---

## Getting Help

- **Questions:** Open a [GitHub Discussion](https://github.com/stephen-sweeney/flightworks-control/discussions)
- **Bug Reports:** Open a [GitHub Issue](https://github.com/stephen-sweeney/flightworks-control/issues)
- **Contributing:** See [CONTRIBUTING.md](../CONTRIBUTING.md)
- **Security Issues:** Email security@flightworksaerial.com

---

## Document Maintenance

This documentation is maintained alongside the codebase. When contributing:

1. Update relevant documentation with code changes
2. Keep jurisdiction-specific docs (HLD/PRD) in sync
3. Update [CHANGELOG.md](../CHANGELOG.md)
4. Ensure cross-references remain valid
5. Follow documentation standards in [CONTRIBUTING.md](../CONTRIBUTING.md)

### Version History

| Date | Version | Changes |
|------|---------|---------|
| February 2026 | 2.0.0 | **Jurisdiction-based architecture restructuring** |
|  |  | • Split into FlightLaw + ThermalLaw + SurveyLaw |
|  |  | • Added HLD/PRD for each jurisdiction |
|  |  | • Updated documentation structure |
| January 2026 | 1.0.0 | Initial monolithic architecture documentation |

---

<p align="center">
  <strong>Flightworks Suite</strong><br>
  Jurisdiction-Based Architecture for Governed Drone Operations<br>
  <a href="https://agentincommand.ai">agentincommand.ai</a> · <a href="https://flightworksaerial.com">flightworksaerial.com</a>
</p>
