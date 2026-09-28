---
name: api-design
description: Use when designing or reviewing API contracts (OpenAPI, GraphQL, gRPC) — REST conventions, error envelope, pagination, idempotency, and versioning.
---

# API Design

Defaults: REST + OpenAPI 3.x unless the architecture selects GraphQL/gRPC explicitly (record the choice in an ADR).

## Resource conventions

- Nouns in kebab-case paths; `snake_case` JSON fields (or match repo convention — repo wins).
- HTTP verbs: `GET` read (idempotent), `POST` create/action, `PUT` full replace, `PATCH` partial update, `DELETE` remove (prefer soft delete; note retention in `data-modeling`).
- Status codes: `200/201/204` success, `400` validation, `401/403` auth, `404` absence, `409` conflict, `422` semantic error, `429` rate limit, `5xx` server.

## Standard error envelope (mandatory)

```json
{
  "error": {
    "code": "machine_readable_code",
    "message": "Human summary without secrets/PII",
    "details": [{ "field": "email", "issue": "invalid format" }],
    "trace_id": "…"
  }
}
```

## Pagination, filtering, idempotency

- List endpoints: cursor pagination (`?cursor=&limit=`) or match repo standard; always cap `limit`.
- Filtering/sorting: declared in the contract with allowed fields enumerated.
- Unsafe creates that clients may retry: accept `Idempotency-Key` header; declare retention window.

## Versioning

- URL major version (`/v1/…`) or header versioning — pick one, document it in the contract and an ADR.
- Never break response shape inside a version; additive fields only. Deprecations need `Sunset` + migration note.

## Security & traceability

- Declare auth scheme per endpoint (none is a decision — say so).
- Rate limits and payload size caps declared when relevant.
- Every endpoint maps to `REQ-###`/`UC-###` IDs (per `id-traceability`).
- Examples for every request/response schema; examples must be synthetic data.
