# Pull Request

## Summary

<!-- What changes? One short paragraph. -->

## Motivation / linked items

<!-- Requirement/issue IDs (REQ-###, UC-###, DEF-###) or link an issue. If none, say why this PR exists. -->

- Closes #
- ADRs: <!-- ADR-#### if this changes or records a decision -->

## Type of change

- [ ] Agent/skill/policy prompt change
- [ ] Script or configuration change (`scripts/`, `opencode.json`, `.github/`)
- [ ] Documentation only
- [ ] Bug fix
- [ ] Other (describe)

## Checklist

- [ ] No secrets, tokens, credentials, or PII added (environment variable **names** only)
- [ ] No instructions that bypass agent safety rules (human-approval gates, repo registration, force-push prohibition)
- [ ] `opencode.json` / `.omni/*.json` still parse as valid JSON
- [ ] Agent files keep the standard structure (frontmatter `model:` from the approved set, operating-contract reference)
- [ ] CI checks pass
- [ ] For behavior changes: verification commands and results listed below

## Verification

<!-- Exact commands run + results, e.g.:
     $ python3 -m json.tool opencode.json  -> OK
-->

## Risk / rollback

<!-- What could break? How to revert if needed? -->
