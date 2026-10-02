---
name: observability-standards
description: Use when defining logging, tracing, metrics, SLIs/SLOs, or alert rules — log schema, OpenTelemetry conventions, PII redaction, and the no-alert-without-runbook rule.
---

# Observability Standards

## Structured log schema (mandatory fields)

| Field | Content |
|---|---|
| `ts` | ISO-8601 UTC timestamp |
| `level` | `trace\|debug\|info\|warn\|error\|fatal` |
| `service` | service/component name |
| `env` | `dev\|staging\|prod` |
| `trace_id` / `span_id` | W3C trace context |
| `event` | stable machine-readable event name |
| `msg` | human summary (no secrets/PII) |
| `user_ref` | pseudonymous/hashed user reference only |

Plus context fields as needed (`req_id`, `http.route`, `db.statement` **sanitized**). Follow **OpenTelemetry semantic conventions** when naming spans/attributes.

## What never goes in logs

- Secrets/tokens/keys (env var **names** only), raw PII (names, emails, addresses, IDs), full auth headers, full request bodies with user content, payment data.
- Redaction rule: hash or drop at the logging call site — do not rely on downstream scrubbers alone.

## Metrics & SLIs

- Golden signals per service: latency, traffic, errors, saturation.
- SLI = precisely measured ratio (e.g. `successful / total` on `GET /orders`, 5-min window).
- SLO = SLI target + window (e.g. 99.9% over 30 days) + **error budget**.

## Alert rules — the no-alert-without-runbook rule

Every alert definition must include: severity, threshold + duration, owner, **runbook link** (written by `technical-writer`), and first action. No runbook → no alert.

- Page only on user-impact SLO burn or imminent exhaustion.
- Everything else is a ticket/dashboard signal. Avoid noisy alerts: dedupe, group, set meaningful thresholds.

## Outputs

- Logging schema + redaction rules → `decision_logs/docs/qa/` or architecture docs.
- SLI/SLO catalog + alert table (SLI | SLO | Window | Budget | Alert | Runbook) → `docs/qa/`.
- Correlation ID propagation notes (HTTP header names, queue headers) for builders.
