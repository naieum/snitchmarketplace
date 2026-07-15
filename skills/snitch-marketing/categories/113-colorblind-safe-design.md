## CATEGORY 113: Color-blind safe design

Roughly 1 in 12 men and 1 in 200 women have some form of color vision deficiency: the most common is red-green (deuteranopia / protanopia), then blue-yellow (tritanopia), then full achromatopsia. WCAG 1.4.1 (Use of Color) and ISO 9241-112 both prohibit using color as the **only** way to convey meaning — meaning every state, status, link, error, and category that's encoded by color alone is unreadable to those users.

Run alongside Cat 49 in the contrast step of `references/accessibility-audit-workflow.md`: contrast is "is it legible," this is "does meaning survive without color" (require a redundant icon, label, or pattern). Use the same evidence discipline — quote the element + the color-only signal it relies on.

This is **not** the same as a contrast failure. A 4.6:1-passing red-on-white error message that has no icon, no asterisk, and no text marker is a Cat 113 failure even though Cat 49 (Color contrast) marks it as passing. The site can be perfectly readable in luminance and still completely unreadable in semantics.

**Cat 49 audits ratios; Cat 113 audits whether color carries meaning that isn't redundantly encoded somewhere else.** Both can fail independently.

### Pre-flight: relevance check

Always run unless the surface has zero color-coded state, status, link, category, or error indication, which is rare. Public-sector / healthcare / education / EAA-covered: required. Marketing-focused commercial sites: strongly recommended (Cat 1.4.1 is Level A, the lowest WCAG bar; failures here block ADA suits in the U.S. and EAA enforcement in the EU as of 2025-06-28).

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for color-encoded state classes: `.error`, `.success`, `.warning`, `.danger`, `.required`, `.active`, `.disabled`, `.new`, `.featured`, status pills, severity tags. For each match, inspect the rendered output: is the meaning conveyed *only* by color, or does it also have an icon, text label, asterisk, weight change, position, or pattern?
2. `Grep` link styling for `text-decoration: none` paired with a color shift. If the link relies on color alone (no underline, no weight, no icon) to signal it's a link, that's a finding.
3. `Grep` chart / data-viz code (`recharts`, `chart.js`, `d3`, `victory`, etc.) for series differentiated by color alone with no marker shape, no pattern, no direct labeling, no legend differentiation beyond the color swatch.
4. For each finding, quote the file:line and describe the meaning that's being conveyed by color alone.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Identify state-bearing UI: form errors, success messages, warning banners, status pills, badges, links, charts.
2. For each: confirm the redundancy channel (icon / text / pattern / position / weight). If absent, that's a finding.
3. Take screenshots through a color-blindness simulator (e.g., Chrome DevTools → Rendering → Emulate vision deficiencies → Deuteranopia / Protanopia / Tritanopia). Quote elements that become indistinguishable.

### Forbidden claims

- "May not be color-blind safe." Walk the surface, identify specific elements, name the deficiency it fails under (deuteranopia / protanopia / tritanopia / achromatopsia).
- "Add some color-blind support." Specify the exact element, the meaning it conveys, and the redundant channel that's missing (icon / text / pattern / weight / position).
- "Use color-blind-friendly palettes." A palette swap doesn't fix Cat 113 — it fixes nothing if the meaning is still encoded only in color. The fix is *adding a redundant channel*, not changing the color.

### What to Search For

- Form errors that turn the field border red but add no icon, no error message text, no asterisk
- "Required" fields marked only by red label color, no asterisk, no `aria-required`
- Status pills (Active / Pending / Failed / Approved) differentiated only by background color
- Links inside paragraph text styled with `text-decoration: none` and a color shift only
- Severity badges (High / Medium / Low) differentiated only by background color
- Stock charts, data visualizations, dashboards using only color to distinguish series
- Heat maps without a numeric label or pattern overlay
- Calendar UIs that mark "selected" / "today" / "disabled" only by background color
- Map UIs with categorical color-coded regions and no pattern fill or text label
- Diff views (red = removed, green = added) with no `+` / `-` prefix, no shape change

### Actually Hurts the Marketing Surface

- **Form error states use only red border / red text** (1.4.1). User with deuteranopia submits a form, sees no obvious error, retries the same input, bounces. Conversion lost.
  Evidence required: form field + error rendering + missing icon / text / aria.
- **"Required" indicator uses only red label color**. Sighted users with red-green CVD perceive the label as the same color as adjacent labels and miss the requirement.
  Evidence required: label markup + missing asterisk / `aria-required` / "required" text.
- **Status pills (Active / Failed / Pending) differentiated only by hue**. Inboxes, dashboards, order histories — the pill becomes a blob of indistinguishable color states.
  Evidence required: pill markup + missing icon / text / position differentiation.
- **Inline links are color-only**. The user can't visually distinguish a link from body text. This kills click-through, especially in marketing copy where the link IS the conversion path.
  Evidence required: anchor styling + missing underline / weight / icon.
- **Charts use color-only series differentiation**. Data viz becomes meaningless. For a B2B marketing surface where charts ARE the proof, this is a conversion-killer.
  Evidence required: chart config + series with no marker / pattern / direct label.
