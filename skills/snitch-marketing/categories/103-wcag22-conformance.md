## CATEGORY 103: WCAG 2.2 AA conformance audit

Cats 45-49 cover the SEO-flavored a11y minimum (viewport, touch targets, readable text, ARIA labels, color contrast). For brands subject to legal accessibility obligations, public-sector, healthcare, education, large-enterprise B2B, EU-market e-commerce under the European Accessibility Act effective 2025-06-28, that minimum isn't enough. They need full WCAG 2.2 AA conformance, the legal threshold cited in the Americans with Disabilities Act (ADA), Section 508, and EAA.

This is the umbrella a11y category — run the full pass in the sequence defined in `references/accessibility-audit-workflow.md` (automated → keyboard → screen-reader → contrast → reflow/zoom) and group findings under the four WCAG principles (Perceivable / Operable / Understandable / Robust) so coverage gaps are visible.

This category audits the full WCAG 2.2 AA criteria set across the 13 guidelines, organized by the four POUR principles (Perceivable, Operable, Understandable, Robust). It's a depth audit, each criterion gets its own pass/fail with evidence.

### Pre-flight: relevance check

Skip with reason `not applicable` if the brand has no public-facing product AND is not subject to legal accessibility obligations. Otherwise: run if (a) the brand is in healthcare / education / public sector / banking; (b) the brand sells in the EU and is subject to EAA; (c) the brand has had an a11y demand letter or audit request; (d) the brand explicitly markets accessibility as a value.

### The framework: 4 principles, 13 guidelines, 56 Level A+AA criteria (32 A + 24 AA)

| Principle | Guideline count | What it means |
|---|---|---|
| **Perceivable** | 4 | Information presentable in ways users can perceive (alt text, captions, contrast, adaptable layout) |
| **Operable** | 4 | UI navigable by all input methods (keyboard, voice, touch; sufficient time; no seizure-inducing content) |
| **Understandable** | 3 | Content and operation understandable (readable, predictable, error-tolerant) |
| **Robust** | 1 | Compatible with assistive tech (parseable HTML, name/role/value, status messages) |

WCAG 2.2 (released October 2023) added 9 new criteria to 2.1, including focus appearance, dragging movements, accessible authentication, and target sizes. AA conformance requires meeting ALL Level A + Level AA criteria (56 total: 32 Level A + 24 Level AA).

### Evidence required (do not skip)

This category mixes checks the skill can perform statically against source/CSS with checks that need a live runner (axe-core / Lighthouse / Pa11y) or a human (keyboard walk, screen reader). The bundle ships no automated runner. Do the static checks directly; for each runtime step, run it only if an external runner or human tester is available, otherwise Skip-with-reason (e.g. `requires external a11y runner — not run`). Never assert a clean or failing result for a check you didn't actually perform.

**Static checks (perform directly on source / CSS):**

1. Identify the test scope: list 5-10 representative pages covering homepage, content, conversion, post-conversion, error.
2. For each WCAG 2.2 criterion, run the targeted static check where source reveals it:
   - **1.1.1 Non-text content**: `Grep` every `<img>`, `<svg>`, `<canvas>`, `<video>` for a missing accessible alternative (`alt`, `aria-label`, `aria-labelledby`, `<title>`).
   - **1.3.1 Info and relationships**: semantic HTML (Cat 17) + ARIA roles per pattern.
   - **1.4.3 Contrast (minimum)**: text contrast ≥4.5:1; large text ≥3:1 — approximate from linked/inline CSS color pairs (Cat 49 cross-ref; resolved/computed value can differ).
   - **1.4.11 Non-text contrast**: UI components and graphical objects ≥3:1 — same CSS-approximation caveat.
   - **2.1.1 Keyboard (partial, static)**: `Grep` for `<div>`/`<span>` with `onClick` but no `role` + no keyboard handler; `tabindex` > 0 (forced focus order). Full operability is a runtime check (below).
   - **2.4.7 Focus visible (partial, static)**: `Grep` for `outline:none` / `outline:0` without a `:focus-visible` replacement.
   - **2.5.8 Target size (minimum, NEW in 2.2)**: 24x24 CSS pixels minimum (Cat 46 stricter) — approximate from CSS dimensions/padding.
   - **3.3.2 Labels (static)**: `<input>` / `<select>` / `<textarea>` missing an associated `<label for>`, `aria-label`, or `aria-labelledby`.

