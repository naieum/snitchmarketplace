## CATEGORY 131: SXO — page-type / SERP-intent alignment

"Search Experience Optimization" reframes the question. Instead of asking "is my page
optimized?", it asks "is my page even the TYPE of result Google rewards for this query?"
For any target query, the current top-ranking results reveal Google's working consensus on
the page type and the intent that satisfy searchers: a listicle, a single product page, a
how-to guide, an interactive tool, a comparison table. If a page's type mismatches that
consensus, strong on-page SEO will not make it rank, because it is answering the wrong job.
This category reads the SERP backwards. It classifies the page types of the top results for
the page's primary target query, classifies the audited page's own type, and flags the
mismatch. It also reads the dominant intent (informational, commercial, transactional,
navigational) and checks whether the page's format serves it.

Scope note: this is distinct from Cat 58 (keyword targeting / intent match, keyword-to-page
relevance) and Cat 86 (keyword research plus SERP-overlap clustering for demand capture).
Those map demand and relevance. This one judges page-TYPE fit against the live SERP
consensus for one specific query. A page can target the right keyword and still be the wrong
type of result for it.

### Pre-flight: relevance check

Run this on money pages and target ranking pages: product, pricing, comparison, feature, and
cornerstone content pages that are trying to rank for a head or commercial query. Skip with
reason `not applicable` for a page that is not trying to rank for a generic query at all (a
pure brand/navigational page, a logged-in app surface, a legal/utility page). Borderline (a
blog post that also doubles as a conversion page): run it, scoped to the single query the
page most wants to win. If the page's primary target query cannot be established from the
page, from Cat 86 output, or by asking the user, record that and Skip rather than guess.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Read `.snitch-marketing-context.md` plus any Cat 86 output to establish the page's primary
   target query. If neither names it, infer the single most likely query from the page's H1,
   title, and lead copy, and state the inference.
2. Classify the audited page's own type from source: read the H1, the dominant content
   block, and the schema (`Read` the JSON-LD / page body). Is it a listicle, a single
   product/PDP, a how-to, a comparison table, an interactive tool, a long-form guide, a
   landing page? Record the type with the evidence that supports it.
3. The SERP-consensus side cannot be observed from source alone. Without crawl/web access you
   can classify YOUR page but not the competition. Say so explicitly and Skip the comparison
   with reason `SERP composition requires live web access; page type classified from source,
   consensus comparison deferred`.

**Crawl mode, required tool calls:**

1. Confirm the page's primary target query (page itself, Cat 86 output, or ask the user).
2. Fetch the top results for that query and classify each. Example:
   `Bash curl -s "https://www.google.com/search?q=<URL-encoded-query>" | grep -oE '<h3[^>]*>[^<]+</h3>' | head -10`,
   then open enough of the ranking URLs to classify each result's page TYPE (listicle,
   single product page, how-to, comparison, tool, guide, forum thread, video).
3. Compute the consensus type(s): which type(s) hold the majority of the top 10, and how many
   results each type holds. Note the presence of an AI overview, People-Also-Ask, and paid
   results, since they shape what "satisfies the searcher" looks like.
4. Derive the dominant intent (informational / commercial / transactional / navigational)
   from the page types that win, not from how the query sounds. The SERP is the intent
   answer.
5. Classify the audited page's type and place it against the consensus. Severity follows how
   rare the page's type is in the top 10: appears 0 times = mismatch; rare but present =
   partial; matches the majority = aligned.

### Forbidden claims

- Do not assert the SERP composition, the consensus type, or any competitor's rank without
  having fetched it. If you could not fetch the SERP, Skip-with-reason; never fabricate the
  top results or their positions.
- Do not claim "your page type is wrong" without quoting the consensus you observed: the top
  results and the type you assigned each. The judgment has to show its evidence.
- Do not call an intent mismatch from the query's wording alone. A query that sounds
  transactional but returns ten guides is informational. Read the SERP, not the phrasing.

### Detection

Crawl mode: establish the primary query, fetch the top ~10 results, classify each result's
page type, compute the consensus type(s) and dominant intent, classify the audited page's
type, and flag by how rare that type is in the top 10. Source mode: classify the audited
page's own type from source, then defer the consensus comparison to a crawl pass when web
access is available.

### What to Search For

- A money/target page whose type appears 0 times in the top 10 for its primary query (a blog
  post where the SERP is all product pages; a product page where the SERP is all comparison
  tables or listicles)
- A transactional or commercial query whose SERP is dominated by one page type, while the
  audited page is a different type that does not do that job
- A page type that is rare but present in the top 10 (partial mismatch: it can rank, but it
  is fighting the format the SERP rewards)
- An intent mismatch: the page's format serves a different intent than the one the SERP
  rewards (informational content aimed at a SERP full of PDPs, or vice versa)
- A SERP whose top results are an interactive tool or a calculator, while the audited page is
  static prose trying to win the same query
- A query the page clearly targets where the SERP already shows a settled consensus type the
  page does not match, with no plausible path to rank as-is

