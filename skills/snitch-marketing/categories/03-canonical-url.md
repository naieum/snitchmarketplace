## CATEGORY 3: Canonical URL

`<link rel="canonical">` tells search engines which URL is the authoritative version when the same content exists at multiple URLs (utm-tagged, paginated, AMP, mobile, locale-prefixed, http vs https, www vs apex, trailing-slash variants). Without it, Google picks one for you, often badly. With one pointing at the wrong URL, you cede ranking to whichever variant the canonical points at.

This is the single highest-leverage SEO tag after the title and meta description, and it's the most commonly broken on AI-built sites because frameworks don't auto-add it and the AI rarely thinks to.

### Detection

#### Source mode

Locate canonical declarations across the framework's metadata system:

- **Next.js App Router**: `metadata.alternates.canonical` in `layout.tsx` / `page.tsx` exports, or in `generateMetadata` returns.
  ```tsx
  export const metadata: Metadata = {
    alternates: { canonical: 'https://example.com/page' },
  };
  ```
- **Next.js Pages Router**: `<link rel="canonical" href="..." />` inside `<Head>` from `next/head`.
- **TanStack Start**: `head: () => ({ links: [{ rel: 'canonical', href: '...' }] })` per-route.
- **Astro**: `<link rel="canonical" href={Astro.url.href}>` or similar in the layout's `<head>` slot.
- **Remix**: `links` export with `{ rel: 'canonical', href: ... }`.
- **Nuxt**: `useHead({ link: [{ rel: 'canonical', href: ... }] })`.
- **WordPress**: Yoast / RankMath emit canonical via filters; check `wp_head` source rendering OR plugin settings. Theme manual emission via `<link rel="canonical" href="<?php echo esc_url(get_permalink()); ?>" />`.
- **Static HTML**: literal `<link rel="canonical">` in each page's `<head>`.

