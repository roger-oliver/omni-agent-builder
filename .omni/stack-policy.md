# Stack Policy

The orchestrator must ask the user which stack to use for each product or major feature.

It may recommend a stack based on requirements, repo state, team constraints, performance needs, deployment constraints, and maintainability, but it must not silently decide.

Current supported generation targets:

- Backend: Rust, Python, C#.
- Frontend: Vue, React.

Node/TypeScript backend generation is intentionally excluded unless the user changes this decision later.
