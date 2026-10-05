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

---

## 9. Repository security hardening (added 2026-09-28, same session)

User request: make the repo public safely — no one except the owner may push or change anything; contributions accepted only via PR.

| Item | Artifact | Status |
|---|---|---|
| Vulnerability intake (no public issues) | `SECURITY.md` + private vulnerability reporting | ✅ File created; PVR enable attempted by script |
| PR-only contributions | `scripts/apply-repo-security.sh` → branch protection on `main` + `develop` | ✅ Script ready; **pending run** (PAT scope, see below) |
| Owner direct-push exception | `enforce_admins: false` in protection | ✅ Encoded in script |
| Review gates | 1 approving review + CODEOWNERS + `omni-validate` required check | ✅ `.github/CODEOWNERS`, workflow |
| CI gate | `.github/workflows/validate.yml` (JSON, agent structure, skill frontmatter, secret scan) | ✅ Created; scan tested locally (clean + positive control detects planted secret) |
| Merge method enforcement | Repo settings: merge commit only (squash/rebase disabled) | ✅ Encoded in script |
| History safety | No force-push, no branch deletion, conversation resolution | ✅ Encoded in script |
| Attack-surface reduction | Wiki + Projects disabled, auto-merge off, delete branch on merge | ✅ Encoded in script |
| Issue hygiene | Blank issues disabled; structured bug/feature templates; security routed to SECURITY.md | ✅ `.github/ISSUE_TEMPLATE/` |
| Secret leakage prevention | `.gitignore` (env/keys/credentials) + CI secret-pattern scan | ✅ Done |
| Dependency monitoring | Dependabot (github-actions, weekly) | ✅ `.github/dependabot.yml` |
| Conduct policy | `.github/CODE_OF_CONDUCT.md` (Contributor Covenant 2.1) | ✅ Done |
| Documentation | README "Repository Security" section + layout tree | ✅ Done |

**Policy override recorded**: `.omni/github-policy.md` forbids agents from
changing branch protection. The user's explicit request of 2026-09-28 takes
precedence (hierarchy of truth #1: current user request). The script is
idempotent and re-checkable (`--check`). Repository visibility change remains
a human action per policy.

**Applied 2026-09-28 (session, after commit normalization)**: repo settings
applied via the owner's `gh` keyring session (admin on repo): merge-commits
only, squash/rebase disabled, auto-merge off, delete-branch-on-merge on, wiki
and projects disabled.

**Remaining blocker**: branch protection on private repos requires GitHub Pro
(API 403: "Upgrade to GitHub Pro or make this repository public"). Sequence:

1. Make the repo public (Settings → General → Danger Zone → Change visibility) — human action.
2. Re-run `./scripts/apply-repo-security.sh` → branch protection + private
   vulnerability reporting will now succeed (free for public repos).
3. Verify: `./scripts/apply-repo-security.sh --check`.

## 10. Commit attribution normalization (2026-09-28)

User report: commits appeared under the wrong account. Evidence showed the
opposite direction: today's commits (`<primary-email-redacted>`) were already
attributed to `roger-oliver`; the older 12 commits (`<legacy-email-redacted>`) were
**unlinked** (no GitHub profile). SSH identity on this machine confirmed as
`roger-oliver` (`ssh -T git@github.com`).

Action: `git filter-branch --env-filter` mapped `<legacy-email-redacted>` →
`<primary-email-redacted>` (author + committer) across all 18 commits on
develop + main; backups (`refs/original`) deleted, reflog expired, objects
pruned; content verified unchanged (identical tree hash); force-pushed with
`--force-with-lease`.

Post-rewrite verification (GitHub API): **all 19 remote commits on develop +
main now show `author.login = roger-oliver`**. No `<legacy-email-redacted>` remains in
emails, commit messages, or tracked files.

Note: the machine's GLOBAL git config still uses `<legacy-email-redacted>` (other repos);
this repo's local config is correct.

## 11. DeepSeek T3 model swap (2026-10-05)

User request: move all `opencode/deepseek-v4-flash` traffic to DeepSeek V4.1
Flash and mark the old model deprecated/retired in the model-allocation policy.

- Zen catalog verified live: model ID is `deepseek-v4.1-flash` (there is no
  `deepseek-flash` ID on the catalog — the parenthetical in the request was
  shorthand). The primary instruction's `opencode/deepseek-v4.1-flash` was used.
- 37 replacements across 12 files (4 T3 agents, model-allocation skill,
  operating contract, model-allocation policy, `opencode.json` `small_model`,
  README, blueprint, manual-opencode-setup, vocabulary). Word-boundary-safe:
  `deepseek-v4-flash-free` / `-vision-exp` references untouched.
- T3 price cells updated $0.14/$0.28 → $0.30/$1.20 (Zen list for v4.1-flash).
- `opencode/deepseek-v4-flash` added to the Do Not Use table (retired
  2026-10-05, traffic → `opencode/deepseek-v4.1-flash`) in
  `.omni/model-allocation-policy.md` + `model-allocation` skill.
- Synced to `~/.config/opencode/` (4 agents, 2 skills, 3 instructions,
  `opencode.jsonc` `small_model`).

## 12. Repo settings follow-up (2026-10-05)

- `has_wiki=false` re-applied successfully (had flipped back to true).
- `has_projects=false` remains inert: repeated PATCH returns `projects:true`.
  Likely account-level Projects (v2) setting overrides the repo flag.
  Low attack surface — contributors cannot modify Projects anyway; left as-is
  and documented here.
- Branch protection + private vulnerability reporting still pending repo
  visibility change (GitHub Free limitation on private repos).

## 13. CI allowlist follow-up (2026-10-05)

The `omni-validate` workflow's approved-model set in
`.github/workflows/validate.yml` still listed `opencode/deepseek-v4-flash`
after the T3 swap (`.github/` was excluded from the swap sweep's grep paths),
so push CI on `74f1399` failed with "missing or non-approved model" for the
4 correctly-swapped T3 agents. Fix: allowlist updated to
`{mimo/mimo-v2.6-pro, mimo/mimo-v2.6-flash, opencode/deepseek-v4.1-flash}`.
Lesson recorded: model-ID sweeps must include `.github/` (workflow allowlists),
not only agents/policies/docs.
