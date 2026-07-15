## CATEGORY 132: SERP-overlap topic clustering + cannibalization

Two pages can read as different topics and still be fighting for the same search results.
Text similarity does not settle that question; the search engine does. This category clusters
the brand's pages and target queries by the results they actually share, not by how alike their
words are. For any two queries, fetch the top 10 results for each and count how many URLs appear
in both. That shared-URL count is the signal: it shows how the engine sees the relationship
between the two topics, and it tells you how the content around them should be structured.

The overlap count maps to a structural decision:

| Shared URLs in top 10 | What the engine is saying | What the content should do |
|---|---|---|
| **7-10** | Effectively the same SERP | One page should serve both queries. If the brand has two separate pages here, that is cannibalization: merge them, or differentiate the intent so they stop competing. |
| **4-6** | Same cluster, distinct facets | Keep separate pages, but interlink them under one hub. |
| **2-3** | Lightly related | A single contextual cross-link is enough. |
| **0-1** | Separate topics | Do not force a link. |

The audit produces two outputs: a hub-and-spoke map (which pages belong under which hub, and
where the interlinks are missing) and a cannibalization list (pairs where two of the brand's own
URLs sit in the same top 10, splitting ranking signals between pages that should be one).

Scope note: distinct from Cat 86 (keyword research + demand capture), Cat 121 (information
architecture / site structure), and Cat 19 (internal link graph / orphans). This category
specifically uses SERP overlap to decide cluster boundaries and to catch self-cannibalization.
`references/content-intelligence.md` provides the source-only TF-IDF / near-duplicate
cannibalization signal used when live SERP data is unavailable.

### Pre-flight: relevance check

Skip with reason `not applicable` for a single-page brand or any site with too few distinct
content pages to form meaningful query pairs (no cluster to build, nothing to cannibalize). Skip
with reason `no data source` only when both are true: no web/crawl access for SERP fetching AND
no set of the brand's own indexable pages to run the source-only fallback against. Required for
any multi-page site that targets distinct queries across blog, docs, feature, landing, or
comparison pages. Borderline (a young site with a handful of pages): run it in source-only mode,
flag any near-duplicate cannibalization, and note that the cluster map needs a re-run once SERP
access is available.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Read `.snitch-marketing-context.md` for the ICP and the brand's target queries / topics, and
   pull the target-query inventory from Cat 86 (keyword research) if it ran. This page-to-query
   map is what the clustering operates on.
2. Without web access there is no SERP to fetch, so fall back to the source-only signal in
   `references/content-intelligence.md`: compute cross-page near-duplicate (Jaccard on shingled
   main-content tokens, flag pairs above 0.80) and TF-IDF cannibalization (cluster pages by
   primary target term from title + H1 + lead body) across the brand's own pages. Quote the URL
   pair and the computed figure for every flagged pair.
3. Label every source-mode finding as produced by the source-only method, and state plainly that
   it is a weaker signal than SERP overlap: it measures text similarity, not how the engine ranks
   the pages. Recommend a re-run with SERP access to produce the actual cluster map.

**Crawl mode, required tool calls:**

1. Collect the brand's target queries (from Cat 86 output or from each page's evident target
   query) and reduce to the meaningful pairs worth testing (10-20 queries max per audit, to keep
   fetches bounded).
2. For each query, fetch the top 10 results and retain the result URLs, not just the titles:
   `Bash curl -s "https://www.google.com/search?q=<URL-encoded-query>" | grep -oE 'https?://[^"&]+' | head -40`,
   then dedupe to the top-10 organic result URLs. Record the top-10 URL set per query (this is
   the same free SERP fetch Cat 86 Stage 3 uses, keeping the URLs).
3. For each meaningful query pair, count the shared URLs across the two top-10 sets and apply the
   threshold table. Build clusters from the 4-6 and 7-10 bands.
4. Flag cannibalization: any SERP where two of the brand's OWN URLs appear in the same top 10, or
   any 7-10-overlap pair the brand serves with two separate pages. Record both owned URLs and the
   shared SERP.

### Forbidden claims

- "These two queries share a SERP." Not without having fetched both top-10 sets and counted the
  overlap. No overlap claim without the two URL sets.
- "These two pages cannibalize each other." Not without showing both owned URLs in the same top
  10 and the shared SERP. In source-only mode, not without the high Jaccard / TF-IDF figure and
  the same target intent. Name the method.
- "This is the same cluster" / "force a hub here." Not without the overlap band that puts the
  pair in the 4-6 or 7-10 range. The band is the evidence.
- Never present a source-only finding as a SERP-overlap finding. The two methods measure
  different things; state which one produced the finding.

### Detection

Pairwise SERP-overlap clustering (shared top-10 URL count, banded by the threshold table) for
cluster boundaries and self-cannibalization when web/crawl access is available; source-only
near-duplicate + TF-IDF cannibalization from `references/content-intelligence.md` across the
brand's own pages when it is not. Every finding states its method.

### What to Search For

- Two of the brand's own URLs in the same top 10 for a commercial-intent query (both ranking,
  splitting signals)
- A query pair with 7-10 shared URLs that the brand serves with two separate pages (one page
  should serve both)
- A 4-6-overlap cluster with no hub page and no interlinks between its members (scattered pages
  the engine already treats as one topic)
- Near-duplicate own pages (Jaccard > 0.80) targeting the same intent, in source-only mode
- Lightly-related pages (2-3 overlap) with no contextual cross-link where one would help the
  reader
- A hub page that does not link down to its spokes, or spokes that do not link up to the hub
  (broken cluster wiring; cross-ref Cat 19)

### Actually Hurts the Marketing Surface

