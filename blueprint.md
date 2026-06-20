# Blueprint: Omni-Agent-Builder

## 1. Purpose

Omni-Agent-Builder is a meta-project whose only responsibility is to configure OpenCode and define a complete set of specialized agents for creating, maintaining, documenting, reviewing, and reverse-engineering software products.

This repository is not a product-code repository. It must not contain generated frontend, backend, UI, or decision-log artifacts for the products built by the agents. Those artifacts live in separate GitHub repositories created on demand by the user and then registered with the orchestrator.

The intended result is an OpenCode-based software factory where a primary orchestrator coordinates many specialized agents across requirements, architecture, UI, frontend, backend, testing, security, DevOps, observability, documentation, GitHub operations, and PR validation.

## 2. Core Principles

1. **OpenCode-native first**: Use OpenCode agents, skills, commands, permissions, provider configuration, and MCP integration before introducing custom plugins.
2. **Separate concerns**: Keep agent-system configuration, decision logs, UI design, frontend code, backend code, and legacy source code in separate repositories.
3. **User-created repositories only**: Agents must never create GitHub repositories. The orchestrator asks the user to create private repos and then records the repo information.
4. **Automatic GitHub workflow after registration**: Once repos are registered, agents may automatically clone, branch, commit, push, open PRs, comment on PRs, validate PRs, and merge passing PRs into `develop`.
5. **Human gate for critical operations**: Merges to `main`, production deployment, rollback execution, repo creation, repo deletion, and force-push remain human-approved.
6. **Stack selection is interactive**: The orchestrator must ask the user which stack to use for each product or major feature. It may recommend, but not silently decide.
7. **Language-specialized, not framework-locked**: Engineering agents specialize by language or frontend ecosystem, but must not be hardcoded to one framework/package. They inspect the repo, recommend current stable/LTS options, explain tradeoffs, ask before major dependencies, and record decisions.
8. **Decision records are first-class artifacts**: Important human and agent decisions are documented in a separate decision/control repo using ADR-style Markdown documents.
9. **Secrets are environment variables**: Secrets must not be committed. OpenCode and Omni config files may reference environment variables, but must not contain raw secret values.
10. **GitHub API access uses `GITHUB_TOKEN` only**: SSH keys are used for Git clone/push. GitHub API operations such as PR creation/comments/labels/merge should use `GITHUB_TOKEN`.

## 3. Target Repository Model

All product-related repositories should be cloned under:

```text
~/workspace/roger-projects/<repo>
```

Example product workspace:

```text
~/workspace/roger-projects/my-product-decisions
~/workspace/roger-projects/my-product-ui
~/workspace/roger-projects/my-product-frontend
~/workspace/roger-projects/my-product-backend
~/workspace/roger-projects/my-product-legacy
```

The user creates private GitHub repositories on demand and provides the SSH URLs to the orchestrator. The orchestrator records them in an Omni-specific config file, not in `opencode.json`.

Recommended file:

```text
.omni/orchestrator.config.json
```

Conceptual shape:

```json
{
  "projects": {
    "example-product": {
      "clone_base_path": "~/workspace/roger-projects",
      "stack_selection_mode": "always_ask",
      "repos": {
        "decision_logs": {
          "ssh_url": "git@github.com:org/example-product-decisions.git",
          "local_path": "~/workspace/roger-projects/example-product-decisions",
          "purpose": "strategy, requirements, ADRs, traceability, release notes"
        },
        "ui_design": {
          "ssh_url": "git@github.com:org/example-product-ui.git",
          "local_path": "~/workspace/roger-projects/example-product-ui",
          "purpose": "wireframes, design tokens, UX specs, exported prototypes"
        },
        "frontend": {
          "ssh_url": "git@github.com:org/example-product-frontend.git",
          "local_path": "~/workspace/roger-projects/example-product-frontend",
          "purpose": "frontend source code"
        },
        "backend": {
          "ssh_url": "git@github.com:org/example-product-backend.git",
          "local_path": "~/workspace/roger-projects/example-product-backend",
          "purpose": "backend source code"
        },
        "legacy": {
          "ssh_url": "git@github.com:org/example-product-legacy.git",
          "local_path": "~/workspace/roger-projects/example-product-legacy",
          "purpose": "legacy source code for as-is analysis"
        }
      },
      "branch_strategy": {
        "development": "develop",
        "release_prefix": "release/",
        "production": "main"
      },
      "github": {
        "api_auth_env": "GITHUB_TOKEN",
        "auto_merge_to_develop": true,
        "human_approval_required_for_main": true
      }
    }
  }
}
```

