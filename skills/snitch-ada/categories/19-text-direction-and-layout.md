## CATEGORY 19: Bidi and RTL, logical properties, text expansion, script-aware typography

A layout built and tested in one language quietly encodes that language's assumptions: that text
starts on the left, that a back arrow points left, that a button is wide enough because the
English word inside it is short, and that every glyph the product will render fits the line box
and the font file it shipped. None of that survives contact with Arabic, Hebrew, Thai, Devanagari,
Japanese or German. The failures are visual and total: an interface that was never mirrored, a
truncated label with no way to read the rest, a name rendered as disconnected letters, diacritics
clipped by the line above.

This category judges whether the layout and typography tolerate a direction and a script other
than the one they were built in. The Unicode Bidirectional Algorithm (UAX #9) already reorders
mixed-direction runs, and its clause HL1 lets a higher-level protocol such as HTML's `dir`
attribute set the paragraph direction explicitly. CSS logical properties already express "the
start edge" instead of "the left edge". The finding is almost always that the code named a
physical side, a fixed width, or a Latin-only font where a flow-relative or script-aware value
belonged.

**Boundary.** This category judges whether the layout survives another direction and script.
Whether the visual hierarchy works and whether a person can finish a task on it is a different
judge: call the Skill tool with "snitch-ux". How the fonts load and what they cost in Core Web
Vitals is a third: call the Skill tool with "snitch-marketing". A font stack is a finding here
when it cannot render a served script, and a finding there when it blocks the render.

### Pre-flight

Run in full when the surface serves or declares an RTL locale (Arabic, Hebrew, Persian, Urdu) or a
non-Latin script (Thai, Devanagari, CJK, Cyrillic, Greek). Establish that from the discovery i18n
inventory: the locale list, the route prefixes, the catalog filenames. Otherwise:

- A recorded `Decision` such as "English-only at launch" or "Latin-script markets only" makes this
  category a **Skip** citing that line. Not a Finding.
- No RTL or non-Latin locale served and no recorded Decision either way: run at **readiness
  severity**. Every finding caps at **Low**, worded as "this will break on the first RTL or
  non-Latin locale", and the physical-property sweep reports a **count with three quoted
  examples**, never one finding per instance.
- Neither declared-intent file present is a **Skip** with that reason.

Text expansion is the one row that runs on any multi-locale surface, RTL or not, because the
source language is usually the shortest one.

### Rule table

| Pattern | What must hold | Static signal | Severity |
|---|---|---|---|
| `<html>` with no `dir`, or `dir="ltr"` hardcoded, on a surface serving an RTL locale | `dir` is derived from the resolved locale and emits `rtl` for RTL locales | The `<html` tag in the root layout or document template with no `dir` or a literal `ltr` | High |
| User-generated text rendered or edited with no direction isolation | Fields and displays carrying content of unknown direction use `dir="auto"`, and inline runs use `<bdi>` | A comment, username, review or search field with no `dir` attribute; the same value interpolated inline with no `<bdi>` | High |
| Physical inline CSS properties used for layout on an RTL-serving surface (`margin-left`, `padding-right`, `left:`, `right:`, `text-align: left`, `float: left`, `border-left`) | Layout uses flow-relative properties (`margin-inline-start`, `inset-inline-start`, `text-align: start`, `border-inline-start`) so it mirrors with `direction` | The declaration in a stylesheet or a utility class name; report a **count plus quoted examples**, not one finding per hit | High |
| Directional icons not mirrored (arrows, chevrons, back and next, progress, sliders, carets) | Direction-carrying icons flip under `[dir="rtl"]`, by a rule or `transform: scaleX(-1)` | An arrow or chevron asset or glyph with no `[dir="rtl"]` rule anywhere in the stylesheet | High |
| Mixed-direction inline content with no isolation (a name, product code, URL or number inside RTL text) | Embedded opposite-direction runs sit in `<bdi>` or carry `unicode-bidi: isolate` | An interpolation inside a translated sentence with no isolating element | Medium |
| Fixed-width buttons, nav items, table columns or cards sized for the source string | Containers size to content and reflow; width constraints are minimums, not fixed values | `width:` with a px value on an interactive or label container; a grid template with fixed track widths | Medium |
| `white-space: nowrap` on a label, or `text-overflow: ellipsis` on a call to action | Labels wrap; truncation never applies to text a reader must read to act | The declaration on a class used by buttons, nav or CTAs | Medium |
| `max-width` or a fixed height on a heading, tuned to the source language | Headings wrap to more lines without clipping; heights are minimums | `height:` with a px value, or `max-width` in `ch`/`em` tuned to the source string, on a heading class | Medium |
| `text-transform: uppercase` on user-facing text | Casing is a translator's decision, not a stylesheet's; uppercase changes meaning in some scripts and does nothing in others | The declaration on a class used for labels, buttons or headings | Low (advisory) |
| `letter-spacing` applied to text that may be Arabic script | Cursive scripts keep their letters joined; letter-spacing is scoped away from those locales | A `letter-spacing` declaration on a global, body or heading selector on an Arabic-serving surface | High |
| `line-height` too tight for stacked diacritics (Thai, Devanagari, Arabic, Vietnamese) | Line height is unitless and leaves room for the tallest served script; the box does not clip | `line-height: 1` or a px line-height smaller than the font size on a text class | Medium |
| No `word-break` or `overflow-wrap` policy for CJK and long-compound languages | Long unbroken words wrap instead of overflowing; CJK breaks where the script allows | A text container with no `overflow-wrap` / `word-break`, plus `overflow: hidden` or a fixed width | Medium |
| Font stack with no fallback covering a served script | Every served script has a declared family that can render it, or a system fallback is reachable | A `font-family` ending in a Latin family with no generic fallback, on a surface serving a non-Latin script | High |
| Self-hosted webfont subsetted to Latin only | `unicode-range` covers the served scripts, or a second `@font-face` covers them | `unicode-range` declarations that stop at the Latin blocks; a single subset file for a multi-script surface | High |
| Vertical writing mode unavailable where the audience expects it | Vertical text is at least reachable for the locales that use it | No `writing-mode` handling on a surface serving Japanese or Traditional Chinese long-form text | Low (advisory) |

### Evidence required

**Source mode, cheapest first:**

1. Read the root layout or document template and quote the `<html>` tag. Record whether `dir` is
   present, hardcoded, or derived from the resolved locale.
2. `Grep` the stylesheets and utility class usage for physical properties: `margin-left`,
   `margin-right`, `padding-left`, `padding-right`, `border-left`, `border-right`,
   `text-align:\s*(left|right)`, `float:\s*(left|right)`, and bare `left:` / `right:` under
   `position`. **Count the hits, then quote three with `file:line`.** A hundred separate findings
   is noise; one finding carrying a count and three quotes is evidence.
3. `Grep` for `[dir="rtl"]`, `:dir(`, `scaleX(-1)`, `margin-inline`, `inset-inline`,
   `text-align:\s*(start|end)`. Their presence is the pass evidence for the mirroring rows; total
   absence on an RTL-serving surface is the finding.
4. `Grep` the typography classes for `letter-spacing`, `text-transform`, `line-height`,
   `white-space:\s*nowrap`, `text-overflow`, `word-break`, `overflow-wrap`.
5. `Grep` `font-family` and `@font-face`, and read every `unicode-range`. Compare the covered
   ranges against the scripts the served locales need.
6. `Grep` fixed dimensions on interactive and label containers: `width:\s*\d+px`,
   `height:\s*\d+px`, `max-width` on heading classes.
7. `Grep` the components that render user-supplied text (comment, review, username, search,
   profile) for `dir=` and `<bdi`.

**Crawl mode, cheapest first:**

1. Fetch one page per served locale, including an RTL one, and quote the `<html>` tag from each.
2. Quote the computed direction-sensitive declarations you can see in the served stylesheets, with
   the URL of the stylesheet and the selector.
3. Where a fixed-width container holds a longer translated string, quote the rule, the string and
   the URL. Visual overflow is not observable from a fetch: record
   `Skip — visual overflow requires a rendering runner; not run` and report the static signal only.

**Cascade caveat, applies to every CSS-derived check here:** a fetch and a source read return
declarations, not the resolved cascade. A later rule, a media query, a logical-property polyfill,
or an RTL-specific stylesheet may override what you quoted. Say so in the finding when the
resolution is ambiguous, and verify the rendered value before asserting a failure.

### Forbidden claims

- "The RTL layout is broken." You have not seen it render. Quote the physical declarations, the
  missing `dir`, and the absence of any `[dir="rtl"]` rule, and say what those mean.
- "This text will overflow." Say the container is fixed at a quoted width and that translated
  strings commonly run longer, and route the visual confirmation to a runner or a human.
- "German is 35% longer." Quote a hedged range from a published source and say it is a general
  tendency, not a measurement of this string. Expansion varies by string, by domain and by length.
- Never "compliant", "conformant" or "non-compliant" as a verdict.
- "The font does not support Arabic." Unless you read the font's coverage, say the stack declares
  no family known to cover the script and no generic fallback, and quote the stack.
- One finding per physical property. A stylesheet with 400 `margin-left` declarations is one
  finding with a count and three quotes.
- Any WCAG success criterion number. Reflow and text spacing under WCAG are Category 05's.

### Detection

Static read of the document `dir`, a counted sweep of physical versus logical CSS properties, a
presence check for RTL mirroring rules, a typography sweep against the served scripts, and a font
coverage read against `unicode-range`. Anything that must be seen rendered Skips with its reason.

### What to Search For

- `<html` with no `dir=`, or `dir="ltr"` as a literal
- `margin-left`, `margin-right`, `padding-left`, `padding-right`, `border-left`, `border-right`,
  `text-align: left`, `text-align: right`, `float: left`, `float: right`, `left:`, `right:`
- The pass shapes: `margin-inline-start`, `padding-inline-end`, `inset-inline-start`,
  `border-inline-start`, `text-align: start`, `[dir="rtl"]`, `:dir(rtl)`, `scaleX(-1)`
- `dir="auto"`, `<bdi`, `unicode-bidi`, and their absence on user-generated text
- `white-space: nowrap`, `text-overflow: ellipsis`, `width: \d+px`, `height: \d+px` on labels,
  buttons, nav items and headings
- `text-transform: uppercase`, `letter-spacing`, `line-height: 1`, `word-break`, `overflow-wrap`
- `@font-face`, `unicode-range`, `font-family` stacks with no generic fallback, and arrow assets:
  `arrow`, `chevron`, `caret`, `back`, `next`, `prev`

### Actually Fails

- **An RTL locale served with no `dir` on `<html>`.** The whole page renders left-to-right, so the
  reading order, the alignment and the punctuation placement are wrong at once. Evidence: the
  `<html>` tag quoted, plus the RTL locale in the served list.
- **Physical properties throughout the layout with no `[dir="rtl"]` rules anywhere.** The mirror
  was never built, so an RTL reader gets an LTR interface with RTL text in it. Evidence: the count
  of physical declarations, three quoted with `file:line`, and the grep for mirroring rules
  returning nothing.
- **Directional icons that never flip.** A back arrow pointing left in an RTL interface points
  forward. Evidence: the icon asset or glyph plus the absent `[dir="rtl"]` or `scaleX(-1)` rule.
- **`letter-spacing` on a global selector on an Arabic-serving surface.** Arabic letters are
  expected to stay joined, and spacing them breaks the word visually. Evidence: the declaration at
  `file:line` and the Arabic locale in the served list.
- **A font stack that cannot render a served script.** The browser falls back to whatever it has,
  so the page renders in a different face or in tofu. Evidence: the stack, the `unicode-range`
  coverage, and the script the served locale needs.
- **Truncation on text a reader must read to act.** `text-overflow: ellipsis` on a CTA hides the
  end of the sentence in exactly the languages that need more room. Evidence: the declaration and
  the class's usage.

### NOT a Failure

- Physical properties on a surface with no RTL locale served and a recorded single-language
  `Decision`. That is the Skip case, not a finding.
- Physical properties where the physical side is the point: a drop shadow, an icon nudge inside a
  fixed square, a decorative border on a non-mirroring element, a canvas or chart coordinate.
- `dir="ltr"` scoped to content that is always LTR: a code block, an IBAN, a machine identifier.
- A fixed width on something that is not text: an avatar, a logo lockup, a media thumbnail.
- `text-transform: uppercase` or `letter-spacing` scoped away from the locales they harm, where
  the scoping is visible in the stylesheet, or applied to a wordmark.
- A Latin-only font subset on a surface serving Latin-only locales, coverage matching the list.
- `white-space: nowrap` on a value that must not wrap and is not a sentence: a numeric table cell,
  a timestamp, a keyboard shortcut.

### Context Check

1. Which locales and scripts are actually served? Every row in this category is scoped to that
   list, and a finding that names a script nobody is served is noise.
2. Is there any RTL support at all? A stylesheet with `[dir="rtl"]` blocks means the mirror exists
   and the physical properties may be deliberate exceptions; check before you count.
3. Does the framework or design system emit logical properties, or transform physical ones at
   build time? Trace it once and record the pass with the trace as evidence.
4. Is the container fixed because of the text, or because of something else in it, and is the
   truncated string a label a reader must read or a preview with a full view elsewhere?
5. Is there a recorded `Decision` fixing the layout to one direction? If so the finding caps at
   Medium with the Fix "revisit the decision or accept the trade-off".

### Severity

One tier per failure shape. `Critical` is not used in this category; it is reserved for Level A
accessibility failures that block a task.

- **High** — missing or hardcoded `dir` on an RTL-serving surface, an unbuilt mirror (physical
  properties plus no `[dir="rtl"]` rules), unmirrored directional icons, `letter-spacing` on
  Arabic script, a font stack or subset that cannot render a served script, unisolated
  user-generated text.
- **Medium** — fixed widths and heights on text containers, `nowrap` and truncation on labels,
  tight line-height for stacked-diacritic scripts, missing wrap policy for CJK and long compounds,
  unisolated mixed-direction inline runs. Also the cap for a finding contradicting a `Decision`.
- **Low** — `text-transform: uppercase`, vertical-text gaps, and every finding on a surface with
  no RTL or non-Latin locale and no declared intent (the readiness case).

### Fix guidance

Name the edge, not the side. Every physical property in a layout is a claim that the text starts
on the left, and that claim is what breaks.

```css
/* Before: the layout, the alignment and the icon all assume left-to-right. */
.card        { margin-left: 16px; padding-right: 24px; border-left: 3px solid; }
.card__title { text-align: left; white-space: nowrap; width: 240px; letter-spacing: .04em; }
.card__more::after { content: "→"; }

/* After: flow-relative edges, content-driven width, spacing scoped off cursive scripts. */
.card        { margin-inline-start: 16px; padding-inline-end: 24px;
               border-inline-start: 3px solid; }
.card__title { text-align: start; min-width: 240px; overflow-wrap: anywhere; line-height: 1.5; }
:where(:lang(ar), :lang(fa), :lang(ur)) .card__title { letter-spacing: normal; }
.card__more::after             { content: "→"; display: inline-block; }
[dir="rtl"] .card__more::after { transform: scaleX(-1); }
```

```html
<!-- Before: direction fixed to the build language; a name of unknown direction inline. -->
<html lang="en" dir="ltr">
<p>Reviewed by {{ author }} on {{ date }}</p>

<!-- After: direction derived from the locale; the unknown run isolated. -->
<html lang="{{ locale }}" dir="{{ textDirection }}">
<p>Reviewed by <bdi>{{ author }}</bdi> on {{ date }}</p>
```

Four rules make this hold. **`dir` comes from the locale**, resolved where `lang` is resolved and
never written as a literal. **Logical properties are the default** and a physical one is the
exception that needs a reason; a stylesheet lint rule keeps it that way. **Containers size to
content**: turn every `width` on a text container into `min-width` and let `overflow-wrap` handle
long compounds instead of `overflow: hidden`. **Fonts are declared per script**: give each served
script a `@font-face` whose `unicode-range` covers it, or a generic fallback the system can
satisfy, because a character outside every declared range falls through to the next family.

Budget for expansion rather than measuring it. Published guidance on translating from English
reports expansion inversely proportional to string length, with short strings of ten characters or
fewer commonly running two to three times their source length and long paragraphs settling nearer
thirty percent. Treat that as a hedged design constraint, not a number to quote at a specific
string, and test the layout with the longest string in the catalog. Do not change a brand font, a
type scale, or a color token as part of this fix; those need per-finding confirmation.

### Reference

- Unicode Standard Annex #9, Unicode Bidirectional Algorithm, including clause HL1 on a
  higher-level protocol setting the paragraph embedding level: https://www.unicode.org/reports/tr9/
- CSS Logical Properties and Values Module Level 1 (`margin-inline-start`, `inset-inline-start`,
  `border-inline-start`, and the flow-relative `start` / `end` values):
  https://www.w3.org/TR/css-logical-1/
- The `dir` global attribute, what `dir="auto"` resolves from, and when to prefer `<bdi>`:
  https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Global_attributes/dir
- `letter-spacing`, including the note that scripts such as Arabic expect connected letters and
  that spacing them can make the text look broken:
  https://developer.mozilla.org/en-US/docs/Web/CSS/letter-spacing
- `@font-face` `unicode-range`, including the rule that a character outside every declared range
  falls through to the next family:
  https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face/unicode-range
- W3C internationalization guidance on text size in translation, the source of the hedged
  expansion range above: https://www.w3.org/International/articles/article-text-size

Facts verified 2026-09-03 against unicode.org, w3.org and developer.mozilla.org.
