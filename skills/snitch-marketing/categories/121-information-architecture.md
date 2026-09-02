## CATEGORY 121: Information architecture & site structure

The whole-site structure view. Cat 19 finds orphan pages, Cat 20 finds broken
links, Cat 95 audits programmatic templates, Cat 22 and Cat 32's BreadcrumbList row
cover breadcrumbs. This
category audits how the site is **organized**: can a user (and a crawler) get from
the homepage to any money page in a few clicks, do related pages cluster into
hubs, and does faceted navigation create crawl traps? A site can pass every
per-page check and still bury its best pages five clicks deep or spray a million
filter-combination URLs into the index.

### Pre-flight: relevance check

Skip with reason `not applicable` for a single-page site or a <10-page brochure
site where structure is trivially flat-and-shallow. Otherwise: required for any
site with a content library, catalog, docs, or >~25 pages.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Map the route tree (route files, nav components, sitemap) into a hierarchy.
2. Compute **click-depth** from the homepage to each key page (pricing, signup,
   top product/category, top content). Quote the click path.
3. Inspect navigation: primary nav breadth, dropdown depth, footer structure,
   internal-link patterns between related pages (hub-and-spoke vs flat list).
4. Look for faceted/filter URL generation (query params, `/filter/`, `/tag/`
   permutations) and whether those URLs are canonicalized / `noindex` / robots-blocked.

**Crawl mode, required tool calls:**

1. Crawl from the homepage; record the **shortest click-depth** to each key page.
2. Capture the nav + breadcrumb structure as rendered.
3. Probe faceted nav: combine 2-3 filters and check whether each combination yields
   a distinct crawlable, indexable URL (a crawl trap) or is parameter-handled.

### Forbidden claims

- "The site structure is probably too deep." Quote the actual click path + depth count.
- "Navigation may be confusing." Quote the nav structure and the specific dead-end or depth.
- "There might be a crawl trap." Show the faceted URL pattern and its index/canonical status.

### Detection

Route/nav tree reconstruction + click-depth measurement + faceted-URL probing.

### What to Search For

- Key pages (pricing, signup, top category/product, cornerstone content) at **>3
  clicks** from the homepage
- Flat dump: 50+ pages all at one level with no category/hub grouping
- No topic-cluster / hub-and-spoke structure on a content library (posts don't link
  to a pillar; pillar doesn't link to posts)
- Faceted nav (`?color=&size=&sort=`, `/tag/x/tag/y`) generating combinatorial
  indexable URLs with no canonical/`noindex`/robots handling (crawl trap, crawl-budget waste)
- Orphaned sections reachable only from the sitemap, not from nav/links (cross-ref Cat 19)
- Inconsistent or missing breadcrumbs on deep pages (cross-ref Cat 22/33)
- Primary nav with 8+ top-level items (no prioritization; Hick's Law, `mental-models.md`)
- URL taxonomy that doesn't reflect hierarchy (`/p?id=4821` vs `/category/product`)

### Actually Hurts the Marketing Surface

- **Key conversion page buried >3 clicks deep.** Depth dilutes link equity and
  buries the page for users and crawlers.
  Evidence required: the click path quoted + depth count.
- **No hub-and-spoke on a content library.** Related content doesn't cluster, so
  topical authority and internal link flow are weak (cross-ref Cat 57, 70, 82).
  Evidence required: a pillar/cluster that should exist + the missing links.
- **Faceted-nav crawl trap.** Filter combinations generate unbounded indexable URLs,
  wasting crawl budget and risking thin/duplicate indexation.
  Evidence required: the URL pattern + its index/canonical/robots status.
- **Flat architecture with no hierarchy** on a large site (everything at root,
  no categories).
  Evidence required: the route inventory showing no grouping.
- **Inconsistent breadcrumbs** across deep sections.
  Evidence required: pages with vs without breadcrumbs quoted.

### NOT a Problem

- A deliberately flat site that's genuinely small (a depth of 2 is fine at 15 pages).
- Faceted nav that IS parameter-handled (canonical to the base category, or
  `noindex,follow`, or robots-disallowed) — that's the correct fix, not a finding.
- A deep path to a low-value page (archival, legal) — depth matters for money pages,
  not every page.
- Single-pillar sites where one hub is the whole structure.

### Context Check

1. Which are the money pages? Depth matters most for those (use `.snitch-marketing-context.md` primary conversion).
2. Is the site big enough that hierarchy matters, or is flat correct here?
3. Is faceted nav intended to be indexable (rare) or parameter-handled (usual)?
4. Does the URL taxonomy match the nav hierarchy? Mismatches confuse users and crawlers.
5. Apply Hick's Law to nav breadth (cross-ref `references/mental-models.md`).

### Reference

Site structure / topic clusters (Nielsen Norman): https://www.nngroup.com/articles/information-architecture-study-guide/

Faceted navigation & crawl budget (Google Search Central): https://developers.google.com/search/docs/crawling-indexing/crawl-budget-large-site-management

**Severity tagging:**
- Faceted-nav crawl trap (indexable combinatorial URLs) → Critical (crawl-budget + index bloat).
- Key conversion page >3 clicks deep → High.
- No hub-and-spoke on a content library → High.
- Flat architecture on a large site → Medium.
- Inconsistent breadcrumbs / over-broad nav → Medium.

**Fix voice:** `systems-designer` (primary) | `solutions-architect` (backup).

Read `souls/systems-designer.json` before writing the Fix.

Worked fix example:

> Structure is navigation plus crawlability. Two moves.
>
> 1. **Flatten the path to money pages.** Pricing and signup should be one click from
> the homepage and present in the primary nav. If pricing is at `/company/plans/details`
> three clicks deep, promote it: `/pricing`, in the top nav, linked from the hero.
> Verify: crawl from home; pricing is reachable in 1 click.
>
> 2. **Cluster the content; cage the facets.** Group the 40 orphaned blog posts under
> 4-6 pillar hubs; each pillar links to its posts and each post links back. For the
> filter URLs (`?color=&size=`), pick one: canonical them to the base category, or
> `noindex,follow`, or disallow the param in robots.txt. Verify: Search Console
> "Indexed" count stops climbing on filter URLs over ~2-4 weeks; pillar pages start
> ranking for the cluster head term.