This file is Omni-specific. It must not be placed directly inside `opencode.json` because OpenCode validates its config strictly and rejects unknown top-level keys.

## 4. Secret and Environment Variable Policy

All secrets must be provided through environment variables. Config files may reference variable names but must not contain raw values.

Required or likely environment variables:

```text
GITHUB_TOKEN
OPENAI_API_KEY
ANTHROPIC_API_KEY
GOOGLE_GENERATIVE_AI_API_KEY
VLLM_BASE_URL
VLLM_API_KEY
```

Optional environment variables for future integrations:

```text
POSTGRES_READONLY_URL
SQLSERVER_READONLY_URL
REDIS_URL
RABBITMQ_URL
AZURE_OPENAI_API_KEY
AZURE_OPENAI_ENDPOINT
```

Rules:

- No agent may write secret values to Markdown docs, ADRs, logs, shell history snippets, PR comments, or config files.
- Database analysis must use read-only credentials only.
- If a required environment variable is missing, the agent must stop and ask the user to configure it.
- `GITHUB_TOKEN` is the only approved GitHub API authentication mechanism for PR operations.
- SSH keys on the machine are used for Git clone/fetch/push.

## 5. OpenCode Configuration Strategy

The project should define a valid OpenCode config at:

```text
opencode.json
```

Important OpenCode schema facts:

- Use `provider`, not `providers`.
- Use `plugin`, not `plugins`.
- Use `agent`, not `agents`.
- Every model ID must include a provider prefix, such as `vllm/GadflyII/Qwen3-Coder-Next-NVFP4`.
- Unknown top-level fields are invalid.
- Project-specific Omni metadata belongs in `.omni/orchestrator.config.json`.

Conceptual `opencode.json` skeleton:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "vllm/GadflyII/Qwen3-Coder-Next-NVFP4",
  "small_model": "vllm/GadflyII/Qwen3-Coder-Next-NVFP4",
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
  },
  "skills": {
    "paths": [".opencode/skills"]
  },
  "mcp": {
    "playwright": {
      "type": "local",
      "command": ["npx", "-y", "@playwright/mcp"],
      "enabled": false
    }
  }
}
```

The implementation AI must validate against `https://opencode.ai/config.json` before writing final config.

## 6. Local and Cloud Model Strategy

Omni uses a hybrid local/cloud model strategy. Local-first execution uses vLLM, but not every agent should use the local model.

The primary local model is expected to be GadflyII/Qwen3-Coder-Next-NVFP4 or equivalent, exposed through an OpenAI-compatible vLLM endpoint, with a target context limit of **131072 tokens**. This large context window is a major design advantage for orchestration, code generation, code review, logging strategy, and privacy-sensitive repository work.

However, 131072 tokens is still a limit. Agents must not blindly load entire large repositories. They should use selective exploration, chunking, summaries, and dedicated codebase search/explorer behavior when needed.

Before final config is created, verify the real model name exposed by vLLM:

```text
GET {VLLM_BASE_URL}/models
```

Recommended allocation:

