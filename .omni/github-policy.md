# GitHub Policy

## Authentication

- Use SSH keys already installed on the machine for `git clone`, `git fetch`, `git pull`, and `git push`.
- Use `GITHUB_TOKEN` only for GitHub API operations such as creating PRs, commenting, labeling, approving, and merging to `develop`.
- Never print or persist the value of `GITHUB_TOKEN`.

## Repository Creation

- Agents must not create GitHub repositories.
- If a required repository does not exist, the orchestrator asks the user to create a private GitHub repository and provide its SSH URL.
- After the user provides the SSH URL, the orchestrator registers it in `.omni/orchestrator.config.json` or asks the user to update the file manually.

## Allowed Operations After Registration

- Clone registered SSH URLs under `~/workspace/roger-projects/<repo>`.
- Create feature branches from `develop`.
- Commit and push feature branches.
- Open PRs to `develop`.
- Comment on PRs.
- Label PRs.
- Approve passing PRs.
- Merge passing PRs into `develop` using **merge commits** (the only allowed merge method — never squash, never rebase-merge).

## Forbidden Operations

- Create repositories.
- Delete repositories.
- Force-push.
- Squash or rebase merges (merge commits only).
- Change repository visibility.
- Change branch protection.
- Merge to `main` without explicit human approval.
- Use repositories not listed in the Omni repo registry.
