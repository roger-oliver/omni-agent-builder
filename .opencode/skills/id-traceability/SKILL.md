---
name: id-traceability
description: Use when creating or linking requirements, use cases, tests, ADRs, PRs, or the RTM — defines the Omni ID scheme and RTM schema.
---

# ID Traceability

## ID scheme (stable, never reused)

| Prefix | Meaning | Format | Created by |
|---|---|---|---|
| `BC-###` | Business Context block | `BC-001`… | `business-interpreter` |
| `UC-###` | Use case | `UC-100`… | `use-case-modeler` |
| `REQ-###` | Functional requirement | `REQ-001`… | `requirements-writer` |
| `NFR-###` | Non-functional requirement | `NFR-001`… | `requirements-writer` |
| `AC-###` | Acceptance criterion (child of REQ/NFR) | `AC-001`… | `requirements-writer` |
| `TC-###` | Test case | `TC-001`… | any test agent |
| `DEF-###` | Finding/defect | `DEF-001`… | QA/security agents |
| `ADR-NNNN` | Architecture Decision Record | `ADR-0001`… | any agent (via `adr-writing`) |
| `PR` | GitHub PR number/link | `#123` | `github-operator` |

Rules:

- IDs are stable: never renumber. Superseded items get status `superseded`, not deletion.
- Every requirement has ≥1 `AC`. Every `AC` has ≥1 `TC` before G10.
- Children cite parents: `AC-003 (REQ-001)`. Parents cite children in the RTM only.
- Code and tests carry IDs in tags/attributes/comments so traceability survives refactors.

## RTM schema (docs/traceability/rtm.md)

| BC | UC | REQ/NFR | AC | TC | PR | ADR | Release | Status |
|---|---|---|---|---|---|---|---|---|

- `traceability-keeper` owns the RTM and refreshes it on every PR merge to `develop`.
- Orphan report (no AC, no TC, no PR, or no release) must list IDs explicitly.
- Scope drift = REQ with no UC parent or UC with no BC parent.

## Verbs

- **Trace**: add the ID link (always do this at creation time).
- **Cover**: REQ has passing TC evidence.
- **Orphan**: item missing a required parent/child link.
