## CATEGORY 86: Keyword research + intent mapping

The queries the audience actually types, classified by what they want when they type them, clustered by SERP overlap, prioritized by leverage. Most teams skip this and write content for what they wish people searched for; the result is content that ranks for nothing.

Include a cannibalization pass: detect multiple pages targeting one query/intent (they split rankings and confuse which page an engine should cite) using the method in `references/content-intelligence.md`. Name the competing URLs, the shared target intent, and which page should be the canonical authority.

### Pre-flight: relevance check

Skip if the brand is in a niche too narrow for query-volume measurement (highly specialized B2B, novel category with no established search behavior). Otherwise this category is universally applicable, every brand has queries it should rank for, even if it doesn't yet.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. From STEP 0.5 Discovery + STEP 0.7 Competitor Research: extract the brand's stated topics and the competitor positioning H1s.
2. `Read` `/blog`, `/docs`, and `/changelog` route titles + headings to capture topics the brand has already produced content for.
3. If Google Search Console export is available: read it for existing query/click/impression data.

**Crawl mode, required tool calls:**

1. For each candidate query (10-20 max per audit): `Bash curl -s "https://www.google.com/search?q=<URL-encoded-query>" | grep -oE '<h3[^>]*>[^<]+</h3>' | head -10`, capture top-10 SERP results to infer intent (informational vs commercial pages dominate?).
2. Quote the SERP shape for each query (page types ranking, presence of AI overview, presence of People-Also-Ask, presence of paid ads, presence of brand pages).
3. Check Google's "People Also Ask" panel and "Related searches" at the bottom of each SERP for query expansion.

### Forbidden claims

- "Volume is probably high." Without a keyword tool's volume data, you don't know. Either get the data (Ahrefs / Semrush / GSC export) or report queries without volume claims.
- "This is a low-competition keyword." Same, without difficulty score or SERP analysis, you don't know.
- "Customers probably search for X." Either GSC shows it OR a community / forum / customer interview confirms it OR you found it in a real SERP. Don't invent queries.

### The framework: 4 stages

#### Stage 1: Capture demand

Cast a wide net. Sources, in order of signal quality:

- **Google Search Console** (existing site): the queries already bringing impressions/clicks. Highest signal because real.
- **Customer language**: support tickets, sales calls, onboarding survey responses, reviews on G2/Capterra/Reddit. The words customers actually use.
- **Competitor SERP scrape**: queries where competitors rank in top 10. Use SERP inspection or a keyword tool's competitor-export.
- **Forum/community language**: niche subreddit, Slack, Discord, Stack Overflow, Hacker News for the relevant tag/category.
- **Auto-suggest**: Google's autocomplete, Bing autocomplete, YouTube autocomplete (different intents per surface).
- **People Also Ask + Related Searches** in actual SERPs.

Goal for an audit pass: 50-200 candidate queries. More if planning a year-long content sprint.

#### Stage 2: Classify intent

Every query maps to one of four intents. The page that wins depends on the intent. Get this wrong and even perfectly-written content ranks for nothing.

| Intent | Signal phrases | Page that wins SERP |
|---|---|---|
| **Informational** | "how to", "what is", "why", "guide to", "tutorial" | Article, guide, tutorial, video |
| **Navigational** | brand or product name + modifier | Brand homepage, product page, login page |
| **Commercial** | "best", "vs", "review", "alternative to", "comparison" | Listicle, comparison, review, "best of" roundup |
| **Transactional** | "buy", "price", "near me", "discount", "free trial" | Product page, pricing page, signup |

Mixed intents exist ("best running shoes under $100" is commercial + transactional). Treat as the dominant intent; note the modifier.

**Verification rule:** to classify intent, look at the actual SERP. If Google's ranking pages 1-10 are predominantly articles, the query is informational regardless of how it sounds. The SERP IS the intent answer; don't second-guess it.

