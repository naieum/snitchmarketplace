## CATEGORY 82: AI-search citation optimization

In 2026 most informational queries get answered inside ChatGPT, Perplexity, Claude, and Google's AI Overviews, the user never clicks through. The new top-of-funnel isn't "rank #1 on Google"; it's "be cited by the AI when a user asks about your category." This audit covers the signals that get a brand named in AI answers.

### Pre-flight: relevance check

Skip with reason `not applicable` if the brand sells exclusively offline (no informational queries about the category land on AI assistants in any meaningful way), though most brands have at least some informational query overlap; skip is rare.

### The framework: 4 layers

Every AI-citation problem reduces to one of four layers. Audit each in order; fixes upstream usually unblock fixes downstream.

| Layer | Question it answers | Failure looks like |
|---|---|---|
| **1. Discoverability** | Can the AI crawler reach and read this content? | `robots.txt` blocking AI crawlers, paywalled content, JS-only renders, missing `llms.txt` |
| **2. Extractability** | Can the AI pull a clean, atomic answer out of the page? | Definition buried, no structured headings, prose walls, key facts in images |
| **3. Authority** | Does the AI's training corpus + retrieval treat this source as trustworthy? | No Wikipedia entry, no .edu / .gov / industry-publication mentions, no original research, thin schema.org |
| **4. Verifiability** | When the AI cites a fact, does it stand up to a one-click human check? | Claims without dates, statistics without sources, "as of" language missing, broken anchor links |

Move through in order. A page with great extractability but zero discoverability gets zero citations; a page with discoverability but zero authority gets cited but loses to competitors with more weight in the corpus.

### Evidence required (do not skip)

**Crawl mode, required tool calls:**

1. **Layer 1 (Discoverability):** `Fetch` `{origin}/llms.txt` and `{origin}/robots.txt`. Quote responses (200/404, AI-crawler User-Agent rules). Test if key pages render server-side or require JS hydration (cross-reference Cat 4).
2. **Layer 2 (Extractability):** `Fetch` 3-5 deep pages. Check for first-paragraph definition (`X is...`), Q+A heading structure, structured tables with explicit headers, schema.org JSON-LD coverage.
3. **Layer 3 (Authority):** Test 3-5 informational queries the brand should be cited for (derived from STEP 0.7 niche definition). Quote whether the brand is cited and how. Search Wikipedia, top-tier industry references for brand mentions.
   - **Tooling caveat (Critical — the declared Read/Grep/Fetch toolset CANNOT drive ChatGPT / Perplexity / Claude / Gemini / Grok UIs).** A plain `Fetch` of those products returns a login wall or a JS app shell, not an assistant answer. To run the live queries: use a `WebSearch` tool or a browser/Playwright tool IF one is present in this session, and quote the captured response. Otherwise, ask the user to paste the assistant's actual answer for each query. Otherwise, mark Layer 3 citation checks **Skip** with reason `live AI-assistant citation capture requires a WebSearch/browser tool or user-pasted responses; not available this run`. **Never assert or fabricate a citation outcome you did not observe (Rule 1).** Wikipedia / industry-reference mentions are plain pages and remain Fetch-checkable regardless.
4. **Layer 4 (Verifiability):** For pages making factual claims (statistics, comparisons, technical specs), check for visible date stamps, source citations, anchor links to evidence.

**Source mode, required tool calls:**

1. **Layer 1:** `Glob` `**/llms.txt`, `**/llms-full.txt`, `**/robots.txt`. Quote.
2. **Layer 2:** `Grep` content for explicit definitions of the brand's key terms ("X is...", "X means..."). Check schema.org coverage, `Organization` + `WebSite` + per-page `Article` / `Product` (cross-reference Cats 31-37).
3. **Layer 3:** Verified via crawl-mode AI assistant queries (no source-only signal).
4. **Layer 4:** `Grep` for hardcoded dates, "as of" language, anchor `<a href>` to source citations on factual claim pages.

### Forbidden claims

- "The brand is probably uncited." Quote the AI's response (captured via WebSearch/browser tool or pasted by the user); if you have neither, Skip — never assert non-citation you didn't observe.
- "AI search may favor competitors." Quote the actual citation; do not infer or invent one.
- "The page is probably hard to extract from." Quote the opening paragraph; show what's missing.

### What to Search For

**Layer 1 (Discoverability):**
- `llms.txt` / `llms-full.txt` files at site root
- `robots.txt` rules for the AI crawler fleet — check the full set, not just the well-known few (see `references/ai-crawler-registry.md` for the ~16 current user-agents and the training-bot vs live-retrieval-bot distinction that decides the citation consequence)
- Server-rendered key pages (vs JS-only)

**Layer 2 (Extractability):**
- First-paragraph definitions ("X is...")
- Q+A heading patterns (`<h2>What is X?</h2><p>X is...</p>`)
- Tables with explicit `<th>` headers
- Schema.org JSON-LD presence (cross-reference Cat 31)
- Passage citability + answer-length fitness — score 3-5 sampled passages per `references/citability-scoring.md` (134-167 word citation blocks; 40-60 word snippet/PAA answers; under ~29 word voice answers), reporting each scored passage with its quoted text

