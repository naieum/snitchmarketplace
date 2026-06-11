# Screenshot Integration (Playwright MCP)

For crawl-mode findings about rendered webpage elements, the report includes a screenshot of the page so the customer sees exactly which section the audit is naming. This reference documents how the skill captures, stores, and embeds screenshots when a Playwright MCP server is available to the agent.

## When this is active

Screenshot capture runs only when:

1. The audit is in **crawl mode** (source mode has no rendered DOM to screenshot).
2. The Playwright MCP server is available (the agent's tool list includes `mcp__plugin_playwright_playwright__browser_navigate`, `browser_take_screenshot`, etc.).
3. The cat being scanned is marked `screenshot-relevant: true` in its category file.
4. The finding's evidence has a URL + element selector (so the screenshot can be focused on the relevant part of the page).

If any condition fails, the audit skips screenshot capture for that cat / finding silently. The report's `audit_metadata` notes:

```yaml
screenshots:
  enabled: true | false
  reason_if_disabled: <one of: "source-mode audit", "Playwright MCP unavailable", "no screenshot-relevant cats in scan">
  captured: N
```

## Per-cat screenshot relevance

Cats are tagged `screenshot-relevant: true | false` in their category file frontmatter or final metadata block. Default for new cats: `false` (opt-in). Cats currently flagged screenshot-relevant by default:

| Cat | Why screenshot-relevant |
|---|---|
| 9 | Title tag rendered in browser tab + SERP preview |
| 11 | Open Graph image renders in social preview |
| 13 | Favicon rendered in browser tab |
| 15 | H1 visible at hero |
| 22 | Breadcrumb component visible in nav |
| 25, 26 | Image alt visible to screen readers (capture surrounding context) |
| 28 | CLS / explicit dimensions visible in layout shift |
| 49 | Color contrast visible in rendered page |
| 60 | Conversion CTAs visible at hero / pricing / signup |
| 81 | Hero positioning copy visible |
| 99 | Conversion funnel visible (homepage → pricing → signup) |
| 111 | Trust artifacts visible (founder face, testimonials, changelog link, etc.) |

Cats NOT screenshot-relevant (source-only or non-visual):

- Cat 1 (robots.txt), Cat 2 (sitemap), Cat 3 (canonical), Cat 4 (indexability), Cat 31 (JSON-LD presence), Cat 39 (font loading), Cat 50-52 (i18n), Cat 53-56 (analytics), schema cats 32-38 + 87-94, Cat 39-44 (performance), Cat 100 (cookieless analytics), Cat 106 (llms.txt), Cat 107-109 (ads measurement methodology).

## Capture flow

For each finding fired by a screenshot-relevant cat:

1. **Navigate** to the URL: `mcp__plugin_playwright_playwright__browser_navigate({ url: <finding_url> })`. Wait for network idle or a configured timeout.
2. **Optionally highlight the element** via `mcp__plugin_playwright_playwright__browser_evaluate` with a small JS snippet that adds an outline + box-shadow to the target element by selector:
   ```javascript
   (selector) => {
     const el = document.querySelector(selector);
     if (el) {
       el.style.outline = '3px solid #dc2626';
       el.style.outlineOffset = '4px';
       el.style.boxShadow = '0 0 0 8px rgba(220, 38, 38, 0.2)';
       el.scrollIntoView({ behavior: 'instant', block: 'center' });
     }
   }
   ```
   The selector comes from the finding's evidence (e.g., `header h1`, `meta[name="description"]` via inspect-via-script). For findings without a clear element selector (e.g., "homepage title duplicates root layout title"), skip the highlight and capture the viewport as-is.
3. **Capture the screenshot**: `mcp__plugin_playwright_playwright__browser_take_screenshot({ format: 'png', fullPage: false })`. Default is viewport-only (above-fold + a bit below). For findings that span the full page (footer link spam, full content depth audits), set `fullPage: true`.
4. **Save the file** to `{working_directory}/snitchfindings/{target_slug}/screenshots/{finding-id}.png`. The file path naming is critical: the markdown report references it via relative path.
5. **Embed in the report**: in the finding's Evidence block, add `![{finding_id} screenshot](./screenshots/{finding-id}.png)` markdown. The HTML renderer (per `html-template.md`) renders this as `<img class="screenshot">` inline.

## Storage and cleanup

- Screenshots accumulate in `snitchfindings/{slug}/screenshots/`. Multi-pass audits produce multiple PNGs per slug.
- `snitchfindings/` is in `.gitignore` so screenshots don't pollute git.
- A `screenshot-retention-days` config knob (in `snitch-marketing.config.md`, default 90) governs cleanup. When the audit runs and detects screenshots older than the retention period, it offers to delete them.
- Screenshots from the previous audit pass (when diff mode runs) are preserved in `snitchfindings/{slug}/screenshots-{prev_date}/` for comparison. Visual diff is a Tier 3 future feature.

## Privacy considerations

Screenshots can capture sensitive content (logged-in dashboard, customer data, etc.). The audit captures only public-facing pages (per the cat's URL-determination logic). If a cat would need to capture an authenticated view, it skips with reason `screenshot-skipped: requires authentication`.

For PII redaction beyond what's caught by the page-naturally-public test, the agent can run a JS snippet to mask elements before capture:

```javascript
(selector) => {
  document.querySelectorAll(selector).forEach(el => {
    el.style.filter = 'blur(8px)';
  });
}
```

Per the existing Rule 5 (Redact PII and Tracking IDs), any screenshot embedded in a report must not contain real customer data, tokens, or PII. The audit's redaction pass runs before screenshot capture for fixtures / mock data and applies to live capture only when explicitly triggered.

## Markdown vs HTML output

- **Markdown**: `![alt](./screenshots/finding-1.png)` — renders inline in markdown viewers (GitHub, agent tools, mdBook).
- **HTML**: the renderer (`scripts/render-report.py`) wraps the markdown image in `<img class="screenshot" alt="..." src="...">` with the CSS class that styles it (max-width, border, rounded corners).

Both formats reference the same PNG file. The screenshots directory MUST be alongside the report files (same directory) for relative paths to resolve.

## Failure modes and recovery

- **Page fails to load** (timeout, 4xx, 5xx): the audit logs the failure to `audit_metadata.screenshots.errors` and continues. The finding still surfaces in the report; the screenshot is just absent for that finding.
- **Element selector doesn't match**: capture the viewport without highlight; note in `audit_metadata.screenshots.warnings`.
- **Screenshot too large** (>2MB): the renderer optionally compresses to JPEG with quality 85 if the target file size exceeds 2MB.
- **Playwright MCP times out**: the audit aborts only the screenshot for that finding; subsequent screenshots and the rest of the audit continue.

## When to ENABLE highlighting (selector-targeted) vs DISABLE (full viewport)

ENABLE highlighting when:
- The finding is about a specific named element (a CTA button, a heading, a meta tag visible in the source viewer extension).
- A clear CSS selector resolves to one element on the page.

DISABLE highlighting when:
- The finding is about the page's overall composition (heading hierarchy across the page, multiple competing CTAs at the hero).
- The selector would resolve to many elements or the highlight would obscure the issue.
- The page's layout is not the issue (the issue is about meta tags or HTTP headers that don't render visually).

## Cross-references

- `snitch-marketing.config.md`, screenshot-related config (retention, capture-defaults).
- `references/report-template.md`, where the finding's Evidence block embeds the screenshot reference.
- `references/html-template.md`, how the HTML renderer styles the embedded screenshots.
- `references/output-formats.md`, the broader output-format options.
- `mcp__plugin_playwright_playwright__*` tool surface, the actual MCP tools used for capture.
