# Standards Table — Schema.org type catalog + SEO impact alignment

Each finding can carry a `Schema.org type` tag and an `Impact` tier. This table is the lookup; categories reference it instead of restating the rules.

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
| `Course` | Course List carousel (built from an `ItemList` of `Course` on a catalog page). The per-course card was removed 2025-09-09 | Medium on a catalog page; Low on a single course detail page |
| `SoftwareApplication` | App rating + price snippet | Medium |
| `Person` (author) | Author entity association (E-E-A-T) | Medium-High for YMYL content; Medium elsewhere |
| `Review` / `AggregateRating` | Star rating in SERP across Product/SoftwareApp/LocalBusiness/Recipe | High when honest; Critical (manual-action risk) when faked or unattributed |

Findings that flag schema as **invalid** (wrong required field, wrong type) are higher impact than findings that flag schema as **missing** (eligibility was never sought) — invalid schema can demote the page.

## Per-type validation rows (the table Cat 32 runs)

Cat 32 (Schema type validation) is one category driven by these rows: one row per type, one pass per
type whose page-type signal fires. A type whose signal never fires is a Skip-with-reason, not a
finding. Cat 31 is the gateway (is there any JSON-LD at all); Cat 94 owns rating honesty wherever
`Review` / `AggregateRating` appears, so a row here never re-audits a rating claim.

