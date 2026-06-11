# Standards Table — Schema.org type catalog + SEO impact alignment

Each finding can carry a `Schema.org type` tag and an `SEO Impact` tier. This table is the lookup; categories reference it instead of restating the rules.

## Schema.org type → SEO impact ceiling

When a finding maps to a schema.org type, its SEO impact ceiling is set by what rich result that type unlocks (or fails to unlock) on Google. Schema misses can't take you down (the page still ranks) but they cap your CTR.

| Schema.org type | Rich-result eligibility | SEO impact ceiling for missing/broken |
|---|---|---|
| `Article` / `NewsArticle` / `BlogPosting` | Top stories, Article rich result, Discover surface | High — costs you Discover/news traffic and rich-result CTR |
| `Product` + `Offer` | Product snippet (price, availability, rating) | Critical for e-commerce — biggest CTR lift Google offers |
| `Product` + `AggregateRating` | Star rating in SERP | High — direct CTR lift |
| `BreadcrumbList` | Breadcrumb path replaces URL in SERP | Medium — better SERP appearance, modest CTR lift |
| `FAQPage` (Q&A pairs) | FAQ accordion in SERP | Was High pre-2023; now Medium (Google reduced surface area) |
| `HowTo` | None — Google removed the HowTo rich result entirely (Sept 2023) | Low / informational — no rich result exists; only minor content-understanding / AI-search value |
| `Organization` (+ logo, sameAs, ContactPoint) | Knowledge panel, brand SERP | Medium-High for brand searches |
| `WebSite` (+ SearchAction) | None — Google retired the Sitelinks Searchbox (Nov 2024); `SearchAction` is now inert | Not a finding — don't flag missing `SearchAction` |
| `VideoObject` | Video rich result, indexed in Google Video | High for video-heavy pages |
| `Recipe` | Recipe rich result (rating, time, calories) | Critical for recipe sites |
| `Event` | Event listing in SERP | Critical for ticket/venue sites |
| `LocalBusiness` | Local pack, business profile linking | Critical for local-intent businesses |
| `JobPosting` | Google for Jobs surface | Critical for job boards |
| `Course` | Course listing in SERP | Medium |
| `SoftwareApplication` | App rating + price snippet | Medium |
| `Person` (author) | Author entity association (E-E-A-T) | Medium-High for YMYL content; Medium elsewhere |
| `Review` / `AggregateRating` | Star rating in SERP across Product/SoftwareApp/LocalBusiness/Recipe | High when honest; Critical (manual-action risk) when faked or unattributed |

Findings that flag schema as **invalid** (wrong required field, wrong type) are higher impact than findings that flag schema as **missing** (eligibility was never sought) — invalid schema can demote the page.

## SEO Impact tiers (tagging rule for findings)

| Tier | Definition | Examples |
|---|---|---|
| **Critical** | Page or site is being actively excluded from indexing OR a paying-customer surface is broken. | Robots.txt blocks the homepage. `noindex` on a primary commercial route. Broken canonical pointing to a 404. Sitemap returns 5xx. Schema with required field missing on a Product page. |
| **High** | Real ranking / CTR loss in measurable terms. The fix has a known positive effect. | Missing canonical on a route with paginated/utm duplicates. Title tag missing. Schema for the page type missing entirely. Broken internal links pointing to important pages. Massive render-blocking JS. |
| **Medium** | The fix is good practice and incrementally helps; the impact is modest or hard to attribute. | Sub-optimal alt text. Missing `width`/`height` causing CLS. Footer link spam. Sub-optimal heading hierarchy on a single page. Anchor text drift. |
| **Low** | Polish. Won't move the needle alone, but a tidy site outranks a sloppy one over time. | Title 5 chars over recommended length. Meta description present but generic. One image without lazy-loading on a long page. |

## Tagging rule

Every finding gets:

1. An `SEO Impact` tier from the table above.
2. A `Schema.org type` only when the finding is about schema or about a page-type the type covers (e.g., a missing alt on a product image is `Product` because it ladders into product visual results; a missing alt on a blog inline image isn't tagged with a type).

If a finding doesn't fit any schema.org type and isn't about a page type the catalog covers, omit the type tag. Don't force it.

## Anti-pattern (don't do this)

- Don't tag every Cat 25 (alt text) finding with `ImageObject` schema. The category is about the alt attribute; the schema type is irrelevant unless the user is also missing `ImageObject` JSON-LD intentionally for image search ranking.
- Don't escalate Medium → High because "Google said it matters once in a 2018 blog post". Use the table.
- Don't downgrade Critical → Medium because "the customer might know about it already". Critical is what it is.

## Reference: Google's own documentation

When in doubt about a schema type or rule, the canonical reference is Google's developer docs at https://developers.google.com/search/docs/appearance/structured-data plus the schema.org spec at https://schema.org. Cite the relevant page in the finding when the user is likely to push back ("why does this matter?").
