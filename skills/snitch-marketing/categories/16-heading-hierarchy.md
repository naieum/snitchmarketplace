## CATEGORY 16: Heading hierarchy

Headings (`<h1>` through `<h6>`) form the page's outline. Skipped levels (h2 → h4 with no h3), out-of-order levels (h3 before h2), or all-headings-as-h2 (no hierarchy at all) confuse screen readers and reduce Google's understanding of the page's structure. Hierarchy isn't visual styling, it's the document's table of contents.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` route + content files. `Grep` for `<h1`, `<h2`, `<h3`, `<h4`, `<h5`, `<h6` AND `^# `, `^## `, `^### `, `^#### ` (Markdown / MDX). Quote each match.
2. For each route or article: extract the heading sequence. Note the level transitions.
3. Identify violations: skipped levels, levels going backward (h3 → h2 → h3 is fine; h4 → h2 with no intermediate is suspicious), all headings same level.
4. Quote the offending heading sequence with file:line.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Parse `<body>`. Extract every heading element in document order with its level + text content.
2. Walk the sequence. Identify level skips and out-of-order patterns.
3. Quote the heading sequence in the report (heading text + level + position in document).

### Forbidden claims

- "The headings are probably out of order." Show the sequence.
- "Some pages may skip levels." Quote the offending sequence.
- "The hierarchy is probably wrong." Be specific, wrong how? Quote the violation.

### Detection

#### Source mode

For each page:
1. Read the page component + any layout components + any MDX content rendered.
2. Build the resulting heading sequence in document order.
3. Walk: every level should be ≤ (previous level + 1). Going from h2 to h3 is fine; going from h2 to h4 skips h3.

For MDX content with custom heading remapping (some MDX providers rebind `h1` → `h2`), check the MDX provider config, the source `# Heading` may not render as `<h1>`.

#### Crawl mode

Parse rendered HTML, extract headings, walk the sequence.

### What to Search For

- `<h[1-6]` in source / HTML
- `^#{1,6} ` (Markdown headings at column 0)
- Heading components: `<Heading level={N}>`, `<H[1-6]>`
- MDX provider configs that remap heading levels

### Actually Hurts SEO

- **Skipped heading level** (h2 → h4 with no h3 between).
  Evidence required: the heading sequence quoted with the skip identified.
- **All sub-headings at h2** (page has h1 + 12 h2s with no h3-h6 nesting).
  Evidence required: quoted heading levels + a count showing the flatness.
- **Heading levels going backward unnecessarily** (h3 in the article body, then a "Recent Posts" h2 sidebar). Often a layout-vs-content collision.
  Evidence required: the sequence + a note on which heading came from which component.
- **Headings used purely for visual styling, not document structure** (`<h2 class="text-sm">` for a small label that isn't a section heading).
  Evidence required: the element + its class/style + the surrounding content showing it's not a real section.
- **`<h6>` used for footer copyright text or other non-heading content**.
  Evidence required: the element + its content.

### NOT a Problem

- A long-form article with h1 → h2 → h2 → h2 → h2 (no h3 sub-sections). Flat is fine if the article doesn't have sub-sub-sections.
- Layout headings (sidebar widgets, footer "More links" h3), common; flag only if they violate document hierarchy.
- HTML5 `<section>` containing its own h1 (per the outline algorithm). Modern browsers don't implement the outline algorithm; treat as flat doc structure for SEO purposes. Don't flag unless paired with other issues.
- Decorative headings styled visually as paragraphs. Flag only if they break the document outline.

### Context Check

1. Is this an article / blog post? Hierarchy matters more here. Strict h1 → h2 → h3 expected.
2. Is this a homepage / landing page? Often flatter; one h1, then h2s for sections, no h3+. Acceptable.
3. Is this a docs page? Strict hierarchy is critical (table-of-contents generated from headings).
4. Does the framework auto-remap headings (e.g., MDX rebinding)? Read the config.
5. Are there hidden or noindex'd headings? If the page is noindex'd, hierarchy doesn't matter for SEO.

### Reference

WCAG 2.1 on heading levels: https://www.w3.org/WAI/tutorials/page-structure/headings/

Google's documentation on headings: https://developers.google.com/search/docs/fundamentals/seo-starter-guide#use-heading-tags-to-emphasize-important-text

**Severity tagging:**
- Skipped levels in long-form content → Medium.
- All-h2 with no nesting on a 3000-word article → Medium.
- Headings used as styling only → Low.
- Backward-going levels from layout-vs-content collision → Low.

**Fix voice:** `hierarchy-purist` (primary) | `less-but-better-designer` (backup).

Read `souls/hierarchy-purist.json` before writing the Fix. Hierarchy made explicit through typography. The document outline IS the hierarchy; CSS is only how you make it visible.

Worked fix example:

> Each heading level is a layer in the outline. Layers descend in order: 1, then 2, then 3, then 4. Skipping is wrong not because Google penalizes it (it largely doesn't), but because it makes the document mean less than it should.
>
> ```html
> <!-- Wrong: skipped h3 -->
> <h1>Pricing</h1>
> <h2>Tiers</h2>
> <h4>Pro</h4>
>
> <!-- Right: continuous descent -->
> <h1>Pricing</h1>
> <h2>Tiers</h2>
> <h3>Pro</h3>
> ```
>
> Style is independent of structure: an `<h3>` can look exactly like an `<h2>` in CSS if that's the visual you want. The structure stays correct; the appearance follows.
