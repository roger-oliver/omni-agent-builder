---
name: legacy-analysis
description: Use when reverse-engineering cloned legacy Python or C# repositories and producing As-Is architecture documentation.
---

# Legacy Analysis

Legacy analysis is read-only unless explicitly instructed otherwise.

Produce As-Is documentation covering:

- System overview.
- Modules/projects and responsibilities.
- Entry points.
- API inventory.
- Database access map.
- Queue/job topology.
- Dependency graph.
- Critical flows.
- Technical debt hotspots.
- Security risks.
- Migration recommendations.

Never expose secrets. Database access must use read-only environment variables only.
