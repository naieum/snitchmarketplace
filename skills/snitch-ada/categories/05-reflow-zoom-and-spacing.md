## CATEGORY 05: Resize, reflow, text spacing and hover content

People change the page to read it. They zoom to 200%, they run a browser at a narrow width, they
apply their own line-height and letter-spacing through a reading extension or a user stylesheet.
Each is a supported way to use the web, and each breaks layouts built for one fixed size. This
category judges what survives that change, against **1.4.4 Resize Text (AA)**, **1.4.10 Reflow
(AA)**, **1.4.12 Text Spacing (AA)** and **1.4.13 Content on Hover or Focus (AA)**.

The static pass here is narrow and honest. Source and CSS show the *conditions* that produce a
reflow or clipping failure: a suppressed zoom, a fixed width, a fixed-height text container, a
`!important` on a spacing property, a tooltip bound to `:hover` alone. They do not show the rendered
result, so most rows produce a static finding plus a runtime confirmation, or a Skip. Say which.

**Boundary.** This category asks whether the content survives the user's own resizing. The viewport
meta tag has a second judge: when `user-scalable=no` is weighed as a **mobile-friendliness and
search signal**, call the Skill tool with "snitch-marketing". When the question is whether a
clipped price table **stops one person from choosing a plan** on their decision path,
call the Skill tool with "snitch-ux". Report the criterion here and cross-file the rest.

### Pre-flight

Always run on any responsive surface with rendered text.

1. **The conversion path.** Which pages a person must get through to do the thing the site exists
   for. Reflow failures there outrank failures on an archive page.
2. **The breakpoint set.** The declared breakpoints, and whether any layout region stops adapting
   below the narrowest. 1.4.10 is measured at a width equivalent to 320 CSS px.
3. **Declared intent.** Read `BLUEPRINT.md` and `marketing/positioning.md` read-only. A `Decision`
   does not excuse a criterion failure; it caps a contradicting best-practice fix at Medium.
   Neither file present is a Skip with that reason.

Skip with reason `no responsive surface in scope` when there is no rendered layout to resize.

### Rule table

One row per success criterion. A finding names its row. A check with no row here is a Skip.

| SC | Level | What must hold | Static signal (source / DOM) | Runtime-only? | Severity |
|---|---|---|---|---|---|
| 1.4.4 Resize Text | AA | Text resizes to 200% with no loss of content or functionality, without assistive technology | `user-scalable=no` or `maximum-scale=1` in the viewport meta; text containers with a fixed `height` and `overflow: hidden`; text areas sized in `vw` alone | partial | High (zoom suppressed) / Medium (clipping) |
| 1.4.10 Reflow | AA | Content presents without scrolling in two dimensions at a width equivalent to **320 CSS px** (or a height of 256 CSS px for horizontally scrolling content), except for parts that require two-dimensional layout | fixed `width` or `min-width` above 320px on a container in the main flow; `white-space: nowrap` on a wide block; a grid with fixed tracks summing past 320px and no narrow breakpoint; horizontal scroll on the body | partial | High (conversion path) / Medium (elsewhere) |
| 1.4.12 Text Spacing | AA | Content survives user-set line-height 1.5×, paragraph spacing 2×, letter spacing 0.12em and word spacing 0.16em | fixed-height text containers; `overflow: hidden` on a text block; `line-height` or `letter-spacing` with `!important`; buttons and pills with a fixed `height` holding a text label | partial | Medium |
| 1.4.13 Content on Hover or Focus | AA | Additional content triggered by hover or focus is **dismissible**, **hoverable** and **persistent** | tooltip or popover shown from `:hover` alone with no `:focus-visible` path; a JavaScript tooltip with no Escape handler; content that hides on `mouseout` of the trigger with no bridge to the popup; a timed auto-hide | partial | Medium |

**`px` font sizes are not a failure.** Browsers zoom `px` text like any other unit, and 1.4.4 is
about scaling to 200%, not about the unit the author chose. Never report a `px` `font-size` as a
1.4.4 failure. What fails 1.4.4 is *suppressed zoom* and *content lost when zoom is applied*.

