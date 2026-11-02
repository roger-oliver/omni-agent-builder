# AGENTS.md — omni-agent-builder

## Repo sync guard (applies to every Omni agent, every repo)
- **Never** commit or push directly to `develop` / `main` / `master`.
- Work in a worktree from `origin/develop`: `git worktree add ../.worktrees/<name> -b <type>/<slug> origin/develop`; commit → push → PR to `develop` (merge commit).
- Before any work: `git fetch --prune origin` and confirm `git rev-list --left-right --count HEAD...origin/develop` = `0 0`.
- Enable the shared hooks once per clone: `git config core.hooksPath .githooks`.
- Full policy: `.omni/repo-sync-policy.md` (deployed to `~/.config/opencode/instructions/repo-sync-policy.md`).