**Runtime checks (requires an external runner or human; otherwise Skip-with-reason):**

1. Run `axe-core` (or `pa11y` / `Lighthouse a11y`) on each representative page and quote each violation. **Requires an external a11y runner; the bundle has none — Skip-with-reason unless a runner is available.**
2. Walk the full keyboard journey (cross-ref Cat 104), the human-judgment check automated tools miss. **Requires a human or runner — Skip-with-reason otherwise.**
3. Test with a screen reader (cross-ref Cat 105). **Requires a human or runner — Skip-with-reason unless access is available.**
4. Verify the runtime-only criteria that source can't confirm:
   - **2.4.11 Focus not obscured (minimum, NEW in 2.2)**: focused element not fully hidden by author content.
   - **2.5.5 Target size (enhanced, AAA, NEW in 2.2)**: 44x44 CSS pixels — measured rendered size.
   - **3.2.6 Consistent help (NEW in 2.2)**: help mechanisms appear in same order across pages.
   - **3.3.7 Redundant entry (NEW in 2.2)**: previously-entered information auto-filled or selectable.
   - **3.3.8 Accessible authentication (minimum, NEW in 2.2)**: cognitive function tests not required for auth.
   - **4.1.3 Status messages**: dynamic status announcements via ARIA live regions or roles (live behavior).

**Crawl mode:** crawl-mode runtime checks (axe-core via Lighthouse / Pa11y / WAVE, keyboard walk, screen reader) carry the same requirement — run only with an external runner or human; otherwise Skip-with-reason. Static source/CSS checks above still apply to the fetched HTML/CSS.

### Forbidden claims

- "WCAG 2.2 AA is probably not met." If a runner is available, quote violations; otherwise report the static findings you proved and Skip-with-reason on the runtime checks. Don't guess a verdict.
- "Contrast may fail in some places." Quote the specific element + approximated contrast ratio (note resolved value can differ).
- "Keyboard navigation may have gaps." Quote the static signal (e.g. `<div onClick>` with no handler); for the live walk, Skip-with-reason unless a human/runner did it.
- Don't claim "compliant" or "conformant", that's a legal determination based on a complete audit, not the partial static scan we run.

### What to Search For

- Automated a11y audit results per page
- Per-WCAG-criterion checks against representative elements
- Form validation error handling (3.3.1 + 3.3.3)
- Page structure hierarchy (1.3.1, `<main>`, `<nav>`, `<header>`, `<footer>`, heading hierarchy per Cat 16)
- Skip-to-content link (2.4.1)
- Page title uniqueness + descriptiveness (2.4.2, Cat 9 cross-ref)
- Language declaration (`<html lang>`, Cat 52)
- Form label associations (3.3.2, `<label for>` or `aria-labelledby`)
- Status messages on dynamic actions (4.1.3)

### Actually Hurts the Marketing Surface

(Each WCAG violation should be its own finding; below are common patterns on marketing sites.)

- **Decorative images with non-empty alt text** (screen reader announces "image-decorative-flourish", wastes user attention).
  Evidence required: image + non-empty alt + decorative role indication.
- **Form fields without labels** (3.3.2).
  Evidence required: `<input>` element + missing `<label>` association.
- **Color used as the only differentiator** (1.4.1) → audited in depth by **Cat 113 (Color-blind safe design)**. This category should cross-ref the Cat 113 finding rather than duplicate it. Don't double-count.
- **Text contrast below 4.5:1 on body text** (1.4.3, Cat 49 cross-ref).
  Evidence required: text element + measured contrast.
- **UI component contrast below 3:1** (1.4.11, buttons that fail to distinguish from background).
  Evidence required: UI element + measured contrast.
- **Non-keyboard-operable functionality** (2.1.1, typically: dropdowns that only respond to mouse, custom buttons without keyboard handlers).
  Evidence required: keyboard journey + specific dead end.
