## CATEGORY 49: Color contrast on text

Body text needs 4.5:1 contrast ratio against background; large text (18pt+ or 14pt+ bold) needs 3:1. Below those thresholds = WCAG AA fail = Lighthouse a11y demerit. SEO value is indirect (accessibility/UX); Google's Mobile Usability report was retired Dec 1 2023, so there's no live mobile-usability test that flags contrast.

Report contrast findings in the verification-table format from `references/accessibility-audit-workflow.md` (element URL+selector | foreground | background | ratio | required | pass) — never assert a ratio without the two hex values it was computed from.

**Scope:** this category audits **contrast ratios only** (WCAG 1.4.3, 1.4.6, 1.4.11). It does not audit color-blindness — color used as the only signifier of meaning is a separate failure mode covered by **Cat 113 (Color-blind safe design)**. A site can pass every ratio threshold here and still fail Cat 113, and vice versa. Don't conflate them.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` CSS for `color:`, `background-color:`, `background:`. Identify text + background pairs.
2. For each pair: compute contrast ratio (you can do this mathematically; the formula is well-defined).
3. Quote the pair + computed ratio + the threshold it fails.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Parse linked/inline CSS and approximate the text + background color pairs from declared rules. Caveat: `Fetch` returns source, not the resolved cascade — the computed/rendered colors (and thus the ratio) can differ from what you approximate.
2. Compute contrast ratios from the approximated pairs. Identify likely failures (verify the resolved colors before asserting if the cascade is ambiguous).

### Forbidden claims

- "Contrast may be insufficient." Compute and quote ratios.
- "Some elements may fail WCAG." Be specific.

### Detection

Text + background color pairs in CSS, contrast ratios approximated from declared colors (resolved value can differ).

### What to Search For

- Light gray text on white (`color: #999` on `background: #fff` = 2.85:1, fails)
- Light blue links on light backgrounds
- White text on yellow / orange (low contrast)

### Actually Hurts SEO

(Indirect: accessibility/UX value (WCAG 1.4.3/1.4.11, Lighthouse a11y). SEO benefit is indirect via readability/engagement; the retired Google Mobile Usability report no longer flags contrast.)

- **Body text contrast <4.5:1**.
  Evidence required: text color + background color + computed ratio.
- **Large text contrast <3:1**.
  Evidence required: same.
- **Link text contrast against body text below 3:1** (WCAG 1.4.11 non-text contrast — links must have a 3:1 distinction from surrounding text when underline / weight / other non-color signal is absent).
  Evidence required: link color + body color + measured contrast ratio.
  Note: if the link relies on color alone to indicate it's a link (no underline, no weight change, no icon), that's a separate Cat 113 finding (color-only signal). Don't double-count; link the two findings if both apply.

### NOT a Problem

- Decorative text (brand wordmark in hero, low-contrast watermarks). Don't flag.
- Disabled-state text (intentionally low contrast).

### Context Check

1. Is the background a gradient or image? Compute against the most-likely background pixel under the text.
2. Is this body text (4.5:1) or large text (3:1)?
3. Is the WCAG target AA or AAA? AAA is 7:1 for body. Most projects target AA.

### Reference

WebAIM Contrast Checker: https://webaim.org/resources/contrastchecker/

WCAG 1.4.3 Contrast (Minimum): https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html

**Severity tagging:**
- Body text <4.5:1 → High.
- Large text <3:1 → High.
- Link-to-body contrast <3:1 (when no other non-color signal) → Medium.

**Brand-impact note:** contrast fixes change color values. Color values are brand identity. Even when a fix is correct (a 4.6:1 ratio is mathematically better than a 2.85:1 one), the user must explicitly confirm before any palette write — see SKILL.md Post-Scan flow. Don't auto-apply color changes; surface the proposal, quote the before / after / ratio, and let the user approve per finding.

**Fix voice:** `dieter-rams` (primary) | `don-norman` (backup).

Read `souls/dieter-rams.json` before writing the Fix. Rams's "color is functional", contrast is the function.

Worked fix example:

> If the user can't read the text, the design has failed before the content even matters. Run the contrast check, find the failures, fix them by adjusting the lighter color toward more contrast.
>
> ```css
> /* Bad: 2.85:1, fails AA for body */
> .body-text { color: #999; background: #fff; }
>
> /* Good: 4.6:1, passes AA for body */
> .body-text { color: #767676; background: #fff; }
>
> /* Better: 7.2:1, passes AAA */
> .body-text { color: #595959; background: #fff; }
> ```
>
> The "lighter is more elegant" instinct is wrong when the text becomes unreadable. Functional contrast first; visual subtlety second.
