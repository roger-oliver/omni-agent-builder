---
name: local-environment
description: Use when bringing up or tearing down a project's local development environment, creating per-iteration test databases, running local migrations, or syncing the local dev database after a merge.
---

# Local Environment

All environment operations are **project-driven**: read `.omni/orchestrator.config.json` → `local_env`. Never assume an engine, runtime, container name, port, service, or script path.

## Contract (all fields project-defined)

```jsonc
"local_env": {
  "runtime": "docker",              // docker | podman | local | none — whatever the project uses
  "services": [
    { "name": "db", "kind": "database", "engine": "<engine>",
      "container": "<container>", "host": "127.0.0.1", "port": 5432,
      "test_db_prefix": "<project>_test", "dev_db": "<project>_dev" }
  ],
  "scripts": {
    "up": "bash scripts/dev-up.sh",
    "down": "bash scripts/dev-down.sh",
    "migrate": "bash scripts/db-migrate.sh",
    "query": "bash scripts/db-query.sh",
    "seed": "bash scripts/db-seed.sh"
  },
  "health_urls": ["http://127.0.0.1:<port>/health"]
}
```

If `local_env` or a required script is missing → **stop and ask** (blocking gap). Do not invent defaults.

## Lifecycle

1. **Up** — run `scripts.up`; verify the configured health URLs/ports (Evidence).
2. **Test database per iteration** — name `<test_db_prefix>_<feature>[_<n>]`; create via `scripts.migrate`, passing the DB name through the configured environment variable **name** (never inline credentials).
3. **Verify** — the migration ledger matches the repo's migration files; seed synthetic data only via `scripts.seed`.
4. **Down** — `scripts.down` or targeted teardown when asked.
5. **Post-merge sync** — after a merge to `develop`, run `scripts.migrate` against the local `dev_db`; verify ledger parity; report evidence to `decision_logs/docs/qa/`.

## Rules

- **Local only** — never staging, production, remote infrastructure, or cloud resources.
- Raw `docker compose`, `psql`, `mysql`, `sqlite3` are not the sanctioned path (they prompt); use project scripts.
- Secrets: environment-variable names only; never echo DB passwords (the project scripts/container env hold the values).
- Destructive operations on the dev DB require explicit human approval; per-iteration test databases are disposable but announced.
- Report exact commands and results; never claim success without output.