- **Focus indicator suppressed** (2.4.7, `*:focus { outline: none }` without replacement).
  Evidence required: CSS rule + visual confirmation.
- **Target size <24x24 CSS pixels on touch** (2.5.8 Target Size (Minimum), AA, NEW in 2.2).
  Evidence required: target element measurements.
- **Status messages not announced** (4.1.3, form submission "Saved!" appears visually, no screen reader announcement).
  Evidence required: dynamic UI without ARIA live region.
- **Authentication that requires remembering a CAPTCHA / cognitive puzzle without alternative** (3.3.8 NEW).
  Evidence required: auth flow + CAPTCHA-only step.
- **Skip-link missing** (2.4.1, keyboard users tab through entire nav before reaching content).
  Evidence required: page source + missing skip link.

### NOT a Problem

- Decorative images with empty alt text (`alt=""`) and `aria-hidden="true"`, correct.
- Button without explicit ARIA role when using semantic `<button>`, `<button>` has implicit role; ARIA is redundant.
- Page section without ARIA landmark when semantic HTML5 element is used (`<main>`, `<nav>`, etc.), semantic element provides the landmark.
- Reasonable contrast variations on visited links + non-text decorative elements where aesthetic choice is documented.

### Context Check

1. What's the legal exposure? Healthcare / education / public sector / EAA-covered → run full WCAG 2.2 AA. Indie SaaS → AA is best-practice, not legal requirement (in most jurisdictions, but check).
2. Does the site have user-generated content? If yes, accessibility extends to UGC moderation (heading structure, image alt, etc.).
3. Is there a published accessibility statement? Most legal frameworks (EAA, ADA) reference an accessibility statement page as a remediation signal.
4. Is there a feedback mechanism for users to report a11y issues? Required by EAA + best-practice elsewhere.
5. Are automated audit results triaged into "must-fix" vs "false positive"? Automated tools have ~20-30% false positive rate.

### Reference

WCAG 2.2 specification: https://www.w3.org/TR/WCAG22/

European Accessibility Act: https://ec.europa.eu/social/main.jsp?catId=1202

Section 508: https://www.section508.gov/

axe-core rules: https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md

Deque University WCAG 2.2 mappings: https://dequeuniversity.com/

**Severity tagging:**
- Form fields without labels → Critical.
- Non-keyboard-operable functionality → Critical.
- Authentication requires cognitive puzzle (no alternative) → Critical.
- Text contrast below 4.5:1 on body text → High.
- UI component contrast below 3:1 → High.
- Focus indicator suppressed → High.
- Target size <24x24 → Medium.
- Status messages not announced → Medium.
- Skip-link missing → Medium.
- Color as only differentiator → handled by Cat 113 (do not tag here; cross-ref the Cat 113 finding).

**Fix voice:** `aarron-walter` (primary) | `don-norman` (backup).

Read `souls/aarron-walter.json` before writing the Fix.

Worked fix example:

> Accessibility is design. It's not a checklist of compliance items pasted onto a finished product; it's the discipline that makes the product usable for everyone, and the same discipline makes the product better for everyone.
>
> Walk the audit in three passes.
>
> **Automated pass first.** Run axe-core (Pa11y / Lighthouse) on every representative page. Triage the violations: fix the high-confidence ones (missing labels, color contrast, missing alt text), set aside the false positives (false ARIA-attribute warnings on intentional patterns), document the deferrals.
>
> **Manual keyboard + screen reader pass second.** Automated tools catch ~50% of WCAG violations. The other half, keyboard navigation flow, screen reader announcement order, focus management on dynamic UI, requires a human walking the journey. Pair with an a11y-fluent engineer or designer; the failure modes are non-obvious until you've experienced them.
>
> **2.2-specific pass third.** WCAG 2.2 added nine criteria; check each against the site explicitly. Focus appearance, dragging movements, target size minimum, accessible authentication, redundant entry, consistent help. These are the criteria most frequently missed because they're new.
>
> Then publish an accessibility statement listing what you've audited, what you've fixed, what's known and not yet fixed, and a contact path for users to report issues. The statement isn't legal cover; it's the brand telling users that accessibility is part of the product, not a feature flag.
