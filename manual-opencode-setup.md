# Manual OpenCode Setup

This project intentionally does not create or modify `opencode.json` automatically. Apply the configuration manually when you are ready.

## 1. Required environment variables

Set these outside the repo, for example in your shell profile, secret manager, or process environment:

```text
GITHUB_TOKEN
XIAOMI_MIMO_API_KEY
OPENCODE_ZEN_API_KEY
```

Notes:

- `GITHUB_TOKEN` is used for GitHub API operations.
- SSH keys are still used for Git clone/fetch/push.
- `XIAOMI_MIMO_API_KEY` authenticates the `mimo` provider (Xiaomi MiMo API, used for `mimo/mimo-v2.6-pro` and `mimo/mimo-v2.6-flash`).
- `OPENCODE_ZEN_API_KEY` authenticates the `opencode` provider (OpenCode Zen, used for `opencode/deepseek-v4.1-flash` and fallback models).
- Do not commit real secret values.

## 2. Model IDs

Omni uses Chinese cloud models only — no Anthropic models, no local runtimes (vLLM/Ollama/llama.cpp), and no Zen `-free` tiers (daily usage limits; data may be used for model improvement).

The configured model IDs are:

```text
mimo/mimo-v2.6-pro        # T1 Thinkers  - $0.435/$0.87 per 1M tokens, 1M context
mimo/mimo-v2.6-flash      # T2 Builders  - $0.14/$0.28 per 1M tokens, 1M context
opencode/deepseek-v4.1-flash # T3 Operators - $0.30/$1.20 per 1M tokens, 1M context
```

Every model ID must include its provider prefix. Keep these IDs in sync across agent frontmatter, `.omni/model-allocation-policy.md`, and `opencode.json`. If a configured model is unavailable, stop and ask; never substitute silently.

## 2.1 Model allocation

| Agent/work type | Model | Tier |
|---|---|---|
| Orchestration | `opencode/deepseek-v4.1-flash` | T3 |
| Strategy and definition | `mimo/mimo-v2.6-pro` | T1 |
| Design and architecture | `mimo/mimo-v2.6-pro` | T1 |
| UI/UX design | `mimo/mimo-v2.6-pro` | T1 |
| Legacy analysis | `mimo/mimo-v2.6-pro` | T1 |
| Security analysis (SAST/DAST, dependencies) | `mimo/mimo-v2.6-pro` | T1 |
| PR validation | `mimo/mimo-v2.6-pro` | T1 |
| Backend/frontend code generation | `mimo/mimo-v2.6-flash` | T2 |
| Unit test generation | `mimo/mimo-v2.6-flash` | T2 |
| QA and performance testing | `mimo/mimo-v2.6-flash` | T2 |
| DevOps and release | `mimo/mimo-v2.6-flash` | T2 |
| Observability | `mimo/mimo-v2.6-flash` | T2 |
| Documentation | `mimo/mimo-v2.6-flash` | T2 |
| Codebase exploration | `opencode/deepseek-v4.1-flash` | T3 |
| Traceability governance | `opencode/deepseek-v4.1-flash` | T3 |
| GitHub operations | `opencode/deepseek-v4.1-flash` | T3 |

Current agent defaults:

```text
solution-architect      -> mimo/mimo-v2.6-pro
ui-ux-designer          -> mimo/mimo-v2.6-pro
codebase-explorer       -> opencode/deepseek-v4.1-flash
technical-writer        -> mimo/mimo-v2.6-flash
```

See `.omni/model-allocation-policy.md` for the complete per-agent roster, deprecated-model list, and the optional `opencode/kimi-k2.7-code` experiment note.

## 3. Suggested `opencode.json`

Create this manually in the repository root or merge it into your existing OpenCode config.

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "mimo/mimo-v2.6-flash",
  "small_model": "opencode/deepseek-v4.1-flash",
  "default_agent": "omni-orchestrator",
  "provider": {
    "mimo": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "MiMo",
      "options": {
        "baseURL": "https://token-plan-ams.xiaomimimo.com/v1",
        "apiKey": "{env:XIAOMI_MIMO_API_KEY}"
      },
      "models": {
        "mimo-v2.6-pro": {
          "name": "mimo-v2.6-pro",
          "limit": { "context": 1048576, "output": 131072 },
          "modalities": { "input": ["text", "image", "video", "audio"], "output": ["text"] }
        },
        "mimo-v2.6-flash": {
          "name": "mimo-v2.6-flash",
          "limit": { "context": 1048576, "output": 131072 },
          "modalities": { "input": ["text", "image", "video", "audio"], "output": ["text"] }
        }
      }
    },
    "opencode": {
      "name": "OpenCode Zen",
      "options": {
        "baseURL": "https://opencode.ai/zen/v1",
        "apiKey": "{env:OPENCODE_ZEN_API_KEY}"
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