For each indexable route, verify:
1. A canonical is declared.
2. The canonical URL is absolute (https://...), not relative or path-only.
3. The canonical points at the page's own URL (self-referencing) unless intentionally pointing at a master version.

#### Crawl mode

Fetch the URL, parse `<head>`. Look for `<link rel="canonical" href="...">`.

Run on multiple URL variants if you have time / quota:
- `https://example.com/page` (canonical form)
- `https://example.com/page/` (trailing slash)
- `https://example.com/page?utm_source=email` (utm-tagged)
- `https://www.example.com/page` (www variant)
- `http://example.com/page` (http variant)

All variants should declare the SAME canonical URL pointing to the canonical form. If variants disagree or the canonical is missing on the variant, the variant becomes its own indexable URL → duplicate content.

### What to Search For

- `<link rel="canonical" href="..."` in any source file or rendered HTML
- `metadata.alternates.canonical` (Next.js App Router shape)
- `links: [{ rel: 'canonical' }` (TanStack Start, Remix, similar)
- `useHead` / `useSeoMeta` calls with link configs (Nuxt)
- Yoast `_yoast_wpseo_canonical` post meta values
- Any place a string ending in `/` and starting with `https://` is being passed as a `href` to a `<link>` element

### Actually Hurts SEO

- **No canonical declared at all on indexable routes.** Default behavior: Google picks one. Often picks a utm-tagged or paginated variant. Result: the canonical version of the page loses ranking to a non-canonical duplicate.
- **Canonical pointing at a different URL with the same content.** "Self-canonical" is the safe default. Pointing at another URL says "rank that one, not this one", only do this when the other URL is genuinely the master.
- **Canonical pointing at a 404 / 5xx.** Tells Google to rank a broken URL. Disastrous; the page loses ranking AND the broken target gets none either.
- **Canonical pointing at a `noindex` page.** Same outcome: the canonical target is excluded, so the entire content disappears from the index.
- **Mixed http/https canonicals.** Canonical declares `http://` but the served page is `https://`. Google treats them as different URLs; canonical is contradicting itself.
- **Canonical with utm parameters / session IDs in the href.** The whole point of canonical is to strip query params. A canonical containing `?utm_source=newsletter` defeats itself.
- **Duplicate canonicals on the same page.** Multiple `<link rel="canonical">` elements; Google picks one (usually the first), the others are ignored. Often a sign of two metadata sources fighting (theme + plugin in WordPress, layout + page metadata in Next.js).
- **Trailing slash inconsistency.** Page accessible at both `/page` and `/page/` but canonical declares only one, the other variant has no canonical pointing back, so it becomes a duplicate.

### NOT a Problem

- A canonical pointing at a genuinely-different master URL (e.g., a syndicated republish where the original is on another site). Intentional, not a bug.
- A canonical with no protocol (relative): `/page`, works in modern browsers / crawlers, though absolute is recommended. Flag as Low, not High.
- A canonical missing on a `noindex` page. The page isn't going to rank anyway; canonical is moot. Don't flag.
- A canonical missing on routes under `Disallow:` in robots.txt. Same logic.
- Pages with `<meta name="robots" content="canonical">` (rare custom directive), generally not standard, but if the site is using a special CMS with this convention, it may be intended.

### Context Check

1. Is this route actually indexable? Check robots.txt + meta robots + framework-level noindex flags before flagging missing canonical.
2. Does the framework auto-emit a canonical? Yoast does for WordPress (via `<link rel="canonical">` action on `wp_head`). Don't flag missing canonical in source if the plugin handles it; verify in crawl mode.
3. Is the page a paginated listing? Pages 2+ of a paginated listing should canonical to the page-specific URL (NOT to page 1, that's an old recommendation Google reversed in 2019; per-page canonicals are now correct).
4. Is this an AMP page? AMP pages should canonical to the non-AMP version, and the non-AMP version should declare `<link rel="amphtml" href="...">`.
5. Is the content syndicated from another source? Canonical pointing at the source is intentional. Flag as "review" not as "broken", the user may want it that way.
6. Is this an internationalized variant? Each locale should self-canonical, with `<link rel="alternate" hreflang>` linking the variants. Don't canonical en-US to en-GB; both should self-canonical and cross-link via hreflang (see Cat 50, 51).

### Reference

Google's documentation on canonicalization: https://developers.google.com/search/docs/crawling-indexing/canonicalization

Google's deprecation of `rel=prev/next` in favor of per-page canonicals (2019): https://developers.google.com/search/blog/2019/03/2019-03-21-no-prev-next

**Severity tagging:**
- Canonical points at a 404, 5xx, or noindex'd page → Critical.
- Canonical missing on indexable, ranking page → High.
- Canonical points at a different content URL (and it's not intentional syndication) → High.
- Canonical contains utm / session params → High.
- Mixed http/https canonical → High.
- Canonical relative instead of absolute → Low.
- Trailing-slash inconsistency without canonical fix → Medium.

**Fix voice:** `dieter-rams` (primary) | `solutions-architect` (backup, for multi-locale or syndication architecture cases where Rams's "less" doesn't fit).

Read `souls/dieter-rams.json` before writing the Fix. Rams's tenth principle, "as little design as possible", maps perfectly to canonical hygiene: one self-referencing canonical, absolute, declared once. The whole category is about removing competing URL signals so search engines have one truth to follow.

Worked fix example:

> One canonical, absolute, self-referencing. The route already has its OG URL declared in `<head>` and a sitemap entry pointing at it, three signals where one would do. Pick the canonical, drop the OG URL declaration (the canonical is the source of truth), and let the sitemap echo the canonical instead of competing with it.
>
> ```tsx
> head: () => ({
>   links: [{ rel: 'canonical', href: `https://snitchplugin.com${pathname}` }],
> })
> ```
>
> Then audit the rest of the route for stale duplicates: a stray `<link rel="canonical">` in the layout, an `og:url` that doesn't match, a sitemap entry with a different trailing slash. Less, but better.
