---
name: agent-operating-contract
description: Use when an Omni agent needs the shared anti-hallucination, safety, response-shape, repository-interaction, and artifact-quality rules.
---

# Agent Operating Contract

The authoritative copy is `.omni/agent-operating-contract.md`. This skill is a pointer plus the essentials.

Key requirements:

- Do not invent facts.
- Separate observed evidence, assumptions, recommendations, and decisions.
- Ask when required information is missing or conflicting.
- Never expose secrets (environment variable **names** only).
- Never claim verification without evidence.
- Work only with registered repositories.
- Keep outputs traceable to requirements, ADRs, PRs, tests, and releases (IDs per `id-traceability`).
- Use the required response shape for non-trivial work.
- **Artifact locations**: write produced documents under `decision_logs/docs/…` per `sdlc-handoffs` and `docs-structure`. Never leave deliverables only in chat.
