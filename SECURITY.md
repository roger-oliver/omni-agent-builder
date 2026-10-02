# Security Policy

## Scope

This repository (`omni-agent-builder`) defines an AI agent system: agent prompts, skills, policies, and setup scripts. It contains **no product code, no credentials, and no user data**. Security issues here are, in practice, issues that could let a malicious contribution:

- inject instructions that steer agents into unsafe actions (data exfiltration, destructive commands, secret disclosure);
- smuggle credentials or PII into committed files;
- bypass the human-approval gates defined in `.omni/*.md` policies;
- exploit the CI workflow or repository configuration.

## Reporting a vulnerability — please do NOT open a public issue

Report security issues **privately** via one of:

1. **GitHub private vulnerability reporting** on this repository: the "Report a vulnerability" button under the Security tab.
2. If private reporting is unavailable, email the maintainer address listed on the GitHub profile and include the repository name in the subject.

Please give the maintainer time to fix before any public disclosure.

### What to include

- Description of the issue and affected files/workflows.
- Steps or proof-of-concept (against a fork of this repo only — never against other users' installations).
- Potential impact and suggested remediation.

### What not to do

- Do not open public issues or PRs describing an unpatched vulnerability.
- Do not scan or attack deployments of other users.
- Do not submit automated scanner noise without a reproducible finding.

## Contribution security rules

Because this project configures autonomous coding agents, contributions are held to these rules (enforced by review + CI):

1. **No secrets or credentials** — environment variable *names* only (see `.omni/agent-operating-contract.md`). CI scans for secret patterns and fails on matches.
2. **No prompt-injection payloads** — agent/skill/policy files must not instruct agents to bypass safety rules (repo registration, human-approval gates, force-push prohibition, secret handling).
3. **No executable code paths without review** — changes to `scripts/`, `.github/workflows/`, or `opencode.json` require explicit maintainer review.
4. **Merge method is merge commits only**; all changes enter `main`/`develop` through reviewed PRs (direct pushes are restricted to the maintainer).

## Supported versions

| Branch | Status |
|---|---|
| `main` | Supported (security fixes applied) |
| `develop` | Supported (pre-release integration) |

## Policy changes

Changes to this policy and to repository protection are recorded as ADRs in the decision log (see commit history / `docs/`).
