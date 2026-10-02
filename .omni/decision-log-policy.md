# Decision Log Policy

Important human and agent decisions must be recorded in the product decision/control repository.

## Required ADR Cases

- Stack selection.
- Major dependency introduction.
- Architecture decisions.
- Database design decisions.
- API contract decisions.
- Security-sensitive decisions.
- Deployment and rollback decisions.
- Legacy migration decisions.
- Significant failed approaches that should not be repeated.

## ADR Template

```markdown
# ADR: [Title]

**Status**: Proposed | Accepted | Superseded | Deprecated
**Date**: YYYY-MM-DD
**Project**: [Project Name]
**Related Requirement(s)**: [IDs]
**Related PR(s)**: [Links]

## Context

## Options Considered

## Decision

## Consequences

## Implementation Notes
```

Agents must never include raw secrets, tokens, credentials, or sensitive customer data in ADRs.
