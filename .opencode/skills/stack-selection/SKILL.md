---
name: stack-selection
description: Use when selecting or confirming the technology stack for a product or feature — the always-ask rule, decision matrix, and supported targets.
---

# Stack Selection

## The always-ask rule

The orchestrator **must ask the user** which stack to use for each product or major feature. Recommendation is allowed; silent decision is forbidden (`.omni/stack-policy.md`).

## Supported generation targets (current)

| Layer | Supported |
|---|---|
| Backend | Rust, Python, C# |
| Frontend | Vue, React |
| Backend Node/TypeScript | **Excluded** unless the user changes this decision |
| Local LLM runtimes | Excluded (see `model-allocation`) |

Pinned defaults the user has already decided: Rust **1.96.0**, .NET SDK **10 LTS**. If a repo pins different versions, follow the repo and note the deviation.

## Decision matrix (present when recommending)

| Criterion | Option A | Option B | Notes |
|---|---|---|---|
| Requirements fit | (NFR drivers) | | latency, concurrency, I/O |
| Team constraints | | | skills, hiring |
| Existing repo evidence | | | via `codebase-explorer` |
| Ecosystem maturity | | | LTS status verified at decision time |
| Ops/deploy constraints | | | hosting, cold starts |
| Maintainability | | | long-term upkeep |

## Process

1. Read `.omni/orchestrator.config.json` + `codebase-explorer` output for existing evidence.
2. List unknowns; ask the user (stack + version policy + deployment target).
3. Record the final choice as an **ADR** (`stack selection` is a required ADR case).
4. Builders may only implement in the confirmed stack.

## Output

Stack table (layer | technology | version policy | rationale) → `decision_logs/docs/architecture/` + `docs/adr/NNNN-stack-selection.md`.
