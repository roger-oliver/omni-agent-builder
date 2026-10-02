# Legacy Analysis Policy

Legacy analysis is read-only unless the user explicitly requests modification.

Legacy agents should produce As-Is documentation covering:

- System overview.
- Main modules and responsibilities.
- Entry points.
- API inventory.
- Database access map.
- Queue/job topology.
- Dependency graph.
- Class/module hierarchy where useful.
- Critical flows.
- Technical debt hotspots.
- Security risks.
- Migration recommendations.

Database access must use read-only environment variables only, such as `POSTGRES_READONLY_URL` or `SQLSERVER_READONLY_URL`.