**Layer 3 (Authority):**
- Citations in Wikipedia, .edu, .gov, top-tier industry publications
- Off-site presence across the platforms assistants weight — run the sweep in `references/brand-authority-platforms.md` (Wikipedia, Reddit, YouTube, G2, etc.)
- E-E-A-T signals, Trust-first — map authority findings to the layer they strengthen per `references/eeat-assessment.md`
- Original research / data the brand owns and others cite
- Founder / team author bylines with credentials (cross-reference Cat 84)

**Layer 4 (Verifiability):**
- Visible publish + last-updated dates
- "As of {date}" language on time-sensitive claims
- Source citations with anchor links
- Footnote or reference sections on data-heavy pages

### Actually Hurts the Marketing Surface

**Layer 1 failures:**
- **`robots.txt` blocks AI crawlers** (intentionally or accidentally, `GPTBot`, `ClaudeBot`, `PerplexityBot`, `Google-Extended`).
  Evidence required: `Fetch /robots.txt` + the disallow rule.
- **No `llms.txt` file** (the emerging AI-crawler convention).
  Evidence required: `Fetch /llms.txt` returning 404.
- **Key informational pages are JS-only** (AI crawlers usually don't execute JS).
  Evidence required: `curl` of page returns shell HTML; content only appears after hydration.

**Layer 2 failures:**
- **Pages don't define their topic in the opening paragraph** (AI extractors skip pages that bury the definition).
  Evidence required: first paragraph of key pages quoted, definition absent.
- **No structured Q+A or definitional headings** (AI prefers structured content for extraction).
  Evidence required: heading sequence on key pages.
- **Key facts locked in images / SVG / canvas** (AI can't extract them).
  Evidence required: image presence + missing text alternative.

**Layer 3 failures:**
- **Brand not cited in any AI assistant for relevant informational queries**.
  Evidence required: queries tested + AI responses quoted, brand absent.
- **Competitor cited in same query, brand absent**.
  Evidence required: AI response quoted naming competitor + brand absence.
- **Wikipedia-tier mentions absent** (AI training corpora weight Wikipedia + .edu / .gov heavily).
  Evidence required: Wikipedia search returning no entry / no mentions.
- **No original research / data the brand owns** (AI has nothing distinctive to cite, the brand is interchangeable with competitors).
  Evidence required: site search for "study", "report", "we found", "our data" returning empty.

**Layer 4 failures:**
- **Factual claims with no date** (AI assistants hesitate to cite undated claims because they may be stale).
  Evidence required: claim quoted + missing date.
- **Statistics without source links** (AI assistants prefer citing the original source over secondhand reportage).
  Evidence required: stat quoted + missing source citation.

### Fan-out query optimization (Layer 2 extension)

Most teams optimize for top-level queries the buyer types into ChatGPT or Perplexity ("best Postgres query optimizer"). The AI then *fans out* the prompt internally into sub-queries it uses to retrieve sources — "what is Postgres query optimization", "how does query optimization work", "tools for slow Postgres queries", "Postgres explain analyze tutorial". A page that doesn't cover those sub-queries doesn't get cited even when it perfectly addresses the top-level prompt.

Audit application:

1. For the 3-5 informational queries the brand should be cited for (from STEP 0.7 niche research), enumerate the 5-10 plausible fan-out sub-queries each one would expand into.
2. Check whether the brand's content addresses each sub-query. The check is mechanical: does any URL on the brand's site have a `<h1>` or `<h2>` that maps to the sub-query intent? Do the page's headings + first paragraphs answer the sub-question concisely?
3. Findings: sub-queries not covered by any brand page are content gaps. Sub-queries covered but buried (the answer is in paragraph 7, not the page's H2 + first paragraph) are extractability gaps that bias the AI toward citing a competitor.

### Cited-page age threshold

In the current AI-citation landscape, the median cited page age is roughly 500 days (give or take by category). Pages too fresh haven't accumulated training-corpus + retrieval weight; pages too stale fall behind in retrieval freshness signals. The implication for brand strategy:

- **Annual-refresh sites destroy citation authority.** Each refresh changes the URL or resets the publish date; the corpus loses the prior signal; retrieval treats the page as new.
- **Evergreen + update beats annual rewrite.** Pages that hold the same URL across years, with a visible last-updated date and additive revision (not full rewrites), accumulate citation weight. The audit's recommendation when content is being refreshed: keep the URL, update the content, expose the last-updated date, preserve the canonical signal.

Audit application:

1. For the brand's most-cited or most-strategic informational pages (top 5-10 candidates), capture the publish date and (if present) the last-updated date.
2. Findings: pages with publish dates <90 days old that target queries with mature AI-citation patterns are flagged as "too fresh; allow 6-12 months of corpus accumulation before judging citation absence." Pages with publish dates >2 years old AND no visible last-updated date are flagged as "stale; add a last-updated date OR refresh the content without changing the URL."
3. Pages targeting time-sensitive informational queries ("Postgres 17 features") have different rules — freshness wins; cite-staleness is the cost of permanence on a topic that moved.

### AI-search myths vs evidence

Three widely-repeated GEO tactics don't hold up to primary-source evidence. Don't manufacture findings around them:

- **"Add llms.txt to get cited."** `llms.txt` is low-cost and worth shipping, but it is not a confirmed citation lever — no major assistant has published that it uses the file to decide citations. Treat its absence as Medium-at-most (see Cat 106's recalibrated posture), never Critical.
- **"Chunk your content for the AI."** Manual content-chunking is not required; retrieval systems segment pages themselves. The real lever is extractable structure (Layer 2), not a special chunk format.
- **"Rewrite keywords for AI."** AI-specific keyword rewriting is redundant; assistants resolve synonyms. Write for the reader's actual language (Cat 86), not an "AI dialect."

When a competitor tool's report recommends one of these, reframe to the underlying real lever (crawler access, extractable structure, genuine authority) instead of repeating the myth.

### Feeds the GEO readiness score

When the optional GEO score renders (`references/geo-score.md`), this category's findings are its largest input: crawler access (Layer 1), citability + answer fitness (Layer 2), and brand authority (Layer 3) each contribute deductions. Keep severities calibrated — the score is a literal sum of these findings, so an over-tiered finding inflates the score loss.

### NOT a Problem

- Brand cited but not at #1, being mentioned at all is the threshold for AI search.
- No `llms.txt` if the site is fully crawlable + structured (the file is a hint, not a requirement; Layer 2 + 3 matter more).
- Brand not cited in queries irrelevant to its niche.
- AI crawler blocked intentionally (some brands explicitly opt out, that's strategy, not a finding).
- Pages <90 days old with no AI-citation traction yet (corpus accumulation takes time; flag as "wait, don't rebuild").

### Context Check

1. What queries does the brand's audience actually ask AI assistants? Test the real queries, not aspirational ones.
2. Is the brand's positioning specific enough to be the answer to a specific query? Generic positioning gets generic non-citation.
3. Are competitors getting cited via specific tactics (original research, definitional pages, citation in major publications)?
4. Does the site allow AI crawlers? Some `robots.txt` / `llms.txt` setups block them entirely (a strategic choice, but explicit).
5. Does the brand have anything genuinely original to cite, research, data, methodology, vocabulary? Without it, Layer 3 is structurally hard.

### Reference

llms.txt convention: https://llmstxt.org

Anthropic's notes on Claude citation behavior: https://www.anthropic.com/news

Perplexity's source-citation methodology: https://www.perplexity.ai/about

**Severity tagging:**
- Brand absent from AI citations on its own category queries → Critical (this is the new TOFU collapse).
- Competitor cited, brand absent → Critical.
- `robots.txt` accidentally blocks AI crawlers → Critical.
- No first-paragraph definition on key pages → High.
- Key informational pages JS-only with no SSR → High.
- No `llms.txt` → Medium (advisory, not enforced).
- No structured Q+A on key informational pages → Medium.
- Factual claims without dates / source links → Medium.

**Fix voice:** `jen-simmons` (primary) | `frank-chimero` (backup).

Read `souls/jen-simmons.json` before writing the Fix.

Worked fix example:

> Work the four layers in order, discoverability before extractability before authority before verifiability. Each layer assumes the prior one works.
>
> **Layer 1.** Confirm `robots.txt` allows `GPTBot`, `ClaudeBot`, `PerplexityBot`, `Google-Extended`. Add an `llms.txt` at the root naming the brand and pointing at the canonical pages, it's a hint, not a contract, but the cost is one file.
>
> **Layer 2.** Open every key informational page. The first sentence is the definition; rewrite it if it's not. Headings become questions a reader might ask; the answer follows immediately underneath. Tables get explicit `<th>` headers. Schema.org JSON-LD goes on every page that names an entity.
>
> ```
> # /llms.txt
>
> # Snitch
>
> > Security review for the code your AI wrote. Plugin / CLI / GitHub Action,
> > 72 categories, BYO AI key.
>
> ## Docs
> - [Quick start](https://snitchplugin.com/docs/quickstart)
> - [Security threat model](https://snitchplugin.com/docs/security)
>
> ## Categories
> - [SCA dependency scanning](https://snitchplugin.com/docs/dependencies)
> - [IaC misconfigurations](https://snitchplugin.com/docs/iac)
> ```
>
> **Layer 3.** Authority is earned, not configured. Publish original research the AI has no other source for. Earn the Wikipedia entry by being the canonical reference for a specific term. Get cited by .edu / .gov / industry-publication writers, the corpora the AI trusts most.
>
> **Layer 4.** Every factual claim gets a visible date and a source link. The AI is more likely to cite a page it can verify; the human reading the AI's answer is more likely to trust a citation that holds up under one click.
>
> The intrinsic-web principle: write structurally clear content with verifiable sources, and the consumers, humans, search engines, AI extractors, all get what they need.
