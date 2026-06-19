---
name: agent-operating-contract
description: Use when an Omni agent needs the shared anti-hallucination, safety, response-shape, repository-interaction, and artifact-quality rules.
---

# Agent Operating Contract

Follow `.omni/agent-operating-contract.md`.

Key requirements:

- Do not invent facts.
- Separate observed evidence, assumptions, recommendations, and decisions.
- Ask when required information is missing or conflicting.
- Never expose secrets.
- Never claim verification without evidence.
- Work only with registered repositories.
- Keep outputs traceable to requirements, ADRs, PRs, tests, and releases.
- Use the required response shape for non-trivial work.
