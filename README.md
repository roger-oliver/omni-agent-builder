# Omni-Agent-Builder

Omni-Agent-Builder is a meta-project for defining an OpenCode-based software factory. It contains agent prompts, reusable skills, policy documents, and setup guidance for coordinating specialized AI agents across the full software development lifecycle.

This repository is for the **agent system only**. It must not contain generated product frontend code, backend code, UI assets, legacy source code, or product decision logs. Product work happens in separate private GitHub repositories created by the user and registered with the orchestrator.

## Current Status

Implemented in this repo:

- Final blueprint: `blueprint.md`
- Manual OpenCode setup guide: `manual-opencode-setup.md`
- Omni policy/config templates under `.omni/`
- Shared anti-hallucination and operating contract: `.omni/agent-operating-contract.md`
- 34 OpenCode agent prompt files under `.opencode/agent/`
- 7 reusable OpenCode skills under `.opencode/skills/`

No `opencode.json` is committed. OpenCode configuration is intentionally left for manual setup.

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
├── blueprint.md
├── initial-blueprint.md
├── manual-opencode-setup.md
├── .omni/
│   ├── orchestrator.config.example.json
│   ├── repo-registry.schema.json
│   ├── stack-policy.md
│   ├── dependency-selection-policy.md
│   ├── github-policy.md
│   ├── decision-log-policy.md
│   ├── model-allocation-policy.md
    │   └── legacy-analysis-policy.md
└── .opencode/
    ├── agent/
    │   └── 34 agent prompt files
    └── skills/
        └── 7 reusable skill folders
```

## Important Files

### `blueprint.md`

The authoritative project blueprint. It describes the purpose, repository model, security policy, OpenCode strategy, agent roster, GitHub workflow, PR validation loop, decision logging, dependency policy, legacy analysis policy, and implementation roadmap.

### `manual-opencode-setup.md`

Manual setup instructions for OpenCode. This includes suggested provider configuration for vLLM, OpenAI, Anthropic, and Google, plus permissions and skill loading guidance.

### `.omni/orchestrator.config.example.json`

Example Omni repo registry. Copy it to `.omni/orchestrator.config.json` when onboarding real product repositories, then replace example values with real private GitHub SSH URLs and local paths.

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

## Manual OpenCode Configuration

This repo intentionally does not include `opencode.json`. Create it manually using `manual-opencode-setup.md` when ready.

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
- Primary local model: GadflyII/Qwen3-Coder-Next-NVFP4 with **131072-token context**
- Shared local model for unit-test generation and SAST assistance: GadflyII/Qwen3-Coder-Next-NVFP4
- Cloud provider placeholders: OpenAI, Anthropic, Google

Recommended model allocation:

| Work type | Recommended model | Location |
|---|---|---|
| Orchestration | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context |
| Backend/frontend code generation | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context |
| PR validation/code review | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context |
| Unit test generation | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context |
| SAST assistance | Rule engine + GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context |
| UI/UX design | Gemini 3 Pro | Cloud |
| Complex architecture | GPT-5.5 or Claude Sonnet 4.6 | Cloud |
| Codebase exploration | Claude Haiku 4.5 | Cloud |
| Documentation/librarian | Claude Sonnet 4.6 | Cloud |

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
python3 -m json.tool .omni/orchestrator.config.example.json >/tmp/orchestrator-config-check.json
python3 -m json.tool .omni/repo-registry.schema.json >/tmp/repo-schema-check.json
git diff --check
```

## Notes for Future Builders

- Do not generate product code in this repo.
- Do not create or edit `opencode.json` unless the user explicitly asks.
- Do not commit secrets.
- Keep agent files focused and separate.
- Ask before adding optional plugins.
- Validate OpenCode config manually against `https://opencode.ai/config.json` if/when config is created.
