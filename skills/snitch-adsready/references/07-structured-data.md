# 07 — Structured data (Schema.org JSON-LD)

Read when adding JSON-LD or auditing why rich results aren't appearing. The `apply_structured_data` fix uses `templates/structured-data/*.starter.json` and substitutes `{{PLACEHOLDER}}` values.

## Why structured data matters for ads

1. **AI search readiness.** AI Overviews + ChatGPT search + Perplexity rely on JSON-LD for entity extraction.
2. **Rich results in SERP.** Sitelinks, FAQ accordions, breadcrumbs, product price + reviews. Higher CTR.
3. **Knowledge Graph.** Organization schema + sameAs links populate Google Knowledge Panel.
4. **Quality signal.** Indirect effect on ad Quality Score for branded queries.

## Canonical types every site should ship

| Type | Where | Why |
|---|---|---|
| Organization | site root (e.g., layout.tsx) | Brand entity; Knowledge Panel |
| WebSite | site root | sitelinks-search-box; AI navigation |
| BreadcrumbList | every page below root | Cleaner SERP titles; AI path extraction |

## Per-vertical types

| Vertical | Add | Notes |
|---|---|---|
| **Ecommerce** | Product, Offer, AggregateRating, Review, MerchantReturnPolicy, OfferShippingDetails | Google requires shipping + returns since June 2023 |
| **SaaS** | SoftwareApplication, FAQPage, Organization, WebSite | List supported OSes + price tier |
| **Marketing site** | Organization, WebSite, FAQPage, Service, ProfessionalService | Add `priceRange` + `areaServed` |
| **Blog / publication** | Article, NewsArticle, BlogPosting, Author (Person), Publisher (Organization) | `BlogPosting` for blog posts; `NewsArticle` only for journalism |
| **Local business** | LocalBusiness (subtypes), GeoCoordinates, OpeningHoursSpecification | Critical for "near me" |
| **Job board** | JobPosting | Google Jobs surfaces these directly |
| **Event** | Event, Place, Offer | Google Events |
| **Recipe** | Recipe, Nutrition, Review | Google Recipes |
| **HowTo** | HowTo (deprecated for desktop SERP, used in AI Overviews) | Worth shipping |
| **Video** | VideoObject (thumbnailUrl, uploadDate, duration) | Required for video rich-result eligibility |

## Common mistakes

1. Hand-crafted JSON-LD that doesn't validate. Run through Rich Results Test + Schema.org Validator before deploy.
2. Multiple Organization schemas on same page. Pick one (root layout); reference elsewhere with `@id`.
3. Mixing Microdata + JSON-LD. JSON-LD is canonical now.
4. Stale prices in Product schema. Use a build-time generator from product DB.
5. Generic `name`/`description`. Concrete + specific wins.
6. No `priceValidUntil`. Google warns; rich result drops.
7. Wrong @type case. Schema.org is case-sensitive: `Product`, not `product`.

## Verification

| Tool | URL |
|---|---|
| Google Rich Results Test | https://search.google.com/test/rich-results |
| Schema.org Validator | https://validator.schema.org/ |
| Search Console → Enhancements | https://search.google.com/search-console |

## Linked-data graph

Use `@id` to link entities across pages so search engines (and LLMs) understand they refer to the same entity:

```json
{
  "@graph": [
    { "@type": "Organization", "@id": "https://example.com/#org", ... },
    { "@type": "WebSite",      "@id": "https://example.com/#site", "publisher": { "@id": "https://example.com/#org" } },
    { "@type": "Article",      "@id": "https://example.com/post/x", "publisher": { "@id": "https://example.com/#org" } }
  ]
}
```

## See also

- `17-llms-txt-and-ai-search.md` — AI Overviews use this schema.
- `references/setup/structured-data.md` — walkthrough.
- `templates/structured-data/*.starter.json` — drop-in starters.
- Schema.org: https://schema.org/
- Google: https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data
