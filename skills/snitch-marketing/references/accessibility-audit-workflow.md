# Accessibility audit workflow

The accessibility categories (49 color contrast, 103 WCAG 2.2 conformance, 104 keyboard
navigation, 105 screen-reader semantics, 113 color-blind-safe design) each audit one slice. This
reference gives the *sequence* to run them in and a shared evidence format, so an a11y pass is
systematic rather than a scattered set of independent checks. Organize findings by the four WCAG
principles (Perceivable, Operable, Understandable, Robust) so coverage gaps are visible.

## When surfaced

Loaded when any of cats 49 / 103 / 104 / 105 / 113 fire, or when the user asks for an accessibility
review / WCAG audit. In crawl mode without JS rendering, mark the DOM-dependent steps Skip per the
SKILL.md crawl-mode rule.

## The sequence (cheapest signal first)

Run in this order; each step catches what the previous can't. Automated tooling catches only a
fraction of issues, so the manual steps are not optional.

1. **Automated scan** (catches ~30-40%) — parse the rendered DOM for the mechanical failures:
   missing `alt`, unlabeled form controls, missing `lang`, empty links/buttons, duplicate IDs,
   missing `<title>`. Cheap; do first. (Cats 25/48/52 overlap here.)
2. **Keyboard-only pass** (Operable) — Tab through every interactive element. Check: visible focus
   ring, logical focus order, no keyboard traps, skip-link present, custom widgets operable with
   Enter/Space/arrows. (Cat 104.)
3. **Screen-reader semantics** (Perceivable + Robust) — landmark regions (`<main>`/`<nav>`/
   `<header>`), heading outline, accessible names on controls, ARIA used correctly (not as a
   band-aid over non-semantic HTML), live-region announcements. (Cats 17/48/105.)
4. **Color contrast** (Perceivable) — text and meaningful UI against background; use the table
   below. (Cats 49/113.)
5. **Reflow + zoom** (Perceivable + Operable) — 200% browser zoom and ~320px viewport: no
   horizontal scroll, no clipped/overlapping content, tap targets stay ≥24×24 (WCAG 2.2) and ideally
   44×44. (Cats 46/47.)

## Contrast verification table (evidence format)

Quote contrast findings as a table so the reader can verify each ratio. Required ratios (WCAG AA):
normal text **4.5:1**, large text (≥24px, or ≥18.66px bold) **3:1**, non-text UI/graphics **3:1**.

| Element (URL + selector) | Foreground | Background | Ratio | Required | Pass |
|---|---|---|---|---|---|
| Hero subhead `/#hero p.sub` | `#9aa0a6` | `#ffffff` | 2.6:1 | 4.5:1 | fail |
| Primary button `/.btn-primary` | `#ffffff` | `#c9a84c` | 2.1:1 | 4.5:1 | fail |

Quote the actual computed colors (from CSS or rendered styles) and the URL+selector — never assert
a ratio without the two colors it was computed from (Rule 1). Color-blind-safe checks (Cat 113)
additionally verify meaning isn't carried by color alone (redundant icon/label/pattern).

## Reporting by principle

Group the a11y findings under Perceivable / Operable / Understandable / Robust in the report so a
missing principle (e.g., zero Operable findings because the keyboard pass was skipped) is obvious.
Note which steps were Skipped and why (e.g., "screen-reader + keyboard steps need a JS-rendering
crawler or in-editor source; ran automated + contrast only").

## Forbidden claims

- A contrast "fail" without both hex values and the URL+selector.
- "Not keyboard accessible" without naming the element and what the Tab pass showed.
- "Screen-reader inaccessible" inferred from source alone when a render check was needed — mark it
  Skip-with-reason instead.

---

*Workflow structure (sequenced testing + principle grouping + contrast table) adapted from the
Apache-2.0 `anthropics/knowledge-work-plugins` design/accessibility-review skill, reimplemented
under Snitch's evidence-first constraints. Internal reference only; not surfaced in reports.*
