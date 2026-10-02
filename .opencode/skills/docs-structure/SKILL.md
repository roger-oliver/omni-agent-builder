---
name: docs-structure
description: Use when creating or organizing documentation — information architecture for decision vs product repos, doc types, audience tagging, and release notes template.
---

# Docs Structure

## Where docs live

| Content | Repo | Path |
|---|---|---|
| Business context, use cases, SRS, architecture, ADRs, RTM, QA reports, release notes | `decision_logs` | `docs/<area>/` (areas: `business-context`, `use-cases`, `requirements`, `architecture`, `api-contracts`, `data-models`, `ui-ux`, `adr`, `traceability`, `qa`, `release-notes`) |
| README, onboarding, API reference, runbooks, troubleshooting | product repo (`frontend`/`backend`) or `decision_logs` if shared | `docs/` at repo root |

Never mix product decision records into code repos and never put generated product code in `decision_logs`.

## Doc types and skeletons

| Type | Must contain |
|---|---|
| Onboarding | Prereqs, setup steps, verify command, troubleshooting pointers |
| API reference | Generated-from-contract or hand-written per `api-design`; examples synthetic |
| Architecture | Context, containers/components, decisions → `ADR` links, data flows |
| Runbook | Trigger, impact, step-by-step recovery, validation, escalation owner |
| Troubleshooting | Symptom → cause → fix table |
| Release notes | see template below |

## Audience tagging

Every doc header carries: `Audience: developer | operator | user` (multiple allowed). Write to the lowest-complexity register that preserves technical precision.

## Release notes template

```markdown
# <product> v<version> — YYYY-MM-DD
Audience: user, developer, operator
## Highlights        (user-visible)
## Changes           (REQ IDs + PR links)
## Decisions         (ADR IDs)
## Fixes             (DEF IDs)
## Upgrade notes     (breaking/migration steps)
## Verification      (commands + results)
```

## Rules

- Prefer concise, searchable Markdown. Tables and checklists over prose walls.
- Secrets: env var names only. Links to ADRs/REQs use real IDs (`id-traceability`).
- Tooling (MkDocs/ReadTheDocs/plain Markdown) follows repo evidence; ask before adding doc-site dependencies.
