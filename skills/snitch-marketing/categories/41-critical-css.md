## CATEGORY 41: Critical-path CSS

Critical CSS is the subset of CSS needed to render the first viewport. Inlining it in the head means the browser can paint the above-fold content without waiting for the full stylesheet to download.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `<style>` (inline) in head. Quote.
2. Check the size of inlined CSS (should be ~14KB to fit in first TCP packet).
3. Check if the framework has critical CSS extraction (Next.js: built-in; Astro: built-in; Remix: built-in; vanilla: needs build step).

**Crawl mode, required tool calls:**

1. `Fetch` URL. Inspect head for inline `<style>` blocks. Quote size.
2. Compare to total CSS weight from external stylesheets.

### Forbidden claims

- "Critical CSS may not be inlined." Quote the head.
- "Page may have no critical CSS extraction." Check framework config.

### Detection

Inline `<style>` blocks at the top of head.

### What to Search For

- `<style>` (in head)
- `__next/static/css/` (Next.js inlined CSS marker)
- `data-astro-cid-` (Astro inlined CSS attribute)
- Critical CSS extraction tools: `critters`, `critical`, `purgecss`

### Actually Hurts SEO

- **No inline CSS in head AND large external stylesheet** (paints blocked entirely).
  Evidence required: head without `<style>` + linked CSS file size.
- **Inline CSS exceeds ~50KB** (no longer "critical"; defeats purpose).
  Evidence required: inline style block size.
- **Inline CSS missing styles for above-fold content** (FOUC: flash of unstyled content briefly).
  Evidence required: visual rendering check.

### NOT a Problem

- Tiny sites with one small stylesheet, critical CSS extraction is overkill.
- Sites where total CSS is under 14KB, entire stylesheet IS the critical CSS.

### Context Check

1. Does the framework do critical-CSS extraction by default? Often yes.
2. Is the LCP element styled by inline CSS or external? External = LCP delayed.
3. How big is the full CSS bundle? Smaller bundles need less critical extraction.

### Reference

Web.dev on critical CSS: https://web.dev/articles/extract-critical-css

**Severity tagging:**
- No critical CSS + large external sheet → High.
- Inline CSS exceeds 50KB → Medium.
- Above-fold styles missing from inlined → Medium.

**Fix voice:** `performance-engineer` (primary) | `sarah-drasner` (backup).

Read `souls/performance-engineer.json` before writing the Fix.

Worked fix example:

> Inline the CSS the first viewport actually uses. Defer the rest. The browser paints faster, the user sees content sooner, the LCP score improves.
>
> ```html
> <head>
>   <!-- ~10KB of styles for above-fold content -->
>   <style>{criticalCss}</style>
>
>   <!-- Full stylesheet, deferred -->
>   <link rel="preload" href="/styles.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
>   <noscript><link rel="stylesheet" href="/styles.css"></noscript>
> </head>
> ```
>
> Most modern frameworks do this automatically. If yours doesn't, build-time tools (`critters`, `critical`) extract critical CSS at build. Configure once.
