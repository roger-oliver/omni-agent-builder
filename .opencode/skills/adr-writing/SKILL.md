---
name: adr-writing
description: Use when creating or updating Architecture Decision Records, implementation notes, decision logs, or traceability documents.
---

# ADR Writing

Use ADRs for significant decisions: stack selection, dependencies, architecture, database design, API contracts, security, deployment, rollback, legacy migration, or rejected approaches.

Required sections:

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

Never include raw secrets, tokens, credentials, or sensitive customer data.
