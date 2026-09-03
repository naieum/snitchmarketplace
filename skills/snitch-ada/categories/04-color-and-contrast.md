## CATEGORY 04: Use of color and contrast

Color does two jobs on a page, and each fails differently. It carries **meaning**: this row is an
error, this field is required, this pill is "failed", this line is the second series. And it carries
**legibility**: whether the text can be read at all. A person with low vision, a person with a
color-vision deficiency, and a person outdoors in sunlight each lose one of those jobs. This
category judges both against **1.4.1 Use of Color (A)**, **1.4.3 Contrast (Minimum) (AA)** and
**1.4.11 Non-text Contrast (AA)**.

The two failure classes are independent. A red error message at 6:1 passes 1.4.3 and still fails
1.4.1 if red is the only thing marking it as an error. A gray label with an icon beside it passes
1.4.1 and still fails 1.4.3 if the gray is too light. Report them separately, each under its own
criterion, with its own evidence.

**Boundary.** This category asks whether the ratio clears the threshold and whether meaning survives
without hue. When the judge is whether the pale CTA **loses one person on their decision path**, or
whether the visual hierarchy is doing its job, call the Skill tool with "snitch-ux". When the judge
is brand consistency or how the palette reads to a buyer,
call the Skill tool with "snitch-marketing". The ratio is here; the persuasion is there.

### Pre-flight

Always run on any surface with rendered text or interactive controls.

1. **The palette inventory.** Every color token, its value, and where each is used as foreground and
   as background. Token files, CSS custom properties and theme objects are the cheapest source.
2. **The theme set.** Light, dark, high-contrast and any brand sub-theme. A `prefers-color-scheme`
   pair is **two** sets of pairings, checked separately. Passing in light says nothing about dark.
3. **Declared intent.** Read `BLUEPRINT.md` and `marketing/positioning.md` read-only. A `Decision`
   such as a locked brand palette does not excuse a Level A failure; it caps a contradicting
   best-practice fix at Medium. Neither file present is a Skip with that reason.

Skip with reason `no rendered color pairs in scope` only when there is no color to read.

### Rule table

One row per success criterion. A finding names its row. A check with no row here is a Skip.

| SC | Level | What must hold | Static signal (source / DOM) | Runtime-only? | Severity |
|---|---|---|---|---|---|
| 1.4.1 Use of Color | A | Color is never the only visual means of conveying information, indicating an action, prompting a response or distinguishing an element | `.error` / `.required` / `.success` / status-pill classes that change only `color` or `background`; body links with `text-decoration: none` distinguished only by hue; chart series differentiated only by stroke color; validation borders that only change color; a required marker that is only a red label | no | Critical (form error or required marker) / High (links, status, charts) |
| 1.4.3 Contrast (Minimum) | AA | Text and images of text are at least **4.5:1**; large text (**≥24px**, or **≥18.66px bold**) is at least **3:1** | declared foreground / background pairs below threshold; placeholder colors; muted body copy; text over a photograph or gradient with no solid backing | partial | High |
| 1.4.11 Non-text Contrast | AA | User-interface components and meaningful graphics are at least **3:1** against adjacent colors | input and button borders below 3:1; icon-only controls whose glyph is below 3:1 against its background; focus indicators below 3:1 against adjacent colors; toggle and checkbox states separated by a sub-3:1 difference; chart marks and map keys carrying meaning below 3:1 | partial | High |

**Thresholds, stated once.** Normal text 4.5:1. Large text 3:1, where large means at least 24 CSS
px, or 18.66 CSS px when bold. Non-text components and meaningful graphics 3:1. There is no fourth
number in this category.

**Exemptions**, which produce no findings: disabled and inactive controls; logotypes and wordmarks;
incidental text (decoration, invisible text, or text inside a picture holding significant other
visual content); pure decoration under 1.4.11, including an aesthetic border where the component's
boundary is carried by something else; browser-default control rendering the author has not styled.

**The contrast script.** Compute, never estimate:

```
python3 "${CLAUDE_SKILL_DIR}/scripts/contrast.py" '#767676' '#ffffff'
```

It prints the ratio for the two colors. **A ratio is never asserted without both values it was
computed from.** If either value cannot be resolved, the row is a Skip, not a guessed ratio.

### Evidence required

A finding needs an observation and a criterion. The observation is the quoted declaration at
`file:line` (source mode) or URL + selector (crawl mode), plus, for contrast rows, the verification
table below.

**Source mode, cheapest first:**

1. `Grep` the token file, theme object and custom properties for every color value and its name.
2. `Grep` for `color:`, `background:`, `background-color:`, `border-color:`, `fill:`, `stroke:` and
   `outline-color:`. Pair each foreground with the background it actually renders on, tracing the
   containing element rather than assuming the page background.
3. Run the contrast script on every pair involving text or a meaningful graphic, and record the
   result in the verification table.
4. Read the font size and weight for each text pair **before** selecting a threshold. The 3:1
   large-text threshold applies only at ≥24px, or ≥18.66px bold.
