## CATEGORY 11: Open Graph tags

Open Graph (`og:title`, `og:description`, `og:image`, `og:url`, `og:type`, `og:site_name`) controls how the page renders when shared on Facebook, LinkedIn, Slack, Discord, iMessage, and most other surfaces that aren't Twitter/X (Cat 12). Missing OG = ugly link previews = lower share rates = lost referral traffic.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` every route file + parent layouts. `Read` each.
2. `Grep` for `og:title`, `og:description`, `og:image`, `og:url`, `og:type`, `og:site_name`, `openGraph:` (Next.js shape), `og.title` (some helper libs). Quote each.
3. For each indexable route: confirm the full OG set exists. Missing `og:image` is the most common gap and the most damaging.
4. For `og:image` findings: confirm the image URL is absolute (https://) and resolves. `Glob` `public/og-image.*` or check the image's existence at the declared path.
5. **For `og:image` dimensions:** run `Bash file <path-to-image>` to read the binary header (output includes dimensions for PNG/JPEG/WebP). Quote the output. Image <1200x630 is a finding. If you cannot run `file` for any reason, mark this sub-check as Skip with reason `dimension verification requires file/exiftool; not run`, do NOT Pass on dimensions you didn't measure.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Quote each `<meta property="og:*">` element.
2. For `og:image` findings: fetch the image URL and quote response status + content-type.
3. **For dimensions in crawl mode:** `Bash curl -sL <url> -o /tmp/og.bin && file /tmp/og.bin && rm /tmp/og.bin`. Quote dimensions. Same Skip-with-reason fallback if the tool isn't available.

**Optional verification (post-audit):** paste the URL into Facebook's Sharing Debugger or LinkedIn's Post Inspector to see the cached preview.

### Forbidden claims

- "OG tags are probably missing." Quote present-or-absent.
- "The OG image is probably broken." Fetch it, quote status.
- "Social shares probably look bad." Quote each tag's value and let the user judge.

### Detection

#### Source mode

- **Next.js App Router**: `metadata.openGraph: { title, description, images, url, type, siteName }`.
- **Next.js Pages Router**: `<meta property="og:title" content="..." />` inside `<Head>`.
- **TanStack Start**: `head: () => ({ meta: [{ property: 'og:title', content: '...' }, ...] })`.
- **Astro**: `<meta property="og:title" content={title}>` in layout.
- **WordPress**: Yoast / RankMath emit OG tags via plugin actions; check plugin settings.

#### Crawl mode

`Fetch`. Look for `<meta property="og:*">` elements in `<head>`. Quote each.

### What to Search For

- `og:title`, `og:description`, `og:image`, `og:url`, `og:type`, `og:site_name`
- `og:image:width`, `og:image:height`, `og:image:alt` (extended set)
- `property="og:` (HTML attribute pattern)
- `openGraph:` (Next.js shape)
- `_yoast_wpseo_opengraph-title` (WordPress Yoast)

### Actually Hurts SEO

- **No `og:image` on a shareable page**.
  Evidence required: missing tag in source/HTML. Quote the `<head>` to show absence.
- **`og:image` URL is relative or 404s**.
  Evidence required: tag's content + fetched image's response status.
- **`og:image` <600px wide (renders poorly on most platforms)**.
  Evidence required: image dimensions + the rendering minimum (recommended 1200x630).
- **OG title differs significantly from `<title>` (potential mismatch / spam signal)**.
  Evidence required: both quoted.
- **No `og:description` (falls back to meta description, which may be wrong shape for social)**.
  Evidence required: tag absence + the `<meta name="description">` value showing the fallback.
- **OG tags duplicated across pages / set globally without per-page overrides**.
  Evidence required: bucketed routes with same OG values quoted.

### NOT a Problem

- `og:image:alt` missing (most platforms don't use it). Low.
- `og:locale` missing (Facebook auto-detects from page lang). Low.
- `og:image` >2000px wide (Facebook caps at 5MB; large is fine if file size is reasonable).

### Context Check

1. Is the page meant to be shared? OG matters most on blog posts, product pages, marketing landing pages. Less on dashboards / authenticated routes.
2. Auto-set by plugin? Check Yoast/RankMath settings.
3. Per-page or global? A single global `og:image` on every URL is a finding, each page deserves its own.
4. Image hosted on a CDN that may rate-limit social-sharing fetches? Some CDNs throttle Facebook's crawler; image becomes unreliable. Consider hosting OG images on a different path with permissive caching.
5. WordPress: is the featured image automatically used as `og:image`? Check theme config.

### Reference

Open Graph protocol: https://ogp.me

Facebook Sharing Debugger: https://developers.facebook.com/tools/debug/

LinkedIn Post Inspector: https://www.linkedin.com/post-inspector/

**Severity tagging:**
- No `og:image` on shareable page → High.
- `og:image` 404 or relative URL → Critical.
- OG tags global / duplicated across pages → Medium.
- Missing `og:title` (defaulted to title tag) → Low.
- Missing `og:description` → Low.

**Fix voice:** `brand-surface-designer` (primary) | `expressive-typographer` (backup).

Read `souls/brand-surface-designer.json` before writing the Fix. Every surface where the brand appears is the brand. A link preview in a message thread IS your brand to the recipient.

Worked fix example:

> The link preview is the only design surface for the people who'll never visit your site. Treat it like packaging.
>
> Per route: a unique 1200x630 OG image that says what the page is in 6 words or less. Set the title and description with the actual page's pitch, not a global default.
>
> ```tsx
> // app/blog/[slug]/page.tsx
> export async function generateMetadata({ params }) {
>   const post = await getPost(params.slug);
>   return {
>     openGraph: {
>       title: post.title,
>       description: post.excerpt,
>       url: `https://example.com/blog/${post.slug}`,
>       siteName: 'Example',
>       images: [{ url: post.heroImage, width: 1200, height: 630, alt: post.title }],
>       type: 'article',
>     },
>   };
> }
> ```
>
> Test with Facebook's Sharing Debugger after deploy. The first scrape Facebook does is what every other surface caches; if it's wrong, fix and re-scrape immediately.
