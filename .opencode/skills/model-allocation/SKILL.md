---
name: model-allocation
description: Use when deciding whether an Omni task should use the shared local vLLM Qwen/Qwen3.8-27B model with 131072-token context, or cloud models such as Claude Sonnet, GPT-5.5, Gemini 3 Pro, or Claude Haiku.
---

# Model Allocation

Follow `.omni/model-allocation-policy.md`.

Key rules:

- Primary local coding/orchestration model: Qwen/Qwen3.8-27B via vLLM with **131072-token context**.
- Use the 131072-token context deliberately; do not load massive repos blindly.
- Use the shared local Qwen/Qwen3.8-27B model for orchestration, backend/frontend code generation, PR validation, logging strategy, and privacy-sensitive repository work.
- Use the shared local Qwen/Qwen3.8-27B model for unit-test generation and SAST assistance.
- Use Gemini 3 Pro for UI/UX design and visual reasoning.
- Use Claude Sonnet 4.6 or GPT-5.5 for complex architecture and debugging.
- Use Claude Haiku 4.5 for codebase exploration, lightweight classification, and routing.
- If the configured model is unavailable, ask the user instead of silently substituting.
