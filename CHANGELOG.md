# Changelog

All notable changes to Omni-Agent-Builder follow [SemVer](https://semver.org).
Entries cite PRs and ADRs where applicable.

## v0.1.0 — 2026-09-28

First public release of the Omni agent system.

### Agent system

- **39 specialized agents** across strategy, design, implementation
  (Rust/Python/C#/Vue/React), legacy reverse-engineering, security, QA,
  DevOps, observability, governance, and GitHub/PR operations.
- **19 reusable skills**: SDLC handoffs with phase gates G1–G12, ID
  traceability (BC/UC/REQ/NFR/AC/TC/DEF/ADR), requirements quality
  (Gherkin ACs + NFR taxonomy), security review (severity taxonomy +
  findings table), test strategy, API design, data modeling,
  observability standards, CI/CD & release, docs structure, UI/UX
  standards (WCAG 2.2 AA), stack selection, ADR writing, GitHub
  workflow, dependency selection, legacy analysis, PR validation,
  model allocation, operating contract.
- **7 policies** under `.omni/` + shared anti-hallucination operating
  contract.
- **6 commands**: `omni-onboard-product`, `omni-new-feature`,
  `omni-as-is`, `omni-pr-review`, `omni-release`,
  `omni-update-traceability`.

### Model allocation (ADR in commit `b8ac9c7`)

- Three Chinese cloud tiers: T1 Thinkers `mimo/mimo-v2.6-pro`,
  T2 Builders `mimo/mimo-v2.6-flash`, T3 Operators
  `opencode/deepseek-v4-flash` (all 1M-token context).
- Anthropic models, local runtimes, deprecated Zen models, and Zen
  free tiers excluded by decision.

### Workflow & governance

- Branch model `feature/* → develop → release/* → main`; merge commits
  only (squash/rebase forbidden).
- Bounded PR validation loop (max 3 fix loops, then human escalation).
- Decision-log/ADR discipline; RTM traceability matrix.

### Tooling

- Global installer + interactive project setup scripts for bash and
  fish (`scripts/install.sh`, `setup-omni-project.sh`, `.fish`
  variants).
- `apply-repo-security.sh`: branch protection + repo hardening for
  public use.
- CI validation workflow: JSON validity, agent structure, skill
  frontmatter, secret-pattern scan.
- Security intake: `SECURITY.md`, private vulnerability reporting,
  CODEOWNERS, structured issue/PR templates, Dependabot.

### Docs

- `docs/vocabulary.md` (shared jargon glossary).
- `docs/agent-skill-audit-2026-09-28.md` (full audit tracking).
- Refreshed `README.md`, `blueprint.md`, `manual-opencode-setup.md`.
