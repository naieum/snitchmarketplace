## CATEGORY 98: Internal site search audit

If the site has its own search (a `/search` route, an Algolia/Typesense/Meilisearch widget, a CMS-built search), the queries users type into it are the highest-signal data the brand owns about audience intent. Every search that returns zero results is a content gap, a navigation gap, or a vocabulary gap. Most teams instrument the search box but never read the search log; the gold sits there untouched. This category audits the existence, quality, and feedback loop of internal site search.

### Pre-flight: relevance check

Skip with reason `not applicable` if the site has no internal search functionality (small marketing site, single-page brand, very small documentation site). Otherwise: required.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for search-widget integrations: `Algolia`, `algoliasearch`, `typesense`, `meilisearch`, `instantsearch`, `useSearch`, `<SearchBar`, `/api/search`. Quote integration locations.
2. Read the search route / API handler. Quote the search query handling (what does it search? title? body? tags? all?).
3. Check for search analytics integration: events fired on search (Cat 55) capturing query string + result count + clicked-through result (or zero-result outcome).
4. If there's a search-analytics dashboard or log, sample the top 50-100 zero-result queries from the past 90 days. Quote them.

**Crawl mode, required tool calls:**

1. Locate the search box on the site. Inspect the form action / API endpoint.
2. Run 5-10 representative queries (terms a target customer might use). Quote results returned + relevance.
3. Run intentionally common but might-not-have-content queries (`pricing`, `enterprise`, `roadmap`, `careers`, `competitor name`, `compare`). Note which return zero results.

### Forbidden claims

- "Search probably returns poor results." Run real queries and quote outputs.
- "Zero-result queries are probably common." Pull the actual search log if available, or note the audit is partial.
- "Search analytics may be missing." Show the missing event in the source / analytics console.

### What to Search For

- Search-widget integration files
- Search API handler
- Search analytics events (query, results count, clicked result)
- Search-results template (what's shown when zero results return, empty state, "no results" message, suggested alternatives)
- Search log dashboard or export (if accessible)

### Actually Hurts the Marketing Surface

- **No internal search analytics** (the search box exists but the team has no log of what users typed).
  Evidence required: search integration present + missing analytics event.
- **Zero-result queries with high frequency for content the team SHOULD have** (`enterprise pricing` returns nothing on a B2B SaaS; `refund policy` returns nothing on an e-commerce; `interview at <brand>` returns nothing on a careers-heavy brand).
  Evidence required: zero-result query + the topic the brand should clearly cover.
- **Empty-state UX is a dead end** (the "no results" page just says "no results" with no recovery path: no suggested searches, no popular pages, no "contact us if you can't find it" CTA).
  Evidence required: search-results template content for the empty case.
- **Search ranking ignores recency / popularity / authority** (search returns matches by lexical match only; doesn't surface the most-visited or most-recent piece on a topic).
  Evidence required: query returning lower-quality result first, when a higher-quality result exists.
- **No synonym / alias handling** (`bug` doesn't match `issue`; `pricing` doesn't match `cost` / `price`).
  Evidence required: query returning zero/poor results when an obvious synonym would match.
- **Search log shows brand-name queries with zero results on the brand's own site** (someone searched the brand on the brand's site, content for that query should exist).
  Evidence required: brand-name query + zero results.
- **Search results unindexed for external SEO** (the `/search?q=...` URLs return 200 with no `noindex`, Google indexes them as thin content).
  Evidence required: sample search URL + missing `noindex`.

### NOT a Problem

- Internal search returns no results for genuinely off-topic queries (`pizza recipe` on a security tool's site), correct.
- Search-result URLs `noindex`'d, correct.
- Small site with no search box, not a Cat 98 candidate (skipped pre-flight).

### Context Check

1. Does the team look at search logs? Many teams instrument and never review.
2. What's the floor on result quality? Does the search match by exact phrase only, or by tokens / fuzzy / semantic?
3. Are zero-result queries a feedback loop into content production (a routine "what did users search for that we don't have" pull)?
4. Does the empty-state page surface the most-visited pages as a fallback?
5. Is `/search?q=...` `noindex`'d? If not, it's a thin-content liability.

### Reference

Algolia analytics docs: https://www.algolia.com/doc/guides/search-analytics/

Typesense search analytics: https://typesense.org/docs/

Site-search analytics in GA4: https://support.google.com/analytics/answer/1012264

**Severity tagging:**
- No internal search analytics → High.
- High-frequency zero-result queries on topics the brand should cover → Critical (content gap evidence).
- Empty-state with no recovery path → High.
- Search ignores recency / popularity → Medium.
- No synonym handling → Medium.
- Brand-name queries return zero results on own site → High.
- Search results pages indexed → Medium.

**Fix voice:** `analytics-engineer` (primary) | `frank-chimero` (backup).

Read `souls/analytics-engineer.json` before writing the Fix.

Worked fix example:

> Internal search is the highest-signal data source the brand owns about audience intent. Every query is a customer telling you, in their words, what they're trying to find. The team that reads the search log writes the next quarter's content; the team that doesn't makes content the team thinks customers want.
>
> Three additions, in order.
>
> **1. Instrument the search.** Capture every query, the result count, and whether the user clicked a result. Three events: `search_submitted`, `search_results_displayed` (with `result_count`), `search_result_clicked` (with the clicked URL). Tie the events to a session ID so you can see the full intent journey, not just isolated queries.
>
> **2. Build the zero-result report.** A weekly query against the analytics warehouse: top 50 queries with `result_count = 0` in the last 7 days, sorted by frequency. Pipe this report into the content-planning channel.
>
> **3. Fix the empty state.** When zero results return, don't say "no results." Show the most-visited pages on the site, surface a "Can't find it? Email us" CTA with a pre-populated subject, and (if the search platform supports it) suggest the closest near-match.
>
> The compounding payoff: the zero-result report drives the content roadmap; the content roadmap closes the gaps; closed gaps reduce zero-result frequency. The search box becomes a conversation, not a black hole.