- **Diff / annotation views (red removed / green added) with no symbol**. Code samples, redline reviews, edit-tracking — all become unreadable.
  Evidence required: rendered diff + missing `+` / `-` / strikethrough / icon.

### NOT a Problem

- Decorative color (brand wordmark, hero gradients, illustrations) where color isn't conveying functional meaning.
- Color used **alongside** a redundant channel — e.g., a green check icon next to "Approved" text, or a red X icon next to "Failed" text. The icon + text pair carries the meaning; color reinforces.
- Underlined inline links with a color shift — the underline is the non-color signal.
- Charts with both color-coded series AND direct-label annotations or pattern fills.
- "Subtle" disabled states (intentionally low-saturation gray) where the disabled state is also signaled by `aria-disabled`, position out of tab order, and pointer-events disabled. The semantic signal is sufficient.

### Context Check

1. Run the surface through a deuteranopia / protanopia / tritanopia simulator (Chrome DevTools or Coblis). What becomes indistinguishable? Those are the findings.
2. For each color-encoded state: is the redundant channel an **icon**, **text label**, **asterisk**, **weight change**, **pattern**, **position**, or **direct annotation**? If none, it's a finding.
3. Is the surface a marketing page where color sells the brand, or a functional UI where color must carry meaning safely? Both must pass — Cat 113 evaluates the latter use of color, not the former.
4. Has the brand published a design-system token for state colors? If yes, the fix is a token-level addition (icon + text token), not a per-page patch — flag the system, not the symptom.

### Reference

WCAG 1.4.1 (Use of Color, Level A): https://www.w3.org/WAI/WCAG21/Understanding/use-of-color.html

Color Oracle (free desktop simulator): https://colororacle.org/

Coblis (online color-blindness simulator): https://www.color-blindness.com/coblis-color-blindness-simulator/

Chrome DevTools vision-deficiency emulation: chrome://devtools → Rendering panel → "Emulate vision deficiencies"

Color Universal Design (Okabe & Ito 2008, the canonical 8-color CVD-safe palette): https://jfly.uni-koeln.de/color/

ISO 9241-112 (Principles for the presentation of information): https://www.iso.org/standard/64840.html

**Severity tagging:**
- Form error states with color-only signal → Critical (blocks conversion).
- Required-field indicator with color-only signal → Critical (blocks form completion for CVD users).
- Inline links with color-only signal in marketing copy → High (kills click-through).
- Status pills / badges with color-only signal → High.
- Charts / data viz with color-only series differentiation → High (when charts carry the argument); Medium otherwise.
- Diff / annotation views with color-only red/green → Medium.
- Calendar / map / heat-map UIs with color-only encoding → Medium.

**Fix voice:** `don-norman` (primary) | `aarron-walter` (backup).

Read `souls/don-norman.json` before writing the Fix. The Norman principle is **redundancy of perceptual channels**: never let one channel of perception carry the entire signal, because that channel will fail for some user, in some condition, at some point. Color is one channel; redundancy is the discipline.

**Brand-impact note:** the fix for Cat 113 is **adding a redundant channel** (icon, text, pattern, weight, position) — *not* changing the color itself. Don't propose palette rewrites. The brand's red can stay red; what must change is that "red" alone is no longer the entire message. This is critical: a Cat 113 fix should never rewrite the user's color tokens. If the only proposed fix is "swap your reds for a CVD-safe red," you've misunderstood the category. Surface the proposal, quote the file:line, describe the redundant channel being added, and let the user approve per finding.

Worked fix example:

> Color is a perceptual channel, and like every perceptual channel, it fails for some users in some conditions. Eight percent of men can't reliably distinguish red from green; everyone is color-blind in the dark, in glare, on a bad monitor, with a screen-protector tint. The fix is not to abandon color — color is fast, brand-aligned, and powerful. The fix is to **add a second channel** so the meaning survives when the first one fails.
>
> Walk the surface. Find every place where color carries meaning alone. Add a redundant signal — an icon, a text label, an asterisk, a position, a pattern, a weight change. Keep the color. The color is the brand. The icon, the text, the asterisk — those are the safety net.
>
> ```html
> <!-- Bad: red border, no icon, no text. CVD user sees a normal field. -->
> <div class="form-field error">
>   <label>Email</label>
>   <input type="email" value="not-an-email">
> </div>
>
> <!-- Good: red border + icon + text. Color reinforces; meaning survives without it. -->
> <div class="form-field error">
>   <label>Email <span class="required-marker">*</span></label>
>   <input type="email" value="not-an-email" aria-invalid="true" aria-describedby="email-err">
>   <span id="email-err" class="error-message">
>     <svg aria-hidden="true">…</svg> Please enter a valid email address.
>   </span>
> </div>
> ```
>
> ```css
> /* Status pills: keep your brand colors; add the icon and the text. */
> .pill { padding: 4px 10px; border-radius: 999px; display: inline-flex; gap: 6px; }
> .pill-success::before { content: "✓ "; }   /* icon — the redundant channel */
> .pill-failed::before  { content: "✕ "; }
> .pill-pending::before { content: "⏱ "; }
> /* The background color stays exactly as the brand defined it. */
> ```
>
> Don't rewrite the palette. Add the second channel. The brand's red is still the brand's red — you've just made it possible to receive the message even if the user can't see the red.
