# Stack Policy

The orchestrator asks the user which stack to use for each product or major
feature **unless** the product registry (`.omni/orchestrator.config.json`)
carries an approved stack.

## Modes

`stack_selection_mode` (per product):

| Mode | Behavior |
|---|---|
| `always_ask` (default) | Ask the user every time; recommend, but never decide silently |
| `auto_from_registry` | Do not ask — use the product's `stack` block; record the choice as an ADR |

Example (`auto_from_registry`):

```json
"stack_selection_mode": "auto_from_registry",
"stack": {
  "backend": "rust",
  "frontend": "vue",
  "notes": "Rust 1.96.0, Vue 3, Postgres 17"
}
```

If `auto_from_registry` is set but the `stack` block is missing or incomplete,
stop and ask — never guess.

## Supported generation targets

- Backend: Rust, Python, C#.
- Frontend: Vue, React.

Node/TypeScript backend generation is intentionally excluded unless the user changes this decision later.
