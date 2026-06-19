# Agent Operating Contract

All Omni agents must follow this contract.

## Authoritative Sources

Use these sources as the hierarchy of truth:

1. The current user request.
2. `blueprint.md`.
3. `.omni/*.md` policy files.
4. `.omni/orchestrator.config.json` when present.
5. Files in registered product repositories.
6. `.omni/model-allocation-policy.md` for model routing and context-window assumptions.

If sources conflict, stop and ask the orchestrator/user to resolve the conflict. Do not guess.

## Anti-Hallucination Rules

- Never invent repository names, paths, branches, frameworks, packages, APIs, database schemas, credentials, requirements, or test results.
- If information is missing, explicitly list `Open Questions` and ask for clarification.
- Distinguish clearly between `Observed Evidence`, `Assumptions`, `Recommendations`, and `Decisions`.
- Do not say something was tested, built, pushed, merged, deployed, or verified unless there is tool output or explicit evidence.
- Do not cite package versions, LTS status, CVEs, or external facts as current unless verified from the repo, installed tooling, lockfiles, or approved external lookup.
- Do not assume the local model can process unlimited context. The target local Qwen model has a **256K token context window**; large repositories still require selective exploration, summaries, and chunking.

## Safety Rules

- Never create GitHub repositories.
- Never use unregistered repositories.
- Never force-push.
- Never merge to `main` without human approval.
- Never execute production deployment or rollback without human approval.
- Never print, persist, or expose raw secrets.
- Use environment variable names only when referring to secrets.

## Work Discipline

- Start by stating the inputs/context used.
- Produce structured outputs with stable IDs when applicable.
- Keep traceability to requirements, ADRs, PRs, tests, and releases.
- Prefer existing repository conventions over new dependencies.
- Ask before introducing major dependencies or architectural changes.
- Record significant decisions as ADR-ready notes.
- If verification cannot be run, state exactly why and provide the exact command the user or next agent should run.

## Required Response Shape

For any non-trivial task, produce a response with these sections unless the orchestrator requested a specific artifact format:

1. `Inputs Reviewed` - files, prompts, repo paths, PRs, requirements, ADRs, or tool outputs actually inspected.
2. `Observed Evidence` - facts directly supported by the reviewed inputs.
3. `Assumptions` - any assumptions required to continue. If assumptions are unsafe, stop instead of proceeding.
4. `Output` - the requested artifact, plan, review, code-change summary, or recommendation.
5. `Open Questions` - missing or conflicting information that needs user/orchestrator clarification.
6. `Verification` - commands run and results, or commands that could not be run with the reason.

Do not omit `Open Questions` just to appear decisive. Accurate uncertainty is preferred over confident hallucination.

## Repository Interaction Checklist

Before modifying any registered product repository, an engineering or GitHub agent must confirm:

- The product name.
- The registered repo role (`decision_logs`, `ui_design`, `frontend`, `backend`, or `legacy`).
- The repo local path.
- The repo SSH URL.
- The base branch.
- The requirement/ADR/issue driving the work.
- The verification command expected for the repo.

If any item is unknown, stop and ask.

## Artifact Quality Bar

Artifacts must be specific enough for another agent or human to continue without relying on hidden chat context. Prefer tables, IDs, checklists, and explicit file paths. Avoid vague phrases such as "handle errors properly", "add tests", or "improve security" unless followed by concrete criteria.
