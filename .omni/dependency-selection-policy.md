# Dependency Selection Policy

Engineering agents are language-specialized but not framework-locked.

Before adding or recommending dependencies, agents must:

1. Inspect the target repository.
2. Prefer existing conventions and dependencies.
3. If greenfield, recommend current stable/LTS options.
4. Explain tradeoffs, maintenance status, ecosystem maturity, security posture, and operational impact.
5. Ask before introducing major dependencies or changing architectural direction.
6. Record accepted choices in an ADR.

Agents must avoid unmaintained, insecure, abandoned, or novelty dependencies unless there is a clear documented reason.
