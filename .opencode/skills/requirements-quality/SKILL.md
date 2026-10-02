---
name: requirements-quality
description: Use when writing or reviewing requirements, NFRs, or acceptance criteria — enforces Gherkin testability and an NFR taxonomy.
---

# Requirements Quality

## Functional requirements (REQ)

Template per requirement:

```markdown
REQ-001: <imperative one-liner>
Parent: UC-1xx
Priority: Must | Should | Could | Won't
AC-001: Given <precondition> When <action> Then <observable outcome>
AC-002: ...
NFR links: NFR-0xx (if any)
```

## Acceptance criteria (AC) rules — Gherkin

- `Given / When / Then` only. One behavior per AC.
- Then-clause must be **observable and testable** without interpretation (API response, UI state, DB row, log event, metric).
- Ban untestable verbs in Then: "works well", "is fast", "is user-friendly", "handles errors properly" — replace with numbers or explicit states.
- Alternative and exception flows each need at least one AC.

## Non-functional requirements (NFR) taxonomy

Tag every NFR with exactly one category:

| Category | Example testable form |
|---|---|
| Performance | p95 latency ≤ 300 ms at 50 RPS |
| Reliability | 99.9% monthly availability |
| Security | OWASP ASVS L1 items pass; no High+ SAST findings |
| Privacy | PII fields enumerated; retention ≤ 30 days |
| Scalability | sustains 10× current load with <2× cost |
| Observability | every request has trace_id; error budget alerts defined |
| Maintainability | build < 5 min; lint clean; documented verification command |
| Accessibility | WCAG 2.2 AA on all user-facing screens |
| Compatibility | browsers/versions matrix enumerated |

## Testability lint (run before finishing an SRS)

1. Every REQ/NFR has ≥1 AC.
2. Every AC is in Gherkin with a measurable Then.
3. No REQ depends on an undecided stack choice (ask via `stack-policy` instead).
4. Every AC maps to a planned TC (see `test-strategy`).
5. All IDs follow `id-traceability`.
