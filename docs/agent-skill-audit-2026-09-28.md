# Agent & Skill Audit — 2026-09-28

Tracking document for the full agent/skill revision pass. All suggestions raised during the audit and their implementation status.

- **Decision date**: 2026-09-28
- **User decisions**: full scope; keep Rust rigor (1.96.0/TDD/crate gates); **merge commits** (not squash); vocabulary + this tracking doc required.
- **Related**: ADR in the commit body of this change (`refactor: revise agents & skills, expand roster`).

## 1. Cross-cutting suggestions (finding → status)

| # | Finding | Status | Where implemented |
|---|---|---|---|
| 1 | 2 agents were format outliers; `solution-architect` outside the contract | ✅ Done | Both rebuilt with standard frontmatter + contract ref |
| 2 | Only 2/34 agents defined output sections | ✅ Done | All 39 agents now have `Inputs / Outputs / Boundaries / Handoff` |
| 3 | Nobody knew artifact paths (blueprint §11 unused) | ✅ Done | Paths in every producer's `Outputs`; codified in `sdlc-handoffs`, `docs-structure` |
| 4 | No handoff packet format | ✅ Done | `sdlc-handoffs` skill + orchestrator usage |
| 5 | PR fix loop unbounded | ✅ Done | Max 3 loops + human escalation (`pr-validation`, `pr-validator`) |
| 6 | Merge method unspecified | ✅ Done | **Merge commits** everywhere (`github-workflow`, `github-operator`, `cicd-release`, vocabulary) |
| 7 | Model names duplicated in agent prose | ✅ Done | Stripped from all bodies; frontmatter + `model-allocation` are the only sources |
| 8 | `backend-rust-engineer` "git only with user consent" conflicted with `github-policy` | ✅ Done | Rewritten per `github-workflow` (commit/push after registration) |
| 9 | Security trio had no severity/output standard | ✅ Done | `security-review` skill + applied in `sast-scanner`, `dast-tester`, `dependency-auditor` |
| 10 | `omni-release` had no owning agent | ✅ Done | New `release-manager` + orchestrator Command ownership table |
| 11 | No E2E UI test agent (Playwright MCP orphaned) | ✅ Done | New `e2e-test-engineer` |
| 12 | Skills covered process, not craft | ✅ Done | 12 new craft skills (see §3) |
| 13 | `backend-csharp-engineer` date-fragile wording ("today is") | ✅ Done | "Default target: .NET SDK 10 LTS" phrasing (decision kept) |

## 2. Per-agent revision status (34 existing)

| Agent | Key change | Status |
|---|---|---|
| omni-orchestrator | Delegation Map G1–G12, command ownership, handoff packet use, codebase-explorer-first rule | ✅ |
| business-interpreter | `BC-###` IDs, `docs/business-context/` path, quote linking | ✅ |
| use-case-modeler | `UC-###` + path, mandatory Mermaid, BC links | ✅ |
| prioritization-agent | Ranked-backlog table + waves, `docs/requirements/backlog.md` | ✅ |
| requirements-writer | Gherkin AC mandate, NFR taxonomy, testability lint, `SRS.md` | ✅ |
| solution-architect | **Contract ref added**; Phases 0–6 kept; ERD/API detail delegated; approval via orchestrator | ✅ |
| data-schema-modeler | Expand/contract, `docs/data-models/`, entity↔REQ map | ✅ |
| api-contract-designer | Error envelope/versioning/idempotency (via `api-design`), path, endpoint↔REQ table | ✅ |
| ui-ux-designer | WCAG 2.2 AA explicit, W3C tokens, state matrix, design bundle | ✅ |
| frontend-vue-engineer | Concrete verify block, token consumption, WCAG AA, PR REQ IDs | ✅ |
| frontend-react-engineer | Same as Vue | ✅ |
| backend-rust-engineer | Rebuilt standard format; **rigor kept** (1.96.0, TDD, clippy, crate top-100 + approval gates); commit rule fixed | ✅ |
| backend-python-engineer | Discover-commands-first verify block | ✅ |
| backend-csharp-engineer | .NET 10 LTS phrasing fix; verify block | ✅ |
| unit-test-generator | Model prose stripped; `TC`/tag conventions; REQ→TC map | ✅ |
| legacy-python-analyst | As-Is template + path + `DEF` severities | ✅ |
| legacy-csharp-analyst | Same | ✅ |
| schema-extractor | Mermaid ERD, `as-is-schema.md`, PII handoff | ✅ |
| sast-scanner | Findings table + tool-first + OWASP mapping | ✅ |
| dast-tester | Approved-target hard stop, safe-test catalog, findings table | ✅ |
| dependency-auditor | Audit commands per ecosystem, SPDX posture, findings table | ✅ |
| integration-tester | Synthetic-only policy, contract compliance, report format | ✅ |
| load-simulator | NFR→threshold table mandatory, tool-approval rule | ✅ |
| qa-validator | Per-AC verdict table format | ✅ |
| uat-mimic | Persona cards + scenario scripts + ranked friction report | ✅ |
| pipeline-engineer | Required jobs, promotion gates, GitHub Actions default | ✅ |
| rollback-manager | Decision matrix, forward-fix option, watch window | ✅ |
| logging-strategist | Log schema table, OTel, call-site redaction | ✅ |
| alerting-monitor | SLI/SLO catalog, **no-alert-without-runbook** rule | ✅ |
| traceability-keeper | RTM schema + gap report formats | ✅ |
| technical-writer | Model prose stripped; `docs-structure` IA, runbooks, release-notes template | ✅ |
| codebase-explorer | Stack Classification output, summarize-large-files rule | ✅ |
| github-operator | Merge-commit rule, label taxonomy, PR template pointer, branch naming | ✅ |
| pr-validator | 10-row checklist, severity findings, 3-loop cap + escalation | ✅ |

