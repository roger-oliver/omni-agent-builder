---
name: pr-validation
description: Use when reviewing PRs against requirements, ADRs, acceptance criteria, tests, lint/build results, security, dependencies, and traceability.
---

# PR Validation

Validation loop:

1. Identify the registered repo, PR number, base branch, requirement IDs, ADRs, and acceptance criteria.
2. Inspect the diff and changed files.
3. Check scope against the requested work.
4. Run build/test/lint/security/dependency checks appropriate to the repo.
5. Validate acceptance criteria and traceability.
6. If failing, comment exact failures and expected fixes on the PR.
7. If passing, approve and allow merge to `develop`.

Never merge to `main`.
