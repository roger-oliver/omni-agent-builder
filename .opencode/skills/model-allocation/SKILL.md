---
name: model-allocation
description: Use when deciding which Omni model tier applies to an agent or task — MiMo 2.6 Pro, MiMo 2.6 Flash, or DeepSeek V4 Flash — or when a configured model is unavailable.
---

# Model Allocation

Follow `.omni/model-allocation-policy.md`.

Key rules:

- Omni uses **Chinese cloud models only** — no Anthropic models, no local runtimes (vLLM/Ollama/llama.cpp).
- **T1 Thinkers** (`mimo/mimo-v2.6-pro`, 1M context): architecture, schema/API design, strategy, requirements, legacy analysis, security analysis, UI/UX, PR validation.
- **T2 Builders** (`mimo/mimo-v2.6-flash`, 1M context): code/test/config generation, QA, DevOps, observability, documentation.
- **T3 Operators** (`opencode/deepseek-v4.1-flash`, 1M context): orchestration routing, codebase search, traceability, GitHub API operations.
- A 1M-token context is a limit, not a license to load whole repositories. Summarize, chunk, and explore selectively.
- Prefer deterministic security scanners; LLMs assist triage and remediation only.
- If the configured model is unavailable, **ask the user instead of silently substituting**.
- Zen `-free` tiers are forbidden (daily usage limits, data used for improvement).
- Deprecated/retired models must not be referenced: `opencode/deepseek-v4-flash` (retired 2026-10-05 → use `opencode/deepseek-v4.1-flash`), `gemini-3-pro`, `kimi-k2.5`, `glm-5`, `minimax-m2.5`.
- Optional experiment only: `opencode/kimi-k2.7-code` for `backend-rust-engineer` A/B testing, never as a silent default.