**Two-dimensional content is exempt from 1.4.10.** Data tables, charts, maps, diagrams, code blocks
and interfaces whose meaning depends on a two-axis layout are named in the criterion's own
exception. A table that scrolls horizontally inside its own container is not a reflow failure; a
page body that scrolls horizontally is.

**Readability advisories carry no criterion.** Body text under 16px on mobile, `line-height` under
1.4 on paragraphs, and reading columns beyond roughly 80 characters are worth reporting and are
**not** WCAG failures. Report them as `readability (advisory)`, severity **Low**, with the CSS rule
quoted and no SC number. Never write them as 1.4.4, 1.4.12 or anything else.

**`title`-attribute tooltips are not a 1.4.13 failure.** The browser renders and dismisses them, so
the author has not created the hover behavior. They are a poor way to convey information, and that
is an advisory note, not a criterion finding.

### Evidence required

A finding needs an observation and a criterion. The observation is the quoted declaration at
`file:line` (source mode) or URL + selector (crawl mode).

**Source mode, cheapest first:**

1. `Grep` for `name="viewport"` and read the `content` value. `user-scalable=no` and
   `maximum-scale=1` (or any maximum-scale below 2) are the 1.4.4 static signal.
2. `Grep` for `width:\s*\d{3,}px`, `min-width:\s*\d{3,}px` and fixed `flex-basis` on containers in
   the main flow; anything above 320px that does not shrink is the 1.4.10 signal. `Grep` for
   `overflow-x:` and `white-space:\s*nowrap` too, reading what each applies to: a table wrapper is
   expected, a paragraph is not.
3. `Grep` for `height:` with `overflow:\s*hidden` on elements holding text, for fixed `height` on
   buttons, pills, chips, nav items and cells with text labels, for `line-height` and
   `letter-spacing` carrying `!important`, and for `-webkit-line-clamp` on essential text (1.4.12).
4. `Grep` the CSS for `:hover` rules that reveal content (`display: block`, `visibility: visible`,
   `opacity: 1`) and check whether a `:focus`, `:focus-visible` or `:focus-within` rule does too.
5. `Grep` tooltip and popover components for `mouseenter` / `mouseleave` handlers, an Escape
   handler, whether the popup sits inside the hover region, and any `setTimeout` auto-hide.
6. Read the breakpoint list and confirm the narrowest reaches 320px. Record body `font-size`,
   paragraph `line-height` and prose `max-width` for the advisories.

**Crawl mode:** `Fetch` each page, quote the viewport meta and the layout CSS for the main flow, and
record URL + selector for each fixed-width container and hover-revealed component.

**Cascade caveat (every CSS-derived check):** a `Grep` or `Fetch` returns declarations, not the
resolved cascade. A fixed width may be overridden in a media query, a `max-width: 100%` may already
neutralise it, and a `height` may be a minimum in practice. Say so when the cascade is ambiguous,
and confirm the rendered layout before asserting a failure.

**Runtime checks (need a human or a runner; the bundle ships neither):**

1. **Zoom to 200%** at a 1280px window and look for lost content, clipped text, overlapping blocks
   and controls that stop working. **Reflow at 320 CSS px** (or a 1280px window zoomed to 400%) and
   look for two-dimensional scrolling on the page body.
2. **Apply the 1.4.12 spacing values** through a user stylesheet or extension: line-height 1.5×,
   paragraph spacing 2×, letter spacing 0.12em, word spacing 0.16em. Look for clipping and overlap.
3. **Hover and focus each tooltip**: dismissible without moving the pointer, hoverable, persistent.

With no runner or human, write `Skip — zoom, reflow and text-spacing confirmation requires a human
or runner; not run`, and report only the static conditions. Never assert unobserved behavior.

### Forbidden claims

- "The layout probably breaks on mobile." Quote the fixed width, or Skip.
- "Text is too small." That is the readability advisory, and it carries no criterion.
- "Zoom is broken." Quote the viewport `content`, or the observed loss at 200%.
- "Content is clipped at 320px." Only a render shows that. Report the fixed width as the condition,
  and mark the confirmation a Skip when nobody looked.
- Never write **compliant**, **conformant** or **non-compliant** as a verdict. Write "fails SC
  1.4.10 at this container" and let the reader draw the line.
