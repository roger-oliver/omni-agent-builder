# Model Allocation Policy

Omni uses a hybrid local/cloud model strategy.

## Local Model Context

Two local models are served by vLLM:

- **GadflyII/Qwen3-Coder-Next-NVFP4**: Target context window of **131072 tokens**. Used for orchestration, PR validation, unit test generation, and SAST assistance. Best for high-frequency, privacy-sensitive tasks requiring large context.
- **Qwen/Qwen3.8-27B**: Lighter-weight model for implementation agents, QA, DevOps, observability, and GitHub operations. Faster inference for code generation and operational tasks.

Both models should be used for high-frequency, private, code-heavy tasks. However, context windows are limits, not permission to load entire large repositories blindly. Agents must summarize, chunk, and inspect selectively when repositories exceed the available context.

## Cloud LLMs for Complex Tasks

| Model | Best For | Notes |
|---|---|---|
| opencode/GPT-5.5 or opencode/claude-sonnet-4-6 | Top-tier architecture decisions, complex debugging | Oracle-style reasoning for hard decisions. |
| opencode/gemini-3-pro | UI/UX design and visual reasoning | Multimodal or visual planning work. |
| opencode/claude-haiku-4-5 | Codebase search, lightweight classification, routing | Low-cost, fast exploration and triage. |

## Concrete Allocation Plan

| Agent Type | Recommended Model | Location | Reasoning |
|---|---|---|---|
| Orchestrator | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context | High-frequency calls, low latency, privacy-sensitive. |
| Strategy and definition | opencode/claude-sonnet-4-6 | Cloud | Complex reasoning for business analysis and requirements. |
| Design and architecture | opencode/claude-sonnet-4-6 | Cloud | Top-tier reasoning for schema and API design. |
| Legacy analysis | opencode/claude-sonnet-4-6 | Cloud | Complex reasoning for legacy codebase analysis. |
| Security scanning | opencode/claude-sonnet-4-6 | Cloud | Deep analysis for security threats and vulnerabilities. |
| UI/UX design | opencode/gemini-3-pro | Cloud | Multimodal and visual reasoning. |
| Codebase search / explorer | opencode/claude-haiku-4-5 | Cloud | Fast, low-cost classification and search. |
| Traceability governance | opencode/claude-haiku-4-5 | Cloud | Fast updates for RTM tracking. |
| Documentation / librarian | opencode/claude-sonnet-4-6 | Cloud | Documentation synthesis and live research when needed. |
| Backend/Frontend code generation | Qwen/Qwen3.8-27B | Local vLLM | Core coding work; code normally stays local. |
| Code review / PR validation | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context | Consistent with code generator and repository context. |
| Unit test generation | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context | Uses the shared local coding model to simplify infrastructure. |
| SAST security scanning | Rule engine + GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context | Prefer deterministic scanners; shared local LLM assists triage. |
| QA and performance testing | Qwen/Qwen3.8-27B | Local vLLM | Test generation and validation. |
| DevOps and release | Qwen/Qwen3.8-27B | Local vLLM | Pipeline and rollback configurations. |
| Observability | Qwen/Qwen3.8-27B | Local vLLM | Close to implementation and code instrumentation. |
| GitHub operations | Qwen/Qwen3.8-27B | Local vLLM | GitHub API operations. |

## Agent Model Defaults

### Primary agent (local vLLM 131072-token context)

- `omni-orchestrator`: `vllm/GadflyII/Qwen3-Coder-Next-NVFP4`

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

- `frontend-vue-engineer`: `vllm/Qwen/Qwen3.8-27B`
- `frontend-react-engineer`: `vllm/Qwen/Qwen3.8-27B`
- `backend-rust-engineer`: `vllm/Qwen/Qwen3.8-27B`
- `backend-python-engineer`: `vllm/Qwen/Qwen3.8-27B`
- `backend-csharp-engineer`: `vllm/Qwen/Qwen3.8-27B`
- `unit-test-generator`: `vllm/GadflyII/Qwen3-Coder-Next-NVFP4`

### Legacy analysis agents (cloud)

- `legacy-python-analyst`: `opencode/claude-sonnet-4-6`
- `legacy-csharp-analyst`: `opencode/claude-sonnet-4-6`
- `schema-extractor`: `opencode/claude-sonnet-4-6`

### Security agents (cloud)

- `sast-scanner`: `vllm/GadflyII/Qwen3-Coder-Next-NVFP4`
- `dast-tester`: `opencode/claude-sonnet-4-6`
- `dependency-auditor`: `opencode/claude-sonnet-4-6`

### QA and performance agents (local vLLM)

- `integration-tester`: `vllm/Qwen/Qwen3.8-27B`
- `load-simulator`: `vllm/Qwen/Qwen3.8-27B`
- `qa-validator`: `vllm/Qwen/Qwen3.8-27B`
- `uat-mimic`: `vllm/Qwen/Qwen3.8-27B`

### DevOps and release agents (local vLLM)

- `pipeline-engineer`: `vllm/Qwen/Qwen3.8-27B`
- `rollback-manager`: `vllm/Qwen/Qwen3.8-27B`

### Observability agents (local vLLM)

- `logging-strategist`: `vllm/Qwen/Qwen3.8-27B`
- `alerting-monitor`: `vllm/Qwen/Qwen3.8-27B`

### Governance and documentation agents (cloud)

- `traceability-keeper`: `opencode/claude-haiku-4-5`
- `technical-writer`: `opencode/claude-sonnet-4-6`

### GitHub and PR agents

- `codebase-explorer`: `opencode/claude-haiku-4-5`
- `github-operator`: `vllm/Qwen/Qwen3.8-27B`
- `pr-validator`: `vllm/GadflyII/Qwen3-Coder-Next-NVFP4`

If a configured model is unavailable, the orchestrator must not silently substitute. It must report the missing model and ask the user whether to change the agent model or enable the required provider/model.
