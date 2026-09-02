# Migration / Replatform Pre-flight (on-demand lane, outside the numbered audit flow)

The single largest source of self-inflicted organic-traffic loss is a poorly executed migration. Replatforming (WordPress → Headless), framework changes (Pages Router → App Router; Gatsby → Astro), domain changes, URL structure changes, design system rewrites, CMS changes — every one of these has lost millions of dollars of organic traffic for brands that didn't pre-flight the SEO impact.

This reference is the pre-flight checklist + post-launch diagnostic chain. Pair with `traffic-diagnosis.md` for post-migration regression analysis.

## When to use this workflow

Run before AND after any of:

- Domain change (`oldbrand.com` → `newbrand.com`)
- URL structure change (`/blog/post-slug` → `/blog/2026/post-slug`)
- Replatform (WordPress → Headless; Shopify → Custom; Webflow → Next.js)
- Framework change (Pages Router → App Router; Gatsby → Astro; Next.js → TanStack Start)
- Major design system rewrite touching head/metadata generation
- CMS change (WordPress → Sanity; Contentful → Strapi)
- Hosting / CDN change that affects redirects / robots.txt / sitemap

## When NOT to use

Routine deploys, content updates, A/B tests, copy changes. Migration here means structural change to URLs, rendering, head content, or origin.

## Pre-flight (BEFORE the migration ships)

Run this checklist on the staging / preview deploy at minimum 2 weeks before production cutover.

### A. URL inventory + redirect map

1. **Export current URL inventory**: every indexable URL on the production site. Sources, in order: `sitemap.xml` (Cat 2), Google Search Console "Pages" report (last 90 days), Ahrefs/Semrush export, server log analysis if available.
2. **Cross-reference with new URL structure**: for each old URL, what's the new URL? (Same path; renamed; merged; deleted.)
3. **Build a redirect map**: every old URL → new URL with 301 (permanent). 302 (temporary) is for genuine temporary redirects only; 301 is the migration default.
4. **Test the redirect map** on staging: `curl -sI https://staging.example.com/old-path` returns 301 → new path. Quote a sample of 20 redirects with their actual response codes.
5. **Watch for redirect chains** (Cat 6): old → middle → new is two hops; collapse to one. Each hop loses link equity.

### B. Indexability + crawl signals

1. **Confirm `robots.txt` on staging matches production** (no leftover `Disallow: /` from the staging environment).
2. **Confirm canonicals point at production URLs** (Cat 3) — staging canonicals pointing at `staging.example.com` block the migration entirely.
3. **Confirm sitemap regenerated** (Cat 2) with new URL structure.
4. **Confirm `noindex` not accidentally shipped to important pages** (Cat 4) — common bug when a "draft" flag stays set in CMS migration.

### C. Metadata + structured data continuity

1. **Title, description, canonical** (Cats 9, 10, 3) — confirm each migrated URL retains its title + description (or has a deliberate, well-considered new one).
2. **Open Graph + Twitter Card** (Cats 11, 12) — confirm preserved.
3. **Schema.org markup** (Cats 31, 32, 94) — confirm each schema type continues to render. Common failure: the new framework's head builder doesn't include the JSON-LD that the old one did.
4. **hreflang** (Cat 50) — confirm hreflang continuity for international.

### D. Performance baseline

1. **Capture pre-migration baselines**: Lighthouse score, Core Web Vitals from CrUX (`https://pagespeed.web.dev`), PageSpeed Insights LCP/INP/CLS for top 5 pages.
2. **Test post-migration on staging**: confirm not regressed. New framework's bundle size + font loading + render strategy can flip Core Web Vitals.

### E. Rendering verification

1. **Confirm critical content is server-side rendered** (not client-side post-hydration only) — Cat 4 cross-ref.
2. **Test as Googlebot**: `curl -A "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" https://staging.example.com/key-page` — quote the response. The HTML returned should contain the key content, headings, canonical, schema.
3. **JS-rendering check**: if the framework is hydration-heavy, confirm Google's URL Inspection tool (in GSC) renders the staged URLs correctly. Quote the rendered HTML preview.

### F. Internal links + sitemap

1. **Update internal links** to point at new URLs (avoid hops: prefer direct links to canonical URLs over relying on redirects).
2. **Confirm navigation, footer, related-posts widgets** all reference new URLs.
3. **Sitemap submitted to GSC** for the new URLs immediately after launch.

## Cutover (the day of migration)

1. **Deploy staging → production with redirect map active.**
2. **Within 1 hour**: run `curl -sI` against 30+ old URLs. Confirm each returns 301 to new URL.
3. **Within 4 hours**: submit new sitemap in GSC. Manually request indexing for top 10 highest-value URLs via "URL Inspection."
4. **Within 24 hours**: monitor GSC for crawl errors. Watch for spikes in 404 / 5xx in the GSC Coverage report.
5. **Within 72 hours**: review the GSC "Coverage" report — old URLs should be moving from "Indexed" to "Page with redirect"; new URLs should appear as "Indexed."

