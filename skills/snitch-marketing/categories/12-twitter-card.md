## CATEGORY 12: Twitter Card tags

`<meta name="twitter:*">` controls how the page renders on Twitter / X. Twitter mostly falls back to OG tags now, but the Twitter-specific tags (`twitter:card`, `twitter:site`, `twitter:creator`, `twitter:image`) provide finer control over the card type and attribution.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`, `twitter:site`, `twitter:creator`, `twitter:` (general). Quote each match.
2. For each indexable route: check whether the page has Twitter-specific tags OR relies on OG fallback. Both are valid; flag only when neither exists OR when the Twitter image is set badly.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Quote each `<meta name="twitter:*">` element.
2. For `twitter:image` findings: fetch the image, quote status + content-type.

### Forbidden claims

- "Twitter cards probably aren't set." Quote present-or-absent.
- "The card type may be wrong." Quote `twitter:card` value.
- "Most pages probably don't have twitter:site." Enumerate.

### Detection

#### Source mode

- **Next.js App Router**: `metadata.twitter: { card, title, description, images, site, creator }`.
- **Next.js Pages Router**: `<meta name="twitter:card" content="summary_large_image" />` inside `<Head>`.
- **TanStack Start**: `head: () => ({ meta: [{ name: 'twitter:card', content: '...' }, ...] })`.
- **Astro**: `<meta name="twitter:card" content={...}>`.
- **WordPress**: Yoast / RankMath plugin output.

#### Crawl mode

`Fetch`. Look for `<meta name="twitter:*">` in `<head>`. Quote.

### What to Search For

- `twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`, `twitter:site`, `twitter:creator`
- `name="twitter:` (HTML attribute pattern)
- `twitter:` (Next.js shape)

### Actually Hurts SEO

- **No `twitter:card` AND no OG fallback**.
  Evidence required: both sets quoted-absent. Twitter renders no preview at all.
- **`twitter:card` set but `twitter:image` missing AND no `og:image` fallback**.
  Evidence required: card type quoted + missing image proof.
- **`twitter:image` URL relative or 404s**.
  Evidence required: tag value + fetched image status.
- **`twitter:card` set to `summary` when `summary_large_image` would render better**.
  Evidence required: tag value (this is a UX downgrade, `summary` is small thumbnail; `summary_large_image` is the full-bleed card).
- **`twitter:site` missing** (no attribution to your brand handle on Twitter shares).
  Evidence required: tag absent.

### NOT a Problem

- Twitter tags missing IF OG tags are present (Twitter falls back gracefully).
- `twitter:player` missing (only relevant for video/audio embed cards).
- `twitter:creator` missing on non-author pages.
- `twitter:dnt` missing (do-not-track signaling, niche).

### Context Check

1. Are OG tags present? If yes, missing Twitter-specific tags is Low (fallback works).
2. Is the page meant for shares? Same logic as OG.
3. Is the brand on Twitter? Set `twitter:site` to the handle even if you don't post often, attribution flows back when others share you.
4. Is the image dimension >1200x630? `summary_large_image` requires reasonable dimensions; use `summary` if your image is square / smaller.

### Reference

Twitter Cards documentation: https://developer.twitter.com/en/docs/twitter-for-websites/cards/overview/abouts-cards

Twitter Card Validator: https://cards-dev.twitter.com/validator (deprecated; render preview via Twitter compose now)

**Severity tagging:**
- No twitter:card AND no OG fallback → High.
- twitter:image 404 or relative → High.
- twitter:card = summary when summary_large_image suits → Medium.
- Missing twitter:site (no brand attribution) → Low.

**Fix voice:** `brand-surface-designer` (primary) | `expressive-typographer` (backup).

Read `souls/brand-surface-designer.json` before writing the Fix. Same brand-surface logic as Cat 11; Twitter is just another canvas where the brand appears.

Worked fix example:

> Set `summary_large_image` on every page that has a hero image worth showing. Set `twitter:site` once globally to your brand handle. Per-page, override `twitter:title` and `twitter:description` only when they should differ from OG; otherwise let Twitter fall back to OG.
>
> ```tsx
> // Global default in root layout
> twitter: {
>   card: 'summary_large_image',
>   site: '@example',
> }
>
> // Per-page override (often unnecessary if OG is set)
> twitter: {
>   creator: '@author-handle',
> }
> ```
>
> Verify with Twitter's compose flow, paste the URL, see what renders. The first render Twitter does is cached; if it's wrong, fix the tags and force a re-scrape via the URL inspector.
