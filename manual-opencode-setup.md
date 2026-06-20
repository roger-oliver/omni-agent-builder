# Manual OpenCode Setup

This project intentionally does not create or modify `opencode.json` automatically. Apply the configuration manually when you are ready.

## 1. Required environment variables

Set these outside the repo, for example in your shell profile, secret manager, or process environment:

```text
GITHUB_TOKEN
VLLM_BASE_URL
VLLM_API_KEY
OPENAI_API_KEY
ANTHROPIC_API_KEY
GOOGLE_GENERATIVE_AI_API_KEY
```

Notes:

- `GITHUB_TOKEN` is used for GitHub API operations.
- SSH keys are still used for Git clone/fetch/push.
- If vLLM does not require an API key, set `VLLM_API_KEY` to the placeholder value expected by your endpoint, such as `EMPTY`.
- Do not commit real secret values.

## 2. Confirm your vLLM model ID

Before setting the default OpenCode model, query your vLLM endpoint:

```text
GET {VLLM_BASE_URL}/models
```

Use the returned model ID in `model`, `small_model`, and each agent frontmatter if needed.

The current agent files use this placeholder:

```text
vllm/qwen3-coder-next-80b
```

The primary local Qwen model is expected to provide a **256K token context window**. This should be preserved in the vLLM deployment because the orchestrator, coding agents, PR validator, and legacy-analysis flows rely on large-context local reasoning.

All local-model agent files should reference the same vLLM model:

```text
vllm/qwen3-coder-next-80b
```

This keeps the local setup simple for a single Vast.ai VM running vLLM/Qwen3-Coder-Next-80B.

If your vLLM server exposes a different model name, update the agent files or configure an equivalent provider/model alias manually.

## 2.1 Cloud model allocation

Not all agents use the local model. The intended routing is:

| Agent/work type | Recommended model | Location |
|---|---|---|
| Orchestrator | Qwen3-Coder-Next 80B | Local vLLM, 256K context |
| Backend/frontend code generation | Qwen3-Coder-Next 80B | Local vLLM, 256K context |
| Code review / PR validation | Qwen3-Coder-Next 80B | Local vLLM, 256K context |
| Unit test generation | Qwen3-Coder-Next 80B | Local vLLM, 256K context |
| SAST security scanning | Rule engine + Qwen3-Coder-Next 80B | Local vLLM, 256K context |
| UI/UX design | Gemini 3 Pro | Cloud |
| Complex architecture decisions | GPT-5.5 or Claude Sonnet 4.6 | Cloud |
| Codebase search / explorer | Claude Haiku 4.5 | Cloud |
| Documentation / librarian | Claude Sonnet 4.6 | Cloud |
| Logging strategy / observability | Qwen3-Coder-Next 80B | Local vLLM, 256K context |

Current cloud-oriented agent defaults:

```text
solution-architect      -> anthropic/claude-sonnet-4-6
ui-ux-designer          -> google/gemini-3-pro
codebase-explorer       -> anthropic/claude-haiku-4-5
technical-writer        -> anthropic/claude-sonnet-4-6
```

If your OpenCode provider catalog uses different model IDs, update the corresponding agent frontmatter manually. Do not leave agent files pointing at unavailable models.

## 3. Suggested `opencode.json`

Create this manually in the repository root or merge it into your existing OpenCode config.

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "vllm/qwen3-coder-next-80b",
  "small_model": "vllm/qwen3-coder-next-80b",
  "default_agent": "omni-orchestrator",
  "provider": {
    "vllm": {
      "name": "vLLM Local",
      "api": "openai",
      "options": {
        "baseURL": "{env:VLLM_BASE_URL}",
        "apiKey": "{env:VLLM_API_KEY}"
      }
    },
    "openai": {
      "options": {
        "apiKey": "{env:OPENAI_API_KEY}"
      }
    },
    "anthropic": {
      "options": {
        "apiKey": "{env:ANTHROPIC_API_KEY}"
      }
    },
    "google": {
      "options": {
        "apiKey": "{env:GOOGLE_GENERATIVE_AI_API_KEY}"
      }
    }
  },
  "skills": {
    "paths": [".opencode/skills"]
  },
  "permission": {
    "read": "allow",
    "glob": "allow",
    "grep": "allow",
    "edit": "ask",
    "webfetch": "ask",
    "websearch": "ask",
    "bash": {
      "*": "ask",
      "git init*": "deny",
      "gh repo create*": "deny",
      "git remote add*": "deny",
      "git push --force*": "deny",
      "git push -f*": "deny",
      "rm -rf*": "deny"
    },
    "external_directory": {
      "*": "ask",
      "~/workspace/roger-projects/**": "allow"
    }
  }
}
```

Important: OpenCode evaluates permission matches in an order-sensitive way. If your local version behaves differently, validate with a harmless dry run before enabling autonomous workflows.

## 4. Optional Playwright MCP

Add this manually only when you want browser/UI validation:

```json
{
  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp"],
      "enabled": true
    }
  }
}
```

## 5. Register product repositories

Copy the example registry:

```text
.omni/orchestrator.config.example.json -> .omni/orchestrator.config.json
```

Then replace example values with real private GitHub SSH URLs and local paths.

The user must create those GitHub repositories manually before registration.

## 6. Restart OpenCode

OpenCode loads config, agents, and skills at startup. After changing `opencode.json`, `.opencode/agent/*.md`, or `.opencode/skills/**/SKILL.md`, quit and restart OpenCode.

## 7. Agent operating contract

All agents reference `.omni/agent-operating-contract.md`. Keep this file aligned with your desired safety, anti-hallucination, repository, and response-shape rules. If you change it, restart OpenCode so future sessions have the updated context available through the agent prompts and skills.