- **Two owned pages on the same SERP for a high-value query.** They compete with each other; the
  engine splits ranking signals between them and may rank neither well. This is self-inflicted.
  Evidence required: the query, both owned URLs in the same fetched top 10, and the shared-URL count.
- **A 7-10-overlap query pair served by two separate pages.** The engine treats them as one
  search; maintaining two pages divides the authority that should sit on one.
  Evidence required: the two queries, their top-10 sets, the 7-10 overlap count, and the two competing owned URLs.
- **A 4-6-overlap cluster with no hub and no interlinking.** The pages belong to one topic the
  engine already recognizes, but nothing ties them together, so none accrues cluster authority.
  Evidence required: the cluster's queries, their pairwise overlap counts in the 4-6 band, and the absent hub / interlinks (cross-ref Cat 19, Cat 121).
- **Source-only near-duplicate pages targeting one intent.** Two pages substantially the same by
  text, aimed at the same query, with no canonical authority.
  Evidence required: the URL pair, the Jaccard (or TF-IDF) figure from `references/content-intelligence.md`, and the shared target intent, labeled as the source-only method.
- **Lightly-related pages with no cross-link.** A 2-3-overlap pair where one contextual link
  would help the reader and the engine, and there is none.
  Evidence required: the pair, the 2-3 overlap count, and the missing contextual link.

### NOT a Problem

- Distinct pages with genuinely low overlap (0-1 shared URLs). Separate topics; do not force a
  link between them.
- An intentional pillar/hub page plus spoke pages that are already interlinked correctly. Pass,
  and note the structure is sound.
- A single page targeting a cluster of close variants (the 7-10 band consolidated onto one URL).
  That is correct consolidation, not a gap.
- Two of the brand's pages appearing in one top 10 where they serve genuinely different intents
  (for example a docs page and a pricing page both surfacing for a branded query). Co-presence is
  not always cannibalization; confirm the intents actually collide before flagging.
- A young site with too little content to cluster. Note "re-run when there are enough pages to
  form clusters," not a finding.

### Context Check

1. Did Cat 86 (or the page targeting) produce a target-query inventory to cluster, or are the
   queries inferred? Inferred queries weaken every overlap claim.
2. Was the overlap measured from fetched SERPs, or is this the source-only fallback? State the
   method on every finding.
3. For each flagged cannibalization pair: are both URLs actually the brand's own, and do they
   serve the same intent, or do they merely co-occur?
4. For each 4-6 cluster: does a hub page exist, and are the spokes linked to it and to each other
   (cross-ref Cat 19)?
5. Is a 7-10 overlap a consolidation opportunity (merge to one page) or a differentiation one
   (sharpen each page's intent so they stop competing)?
6. Could SERP volatility have produced a one-off overlap reading? In volatile niches, confirm the
   overlap holds across a second fetch before acting.

### Reference

The hub-and-spoke / topic-cluster content model: a pillar (hub) page covers a topic broadly and
links to and from focused spoke pages, concentrating topical authority on the hub. SERP overlap
as a clustering signal: queries that share top-10 results want the same page (the same mechanical
signal Cat 86 Stage 3 uses for cluster building).

`references/content-intelligence.md` for the source-only near-duplicate (Jaccard > 0.80) and
TF-IDF cannibalization fallback.

Cross-ref: Cat 86 (keyword research + demand capture), Cat 121 (information architecture / site
structure), Cat 19 (internal link graph / orphans), Cat 95 (programmatic SEO / near-duplication
at scale).

**Severity tagging:**
- Two owned pages cannibalizing a high-value commercial query (both in the same top 10, splitting signals) → High.
- A 7-10-overlap pair served by two separate pages → High (merge or differentiate).
- A 4-6-overlap cluster with no hub and no interlinking → Medium.
- Source-only near-duplicate cannibalization on the same intent → Medium (weaker signal; re-run with SERP access).
- Scattered lightly-related pages (2-3 overlap) missing a contextual cross-link → Low.

**Fix voice:** `brad-frost` (primary) | `solutions-architect` (backup).

Read `souls/brad-frost.json` before writing the Fix.

Worked fix example:

> Stop thinking about these as separate pages. You're designing a system, and right now two of
> them are quietly competing to be the same instance of it.
>
> Build the inventory first. Lay the query, the page that targets it, and the top-10 URLs it
> shares with its neighbors side by side in one table. The moment you see two of your own URLs
> sitting in the same search results, the problem stops being abstract; it's right there,
> undeniable, the way a button audit makes six near-identical buttons impossible to defend.
>
> Now read the overlap and let it dictate the structure:
>
> 1. **7-10 shared**: same SERP. This is one component, not two. Merge the pages onto a single
>    canonical URL and 301 the other to it, or sharpen each one's intent until they stop
>    overlapping. Two instances of the same thing is exactly the inconsistency you're killing.
> 2. **4-6 shared**: same cluster. Keep the pages, but give them a hub. The pillar page is the
>    organism; the spokes are its parts. Link the hub down to every spoke and every spoke back up
>    to the hub, so the cluster reads as one system to a reader and to the engine (Cat 19).
> 3. **2-3 shared**: lightly related. One contextual link between them, placed where it actually
>    helps the reader. No hub, no ceremony.
> 4. **0-1 shared**: separate topics. Leave them alone. Forcing a link here is just noise.
>
> Make the right thing the easy thing: write the cluster map down (hub, spokes, the links that
> wire them) so the next person adding a page slots it into the system instead of starting
> another snowflake that competes with what's already there.
>
> Verify by re-fetching the SERPs after the merges land. The signal you want is the
> two-own-URLs collisions gone, and one page per cluster climbing where two used to split the
> vote. If you ran this without live SERP access, treat the text-similarity matches as a flag,
> not the map, and re-run the overlap pass once you can fetch the results.
