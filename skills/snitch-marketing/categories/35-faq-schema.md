## CATEGORY 35: FAQ schema

`FAQPage` schema with question/answer pairs makes the FAQ accordion appear directly in SERP. Google reduced this rich-result surface in 2023 (now mostly limited to .gov / .edu / authoritative sites), but the schema still helps with content understanding and may resurface for select queries.

For sites outside the eligible categories, recommend FAQ schema for AI-extractability and entity clarity, not for a SERP accordion that won't appear — see `references/schema-deprecations.md` for the eligibility narrowing. The Q&A answers themselves should hit the snippet/voice answer-length bands (40-60 words for a featured snippet / PAA, under ~29 words for voice); score them per `references/citability-scoring.md`.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify FAQ pages: routes named `/faq`, `/faqs`, `/help`, OR pages with multiple `<details>` / accordion / Q&A patterns.
2. `Grep` for `"@type": "FAQPage"`, `"@type": "Question"`, `"@type": "Answer"`. Quote each.
3. For each FAQ-shaped page: confirm schema. If missing, flag.
4. For schema with Q&A pairs: cross-check each pair against the visible content. Schema describes content not on the page = Google penalty.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Parse JSON-LD for FAQPage. Quote.
2. Compare to visible Q&A elements. Quote both.

### Forbidden claims

- "FAQ schema may be missing." Confirm FAQ page + schema absent.
- "Schema Q&A may not match visible." Quote both.

### Detection

Looking for `"@type": "FAQPage"` with `mainEntity` array of `Question` items.

### What to Search For

- `"@type": "FAQPage"`
- `"@type": "Question"`, `"@type": "Answer"`
- `mainEntity`, `acceptedAnswer`
- `<details>`, `<summary>` elements (visible FAQ accordion)
- Question-shaped headings ("How do I...?", "What is...?", "Can I...?")

### Actually Hurts SEO

- **FAQ page with no FAQPage schema**.
  Evidence required: FAQ-shaped content + no schema.
- **Schema with Q&A pairs not visible on page**.
  Evidence required: schema's questions/answers + page content showing they're absent.
- **Schema fewer Q&A pairs than visible** (5 visible, 2 in schema).
  Evidence required: visible count + schema count.
- **Answer text very short (<20 chars)** (Google requires substantive answers).
  Evidence required: quoted answer.

### NOT a Problem

- Sites without FAQ pages (skip the category).
- FAQ accordion on a product page that's not the page's primary content (acceptable as Question schema attached to Product schema).
- FAQ schema on a non-FAQ.gov / non-authoritative site (rich result less likely to appear; schema still valid).

### Context Check

1. Is the page actually a FAQ (multiple Q&A pairs)?
2. Are answers substantive (>20 chars; ideally 50+)?
3. Is the schema generated from the same data as the visible accordion?
4. Is the site authoritative enough that Google might show the FAQ rich result?

### Reference

Google on FAQ structured data: https://developers.google.com/search/docs/appearance/structured-data/faqpage

Schema.org FAQPage: https://schema.org/FAQPage

**Severity tagging:**
- FAQ page with no schema → Medium (post-2023 rich-result reduction).
- Schema/visible mismatch → High.
- Answer <20 chars → Medium.

**Fix voice:** `mike-monteiro` (primary) | `frank-chimero` (backup).

Read `souls/mike-monteiro.json` before writing the Fix. Mike's voice on FAQs: write the questions your customers actually ask, in their words, not the ones you wish they would.

Worked fix example:

> A FAQ schema block is just a structured version of what's already on the page. If the questions are the right ones, the ones your customers actually type into Google, the schema makes them eligible for rich rendering AND helps Google understand the page.
>
> ```tsx
> const faqs = [
>   { q: "Does Snitch send my code anywhere?", a: "Snitch's servers never receive your code…" },
>   { q: "Can I cancel anytime?", a: "Yes, from your dashboard. Access continues to the end of the period." },
> ];
>
> // Render visible accordion
> {faqs.map(item => (
>   <details><summary>{item.q}</summary><p>{item.a}</p></details>
> ))}
>
> // Render matching schema
> <script type="application/ld+json" dangerouslySetInnerHTML={{
>   __html: JSON.stringify({
>     '@context': 'https://schema.org',
>     '@type': 'FAQPage',
>     mainEntity: faqs.map(item => ({
>       '@type': 'Question',
>       name: item.q,
>       acceptedAnswer: { '@type': 'Answer', text: item.a },
>     })),
>   }),
> }} />
> ```
>
> Same data, schema and visible always in sync. Don't add Q&A to the schema that aren't on the page; that's lying, and Google penalizes it.
