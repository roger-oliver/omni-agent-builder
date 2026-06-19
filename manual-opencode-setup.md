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

If your vLLM server exposes a different model name, update the agent files or configure an equivalent provider/model alias manually.

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