| Agent Type | Recommended Model | Location | Reasoning |
|---|---|---|---|
| Orchestrator | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context | High-frequency calls, low latency, privacy-sensitive. |
| Backend/Frontend code generation | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context | Core coding work; code normally stays local. |
| Code review / PR validation | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context | Consistent with code generator and repository context. |
| Unit test generation | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context | Lightweight code/test generation. |
| SAST security scanning | Rule engine + GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context | Prefer deterministic scanners; shared local LLM assists triage. |
| UI/UX design | Gemini 3 Pro | Cloud | Multimodal and visual reasoning. |
| Complex architecture decisions | GPT-5.5 or Claude Sonnet 4.6 | Cloud | One-off, high-complexity reasoning. |
| Codebase search / explorer | Claude Haiku 4.5 | Cloud | Fast, low-cost classification and search. |
| Documentation / librarian | Claude Sonnet 4.6 | Cloud | Documentation synthesis and live research when needed. |
| Logging strategy / observability | GadflyII/Qwen3-Coder-Next-NVFP4 | Local vLLM, 131072-token context | Close to implementation and code instrumentation. |

Cloud providers should be configured as placeholders for OpenAI, Anthropic, and Google. Agents decide whether escalation is appropriate, but must record why in the decision log for significant decisions. If a configured model is unavailable, the orchestrator must not silently substitute; it must ask the user.

## 7. Agent File Strategy

Use one Markdown file per agent under:

```text
.opencode/agent/<agent-name>.md
```

Each agent file should include frontmatter similar to:

```markdown
---
description: Short description of when to use this agent.
mode: subagent
model: vllm/GadflyII/Qwen3-Coder-Next-NVFP4
permission:
  edit: ask
  bash: ask
---

Agent prompt body here.
```

The primary orchestrator should use:

```markdown
---
description: Primary Omni orchestrator for coordinating product creation workflows.
mode: primary
model: vllm/GadflyII/Qwen3-Coder-Next-NVFP4
---
```

## 8. Complete Agent Roster

### Primary Agent

1. `omni-orchestrator`
   - Coordinates all workflows.
   - Asks stack and repo questions.
   - Reads `.omni/orchestrator.config.json`.
   - Delegates to specialized agents.
   - Enforces repo boundaries and GitHub workflow.
   - Maintains decision-log discipline.

### Layer 1: Strategy and Definition

2. `business-interpreter`
   - Converts raw user briefs, transcripts, emails, or notes into a Business Context Document.

3. `use-case-modeler`
   - Creates actors, use cases, basic flows, alternative flows, exception flows, and use case diagrams.

4. `prioritization-agent`
   - Ranks work using MoSCoW or another explicitly chosen prioritization model.

5. `requirements-writer`
   - Produces SRS documents with functional requirements, non-functional requirements, and acceptance criteria.

### Layer 2: Design and Architecture

6. `solution-architect`
   - Produces HLDs, architectural options, technology selection matrices, deployment topology, and major tradeoffs.
   - Must ask for stack confirmation or delegation before finalizing stack choices.

7. `data-schema-modeler`
   - Produces ERDs, data dictionaries, schema evolution plans, migration strategy, indexing strategy, and data-quality rules.

8. `api-contract-designer`
   - Produces OpenAPI/Swagger, GraphQL, gRPC, or other API contracts based on selected architecture.

9. `ui-ux-designer`
   - Produces user journeys, wireframes, accessibility notes, design tokens, component specs, and exported prototype artifacts.

### Layer 3: Implementation Builders

10. `frontend-vue-engineer`
    - Builds Vue-based frontend code.
    - Must inspect existing repo conventions and recommend current stable/LTS frontend packages.
    - Must not assume Vite, Nuxt, Pinia, or any package without repo evidence or approval.

11. `frontend-react-engineer`
    - Builds React-based frontend code.
    - Must inspect existing repo conventions and recommend current stable/LTS packages.
    - Must not assume Next.js, Redux, Zustand, or any package without repo evidence or approval.

12. `backend-rust-engineer`
    - Builds Rust backend code.
    - Must inspect the repo and recommend suitable stable Rust ecosystem choices.
    - Must not assume Axum, Actix, Rocket, Tokio, SQLx, Diesel, or any package without repo evidence or approval.

13. `backend-python-engineer`
    - Builds Python backend code.
    - Must inspect the repo and recommend suitable stable Python ecosystem choices.
    - Must not assume FastAPI, Django, Flask, SQLAlchemy, Pydantic, or any package without repo evidence or approval.

