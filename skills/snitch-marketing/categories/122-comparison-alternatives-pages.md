## CATEGORY 122: Comparison / alternatives / "vs" page strategy

The highest-commercial-intent content most brands never build. Searchers typing
`{competitor} alternatives`, `{brand A} vs {brand B}`, or `best {category} for {use
case}` are at the decision stage (cross-ref the keyword→buyer-stage map in
`references/context-file.md` / Cat 86). This category audits whether the site
**captures that intent** with credible comparison and alternatives pages, and
whether those pages convert. Distinct from `references/comparative-mode.md` (which
audits the user's site *against* a competitor for the consultant); this audits the
site's own bottom-funnel comparison surface.

### Pre-flight: relevance check

Skip with reason `not applicable` when the brand is a true category creator with no
named competitors, or a pure-content/personal site with nothing to sell. Otherwise:
required for any product/service with named alternatives in a searched category.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Search routes/content for comparison surfaces: `/vs/`, `/compare`, `/alternatives`,
   `/{competitor}-alternative`, "best {category}" pages, comparison tables.
2. Read `.snitch-marketing-context.md` for competitors, differentiation, anti-persona
   (so the audit knows which comparisons are worth making and how to frame honestly).
3. If comparison pages exist: inspect for an honest comparison table, a clear CTA, and
   comparison/Product/Review schema (cross-ref Cat 34/94).

**Crawl mode, required tool calls:**

1. Fetch any `/vs`, `/compare`, `/alternatives` pages; capture the table, the framing,
   the CTA, the schema.
2. Note absence: no comparison/alternatives surface anywhere in nav, sitemap, or links.

### Forbidden claims

- "They should probably have comparison pages." First confirm named competitors exist
  (from context or SERP) and that the category has comparison/alternatives search demand;
  quote the basis.
- "The comparison page is biased." Quote the table; show the missing honest cons / the
  one-sided framing.
- "These pages don't convert." Quote the page's CTA (or its absence) and message match.

### Detection

Comparison-surface presence + quality (credibility, conversion, schema), grounded in
the context file's competitive landscape.

### What to Search For

- **No comparison/alternatives surface** at all on a product with named competitors in a
  searched category (a whole intent stage left to competitors and review sites)
- "{Competitor} alternatives" pages that don't actually name/list alternatives (thin,
  keyword-bait)
- One-sided comparison tables with **no honest cons** for the brand (low credibility;
  Pratfall Effect, `mental-models.md` — admitting a real weakness raises trust)
- Comparison/alternatives page with **no CTA / no conversion path** (high intent wasted)
- Message mismatch: page targets `{brand} vs {competitor}` but the headline doesn't
  mention either (cross-ref Cat 109)
- No comparison-table or Product/Review schema on comparison pages (cross-ref Cat 34/94)
- Outdated competitor claims (pricing/features that changed) — a credibility + legal risk
- Comparisons that misrepresent the competitor (deceptive; cross-ref Cat 114 ethics overlay)

### Actually Hurts the Marketing Surface

- **No comparison/alternatives pages despite decision-stage demand.** Competitors and
  third-party listicles capture `{brand} alternatives` / `vs` searches instead.
  Evidence required: named competitors (context/SERP) + the absent surface.
- **Thin "alternatives" page that names no alternatives.** Keyword-bait that ranks
  poorly and converts worse.
  Evidence required: the page content showing no real comparison.
- **One-sided, non-credible comparison.** No honest cons; reads as marketing, not help.
  Evidence required: the table quoted.
- **High-intent page with no CTA.** The buyer is closest to deciding here.
  Evidence required: the page with the missing/weak CTA.
- **Stale or misleading competitor claims.** Credibility and legal exposure.
  Evidence required: the outdated/false claim quoted.

### NOT a Problem

- A category creator with no real competitors (forcing a "vs" page would be contrived).
- A brand that deliberately stays out of competitor-name SEO for legal/brand reasons
  (a strategy choice; note it, don't flag as a defect).
- An honest comparison that concludes a competitor is better for a specific segment —
  that's credibility, not a flaw (it serves the anti-persona correctly).
- Sites with no commercial offering.

### Context Check

1. Who are the named competitors (from `.snitch-marketing-context.md`)? Without them,
   there's no comparison to build.
2. Is there real search demand for `{competitor} alternatives` / `vs` in this category?
3. Does the brand's positioning (context differentiation) give an honest angle, or would
   a comparison be contrived?
4. Do the comparison pages convert, or just rank? CTA + message match (Cat 109).
5. Is the framing honest (Pratfall / real cons), or one-sided (credibility + ethics risk, Cat 114)?

### Reference

Consideration-stage keyword intent: `references/context-file.md` + Cat 86.

Bottom-funnel comparison content (Reforge): https://www.reforge.com/blog

**Severity tagging:**
- No comparison/alternatives surface despite clear decision-stage demand → High.
- High-intent comparison page with no CTA → High.
- Thin "alternatives" page naming no alternatives → Medium.
- One-sided / non-credible comparison → Medium.
- Stale or misleading competitor claims → High (credibility + legal).

**Fix voice:** `april-dunford` (primary) | `seth-godin` (backup).

Read `souls/april-dunford.json` before writing the Fix.

Worked fix example:

> Decision-stage searchers are looking for `{you} vs {competitor}` and `{competitor}
> alternatives` right now. If you don't answer, a review site or the competitor does,
> and they frame it.
>
> Build two page types, honestly. A `/{competitor}-alternative` page: name the
> alternatives (yours first, with a real reason), a comparison table with honest cons,
> and the segment each option fits. A `/vs/{competitor}` page for the head-to-head.
> Ground the angle in your actual differentiation, not spin; admitting "they're better
> if you need X" earns the trust that converts the buyers who need *your* X (Pratfall
> Effect). Put a clear CTA on both, add comparison + Product schema, and match the
> headline to the query.
>
> Verify: the pages rank for the target `vs`/`alternatives` queries (Search Console
> impressions over ~4-8 weeks) and carry a measurable CTA click-through; A/B the framing
> per Cat 73.
