---
name: legacy-analysis
description: Use when reverse-engineering cloned legacy Python or C# repositories and producing As-Is architecture documentation.
---

# Legacy Analysis

Legacy analysis is read-only unless explicitly instructed otherwise. Never modify legacy source code.

## As-Is document template

```markdown
# As-Is: <repo name>
Audience: developer, operator
## System overview
## Main modules / projects and responsibilities
## Class / module hierarchy (where useful)
## Entry points
## API inventory
## Database access map
## Queue / job topology
## Dependency graph
## Critical flows
## Technical debt hotspots   (DEF IDs + severity: High/Medium/Low)
## Security risks            (DEF IDs + severity per security-review)
## Migration recommendations (phased; risks; unknowns)
## Verification notes        (how evidence was gathered)
```

- File name: `as-is-<repo-slug>.md` under `decision_logs/docs/architecture/` (or the location the orchestrator specifies).
- Tech-debt and security findings get `DEF-###` IDs and severities (per `id-traceability` and `security-review`).

## Evidence rules

- Every claim cites a path (`src/module/file.py:120`) or a read-only command output.
- Distinguish Observed Evidence / Assumptions / Recommendations strictly.
- Database access: read-only environment variables only (`POSTGRES_READONLY_URL`, `SQLSERVER_READONLY_URL`). Never print connection strings or credentials.
- Never expose secrets found in legacy code — report `file:line` + variable name only (secret patterns per `security-review`).