5. `Grep` for `::placeholder` and its vendor-prefixed forms and compute those pairs too, since
   placeholder text is text. Then `Grep` for `@media (prefers-color-scheme: dark)` and any
   theme-class scope, and repeat steps 2 to 5 for every theme, reporting per theme.
6. `Grep` for state classes carrying meaning: `error`, `invalid`, `required`, `success`, `warning`,
   `active`, `selected`, `unread`, `status`, `pill`, `badge`, `tag`. For each, read whether anything
   other than color changes: an icon, a text string, an asterisk, weight, an underline, a pattern.
7. `Grep` for `text-decoration:\s*none` on content anchors and read what distinguishes those links
   from surrounding text; `Grep` chart and map configuration for series color arrays with no
   marker, dash, pattern or direct label.
8. `Grep` for `:focus-visible`, `:focus`, `outline` and focus `box-shadow`, and compute the
   indicator's contrast against **both** the component and the background it sits on (1.4.11).
9. `Grep` for text over `background-image`, `linear-gradient` or video. Not computable statically.

**Crawl mode:** `Fetch` each page, extract the style pairs in the served HTML and CSS, record URL +
selector per row of the verification table, and where the CSS resolves a variable chain, quote both
the resolved value and the chain.

**Contrast verification table (required evidence format).** Quote contrast findings as a table so
each ratio can be re-checked.

| Element (URL + selector) | Foreground | Background | Ratio | Required | Pass |
|---|---|---|---|---|---|
| Hero subhead `/#hero p.sub` | `#9aa0a6` | `#ffffff` | 2.6:1 | 4.5:1 | fail |
| Primary button `/.btn-primary` | `#ffffff` | `#c9a84c` | 2.1:1 | 4.5:1 | fail |

Never assert a ratio without the two colors it was computed from.

**Cascade caveat (every CSS-derived check):** a `Grep` or `Fetch` returns declarations, not the
resolved cascade. The rendered color can come from a later rule, an inherited variable, a
specificity win, a `filter`, an ancestor's `opacity`, or a runtime theme class. Say so when the
cascade is ambiguous, and verify the rendered value before asserting a failure. Where `opacity`
applies to text, the effective foreground is the blend; compute the blend or Skip.

**Runtime confirmations.** Text over a photograph, a gradient or a video; a ratio produced by a
runtime theme; and color-only meaning under a vision-deficiency simulation all need a render. With
no runner or human, write `Skip — rendered contrast over an image requires a human or runner; not
run`.

### Forbidden claims

- "Contrast may be insufficient." Compute the ratio and quote both hex values, or Skip.
- "The palette is inaccessible." Ratios are per pair, not per palette. Name the pairs, and never
  write "this looks like it fails": a ratio with no computation behind it is not evidence.
- "Color-blind users cannot use this." Name the element, the meaning it carries, and the missing
  redundant channel.
- Never write **compliant**, **conformant** or **non-compliant** as a verdict. Write "fails SC 1.4.3
  at these elements" and let the reader draw the line.
- A ratio asserted for text over a photograph or gradient. Report Medium with "verify the rendered
  value", or Skip.
- A 1.4.3 finding on a disabled control, a logotype or incidental text. All exempt.
- A 1.4.3 finding at the 3:1 large-text threshold without stating the size and weight that earned
  it, and any 1.4.1 finding where color is used alongside another channel.

### Detection

Static read of design tokens, stylesheets, theme objects, component styles and chart configuration,
in source or crawl mode, with every ratio computed by the bundled script. Text over images and
runtime themes need a render; Skip when none is available.

### What to Search For

- Design tokens, custom properties and theme objects, and every declaration using them: `color`,
  `background-color`, `border-color`, `fill`, `stroke`, `outline-color`
- `@media (prefers-color-scheme: dark)` blocks and theme-class scopes, each its own set
- `::placeholder` rules, focus styles and what they sit against, and font size and weight
- State classes: error, invalid, required, success, warning, active, selected, unread, badge, pill
- `text-decoration: none` on links in body copy; validation styling that only changes border color
- Chart, graph and map series colors with no marker, dash or direct label; text over
  `background-image`, `linear-gradient` or video; `opacity` or `filter` on text

### Actually Fails

- **Body text below 4.5:1, or large text below 3:1.** Evidence: the verification-table row with both
  values and the ratio, plus the size and weight that select the threshold. 1.4.3, High.
- **Placeholder text below 4.5:1.** Evidence: the rule and the row. 1.4.3, High.
- **Input or button border below 3:1 where that border is the component's boundary, or an icon-only
  control whose glyph is below 3:1 against its background.** Evidence: the row. 1.4.11, High.
- **Focus indicator below 3:1 against adjacent colors, or a toggle, checkbox or radio whose on and
  off states differ by less than 3:1.** Evidence: the rule, both colors, the ratio. 1.4.11, High. A
  suppressed indicator with no replacement is 2.4.7, Cat 06.
- **Form error signalled only by a color change.** Evidence: the error class and the absent icon,
  text message or `aria-describedby` link. 1.4.1, Critical.
- **Required field marked only by a red label or asterisk color.** Evidence: the markup and the
  style. 1.4.1, Critical.
