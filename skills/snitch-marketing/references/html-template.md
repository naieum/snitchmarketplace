# HTML Template

The HTML version of the audit report is a SINGLE-FILE, OFFLINE, BRAND-PALETTE-COMPLIANT static page derived from the canonical markdown.

## Hard constraints

1. **Single file.** No external CSS, no external JS, no CDN dependencies. The file must work when opened from disk with no internet connection. Embed all styles inline; embed Prism.js for syntax highlighting inline; embed any icons as SVG inline.
2. **Brand palette only.** Red, white, and black are the only hues the report uses. No cyan, no blue (including the link-blue default), no green (including the success-green default). Severity badges use red shades for Critical / High, gray for Medium / Low, no green checkmarks for "What's working" (use a black or red bullet instead).
3. **Print-friendly.** A `@media print` block hides nav / TOC / interactive elements and produces a clean PDF when the user prints to PDF.
4. **Accessible.** Semantic HTML throughout (`<main>`, `<nav>`, `<article>`, `<section>`, `<h1>`-`<h6>` hierarchy). ARIA labels on interactive elements. Color is not the only severity signal (text labels accompany every color-coded badge).
5. **Confidential mode.** When `snitch-marketing.config.md` has `confidential: true`, the HTML adds a fixed footer banner ("CONFIDENTIAL — DO NOT DISTRIBUTE") and disables the print / share affordances.

## File output

The HTML file is written to `{working_directory}/snitchfindings/{target_slug}/SEO_AUDIT_REPORT.html` alongside the markdown. Both regenerate on every audit. Customers who prefer markdown ignore the HTML; customers who want a formatted report open the HTML in a browser.

## Page structure

```
┌─────────────────────────────────────────────────────────┐
│ HEADER (sticky)                                         │
│ Brand mark | target name | severity counts inline       │
│ [Print] [Toggle TOC]                                    │
├─────────────────┬───────────────────────────────────────┤
│ TOC (sticky)    │ MAIN CONTENT                          │
│                 │                                       │
│ Executive       │ ## Executive snapshot                 │
│ snapshot        │ (one-page TL;DR)                      │
│                 │                                       │
│ Severity counts │ ## Severity counts                    │
│                 │ (table)                               │
│ Site context    │                                       │
│                 │ ## Site context                       │
│ What needs work │ (purpose / business model / audience) │
│  - Critical     │                                       │
│  - High         │ ## What needs work                    │
│  - Medium       │ ### Critical                          │
│  - Low          │ Finding cards (collapsible)           │
│                 │   - Severity badge                    │
│ What's working  │   - Cat number + title                │
│                 │   - Evidence block (code-formatted)   │
│ Skipped         │   - Risk + Fix                        │
│                 │   - Screenshot (if Playwright)        │
│ Recommendations │                                       │
│                 │ (...the rest of the report sections)  │
│ Audit metadata  │                                       │
└─────────────────┴───────────────────────────────────────┘
```

The TOC is sticky on the left at desktop widths; collapses to a top-of-page accordion on mobile.

## Severity badge colors (brand-palette compliant)

| Severity | Background | Text | Visual cue |
|---|---|---|---|
| Critical | `#7f1d1d` (deep red) | white | Filled badge, exclamation icon |
| High | `#dc2626` (red) | white | Filled badge, warning icon |
| Medium | `#525252` (neutral 600) | white | Outlined badge, dot icon |
| Low | `#a3a3a3` (neutral 400) | black | Outlined badge, no icon |
| Pass | `#000000` (black) | white | Filled badge, no icon (NOT green) |
| Skip | `#e5e5e5` (neutral 200) | black | Outlined badge, dash icon |

## Inlined CSS (skeleton)

