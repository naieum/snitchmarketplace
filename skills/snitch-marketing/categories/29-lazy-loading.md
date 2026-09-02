## CATEGORY 29: Lazy-load directives

Below-fold images / iframes that load eagerly waste bandwidth and slow LCP for the visible content. `loading="lazy"` defers their fetch until they're near the viewport. Counterintuitively, hero images SHOULD NOT be lazy-loaded, that delays LCP. The fix is per-image: lazy below the fold, eager above.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `<img ` and `<iframe `. Quote each.
2. Identify which are above the fold (typically the first image in a layout, hero images) vs below (in-content images, sidebar embeds).
3. Check `loading="lazy"`, `loading="eager"`, or absent.
4. Above-fold images with `loading="lazy"` is a Critical mistake (delays LCP). Below-fold images without lazy is a Medium opportunity.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Parse images + iframes. Quote each with `loading=` attribute.

### Forbidden claims

- "Lazy loading is probably misconfigured." Quote the directive on each image.
- "Some images may load eagerly when they shouldn't." Identify which.

### Detection

Source pattern: `<img loading="lazy">`, `<img loading="eager">`, or absent.

### What to Search For

- `loading="lazy"`, `loading='lazy'`
- `loading="eager"`, `loading='eager'`
- `<iframe` without loading attribute (default is eager, often a perf bug)

### Actually Hurts SEO

- **Hero / above-fold image with `loading="lazy"`**.
  Evidence required: the element + page-position evidence (it's the first image / hero / above the fold).
- **Below-fold images without `loading="lazy"`**.
  Evidence required: image position + missing lazy directive.
- **`<iframe>` for below-fold embeds (YouTube, Twitter, Calendly) without `loading="lazy"`**.
  Evidence required: iframe element.

### NOT a Problem

- Hero image with `loading="eager"` or no loading attribute (default eager). Correct.
- Below-fold image with `loading="lazy"`. Correct.
- Tiny inline icon SVGs without loading attr. Doesn't matter.

### Context Check

1. Is the image LCP-eligible? Don't lazy-load LCP elements.
2. Does the framework auto-set loading? Next.js Image: `priority={true}` for above-fold (translates to `loading="eager"`).
3. Is the lazy threshold native or polyfilled? Modern browsers do native lazy-load; older browsers ignore the attribute (no harm).

### Reference

Web.dev on lazy loading: https://web.dev/articles/browser-level-image-lazy-loading

**Severity tagging:**
- Above-fold image lazy-loaded → Critical.
- Many below-fold images without lazy → Medium.
- Iframe without lazy → Medium.

**Fix voice:** `motion-engineer` (primary) | `performance-engineer` (backup).

Read `souls/motion-engineer.json` before writing the Fix. The motion-and-perf position: lazy does not mean janky; properly configured lazy loading is invisible to the user and saves bandwidth.

Worked fix example:

> The default for content images below the fold is lazy. The default for the hero image is eager. Get this backwards and you delay the LCP element AND eagerly load images nobody scrolls to.
>
> ```html
> <!-- Hero / above-fold: load now -->
> <img src="/hero.webp" alt="…" loading="eager" fetchpriority="high">
>
> <!-- Below-fold: load when near viewport -->
> <img src="/below-fold.webp" alt="…" loading="lazy">
>
> <!-- Below-fold iframe: same -->
> <iframe src="https://youtube.com/embed/…" loading="lazy"></iframe>
> ```
>
> If the framework Image component supports `priority` / `fetchpriority`, use it on the hero. The browser fetches the LCP image first, lazy-loads everything else as the user scrolls.
