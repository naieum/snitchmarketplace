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
4. De-personalize every manual SERP check: logged out, private/incognito session, inspecting from (or emulating) the geography the brand wants to rank in — city/zip-level for local queries. Note the inspection location in the evidence; a personalized or wrong-geo SERP invalidates the intent read.
5. Interpret SERP features as intent evidence, not decoration, per the feature-to-intent map in Cat 58.

### Forbidden claims

- "Volume is probably high." Without a keyword tool's volume data, you don't know. Either get the data (Ahrefs / Semrush / GSC export) or report queries without volume claims.
- "This is a low-competition keyword." A difficulty score alone is never enough — scores are typically referring-domains-only proxies (see "Vetting winnability" below). The claim requires the score plus the five-check manual SERP validation. Score + eyeballs, never score alone.
- A keyword-difficulty number cited without naming the tool that produced it. Different tools' scores for the same keyword diverge wildly; an unattributed score is not comparable to anything.
- "High volume" as justification for targeting a query containing another brand's name. Navigational queries concentrate nearly all clicks on the brand's #1 result — position 3 gets almost nothing. Target one only when a non-brand page can fully satisfy the intent (a fact, number, or how-to about the brand: fair game; a login or homepage destination: skip).
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

Expansion moves that surface candidates competitors' researchers miss (every output still passes Stages 2-4):

- **Modifier filtering**: filter large expansions to intent-specific modifiers first — informational (how, what, why, tutorial, guide, list, ideas, tips, examples) or commercial-investigation (best, top, vs, review, price, cheap, alternative, comparison) — then apply a difficulty ceiling. Difficulty scores are most reliable on exactly these link-driven query classes.
- **Uncommon-seed subtraction**: pull a competitor's full keyword rankings and exclude every query containing the obvious seed words; the survivors are lesser-known head terms nobody else expanded. This mines for seeds, not keywords — each survivor gets its own expansion pass. Repeat the loop through competitors-of-competitors.
- **Brand-facet harvest** (bottom-funnel): scrape the brand/model list from a category-leading store's facet navigation, expand those names, filter to "vs" / "versus" / "review*". Purchase-adjacent queries that are typically near-zero on links. Exclude brand words that collide with common meanings.
- **SERP-changing modifier test**: a modifier is only a separate opportunity if it changes the SERP. Compare results for two values — different results = each value needs its own page; near-identical = one page covers all. A SERP-changing modifier over an enumerable set (states, years, models, cities) is a template for a coherent cluster of pages, and the SERP-difference test is exactly what separates legitimate programmatic pages from doorway spam: content must genuinely differ per instance.
- **Proven-winner mining**: search a page-level content index for pages already earning meaningful organic traffic (≥~500/month) with very few referring domains (≤~10) — each hit is proof its topic ranks without links. Use those pages' topics and top keywords as new seeds.

Goal for an audit pass: 50-200 candidate queries. More if planning a year-long content sprint.

#### Stage 2: Classify intent

Every query maps to one of four intents. The page that wins depends on the intent. Get this wrong and even perfectly-written content ranks for nothing.

| Intent | Signal phrases | Page that wins SERP |
|---|---|---|
| **Informational** | "how to", "what is", "why", "guide to", "tutorial" | Article, guide, tutorial, video |
| **Navigational** | brand or product name + modifier | Brand homepage, product page, login page |
| **Commercial** | "best", "vs", "review", "alternative to", "comparison" | Listicle, comparison, review, "best of" roundup |
| **Transactional** | "buy", "price", "near me", "discount", "free trial" | Product page, pricing page, signup |

Mixed intents exist ("best running shoes under $100" is commercial + transactional). Treat as the dominant intent; note the modifier. For genuinely fractured SERPs — one query serving several distinct audiences — rank the interpretations dominant > common > minor by how many top results serve each; build for the dominant intent, fall back to a common intent only when the dominant one is unservable by this site type, otherwise drop the keyword. Dominant intent is the only classification that must be right: in a practitioner exercise where three analysts classified the same keyword set, they diverged on secondary intents but always agreed on the dominant one. Full handling in Cat 58.

