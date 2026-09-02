## CATEGORY 7: Pagination (per-page canonical)

Paginated listings (blog index, product collection, search results) need careful canonical handling. Google deprecated `rel="prev"` / `rel="next"` in 2019, the modern guidance is each paginated page declares its own self-canonical and is independently indexable. The legacy advice ("canonical all pages to page 1") is now wrong and actively harmful.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` for paginated listing routes: `**/page/[page]`, `**/blog/[page]`, `**/products/[page]`, OR routes with `?page=`, `?p=`, `?offset=` query params.
2. `Read` each paginated route's `head()` / `metadata` block and quote the canonical declaration.
3. Cross-reference with Cat 3 (canonical) findings, pagination pages with canonical pointing at page 1 is the legacy anti-pattern, flag explicitly.
4. `Grep` for `rel="prev"`, `rel="next"`, `rel='prev'`, `rel='next'`, these are now deprecated; Google ignores them. Not a critical issue, but worth noting in the report.

**Crawl mode, required tool calls:**

1. `Fetch` page 1 of a paginated listing AND page 2+ (`{listing-url}?page=2` or `{listing-url}/page/2`). Quote each page's canonical.
2. Pages 2+ with canonical pointing at page 1 = legacy anti-pattern. Quote both pages' canonicals to prove the divergence.
3. For pages 2+ with no canonical AND no alternative pagination signal: that's a finding, Google has to guess the URL is paginated, may demote.

### Forbidden claims

- "The site probably canonicalizes pagination wrong." Quote each page's canonical.
- "Pages 2+ may not be indexable." Check the meta robots on those pages and quote.
- "rel=prev/next probably aren't set." Grep + report present-or-absent.

### Detection

#### Source mode

Look for paginated route patterns:

- **Path-based pagination**: `/blog/page/2`, `/products/page/3`. The `[page]` param is part of the URL.
- **Query-based pagination**: `/blog?page=2`, `/products?p=3`. The page param is a query string.
- **Offset-based**: `/products?offset=20&limit=20`. Less common but appears in some headless setups.

For each, the canonical for page 2 should be `/blog/page/2` (self-referencing), NOT `/blog` (page 1).

Common WordPress patterns: `/page/2/` is auto-handled by WordPress; check theme + Yoast settings for canonical behavior.

#### Crawl mode

Fetch paginated URLs and quote canonicals.

### What to Search For

Source patterns:
- `params.page`, `params.p`, `searchParams.page`
- `rel="prev"`, `rel="next"` (deprecated, but worth flagging)
- `?page=`, `&page=`, `/page/` URL patterns
- Pagination components: `<Pagination>`, `<Paginator>`, `<PageNav>`

### Actually Hurts SEO

- **Page 2+ canonical points at page 1**.
  Evidence required: page 1's canonical AND page 2's canonical, both quoted, showing page 2 declares page 1 as its canonical.
- **Page 2+ has no canonical at all**.
  Evidence required: page 2's `<head>` quoted, showing absence of `<link rel="canonical">`.
- **Page 2+ is `noindex`'d**.
  Evidence required: page 2's meta robots quoted. (Some sites do this intentionally; only flag if pages 2+ contain content the site wants discoverable, e.g., older blog posts only reachable via pagination.)
- **Pagination URLs include session IDs / utm params in canonical**.
  Evidence required: the canonical href showing the param.
- **Infinite scroll without paginated URL fallback**.
  Evidence required: the listing page source showing infinite-scroll JS but no `?page=N` URL pattern. Infinite-scroll-only sites can lose indexability of paginated content; flag as Medium.

### NOT a Problem

- Page 1 declared as `/blog` AND `/blog/page/1` returning a 301 to `/blog`. Avoids the duplicate-content trap; good practice.
- Pages 2+ each self-canonicalizing. Modern correct pattern. Don't flag.
- `rel="prev"` / `rel="next"` declared but not relied on, Bing still uses them, Google ignores. Harmless.
- `/page/1/` URL existing AND canonical-redirected to base `/blog/`, clean.

### Context Check

1. Is the pagination indexable? Some sites intentionally `noindex` pages 2+. That's a content strategy choice; don't flag unless the site clearly wants the older content discoverable.
2. Is this an infinite-scroll page? Check for `IntersectionObserver` patterns in source. If the site uses infinite scroll, the SEO concern is whether paginated URLs exist AT ALL as a fallback, separate issue.
3. Is the pagination query-based or path-based? Both work; the canonical strategy is the same (self-canonical).
4. Are filter+sort params adding to the canonical? `?category=foo&sort=newest&page=2`, the canonical should NOT include the filter/sort params unless the filtered subset is intentionally a separate indexable surface.
5. WordPress: is Yoast handling pagination canonicals? Yoast has a setting; check it.

### Reference

Google's 2019 deprecation of rel=prev/next: https://developers.google.com/search/blog/2019/03/2019-03-21-no-prev-next

**Severity tagging:**
- Page 2+ canonical points at page 1 → High (this is the legacy anti-pattern; pages 2+ become invisible).
- Page 2+ has no canonical → Medium.
- Pagination URLs canonical with utm/session params → High.
- Infinite-scroll only with no paginated URL fallback → Medium.

**Fix voice:** `intrinsic-web-engineer` (primary) | `solutions-architect` (backup).

Read `souls/intrinsic-web-engineer.json` before writing the Fix. The intrinsic-web position applies here: each page in a paginated listing is its own resource, with its own URL, its own content, its own self-canonical. The structure should match the reality.

Worked fix example:

> Each page in the listing is its own page. Page 2 of `/blog` is `/blog/page/2`, not a duplicate of `/blog`. So the canonical on page 2 declares `/blog/page/2`, itself.
>
> ```tsx
> // app/blog/page/[page]/page.tsx (or equivalent)
> export async function generateMetadata({ params }) {
>   return {
>     alternates: {
>       canonical: `https://example.com/blog/page/${params.page}`,
>     },
>   };
> }
> ```
>
> Drop any `rel="prev"` / `rel="next"` declarations, they don't help and Google doesn't use them anymore. Drop the legacy "canonical all pages to page 1" pattern; that pattern was the right answer a decade ago and the wrong answer now. The intrinsic web rewards each resource being itself.
