# Omni Vocabulary

Shared glossary of jargon used across Omni agents, skills, policies, and docs. Every term here has exactly one meaning in Omni artifacts. Agents and humans should use these terms consistently.

## Process terms

| Term | Meaning |
|---|---|
| **Omni** | This multi-agent SDLC system (orchestrator + specialized agents + skills + policies) |
| **Orchestrator** | `omni-orchestrator` — the primary agent that routes work to specialized agents |
| **Agent** | A specialized OpenCode subagent (`.opencode/agent/<name>.md`) with one job |
| **Skill** | Reusable instructions (`.opencode/skills/<name>/SKILL.md`) loaded on trigger |
| **Policy** | Non-negotiable rule document under `.omni/*.md` (contract, stack, github, dependency, decision-log, legacy-analysis, model-allocation) |
| **Handoff packet** | Structured task brief passed between agents: Goal, Requirement IDs, Context, Constraints, Done-when, Verification command |
| **Phase gate (G1–G12)** | Ordered SDLC checkpoints in `sdlc-handoffs`; a gate closes only when its artifact + ADRs exist |
| **Delegation map** | Orchestrator's table: phase → lead agents |
| **Builder** | Implementation agents (`backend-*`, `frontend-*`, `data-migration-engineer`, `e2e-test-engineer`) |
| **Thinker / Builder / Operator** | Model tiers T1/T2/T3 (see "Model terms") |

## Repository & workflow terms

| Term | Meaning |
|---|---|
| **decision_logs repo** | The product's control repository: requirements, ADRs, RTM, QA reports, release notes |
| **Registered repo** | A repo listed in `.omni/orchestrator.config.json` (`decision_logs`, `ui_design`, `frontend`, `backend`, `legacy`) — the only repos agents may touch |
| **Clone base path** | User-chosen directory where registered repos are cloned (configured per project in `.omni/orchestrator.config.json`) |
| **develop / release/* / main** | Branch model: `feature/*` → `develop` → `release/<version>` → `main` |
| **Merge commit** | The **only** allowed PR merge method (history preserved; no squash, no rebase-merge, no force-push) |
| **PR loop** | pr-validator ↔ builder fix cycle; **max 3 loops**, then human escalation |
| **needs-work / approved** | PR labels applied by `pr-validator` on fail/pass |
| **Human approval gate** | Action requiring explicit human consent: merge to `main`, production deploy, rollback execution, repo create/delete, force-push |
| **Verification command** | The exact command(s) proving a Done-when claim — results must be real tool output |

## Artifact & ID terms (see `id-traceability`)

| Term | Meaning |
|---|---|
| **BC-###** | Business Context block |
| **UC-###** | Use case |
| **REQ-###** | Functional requirement |
| **NFR-###** | Non-functional requirement (one category: performance, reliability, security, privacy, scalability, observability, maintainability, accessibility, compatibility) |
| **AC-###** | Acceptance criterion — **Given/When/Then** with an observable Then |
| **TC-###** | Test case (unit/integration/E2E/load) |
| **DEF-###** | Finding/defect (QA, security, tech debt, a11y, privacy) |
| **ADR-NNNN** | Architecture Decision Record in `decision_logs/docs/adr/` |
| **RTM** | Requirements Traceability Matrix: `BC | UC | REQ/NFR | AC | TC | PR | ADR | Release | Status` |
| **SRS** | Software Requirements Specification (`docs/requirements/SRS.md`) |
| **As-Is doc** | Read-only reverse-engineering report of a legacy repo (`as-is-<repo>.md`) |
| **HLD** | High-Level Design (architecture blueprint output) |
| **ERD** | Entity-Relationship Diagram (Mermaid `erDiagram`) |
| **Backfill** | Batched, resumable data rewrite during a migration |
| **Expand/contract** | Zero-downtime migration pattern: add → backfill → remove |
| **Runbook** | Trigger/impact/recovery/validation/escalation doc; **required before any alert exists** |
| **Watch window** | Post-release monitoring period with defined triggers |

## Quality & security terms

| Term | Meaning |
|---|---|
| **Severity** | `Critical | High | Medium | Low` — the only severity scale in Omni (see `security-review`) |
| **Findings table** | `DEF ID | Location | Severity | OWASP/ASVS | Evidence | Exploitability | Remediation` |
| **WCAG 2.2 AA** | Accessibility floor for all user-facing UI |
| **Tool-first rule** | Deterministic scanners detect; LLM judgment only triages/remediates |
| **Synthetic data only** | Test fixtures with no real PII/credentials (env var **names** only) |
| **Gherkin AC** | `Given / When / Then` acceptance criterion with measurable outcome |
| **Testability lint** | Pre-SRS checklist: every REQ/NFR has ACs; every AC has a TC; no untestable verbs |
| **Golden signals** | Latency, traffic, errors, saturation (metrics baseline) |
| **SLI / SLO / error budget** | Measured ratio / target+window / allowed failure spend |
| **PII** | Personal data (names, emails, addresses, IDs, location trails) — inventoried by `privacy-compliance-reviewer` |
| **Lawful basis** | GDPR ground for processing (consent/contract/legitimate-interest/…) — user decides when ambiguous, recorded as ADR |
| **ASVS** | OWASP Application Security Verification Standard (finding category mapping) |
| **SemVer** | `MAJOR.MINOR.PATCH` versioning (breaking/feature/fix) |

## Model terms (see `model-allocation`)

| Term | Meaning |
|---|---|
| **T1 Thinkers** | `mimo/mimo-v2.6-pro` — deep-reasoning agents |
| **T2 Builders** | `mimo/mimo-v2.6-flash` — code/test/config generation |
| **T3 Operators** | `opencode/deepseek-v4.1-flash` — routing, search, tracking, GitHub ops |
| **Chinese cloud models only** | Approved pool = Xiaomi MiMo + OpenCode Zen non-Anthropic, non-local, non-free-tier, non-deprecated models |
| **Zen** | OpenCode Zen gateway (`opencode/...` model IDs) |
| **MiMo** | Xiaomi MiMo API (`mimo/...` model IDs) |
| **Provider prefix** | Every model ID starts with its provider: `mimo/…` or `opencode/…` |
| **No silent substitution** | Unavailable model → stop and ask; never swap models without approval |
| **1M-token context** | Configured context window — still a limit; explore selectively |

## Commands

| Command | Owner |
|---|---|
| `omni-onboard-product` | orchestrator |
| `omni-new-feature` | orchestrator (G1–G12) |
| `omni-as-is` | legacy analysts / schema-extractor |
| `omni-pr-review` | pr-validator |
| `omni-release` | release-manager |
| `omni-update-traceability` | traceability-keeper |