## Post-launch monitoring (weeks 1-12)

Migrations dip traffic for 2-6 weeks even when done well. The monitoring is to distinguish a normal dip from a problem.

### Daily for 2 weeks

- **GSC clicks + impressions** vs prior period
- **GSC Coverage**: any new "Excluded" reasons appearing?
- **Top 50 ranked queries**: still ranking? Position deltas?
- **Server logs**: 404 rate; spike of redirect chains?

### Weekly for 12 weeks

- **Organic sessions** vs prior period (analytics)
- **Position trends** for top 100 query targets
- **Backlink redirect verification**: external backlinks (per Ahrefs / Semrush) are pointing at old URLs that now 301 to new URLs. Confirm those redirects work; spot-check 10-20.
- **Competitor SERP positions**: if the brand is dropping, are competitors taking the slots?

## Failure modes — and which one you're hitting

When traffic drops post-migration, these are the most common causes in approximate frequency order. Use the `traffic-diagnosis.md` framework to narrow down.

| Symptom | Likely cause | Fix |
|---|---|---|
| Sharp drop in 24-72 hours after launch | Robots.txt / noindex shipped to important pages, or canonical pointing at staging | Audit robots.txt + canonical chain immediately |
| Drop in 7-14 days after launch | Redirect map incomplete; old URLs returning 404 instead of 301 | Cross-reference GSC's old URLs vs your redirect map; add missing redirects |
| Slow decay over 4-8 weeks | Internal link graph still references old URLs (creating redirect chains); content depth lost in migration | Update internal links to canonical destinations; restore lost content |
| Drop concentrated on one segment (mobile only / one country) | Framework regression on a specific render path (mobile-specific JS bug; locale-specific routing) | Re-test the affected segment in production |
| Slow recovery + position drop | Schema markup lost; Core Web Vitals regressed; rendering changed (SSR → CSR) | Audit schema (Cats 31, 32, 94); audit performance (Cats 39-44); audit rendering |

## Red flags during pre-flight (escalate before launch)

If any of these are TRUE on staging, do not launch yet — the migration will lose traffic.

- [ ] `robots.txt` blocks important paths
- [ ] `noindex` meta on indexable pages
- [ ] Canonicals point at staging or wrong production paths
- [ ] Critical content only renders post-hydration (Googlebot test fails)
- [ ] Schema.org markup absent on pages that previously had it
- [ ] Redirect map covers <90% of high-value old URLs
- [ ] Lighthouse / Core Web Vitals regressed >15% on top pages
- [ ] Top 100 queries can't find a content match in the new sitemap
- [ ] Sitemap missing or returns 404
- [ ] Internal links still reference old URL structure broadly

Each red flag is a launch-blocker. The cost of delaying a migration by 1-2 weeks to fix red flags is far less than the cost of a 30%+ traffic drop that takes 3-6 months to recover.

## Output template

Save migration audit to `MIGRATION_PREFLIGHT_REPORT.md` in the working directory:

```markdown
# Migration Pre-flight Report — {brand} — {date}

## Migration scope
- Type: {domain change / URL change / replatform / framework / CMS}
- Old: {old surface}
- New: {new surface}
- Target launch: {date}

## URL inventory
- Indexable URLs on production: {count}
- Mapped to new structure: {count}
- New URLs: {count}
- Mapped: {percent}

## Redirect map status
- 301 redirects defined: {count}
- Tested via curl: {count}
- Redirect chains detected: {count}

## Indexability + canonicals
- Robots.txt staging vs production: {match / mismatch}
- Canonicals point at production: {yes / no}
- Sitemap regenerated: {yes / no}
- Noindex on important pages: {none / some — list}

## Metadata + schema continuity
- Title preserved on top-50 pages: {yes / no}
- Description preserved: {yes / no}
- Schema preserved: {yes / no — schema types lost}
- OG / Twitter Card preserved: {yes / no}
- hreflang preserved (if applicable): {yes / no / N/A}

## Performance baseline
- Lighthouse score pre / post staging: {a / b}
- LCP top page pre / post: {a / b}
- INP top page pre / post: {a / b}
- CLS top page pre / post: {a / b}

## Rendering verification
- Server-side rendering of critical content: {yes / no}
- Googlebot user-agent test: {pass / fail per page}
- GSC URL Inspection on top pages: {tested / not tested}

## Red flags
{enumerated list of any of the 10 launch-blockers detected}

## Go / no-go recommendation
- Recommendation: {go / no-go}
- Reason: {one sentence}

## Post-launch monitoring plan
- Daily for 2 weeks: {metrics}
- Weekly for 12 weeks: {metrics}
- Owner: {name}
```

## Cross-references

- `traffic-diagnosis.md` — the diagnostic framework for post-launch regression
- Cat 1 (robots.txt), Cat 2 (sitemap), Cat 3 (canonical), Cat 4 (indexability), Cat 6 (redirect chains)
- Cat 9-14 (metadata), Cats 31, 32, 94 (schema)
- Cat 39-44 (performance baselines)
