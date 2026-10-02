---
name: adr-writing
description: Use when creating or updating Architecture Decision Records, implementation notes, decision logs, or traceability documents.
---

# ADR Writing

Use ADRs for significant decisions: stack selection, dependencies, architecture, database design, API contracts, security, deployment, rollback, legacy migration, or **failed approaches that must not be repeated**.

## File naming and location

`decision_logs/docs/adr/NNNN-kebab-title.md` — zero-padded sequence `ADR-0001`, `ADR-0002`, … (IDs from `id-traceability`). Never renumber.

## Status transitions

`Proposed` → `Accepted` → `Superseded by ADR-NNNN` | `Deprecated`

Status changes are edits to the header plus a line in `Implementation Notes` (date + reason). The ADR body is never rewritten to pretend a different past.

## Required sections

```markdown
# ADR: [Title]

**Status**: Proposed | Accepted | Superseded | Deprecated
**Date**: YYYY-MM-DD
**Project**: [Project Name]
**Related Requirement(s)**: [REQ/NFR/UC IDs]
**Related PR(s)**: [Links or #numbers]

## Context
## Options Considered
## Decision
## Consequences
## Implementation Notes
```

## Failed-approach ADRs (required case)

If an approach was tried and failed, write an ADR with `Status: Deprecated`, Options = the alternatives, Decision = why it failed and what replaces it. Title prefix `ADR-NNNN: Rejected …` when nothing replaces it yet.

## Rules

- Options Considered: ≥2 options with pros/cons — including "do nothing" when relevant.
- Implementation Notes filled **after** the fact: delivered PRs, deviations, test results, follow-ups.
- Never include raw secrets, tokens, credentials, or sensitive customer data. Env var names only.
- Cite real IDs/links only (no invented references) per `id-traceability`.
