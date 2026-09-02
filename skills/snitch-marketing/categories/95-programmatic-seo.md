## CATEGORY 95: Programmatic SEO audit

Programmatic SEO is the practice of generating thousands (or millions) of pages from a template, fed by a structured dataset, `[city] + [service]`, `[product] + [feature]`, `[language A] to [language B]`, `[tool] alternative`. Done well, it owns long-tail SERP at scale (Zapier integrations, Wise currency converters, Tripadvisor city pages, G2 software comparisons). Done poorly, it spawns thousands of near-duplicate, thin, low-value pages that trigger spam-update demotions and crawl-budget waste.

Quantify the near-duplication rather than asserting it: compute Jaccard similarity across the templated set per `references/content-intelligence.md` (flag pairs above 0.80, shingling the main content region only), and quote the URL pair + similarity figure as the evidence.

This category audits the discipline of templated page generation: uniqueness, content depth, sitemap shape, indexability gating, and AI-content-tell density.

### Pre-flight: relevance check

Skip with reason `not applicable` if the site has fewer than ~50 templated pages OR generates pages individually (no template). Run only when the site clearly has a programmatic surface, long URL patterns repeated with one variable changing (`/integrations/[tool]`, `/locations/[city]`, `/compare/[a]-vs-[b]`).

### The framework: 5 layers

Programmatic SEO problems decompose into five layers. Audit each in order.

| Layer | Question it answers | Failure looks like |
|---|---|---|
| **1. Demand** | Does each generated page target a real query a real user types? | Pages exist for queries with zero search volume; templated by exhaustive cartesian product of two lists |
| **2. Uniqueness** | Is each page substantively different from its siblings, beyond variable swap? | Pages are 95%+ identical with only the variable changed; Google's near-duplicate detection collapses them |
| **3. Depth** | Does each page provide enough unique value to justify ranking? | Thin templated text (200 words of swapped variables); no original data, no use-case-specific info |
| **4. Indexability gating** | Do you let Google index ALL the pages, or only the ones worth indexing? | All N pages indexed regardless of whether they have data; sitemap explosion + crawl-budget waste |
| **5. Quality monitoring** | Do you track which pages actually earn impressions and prune the dead weight? | No GSC integration on programmatic surface; can't tell which pages are working |

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify the programmatic surface: route templates with dynamic params (`[slug]`, `[city]`, `[tool]`, `:id`). Quote the route file.
2. Read the data source feeding the template (JSON / CSV / DB query / CMS collection). Quote a sample record + total record count.
3. Read the page template. Quote the visible content blocks. Identify which blocks vary per record vs which are static.
4. Compute approximate pages-by-variable-only-swap percentage: `(static_words / total_words) * 100`. >70% static = uniqueness risk.
5. Check sitemap inclusion. Does the sitemap list every templated page or only those meeting a quality bar?
6. Check `robots.txt` / route-level `noindex`. Are obvious-thin pages excluded from index?
7. If GSC is available: pull impressions/clicks per templated URL. Identify pages that have been live >90 days with 0 impressions.

**Crawl mode, required tool calls:**

1. Sample 10-20 templated URLs (mix of likely-popular and likely-rare variables).
2. Compute pairwise content overlap. Quote sections that are identical across samples.
3. Check sitemap for total templated URL count.
4. Search a representative templated query in Google. Note whether the brand's templated page ranks AND whether competitors' programmatic pages rank.

### Forbidden claims

- "These pages are probably thin." Quote two sample pages side-by-side; show the overlap.
- "Crawl budget is probably wasted." Show sitemap URL count + an approximate index-coverage estimate from GSC if available.
- "Google may have demoted these." Quote the date the templated surface was launched + any traffic-shape evidence.

### Detection

Route-template and data-source read across the generated page set, then per-layer scoring of the sampled pages.

### What to Search For

- Route patterns with dynamic params + a data source feeding many records
- Templates with high static-content ratio (most of the page is the same string with one swap)
- Sitemaps with thousands of URLs that follow a repeating pattern
- Programmatic URLs with no `noindex` gate + no quality threshold
- Programmatic URLs that have been live but earned 0 impressions per GSC

### Actually Hurts the Marketing Surface

- **Thin templated content (200-400 words mostly static, one variable swap)**.
  Evidence required: two URLs side-by-side, with content overlap quoted.
