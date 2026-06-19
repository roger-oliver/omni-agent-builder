---
name: model-allocation
description: Use when deciding whether an Omni task should use local vLLM Qwen 256K context, local DeepSeek-Coder-V2 Lite, or cloud models such as Claude Sonnet, GPT-5.5, Gemini 3 Pro, or Claude Haiku.
---

# Model Allocation

Follow `.omni/model-allocation-policy.md`.

Key rules:

- Primary local coding/orchestration model: Qwen3-Coder-Next 80B via vLLM with **256K token context**.
- Use the 256K context deliberately; do not load massive repos blindly.
- Use local Qwen for orchestration, backend/frontend code generation, PR validation, logging strategy, and privacy-sensitive repository work.
- Use local DeepSeek-Coder-V2 Lite for lightweight unit-test generation and SAST assistance when available.
- Use Gemini 3 Pro for UI/UX design and visual reasoning.
- Use Claude Sonnet 4.6 or GPT-5.5 for complex architecture and debugging.
- Use Claude Haiku 4.5 for codebase exploration, lightweight classification, and routing.
- If the configured model is unavailable, ask the user instead of silently substituting.