**Verification rule:** to classify intent, look at the actual SERP. If Google's ranking pages 1-10 are predominantly articles, the query is informational regardless of how it sounds. The SERP IS the intent answer; don't second-guess it.

Two lazy routes are banned: classifying from titles/snippets alone, and assigning a bucket without documenting the SERP evidence. Titles and URLs misrepresent pages — a SERP that reads as all lead-gen landing pages from its titles can actually be won by informational content. Open at least the top 3 ranking pages and record their content intent (what the page tries to do), not their SERP presentation. And classifications expire: SERPs re-shape when the world changes, so every intent read carries a freshness date (Cat 58 covers intent drift).

#### Stage 3: Cluster by SERP overlap

Group queries that should target the same page. Two methods:

- **SERP overlap** (mechanical, reliable): if two queries share 3+ of the top 10 results, they want the same page. Build the cluster around the dominant query.
- **Topical relevance** (judgmental): "how to install Snitch" and "Snitch quick start" are the same topic, different facets. Group by underlying job-to-be-done.

A typical cluster: 1 primary query (highest volume in cluster), 3-8 secondary queries (long-tail variants), targeting one page that comprehensively addresses all of them.

AI overviews complicate this: many informational queries get answered by the overview, no click needed. Clustering still matters because the overview cites sources; the source it cites is your page IF your page is the best target for the cluster. Cross-reference Cat 82.

#### Stage 4: Prioritize by leverage

Score each cluster on three dimensions:

1. **Demand (traffic potential)**, how many visits ranking would actually earn. A single keyword's volume understates or misstates this because a page ranks for many queries; the better estimator is the total organic traffic of the current top-3 ranking pages (any tool with page-level traffic estimates). Low-volume keyword + high top-page traffic = hidden opportunity; the inverse — high volume, low top-page traffic, common when a SERP feature absorbs the clicks — is a trap. Fall back to keyword volume or GSC only when page-level estimates are unavailable.
2. **Winnability (difficulty)**, can this brand realistically rank? Factors: domain authority gap, content depth needed, SERP saturation, AI-overview displacement risk, SERP stability (Context Check 3), and the difficulty-score caveats in "Vetting winnability" below. Read rank inversions as signal: a page outranking others with materially more referring domains isn't noise, it's the SERP telling you what wins. Diagnose the cause — closer intent/angle match, more topically focused domain, or tighter relevance to the query's modifier — because the diagnosis dictates the play.
3. **Business fit**, does ranking for this drive revenue? An informational query about a topic adjacent to your product is low business fit; a commercial query for "best <your-category>" is high.

Multiply: `demand × winnability × business fit` = leverage score. Sort. Top 10-20 clusters become the content backlog; the rest are noted for future sprints.

### Vetting winnability: what difficulty scores miss

Keyword-difficulty scores are typically a weighted average of referring domains to the current top-10 pages — a links-count-only proxy. They ignore link quality (topical relevance of the linking domains, authority of the linking pages), domain-level authority, brand equity, on-page factors, and intent. Consequences for the audit:

- Scores are relative to the auditee. A "5" whose top 10 are all high-authority domains is easy for a peer-authority site and hard for a new one; there is no absolute "low."
- Scores are most trustworthy for informational and commercial-investigation queries, where rankings are link-driven; least trustworthy for transactional head terms, where brand equity dominates — a near-zero difficulty score on a head product query whose SERP is wall-to-wall mega-retailers is unrankable for anyone who isn't a peer brand.
- In YMYL niches (health, finance), weigh E-E-A-T on top of any score.
- Inversion for link building: high-difficulty informational queries mean the top pages hold many backlinks — a dense pool of link prospects. Earning links on those topics and routing the equity internally to money pages is the middleman pattern (Cat 19).

**Five-check manual validation**, run per SERP before any keyword is declared low-competition:

1. **Intent match** — can this site type produce the dominant content type/format? If not, stop.
2. **Authority mix** — are low-authority sites present in the top 10? Their presence proves the query is penetrable; an all-mega-brand SERP is brand-gated regardless of the score.
3. **Topical authority** — do the ranking domains specialize in this topic, and does the auditee's?
4. **Page specificity** — are the top pages exactly on this query, or on a broader parent? Generic pages ranking = room for a specific page to win.
5. **Top page's link quality** — count the #1 page's referring domains, then check their quality: authority of the linking sites, followed vs nofollow. A page held up by a handful of low-authority, mostly-nofollow links is beatable on content.

Portfolio guardrail: low-competition targets suit new/low-authority sites but shouldn't be the whole strategy — competitive topics carry more traffic, links, and commercial value; take them with a realistic time horizon.

### Detection

Four-stage read: capture demand from the sources above, classify intent, cluster by SERP overlap, prioritize by leverage.

### What to Search For

**In source (the auditable half — this is where a Finding gets its `file:line`):**
- A checked-in keyword or topic map: `keywords.json`, `keywords.csv`, `topics.*`, `content-plan.*`, `editorial-calendar.*`, or a `keywords:` / `targetKeyword:` field in post frontmatter
- Frontmatter fields that record intent or a target query per post (`intent:`, `query:`, `primaryKeyword:`, `searchIntent:`)
- Titles and H1s across `content/`, `posts/`, `blog/`, `docs/` — the implied target query of each page, and repeats across pages (the cannibalization input)
- Slugs that collide or near-collide (`/best-x`, `/x-best`, `/top-x`) targeting one query with several pages
- Internal-link anchor text pointing at those pages, which reveals which page the site itself treats as canonical for the query
- Linkable-asset shapes already present: calculators, comparison tables, datasets, glossaries, free tools under `/tools/`, `/calculator/`, `/compare/`

**Off-site (needs a keyword tool, `WebSearch`, or user-pasted exports — else Skip-with-reason):**
- Volume, difficulty and SERP composition for each implied target query
- Which of the site's own pages currently rank for the same query (the cannibalization confirmation)

Never assert a volume, a difficulty score, or a SERP composition that was not captured this run.

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

1. Inventory the brand's site for linkable assets. URLs like `/tools/`, `/calculator/`, `/template/`, `/research/`, `/benchmark/`, `/compare/` are candidates; also check Cat 122 (Comparison / alternatives pages) output.
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
3. Are the target SERPs stable? Where ranking history is available, check the top 5-6 results over ~12 months. Stable for a year = intent is settled; difficulty and link-gap analysis are reliable, but incumbents are entrenched, so wins come slower. Churning top 10 = the engine itself is unsure of the intent; discount the projected traffic, flag intent as unclear, and prefer the query only for fast experiments.
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
- Backlog prioritized on raw volume or an unvalidated difficulty score (no manual SERP validation, no top-page traffic estimate) → Medium.
- Targeting another brand's navigational queries the site cannot serve → Medium.
- Branded query bidding not in place (with paid budget) → Low (cross-reference Cat 66).

**Fix voice:** `content-shape-editor` (primary) | `plain-language-designer` (backup, when the fix is "use the words customers actually use, not the words you wish they did").

Read `souls/content-shape-editor.json` before writing the Fix.

Worked fix example:

> The content's job is to be found by the people looking for what it's about. That requires writing for the queries those people actually type, not the queries you'd prefer they typed.
>
> Pull GSC, export the queries already bringing impressions but ranking on page 2-3. Those are the wins closest at hand, the algorithm already thinks you're relevant; the page just needs to earn one more rank position. Pick 5 to optimize this quarter.
>
> For each: read the actual SERP. What page type is winning? If it's a comparison article and your page is a product page, rewrite the page (or build a sibling page) that matches the intent. The form follows the function; if the form is wrong, no amount of internal linking saves it.
>
> Cluster the rest by SERP overlap. Each cluster gets one comprehensive page that addresses the primary query plus 3-8 long-tail variants. Internal linking knits clusters together so the topical authority compounds.
