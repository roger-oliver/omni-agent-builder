---
name: security-review
description: Use when performing SAST, DAST, dependency audits, or PR security checks — defines severity taxonomy, findings table, OWASP mapping, and secret-detection patterns.
---

# Security Review

## Severity taxonomy (mandatory)

| Severity | Meaning | Action |
|---|---|---|
| Critical | Exploitable now, data/system compromise | Block merge; fix immediately |
| High | Exploitable with modest effort | Block merge |
| Medium | Needs chaining or misconfig to exploit | Fix in this feature or schedule with ADR note |
| Low | Hardening opportunity | Backlog |

Optionally add a CVSS v4 vector string. When CVSS conflicts with the table, the table wins (context judgment).

## Findings table (mandatory output shape)

| DEF ID | Location (file:line) | Severity | OWASP/ASVS | Evidence | Exploitability | Remediation |
|---|---|---|---|---|---|---|

- `DEF-###` IDs per `id-traceability`. Evidence must be a quote/snippet, never a paraphrase.
- One row per finding. No findings → explicit "No findings at [scope]" line with the scanner commands run.

## Tool-first rule

1. Prefer deterministic scanners (repo-native linters, semgrep-class scanners, `cargo audit`, `pip-audit`, `osv-scanner`, `npm audit`, `dotnet list package --vulnerable`).
2. LLM judgment **triages and writes remediation only** — never the sole detector for High+ claims.
3. Record scanner name + command in `Verification`.

## Scope categories (map findings to these)

A01 Broken access · A02 Crypto failures · A03 Injection · A04 Insecure design · A05 Misconfig · A06 Vulnerable components · A07 Auth failures · A08 Data integrity · A09 Logging failures · A10 SSRF. (OWASP Top 10; cite ASVS level when known.)

## Secret-detection patterns (never print the secret value)

- API keys/tokens: `AKIA…`, `ghp_…`, `sk-…`, `xox[baprs]-…`, `eyJ…` (JWT), long base64/hex blobs ≥ 32 chars assigned to sensitive-looking names.
- Private keys: `-----BEGIN … PRIVATE KEY-----`.
- Connection strings with inline passwords: `proto://user:pass@`.
- Hardcoded credentials in config, CI files, test fixtures, and logs.
- Response: report `file:line`, variable **name**, pattern class only.

## Hard rules

- DAST only against explicitly approved staging URLs. Never production, never third-party systems.
- Never execute destructive or state-changing probes without explicit approval.
- Secrets: environment variable **names** only in all outputs.
