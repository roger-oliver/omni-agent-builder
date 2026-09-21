# Model Allocation Policy

Omni uses a hybrid local/cloud model strategy.

## Local Model Context

The primary local model is **Qwen/Qwen3.8-27B** served by vLLM with a target context window of **131072 tokens**.

This model handles orchestration, PR validation, unit test generation, SAST assistance, implementation, QA, DevOps, observability, and GitHub operations. It should be used for high-frequency, private, code-heavy tasks. However, 131072 tokens is still a limit, not permission to load entire large repositories blindly. Agents must summarize, chunk, and inspect selectively when repositories exceed the available context.

## Cloud LLMs for Complex Tasks

| Model | Best For | Notes |
|---|---|---|
| opencode/GPT-5.5 or opencode/claude-sonnet-4-6 | Top-tier architecture decisions, complex debugging | Oracle-style reasoning for hard decisions. |
| opencode/gemini-3-pro | UI/UX design and visual reasoning | Multimodal or visual planning work. |
| opencode/claude-haiku-4-5 | Codebase search, lightweight classification, routing | Low-cost, fast exploration and triage. |

## Concrete Allocation Plan

| Agent Type | Recommended Model | Location | Reasoning |
|---|---|---|---|
| Orchestrator | Qwen/Qwen3.8-27B | Local vLLM, 131072-token context | High-frequency calls, low latency, privacy-sensitive. |
| Strategy and definition | opencode/claude-sonnet-4-6 | Cloud | Complex reasoning for business analysis and requirements. |
| Design and architecture | opencode/claude-sonnet-4-6 | Cloud | Top-tier reasoning for schema and API design. |
| Legacy analysis | opencode/claude-sonnet-4-6 | Cloud | Complex reasoning for legacy codebase analysis. |
| Security scanning | opencode/claude-sonnet-4-6 | Cloud | Deep analysis for security threats and vulnerabilities. |
| UI/UX design | opencode/gemini-3-pro | Cloud | Multimodal and visual reasoning. |
| Codebase search / explorer | opencode/claude-haiku-4-5 | Cloud | Fast, low-cost classification and search. |
| Traceability governance | opencode/claude-haiku-4-5 | Cloud | Fast updates for RTM tracking. |
| Documentation / librarian | opencode/claude-sonnet-4-6 | Cloud | Documentation synthesis and live research when needed. |
| Backend/Frontend code generation | Qwen/Qwen3.8-27B | Local vLLM | Core coding work; code normally stays local. |
| Code review / PR validation | Qwen/Qwen3.8-27B | Local vLLM, 131072-token context | Consistent with code generator and repository context. |
| Unit test generation | Qwen/Qwen3.8-27B | Local vLLM, 131072-token context | Uses the shared local coding model to simplify infrastructure. |
| SAST security scanning | Rule engine + Qwen/Qwen3.8-27B | Local vLLM, 131072-token context | Prefer deterministic scanners; shared local LLM assists triage. |
| QA and performance testing | Qwen/Qwen3.8-27B | Local vLLM | Test generation and validation. |
| DevOps and release | Qwen/Qwen3.8-27B | Local vLLM | Pipeline and rollback configurations. |
| Observability | Qwen/Qwen3.8-27B | Local vLLM | Close to implementation and code instrumentation. |
| GitHub operations | Qwen/Qwen3.8-27B | Local vLLM | GitHub API operations. |

## Agent Model Defaults

### Primary agent (local vLLM 131072-token context)

- `omni-orchestrator`: `opencode/qwen3.8-flash`

### Strategy and definition agents (cloud)

- `business-interpreter`: `opencode/claude-sonnet-4-6`
- `use-case-modeler`: `opencode/claude-sonnet-4-6`
- `prioritization-agent`: `opencode/claude-sonnet-4-6`
- `requirements-writer`: `opencode/claude-sonnet-4-6`

### Design and architecture agents (cloud)

- `solution-architect`: `opencode/claude-sonnet-4-6`
- `data-schema-modeler`: `opencode/claude-sonnet-4-6`
- `api-contract-designer`: `opencode/claude-sonnet-4-6`
- `ui-ux-designer`: `opencode/gemini-3-pro`

### Implementation agents (local vLLM)

- `frontend-vue-engineer`: `opencode/qwen3.8-flash`
- `frontend-react-engineer`: `opencode/qwen3.8-flash`
- `backend-rust-engineer`: `opencode/qwen3.8-flash`
- `backend-python-engineer`: `opencode/qwen3.8-flash`
- `backend-csharp-engineer`: `opencode/qwen3.8-flash`
- `unit-test-generator`: `opencode/qwen3.8-flash`

### Legacy analysis agents (cloud)

- `legacy-python-analyst`: `opencode/claude-sonnet-4-6`
- `legacy-csharp-analyst`: `opencode/claude-sonnet-4-6`
- `schema-extractor`: `opencode/claude-sonnet-4-6`

### Security agents (cloud)

- `sast-scanner`: `opencode/qwen3.8-flash`
- `dast-tester`: `opencode/claude-sonnet-4-6`
- `dependency-auditor`: `opencode/claude-sonnet-4-6`

### QA and performance agents (local vLLM)

- `integration-tester`: `opencode/qwen3.8-flash`
- `load-simulator`: `opencode/qwen3.8-flash`
- `qa-validator`: `opencode/qwen3.8-flash`
- `uat-mimic`: `opencode/qwen3.8-flash`

### DevOps and release agents (local vLLM)

- `pipeline-engineer`: `opencode/qwen3.8-flash`
- `rollback-manager`: `opencode/qwen3.8-flash`

### Observability agents (local vLLM)

- `logging-strategist`: `opencode/qwen3.8-flash`
- `alerting-monitor`: `opencode/qwen3.8-flash`

### Governance and documentation agents (cloud)

- `traceability-keeper`: `opencode/claude-haiku-4-5`
- `technical-writer`: `opencode/claude-sonnet-4-6`

### GitHub and PR agents

- `codebase-explorer`: `opencode/claude-haiku-4-5`
- `github-operator`: `opencode/qwen3.8-flash`
- `pr-validator`: `opencode/qwen3.8-flash`

If a configured model is unavailable, the orchestrator must not silently substitute. It must report the missing model and ask the user whether to change the agent model or enable the required provider/model.
