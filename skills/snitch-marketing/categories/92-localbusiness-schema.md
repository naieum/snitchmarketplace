## CATEGORY 92: LocalBusiness schema

`LocalBusiness` (and its many subtypes, `Restaurant`, `Dentist`, `LegalService`, `AutoRepair`, `MedicalClinic`, etc.) powers Google's local pack, knowledge panel, and Maps integration. Distinct from Cat 79 (Local SEO + Google Business Profile): Cat 79 audits the off-site GBP listing; this category audits the on-site structured data that disambiguates the business entity for crawlers and feeds the knowledge panel.

### Pre-flight: relevance check

Skip this category with reason `not applicable` unless the site represents a business with a physical address, service area, or location-bound service. SaaS / pure-online businesses are not candidates.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify business-info pages (homepage; `/contact`; `/locations`; `/about`).
2. `Grep` for `"@type": "LocalBusiness"` (or any subtype). Quote each.
3. Parse the JSON. Check required: `name`, `address` (PostalAddress with `streetAddress`, `addressLocality`, `addressRegion`, `postalCode`, `addressCountry`). Strongly recommended: `telephone`, `url`, `image`, `priceRange`, `openingHoursSpecification`, `geo` (with `latitude`, `longitude`), `sameAs`.
4. Cross-reference NAP (name + address + phone) consistency between schema, visible page, footer, and the brand's GBP listing (Cat 79).

**Crawl mode, required tool calls:**

1. `Fetch` the homepage / contact page. Find JSON-LD blocks.
2. Quote the entire `LocalBusiness` object.
3. Check required + recommended fields. Quote any missing.
4. Compare to the visible NAP on the page.

### Forbidden claims

- "LocalBusiness schema is probably missing." Confirm the brand IS a local business AND parse.
- "NAP may not match." Quote schema NAP, visible NAP, and (if available) GBP NAP.

### Detection

Looking for `"@type": "LocalBusiness"` (or subtypes) on pages representing a local business entity.

### What to Search For

- `"@type": "LocalBusiness"` or any of the ~150 subtypes (`Restaurant`, `Dentist`, `Hotel`, `Bank`, `LegalService`, `MedicalClinic`, `AutoRepair`, etc.). **Use the most specific subtype that fits**.
- Required: `name`, `address` (PostalAddress with full structured fields)
- Strongly recommended: `telephone`, `url`, `image` (logo + photos), `priceRange` (`"$"` to `"$$$$"`), `openingHoursSpecification` (array of `OpeningHoursSpecification` with `dayOfWeek`, `opens`, `closes`), `geo` (latitude + longitude), `sameAs` (Yelp / TripAdvisor / Facebook / official social profiles), `aggregateRating` (only if backed by a visible review surface)
- For multi-location businesses: separate LocalBusiness schema per location, each on its own location page

### Actually Hurts the Marketing Surface

- **Local business with no LocalBusiness schema**.
  Evidence required: visible address on page + missing JSON-LD.
- **Generic `LocalBusiness` instead of a specific subtype** (`Dentist` / `Restaurant` / `LegalService` etc.). Specific subtypes earn richer SERP features.
  Evidence required: parsed `@type` + visible business category on page.