#### Stage 3: Cluster by SERP overlap

Group queries that should target the same page. Two methods:

- **SERP overlap** (mechanical, reliable): if two queries share 3+ of the top 10 results, they want the same page. Build the cluster around the dominant query.
- **Topical relevance** (judgmental): "how to install Snitch CLI" and "Snitch CLI quick start" are the same topic, different facets. Group by underlying job-to-be-done.

A typical cluster: 1 primary query (highest volume in cluster), 3-8 secondary queries (long-tail variants), targeting one page that comprehensively addresses all of them.

In 2026, AI overviews complicate this, many informational queries get answered by the overview, no click needed. Clustering still matters because the overview cites sources; the source it cites is your page IF your page is the best target for the cluster. Cross-reference Cat 82.

#### Stage 4: Prioritize by leverage

Score each cluster on three dimensions:

1. **Demand (volume)**, how many people search this monthly. From keyword tool or GSC.
2. **Winnability (difficulty)**, can this brand realistically rank? Factors: domain authority gap, content depth needed, SERP saturation, AI-overview displacement risk.
3. **Business fit**, does ranking for this drive revenue? An informational query about a topic adjacent to your product is low business fit; a commercial query for "best <your-category>" is high.

Multiply: `demand × winnability × business fit` = leverage score. Sort. Top 10-20 clusters become the content backlog; the rest are noted for future sprints.

### Actually Hurts the Marketing Surface

- **No keyword research baseline at all** (team writes what feels right, not what users search for).
  Evidence required: blog content + missing keyword/intent rationale per post.
- **Existing content targets queries with no demand** (volume = 0 or near-zero in keyword tool).
  Evidence required: post topic + keyword tool's volume number for the implied target query.
- **Content targets the wrong intent** (informational article ranking for a transactional query, or vice versa).
  Evidence required: post intent + the SERP for the implied target query (different page type winning).
- **No clustering**, every post targets one query in isolation, missing topical authority compound effect.
  Evidence required: blog inventory + the absence of cross-linked topic clusters.