| Type | Page-type signal (pre-flight) | Required properties | Recommended properties | Rich-result status | Fix voice (primary / backup) |
|---|---|---|---|---|---|
| `Article` / `BlogPosting` / `NewsArticle` / `TechArticle` | `/blog/`, `/posts/`, `/articles/` path OR an `<article>` element with a byline and a date | `headline`, `image`, `datePublished`, `author`, `publisher` | `dateModified`; `author` as a structured `Person` / `Organization` with `url`; hero image at 1200x630 or larger for Top Stories | Live — Article rich result, Top Stories, Discover | `content-shape-editor` / `intrinsic-web-engineer` |
| `BreadcrumbList` | A visible breadcrumb component (Cat 22) OR a page three or more levels deep | `itemListElement`, an array of `ListItem`, each with `position`, `name`, `item` | Positions sequential from 1; item URLs identical to the visible breadcrumb's hrefs | Live — the breadcrumb path replaces the URL in SERP | `systems-designer` / `intrinsic-web-engineer` |
| `Product` (+ `Offer`) | `/product/`, `/p/`, `/products/` path; "add to cart" text; an e-commerce framework in the dependency list | `name`, `image`, `offers` with `price` + `priceCurrency` + `availability` | `sku`, `brand`, `itemCondition`; `shippingDetails` (`OfferShippingDetails`) and `hasMerchantReturnPolicy` (`MerchantReturnPolicy`) for the full merchant listing; `hasEnergyConsumptionDetails` for EU-sold regulated electronics/appliances; `hasMemberProgram` where the page shows loyalty pricing | Live — product snippet and merchant listing; the biggest CTR lift Google offers e-commerce | `indie-commerce-founder` / `brand-surface-designer` |
| `FAQPage` | `/faq`, `/faqs`, `/help` route OR several `<details>` / accordion pairs with question-shaped headings | `mainEntity`, an array of `Question`, each with `name` and `acceptedAnswer.text` | Every schema pair also visible on the page; answers inside the snippet/voice answer-length bands in `references/citability-scoring.md` | Narrowed since 2023 to authoritative / government / health sites; treat as content understanding and AI extractability, not a SERP accordion | `honest-design-critic` / `content-shape-editor` |
| `HowTo` | `/how-to/`, `/tutorial/`, `/guide/` path; numbered step headings | `name`, `step` (array of `HowToStep`, each with `text` or `name`) | `totalTime`, `tool`, `supply`; steps in the same order as the visible steps | Removed Sept 2023 — no rich result exists. Never recommend it "for a rich result" | `plain-language-designer` / `honest-design-critic` |
| `Organization` / `WebSite` | Every site; both belong in the global layout so they appear on every page | Organization: `name`, `url`, `logo`. WebSite: `name`, `url` | `sameAs` (real, live brand profiles), `contactPoint`; logo 512x512 or larger, JPG or PNG | Live for `Organization` — knowledge panel and brand SERP. `WebSite` `potentialAction` / `SearchAction` is inert since the Sitelinks Searchbox was retired Nov 2024; its absence is not a finding | `brand-surface-designer` / `expressive-typographer` |
| `VideoObject` | A `<video>` element or a YouTube / Vimeo embed; a video sitemap entry (Cat 30) | `name`, `description`, `thumbnailUrl`, `uploadDate` | `duration` in ISO 8601 (`PT2M30S`), `contentUrl`, `embedUrl`, `transcript` | Live — video rich result and Google Video indexing | `motion-engineer` / `analytics-engineer` |
| `Recipe` | `/recipe/`, `/recipes/`, `/cook/` path OR an ingredient list plus numbered instructions plus a yield | `name`, `image`, `recipeIngredient`, `recipeInstructions` | `author`, `datePublished`, `description`, `prepTime`, `cookTime`, `totalTime`, `recipeYield`, `recipeCategory`, `recipeCuisine`, `nutrition`, `video`; times in ISO 8601 duration | Live — recipe rich result, by-ingredient filter, recipe carousel | `recipe-author` / `intrinsic-web-engineer` |
| `Course` | `/courses/`, `/learn/`, `/program/`, `/certificate/` path plus a named provider, a curriculum and an enrollment CTA | `name`, `description`, `provider` (an `Organization` with `name` + `sameAs`) | `hasCourseInstance` (`courseMode`, `instructor`, `startDate`, `endDate`, `location`, `offers`), `coursePrerequisites`, `educationalCredentialAwarded`; a catalog page uses an `ItemList` of `Course`, not one `Course` block | Course List carousel only; the per-course card was removed 2025-09-09 | `content-shape-editor` / `intrinsic-web-engineer` |
| `Event` (+ `BusinessEvent`, `EducationEvent`, `MusicEvent`, `SocialEvent`, `SportsEvent`, `TheaterEvent`, `VisualArtsEvent`) | `/events/`, `/event/`, `/conference/`, `/webinar/` path plus a specific date and a location or stream URL and a register CTA | `name`, `startDate` (ISO 8601 **with** timezone) | `endDate`, `location` (`Place` with `address` in person, `VirtualLocation` with `url` online, both for hybrid), `eventAttendanceMode`, `eventStatus`, `organizer`, `offers` (`price`, `priceCurrency`, `availability`, `validFrom`, `url`), `description`, `image`; one Event per occurrence, or one Event with a `subEvent` array | Live — the Events SERP card | `solutions-architect` / `honest-design-critic` |
| `JobPosting` | `/careers/`, `/jobs/`, `/job/`, `/positions/` path plus a role title, an employer, responsibilities and an apply CTA | `title`, `description`, `datePosted`, `hiringOrganization` (structured `Organization`), and `jobLocation` (`Place` with `address`) OR `jobLocationType: "TELECOMMUTE"` with `applicantLocationRequirements` | `validThrough`, `employmentType` (`FULL_TIME` / `PART_TIME` / `CONTRACTOR` / `TEMPORARY` / `INTERN`), `baseSalary` as a `MonetaryAmount` with `currency` and a `value` `QuantitativeValue` carrying `minValue` / `maxValue` + `unitText`; `hiringOrganization.sameAs` + `logo` | Live — Google for Jobs | `honest-design-critic` / `solutions-architect` |
| `SoftwareApplication` (+ `WebApplication`, `MobileApplication`, `VideoGame`) | `/`, `/product/`, `/app/`, `/extension/`, `/download/` plus a named app, a feature list and a signup or download CTA | `name`, `applicationCategory` (`BusinessApplication`, `DeveloperApplication`, `SecurityApplication`, `BrowserApplication`, …) | `operatingSystem` (`Web`, `Windows`, `macOS`, `Linux`, `iOS`, `Android`), `offers` with `price` + `priceCurrency` (`"0"` stated explicitly for free), `description`, `image` or `screenshot`, `url`, `softwareVersion`, `releaseNotes`, `downloadUrl` / `installUrl` | Live — the app SERP card (name, category, price, rating, install link) | `indie-commerce-founder` / `brand-surface-designer` |
| `LocalBusiness` (+ its subtypes: `Restaurant`, `Dentist`, `Hotel`, `LegalService`, `MedicalClinic`, `AutoRepair`, …) | A physical address, a service area, or a location-bound service on `/`, `/contact`, `/locations`, `/about` | `name`, `address` as a `PostalAddress` with `streetAddress`, `addressLocality`, `addressRegion`, `postalCode`, `addressCountry`; the most specific subtype that fits | `telephone`, `url`, `image`, `priceRange`, `openingHoursSpecification` (`dayOfWeek`, `opens`, `closes`), `geo` (`latitude`, `longitude`), `sameAs`; `areaServed` instead of `address` for a service-area business; one page plus one schema block per location | Live — local pack, knowledge panel, Maps | `solutions-architect` / `honest-design-critic` |
| `Person` (author / founder / instructor) | An author byline, `/about`, `/team`, `/authors/`, a founder or instructor profile | `name` | `url` (canonical profile page), `image`, `jobTitle`, `worksFor`, `sameAs` (LinkedIn, X, GitHub, Wikipedia, ORCID); an `@id` on the profile that every Article's `author` points at; `alumniOf`, `award`, `knowsAbout`, `description` for E-E-A-T depth | No standalone card; feeds the knowledge panel, the E-E-A-T read in `references/eeat-assessment.md`, and human attribution in AI answers | `content-shape-editor` / `honest-design-critic` |