- **Pages exist for queries with no demand** (cartesian product of two lists where most combinations have no search volume, e.g., `[city] + [niche service]` for cities the service doesn't even operate in).
  Evidence required: sample URL + zero-volume context (GSC impressions or third-party tool).
- **All templated pages indexed regardless of whether they have data** (a `[city]` page exists for cities with no data, just an empty template).
  Evidence required: sample URL with empty / placeholder content.
- **Sitemap lists every templated URL** (sitemap explosion; crawl budget on dead pages).
  Evidence required: sitemap URL count + sample of low-quality URLs included.
- **No `noindex` gate on programmatic surface**, Google indexes all of it, including the worthless 80%.
  Evidence required: page-level `<head>` + missing conditional `noindex`.
- **No GSC impression-based pruning workflow** (no process to identify and `noindex`/redirect/delete the dead pages after launch).
  Evidence required: GSC absent OR no documented pruning cadence.
- **AI-generated content tells across templated pages** (the template was filled by an LLM with no human review; over-hedged language, generic transitions, made-up stats). Cross-reference Cat 59.
  Evidence required: quoted phrases from sample pages.
- **No internal linking between sibling templated pages** (the topical authority compound effect is missed).
  Evidence required: sample page + missing inter-template links.
- **Canonical conflicts** (multiple variant URLs, `/integrations/slack`, `/integrations/Slack`, `/integrations/slack-app`, all returning 200 with no canonical).
  Evidence required: 3+ variant URLs returning 200.

### NOT a Problem

- Programmatic page with deep, original, data-backed content per record (Wise's currency-converter pages with live rates + historical data + region-specific notes).
- Programmatic surface with conditional `noindex` for thin records (Tripadvisor sometimes noindexes city pages with <N businesses).
- Programmatic surface with documented pruning cadence (regular review of GSC zero-impression URLs).
- Multi-language programmatic with hreflang done correctly (Cat 50).

### Context Check

1. What's the data source per record? Live data, original research, structured database, strong. Variable swap with no record-specific data, weak.
2. What's the unique-content-per-page floor? <300 words of unique content per page is too thin.
3. Is there a quality gate before publishing? Records below the quality bar should not generate a page.
4. Is the sitemap selective? Only pages worth indexing should be in the sitemap.
5. Is there a pruning workflow? Programmatic surfaces decay; pages that earn no impressions after 90+ days are crawl-budget waste.

### Reference

Programmatic SEO playbook (Tom Hirst): https://tomhirst.com/programmatic-seo

Google's Spam Update guidance: https://developers.google.com/search/blog/2024/03/core-update-spam-policies

Google's Helpful Content Update guidance (often demotes programmatic-thin): https://developers.google.com/search/blog/2022/08/helpful-content-update

**Severity tagging:**
- Thin templated content (>70% static) → High.
- Cartesian-product pages with no demand validation → High.
- Sitemap lists every templated URL → Medium.
- No `noindex` gate on programmatic surface → High.
- No GSC-based pruning workflow → Medium.
- AI-content tells across templated pages → High.
- Canonical conflicts on variant URLs → Medium.

**Fix voice:** `solutions-architect` (primary) | `honest-design-critic` (backup).

Read `souls/solutions-architect.json` before writing the Fix.

Worked fix example:

> Programmatic SEO works when each generated page is a thin layer over a thick data source. The page is the projection; the data is the substance. If the data per record is shallow, no template fixes that, the architecture is wrong, not the markup.
>
> Three controls to add, in order.
>
> **1. Quality gate at generation time.** A record without enough unique data does not generate a page. Codify the threshold: minimum unique-content character count, minimum field count, minimum data freshness.
>
> ```ts
> // generation-time gate
> for (const record of records) {
>   if (uniqueContentLength(record) < 800) continue;        // not enough substance
>   if (fieldCompleteness(record) < 0.7) continue;          // missing data
>   if (daysSinceUpdate(record) > 365) continue;            // stale
>   await generatePage(record);
> }
> ```
>
> **2. Indexability gating.** Pages that exist but didn't pass the quality gate get `noindex` rather than getting deleted, they may still serve internal navigation. Sitemap includes only the indexable subset.
>
> **3. Pruning telemetry.** A scheduled job pulls GSC impressions per URL on the programmatic surface. URLs at 0 impressions for 90+ days get a downgrade decision: improve the data, redirect to a richer parent, or `noindex` permanently.
>
> The pattern at the architectural level: data quality controls page existence; page existence controls index inclusion; index inclusion is monitored and pruned. Each step is a deliberate decision, not a default.
