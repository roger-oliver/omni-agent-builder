# Omni-Agent-Builder

Omni-Agent-Builder is a meta-project for defining an OpenCode-based software factory. It contains agent prompts, reusable skills, policy documents, and setup guidance for coordinating specialized AI agents across the full software development lifecycle.

This repository is for the **agent system only**. It must not contain generated product frontend code, backend code, UI assets, legacy source code, or product decision logs. Product work happens in separate private GitHub repositories created by the user and registered with the orchestrator.

## Current Status

Implemented in this repo:

- Final blueprint: `blueprint.md`
- Manual OpenCode setup guide: `manual-opencode-setup.md`
- `opencode.json`: root OpenCode configuration (default agent, providers, permissions, skills)
- `.omni/orchestrator.config.json`: active repo registry for product repositories
- `.omni/orchestrator.config.example.json`: example/template repo registry
- `.omni/repo-registry.schema.json`: JSON schema for validating the registry
- Omni policies under `.omni/` (stack, dependency, GitHub, decision-log, model-allocation, legacy-analysis)
- Shared anti-hallucination and operating contract: `.omni/agent-operating-contract.md`
- 34 OpenCode agent prompt files under `.opencode/agent/`
- 7 reusable OpenCode skills under `.opencode/skills/`

## Design Principles

- OpenCode-native first: use agents, skills, permissions, commands, providers, and MCP before custom plugins.
- Repositories are user-created only; agents must never create GitHub repositories.
- Registered product repos are cloned under `~/workspace/roger-projects/<repo>`.
- GitHub API operations use `GITHUB_TOKEN` only.
- SSH keys are used for Git clone/fetch/push.
- Secrets must be environment variables and must never be committed.
- Stack selection is interactive; the orchestrator asks the user every time.
- Engineering agents are language-specialized but not framework-locked.
- Passing PRs may auto-merge into `develop`.
- Merge to `main`, production deployment, rollback execution, repo creation, repo deletion, and force-push remain human-approved.

## Repository Layout

```text
.
├── README.md
├── opencode.json                  # Root OpenCode configuration
├── blueprint.md
├── initial-blueprint.md
├── manual-opencode-setup.md
├── .omni/
│   ├── orchestrator.config.json          # Active repo registry
│   ├── orchestrator.config.example.json  # Example/template repo registry
│   ├── repo-registry.schema.json
│   ├── agent-operating-contract.md
│   ├── model-allocation-policy.md
│   ├── stack-policy.md
│   ├── dependency-selection-policy.md
│   ├── github-policy.md
│   ├── decision-log-policy.md
│   └── legacy-analysis-policy.md
└── .opencode/
    ├── agent/
    │   └── 34 agent prompt files
    └── skills/
        └── 7 reusable skill folders
```

## Important Files

### `opencode.json`

Root OpenCode configuration. Sets the default agent to `omni-orchestrator`, configures providers (vLLM, OpenAI, Anthropic, Google), loads skills from `.opencode/skills`, and defines security permissions (deny force-push, repo creation, `rm -rf`; allow read/glob/grep; ask for edit/bash/webfetch).

### `blueprint.md`

The authoritative project blueprint. It describes the purpose, repository model, security policy, OpenCode strategy, agent roster, GitHub workflow, PR validation loop, decision logging, dependency policy, legacy analysis policy, and implementation roadmap.

### `manual-opencode-setup.md`

Manual setup instructions for OpenCode. This includes suggested provider configuration for vLLM, OpenAI, Anthropic, and Google, plus permissions and skill loading guidance.

### `.omni/orchestrator.config.example.json`

Example Omni repo registry. Copy it to `.omni/orchestrator.config.json` when onboarding real product repositories, then replace example values with real private GitHub SSH URLs and local paths.

### `.omni/orchestrator.config.json`

Active repo registry. The orchestrator reads this at runtime to know which product repos exist, their SSH URLs, local paths, branch strategy, and GitHub settings. Update this file with real values before starting product work.

