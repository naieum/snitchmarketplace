## CATEGORY 19: Internal link graph (orphan pages)

The internal link graph is how Google discovers your URLs and how it weights their importance. Pages with many internal links pointing at them rank higher; pages with zero internal links (orphans) often go uncrawled until they appear in a sitemap, and even then receive minimal link equity.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` route files + sitemap to enumerate every indexable page (set: ALL_ROUTES).
2. `Glob` content files (route components, MDX, layout). `Grep` for `<a href`, `<Link to=`, `to=`, `href=` patterns. Capture every internal link target (set: LINKED_ROUTES).
3. ORPHAN = ALL_ROUTES minus LINKED_ROUTES (excluding the homepage and pages reachable only from the sitemap).
4. For each orphan: quote its route file path + a confirmation (ran the grep, no inbound link found).

**Crawl mode, required tool calls:**

1. `Fetch` the sitemap, extract URL list (set: ALL_URLS).
2. Crawl from the homepage, depth-first up to `crawl-max-pages`. For each page fetched, extract internal links. Build the union (set: LINKED_URLS).
3. ORPHAN = ALL_URLS minus LINKED_URLS minus the homepage.
4. Quote each orphan URL.

### Forbidden claims

- "Many pages are probably orphans." Enumerate them.
- "The link graph is probably uneven." Quote the count distribution.
- "Some pages may be hard to discover." Same.

### Detection

#### Source mode

Build the graph from static analysis:
1. Enumerate routes (Glob).
2. Enumerate links (Grep + Read).
3. Each link's `href` / `to` value is an edge from the source route to the target route.
4. Compute in-degree per route. Routes with in-degree 0 (excluding homepage) are orphans.

For frameworks with dynamic routing (`/blog/[slug]`), be careful: a link to `/blog/foo` references the dynamic route AND the specific slug. The dynamic route is the route file; `/blog/foo` is one of many actual pages it produces. Both matter.

#### Crawl mode

Crawl the live site from the homepage. Note that infinite-scroll listings, modal-only links, and JS-only navigation may not be discoverable by a static crawler, note these limitations in the report.

### What to Search For

Source patterns:
- `<a href=`
- `<Link to=`
- `<Link href=` (Next.js)
- `<NavLink to=` (TanStack)
- `to:` (in route configs)
- `href:` (in metadata link configs)

### Actually Hurts SEO

- **Orphan pages: routes that exist, are indexable, are in the sitemap, but no other page links to them**.
  Evidence required: the route + the (empty) Grep results showing no inbound links.
- **Important pages with very few inbound links** (e.g., the pricing page with only one link, from the homepage).
  Evidence required: in-degree count + sample of pages that link to the homepage but not to pricing.
- **Important pages buried >3 clicks from the homepage**.
  Evidence required: shortest path from homepage to the page, counted in clicks.
- **Heavy reliance on the footer for important links** (every important page is linked only from the footer).
  Evidence required: in-degree count + which sections those inbound links come from (footer-only is the finding).
- **Broken navigation patterns** (a "Resources" menu that links to 12 pages, but 4 of them are orphans because the menu only renders on certain page types).
  Evidence required: which pages render the menu, which pages don't, which orphans result.

### NOT a Problem

- An admin / dashboard page that's not in the sitemap and not indexable. Orphan by design.
- A landing page reachable only from a paid ad campaign. Orphan in the internal link sense; reachable in practice.
- A blog post deliberately unlinked from the index (e.g., a draft accidentally published). Find the draft state and fix data, not the link.
- "Lost" pages from migrations that should 410 / redirect. The fix is removal, not adding links.

### Context Check

1. Is the orphan in the sitemap? If yes, Google can find it but it gets minimal link equity. Worth linking from a relevant index.
2. Is the orphan noindex'd? Doesn't matter; Google won't index regardless.
3. Is the orphan a recently-launched page that hasn't been added to navigation yet? Common pattern: ship the page, forget the link. Easy fix.
4. Are the in-degrees concentrated on a few pages (e.g., 80% of internal links point at the homepage)? That's a sign the rest of the site is starved. Spread the equity.
5. Is the navigation primarily JS-rendered without static fallbacks? Crawlers may not see those links; SSR the navigation.

### Reference

Google on internal linking: https://developers.google.com/search/docs/fundamentals/seo-starter-guide#promote-your-website

**Severity tagging:**
- Indexable orphan page (in sitemap) → Medium per page.
- Important page with in-degree <3 → Medium.
- Page >4 clicks from homepage → Medium.
- Footer-only-linked critical page → Medium.

**Fix voice:** `jen-simmons` (primary) | `solutions-architect` (backup).

Read `souls/jen-simmons.json` before writing the Fix. Site architecture is intentional structure; links are how the structure becomes navigable.

Worked fix example:

> The site has 47 indexable pages. 12 are orphans, they exist, the sitemap declares them, no other page on the site links to them. They might as well not exist; Google sees them with no signal of their importance.
>
> Walk the orphan list. For each: ask what other page would naturally point at it.
>
> - Blog post about CVE-2026-3854 → linked from the blog index, the changelog v7.5.0 entry, and the security docs page. Three inbound links, contextual, none forced.
> - Pricing page reachable only from the top nav → add an in-content link from the homepage hero, from the docs index, and from each product page's "what's included" section.
>
> The link goes where the user would expect to find it. Internal linking is not link-stuffing; it's making the structure of the site match the structure of the user's questions.
