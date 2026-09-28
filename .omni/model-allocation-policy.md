# Model Allocation Policy

Omni runs entirely on **Chinese cloud models** — Anthropic models and local runtimes (vLLM, Ollama, llama.cpp) are excluded by decision. Two providers are configured:

| Provider | Auth env | Endpoint | Models used |
|---|---|---|---|
| `mimo` (Xiaomi MiMo) | `XIAOMI_MIMO_API_KEY` | Xiaomi MiMo API | `mimo/mimo-v2.6-pro`, `mimo/mimo-v2.6-flash` |
| `opencode` (OpenCode Zen) | `OPENCODE_ZEN_API_KEY` | `https://opencode.ai/zen/v1` | `opencode/deepseek-v4-flash` (plus the full Zen catalog as fallback candidates) |

## Model Tiers

| Tier | Model | $/1M in / out | Context | Selection rule |
|---|---|---|---|---|
| **T1 Thinkers** | `mimo/mimo-v2.6-pro` | $0.435 / $0.87 | 1M tokens | Agents that "think on a solution": architecture, schema/API design, strategy, requirements, legacy reverse-engineering, security analysis, visual design, PR gate |
| **T2 Builders** | `mimo/mimo-v2.6-flash` | $0.14 / $0.28 | 1M tokens | Agents that generate code, tests, or configs at volume or iterate with tools (RL-trained agentic coding) |
| **T3 Operators** | `opencode/deepseek-v4-flash` | $0.14 / $0.28 | 1M tokens | Routing, API calls, classification, tracking, search — fast and cheap; also gives provider diversity if the Xiaomi API is down |

A 1M-token context window is still a limit, not permission to load entire large repositories blindly. Agents must summarize, chunk, and inspect selectively when repositories exceed what is needed for the task.

## Concrete Allocation Plan

| Agent type | Model | Tier | Reasoning |
|---|---|---|---|
| Orchestration | `opencode/deepseek-v4-flash` | T3 | High-frequency routing; provider diversity |
| Strategy and definition | `mimo/mimo-v2.6-pro` | T1 | Complex reasoning for business analysis and requirements |
| Design and architecture | `mimo/mimo-v2.6-pro` | T1 | Top-tier reasoning for schema and API design |
| UI/UX design | `mimo/mimo-v2.6-pro` | T1 | Omnimo­dal input (text/image/video/audio); strong visual-coding scores |
| Legacy analysis | `mimo/mimo-v2.6-pro` | T1 | Complex reasoning for legacy codebase analysis |
| Security scanning | `mimo/mimo-v2.6-pro` | T1 | Deep analysis for threats and vulnerabilities |
| PR validation | `mimo/mimo-v2.6-pro` | T1 | Quality gate — consequential judgment |
| Backend/frontend code generation | `mimo/mimo-v2.6-flash` | T2 | High-volume code output with agentic tool use |
| Unit test generation | `mimo/mimo-v2.6-flash` | T2 | Same builder profile as implementation |
| QA and performance testing | `mimo/mimo-v2.6-flash` | T2 | Test generation and validation |
| DevOps and release | `mimo/mimo-v2.6-flash` | T2 | Pipeline and rollback configurations |
| Observability | `mimo/mimo-v2.6-flash` | T2 | Logging/monitoring strategy close to implementation |
| Documentation | `mimo/mimo-v2.6-flash` | T2 | Documentation synthesis |
| Codebase search / explorer | `opencode/deepseek-v4-flash` | T3 | Fast, low-cost classification and search |
| Traceability governance | `opencode/deepseek-v4-flash` | T3 | Fast updates for RTM tracking |
| GitHub operations | `opencode/deepseek-v4-flash` | T3 | GitHub API operations |

## Agent Model Defaults

### T1 Thinkers — `mimo/mimo-v2.6-pro`

- `business-interpreter`
- `use-case-modeler`
- `requirements-writer`
- `solution-architect`
- `data-schema-modeler`
- `api-contract-designer`
- `ui-ux-designer`
- `legacy-python-analyst`
- `legacy-csharp-analyst`
- `sast-scanner`
- `dast-tester`
- `dependency-auditor`
- `pr-validator`
- `privacy-compliance-reviewer`

### T2 Builders — `mimo/mimo-v2.6-flash`

- `prioritization-agent`
- `frontend-vue-engineer`
- `frontend-react-engineer`
- `backend-rust-engineer`
- `backend-python-engineer`
- `backend-csharp-engineer`
- `unit-test-generator`
- `schema-extractor`
- `integration-tester`
- `e2e-test-engineer`
- `load-simulator`
- `qa-validator`
- `uat-mimic`
- `accessibility-auditor`
- `pipeline-engineer`
- `rollback-manager`
- `release-manager`
- `data-migration-engineer`
- `logging-strategist`
- `alerting-monitor`
- `technical-writer`

### T3 Operators — `opencode/deepseek-v4-flash`

- `omni-orchestrator`
- `codebase-explorer`
- `traceability-keeper`
- `github-operator`

### OpenCode defaults

- `model`: `mimo/mimo-v2.6-flash`
- `small_model`: `opencode/deepseek-v4-flash`

## Rules

- Every model ID must include its provider prefix (`mimo/...` or `opencode/...`).
- If a configured model is unavailable, **never substitute silently** — stop and ask the user/orchestrator to enable the provider or pick an approved alternative.
- Prefer deterministic security scanners (SAST/DAST tooling) over LLM judgment; the LLM assists triage and remediation guidance only.
- Keep model IDs in sync across: agent frontmatter, this policy, `opencode.json`, and `manual-opencode-setup.md`.

## Do Not Use

| Model / class | Reason |
|---|---|
| Any `claude-*` | Excluded by decision |
| Local runtimes (`vllm/`, `ollama/`, `llama.cpp`) | Excluded by decision |
| `opencode/gemini-3-pro` | **Deprecated** on OpenCode Zen (2026-03-09) |
| `opencode/kimi-k2.5`, `opencode/glm-5`, `opencode/minimax-m2.5` | Deprecated on OpenCode Zen |
| Zen `-free` tiers (`deepseek-v4-flash-free`, `mimo-v2.6-flash-free`, …) | Hard daily usage limits, "limited time" availability, data may be used for model improvement |

## Optional experiment

`opencode/kimi-k2.7-code` ($0.95/$4.00) is a coding specialist with strong vendor-reported tool-use scores, but independent signals are mixed and it costs ~7–14× more than T2. Not adopted by default. If the user wants to A/B it for `backend-rust-engineer`, change only that agent's `model:` line and compare results before rolling out further.