- A `px` `font-size` reported as a 1.4.4 failure. Browsers zoom it.
- A 1.4.10 finding on a data table, chart or map that scrolls inside its own container, or a 1.4.13
  finding on a `title`-attribute tooltip. Both are exempt.
- Any criterion number attached to the 16px floor, the line-height advisory or the column-width
  advisory.

### Detection

Static read of the viewport meta, layout CSS, text containers, spacing declarations and hover
components, in source or crawl mode, plus a human or runner confirmation at 200% zoom, at 320 CSS px
and under the 1.4.12 spacing values. Every row produces a condition plus a confirmation, or a
condition plus an honest Skip.

### What to Search For

- `name="viewport"` and its `content`: `user-scalable=no`, `maximum-scale` below 2
- Fixed `width`, `min-width`, `flex-basis` or grid tracks above 320px in the main flow
- `overflow-x` on the body or a main region; `white-space: nowrap` on body copy; `height` with
  `overflow: hidden` on anything holding text; fixed-height buttons, pills, chips and cells
- `!important` on `line-height` or `letter-spacing`; `-webkit-line-clamp` on essential text;
  `:hover` rules revealing content with no matching focus rule
- Tooltip components: pointer handlers, Escape handling, hover bridge, auto-hide timers; the
  narrowest declared breakpoint; body `font-size`, `line-height` and prose `max-width` (advisory)

### Actually Fails

- **Viewport meta suppressing zoom** with `user-scalable=no` or a `maximum-scale` below 2.
  Evidence: the meta tag's `content` value. 1.4.4, High.
- **Text container with a fixed height and `overflow: hidden`**, confirmed to clip at 200% zoom.
  Evidence: the rule plus the observation. 1.4.4, Medium.
- **Fixed width above 320px in the main flow with no narrow breakpoint**, producing two-dimensional
  scrolling, or **body-level horizontal scroll at 320 CSS px**. Evidence: the rule and the
  observation. 1.4.10, High on the conversion path, Medium elsewhere.
- **`white-space: nowrap` on body copy or a long label.** Evidence: the rule and its target.
  1.4.10, Medium.
- **Text clipped or overlapped under the 1.4.12 spacing values**, confirmed by a render, or
  **`line-height` / `letter-spacing` locked with `!important`**. Evidence: the rule plus the
  observation, or the declaration. 1.4.12, Medium.
- **Tooltip revealed on `:hover` with no focus path.** Evidence: the CSS or handler, and the absent
  focus rule. 1.4.13, Medium. A control unreachable by keyboard at all is 2.1.1, Cat 06.
- **Hover content with no dismiss mechanism, that vanishes when the pointer moves toward it, or that
  auto-hides on a timer.** Evidence: the component, the `mouseleave` handler and the gap to the
  popup, or the `setTimeout` call. 1.4.13, Medium.
- **Body text under 16px on mobile, `line-height` under 1.4, or a prose column past roughly 80
  characters.** Evidence: the CSS rule. `readability (advisory)`, Low, no SC number.

### NOT a Failure

- `font-size` declared in `px`. Browsers zoom it, and 1.4.4 is about scaling, not units.
- A data table, chart, map, diagram or code block scrolling horizontally inside its own container,
  and the `overflow-x: auto` wrapper that makes it do so. Exempt from 1.4.10.
- A fixed width neutralised by `max-width: 100%` or overridden in a narrow media query; a fixed
  height on a decorative element or a container with no text; `-webkit-line-clamp` on a preview
  snippet whose full text is one link away.
- `viewport-fit=cover` or `user-scalable=yes` in the viewport meta, and a `title`-attribute
  tooltip, which is user-agent behavior rather than author-created hover content.
- A tooltip that opens on focus too, stays until Escape or blur, and lets the pointer travel onto
  it, and one that closes when its trigger is no longer valid. The 1.4.13 pattern, not a violation.

### Context Check

1. Is the failing container on the conversion path? That decides High against Medium under 1.4.10.
2. Does the content genuinely need two dimensions? Tables and maps are exempt; a marketing section
   in a wide grid is not.
