## CATEGORY 47: Readable text without zoom

Mobile users shouldn't need to pinch-zoom to read body text. Body text should be 16px minimum on mobile; smaller text passes the WCAG bar but fails the readability bar. Tightly-packed lines (line-height <1.5) and narrow column widths (>80 chars per line) compound the issue.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` CSS for `font-size:`, `line-height:`. Quote body text declarations.
2. For body text: confirm font-size 16px (or 1rem) minimum on mobile.
3. For line-height: confirm 1.4-1.6 range.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Parse linked/inline CSS and approximate body text font-size / line-height / column width from declared rules. Caveat: `Fetch` returns source, not the resolved cascade — the computed/rendered value can differ from what you approximate.

### Forbidden claims

- "Text may be too small." Quote font-size values.
- "Line-height may be wrong." Show the values.

### Detection

CSS body text rules.

### What to Search For

- `font-size:` values <16px on body / paragraph text
- `line-height:` values <1.4
- `max-width:` values >900px on body containers (reading line too long)

### Actually Hurts SEO

- **Body text <16px** on mobile.
  Evidence required: CSS rule + element it applies to.
- **Line-height <1.4** for paragraph text.
  Evidence required: CSS rule.
- **Reading column wider than ~80 characters**.
  Evidence required: container max-width + estimated chars per line.

### NOT a Problem

- Caption / footnote text 12-14px (acceptable for de-emphasis).
- Headings of any size (visual hierarchy, not body reading).
- Single-purpose UI labels (buttons, badges) at 12-14px.

### Context Check

1. What's the primary use case? Long-form reading needs more rigor than dashboard UI.
2. Is the text content-bearing or chrome (nav, footer)?
3. Is mobile font-size set with `clamp()` to scale fluidly? Best practice.

### Reference

Web.dev on font sizing: https://web.dev/articles/font-size

WCAG 1.4.4 Resize text: https://www.w3.org/WAI/WCAG21/Understanding/resize-text.html

**Severity tagging:**
- Body text <16px on mobile → High.
- Line-height <1.4 on paragraphs → Medium.
- Reading column >100 chars → Medium.

**Fix voice:** `erik-spiekermann` (primary) | `don-norman` (backup).

Read `souls/erik-spiekermann.json` before writing the Fix. Spiekermann's typography POV: type that's hard to read isn't communicating, regardless of how it looks.

Worked fix example:

> Body text on mobile starts at 16px. Line height between 1.4 and 1.6. Reading column 60-75 characters. These aren't preferences; they're how the human eye reads sustained text without effort.
>
> ```css
> body {
>   font-size: 16px;
>   line-height: 1.6;
> }
> .article-body {
>   max-width: 65ch;  /* about 65 characters */
> }
>
> /* Fluid scaling for larger viewports */
> @media (min-width: 1200px) {
>   body { font-size: 18px; }
> }
> ```
>
> Or use `clamp()` for fluid responsive type that doesn't need media query breakpoints.
