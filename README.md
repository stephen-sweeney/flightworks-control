# Flightworks Control

An open-source Ground Control Station built on SwiftVector principles—demonstrating deterministic control architecture for safety-critical autonomous systems.

![Status](https://img.shields.io/badge/status-early%20development-orange)
![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![Swift](https://img.shields.io/badge/swift-5.9+-orange)
![License](https://img.shields.io/badge/license-MIT-blue)

## Vision

Unmanned aircraft operators need clarity, speed, and confidence. Current ground control systems either lack modern UI/UX or rely on unpredictable AI that cannot be certified for safety-critical operations.

Flightworks Control demonstrates a different approach:

- **Deterministic Architecture** — Built on [SwiftVector](docs/SWIFTVECTOR.md) patterns where state is truth, actions are proposals, and reducers enforce invariants
- **Operator-First Design** — Reduce cognitive load, prioritize safety cues, maintain situational awareness
- **Swift-Native** — Leveraging Swift's type system, actor model, and Apple Silicon optimization for reliable real-time performance
- **Auditable** — Every state transition logged, every decision traceable, every session replayable

## Project Status

🚧 **Early Development** — Phase 0: Foundation

This project is in active early development. Core architecture is being established. Not yet suitable for any operational use.

### Roadmap

| Phase | Focus | Status |
|-------|-------|--------|
| 0 | Foundation & Architecture | 🔄 In Progress |
| 1 | Core Flight Interface | ⏳ Planned |
| 2 | Mission Planning | ⏳ Planned |
| 3 | Autonomy-Aware Enhancements | ⏳ Planned |
| 4 | Debrief & Replay | ⏳ Planned |
| 5 | Deterministic Decision Support | ⏳ Planned |

See [ROADMAP.md](docs/ROADMAP.md) for detailed phase descriptions.

## Architecture

Flightworks Control implements the SwiftVector pattern:

```
State → Agent → Action → Reducer → New State
```

- **State** is immutable and represents complete system truth
- **Actions** are typed proposals for state changes
- **Reducers** validate and apply actions deterministically
- **Agents** (future) reason about state and propose actions within constraints

This architecture ensures:
- Reproducible behavior for certification
- Complete audit trails for compliance
- Deterministic replay for debugging
- Safe boundaries around AI reasoning

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed design documentation.

## Why Open Source?

Safety-critical software demands transparency. When lives depend on system behavior, "trust us" isn't good enough.

Open source enables:

- **Verification** — Anyone can audit the code that controls aircraft
- **Auditability** — The deterministic architecture we claim is provable, not just promised
- **Community** — Collective expertise improves safety for everyone
- **Trust** — Operators can inspect exactly what their GCS does

SwiftVector's core principle—state as truth, not hidden in prompts—extends to the project itself. The code is the truth. It's open for inspection.

This is a research and demonstration platform, not certified operational software. But we believe the path to certified systems starts with architectures that *can* be audited. Open source makes that possible.

## Getting Started

### Requirements

- macOS 14.0+
- Xcode 15.0+
- Swift 5.9+

#### 1. Fork and Clone
```bash
# Using GitHub CLI
gh repo fork stephen-sweeney/flightworks-control --clone
cd flightworks-control

# Or manually: Fork via GitHub.com, then clone your fork
git clone https://github.com/stephen-sweeney/flightworks-control.git
cd flightworks-control
```

Build and run in Xcode (⌘R).

### Running with Simulator

PX4 SITL integration coming in Phase 1. Currently displays simulated telemetry data.

## Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting PRs.

### Development Philosophy

This project practices **Human-in-Command** development:
- Clear specifications before implementation
- Tests written before or alongside code
- All changes reviewed against architectural principles
- Safety-critical code requires explicit approval

## Related Work

Flightworks Control is part of the [Agent in Command](https://agentincommand.ai) project exploring deterministic AI architectures.

### Papers & Documentation

- [SwiftVector Whitepaper](https://agentincommand.ai/swiftvector) — Deterministic control for stochastic agent systems
- [Swift at the Edge](https://agentincommand.ai/swift-at-the-edge) — A manifesto for on-device AI
- [The Agency Paradox](https://agentincommand.ai/agency-paradox) — Human command over AI systems

## License

MIT License — See [LICENSE](LICENSE) for details.

## Author

**Stephen Sweeney**  
Founder, Flightworks Aerial LLC  
[agentincommand.ai](https://agentincommand.ai)

---

*Building trustworthy autonomous systems, one deterministic state transition at a time.*

