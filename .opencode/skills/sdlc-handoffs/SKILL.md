---
name: sdlc-handoffs
description: Use when the orchestrator delegates work between agents or any agent produces an artifact for downstream agents — defines phase gates, handoff packet fields, artifact paths, and done-when criteria.
---

# SDLC Handoffs

Every handoff between Omni agents is a **handoff packet**. Do not rely on hidden chat context.

## Handoff packet fields (mandatory)

| Field | Content |
|---|---|
| Goal | One sentence: what the receiving agent must achieve |
| Requirement IDs | `BC-`/`UC-`/`REQ-` IDs driving the work |
| Context | Inputs Reviewed so far, key Observed Evidence, links to prior artifacts |
| Constraints | Stack, repo boundaries, budget/risk limits, policies in play |
| Done-when | Testable completion criteria |
| Verification command | Exact command(s) that prove Done-when |

## Phase gates (gates run in order — agents within a gate's parallel group run concurrently)

| Gate | Producer | Artifact → path in `decision_logs` | Next |
|---|---|---|---|
| G1 Business context | `business-interpreter` | Business Context → `docs/business-context/` | `use-case-modeler` |
| G2 Use cases | `use-case-modeler` | Use cases → `docs/use-cases/` | `prioritization-agent` |
| G3 Prioritized backlog | `prioritization-agent` | Ranked backlog → `docs/requirements/backlog.md` | `requirements-writer` |
| G4 SRS | `requirements-writer` | SRS (REQ/NFR/AC) → `docs/requirements/SRS.md` | `solution-architect` (+ `codebase-explorer` first on unfamiliar repos) |
| G5 Architecture | `solution-architect` | HLD + checklist → `docs/architecture/` | `data-schema-modeler`, `api-contract-designer`, `ui-ux-designer` |
| G6 Contracts | `data-schema-modeler` / `api-contract-designer` / `ui-ux-designer` | ERD → `docs/data-models/`; OpenAPI → `docs/api-contracts/`; UX → `docs/ui-ux/` | builders |
| G7 Build | `backend-*` / `frontend-*` / `data-migration-engineer` / `e2e-test-engineer` | Code in product repos; PR to `develop` | `unit-test-generator`, `integration-tester` |
| G8 Test & QA | `unit-test-generator`, `integration-tester`, `load-simulator`, `qa-validator`, `uat-mimic`, `accessibility-auditor` | Tests in code repos; reports → `docs/qa/` | `sast-scanner`, `dast-tester`, `dependency-auditor` |
| G9 Security | `sast-scanner`, `dast-tester`, `dependency-auditor` | Findings reports → `docs/qa/` | `pr-validator` |
| G10 PR validation | `pr-validator` + `github-operator` | PR comments; merge to `develop` (merge commit) | `traceability-keeper` |
| G11 Governance | `traceability-keeper`, `technical-writer` | RTM → `docs/traceability/`; docs → `docs/`; release notes → `docs/release-notes/` | `release-manager` |
| G12 Release | `release-manager`, `rollback-manager` | Release plan → `docs/release-notes/` | human approval for `main` |

## Parallelism

An agent is spawnable **in parallel** when all three hold:

1. its input artifacts exist (it is not waiting on another in-flight agent), and
2. its output paths are disjoint from every other in-flight agent, and
3. it shares no mutable resource (same repo working tree, same file).

Parallel groups:

| Gate | Parallel group |
|---|---|
| G6 Design | `[data-schema-modeler ∥ api-contract-designer ∥ ui-ux-designer]` (after `solution-architect`) |
| G8 Test | `[unit-test-generator ∥ integration-tester ∥ e2e-test-engineer ∥ load-simulator ∥ accessibility-auditor]`, then `[qa-validator ∥ uat-mimic]` |
| G9 Security | `[sast-scanner ∥ dast-tester ∥ dependency-auditor]` |
| G11 Governance | `[traceability-keeper ∥ technical-writer]` |
| G12 Release | `[rollback-manager ∥ pipeline-engineer]` while `release-manager` prepares |

Safe cross-gate overlaps: e2e specs authored from `UC`/`AC` during build; SAST per commit; `codebase-explorer` per repository.

Rules:

- **One writer per repository or file** at a time; when outputs overlap, serialize.
- Parallelize across repos or over disjoint artifact paths only.
- Cap at ≤ 5 concurrent agents (provider rate limits).
- Collect compact summaries — the orchestrator's context is the accumulator; files are the memory.
- Only the orchestrator asks the user; batch subagent `Open Questions` into one message.

Anti-patterns: parallel builders on the same repo/branch; two writers to one artifact; validating the same PR twice.

## Rules

- **Before G5 on an unfamiliar repo**, run `codebase-explorer` and attach its evidence to the packet.
- Producers must name the artifact path; consumers must list the artifact under `Inputs Reviewed`.
- Missing or conflicting packet fields → stop and ask. Never guess.
- ADR-required decisions (per `decision-log-policy.md`) must be written to `docs/adr/` before the gate closes.
- Phase gates G1–G6 are design gates (no product code). G7+ write to product repos only, after `Repository Interaction Checklist` passes.