### `.omni/repo-registry.schema.json`

JSON schema for validating the Omni repo registry.

### `.omni/agent-operating-contract.md`

Shared non-negotiable behavior contract for all agents. It defines source-of-truth hierarchy, anti-hallucination rules, required response shape, safety rules, repository checklist, and artifact quality bar.

### `.omni/model-allocation-policy.md`

Hybrid local/cloud model routing guidance. It emphasizes the local GadflyII/Qwen3-Coder-Next-NVFP4 vLLM model's **131072-token context window** while assigning complex architecture, UI/UX, codebase exploration, and documentation/librarian work to appropriate cloud models.

### `.opencode/agent/`

Contains one Markdown file per OpenCode agent.

### `.opencode/skills/`

Contains reusable OpenCode skills shared by agents.

## Agent Roster

Primary agent:

- `omni-orchestrator`

Strategy and definition agents:

- `business-interpreter`
- `use-case-modeler`
- `prioritization-agent`
- `requirements-writer`

Design and architecture agents:

- `solution-architect`
- `data-schema-modeler`
- `api-contract-designer`
- `ui-ux-designer`

Implementation agents:

- `frontend-vue-engineer`
- `frontend-react-engineer`
- `backend-rust-engineer`
- `backend-python-engineer`
- `backend-csharp-engineer`
- `unit-test-generator`

Legacy reverse-engineering agents:

- `legacy-python-analyst`
- `legacy-csharp-analyst`
- `schema-extractor`

Security agents:

- `sast-scanner`
- `dast-tester`
- `dependency-auditor`

QA and performance agents:

- `integration-tester`
- `load-simulator`
- `qa-validator`
- `uat-mimic`

DevOps, release, and observability agents:

- `pipeline-engineer`
- `rollback-manager`
- `logging-strategist`
- `alerting-monitor`

Governance and documentation agents:

- `traceability-keeper`
- `technical-writer`

GitHub and PR agents:

- `codebase-explorer`
- `github-operator`
- `pr-validator`

## Skills

Reusable skills currently defined:

- `agent-operating-contract`: shared anti-hallucination, safety, response-shape, and artifact-quality rules.
- `model-allocation`: local/cloud model routing, including the shared local GadflyII/Qwen3-Coder-Next-NVFP4 131072-token context model and cloud specialist models.
- `adr-writing`: creating and updating Architecture Decision Records.
- `github-workflow`: registered repo, branch, PR, and `GITHUB_TOKEN` workflow.
- `dependency-selection`: package/framework selection without lock-in.
- `legacy-analysis`: read-only As-Is documentation for legacy repos.
- `pr-validation`: PR validation against requirements, ADRs, tests, security, and traceability.

## OpenCode Configuration

`opencode.json` is included in this repo with the following defaults:

- Default agent: `omni-orchestrator`
- Primary model: `vllm/GadflyII/Qwen3-Coder-Next-NVFP4` (131072-token context)
- Skills path: `.opencode/skills`
- Providers: vLLM (local), OpenAI, Anthropic, Google
- Security permissions: deny force-push, repo creation, `rm -rf`; allow read/glob/grep; ask for edit/bash/webfetch

To customize, edit `opencode.json` directly or refer to `manual-opencode-setup.md` for the full configuration reference.

Required or likely environment variables:

```text
GITHUB_TOKEN
VLLM_BASE_URL
VLLM_API_KEY
OPENAI_API_KEY
ANTHROPIC_API_KEY
GOOGLE_GENERATIVE_AI_API_KEY
```

Suggested OpenCode defaults:

- Default agent: `omni-orchestrator`
- Skills path: `.opencode/skills`
- Local model provider: vLLM using OpenAI-compatible API
- Primary local model: GadflyII/Qwen3-Coder-Next-NVFP4 with **131072-token context** (orchestrator, PR validation, unit tests, SAST)
- Secondary local model: Qwen/Qwen3.8-27B (implementation, QA, DevOps, observability, GitHub)
- Cloud provider placeholders: OpenAI, Anthropic, Google

