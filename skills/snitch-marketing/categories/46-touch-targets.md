## CATEGORY 46: Touch target size

Mobile touch targets (buttons, links, form controls) must be at least 24x24 CSS pixels per WCAG **2.5.8 Target Size (Minimum)** (AA, new in 2.2). The stricter 44x44 is **2.5.5 Target Size (Enhanced)** (AAA); Apple HIG and Material Design recommend 44x44 too, but they're additional support, not the source of the rule — the rule is WCAG. Smaller targets fail accessibility and fail usability. (Google's old Mobile Usability report was retired Dec 1 2023, so there's no live "mobile usability check" to fail anymore; the value here is accessibility/UX, with only indirect SEO benefit via engagement.)

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for buttons + interactive elements. Read CSS for their dimensions / padding.
2. For each interactive element: estimate rendered touch target size.
3. Identify cluster patterns (links spaced too close to each other → effectively unclickable on touch).

**Crawl mode, required tool calls:**

1. `Fetch` URL. Parse linked/inline CSS and approximate each interactive element's size from declared dimensions/padding. Caveat: `Fetch` returns source, not the resolved cascade — the computed/rendered size can differ from what you approximate.
2. Touch targets approximated <44x44 with no spacing buffer = finding (verify rendered size before asserting if the cascade is ambiguous).

### Forbidden claims

- "Touch targets may be too small." Quote the elements + their approximated dimensions (note resolved size can differ).
- "Mobile usability/accessibility may suffer." Show specific elements.

### Detection

CSS dimensions of interactive elements.

### What to Search For

- Inline icons used as buttons (often 16x16 or 24x24)
- Text-only links in tightly-packed lists
- Close buttons / dismiss icons in modals (often too small)
- Footer link grids with no padding

### Actually Hurts SEO

(Indirect: accessibility/UX value (WCAG 2.5.8, Lighthouse a11y). SEO benefit is indirect via engagement/mobile experience; the retired Google Mobile Usability report no longer scores this.)

- **Interactive elements <24x24 CSS pixels** (WCAG 2.5.8 Minimum, AA).
  Evidence required: element + its approximated size from CSS (note resolved value can differ).
- **Touch targets within 8px of other touch targets** (no buffer).
  Evidence required: spacing between targets.

### NOT a Problem

- Inline links inside body text (acceptable target size; users tolerate due to context).
- Decorative icons that aren't interactive.
- Desktop-only sites (rare; flag as Low for them).

### Context Check

1. Is this a primary action (CTA, form submit)? Should be 48-64px.
2. Is this a secondary action (close, expand)? 44x44 minimum.
3. Is the spacing between targets adequate?

### Reference

WCAG 2.5.8 Target Size (Minimum), AA, new in 2.2 (the 24x24 rule): https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html

WCAG 2.5.5 Target Size (Enhanced), AAA (the 44x44 rule): https://www.w3.org/WAI/WCAG22/Understanding/target-size-enhanced.html

Material Design touch targets (additional support, not the source of the rule): https://m3.material.io/foundations/accessible-design/accessibility-basics

**Severity tagging:**
- Primary CTA <44x44 → High.
- Secondary buttons <24x24 → Medium.
- Adjacent targets without buffer → Medium.

**Fix voice:** `don-norman` (primary) | `aarron-walter` (backup).

Read `souls/don-norman.json` before writing the Fix. Norman wrote the book on usability; touch targets are the most basic affordance.

Worked fix example:

> A target the user can't reliably hit isn't a button. The fix is dimensions plus spacing.
>
> ```css
> /* Minimum: 44x44 hit area */
> button, .button {
>   min-height: 44px;
>   min-width: 44px;
>   padding: 12px 16px;
> }
>
> /* Adequate spacing between adjacent targets */
> .button-group { gap: 12px; }
> ```
>
> Visual size and hit-area size can differ, a 24px icon button can have 44x44 hit area via padding. The user only sees the icon; the touch hits the padding too. Both work.
