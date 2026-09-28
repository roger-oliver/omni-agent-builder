---
name: cicd-release
description: Use when designing CI/CD pipelines, environment promotion, versioning, release branches, or rollback hooks — job requirements, promotion gates, and SemVer rules.
---

# CI/CD & Release

## Required pipeline jobs (every PR + main)

1. Lint/format check
2. Unit tests (+ integration where they are hermetic)
3. SAST / secret scan (deterministic tool)
4. Dependency audit
5. Build (deterministic artifact)
6. Artifact publish (versioned)

Optional per repo: E2E (staging), load smoke, SBOM.

## Environment promotion gates

| Step | Gate |
|---|---|
| `feature/*` → `develop` | All PR checks green + `pr-validator` approval; auto-merge by **merge commit** (never squash, never force-push) |
| `develop` → `release/<version>` | Release checklist complete (see `release-manager`); human-informed |
| `release/*` → `main` | **Human approval required** (never auto) |
| deploy `staging` | Pipeline after `develop` merge |
| deploy `production` | **Human approval required**; `rollback-manager` plan ready beforehand |

## Secrets in pipelines

- Reference platform secrets / env var **names** only. Never inline values in workflow files, matrices, or logs.
- Least-privilege tokens per job (`GITHUB_TOKEN` for GitHub API only).

## Versioning (SemVer)

- `MAJOR.MINOR.PATCH` — breaking / feature / fix. Tag `v<version>`.
- Pre-release: `v1.2.0-rc.1` on `release/*` branches.
- Version bump decided by `release-manager` from merged REQ/PR/ADR evidence, not guesswork.

## Rollback hooks

- Every pipeline that deploys exposes: previous-artifact redeploy path, health check command, and trigger thresholds (defined with `rollback-manager`).
- Deploy jobs must be re-runnable and idempotent.

## Rollback decision matrix (fill per release)

| Trigger | Metric threshold | Action | Command | Owner |
|---|---|---|---|---|

Forward-fix vs rollback is a recommendation with rationale; executing production rollback needs explicit human approval.