Recommended model allocation:

| Work type | Recommended model | Location |
|---|---|---|
| Orchestration | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context |
| PR validation/code review | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context |
| Unit test generation | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context |
| SAST assistance | Rule engine + GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context |
| Strategy and definition | Claude Sonnet 4.6 | Cloud |
| Design and architecture | Claude Sonnet 4.6 | Cloud |
| Legacy analysis | Claude Sonnet 4.6 | Cloud |
| Security scanning (DAST, deps) | Claude Sonnet 4.6 | Cloud |
| UI/UX design | Gemini 3 Pro | Cloud |
| Codebase exploration | Claude Haiku 4.5 | Cloud |
| Traceability governance | Claude Haiku 4.5 | Cloud |
| Documentation/librarian | Claude Sonnet 4.6 | Cloud |
| Backend/frontend code generation | Qwen/Qwen3.8-27B | Local vLLM |
| QA and performance testing | Qwen/Qwen3.8-27B | Local vLLM |
| DevOps and release | Qwen/Qwen3.8-27B | Local vLLM |
| Observability | Qwen/Qwen3.8-27B | Local vLLM |
| GitHub operations | Qwen/Qwen3.8-27B | Local vLLM |

Before finalizing the model config, query your vLLM endpoint and confirm the real model ID:

```text
GET {VLLM_BASE_URL}/models
```

After creating or changing OpenCode config, agents, skills, or plugins, restart OpenCode. OpenCode loads these files at startup.

## Product Repository Onboarding

1. User creates private GitHub repositories manually.
2. User provides SSH URLs to the orchestrator.
3. Copy `.omni/orchestrator.config.example.json` to `.omni/orchestrator.config.json`.
4. Replace example repo URLs and paths.
5. Product repositories are cloned under `~/workspace/roger-projects/<repo>`.
6. Agents work only with registered repositories.

Typical product repositories:

- Decision/control repo: requirements, ADRs, traceability, release notes.
- UI design repo: wireframes, UX specs, design tokens, prototypes.
- Frontend repo: Vue or React source code.
- Backend repo: Rust, Python, or C# source code.
- Optional legacy repo: cloned source for read-only As-Is analysis.

## GitHub Workflow

Recommended branch flow:

```text
feature/<requirement-id>-short-title -> develop -> release/<version> -> main
```

Allowed after repo registration:

- Clone registered repos.
- Create feature branches from `develop`.
- Commit and push feature branches.
- Open PRs to `develop`.
- Comment, label, approve, and validate PRs.
- Auto-merge passing PRs to `develop`.

Forbidden unless policy changes:

- Create repositories.
- Delete repositories.
- Force-push.
- Change repository visibility.
- Change branch protection.
- Merge to `main` without human approval.

## PR Validation Loop

1. Builder agent implements a requirement on a feature branch.
2. Builder opens a PR to `develop`.
3. `pr-validator` inspects the PR, requirements, acceptance criteria, ADRs, tests, security, dependencies, and traceability.
4. If validation fails, it comments exact failures and routes the PR back for fixes.
5. Builder pushes fixes to the same branch.
6. `pr-validator` reviews again.
7. When validation passes, the PR may be merged automatically into `develop`.
8. Merge to `main` remains human-approved.

## Verification Commands

Useful local checks for this repository:

```bash
python3 -m json.tool opencode.json >/dev/null
python3 -m json.tool .omni/orchestrator.config.json >/dev/null
python3 -m json.tool .omni/orchestrator.config.example.json >/dev/null
python3 -m json.tool .omni/repo-registry.schema.json >/dev/null
git diff --check
```

## Notes for Future Builders

- Do not generate product code in this repo.
- Do not commit secrets.
- Keep agent files focused and separate.
- Ask before adding optional plugins.
- Validate OpenCode config against `https://opencode.ai/config.json` after changes.
- After editing `opencode.json`, `.opencode/agent/*.md`, or `.opencode/skills/**/SKILL.md`, restart OpenCode.
