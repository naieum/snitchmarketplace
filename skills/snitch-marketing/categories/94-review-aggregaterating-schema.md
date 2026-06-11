## CATEGORY 94: Review / AggregateRating schema

`Review` and `AggregateRating` schema power the star ratings shown in SERP rich results, for products (Cat 34), local businesses (Cat 92), software apps (Cat 91), recipes (Cat 87), courses (Cat 88), and services. Misused, they're one of Google's most-policed schema types: faked, padded, or self-applied ratings invite manual actions and SERP suppression. This category audits review/rating schema across all surfaces, product, app, business, service, for honesty and structural correctness.

### Pre-flight: relevance check

Skip this category with reason `not applicable` ONLY if the site has no review or rating surface anywhere (no testimonials, no star ratings, no review section, no aggregate score). Otherwise: required, even if the site doesn't yet surface reviews, silent absence is itself a finding (cross-reference Cat 74).

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` across schema for `"@type": "Review"` and `"@type": "AggregateRating"`. Quote each.
2. For each Review: check the fields Google actually REQUIRES: `author`, `itemReviewed` with a `name` (or a parent Product/LocalBusiness/etc. that supplies the reviewed item's name), and `reviewRating.ratingValue`. Recommended (not required): `datePublished`, `reviewBody`, `reviewRating.bestRating` / `worstRating` (needed only when the scale isn't the default 5).
3. For each AggregateRating: check required: `ratingValue`, `bestRating`, `ratingCount` OR `reviewCount`. Cross-reference with the visible review surface on the page, does the page actually display the count of reviews claimed?
4. Distinguish self-applied ratings (the brand rating itself; forbidden by Google) from third-party ratings (G2, Capterra, Trustpilot, allowed if attributed) from real customer reviews on the site.

**Crawl mode, required tool calls:**

1. `Fetch` pages with rating surfaces. Find JSON-LD blocks.
2. Quote each Review and AggregateRating object.
3. Cross-reference with visible review content on the page.

### Forbidden claims

- "Reviews may be fake." Show the count discrepancy, schema claims 247 reviews; page surfaces 4.
- "AggregateRating may be padded." Quote schema rating + provide a count check.
- Don't claim "Google will issue a manual action", that's their decision, not ours. Frame as "this pattern is known to invite manual review per Google's guidelines [link]."

### Detection

Looking for `Review` and `AggregateRating` schema across product, app, business, service, recipe, and course pages.

### What to Search For

- `"@type": "Review"` and `"@type": "AggregateRating"`
- Review required (per Google): `author` (Person or Organization), `itemReviewed` carrying a `name` (or a parent Product/LocalBusiness/SoftwareApplication that supplies it), and `reviewRating.ratingValue`
- Review recommended (not required): `datePublished`, `reviewBody`, `reviewRating.bestRating` / `worstRating` (only when the scale isn't the default 5)
- AggregateRating required: `ratingValue` (number), `bestRating` (typically 5), and EITHER `ratingCount` OR `reviewCount` (must match the surface)
- For third-party-sourced ratings: clearly attributed (`Source: G2 reviews`) AND linked

### Actually Hurts the Marketing Surface

- **Self-applied AggregateRating** (the brand publishes a rating of its own product/service with no real review surface, Google forbids this).
  Evidence required: schema rating + zero visible reviews.
- **`ratingCount` / `reviewCount` mismatch with visible reviews** (schema claims 247 reviews; page shows 4).
  Evidence required: schema count + page visible count.
- **Review schema without `itemReviewed` context** (Google can't connect the review to what was reviewed).
  Evidence required: parsed Review without parent / `itemReviewed`.
- **`ratingValue` outside the `bestRating` range** (e.g., `ratingValue: 4.7` with no `bestRating`, leaving Google to guess the scale).
  Evidence required: parsed values.
- **Reviews without `author`** (Google rejects anonymous reviews for the rich result).
  Evidence required: parsed Review without author.
- **Borrowed third-party ratings without attribution** (schema cites "4.8 stars" but doesn't say it's from G2; the page doesn't link the source).
  Evidence required: schema rating + missing source context.
- **Old `datePublished` on all reviews (>2 years)**, review freshness affects rich result eligibility.
  Evidence required: dates quoted.
- **Review surface present on page but no Review schema published**, leaving SERP rich result on the table.
  Evidence required: visible reviews + missing schema.

### NOT a Problem

- A page with no review surface AND no Review schema, correct (don't fake reviews to qualify for rich results).
- AggregateRating sourced from a real on-page review system with reviews that match the count, the canonical correct case.
- Third-party AggregateRating clearly attributed and linked (G2 / Capterra / Trustpilot), acceptable per Google's guidelines.
- Mixed sources (some on-site, some attributed third-party) clearly delineated, acceptable.

### Context Check

1. Are reviews real (visible on the page, with named authors, with datestamps)?
2. Do schema counts match the visible review surface?
3. Are third-party ratings attributed to the source?
4. Does each Review have a parent `itemReviewed` (or is attached to a Product/SoftwareApplication/LocalBusiness)?
5. Is the brand publishing self-applied ratings (their own rating of their own product)? That's the bright line Google penalizes.

### Reference

Google's Review snippet documentation: https://developers.google.com/search/docs/appearance/structured-data/review-snippet

Schema.org Review: https://schema.org/Review

Schema.org AggregateRating: https://schema.org/AggregateRating

Google's manual actions guide on rich results: https://developers.google.com/search/docs/monitor-debug/manual-actions

**Severity tagging:**
- Self-applied AggregateRating with no real reviews → Critical (manual action risk).
- `ratingCount` mismatch with visible count → Critical (deceptive).
- Review without `itemReviewed` → High.
- Review without `author` → High.
- Borrowed third-party rating with no attribution → High.
- Review surface present but no schema → Medium.
- Stale review datePublished → Low.

**Fix voice:** `mike-monteiro` (primary) | `solutions-architect` (backup).

Read `souls/mike-monteiro.json` before writing the Fix.

Worked fix example:

> Reviews are not optional content. They are a record of what real customers said about a real product or service. The schema for them is a way of telling Google "these are the receipts." If your schema says you have 247 reviews and your page shows 4, you are not optimizing, you are lying.
>
> Two clean paths.
>
> If you have real on-site reviews:
>
> ```tsx
> const aggregateRatingSchema = {
>   '@type': 'AggregateRating',
>   ratingValue: reviews.averageStars.toFixed(1),  // computed, not hardcoded
>   bestRating: '5',
>   ratingCount: reviews.length,                    // matches visible count, exactly
> };
>
> const reviewSchemas = reviews.map(r => ({
>   '@type': 'Review',
>   author: { '@type': 'Person', name: r.authorName },
>   datePublished: r.publishedAt,
>   reviewBody: r.body,
>   reviewRating: { '@type': 'Rating', ratingValue: r.stars, bestRating: '5' },
> }));
> ```
>
> If you don't have on-site reviews but have third-party reviews on G2 / Capterra / Trustpilot:
>
> ```tsx
> // attribute clearly, link the source
> const aggregateRatingSchema = {
>   '@type': 'AggregateRating',
>   ratingValue: '4.8',
>   bestRating: '5',
>   reviewCount: 312,
>   url: 'https://www.g2.com/products/snitch/reviews',
>   // surface a "Reviews from G2" section on the page that links here
> };
> ```
>
> If you have no reviews, don't publish AggregateRating. Build a real review surface first (Cat 74), let real customers leave real reviews, then add the schema. The shortcut of inventing or padding ratings ends the same way every time.