14. `backend-csharp-engineer`
    - Builds C# backend code.
    - Must inspect the repo and recommend suitable current LTS .NET choices.
    - Must not assume Minimal APIs, Controllers, EF Core, Dapper, Clean Architecture, or any package without repo evidence or approval.

15. `unit-test-generator`
    - Writes native unit tests for the selected language/framework.
    - Rust: native Rust test tools.
    - Python: native Python test tools.
    - C#: native .NET test tools.
    - Frontend: native JS/TS test tools.

No `backend-node-typescript-engineer` is planned. TypeScript/JavaScript are frontend-focused in this system unless the user later changes this decision.

### Layer 3.5: Legacy Reverse Engineering

16. `legacy-python-analyst`
    - Analyzes cloned Python 2/3 legacy repos and produces As-Is architecture documents.

17. `legacy-csharp-analyst`
    - Analyzes cloned .NET Framework/Core legacy repos and produces As-Is architecture documents.

18. `schema-extractor`
    - Extracts database schema, ERDs, relationships, indexes, constraints, and data dictionaries using read-only credentials only.

### Layer 4: Security and Integrity

19. `sast-scanner`
    - Reviews source code and diffs for secure coding issues, OWASP risks, injection, XSS, secrets, unsafe deserialization, auth bugs, and insecure config.

20. `dast-tester`
    - Tests staging URLs and API endpoints for runtime security issues using safe, approved techniques.

21. `dependency-auditor`
    - Reviews dependency manifests and lockfiles for CVEs, abandoned packages, risky licenses, and safer upgrade paths.

### Layer 5: Testing, QA, and Performance

22. `integration-tester`
    - Creates and runs integration tests across backend, database, external services, APIs, and frontend where applicable.

23. `load-simulator`
    - Creates load/performance test plans and scripts based on NFRs and expected traffic.

24. `qa-validator`
    - Validates implementation against SRS and acceptance criteria.

25. `uat-mimic`
    - Simulates business-user acceptance and checks whether the delivered workflow solves the actual business problem.

### Layer 6: DevOps, Release, and Rollback

26. `pipeline-engineer`
    - Creates CI/CD pipelines, build/test/release workflows, and environment promotion logic.

27. `rollback-manager`
    - Produces rollback plans and health checks.
    - Must not execute production rollback without human approval.

### Layer 7: Observability

28. `logging-strategist`
    - Defines structured logging schemas, OpenTelemetry strategy, correlation IDs, PII rules, retention, and log routing.

29. `alerting-monitor`
    - Defines SLIs/SLOs, dashboards, alert rules, synthetic checks, and incident thresholds.

### Layer 8: Governance and Documentation

30. `traceability-keeper`
    - Maintains the Requirements Traceability Matrix linking business context, use cases, requirements, tests, PRs, ADRs, and releases.

31. `technical-writer`
    - Produces developer docs, onboarding docs, API docs, MkDocs/ReadTheDocs content, and release notes.

### GitHub and PR Operations

32. `codebase-explorer`
    - Performs read-only codebase exploration and classification for registered repositories.
    - Uses fast, low-cost cloud reasoning for structure discovery, conventions, build/test command identification, and implementation evidence gathering.

33. `github-operator`
    - Performs GitHub API operations using `GITHUB_TOKEN` only.
    - Creates PRs, comments, labels, requests reviews, inspects PR status, and merges to `develop` when allowed.

34. `pr-validator`
    - Reviews PRs against requirements, ADRs, acceptance criteria, tests, lint/build status, security, dependencies, and traceability.
    - Comments failures on the PR.
    - Sends failed PRs back to the coding agent.
    - Approves and allows auto-merge to `develop` when all checks pass.

## 9. GitHub Workflow

### Branches

Recommended branch model:

```text
feature/<requirement-id>-short-title -> develop -> release/<version> -> main
```

Rules:

- Agents create feature branches from `develop`.
- Agents open PRs to `develop`.
- Passing PRs may be automatically merged into `develop`.
- Release branches are created from `develop` when preparing a release.
- Merge to `main` requires human approval.
- Force-push is forbidden.
- Repo creation and deletion are forbidden for agents.

