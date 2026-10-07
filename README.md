# Omni-Agent-Builder

**An OpenCode-based software factory: 39 specialized AI agents, 19 reusable skills, and enforceable SDLC policies that orchestrate the full product lifecycle — business context, requirements, architecture, data/API design, UI/UX, implementation (Rust/Python/C#/Vue/React), testing, security, observability, releases, and legacy reverse-engineering — across user-registered GitHub repositories, with human-approval gates and decision-log discipline built in.**

Omni-Agent-Builder is a meta-project: it configures the agent system only. It must not contain generated product frontend code, backend code, UI assets, legacy source code, or product decision logs. Product work happens in separate private GitHub repositories created by the user and registered with the orchestrator.

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
- 39 OpenCode agent prompt files under `.opencode/agent/`
- 19 reusable OpenCode skills under `.opencode/skills/`
- Global setup scripts under `scripts/` (installer + interactive project setup for bash and fish)
- `docs/vocabulary.md` (shared jargon glossary) and `docs/agent-skill-audit-2026-09-28.md` (revision tracking)

## Installation

Clone this repository and run the installer once per machine. It installs the
project-setup scripts globally so `setup-omni` (bash) and `setup-omni.fish`
work from any directory:

```bash
# Bash/Zsh — clone to any directory you like; the path below is just an example
git clone <repo-url> ~/omni-agent-builder
cd ~/omni-agent-builder
./scripts/install.sh

# Fish — same, the path is an example
git clone <repo-url> ~/omni-agent-builder
cd ~/omni-agent-builder
./scripts/install.fish
```

What the installer does:

| Step | Target |
|------|--------|
| Copy setup scripts | `~/.config/opencode/setup-omni-project.{sh,fish}` |
| Copy registry schema | `~/.config/opencode/instructions/repo-registry.schema.json` (only if missing) |
| Create PATH links | `~/.local/bin/setup-omni` → bash script |
| | `~/.local/bin/setup-omni.fish` → fish script |
| Check PATH | warns if `~/.local/bin` is not on `PATH` |

Then create any new project:

```bash
mkdir my-project && cd my-project
setup-omni            # bash/zsh
setup-omni.fish       # fish
```

The setup script asks for the project name, GitHub org (placeholder allowed),
a **required** base clone path (any directory you choose — no default), and
which repos to register, then generates the minimal Omni
structure:

```text
my-project/
├── opencode.json
└── .omni/
    ├── orchestrator.config.json
    └── repo-registry.schema.json
```

## Design Principles

- OpenCode-native first: use agents, skills, permissions, commands, providers, and MCP before custom plugins.
- Repositories are user-created only; agents must never create GitHub repositories.
- Registered product repos are cloned under the clone base path you choose (configured in `.omni/orchestrator.config.json`).
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
├── scripts/
│   ├── install.sh                     # Global installer (bash)
│   ├── install.fish                   # Global installer (fish)
│   ├── setup-omni-project.sh          # Interactive project setup (bash)
│   ├── setup-omni-project.fish        # Interactive project setup (fish)
│   └── apply-repo-security.sh         # Branch protection + repo hardening
├── SECURITY.md                        # Vulnerability reporting + contribution rules
├── .github/
│   ├── workflows/validate.yml         # PR CI gate (structure + secret scan)
│   ├── dependabot.yml                 # Actions updates
│   ├── CODEOWNERS                     # @roger-oliver reviews everything
│   ├── pull_request_template.md
│   ├── CODE_OF_CONDUCT.md
│   └── ISSUE_TEMPLATE/                # Bug/feature forms; blank issues disabled
├── docs/
│   ├── vocabulary.md                  # Shared jargon glossary
│   └── agent-skill-audit-2026-09-28.md  # Agent/skill revision tracking
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
    │   └── 39 agent prompt files
    └── skills/
        └── 19 reusable skill folders
```

## Important Files

### `opencode.json`

Root OpenCode configuration. Sets the default agent to `omni-orchestrator`, configures providers (Xiaomi MiMo, OpenCode Zen), loads skills from `.opencode/skills`, and defines security permissions (deny force-push, repo creation, `rm -rf`; allow read/glob/grep; ask for edit/bash/webfetch).

### `blueprint.md`

The authoritative project blueprint. It describes the purpose, repository model, security policy, OpenCode strategy, agent roster, GitHub workflow, PR validation loop, decision logging, dependency policy, legacy analysis policy, and implementation roadmap.

### `manual-opencode-setup.md`

Manual setup instructions for OpenCode. This includes provider configuration for Xiaomi MiMo and OpenCode Zen, permissions, and skill loading guidance.

### `.omni/orchestrator.config.example.json`

Example Omni repo registry. Copy it to `.omni/orchestrator.config.json` when onboarding real product repositories, then replace example values with real private GitHub SSH URLs and local paths.

### `.omni/orchestrator.config.json`

Active repo registry. The orchestrator reads this at runtime to know which product repos exist, their SSH URLs, local paths, branch strategy, and GitHub settings. Update this file with real values before starting product work.

### `.omni/repo-registry.schema.json`

JSON schema for validating the Omni repo registry.

### `.omni/agent-operating-contract.md`

Shared non-negotiable behavior contract for all agents. It defines source-of-truth hierarchy, anti-hallucination rules, required response shape, safety rules, repository checklist, and artifact quality bar.

### `.omni/model-allocation-policy.md`

Three-tier model routing over Chinese cloud models only (no Anthropic, no local runtimes). `mimo/mimo-v2.6-pro` for deep-reasoning agents, `mimo/mimo-v2.6-flash` for code/test generation, `opencode/deepseek-v4.1-flash` for routing and lightweight operations — all with 1M-token context windows.

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
- `data-migration-engineer`
- `unit-test-generator`
- `e2e-test-engineer`

Legacy reverse-engineering agents:

- `legacy-python-analyst`
- `legacy-csharp-analyst`
- `schema-extractor`

Security and compliance agents:

- `sast-scanner`
- `dast-tester`
- `dependency-auditor`
- `privacy-compliance-reviewer`

QA and performance agents:

- `integration-tester`
- `load-simulator`
- `qa-validator`
- `uat-mimic`
- `accessibility-auditor`

DevOps, release, and observability agents:

- `pipeline-engineer`
- `rollback-manager`
- `release-manager`
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

Reusable skills currently defined (19):

Process and governance:

- `agent-operating-contract`: shared anti-hallucination, safety, response-shape, and artifact-quality rules.
- `sdlc-handoffs`: phase gates G1–G12, handoff packet fields, artifact paths.
- `id-traceability`: `BC/UC/REQ/NFR/AC/TC/DEF/ADR` ID scheme and RTM schema.
- `stack-selection`: the always-ask stack rule and decision matrix.
- `adr-writing`: ADR creation, status transitions, failed-approach ADRs.
- `github-workflow`: registered repo, branch/PR conventions, merge-commit rules, `GITHUB_TOKEN` workflow.
- `dependency-selection`: package/framework selection with SPDX license posture and audit tools.
- `docs-structure`: documentation information architecture and release-notes template.
- `legacy-analysis`: read-only As-Is documentation for legacy repos.

Craft and quality:

- `model-allocation`: three-tier Chinese cloud model routing (MiMo 2.6 Pro, MiMo 2.6 Flash, DeepSeek V4 Flash).
- `requirements-quality`: Gherkin acceptance criteria, NFR taxonomy, testability lint.
- `api-design`: REST conventions, error envelope, pagination, idempotency, versioning.
- `data-modeling`: naming rules, expand/contract migrations, data lifecycle.
- `test-strategy`: test pyramid, traceability tags, synthetic-only test data.
- `security-review`: severity taxonomy, findings table, OWASP mapping, secret patterns.
- `observability-standards`: log schema, OpenTelemetry, SLI/SLO, no-alert-without-runbook.
- `ui-ux-standards`: WCAG 2.2 AA checklist, W3C design tokens, state matrix.
- `cicd-release`: required pipeline jobs, promotion gates, SemVer, rollback matrix.
- `pr-validation`: 10-row PR validation checklist and the bounded fix loop.

## OpenCode Configuration

`opencode.json` is included in this repo with the following defaults:

- Default agent: `omni-orchestrator`
- Default model: `mimo/mimo-v2.6-flash`
- Small model: `opencode/deepseek-v4.1-flash`
- Skills path: `.opencode/skills`
- Providers: Xiaomi MiMo (`mimo/...`), OpenCode Zen (`opencode/...`)
- Security permissions: deny force-push, repo creation, `rm -rf`; allow read/glob/grep; ask for edit/bash/webfetch
- External directory access: the example clone base path `~/omni-projects/**` is allowed; if you chose a different base directory, update this allow in `opencode.json` (otherwise agents will simply ask for permission each time)

To customize, edit `opencode.json` directly or refer to `manual-opencode-setup.md` for the full configuration reference.

Required environment variables:

```text
GITHUB_TOKEN
XIAOMI_MIMO_API_KEY
OPENCODE_ZEN_API_KEY
```

- `GITHUB_TOKEN` is used for GitHub API operations only; SSH keys handle Git clone/fetch/push.
- `XIAOMI_MIMO_API_KEY` authenticates the `mimo` provider (Xiaomi MiMo API).
- `OPENCODE_ZEN_API_KEY` authenticates the `opencode` provider (OpenCode Zen).
- Do not commit real secret values.

### Model Allocation (3 tiers)

All Omni agents run on Chinese cloud models. Anthropic models and local runtimes (vLLM, Ollama, llama.cpp) are excluded by decision. Zen `-free` tiers are excluded because of daily usage limits and data-usage terms.

| Tier | Model | $/1M in / out | Context | Used for |
|---|---|---|---|---|
| T1 Thinkers | `mimo/mimo-v2.6-pro` | $0.435 / $0.87 | 1M tokens | Strategy, requirements, architecture, schema/API design, UI/UX, legacy analysis, security analysis, PR validation |
| T2 Builders | `mimo/mimo-v2.6-flash` | $0.14 / $0.28 | 1M tokens | Backend/frontend code generation, unit tests, QA, DevOps, observability, documentation, schema extraction |
| T3 Operators | `opencode/deepseek-v4.1-flash` | $0.30 / $1.20 | 1M tokens | Orchestration routing, codebase search, traceability, GitHub API operations |

| Work type | Model | Tier |
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

Rules:

- Every model ID must include its provider prefix (`mimo/...` or `opencode/...`).
- If a configured model is unavailable, stop and ask; never substitute silently.
- Keep model IDs in sync across agent frontmatter, `.omni/model-allocation-policy.md`, `opencode.json`, and `manual-opencode-setup.md`.
- A 1M-token context is a limit, not permission to load entire repositories blindly.

After creating or changing OpenCode config, agents, skills, or plugins, restart OpenCode. OpenCode loads these files at startup.

## Product Repository Onboarding

1. User creates private GitHub repositories manually.
2. User provides SSH URLs to the orchestrator.
3. Copy `.omni/orchestrator.config.example.json` to `.omni/orchestrator.config.json`.
4. Replace example repo URLs and paths.
5. Product repositories are cloned under the clone base path you chose (see `.omni/orchestrator.config.json`).
6. Agents work only with registered repositories.

Typical product repositories:

- Decision/control repo: requirements, ADRs, traceability, release notes.
- UI design repo: wireframes, UX specs, design tokens, prototypes.
- Frontend repo: Vue or React source code.
- Backend repo: Rust, Python, or C# source code.
- Optional legacy repo: cloned source for read-only As-Is analysis.

## Repository Security

This repo configures autonomous coding agents, so contributions are treated as
a security boundary. Current protections:

| Layer | Control |
|---|---|
| Contribution path | Fork + pull request only. Branch protection on `main` and `develop` requires 1 approving review, `CODEOWNERS` approval, and a passing `omni-validate` status check. Direct pushes are blocked for everyone except the owner (`enforce_admins: false`). |
| Merge policy | Merge commits only. Squash and rebase merges are disabled repo-wide (see `.omni/github-policy.md`). |
| History safety | Force-push and branch deletion blocked on protected branches. Conversation resolution required before merge. |
| CI gate | `.github/workflows/validate.yml`: JSON validity, agent structure, skill frontmatter, deterministic secret-pattern scan. |
| Secrets | `.gitignore` blocks `.env`, keys, and credential files. CI fails on committed secret patterns. Env var **names** only (`.omni/agent-operating-contract.md`). |
| Vulnerability intake | `SECURITY.md` + private vulnerability reporting. Blank issues disabled; structured bug/feature templates route security reports away from the public issue tracker. |
| Dependency updates | Dependabot for GitHub Actions (weekly). |
| Attack surface | Wiki and Projects disabled. Auto-merge disabled. Branches deleted on merge. |

Apply or audit the protection rules:

```bash
./scripts/apply-repo-security.sh          # apply (needs PAT with repo admin)
./scripts/apply-repo-security.sh --check  # report current state
```

The script requires the repo to be included in your GitHub fine-grained PAT
with **Administration: Read and write**. It prints exact instructions if not.

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
- Auto-merge passing PRs to `develop` using **merge commits** (the only allowed merge method — no squash, no rebase-merge).

Forbidden unless policy changes:

- Create repositories.
- Delete repositories.
- Force-push.
- Squash or rebase merges.
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
./scripts/apply-repo-security.sh --check   # remote protection state
```

## Notes for Future Builders

- Do not generate product code in this repo.
- Do not commit secrets.
- Keep agent files focused and separate.
- Ask before adding optional plugins.
- Validate OpenCode config against `https://opencode.ai/config.json` after changes.
- After editing `opencode.json`, `.opencode/agent/*.md`, or `.opencode/skills/**/SKILL.md`, restart OpenCode.
