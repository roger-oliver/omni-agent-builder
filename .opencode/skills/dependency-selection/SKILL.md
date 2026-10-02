---
name: dependency-selection
description: Use when selecting, adding, upgrading, or recommending frameworks, packages, crates, NuGet packages, npm packages, or Python dependencies.
---

# Dependency Selection

Agents are language-specialized but not framework-locked.

## Process

1. Inspect the repo first (manifests, lockfiles, CI, existing conventions).
2. Prefer existing conventions and dependencies.
3. For greenfield projects, recommend current stable/LTS options (verify LTS status at decision time; do not cite stale facts).
4. Explain tradeoffs: maintenance status, security posture, ecosystem maturity, operational impact.
5. Ask before major dependency introduction or architectural direction change.
6. Record accepted choices in an ADR (`ADR` case: "major dependency introduction").

## Security & maintenance checks (run before recommending)

- Advisory scan with the ecosystem's deterministic tool: `cargo audit` / `pip-audit` / `osv-scanner` / `npm audit` / `dotnet list package --vulnerable`.
- Maintenance signals: recent releases, open-issue responsiveness, bus factor, download counts (as evidence, not sole criterion).
- Avoid obsolete, unmaintained, insecure, or novelty dependencies unless explicitly justified in the ADR.

## License posture

| Posture | Examples | Rule |
|---|---|---|
| Allow | MIT, Apache-2.0, BSD-2/3, ISC, MPL-2.0, Unlicense | OK |
| Ask | LGPL-2.1/3.0, EPL-2.0, CDDL, CC-BY-SA | Ask user before adopting; note obligations |
| Deny | SSPL, BUSL, unknown/no-license, "source available" with non-compete | Do not adopt without explicit user override (recorded in ADR) |

Report licenses as **SPDX identifiers**. Verify from the package itself at decision time.

## Lockfiles

- Commit lockfiles (`Cargo.lock` for binaries, `package-lock.json`/`pnpm-lock.yaml`, `poetry.lock`/`uv.lock`, `packages.lock.json`).
- Never hand-edit lockfiles. Upgrades go through the package manager.

## Boring over novelty

Prefer boring, stable, well-documented dependencies over novelty unless there is a clear, written reason. One-in, one-out review when dependency count grows fast.
