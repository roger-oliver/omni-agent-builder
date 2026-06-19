# Model Allocation Policy

Omni uses a hybrid local/cloud model strategy.

## Local Model Context

The primary local model is Qwen3-Coder-Next 80B served by vLLM with a target context window of **256K tokens**.

This large context window should be emphasized and used for high-frequency, private, code-heavy tasks. However, 256K is still a limit, not permission to load an entire large repository blindly. Agents must summarize, chunk, and inspect selectively when repositories exceed the available context.

## Cloud LLMs for Complex Tasks

| Model | Best For | Notes |
|---|---|---|
| GPT-5.5 or Claude Sonnet 4.6 | Top-tier architecture decisions, complex debugging | Oracle-style reasoning for hard decisions. |
| Gemini 3 Pro | UI/UX design and visual reasoning | Multimodal or visual planning work. |
| Claude Haiku 4.5 | Codebase search, lightweight classification, routing | Low-cost, fast exploration and triage. |

## Concrete Allocation Plan

| Agent Type | Recommended Model | Location | Reasoning |
|---|---|---|---|
| Orchestrator | Qwen3-Coder-Next 80B | Local vLLM, 256K context | High-frequency calls, low latency, privacy-sensitive. |
| Backend/Frontend code generation | Qwen3-Coder-Next 80B | Local vLLM, 256K context | Core coding work; code normally stays local. |
| Code review / PR validation | Qwen3-Coder-Next 80B | Local vLLM, 256K context | Consistent with code generator and repository context. |
| Unit test generation | DeepSeek-Coder-V2 Lite | Local vLLM when available | Lightweight code/test generation. |
| SAST security scanning | Rule engine + small local model | Local | Prefer deterministic scanners; LLM assists triage. |
| UI/UX design | Gemini 3 Pro | Cloud | Multimodal and visual reasoning. |
| Complex architecture decisions | GPT-5.5 or Claude Sonnet 4.6 | Cloud | One-off, high-complexity reasoning. |
| Codebase search / explorer | Claude Haiku 4.5 | Cloud | Fast, low-cost classification and search. |
| Documentation / librarian | Claude Sonnet 4.6 | Cloud | Documentation synthesis and live research when needed. |
| Logging strategy / observability | Qwen3-Coder-Next 80B | Local vLLM, 256K context | Close to implementation and code instrumentation. |

## Agent Model Defaults

- `omni-orchestrator`: `vllm/qwen3-coder-next-80b`
- Builder agents: `vllm/qwen3-coder-next-80b`
- `pr-validator`: `vllm/qwen3-coder-next-80b`
- `unit-test-generator`: `vllm/deepseek-coder-v2-lite`
- `sast-scanner`: `vllm/deepseek-coder-v2-lite`
- `solution-architect`: `anthropic/claude-sonnet-4-6`
- `ui-ux-designer`: `google/gemini-3-pro`
- `codebase-explorer`: `anthropic/claude-haiku-4-5`
- `technical-writer`: `anthropic/claude-sonnet-4-6`

If a configured model is unavailable, the orchestrator must not silently substitute. It must report the missing model and ask the user whether to change the agent model or enable the required provider/model.
