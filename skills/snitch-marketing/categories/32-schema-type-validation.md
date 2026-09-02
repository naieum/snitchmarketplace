## CATEGORY 32: Schema type validation

Every schema.org type Google reads has the same three questions behind it: does the page type that
earns this markup exist, does the markup carry the properties the type requires, and does what the
markup claims match what the page shows. This category asks those three questions once and answers
them per type, driven by the per-type rows in `references/standards-table.md`.

The rows cover Article, BreadcrumbList, Product, FAQPage, HowTo, Organization / WebSite,
VideoObject, Recipe, Course, Event, JobPosting, SoftwareApplication, LocalBusiness and Person. Each
row carries the page-type signal that makes the type in scope, its required properties, its
recommended properties, its rich-result status (including the types whose rich result is gone), and
the Fix voice to write in. The impact ceiling per type comes from the same file's schema.org type
table; the deprecation register is `references/schema-deprecations.md`.

Two neighbors own what this category does not. Cat 31 is the gateway: is there any JSON-LD on the
page at all, does it parse, is `@context` right. Cat 94 owns rating honesty: any `Review` or
`AggregateRating` property met while validating a type here is quoted and handed to 94, never
re-audited as a second finding.

### Pre-flight: relevance check

Run one pass per type whose page-type signal fires, and only those. A type whose signal never fires
is a Skip with the reason naming the signal that was absent ("Recipe, skipped: no `/recipe/` route
and no ingredient-list-plus-instructions page found"). Never flag a missing type on a page that was
never eligible for it. A SaaS site is not missing Recipe schema.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Resolve which types are in scope: for each row of the per-type table in
   `references/standards-table.md`, test its page-type signal against the routes and page content.
   Quote the signal you matched (the route, the element, the framework) or record the Skip.
2. `Grep` for the `@type` strings of every in-scope type (including its subtypes, which the row
   names). Quote every match with its `file:line`.
3. Parse each matched JSON-LD object. Check the row's required properties, then its recommended
   properties. Quote each property that is absent, and quote the value of each that is present and
   wrong.
4. Compare the schema to the rendered page for the same fact: the price the schema states against
   the price the page shows, the ingredient count, the salary, the breadcrumb labels, the Q&A pairs,
   the opening hours, and the `ratingCount` / `reviewCount` against the reviews or testimonials the
   page actually displays. Quote both sides of any divergence — including where the divergence is
   another category's call (a rating goes to Cat 94 with both sides already quoted, per Context
   Check #6).
5. For a "type missing on an eligible page" finding: quote the page-type signal AND the absence
   (the grep that returned nothing across the pages you enumerated).

**Crawl mode, required tool calls:**

1. `Fetch` one representative URL per in-scope page type. Find every
   `<script type="application/ld+json">` block and parse it.
2. Quote the whole object for each type you are validating.
3. Check required and recommended properties against the row. Quote what is missing.
4. Fetch the URLs the schema asserts (`image`, `logo`, `thumbnailUrl`, `offers.url`, `sameAs`
   entries) and quote the status code for any that does not resolve.

### Forbidden claims

- "Schema is probably missing." Confirm the page type fires the signal, then grep or parse. There is
  no "probably": either the block is there or it is not.
- "The required fields may be incomplete." Parse the object and name the absent property.
- "The schema may not match the page." Quote the schema value and the visible value side by side.
- "Adding HowTo / FAQ schema will win a rich result." Check the row's rich-result status first;
  `references/schema-deprecations.md` is the register of what no longer renders.
- "Most product pages lack Product schema." Enumerate the pages you checked. "Most" needs a
  denominator.

### Detection

For each in-scope type, the loop is the same: find the JSON-LD block, parse it, check the required
properties, check the recommended properties, compare it to the visible page, then read the
type-specific pitfalls in `references/standards-table.md` for the failure modes only that type has
(a `position` gap in a breadcrumb, a `startDate` with no timezone, an ingredient count that does not
match, a `baseSalary` without `unitText`).

Where the site emits schema through a plugin or theme (Yoast, RankMath, AIOSEO, a Shopify theme),
source may be silent while the rendered HTML is complete. Verify in crawl mode before writing a
"missing type" finding. That check is Cat 31's Context Check and it applies here too.

### What to Search For

- `"@type":` followed by any type or subtype named in the per-type table
- The required properties for each in-scope type, per the table's Required column
- The recommended properties that gate a feature: `offers`, `shippingDetails`,
  `hasMerchantReturnPolicy`, `eventAttendanceMode`, `hasCourseInstance`, `validThrough`,
  `openingHoursSpecification`, `geo`, `operatingSystem`, `sameAs`, `duration`, `recipeYield`
- ISO 8601 shapes where the type demands them: `PT30M` durations, `2026-06-15T18:00:00-07:00`
  timestamps with an offset
- Full schema.org enum URLs where the type demands them (`https://schema.org/InStock`,
  `https://schema.org/OnlineEventAttendanceMode`), not bare strings
- `@id` references that point an Article's `author` at a canonical Person profile
- The visible counterpart of each claim: the price label, the breadcrumb trail, the ingredient list,
  the hours block, the salary line, the accordion

### Actually Hurts SEO

- **An eligible page type carries no schema of its type.** The signal fired, the markup is absent,
  and the rich result the type unlocks was never sought.
  Evidence required: the quoted page-type signal + the enumerated pages + the empty grep.
- **A required property is missing.** The type's row names them; without them Google drops the
  block, so the page has no schema of that type even though the source looks like it does.
  Evidence required: the parsed object with the property named as absent.
- **A recommended property that gates a feature is missing.** The block validates but the feature it
  was meant to earn does not render.
  Evidence required: the parsed object + the feature the row says it gates.
- **The schema contradicts the visible page.** A price, a salary, an ingredient count, an hours
  block, a breadcrumb label or a Q&A pair that differs from what the reader sees. This is the
  highest-cost class here: Google reads it as inconsistency and can drop the rich result entirely.
  Evidence required: both values quoted, with the diff shown.
- **A value is in the wrong shape.** A duration that is not ISO 8601, a date with no timezone, an
  enum written as a bare word, a price with a currency symbol inside the string, an address as one
  line instead of a structured `PostalAddress`.
  Evidence required: the quoted value + the shape the row requires.
- **A URL the schema asserts does not resolve.** `image`, `logo`, `thumbnailUrl`, `offers.url`,
  `screenshot`, `sameAs`.
  Evidence required: the URL + the fetch status.
- **The schema outlives the thing it describes.** A closed role, a cancelled event, a sunset app, a
  past date still marked scheduled.
  Evidence required: the visible closure notice + the still-live schema.
- **The type-specific pitfalls** listed per type in `references/standards-table.md`, each with the
  severity that row assigns.
  Evidence required: as the pitfall states.

### NOT a Problem

- A page that never fires a type's signal. Skip it; do not report an absence.
- A markup choice the type accepts either way: `BlogPosting` in place of `Article`, several
  `Product` blocks on a category page, several `Person` entries in a team-page `ItemList`, several
  `hasCourseInstance` entries for quarterly cohorts, an `ItemList` on a catalog or index page.
- A recommended property that is genuinely optional for the site: `nutrition` on a recipe,
  `dateModified` on an article, `releaseNotes` on a brand-new app, `award` on a Person.
- `sameAs` absent from a `Person` that is nested inside another type (an Article's `author`, a
  Course's `instructor`) and already carries a canonical `url` or an `@id`. That object's job is to
  identify the person and point at the profile; `sameAs` is owed on the standalone profile page the
  `url` / `@id` resolves to, and the pitfall row in `references/standards-table.md` fires there, not
  here.
- A type whose rich result is gone (HowTo, the `WebSite` `SearchAction`) declared anyway. Still valid
  structured data; its absence is not a missed opportunity and never a High. It is not silence
  either: report it as a Pass-with-evidence that says both halves out loud — the properties that
  check out (and the visible steps they match), **and** that the rich result the type once earned no
  longer renders, with the retirement date from `references/schema-deprecations.md`. A Pass that
  quotes only the properties is incomplete, because it leaves the reader expecting a SERP feature
  that will never appear.
- Schema absent from source but present in the rendered HTML because a plugin or theme emits it.
- A service-area business with `areaServed` and no street address.

### Context Check

1. Which types actually fire? Run the page-type signals before anything else and write the Skips
   down; a report that flags nine missing types on a five-page site has skipped this step.
2. Is the rich result the finding implies still live? Check the row's status and
   `references/schema-deprecations.md` before framing a fix as CTR upside — and before writing a
   Pass, since a Pass on a retired type has to say the rich result is gone (see NOT a Problem).
3. Is the schema server-rendered? Client-injected blocks may not be seen on the initial render;
   state the limitation in the finding rather than asserting the outcome.
4. Does a plugin, theme or framework emit the type already? Verify in crawl mode before flagging.
5. Where the same fact appears in both schema and page, which one is wrong? The page is the source
   of truth for the reader; say which side to change, and prefer the fix that makes one value feed
   both.
6. Does the object carry `aggregateRating` or `review`? Quote it **and its visible counterpart** —
   the reviews, testimonials or star widget a reader can count on the page, with their `file:line` —
   then hand both sides to Cat 94; do not open a rating finding here. The hand-off anchors at the
   schema block *and* the visible review section, so 94 inherits the contrast (a four-figure
   `ratingCount` against three testimonials on the page) instead of having to re-find it. Where the
   page shows no reviews at all, say that: "no visible review or testimonial block found" is the
   other half of the anchor.
7. Is the most specific correct type used (`Dentist` over `LocalBusiness`, `NewsArticle` over
   `Article` for news)? Specificity earns richer features, but only when it is true.

### Reference

The per-type rows, pitfalls and impact ceilings: `references/standards-table.md`.

Retired and narrowed rich results: `references/schema-deprecations.md`.

Google's structured data documentation: https://developers.google.com/search/docs/appearance/structured-data

The schema.org type hierarchy: https://schema.org/docs/full.html

Google's Rich Results Test (manual validation): https://search.google.com/test/rich-results

Cat 31 (JSON-LD presence) is the gateway; Cat 94 (Review / AggregateRating) owns rating honesty;
Cat 22 supplies the visible breadcrumb this category compares against; Cat 30 supplies the video
sitemap that pairs with VideoObject; Cat 79 supplies the Google Business Profile that LocalBusiness
NAP is checked against; Cat 82 and `references/eeat-assessment.md` consume the Person entity.

**Severity tagging:**
- Eligible page type with none of its schema, where the rich result is live → High; Critical when
  the type's ceiling in `references/standards-table.md` is Critical (Product, Recipe, Event,
  LocalBusiness, JobPosting on the surfaces those serve).
- Required property missing → High (Critical where the type's ceiling is Critical).
- Schema contradicting the visible page → High, and Critical where the contradiction misleads a
  buyer, a cook, an applicant or an attendee.
- Value in the wrong shape (non-ISO date or duration, bare enum, price string, unstructured address)
  → High when it invalidates the block, Medium when Google merely drops that property.
- Recommended feature-gating property missing → Medium.
- Asserted URL 404s → Critical for `logo`, `image` and `thumbnailUrl`; High for `offers.url`;
  Medium for `screenshot` and `sameAs`.
- Schema outliving what it describes (closed role, cancelled event, past event) → High.
- A type whose rich result is retired, absent → Low / informational.
- Anything the per-type pitfall list in `references/standards-table.md` scores explicitly → that
  severity, which overrides the generic tier above.

**Fix voice:** per type, from the Fix voice column of the per-type table in
`references/standards-table.md`. `content-shape-editor` writes Article, Course and Person,
`indie-commerce-founder` for Product and SoftwareApplication, `solutions-architect` for Event and
LocalBusiness, `honest-design-critic` for FAQ and JobPosting, and so on. When one finding spans
several types, write it in `intrinsic-web-engineer`, whose read of structured data as the thing that
makes a page work for both humans and machines holds the whole category together.

Read the soul file for the voice the row names before writing the Fix.

Worked fix example (Article row):

> Every blog post deserves an Article block, and the required fields aren't decorative: they're the
> difference between Google understanding the post is a 2026 piece by a named author about
> CVE-2026-3854 and Google seeing a generic blob of HTML.
>
> ```tsx
> const articleSchema = {
>   '@context': 'https://schema.org',
>   '@type': 'BlogPosting',
>   headline: post.title,
>   image: [post.heroImage],
>   datePublished: post.publishedAt,
>   dateModified: post.updatedAt,
>   author: { '@id': `https://example.com/authors/${post.author.slug}#person` },
>   publisher: {
>     '@type': 'Organization',
>     name: 'Example',
>     logo: { '@type': 'ImageObject', url: 'https://example.com/logo.png' },
>   },
> };
> ```
>
> Every field is derived from the same data the page renders, so schema/page divergence is not
> possible, which is the fix for most of this category, not just this row. `JSON.stringify` the
> whole object and inject it as JSON-LD in the head. The `author` is an `@id` reference to the
> canonical Person profile, so a role change is edited in one file.