- **Body links distinguished by hue alone**, with no underline, no weight change, and no 3:1
  difference against surrounding text plus a hover and focus cue. Evidence: the link and paragraph
  styles. 1.4.1, High.
- **Status pills separated only by hue, or chart series distinguished only by color.** Evidence: the
  pill set or series config, and the absent text, icon, marker or dash. 1.4.1, High.
- **Text over a photograph or gradient with no solid backing**, where the rendered ratio cannot be
  computed. Evidence: the rule and the backdrop. 1.4.3, Medium, as "verify the rendered value".
- **A dark-theme pair below threshold where the light-theme pair passes.** Evidence: the theme
  block and its own row. 1.4.3 or 1.4.11, severity as above.

### NOT a Failure

- Color used **alongside** a redundant channel: a check icon beside "Approved", an asterisk beside a
  required label, an underline on a link, a dashed line on a chart series.
- Low-contrast **disabled** states, logotypes, wordmarks and watermarks. Exempt.
- Decorative graphics and dividers under 1.4.11; a decorative border where the boundary is a fill
  that clears 3:1; a focus indicator that clears 3:1 but is thin, since thickness is not this
  criterion.
- Text at 24px and above, or 18.66px bold and above, at 3:1. The large-text threshold, not a
  concession. Placeholder text as a hint beside a real label also passes once it clears 4.5:1.
- A brand color that fails as text but passes as a heading or background color. Report the pair,
  not the token; likewise text on a scrim that clears the threshold.

### Context Check

1. Which theme is being audited? Every `prefers-color-scheme` pair is checked separately, and the
   finding names its theme.
2. Is the pair real? Trace the containing background rather than assuming the page background. A
   wrong background produces a wrong ratio and a wrong finding.
3. Is the text large? Size and weight decide the threshold, so read them before choosing.
4. Is the element exempt? Disabled, logotype, incidental, decorative. Check before computing.
5. Does the meaning survive in grayscale? That is the 1.4.1 test, separate from the ratio.
6. Does the fix touch a color value or a brand token? It needs **per-finding confirmation**, and a
   ratio asserted without both values is a defect in the report, not in the site.

### Severity

- **Critical** — meaning carried by color alone on a form error or required marker (1.4.1). A person
  who cannot see the hue does not know the form failed, and cannot complete it.
- **High** — body text below 4.5:1 and large text below 3:1 (1.4.3); component, glyph, state or
  focus indicator below 3:1 (1.4.11); color-only meaning on links, pills and chart series (1.4.1).
- **Medium** — text over an image or gradient whose rendered ratio could not be computed, reported
  as "verify the rendered value"; a near-miss pair where the cascade is ambiguous.
- **Low** — palette advisories with no criterion, such as a hover state that passes but drops
  contrast. Report as `color (advisory)` with no SC number.

### Fix guidance

Two fixes, and they are not the same fix.

**1. Fix the ratio.** Contrast is "can it be read". Change the value, keep the role. Compute every
replacement with the bundled script before proposing it.

```css
/* 1.4.3: #999 on #fff computes to 2.85:1, below the 4.5:1 floor */
.body-text { color: #999999; background: #ffffff; }
/* 1.4.3: #767676 on #fff computes to 4.54:1 and clears it */
.body-text { color: #767676; background: #ffffff; }

input::placeholder { color: #767676; }        /* placeholder text is text */
*:focus-visible { outline: 2px solid #1a5fb4; outline-offset: 2px; }  /* 1.4.11 */
```

**2. Add the second channel.** Color-only meaning is "does the meaning survive without the hue".
The palette stays the brand's; hue simply stops carrying the whole message.

```css
.pill-failed::before { content: "✕ "; }        /* 1.4.1: the pill was hue alone */
.pill-passed::before { content: "✓ "; }
.prose a { text-decoration: underline; text-underline-offset: 2px; }
```

```html
<!-- 1.4.1: the error was a red border and nothing else -->
<input id="email" aria-invalid="true" aria-describedby="email-err">
<p id="email-err"><span aria-hidden="true">⚠</span> Enter an email, like you@company.com.</p>
```

**Never propose a palette rewrite as the fix for 1.4.1.** The criterion asks for a redundant
channel, not a new brand. And because every fix here changes a color value or a brand token, each
carries **per-finding confirmation**: show the before, the after and the computed ratio, and get
explicit approval for that finding before anything is applied.

### Reference

WCAG 2.2, SC 1.4.1 Use of Color, Level A: https://www.w3.org/TR/WCAG22/#use-of-color ·
SC 1.4.3 Contrast (Minimum), Level AA: https://www.w3.org/TR/WCAG22/#contrast-minimum ·
SC 1.4.11 Non-text Contrast, Level AA: https://www.w3.org/TR/WCAG22/#non-text-contrast

Understanding 1.4.1: https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html ·
Understanding 1.4.3: https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html ·
Understanding 1.4.11: https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html

Contrast-ratio definition, the formula the bundled script implements:
https://www.w3.org/TR/WCAG22/#dfn-contrast-ratio · MDN `prefers-color-scheme`:
https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme · color-vision
simulation: the browser's own rendering panel ("Emulate vision deficiencies").
