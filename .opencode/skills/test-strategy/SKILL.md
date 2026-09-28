---
name: test-strategy
description: Use when creating unit, integration, E2E, or load tests — defines the test pyramid, naming/traceability tags, coverage expectations, and synthetic-only test data policy.
---

# Test Strategy

## Test pyramid

| Layer | Owner | Ratio guide | Scope |
|---|---|---|---|
| Unit | `unit-test-generator` | ~70% | Pure logic, normal/alternative/exception flows from ACs |
| Integration | `integration-tester` | ~20% | API contracts, DB behavior, service boundaries, external fakes |
| E2E (browser) | `e2e-test-engineer` | ~10% | Critical user journeys only (from `UC` basic flows) |
| Non-functional | `load-simulator`, `accessibility-auditor` | as needed | NFR thresholds, WCAG |

## Naming and traceability tags

- Test name contains or attributes/tags carry the `AC-###`/`REQ-###` it covers, e.g. `test_req_001_ac_002_…` or `[Trait("Req","REQ-001")]`.
- One TC ID (`TC-###`) per test, referenced in the RTM.
- Tests live beside the code under test, using the repo's native layout — never invent a parallel convention.

## Coverage expectations

- Every `AC` has ≥1 passing TC before G10 (PR validation).
- Branch coverage target: match repo convention if one exists; otherwise state the achieved number, do not invent a mandate.
- Flaky tests are defects (`DEF-###`) — do not silently retry.

## Test data policy

- **Synthetic data only.** No real PII, no production dumps, no real credentials (use env var names).
- Fixtures are deterministic and versioned with the tests.
- Time, randomness, and network are faked or controlled; document the seam used.

## Execution rules

- Discover the repo's test command first (never assume `pytest`/`cargo test`/`dotnet test` — run what the repo shows in CI/Makefile/docs).
- After edits, run the relevant subset; if unable, state why and give the exact command in `Verification`.
- Report format: `TC-### | AC-### | Pass/Fail | Evidence (output excerpt)`.
