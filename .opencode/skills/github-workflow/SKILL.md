---
name: github-workflow
description: Use when cloning registered repos, creating branches, pushing commits, opening PRs, commenting, labeling, approving, or merging to develop with GITHUB_TOKEN.
---

# GitHub Workflow

## Rules

- Repositories must already be registered in `.omni/orchestrator.config.json`.
- Use SSH for Git transport (`git clone/fetch/pull/push`).
- Use `GITHUB_TOKEN` for GitHub API operations only (never print its value).
- Branch naming: `feature/<REQ-ID>-short-kebab-slug` (e.g. `feature/REQ-014-order-export`); hotfixes `fix/<DEF-ID>-slug`; releases `release/<version>`.
- Open PRs to `develop`.
- **Merge method: merge commits** (the PR's commit history is preserved; no squash, no rebase-merge, no force-push).
- Passing PRs may auto-merge to `develop` after `pr-validator` approval.
- Merge to `main` requires **human approval**.

## PR conventions

- Title: `<type>: <summary>` (`feat|fix|docs|test|refactor|chore`) + `REQ-###` when applicable.
- Body template:

```markdown
## Summary
## Requirement IDs (REQ/NFR/UC/AC)
## ADR links (if decisions changed)
## Verification commands (exact) + results
## Risk / rollback notes
```

- Labels: `needs-work`, `approved`, `security`, `breaking`, `release-candidate`. Apply `needs-work` on failed validation; remove on pass.

## Forbidden

- Creating repositories.
- Deleting repositories.
- Force-pushing (any branch).
- Changing visibility or branch protection.
- Using unregistered repositories.
- Squash or rebase merges (project decision: merge commits).
- Merging to `main` without human approval.