## 3. New skills (12) — all implemented ✅

| Skill | Tier | Purpose |
|---|---|---|
| `sdlc-handoffs` | A | Handoff packets, phase gates G1–G12, artifact paths |
| `id-traceability` | A | BC/UC/REQ/NFR/AC/TC/DEF/ADR ID scheme + RTM schema |
| `requirements-quality` | A | Gherkin ACs, NFR taxonomy, testability lint |
| `security-review` | A | Severity taxonomy, findings table, OWASP/ASVS, secret patterns, tool-first |
| `test-strategy` | A | Test pyramid, tags↔REQ, synthetic data policy |
| `api-design` | B | REST conventions, error envelope, pagination, idempotency, versioning |
| `data-modeling` | B | Naming, expand/contract, spatial, lifecycle hooks |
| `observability-standards` | B | Log schema, OTel, SLI/SLO, no-alert-without-runbook |
| `cicd-release` | B | Required jobs, promotion gates, SemVer, rollback matrix |
| `docs-structure` | B | Doc IA, types, audience tags, release-notes template |
| `ui-ux-standards` | B | WCAG 2.2 AA checklist, W3C tokens, state matrix |
| `stack-selection` | B | Always-ask rule, decision matrix, supported targets |

## 4. Existing skills revised (7) — all done ✅

| Skill | Change |
|---|---|
| `adr-writing` | File naming `NNNN-kebab`, status transitions, failed-approach ADRs |
| `agent-operating-contract` | Artifact-location pointer |
| `dependency-selection` | SPDX license posture, audit commands, lockfile policy |
| `github-workflow` | **Merge commits**, branch naming, PR template, label taxonomy |
| `legacy-analysis` | As-Is template skeleton, `DEF` severities, evidence rules |
| `model-allocation` | No change (fresh) |
| `pr-validation` | 10-row checklist form, labels, 3-loop escalation |

## 5. New agents (5) — all implemented ✅

| Agent | Tier | Fills gap |
|---|---|---|
| `e2e-test-engineer` | T2 (`mimo-v2.6-flash`) | Browser E2E; owns Playwright-class tooling |
| `release-manager` | T2 | Owns `omni-release`: SemVer, release branches, changelog, human-approval handoff |
| `data-migration-engineer` | T2 | Implements expand/contract migrations + rollbacks |
| `accessibility-auditor` | T2 | WCAG 2.2 AA audits with evidence |
| `privacy-compliance-reviewer` | T1 (`mimo/mimo-v2.6-pro`) | GDPR processing inventory, minimization, retention, DS rights hooks |

**Explicitly not built** (decided against): context-compressor agent (user decision D: skip — evidence showed ~8.5% real agentic savings), `backend-node-typescript-engineer` (excluded by `stack-policy`), mobile/ML agents, `security-architect` (covered by existing agents).

## 6. New docs (2) — done ✅

| Doc | Content |
|---|---|
| `docs/vocabulary.md` | Jargon glossary (process, workflow, IDs, quality/security, model tiers, commands) |
| `docs/agent-skill-audit-2026-09-28.md` | This tracking document |

## 7. User decisions captured

| # | Question | Decision | Applied where |
|---|---|---|---|
| 1 | Scope | **Full** (12 skills + 5 agents) | §3, §5 |
| 2 | Rust rigor | **Keep** (1.96.0, TDD, crate top-100 + approval gates) | `backend-rust-engineer` |
| 3 | Merge method | **Merge commits** (not squash) | `github-workflow`, `github-operator`, `cicd-release` |
| 4 | Vocabulary | **Create** | `docs/vocabulary.md` |
| 5 | Tracking doc | **Create** | this file |

## 8. Resulting counts

| Component | Before | After |
|---|---|---|
| Agents | 34 | **39** |
| Skills | 7 | **19** |
| Policy files (`.omni`) | 6 + registry | unchanged |
| Docs | — | +2 (`docs/`) |

Model tiers after the change: **T1** `mimo/mimo-v2.6-pro` × 14 (13 + `privacy-compliance-reviewer`), **T2** `mimo/mimo-v2.6-flash` × 21 (17 + `e2e-test-engineer`, `release-manager`, `data-migration-engineer`, `accessibility-auditor`), **T3** `opencode/deepseek-v4-flash` × 4 (unchanged: `omni-orchestrator`, `codebase-explorer`, `traceability-keeper`, `github-operator`). See `.omni/model-allocation-policy.md` for the authoritative roster.
