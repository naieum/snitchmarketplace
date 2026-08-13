# Setup — Structured data (JSON-LD)

Walkthrough for `setup structured-data`. Goal: ship validated Schema.org JSON-LD for Organization, WebSite, BreadcrumbList, plus vertical-specific types.

## Pre-checks

1. **Run `bash ads-ready.sh state site <url> structured-data`.** Reports detected JSON-LD types.
2. **Confirm vertical:** ecommerce, SaaS, marketing, blog, local services. Each maps to different schema.
3. **Gather org details:** legal name, URL, logo URL (1:1 + transparent ideally), founders, social profile URLs (LinkedIn, X, Facebook, Instagram, YouTube, GitHub).

## Steps

### 1. Identify vertical-specific types (manual)

Per `07-structured-data.md`:

| Vertical | Required types |
|---|---|
| Ecommerce | Organization, WebSite, Product, Offer, AggregateRating, MerchantReturnPolicy, OfferShippingDetails, BreadcrumbList |
| SaaS | Organization, WebSite, SoftwareApplication, FAQPage, BreadcrumbList |
| Marketing | Organization, WebSite, Service or ProfessionalService, FAQPage, BreadcrumbList |
| Blog / News | Organization, WebSite, BlogPosting / NewsArticle / Article, Person (author), BreadcrumbList |
| Local services | LocalBusiness (subtype), GeoCoordinates, OpeningHoursSpecification |

### 2. Apply base schemas (auto)

```bash
bash ads-ready.sh fix structured-data
```

The apply step:
- Reads `templates/structured-data/{organization,website,breadcrumb}.starter.json`.
- Substitutes `{{PLACEHOLDER}}` from user-supplied org details.
- Emits `=== FILE/DIFF/CONTENT ===` targeting host's root layout/shell.

For Next.js, JSON-LD goes in `app/layout.tsx` as `<script type="application/ld+json">`. For Astro, in `src/layouts/Layout.astro`. For SvelteKit, in `src/app.html` (or per-page via `<svelte:head>`). For WordPress, in `header.php` or via Yoast SEO Premium.

### 3. Apply vertical-specific schemas (auto)

For per-product pages (ecommerce):
```bash
bash ads-ready.sh fix structured-data --type product
```

For per-article pages (blog):
```bash
bash ads-ready.sh fix structured-data --type article
```

For FAQ sections:
```bash
bash ads-ready.sh fix structured-data --type faq
```

User fills real product / article / FAQ data via build-time interpolation (CMS bindings, MDX frontmatter, React component props).

### 4. Validate (external-tool)

| Tool | URL | What it checks |
|---|---|---|
| Google Rich Results Test | https://search.google.com/test/rich-results | Eligibility for Google rich results |
| Schema.org Validator | https://validator.schema.org/ | Type / property correctness |
| Search Console → Enhancements | https://search.google.com/search-console | Per-type errors + warnings |

Resolve every error. Warnings: resolve high-value ones (missing image, missing aggregateRating).

### 5. Re-run state site (auto)

```bash
bash ads-ready.sh state site <url> structured-data
```

Digest should report all expected types under `structured_data_types`.

## Linked-data graph

Use `@id` to link entities across pages:

```json
{
  "@context": "https://schema.org",
  "@graph": [
    { "@type": "Organization", "@id": "https://example.com/#org", "name": "..." },
    { "@type": "WebSite", "@id": "https://example.com/#site", "publisher": { "@id": "https://example.com/#org" } }
  ]
}
```

## Common mistakes

- Hand-crafted JSON-LD that doesn't validate.
- Multiple Organization schemas on the same page.
- Wrong @type case (Schema.org is case-sensitive).
- Stale prices in Product schema.
- Generic `name`/`description`.
- Missing `priceValidUntil`.

## See also

- `07-structured-data.md` — full reference.
- `templates/structured-data/*.starter.json` — drop-in starters.
- Schema.org: https://schema.org/
- Google: https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data