```css
* { box-sizing: border-box; }
:root {
  --bg: #ffffff;
  --fg: #0a0a0a;
  --muted: #525252;
  --border: #e5e5e5;
  --critical: #7f1d1d;
  --high: #dc2626;
  --medium: #525252;
  --low: #a3a3a3;
  --pass: #000000;
  --skip: #e5e5e5;
  --code-bg: #fafafa;
}
html { font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; color: var(--fg); background: var(--bg); }
body { margin: 0; line-height: 1.6; max-width: 100vw; }
.layout { display: grid; grid-template-columns: 280px 1fr; gap: 2rem; padding: 1rem 2rem; }
.toc { position: sticky; top: 5rem; height: calc(100vh - 6rem); overflow-y: auto; padding-right: 1rem; border-right: 1px solid var(--border); font-size: 0.875rem; }
.toc a { color: var(--fg); text-decoration: none; display: block; padding: 0.25rem 0; }
.toc a:hover { text-decoration: underline; }
.toc a.active { font-weight: 600; }
header.sticky { position: sticky; top: 0; background: var(--bg); border-bottom: 1px solid var(--border); padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; z-index: 10; }
.severity-badge { display: inline-block; padding: 0.125rem 0.5rem; border-radius: 0.25rem; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
.severity-badge.critical { background: var(--critical); color: white; }
.severity-badge.high { background: var(--high); color: white; }
.severity-badge.medium { background: var(--medium); color: white; }
.severity-badge.low { background: var(--bg); color: var(--low); border: 1px solid var(--low); }
.severity-badge.pass { background: var(--pass); color: white; }
.severity-badge.skip { background: var(--bg); color: var(--muted); border: 1px solid var(--border); }
.finding { border-left: 4px solid var(--border); padding: 1rem 1.5rem; margin-bottom: 1.5rem; }
.finding.critical { border-left-color: var(--critical); }
.finding.high { border-left-color: var(--high); }
.finding.medium { border-left-color: var(--medium); }
.finding.low { border-left-color: var(--low); }
pre, code { font-family: ui-monospace, "SF Mono", Menlo, Consolas, monospace; }
pre { background: var(--code-bg); padding: 1rem; border-radius: 0.25rem; overflow-x: auto; font-size: 0.875rem; line-height: 1.5; }
code { background: var(--code-bg); padding: 0.125rem 0.25rem; border-radius: 0.125rem; font-size: 0.875em; }
img.screenshot { max-width: 100%; border: 1px solid var(--border); border-radius: 0.25rem; margin: 0.75rem 0; }
table { border-collapse: collapse; width: 100%; margin: 1rem 0; }
th, td { border: 1px solid var(--border); padding: 0.5rem 0.75rem; text-align: left; vertical-align: top; }
th { background: var(--code-bg); font-weight: 600; }
@media (max-width: 768px) {
  .layout { grid-template-columns: 1fr; }
  .toc { position: relative; top: auto; height: auto; border-right: none; border-bottom: 1px solid var(--border); padding-bottom: 1rem; }
}
@media print {
  header.sticky, .toc, .no-print { display: none; }
  .layout { grid-template-columns: 1fr; padding: 0; }
  .finding { page-break-inside: avoid; }
}
.confidential-banner { position: fixed; bottom: 0; left: 0; right: 0; background: var(--critical); color: white; padding: 0.5rem 1rem; text-align: center; font-weight: 600; z-index: 100; }
```

## Markdown to HTML conversion

The markdown report is parsed with the following rules:

- `#` headings become `<h1>` through `<h6>`. Build the TOC from `<h2>` and `<h3>` (deeper levels not in TOC by default).
- Tables become semantic `<table>` with `<thead>` and `<tbody>`.
- Fenced code blocks (```` ``` ````) become `<pre><code class="language-X">` with Prism.js syntax highlighting (Prism.js inlined as a small embedded JS block).
- Inline code (`` ` ``) becomes `<code>`.
- Severity tier mentions in finding headers (e.g., "Cat 3, Canonical, Critical") parse the severity word and apply the corresponding CSS class to the parent finding container.
- Image references (`![alt](path)`) become `<img>` tags with the path resolved relative to the report file. Screenshots from `snitchfindings/{slug}/screenshots/` render inline.
- Links to other findings (`Finding 5`) become anchor links to the target finding's `<section id="finding-5">`.
- Links to other reports / files use relative paths.

## Renderer script (`scripts/render-report.py`)

A small Python script that takes the markdown report path as input and writes the HTML report alongside it. Skill invokes it via Bash after writing the markdown.

The script:

1. Reads the markdown file.
2. Parses it with a markdown library OR a small handwritten parser (sufficient for the structured report format we produce).
3. Extracts the TOC entries from `##` and `###` headings.
4. Wraps the rendered body in the HTML template skeleton above.
5. Inlines the CSS, the Prism.js (or hand-rolled syntax highlighter for code blocks), and the SVG icons.
6. Adds the confidential banner if config flag is set.
7. Writes the HTML to the same directory as the markdown, with `.html` extension.

The script is small (~200 lines) and has no third-party dependencies beyond what ships with Python's standard library plus optionally `markdown-it-py` if available. If `markdown-it-py` is not installed, the script falls back to a basic regex-based parser.

## When the HTML is regenerated

Every time the markdown is written. The HTML is a derived view; it tracks the markdown 1-to-1.

## Cross-references

- `references/report-template.md`, the markdown structure that the renderer parses.
- `references/output-formats.md`, the broader output-format options (executive summary, JSON, CSV, PR comment) of which HTML is one.
- `snitch-marketing.config.md`, the `confidential` flag and (future) HTML-styling overrides.