### Per-type pitfalls and severities

The failure modes that are specific to a type. The type-independent ones (type absent on a signalled
page, a required property missing, schema contradicting the visible page) carry the tiers in Cat 32's
own severity block.

- **Article** — `headline` over 110 characters (Google truncates the rich result) → Medium. `image` relative or 404 → Critical. `author` a plain string rather than a `Person` / `Organization` → Low, advisory upgrade. `datePublished` in the future → High. Subtype choice (`BlogPosting` vs `Article`) is never a finding; `dateModified` absent is never a finding.
- **BreadcrumbList** — `position` skipping a number → High. Schema item URLs disagreeing with the visible breadcrumb → High. A `ListItem` missing `name` or `item` → High. Schema with no visible breadcrumb is fine; a single "Home" crumb is not worth schema, Skip it.
- **Product** — `offers` absent → Critical. `availability` not a full schema.org enum URL (`https://schema.org/InStock`) → High. Price written as a string with a currency symbol instead of a number plus `priceCurrency` → High. A sellable product with neither `shippingDetails` nor `hasMerchantReturnPolicy` → Medium, written as the merchant-listing gate on its own; the generic recommended tier (`sku`, `brand`, `itemCondition`) is a separate, lower finding, never bundled into this one. An EU-sold regulated product with no `hasEnergyConsumptionDetails` → Medium. Shipping, returns or energy values contradicting the visible policy → High. Several `Product` blocks on a category page (one per card) is correct, not a finding.
- **FAQPage** — schema Q&A pairs that are not on the page → High. Fewer pairs in the schema than on the page → Medium. An `acceptedAnswer.text` under 20 characters → Medium. Missing FAQ schema on an FAQ page → Medium, and framed as extractability rather than a lost accordion.
- **HowTo** — schema steps not matching the visible steps → Medium (the schema misrepresents the page; no rich result is at stake). A step with empty `text` and `name` → Low. Missing HowTo schema on a how-to page → Low / informational. Present and correct → a Pass that states both halves: the properties and step match check out, and the rich result was removed Sept 2023 so none will render.
- **Organization / WebSite** — no `Organization` schema anywhere on the site → Medium. `logo` missing → High (knowledge-panel eligibility). `logo` 404 or wrong dimensions → Critical. `sameAs` absent → Low; `sameAs` pointing at a 404 or abandoned profile weakens the entity, so verify each URL (cross-check Cat 96). Conflicting `Organization` blocks across pages (different names or logos) → Medium. Missing `SearchAction` → not a finding.
- **VideoObject** — `thumbnailUrl` missing → Critical; `thumbnailUrl` 404 → Critical. `uploadDate` in the future or not ISO 8601 → High. `duration` in a non-ISO format (`"2:30"` instead of `"PT2M30S"`) → Medium. An embedded YouTube video with no local schema is acceptable; native video with none → High. Pair the finding with Cat 30 (video sitemap).
- **Recipe** — structured `recipeIngredient` count diverging from the visible ingredient count → Critical (it misleads the cook and Google at once). `recipeInstructions` as one string instead of a `HowToStep` array → High. Time fields not ISO 8601 duration → Medium. `recipeYield` absent while per-serving `nutrition` is present → High; absent with no nutrition → Low. Hero image under Google's 50,000-pixel minimum (width × height) → Medium; there is no 1200x675 floor and the rich result is not suppressed below it, so do not assert one.
- **Course** — a catalog page using one `Course` block instead of an `ItemList` of `Course` → Medium (it blocks Course List eligibility). `provider` as a plain string → Medium. `provider.sameAs` absent → Low. `hasCourseInstance` absent for a cohort-based course → Low, informational. Stale cohort dates feed wrong data to the carousel and to AI surfaces → Medium.
- **Event** — `startDate` missing or without a timezone offset → Critical. `location` missing (no `Place` in person, no `VirtualLocation` online) → High. `eventAttendanceMode` missing → Medium. `eventStatus` still `EventScheduled` after a visible cancellation or postponement → High (it lies to attendees). A past event still `EventScheduled` → Medium. `offers.url` missing or broken → High. Recurring occurrences merged into one Event with a vague `startDate` → High.
- **JobPosting** — `hiringOrganization` as a plain string → High. `jobLocation` absent with no `TELECOMMUTE` → Critical (invisible to geographic job search). `datePosted` older than 90 days with no `validThrough` → High. A filled or closed role with live JobPosting schema → High. `baseSalary` disagreeing with the salary visible on the page → High (a schema/content mismatch Google acts on). `baseSalary` malformed (no `currency`, or a `value` without `minValue` / `maxValue` / `unitText`) → Medium; Google drops the salary display. A `description` of perks rather than responsibilities → Medium. A remote role with no `applicantLocationRequirements` → Medium.
- **SoftwareApplication** — `applicationCategory` missing → Medium. `operatingSystem` missing on a downloadable app → High. `offers` missing entirely → Medium (no price or "free" badge). `screenshot` missing or 404 → Medium. `softwareVersion` more than 12 months behind the visible changelog → Low, advisory. A sunset product still carrying live schema → Medium.
- **LocalBusiness** — a generic `LocalBusiness` where a specific subtype fits → Medium. `address` as one string instead of a structured `PostalAddress` → High. NAP disagreeing between schema and the visible page → Critical; between schema and the brand's Google Business Profile → Critical (Cat 79 supplies the listing side). `openingHoursSpecification` missing or stale → High. `geo` missing → Medium. Several locations modeled as one business with several addresses → High.
- **Person** — an Article `author` as a plain string rather than a `Person` object → High. a standalone `Person` profile page (`/about`, `/team`, `/authors/<name>`) whose `Person` block has no `sameAs` → Medium; a `Person` nested as another type's `author` or `instructor` that already carries a canonical `url` or an `@id` is complete where it stands — no `sameAs` finding against the nested object. An author bylined on several articles with no canonical profile page holding the authoritative `Person` (and no `@id` reference) → Medium. `jobTitle` / `worksFor` disagreeing with the visible bio → Medium. `image` 404 or the wrong person → Low. A pseudonymous author on YMYL content with no identity disambiguation → High.

