# Contributing to Flightworks Control

Thank you for your interest in contributing to Flightworks Control! This document outlines our development philosophy and contribution process.

## Development Philosophy

Flightworks Control follows **Human-in-Command** development principles:

### 1. Specification First

Every significant change begins with a written specification:
- What problem does this solve?
- What are the inputs and outputs?
- What constraints must be respected?
- What invariants must be preserved?
- What test cases verify correctness?

### 2. Tests Alongside Code

- Unit tests for all reducers (pure functions)
- Property-based tests for determinism verification
- Integration tests for cross-component behavior
- No PR merged without appropriate test coverage

### 3. Architectural Consistency

All contributions must align with SwiftVector principles:
- State is immutable
- Actions are typed proposals
- Reducers are pure functions
- Side effects are isolated
- Determinism is non-negotiable

### 4. Safety-Critical Awareness

This is GCS software. Even as a demonstration project:
- Consider failure modes
- Handle errors explicitly
- Document safety implications
- Never fail silently

## Getting Started

### 1. Fork and Clone

```bash
git fork https://github.com/[username]/flightworks-control.git
git clone https://github.com/[your-username]/flightworks-control.git
cd flightworks-control
```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
```

Branch naming conventions:
- `feature/` — New functionality
- `fix/` — Bug fixes
- `docs/` — Documentation updates
- `refactor/` — Code restructuring
- `test/` — Test additions or improvements

### 3. Make Changes

- Follow existing code style
- Add tests for new functionality
- Update documentation as needed
- Keep commits focused and well-messaged

### 4. Submit PR

- Fill out the PR template completely
- Reference any related issues
- Ensure CI passes
- Request review

## Code Style

### Swift Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use meaningful names over comments
- Prefer immutability (`let` over `var`)
- Use Swift's type system to prevent invalid states

### SwiftVector Patterns

```swift
// State: Immutable, complete representation
struct FlightState: Equatable, Codable {
    let altitude: Double
    let groundspeed: Double
    let flightMode: FlightMode
}

// Action: Typed proposal for change
enum FlightAction: Equatable, Codable {
    case updateAltitude(Double)
    case changeMode(FlightMode)
}

// Reducer: Pure function, deterministic
func reduce(state: FlightState, action: FlightAction) -> FlightState {
    switch action {
    case .updateAltitude(let alt):
        return FlightState(
            altitude: alt,
            groundspeed: state.groundspeed,
            flightMode: state.flightMode
        )
    // ... handle other actions
    }
}
```

### Documentation

- Public APIs must have documentation comments
- Complex logic should have inline explanations
- Architecture decisions should be documented in `/docs`

## Review Process

### What We Look For

1. **Correctness** — Does it do what it claims?
2. **Determinism** — Same inputs → same outputs?
3. **Safety** — Are failure modes handled?
4. **Consistency** — Does it follow project patterns?
5. **Tests** — Is behavior verified?
6. **Documentation** — Is it understandable?

### Response Time

We aim to review PRs within one week. Complex changes may take longer.

## Questions?

- Open a [Discussion](https://github.com/[username]/flightworks-control/discussions)
- Check existing issues and documentation
- Reach out via [agentincommand.ai](https://agentincommand.ai)

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

---

*Thank you for helping build trustworthy autonomous systems!*

