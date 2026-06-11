## CATEGORY 40: Render-blocking CSS / JS

Synchronous `<link rel="stylesheet">` and `<script src>` in `<head>` block the browser from painting until they download and parse. Each one delays first paint, the user sees a blank screen until they're done. Defer / async / inline-critical reduce or eliminate this.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `<link rel="stylesheet"`, `<script src=`, `<script async`, `<script defer`, `<script type="module"`. Quote each.
2. For each `<link rel="stylesheet">`: check if it's in `<head>` (render-blocking) or `<body>` (deferred).
3. For each `<script src>`: check for `async` or `defer` attribute or `type="module"` (which is implicitly deferred).
4. Identify "critical" stylesheets vs non-critical (analytics, third-party widgets).

**Crawl mode, required tool calls:**

1. `Fetch` URL. Find render-blocking elements in `<head>`. Quote.
2. Optionally: run Lighthouse / PSI for the render-blocking-resources audit; quote the score and contributing files.

### Forbidden claims

- "Render-blocking resources are probably present." Quote them.
- "JS may be blocking the parser." Show the synchronous scripts.

### Detection

`<head>` is the danger zone. Look for synchronous scripts and stylesheets there.

### What to Search For

- `<link rel="stylesheet"` (in head: blocking)
- `<script src=` (in head, no async/defer/module: blocking)
- `<script async`, `<script defer`, `<script type="module"` (non-blocking)
- Inline `<style>` with critical CSS (correct pattern)

### Actually Hurts SEO

- **Multiple `<link rel="stylesheet">` in head, each blocking paint**.
  Evidence required: count + list of stylesheet URLs.
- **Synchronous third-party `<script>` in head** (analytics, A/B test, chat widget).
  Evidence required: script tag + the third-party domain.
- **No critical CSS inlined** (entire CSS file blocks paint).
  Evidence required: head with link to large CSS but no inline style block.

### NOT a Problem

- A single small CSS file blocking paint (acceptable for tiny sites).
- Scripts at end of body (acceptable; not blocking initial paint).
- Async / defer scripts (correct).
- ESM modules (`type="module"` is implicitly deferred).

### Context Check

1. Is the framework auto-handling critical CSS? Next.js / Astro inline critical CSS by default.
2. Are third-party scripts gated behind consent (don't load before user interaction)? Better.
3. Is the LCP element getting blocked by the resources, or rendered fine despite them? Correlate with PSI.

### Reference

Web.dev on render-blocking: https://web.dev/articles/render-blocking-resources

**Severity tagging:**
- Multiple blocking stylesheets → High.
- Sync third-party script in head → High.
- Critical CSS not inlined → Medium.

**Fix voice:** `performance-engineer` (primary) | `solutions-architect` (backup).

Read `souls/performance-engineer.json` before writing the Fix.

Worked fix example:

> The browser can't paint while it's parsing render-blocking resources. Every blocking stylesheet and every sync script adds time before pixels appear.
>
> ```html
> <!-- Block: synchronous stylesheet -->
> <link rel="stylesheet" href="/styles.css">
>
> <!-- Inline critical CSS, defer the rest -->
> <style>{criticalCss}</style>
> <link rel="preload" href="/styles.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
>
> <!-- Block: synchronous script -->
> <script src="/analytics.js"></script>
>
> <!-- Defer: -->
> <script src="/analytics.js" async></script>
> ```
>
> Inline only the CSS the first viewport actually uses (~14KB max). Defer everything else. Async or defer all scripts that aren't strictly required for first paint. Frameworks (Next.js, Astro, Remix) often automate this, verify by inspecting production HTML.