### GitHub API

Agents must use `GITHUB_TOKEN` for GitHub API operations.

Acceptable operations after repo registration:

- Create PR.
- Read PR metadata.
- Comment on PR.
- Add or remove labels.
- Request changes.
- Approve PR.
- Merge passing PR to `develop`.

Forbidden operations unless a future policy explicitly allows them:

- Create repository.
- Delete repository.
- Change repository visibility.
- Modify branch protection.
- Force-push.
- Merge to `main` without human approval.

## 10. PR Validation Loop

1. Orchestrator assigns a requirement to a builder agent.
2. Builder agent checks the registered repo and creates a feature branch from `develop`.
3. Builder implements the change, runs local verification, commits, pushes, and opens a PR.
4. `pr-validator` receives the PR, requirement ID, ADR links, and acceptance criteria.
5. `pr-validator` checks out the PR branch locally.
6. `pr-validator` validates the diff against the requested scope.
7. `pr-validator` runs appropriate build/test/lint/security/dependency checks.
8. If validation fails:
   - It comments exact failures on the PR.
   - It applies a needs-work label if available.
   - The orchestrator returns the task to the original builder/fixer agent.
9. Builder fixes the same branch and pushes new commits.
10. `pr-validator` re-runs the review.
11. Loop continues until pass.
12. If validation passes:
   - `pr-validator` comments approval.
   - `github-operator` merges to `develop` automatically.
   - Orchestrator updates decision logs and traceability records.

## 11. Decision Logging Strategy

The decision/control repo is the source of truth for requirements, ADRs, plans, outcomes, traceability, and releases.

Recommended structure inside a product decision repo:

```text
docs/
  business-context/
  use-cases/
  requirements/
  architecture/
  api-contracts/
  data-models/
  ui-ux/
  adr/
  traceability/
  qa/
  release-notes/
```

ADR template:

```markdown
# ADR: [Title]

**Status**: Proposed | Accepted | Superseded | Deprecated
**Date**: YYYY-MM-DD
**Project**: [Project Name]
**Related Requirement(s)**: [IDs]
**Related PR(s)**: [Links]

## Context

What problem, constraint, or tradeoff caused this decision?

## Options Considered

1. Option A - pros/cons
2. Option B - pros/cons
3. Option C - pros/cons

## Decision

What was chosen and why?

## Consequences

Positive and negative consequences.

## Implementation Notes

Filled after implementation. Include delivered PRs, deviations, test results, and follow-up work.
```

Agents must create or update ADRs for:

- Stack selection.
- Major dependency introduction.
- Architecture decisions.
- Database design decisions.
- API contract decisions.
- Security-sensitive decisions.
- Deployment/rollback decisions.
- Legacy migration decisions.
- Significant failed approaches that should not be repeated.

## 12. Dependency Selection Policy

Every engineering agent must follow this policy:

1. Inspect the existing repo first.
2. Prefer existing conventions and dependencies.
3. If greenfield, recommend current stable/LTS options.
4. Present tradeoffs before adding major packages.
5. Ask the user or orchestrator before introducing high-impact dependencies.
6. Record accepted choices in an ADR.
7. Avoid obsolete, unmaintained, or insecure packages.
8. Prefer boring, stable, well-documented dependencies over novelty unless there is a clear reason.

## 13. Legacy Reverse Engineering Policy

Legacy repos are cloned locally under the standard clone base path. Legacy analysts produce As-Is documentation before migration or rewrite work starts.

Outputs should include:

- System overview.
- Main modules and responsibilities.
- Entry points.
- API inventory.
- Database access map.
- Queue/job topology.
- Dependency graph.
- Class/module hierarchy where useful.
- Critical flows.
- Technical debt hotspots.
- Security risks.
- Migration recommendations.

Legacy analysis must not modify legacy source code unless explicitly requested.

## 14. Skills to Create

Reusable skills should live under:

```text
.opencode/skills/<skill-name>/SKILL.md
```

Recommended initial skills:

