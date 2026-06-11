## CATEGORY 20: Broken internal links

A link from one page on your site to another that 404s. Each one bleeds: the user gives up, the crawler wastes a request, and the source page loses some of its trust signal (if you can't even link to your own pages correctly, why should Google trust your content?).

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Enumerate all internal link targets (same Grep + Read pass as Cat 19).
2. Enumerate all valid routes (same Glob as Cat 19).
3. For each link target: check if it resolves to a known route. Targets that don't resolve are broken.
4. Quote the source file:line + the broken target URL for each finding.

**Crawl mode, required tool calls:**

1. Crawl from the homepage to depth 3-5. For each page, extract internal links.
2. For each unique internal link: `Fetch` it. Quote response status.
3. Status 404, 410, or 5xx = broken. Quote source URL → broken target → status.

### Forbidden claims

- "The site probably has broken links." Show me the count + samples.
- "Some links may be stale after the recent redesign." Crawl and verify.
- "404s are likely happening." Either you found them or you didn't.

### Detection

#### Source mode

Static-analyze internal link targets against the route table. Be careful with:

- **Dynamic routes**: a link to `/blog/some-slug` resolves to the dynamic route file `[slug]`, but only if `some-slug` is a real post. Cross-reference with the actual data (read the posts collection / DB).
- **Hash links**: `/page#section` is "broken" if the page exists but `#section` doesn't (less critical; can flag as Low).
- **Locale-prefixed routes**: `/en/about` resolves only if the i18n setup includes that locale.

#### Crawl mode

Crawl + check each link. Note: crawl-mode finds broken links to external sites too, different category, but worth noting if found.

### What to Search For

- All internal `<a href>` and `<Link to>` patterns from Cat 19's enumeration.
- Sitemap entries that the route table doesn't produce.
- Old paths from migrations (e.g., `/v1/...` after migrating to `/v2/...`).

### Actually Hurts SEO

- **Internal link to a 404 page**.
  Evidence required: source page + line + broken target URL + 404 response.
- **Internal link to a redirect chain ending in 404** (cross-reference Cat 6).
  Evidence required: source + chain.
- **Sitemap-listed URL that 404s**.
  Evidence required: sitemap entry + fetched URL response.
- **Hash anchor that doesn't exist on target page** (`#section-name` with no matching `id`).
  Evidence required: link + the target page's quoted heading IDs (none matching).
- **Broken image link in content** (an image embedded inline that 404s).
  Evidence required: `<img src>` + fetched image status.
- **Internal link to a page with `noindex` AND no `canonical` to a real page**.
  Evidence required: link target + the target page's robots meta showing noindex.

### NOT a Problem

- External links that 404, different category (might be Cat 24-flavored, but generally not in scope).
- Hash links to pages with valid content (the hash adds anchor jump but missing it just means scroll-to-top, not broken).
- Links inside test fixtures / Storybook / dev-only routes.

### Context Check

1. Is the broken link in heavily-trafficked navigation (header / sidebar) or in deep content? Header-broken is critical; deep-content-broken is medium.
2. Is the target a recently-deleted page or a never-existed page? Recently-deleted: candidate for redirect (301). Never-existed: typo in source.
3. Is the broken link the result of a migration? Pattern: hundreds of `/blog/2023/...` links after blog moved to `/posts/`. Mass-redirect at the framework level.
4. Are the broken links primarily from MDX content vs component code? MDX broken links are content rot; component broken links are dev mistakes.
5. Does the framework have a build-time link-checker? Many static-site generators (Astro, Hugo, Eleventy) can fail builds on broken internal links.

### Reference

Google on broken links: https://developers.google.com/search/docs/crawling-indexing/http-network-errors

**Severity tagging:**
- Internal link to 404 in primary navigation → Critical.
- Internal link to 404 in body content → High.
- Sitemap URL 404s → Critical.
- Hash anchor missing → Low.
- Broken image link → High (UX + SEO).

**Fix voice:** `mike-monteiro` (primary) | `solutions-architect` (backup).

Read `souls/mike-monteiro.json` before writing the Fix. Mike's voice for "you're shipping links to nowhere. That's on you. Fix it." No softening, no excuses.

Worked fix example:

> Every broken link is a promise you broke. The user clicked because you said the page was there. The crawler followed because you told it to. Both got nothing.
>
> Walk the list. For each broken link:
>
> 1. Did the target ever exist? If yes, redirect the old path to wherever the content moved (301). If no (typo, deleted draft, never-shipped page), fix the link in source, change the href to the right target, or remove the link if there's no target.
> 2. Don't paper over it with a 404 page that says "Sorry, this content has moved." That's a lie too. The page didn't move; you broke the link.
>
> ```ts
> // Migration cleanup pattern: mass-redirect old paths
> // next.config.js
> module.exports = {
>   async redirects() {
>     return [
>       { source: '/v1/:path*', destination: '/v2/:path*', permanent: true },
>     ];
>   },
> };
> ```
>
> Then add a CI step that runs a link-checker against built output and fails the build if any internal link 404s. The first broken link from now on doesn't ship.
