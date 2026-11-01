# Repo Sync Policy (Omni source)

**Incident (2026-11-01):** an agent committed to a **stale local `develop`** (1 ahead / 5 behind `origin/develop`) in a registered repo, unsynced from origin. This policy is part of the Omni system and applies to **every agent and every registered repository**.

## Before ANY work in a registered repository
1. `git fetch --prune origin`.
2. `git rev-list --left-right --count HEAD...origin/develop`:
   - **0 0** → current, proceed.
   - **non-zero** → **do not commit**; fast-forward or use a fresh worktree from `origin/develop`.
3. The local `develop` / `main` must **never** diverge from origin.

## Never commit or push to a protected branch
`develop`, `main`, `master` are protected. Always:
```sh
git worktree add ../.worktrees/<name> -b <type>/<slug> origin/develop   # type=feature|docs|fix|chore
# commit there → push the branch → PR to develop (merge commit)
```
Enable the shared hooks once per clone: `git config core.hooksPath .githooks`.

## Before opening/merging a PR
Re-`git fetch`; confirm the branch is based on the **current** `origin/develop`; merge/rebase origin into it first (never force-push).

## Enforcement (three layers)
1. **Git hooks** — `.githooks/pre-commit` (refuse a commit on develop/main/master) + `.githooks/pre-push` (refuse a push to them). Committed; enabled via `core.hooksPath`.
2. **`AGENTS.md`** at every repo root + this policy.
3. **Global** — this file is deployed to `~/.config/opencode/instructions/repo-sync-policy.md` and loaded for every agent.

The `omni-orchestrator` runs the **pre-flight** before delegating: `git fetch` + the divergence check on the target repo.