### Actually Hurts the Marketing Surface

- **A money/target page whose type appears 0 times in the top 10 for its primary query.** The
  page is the wrong kind of result for the job; on-page SEO will not move it, because Google
  has already decided what type of page satisfies this searcher.
  Evidence required: the top-10 results listed with the type assigned each, the consensus
  type, and the audited page's type quoted from its H1/content.
- **A transactional/commercial query served by the wrong format.** The SERP is all product or
  comparison pages and the audited page is a blog post (or the reverse), so the page answers a
  different job than the searcher is doing.
  Evidence required: the dominant intent derived from the winning page types, plus the audited
  page's format.
- **A partial type mismatch on a target page.** The page's type is rare in the top 10 but not
  absent; it can rank, but it is competing against the format the SERP favors.
  Evidence required: the count of each type in the top 10 showing the audited type is the
  minority.
- **An intent-format mismatch on a secondary page.** The page serves the wrong intent for its
  query, costing relevance even where the type is not fully disqualifying.
  Evidence required: the SERP-derived intent versus the page's served intent, both quoted.
- **A consensus the page could match but does not.** The winning type is well within the
  brand's ability to produce (a comparison table, a how-to), yet the page ships as a different
  type for no stated reason.
  Evidence required: the consensus type and the audited type side by side, with no
  differentiation rationale present on the page.

### NOT a Problem

- A brand or navigational page that is not trying to rank for a generic head term. Its job is
  the brand query, which it serves; the SERP for the head term is not its target.
- A page whose type already matches the SERP majority. Aligned is the pass state; note it and
  move on.
- A deliberately differentiated format that still satisfies the same intent: an interactive
  tool where the SERP is guides, when the tool genuinely answers the job better. Note it as
  intentional, not a break, and let the page's performance settle the bet.
- A page where the SERP shows no settled consensus (the top 10 are a mix of many types with
  no majority). There is no single "right" type to mismatch; record the spread, do not force a
  finding.
- A new page that has not had time to be indexed or assessed. Type fit is the question; rank
  timing is not this category's call.

### Context Check

1. What is the page's primary target query, and where did that come from (the page itself,
   Cat 86 output, or the user)? If it cannot be established, this category Skips.
2. What page types win the top 10 for that query, and what is the consensus type? Quote the
   results and the type assigned each.
3. What type is the audited page, classified from its H1, dominant content, and schema?
4. How rare is the audited page's type in the top 10: absent, rare, or majority? That answer
   sets severity.
5. What is the dominant intent the SERP rewards, and does the page's format serve it?
6. If the page is a deliberate format bet against the consensus, is that intentional and
   does it still satisfy the same intent, or is it an accidental mismatch?

### Reference

Google "How Search Works" and the helpful-content guidance on matching what searchers are
looking for: https://developers.google.com/search/docs/fundamentals/creating-helpful-content

The concept of SERP-consensus page-type matching: read the live top results as Google's
revealed answer for the page type and intent that satisfy a query, then match it.

Cross-ref Cat 58 (keyword targeting / intent match), Cat 86 (keyword research and SERP
clustering), Cat 122 (comparison pages), and `references/citability-scoring.md`.

**Severity tagging:**

- A money/target page whose type appears 0 times in the top 10 for its primary query → High
  (often Critical when it is a primary conversion page; it likely cannot rank as-is).
- A partial type mismatch (type is rare but present in the top 10) → Medium.
- An intent-format mismatch on a secondary page → Low.
- A deliberate, intent-satisfying format bet against the consensus → note, not a finding.
- Could not establish the primary query, or no web access to read the SERP → Skip-with-reason,
  not a guessed severity.

**Fix voice:** `frank-chimero` (primary) | `april-dunford` (backup).

Read `souls/frank-chimero.json` before writing the Fix.

Worked fix example:

> The page is answering a different question than the one people are asking. You wrote a guide.
> The searcher who types this query is not looking to read; the top ten results are product
> pages and comparison tables, and Google has already settled what kind of result satisfies
> this query. Form follows function here. When the form is wrong, no amount of internal linking
> or keyword polishing saves it, because the page is doing the wrong job well.
>
> Start by reading the SERP as the answer, not the obstacle. Fetch the top ten for the query
> and name what each one is: eight comparison pages, two product pages, zero guides. That
> spread is not noise. It is the medium telling you what shape the content wants to be.
>
> Then ask the quieter question: does this page want to change its type, or does it want a
> sibling? If the query is genuinely transactional, reshape the page into the type that wins,
> a comparison or a product page that does the job the searcher came to do. If the guide is
> good and serves a real informational need, keep it, and build a separate page in the winning
> type to carry this query. One page, one job.
>
> Verify by fetching the SERP again after the change and placing the new page's type against
> the consensus. If your type now matches the majority, the page is at least the right kind of
> answer. If you made a deliberate bet on a different format, say so plainly and watch whether
> it earns its place; an intentional difference is a choice, not a mistake, only when it still
> answers the same job better.
