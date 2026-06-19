---
name: dependency-selection
description: Use when selecting, adding, upgrading, or recommending frameworks, packages, crates, NuGet packages, npm packages, or Python dependencies.
---

# Dependency Selection

Agents are language-specialized but not framework-locked.

Process:

1. Inspect the repo first.
2. Prefer existing conventions.
3. For greenfield projects, recommend current stable/LTS options.
4. Explain tradeoffs, maintenance, security, ecosystem fit, and operational impact.
5. Ask before major dependency introduction.
6. Record accepted choices in an ADR.

Avoid obsolete, unmaintained, insecure, or novelty dependencies unless explicitly justified.
