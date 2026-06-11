## CATEGORY 30: Video sitemap presence

Sites with video content benefit from a video-specific sitemap (or video extension entries in the main sitemap). Without it, Google has to discover videos through page crawls; with it, videos get indexed faster and qualify for Video rich results in SERP.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `<video`, YouTube embed iframes, Vimeo embeds, and other video patterns. Identify pages with video content.
2. `Glob` for `**/video-sitemap.xml`, `**/sitemap-video.xml`, or sitemap entries with `<video:video>` elements.
3. If video content exists but no video sitemap → finding.

**Crawl mode, required tool calls:**

1. `Fetch` `/sitemap.xml`. Parse for `<video:video>` elements (xmlns: video).
2. Or fetch `/sitemap-video.xml` separately.
3. Sample video pages, confirm they have VideoObject schema (Cat 38), different but related.

### Forbidden claims

- "The site probably has video without a video sitemap." Confirm video presence + sitemap absence.

### Detection

Source: `<video>` elements, YouTube iframe embeds, Vimeo embeds, Wistia embeds.

Sitemap: video-specific entries with `xmlns:video="http://www.google.com/schemas/sitemap-video/1.1"`.

### What to Search For

- `<video`
- `youtube.com/embed/` or `youtube-nocookie.com/embed/`
- `vimeo.com/`, `player.vimeo.com/`
- `wistia.net/embed/`
- `<video:video>` in sitemap XML

### Actually Hurts SEO

- **Video content present, no video sitemap entries**.
  Evidence required: pages with video + sitemap that lacks `<video:video>` entries.
- **Video sitemap with broken video URLs / thumbnails**.
  Evidence required: sitemap entries + fetched video URLs returning 404.
- **VideoObject schema present but no video sitemap** (works partially; sitemap helps discovery).

### NOT a Problem

- Sites with no video content. Skip the category.
- Sites with only embedded YouTube videos (YouTube handles its own discovery). Sitemap optional.
- Sites with self-hosted video on a homepage hero (single video). Schema is enough.

### Context Check

1. Does the site have native video content (not third-party embeds)? More valuable to declare in sitemap.
2. Is the video the primary content (a video tutorial site)? Critical for discovery.
3. Are videos behind paywall / login? Don't include in public sitemap.

### Reference

Google on video sitemaps: https://developers.google.com/search/docs/crawling-indexing/sitemaps/video-sitemaps

**Severity tagging:**
- Native video content with no sitemap → Medium.
- Embedded video site with no sitemap → Low (third-party handles it).
- Video sitemap with broken URLs → High.

**Fix voice:** `analytics-engineer` (primary) | `solutions-architect` (backup).

Read `souls/analytics-engineer.json` before writing the Fix. AnalyticsEng voice for "if you want it discovered, declare it explicitly."

Worked fix example:

> Videos that aren't in a sitemap rely on Google finding them through page crawls. That's slow and inconsistent. A video sitemap entry tells Google the video exists, where the player is, what the thumbnail is, and what the duration is, directly.
>
> ```xml
> <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
>         xmlns:video="http://www.google.com/schemas/sitemap-video/1.1">
>   <url>
>     <loc>https://example.com/tutorials/snitch-quickstart</loc>
>     <video:video>
>       <video:thumbnail_loc>https://example.com/thumbs/quickstart.jpg</video:thumbnail_loc>
>       <video:title>Snitch Quickstart in 60 seconds</video:title>
>       <video:description>Run your first audit on a Next.js site.</video:description>
>       <video:content_loc>https://example.com/videos/quickstart.mp4</video:content_loc>
>       <video:duration>62</video:duration>
>     </video:video>
>   </url>
> </urlset>
> ```
>
> Pair this with VideoObject schema on the video page itself (Cat 38). Sitemap declares existence; schema describes the video for rich results. Both, not either.
