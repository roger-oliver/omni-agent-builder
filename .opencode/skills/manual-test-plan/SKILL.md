---
name: manual-test-plan
description: Use when preparing the step-by-step manual test document for a delivery, iterating on user-reported problems, and gating the merge to develop on user approval.
---

# Manual Test Plan

One document per delivery, per repository. It lives with the candidate branch and travels through the PR: `<repo>/docs/qa/manual-tests/<delivery>.md`. Register every document in the project's decision_logs index (`docs/qa/manual-tests.md`, resolved from `repos.decision_logs.local_path`).

## Template

```markdown
# Manual test — <feature> (<repo>)

- Branch: <branch> · Commit: <sha> · Date: <date>
- Requirements: <REQ / AC IDs>
- Environment: <local URLs / ports from local_env>
- Prerequisites: services up (`scripts.up`); test DB <name> migrated and seeded

## Setup

1. <exact command / env-var names only>

## Steps

1. <action> → expected: <observable result> (REQ-<id> / AC-<id>)
2. … include negative and error cases

## Problem points (updated every iteration)

| # | Symptom | Steps to reproduce | Expected vs actual | Fix applied | Retest |
|---|---|---|---|---|---|

## Approval

- [ ] All steps pass · Tester: <name> · Date: <date>
```

## Iteration loop

1. Build finished on the candidate branch; local test DB migrated (`local-environment`).
2. Write v1 of the document (numbered steps, expected results, REQ mapping).
3. The user tests manually and reports problems.
4. Fix on the same branch; **update the document**, emphasizing the problematic points (new rows, regression steps, retest instructions).
5. Repeat until the user approves.
6. **Only after approval**: merge the candidate PR to `develop` with a merge commit. Release and deploy commands remain the user's responsibility.

## Rules

- Steps must be executable by a human without reading code; commands exact; credentials as environment-variable names only.
- Every step maps to a `REQ`/`AC`; every reported problem gets a table row and a retest step.
- Never merge before approval; never deploy or release.
- The document is history: append iterations — never erase them.
