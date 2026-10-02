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

## Phase gates (orchestrator runs these in order)

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

## Rules

- **Before G5 on an unfamiliar repo**, run `codebase-explorer` and attach its evidence to the packet.
- Producers must name the artifact path; consumers must list the artifact under `Inputs Reviewed`.
- Missing or conflicting packet fields → stop and ask. Never guess.
- ADR-required decisions (per `decision-log-policy.md`) must be written to `docs/adr/` before the gate closes.
- Phase gates G1–G6 are design gates (no product code). G7+ write to product repos only, after `Repository Interaction Checklist` passes.
