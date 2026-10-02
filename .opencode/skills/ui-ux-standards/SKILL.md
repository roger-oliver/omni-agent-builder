---
name: ui-ux-standards
description: Use when creating or reviewing UI/UX artifacts — WCAG 2.2 AA checklist, design token schema, wireframe conventions, and state coverage.
---

# UI/UX Standards

## Accessibility target: WCAG 2.2 AA (non-negotiable)

Checklist for every user-facing screen:

- [ ] Text contrast ≥ 4.5:1 (≥ 3:1 for large text); UI components ≥ 3:1
- [ ] All functionality keyboard-operable; visible focus indicator
- [ ] Images/icons have text alternatives; decorative marked `aria-hidden`
- [ ] Form fields have persistent labels; errors associated via `aria-describedby`
- [ ] Status messages announced (`aria-live`); no focus traps
- [ ] Motion respects `prefers-reduced-motion`
- [ ] Touch targets ≥ 24×24 CSS px (WCAG 2.2 AA)
- [ ] Language of page/changes declared

## Design tokens (W3C-style JSON)

```json
{
  "color": { "brand": { "primary": { "$value": "#0B5FFF", "$type": "color" } } },
  "space": { "md": { "$value": "16px", "$type": "dimension" } },
  "font": { "body": { "$value": "Inter, sans-serif", "$type": "fontFamily" } },
  "radius": { "sm": { "$value": "4px", "$type": "dimension" } }
}
```

- Tokens, not hardcoded values, in component specs. Semantic tokens (`text-muted`) alias primitives (`gray-500`).
- Light/dark as token sets, not forked designs.

## Wireframes & flows

- User journeys reference `UC-###` IDs; each journey step has a screen/state.
- Wireframes: text + Mermaid/ASCII or exported artifacts in `decision_logs/docs/ui-ux/`. Do not assume Figma integration.
- Cover **interaction states** per component: default, hover, focus, active, disabled, loading, empty, error.
- Content and microcopy written out (no "lorem"); locale assumptions stated.

## Handoff to builders

Deliverables bundle: journeys (UC links), wireframes, state matrix, token JSON, a11y notes, open questions. Frontend engineers consume exactly this bundle (`frontend-vue-engineer`, `frontend-react-engineer`).
