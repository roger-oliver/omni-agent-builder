---
name: data-modeling
description: Use when designing or evolving database schemas, ERDs, indexes, or migrations — naming rules, migration patterns, and data lifecycle conventions.
---

# Data Modeling

## Naming (unless the repo already has a convention — repo wins)

- Tables: `snake_case`, plural (`orders`, `line_items`).
- Columns: `snake_case`; booleans `is_`/`has_`; timestamps `created_at`, `updated_at`, `deleted_at`.
- Foreign keys: `<referenced_singular>_id`. Junction tables: `<a>_<b>` alphabetical.
- Indexes: `idx_<table>_<cols>`. Unique: `uq_<table>_<cols>`. FKs: `fk_<table>_<ref>`.

## Modeling rules

- Every table gets `id`, `created_at`, `updated_at` unless justified otherwise.
- Soft delete (`deleted_at`) when retention/audit needs it; hard delete only with a retention note.
- Constraints in the DB, not only app code: NOT NULL, UNIQUE, CHECK, FK with explicit `ON DELETE` behavior.
- Enums: DB enum or lookup table — pick one, note it in the ADR for schema decisions.
- Money: integer minor units or `NUMERIC` — never float. Times: UTC. Locales: explicit.

## Spatial (when PostGIS/geospatial is selected)

- Store `GEOGRAPHY` for lat/lon distances, `GEOMETRY` for planar work.
- Always declare SRID (4326 default for WGS84). Add GiST index on spatial columns used in filters.

## Migrations — expand/contract pattern

1. **Expand**: add new tables/columns/indices (nullable or defaulted). Deploy code that writes both when needed.
2. **Backfill**: batched, resumable, progress-logged. Never one long transaction over big tables.
3. **Contract**: drop old structures only after readers/writers are gone.
- Every migration file has a matching **rollback** description or script.
- Migration naming: `<sequence>_<verb>_<object>` matching the repo's tool (Flyway/Alembic/diesel/sqlx/refinements).
- Never edit an applied migration; add a new one.

## Data lifecycle & privacy hooks

- Declare retention per PII-bearing table (owner: `privacy-compliance-reviewer` when GDPR applies).
- PII fields enumerated in the data dictionary with masking/redaction rules (`observability-standards`).

## Outputs

- ERD (Mermaid `erDiagram`), data dictionary (table/column/type/nullability/constraints/purpose), index rationale, migration plan, retention notes → `decision_logs/docs/data-models/`.
- Every entity touched traces to `REQ-###`/`UC-###` IDs.