- **Targeting commercial queries with informational content** (the brand's "/best-x-tools" article is a competitor analysis instead of a product comparison).
  Evidence required: query + page content showing intent mismatch.
- **Branded queries unmonitored** (no GSC tracking, no defensive bid for brand-name searches per Cat 66).
  Evidence required: GSC absent OR no defensive Google Ad on brand search.

### Keyword cannibalization detection

When 3+ pages on the same site target highly-similar low-difficulty (KD <30) keywords, the pages compete with each other in the SERP. Google picks one to rank; the others either get suppressed entirely or rank in positions 30-100 with no clicks. The fix is usually consolidation: one comprehensive page replaces 3 thin pages, the consolidated page targets the cluster, and the 3 originals 301-redirect to it.

Audit application:

1. From Stage 1 capture and Stage 3 cluster maps, identify keyword clusters where the brand has multiple competing pages.
2. For each candidate cannibalization cluster, check the SERP: do any of the brand's pages rank? If two pages from the same site appear in the top 30 for the same query, cannibalization is confirmed.
3. Findings: 3+ pages targeting the same KD-<30 cluster with no ranking page is a Critical finding (the brand is fragmenting topical authority). 2 pages with one ranking and one suppressed is a High finding (consolidate; redirect the suppressed page; concentrate authority on the ranking one).

The consolidation pattern: pick the strongest page (highest topical authority + most internal links + best content), expand it to cover the full cluster (primary query + 3-8 long-tail variants), 301-redirect the thinner pages to the consolidated one. Internal links from the redirected pages preserve the redirect-source authority; the consolidated page inherits the equity.

### Linkable-asset inventory

Most ranking-by-content strategies stall because the brand has no shareable asset that earns links. A "linkable asset" is something on the site that other writers, podcasters, newsletter authors, or community members link to because it serves their audience — not because the brand asked. Patterns:

- **Free utility tools** (calculators, generators, format converters, comparison tables). Donothingfor2minutes.com pattern.
- **Original research / data** (a survey, a benchmark, a "we analyzed N samples and found X" report). Citation-bait for journalists.
- **Comprehensive references** ("the complete guide to X" with depth competitors don't match). Wikipedia-adjacent authority.
- **Interactive visualizations** (data viz, interactive demos, before/after sliders for transformations).
- **Templates / starter kits** ({thing} template, {thing} starter, opinionated stack).

The audit checks whether the brand has any of these. The pattern that earns links — and AI citations (cross-reference Cat 82 Layer 3 authority) — requires *something* worth linking to.

Audit application:

1. Inventory the brand's site for linkable assets. URLs like `/tools/`, `/calculator/`, `/template/`, `/research/`, `/benchmark/`, `/compare/` are candidates; also check Cat 95 (Comparison pages) output.
2. Findings: a brand with no linkable asset and active "we want to rank for {category} keyword" goals is structurally hard to grow. High-leverage recommendation: build one linkable asset before another six months of blog posts.
3. The recommendation specifies the asset type, not just "build something" — pick the asset type whose audience matches the brand's ICP, with the lowest production cost the brand can deliver in 90 days.

### NOT a Problem

- Brand-new site without GSC data yet. Use customer language + competitor scrape; volume data comes after launch.
- Niche so narrow that volume tools return "low volume" for everything, focus on long-tail + community signal.
- Single-page brand (one landing page), keyword research scope is just "what query brings people to this one page."
- Brands with deliberate content fragmentation strategies (e.g., one product page per geographic market) — that's intentional, not cannibalization, when the pages target geo-modified queries rather than identical queries.

### Context Check

1. Is GSC available? Without it, all volume claims are estimates from third-party tools.
2. Has the brand been live long enough for query data? <90 days = thin data.
3. Are competitors' SERP rankings stable enough to use as a benchmark? In volatile niches, last week's rankings are stale.
4. Does the team have content-production capacity to act on the prioritized list? A prioritized backlog with no writer is a wishlist.
5. Is AI-overview displacement likely for the cluster? If the top-10 SERP already shows an AI overview answering the query, ranking #1 may not earn the click. Cross-reference Cat 82.

### Reference

Google Search Console: https://search.google.com/search-console

Google Keyword Planner (free tier): https://ads.google.com/aw/keywordplanner

Ahrefs Keywords Explorer (paid): https://ahrefs.com/keywords-explorer

Semrush Keyword Magic Tool (paid): https://www.semrush.com/

**Severity tagging:**

- Brand publishes content with no keyword/intent rationale → High.
- Existing content targets zero-volume queries → High.
- Intent mismatch on indexed pages → High.
- No topic clustering → Medium.
- No GSC integration → Medium.
- Branded query bidding not in place (with paid budget) → Low (cross-reference Cat 66).

**Fix voice:** `frank-chimero` (primary) | `aaron-draplin` (backup, when the fix is "use the words customers actually use, not the words you wish they did").

Read `souls/frank-chimero.json` before writing the Fix.

Worked fix example:

> The content's job is to be found by the people looking for what it's about. That requires writing for the queries those people actually type, not the queries you'd prefer they typed.
>
> Pull GSC, export the queries already bringing impressions but ranking on page 2-3. Those are the wins closest at hand, the algorithm already thinks you're relevant; the page just needs to earn one more rank position. Pick 5 to optimize this quarter.
>
> For each: read the actual SERP. What page type is winning? If it's a comparison article and your page is a product page, rewrite the page (or build a sibling page) that matches the intent. The form follows the function; if the form is wrong, no amount of internal linking saves it.
>
> Cluster the rest by SERP overlap. Each cluster gets one comprehensive page that addresses the primary query plus 3-8 long-tail variants. Internal linking knits clusters together so the topical authority compounds.