3. Did anyone zoom, narrow or re-space the page? If not, the condition is reported and the
   confirmation is a Skip, stated as two outcomes.
4. Is the tooltip carrying information that exists nowhere else? Then the failure also removes
   content, and the severity argument is stronger.
5. Is this a readability advisory or a criterion failure? The 16px floor, the line-height floor and
   the column width are advisories with no SC number, always.

### Severity

- **Critical** — reserved here for a reflow or zoom failure that removes a Level A function
  outright, such as a checkout control unreachable at 320 CSS px. Rare, and it needs the
  observation, not the condition.
- **High** — zoom suppressed in the viewport meta (1.4.4); two-dimensional scrolling on the body or
  on a conversion-path container at 320 CSS px (1.4.10).
- **Medium** — text clipped at 200% zoom; reflow failure off the conversion path; `white-space:
  nowrap` on body copy; text-spacing clipping and locked spacing (1.4.12); every 1.4.13 failure.
- **Low** — readability advisories: body text under 16px on mobile, paragraph `line-height` under
  1.4, prose columns past roughly 80 characters, and `title` tooltips carrying real information.
  Reported as `readability (advisory)` with no SC number.

### Fix guidance

**1. Let the page zoom.**

```html
<!-- Fails 1.4.4: the user is not allowed to scale -->
<meta name="viewport" content="width=device-width, initial-scale=1,
      maximum-scale=1, user-scalable=no">
<!-- Passes: one line, every page, no exceptions -->
<meta name="viewport" content="width=device-width, initial-scale=1">
```

**2. Size containers by their content, not by a number.**

```css
/* Fails 1.4.10: 960px does not fit in 320px, so the body scrolls sideways */
.pricing-grid { width: 960px; grid-template-columns: 320px 320px 320px; }
/* Passes: the track count follows the space available */
.pricing-grid {
  width: 100%; display: grid; gap: 1rem;
  grid-template-columns: repeat(auto-fit, minmax(min(280px, 100%), 1fr));
}
.table-wrap { overflow-x: auto; }   /* the exemption, used correctly */
```

**3. Let text breathe, and let hover content behave.**

```css
/* Fails 1.4.12: the label clips as soon as the user adds spacing */
.chip { height: 32px; overflow: hidden; line-height: 1.2 !important; }
/* Passes: the box grows with its text */
.chip { min-height: 32px; padding: 6px 12px; line-height: 1.5; }

/* Fails 1.4.13: pointer only, and it vanishes on the way to the popup */
.tip:hover .tip-content { display: block; }
/* Passes: keyboard reaches it, and no dead gap to cross */
.tip:hover .tip-content, .tip:focus-within .tip-content { display: block; }
.tip-content { margin-top: 0; padding-top: 8px; }
```

```js
tip.addEventListener('keydown', (e) => {   // dismissible without moving the
  if (e.key === 'Escape') hideTip();       // pointer or the focus
});
```

The rule under all three: the layout is the browser's job, and the reader's settings are the
reader's business. Fixed sizes take both away. Nothing here touches a color value or a brand token.
Report first; apply nothing unconfirmed.

### Reference

WCAG 2.2, SC 1.4.4 Resize Text, Level AA: https://www.w3.org/TR/WCAG22/#resize-text ·
SC 1.4.10 Reflow, Level AA: https://www.w3.org/TR/WCAG22/#reflow · SC 1.4.12 Text Spacing, Level AA:
https://www.w3.org/TR/WCAG22/#text-spacing · SC 1.4.13 Content on Hover or Focus, Level AA:
https://www.w3.org/TR/WCAG22/#content-on-hover-or-focus

Understanding 1.4.10: https://www.w3.org/WAI/WCAG22/Understanding/reflow.html · 1.4.12:
https://www.w3.org/WAI/WCAG22/Understanding/text-spacing.html · 1.4.13:
https://www.w3.org/WAI/WCAG22/Understanding/content-on-hover-or-focus.html · MDN, the viewport meta
tag: https://developer.mozilla.org/en-US/docs/Web/HTML/Guides/Viewport_meta_element · MDN CSS
`min()`: https://developer.mozilla.org/en-US/docs/Web/CSS/min
