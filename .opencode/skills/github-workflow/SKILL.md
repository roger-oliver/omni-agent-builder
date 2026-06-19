---
name: github-workflow
description: Use when cloning registered repos, creating branches, pushing commits, opening PRs, commenting, labeling, approving, or merging to develop with GITHUB_TOKEN.
---

# GitHub Workflow

Rules:

- Repositories must already be registered in `.omni/orchestrator.config.json`.
- Use SSH for Git transport.
- Use `GITHUB_TOKEN` for GitHub API operations.
- Create feature branches from `develop`.
- Open PRs to `develop`.
- Passing PRs may auto-merge to `develop`.
- Merge to `main` requires human approval.

Forbidden:

- Creating repositories.
- Deleting repositories.
- Force-pushing.
- Changing visibility or branch protection.
- Using unregistered repositories.
