## CATEGORY 43: Image weight

Total image weight on the page. A single 5MB JPEG sinks LCP and mobile experience. The fix is per-image: smaller files via better format (Cat 27), better compression, and responsive image variants for different viewports.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` `**/*.{jpg,jpeg,png,webp,avif,gif}`. List file sizes.
2. For images >300KB: flag as oversized.
3. Cross-reference with `<img>` references, large unused images aren't a finding (they don't ship).

**Crawl mode, required tool calls:**

1. `Fetch` URL. List image elements. For each, fetch the image and quote response Content-Length.
2. Total image weight per page.

### Forbidden claims

- "Images may be too large." Quote sizes.
- "The page is image-heavy." Sum the bytes.

### Detection

File size of images vs their rendered dimensions on the page.

### What to Search For

- Image files with size >300KB
- `<img>` elements without `srcset` (no responsive variants)
- `<picture>` elements without multiple `<source>` for different viewports

### Actually Hurts SEO

- **Hero image >500KB unoptimized**.
  Evidence required: file size + rendered position (above fold).
- **Page total image weight >2MB**.
  Evidence required: per-image sum.
- **No `srcset` on responsive images** (mobile loads desktop-sized image).
  Evidence required: img tag without srcset.

### NOT a Problem

- A single illustrative image at 200-300KB. Fine.
- Vector SVGs (kilobytes regardless of dimensions).
- Lazy-loaded below-fold images (still ship, but don't block LCP).

### Context Check

1. What's the LCP image? Optimize that one first.
2. Does the framework / CDN serve responsive variants automatically?
3. Are images source files (high-quality originals) accidentally being shipped as production assets? Common pattern.

### Reference

Web.dev on image optimization: https://web.dev/articles/optimize-images

**Severity tagging:**
- Hero image >500KB → High.
- Page image total >2MB → High.
- Missing srcset on responsive images → Medium.

**Fix voice:** `performance-engineer` (primary) | `less-but-better-designer` (backup).

Read `souls/performance-engineer.json` before writing the Fix.

Worked fix example:

> A 2MB image is 2 seconds of LTE bandwidth. Compress, format-shift, and srcset.
>
> ```html
> <picture>
>   <source media="(max-width: 768px)" srcset="/hero-mobile.webp" type="image/webp">
>   <source media="(min-width: 769px)" srcset="/hero-desktop.webp" type="image/webp">
>   <img src="/hero-fallback.jpg" alt="…" width="1200" height="600" fetchpriority="high">
> </picture>
> ```
>
> Mobile gets the mobile-sized image (smaller bytes), desktop gets the larger one. Both are WebP/AVIF. Hero gets `fetchpriority="high"` so it preempts other resources. Total page image weight drops 60-80% on mobile.