Any `aggregateRating` or `review` property encountered while validating a type above is Cat 94's
call, not this table's: quote it, hand it to 94, and do not open a second rating finding here.

## Impact tiers (tagging rule for findings)

| Tier | Definition | Examples |
|---|---|---|
| **Critical** | Page or site is being actively excluded from indexing OR a paying-customer surface is broken. | Robots.txt blocks the homepage. `noindex` on a primary commercial route. Broken canonical pointing to a 404. Sitemap returns 5xx. Schema with required field missing on a Product page. |
| **High** | Real ranking / CTR loss in measurable terms. The fix has a known positive effect. | Missing canonical on a route with paginated/utm duplicates. Title tag missing. Schema for the page type missing entirely. Broken internal links pointing to important pages. Massive render-blocking JS. |
| **Medium** | The fix is good practice and incrementally helps; the impact is modest or hard to attribute. | Sub-optimal alt text. Missing `width`/`height` causing CLS. Footer link spam. Sub-optimal heading hierarchy on a single page. Anchor text drift. |
| **Low** | Polish. Won't move the needle alone, but a tidy site outranks a sloppy one over time. | Title 5 chars over recommended length. Meta description present but generic. One image without lazy-loading on a long page. |

## Tagging rule

Every finding gets:

1. An `Impact` tier from the table above.
2. A `Schema.org type` only when the finding is about schema or about a page-type the type covers (e.g., a missing alt on a product image is `Product` because it ladders into product visual results; a missing alt on a blog inline image isn't tagged with a type).

If a finding doesn't fit any schema.org type and isn't about a page type the catalog covers, omit the type tag. Don't force it.

## Anti-pattern (don't do this)

- Don't tag every Cat 25 (alt text) finding with `ImageObject` schema. The category is about the alt attribute; the schema type is irrelevant unless the user is also missing `ImageObject` JSON-LD intentionally for image search ranking.
- Don't escalate Medium → High because "Google said it matters once in a 2018 blog post". Use the table.
- Don't downgrade Critical → Medium because "the customer might know about it already". Critical is what it is.

## Reference: Google's own documentation

When in doubt about a schema type or rule, the canonical reference is Google's developer docs at https://developers.google.com/search/docs/appearance/structured-data plus the schema.org spec at https://schema.org. Cite the relevant page in the finding when the user is likely to push back ("why does this matter?").