1. `agent-operating-contract`
   - Shared anti-hallucination, safety, response-shape, repository-interaction, and artifact-quality rules.

2. `model-allocation`
   - How to route tasks between the shared local GadflyII/Qwen3-Coder-Next-NVFP4 131072-token context model and cloud specialist models.

3. `adr-writing`
   - How to create and update ADRs.

4. `github-workflow`
   - How to work with registered repos, branches, PRs, and `GITHUB_TOKEN`.

5. `dependency-selection`
   - How to choose packages without framework lock-in.

6. `legacy-analysis`
   - How to produce As-Is documentation.

7. `pr-validation`
   - How to validate PRs against requirements and acceptance criteria.

## 15. Commands to Consider

OpenCode commands can be added later in `opencode.json`. Recommended commands:

- `omni-onboard-product`: register product repos after the user creates them.
- `omni-new-feature`: start strategy/design/build flow for a feature.
- `omni-as-is`: run legacy analysis.
- `omni-pr-review`: validate a PR.
- `omni-release`: prepare release branch and release notes.
- `omni-update-traceability`: refresh RTM.

## 16. Implementation Roadmap

### Phase 0: Blueprint and Policy Foundation

- Create this blueprint.
- Create `.omni` policy documents.
- Create valid `opencode.json`.
- Confirm vLLM model ID.
- Confirm required environment variables.

### Phase 1: Agent Skeletons

- Create all agent Markdown files.
- Give each agent clear responsibility, inputs, outputs, boundaries, and permissions.
- Keep prompts maintainable and focused.

### Phase 2: Core Orchestrator Flow

- Implement `omni-orchestrator` prompt.
- Implement repo registration behavior.
- Implement stack-selection behavior.
- Implement delegation rules.

### Phase 3: GitHub and PR Loop

- Implement `github-operator`.
- Implement `pr-validator`.
- Validate with a dry run on a test repo.

### Phase 4: Strategy and Design Layers

- Validate business-context to requirements flow.
- Validate requirements ranking and traceability.
- Validate architecture/API/data/UI design outputs.

### Phase 5: Engineering Agents

- Validate Rust backend agent.
- Validate Python backend agent.
- Validate C# backend agent.
- Validate Vue frontend agent.
- Validate React frontend agent.
- Validate unit-test generator.

### Phase 6: Legacy and Governance

- Validate legacy Python analysis.
- Validate legacy C# analysis.
- Validate schema extraction using read-only env vars.
- Validate ADR and traceability updates.

### Phase 7: Security, QA, DevOps, Observability

- Validate SAST, DAST, dependency auditing.
- Validate integration/load/QA/UAT agents.
- Validate pipeline, rollback, logging, and alerting agents.

## 17. Known Conflicts Resolved

1. **Agent count**: The system is not limited to 24 or 25 agents. The final roster includes 34 named agents including codebase exploration, GitHub, and PR-specific agents.
2. **Node/TypeScript backend**: Excluded. TypeScript/JavaScript are frontend-focused unless this decision changes later.
3. **Repo creation**: User creates repos. Agents never create repos.
4. **GitHub authentication**: `GITHUB_TOKEN` only for API operations; SSH keys for Git transport.
5. **Automatic merge**: Passing PRs may auto-merge to `develop`.
6. **Main branch**: Merge to `main` remains human-approved.
7. **Secrets**: Environment variables only; no secrets committed.
8. **Framework lock-in**: Disallowed. Agents must recommend stable/LTS choices after inspection.
9. **OpenCode config shape**: Use current OpenCode schema fields: `provider`, `plugin`, and `agent`.

## 18. Builder Instructions for the Next AI

When implementing this blueprint:

1. Do not create product repos.
2. Do not create generated product code.
3. Work only in this Omni-Agent-Builder repo.
4. Create OpenCode config and agent files iteratively.
5. Validate config against OpenCode schema.
6. Keep secrets as environment-variable references only.
7. Ask before adding optional plugins.
8. Prefer many small, focused agent files over one large prompt.
9. After changing OpenCode config, agent files, skills, or plugins, remind the user to restart OpenCode because config is loaded at startup.
