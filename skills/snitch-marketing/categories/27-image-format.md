## CATEGORY 27: Image format (webp / avif)

Modern image formats (WebP, AVIF) compress 25-50% smaller than JPEG/PNG at the same quality. Shipping JPEG/PNG when modern formats would work means slower page loads, worse Core Web Vitals (LCP), worse mobile experience on slow connections, worse SEO.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` `**/*.{jpg,jpeg,png,gif}` AND `**/*.{webp,avif}`. Quote counts.
2. `Grep` for `<img src=`, `<Image src=`. Inspect each src extension.
3. For framework Image components (Next.js Image, Astro Image): `Read` the component config, most auto-generate WebP/AVIF on the fly. If so, the source `.jpg`/`.png` files are fine; the served version is modern.
4. For raw `<img>` tags pointing at JPEG/PNG: that IS the finding (no auto-conversion).

**Crawl mode, required tool calls:**

1. `Fetch` URL. Find `<img>` elements. Note response Content-Type for each src on follow-up fetches.
2. If responses are `image/jpeg` or `image/png` for content images, that's the finding.
3. Note if `<picture>` elements with `<source type="image/webp">` are present (correct adaptive serving).

### Forbidden claims

- "Images are probably not WebP." Count by format.
- "Modern format adoption is probably low." Quote percentages.

### Detection

Source patterns + crawl response types tell the story together.

### What to Search For

- File extensions in src: `.jpg`, `.jpeg`, `.png`, `.gif`
- Modern formats: `.webp`, `.avif`
- `<picture>` with `<source>` for format negotiation
- Framework Image components and their config

### Actually Hurts SEO

- **Heavy use of JPEG / PNG for content images on a site that can serve modern formats**.
  Evidence required: count of legacy images + the fact that the deployment target supports modern formats (Cloudflare, Vercel, Netlify all do).
- **No `<picture>` element with WebP/AVIF source for important hero images**.
  Evidence required: `<img>` quoted + missing `<picture>` wrapper.
- **GIF used for animated content where MP4/WebM would be 90% smaller**.
  Evidence required: `<img src="*.gif">` + dimensions/duration.

### NOT a Problem

- A small site with 5 images all in JPEG. The savings are real but small; flag as Low.
- SVGs for vector content. SVGs are already efficient; modern formats don't apply.
- Framework with on-the-fly transformation pipeline (Next.js, Astro, Cloudinary), the source JPEG is fine because the served WebP is automatic.

### Context Check

1. Does the framework serve modern formats automatically? If yes, source format doesn't matter much.
2. Is the deployment target a CDN that does on-the-fly format conversion (Cloudflare Polish, Vercel Image Optimization)? Often automatic.
3. Are images on a CDN with no transformation? Source format = served format. Convert.
4. What's the image-weight budget per page? If pages are 2-3MB and 80% is image bytes, format upgrade is high-leverage.

### Reference

Google on image optimization: https://developers.google.com/speed/docs/insights/OptimizeImages

WebP / AVIF browser support: https://caniuse.com/webp + https://caniuse.com/avif

**Severity tagging:**
- Heavy legacy-format usage on content images → Medium.
- GIF for video content → High.
- No format negotiation on hero / above-fold images → Medium.

**Fix voice:** `performance-engineer` (primary) | `solutions-architect` (backup).

Read `souls/performance-engineer.json` before writing the Fix. Pure perf decision: bytes shipped = time to render = ranking signal.

Worked fix example:

> JPEG hero at 800KB renders in 1.2s on a slow phone. Same image as WebP at 280KB renders in 400ms. AVIF at 180KB renders in 250ms. Same visual quality. Same image. Three formats, three different LCP scores.
>
> ```html
> <picture>
>   <source srcset="/hero.avif" type="image/avif">
>   <source srcset="/hero.webp" type="image/webp">
>   <img src="/hero.jpg" alt="…" width="1200" height="600">
> </picture>
> ```
>
> Browsers pick the first format they support. AVIF for new browsers, WebP for older ones, JPEG as ultimate fallback. Or, if your framework does on-the-fly format negotiation (Next.js Image, Astro Image, Vercel/Cloudflare CDN), keep one source file and let the platform serve the right format per request.