- **`address` as a single string instead of structured `PostalAddress`** (Google can't disambiguate components).
  Evidence required: parsed `address` value.
- **NAP inconsistency between schema and visible page** (different phone number or street address).
  Evidence required: both quoted with diff highlighted.
- **NAP inconsistency between schema and the brand's GBP listing** (Google penalizes NAP drift across the web).
  Evidence required: schema NAP + GBP NAP + diff.
- **`openingHoursSpecification` missing or stale** (knowledge panel cannot show hours; users see "hours unknown").
  Evidence required: parsed schema + visible hours on page.
- **`geo` coordinates missing** (Maps integration suffers).
  Evidence required: parsed schema.
- **Multiple locations modeled as one LocalBusiness with multiple addresses** (each location should have its own page + schema).
  Evidence required: page lists multiple locations + single schema block.
- **Faked `aggregateRating`**, same anti-pattern as other schema types.
  Evidence required: schema rating + missing visible review surface.

### NOT a Problem

- Service-area business (SAB) without a fixed address (mobile dog grooming, plumber, locksmith), use `areaServed` and omit `address` / use a less specific address; this is correct.
- Multi-location business with separate location pages, each with its own LocalBusiness schema, correct.
- A SaaS / pure-online brand without LocalBusiness schema, correct (use Organization instead per Cat 37).
- `aggregateRating` absent, better to omit than to fake.

### Context Check

1. Is the business actually local (physical address or geographic service area)?
2. Is the most specific subtype used? `Dentist` beats `LocalBusiness`.
3. Is the NAP consistent across schema + visible page + GBP + footer? NAP drift is one of the highest-cost local SEO mistakes.
4. Do `openingHoursSpecification` reflect current hours? Stale hours mislead customers and lower trust.
5. For multi-location: separate page + separate schema per location?

### Reference

Google's LocalBusiness documentation: https://developers.google.com/search/docs/appearance/structured-data/local-business

Schema.org LocalBusiness: https://schema.org/LocalBusiness

LocalBusiness subtypes: https://schema.org/docs/full.html#term_LocalBusiness

**Severity tagging:**
- Local business with no LocalBusiness schema → High.
- Generic `LocalBusiness` instead of specific subtype → Medium.
- `address` as string → High.
- NAP inconsistency (schema vs page) → Critical.
- NAP inconsistency (schema vs GBP) → Critical.
- `openingHoursSpecification` missing or stale → High.
- `geo` missing → Medium.
- Multi-location modeled as single business → High.
- Faked `aggregateRating` → Critical.

**Fix voice:** `solutions-architect` (primary) | `mike-monteiro` (backup).

Read `souls/solutions-architect.json` before writing the Fix.

Worked fix example:

> A local business has one canonical NAP, name, address, phone. The schema, the visible page, the footer, the Google Business Profile, the Yelp listing, all of them are projections of that single source of truth. When the projections drift, customers and crawlers see contradictory facts and trust evaporates.
>
> Treat NAP as configuration, not as content. One module, one truth, every surface reads from it.
>
> ```tsx
> // src/lib/business.ts, single source of truth
> export const BUSINESS = {
>   name: "Bagel Co.",
>   streetAddress: "123 Main St",
>   addressLocality: "Brooklyn",
>   addressRegion: "NY",
>   postalCode: "11201",
>   addressCountry: "US",
>   telephone: "+1-718-555-0100",
>   geo: { latitude: 40.6928, longitude: -73.9903 },
>   openingHours: [
>     { dayOfWeek: 'Monday', opens: '07:00', closes: '17:00' },
>     // ...
>   ],
> };
>
> // schema is derived
> const localBusinessSchema = {
>   '@context': 'https://schema.org',
>   '@type': 'CafeOrCoffeeShop', // most specific subtype (a real schema.org LocalBusiness subtype)
>   name: BUSINESS.name,
>   address: {
>     '@type': 'PostalAddress',
>     streetAddress: BUSINESS.streetAddress,
>     addressLocality: BUSINESS.addressLocality,
>     addressRegion: BUSINESS.addressRegion,
>     postalCode: BUSINESS.postalCode,
>     addressCountry: BUSINESS.addressCountry,
>   },
>   telephone: BUSINESS.telephone,
>   geo: { '@type': 'GeoCoordinates', ...BUSINESS.geo },
>   openingHoursSpecification: BUSINESS.openingHours.map(h => ({
>     '@type': 'OpeningHoursSpecification',
>     dayOfWeek: h.dayOfWeek,
>     opens: h.opens,
>     closes: h.closes,
>   })),
>   sameAs: ['https://www.yelp.com/biz/bagel-co', 'https://maps.google.com/?cid=...'],
>   url: 'https://bagelco.example.com',
> };
> ```
>
> Once the source of truth lives in one place, NAP drift becomes a deploy-time check, not a manual audit.
