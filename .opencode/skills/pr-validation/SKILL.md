---
name: pr-validation
description: Use when reviewing PRs against requirements, ADRs, acceptance criteria, tests, lint/build results, security, dependencies, and traceability.
---

# PR Validation

## Validation checklist (complete every row)

| # | Check | Evidence required |
|---|---|---|
| 1 | Scope matches the requested work (no unrelated changes) | diff summary |
| 2 | REQ/NFR/AC coverage — every changed line serves a listed ID | ID ↔ hunk mapping |
| 3 | ADR compliance — decisions match accepted ADRs; new decisions get a new ADR | ADR IDs |
| 4 | Tests present for each AC; naming/tags per `test-strategy` | TC IDs + run output |
| 5 | Build passes | command + result |
| 6 | Lint/format passes | command + result |
| 7 | SAST / secret scan clean (or accepted findings with DEF IDs) | scanner output |
| 8 | Dependency audit clean (or ADR-noted exceptions) | audit output |
| 9 | Traceability updated (RTM rows added/updated) | RTM diff |
| 10 | PR body complete (Summary, IDs, ADRs, Verification commands) | PR body |

Findings use the severity taxonomy and findings table from `security-review` (for security items) or `DEF-###` rows with `High/Medium/Low` for non-security gaps.

## Loop and labels (bounded)

1. Failing checks → comment **exact** failures + expected fixes; label `needs-work`.
2. Builder fixes the same branch; re-run the full checklist (not only failed rows).
3. **Max 3 validation loops** per PR. After the third failure: stop, keep `needs-work`, escalate to the orchestrator → human with a summary of unresolved DEF IDs.
4. Passing → comment approval, label `approved`, allow merge to `develop` as a **merge commit** (per `github-workflow`).

Never merge to `main`. Never force-push. Never validate against unregistered repos.
