## CATEGORY 38: VideoObject schema

`VideoObject` schema makes video content eligible for video rich results in SERP, indexed in Google Video, and surfaceable in featured snippets. Required: `name`, `description`, `thumbnailUrl`, `uploadDate`. Recommended: `duration`, `contentUrl`, `embedUrl`, `interactionStatistic`.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify pages with video content (Cat 30 detection, `<video>`, YouTube/Vimeo embeds).
2. `Grep` for `"@type": "VideoObject"`. Quote.
3. For each video page: confirm schema. Check required fields.

**Crawl mode, required tool calls:**

1. `Fetch` video page. Parse JSON-LD. Quote VideoObject blocks.
2. Verify thumbnailUrl resolves.

### Forbidden claims

- "Video pages may lack VideoObject schema." Confirm presence/absence.
- "Schema may be missing required fields." Parse and quote.

### Detection

Looking for `"@type": "VideoObject"` on pages with video content.

### What to Search For

- `"@type": "VideoObject"`
- `name`, `description`, `thumbnailUrl`, `uploadDate`
- `duration` (ISO 8601: PT2M30S = 2 min 30 sec)
- `contentUrl` (direct video file)
- `embedUrl` (player URL)

### Actually Hurts SEO

- **Video page with no VideoObject schema**.
  Evidence required: video element + missing schema.
- **VideoObject missing `thumbnailUrl`**.
  Evidence required: parsed schema.
- **`thumbnailUrl` 404s**.
  Evidence required: URL + fetch status.
- **`uploadDate` in future or invalid ISO format**.
  Evidence required: quoted date.
- **`duration` in non-ISO format** (`"2:30"` instead of `"PT2M30S"`).
  Evidence required: quoted duration.

### NOT a Problem

- Pages without video content.
- Embedded YouTube without local schema (YouTube provides its own indexing).

### Context Check

1. Is the video native or embedded? Embedded YouTube is mostly handled by YouTube; native video benefits more from schema.
2. Is there a transcript on the page? Adding `transcript` field to VideoObject helps further.
3. Is the duration accurate? Mismatched duration = inconsistent signal.

### Reference

Google on VideoObject: https://developers.google.com/search/docs/appearance/structured-data/video

Schema.org VideoObject: https://schema.org/VideoObject

**Severity tagging:**
- Native video page with no schema → High.
- Missing thumbnailUrl → Critical.
- Invalid uploadDate → High.
- Wrong duration format → Medium.

**Fix voice:** `sarah-drasner` (primary) | `analytics-engineer` (backup).

Read `souls/sarah-drasner.json` before writing the Fix. Sarah's animation/video chops: video deserves first-class metadata so it's discoverable as video, not just as a page that happens to contain a player.

Worked fix example:

> Every video page gets VideoObject schema describing the video as its own resource. Thumbnail, duration, upload date, all the things Google needs to index it as a video.
>
> ```tsx
> const videoSchema = {
>   '@context': 'https://schema.org',
>   '@type': 'VideoObject',
>   name: video.title,
>   description: video.description,
>   thumbnailUrl: [video.thumbnail],
>   uploadDate: video.uploadedAt,  // ISO 8601 like 2026-04-29
>   duration: `PT${Math.floor(video.durationSec / 60)}M${video.durationSec % 60}S`,
>   contentUrl: video.fileUrl,
>   embedUrl: video.playerUrl,
> };
> ```
>
> Pair with a video sitemap entry (Cat 30) for full discoverability. Both, not either.
