## CATEGORY 82: AI-search citation optimization

A large and growing share of informational queries now get answered inside ChatGPT, Perplexity, Claude, and Google's AI Overviews, and the user never clicks through. The new top-of-funnel isn't "rank #1 on Google"; it's "be cited by the AI when a user asks about your category." This audit covers the signals that get a brand named in AI answers.

### Pre-flight: relevance check

Skip with reason `not applicable` if the brand sells exclusively offline (no informational queries about the category land on AI assistants in any meaningful way), though most brands have at least some informational query overlap; skip is rare.

### The framework: 4 layers

Every AI-citation problem reduces to one of four layers. Audit each in order; fixes upstream usually unblock fixes downstream.

| Layer | Question it answers | Failure looks like |
|---|---|---|
| **1. Discoverability** | Can the AI crawler reach and read this content? | `robots.txt` blocking AI crawlers, paywalled content, JS-only renders, a missing or misleading `llms.txt` |
| **2. Extractability** | Can the AI pull a clean, atomic answer out of the page? | Definition buried, no structured headings, prose walls, key facts in images |
| **3. Authority** | Does the AI's training corpus + retrieval treat this source as trustworthy? | No Wikipedia entry, no .edu / .gov / industry-publication mentions, no original research, thin schema.org |
| **4. Verifiability** | When the AI cites a fact, does it stand up to a one-click human check? | Claims without dates, statistics without sources, "as of" language missing, broken anchor links |

Move through in order. A page with great extractability but zero discoverability gets zero citations; a page with discoverability but zero authority gets cited but loses to competitors with more weight in the corpus.

**Two influence paths.** Everything in this category works through one of exactly two mechanisms, mirroring the training-bot vs live-retrieval-bot split in `references/ai-crawler-registry.md`: (1) the **training path** — being mentioned so widely and consistently across the corpus that the brand→topic association is baked into the model (slow, compounding; unlinked mentions feed this); (2) the **retrieval path** — surfacing when the assistant fetches live sources (fast; this is classic SEO: ranking, extractable structure, freshness). Tag each recommendation with its path, because timescales differ: retrieval-path work can show up in days, training-path work in months-to-model-updates. And citations are probabilistic — the same question asked five times may cite the brand three; speak of AI *visibility* (a distribution) never AI *rankings* (a position). Consensus across sources, freshness, and existing search authority are the three pattern-level drivers the correlational industry data supports. When Layer 3 / off-site findings accumulate, classify and prioritize them per `references/ai-visibility-gap-analysis.md` (six gap dimensions, Fix/Build/Influence triage) instead of shipping an undifferentiated list.

### Evidence required (do not skip)

**Crawl mode, required tool calls:**

1. **Layer 1 (Discoverability):** `Fetch` `{origin}/llms.txt`, `{origin}/llms-full.txt` and `{origin}/robots.txt`. Quote responses (200/404, AI-crawler User-Agent rules). When `/llms.txt` returns 200, run the file-quality checks in the Layer 1 block of What to Search For (format, content type, linked-URL resolution, drift) — a present-but-misleading file is the stronger finding. Test if key pages render server-side or require JS hydration (cross-reference Cat 4).
2. **Layer 2 (Extractability):** `Fetch` 3-5 deep pages. Check for first-paragraph definition (`X is...`), Q+A heading structure, structured tables with explicit headers, schema.org JSON-LD coverage.
3. **Layer 3 (Authority):** Test 3-5 informational queries the brand should be cited for (derived from STEP 0.7 niche definition), in each assistant the audience actually uses — the assistants diverge, so run them separately and record the outcome per assistant (`references/assistant-profiles.md`). Quote whether the brand is cited and how. Search Wikipedia, top-tier industry references for brand mentions.
   - **Tooling caveat (Critical — the declared Read/Grep/Fetch toolset CANNOT drive ChatGPT / Perplexity / Claude / Gemini / Grok UIs).** A plain `Fetch` of those products returns a login wall or a JS app shell, not an assistant answer. To run the live queries: use a `WebSearch` tool or a browser/Playwright tool IF one is present in this session, and quote the captured response. Otherwise, ask the user to paste the assistant's actual answer for each query. Otherwise, mark Layer 3 citation checks **Skip** with reason `live AI-assistant citation capture requires a WebSearch/browser tool or user-pasted responses; not available this run`. **Never assert or fabricate a citation outcome you did not observe (Rule 1).** Wikipedia / industry-reference mentions are plain pages and remain Fetch-checkable regardless.
4. **Layer 4 (Verifiability):** For pages making factual claims (statistics, comparisons, technical specs), check for visible date stamps, source citations, anchor links to evidence.

**Source mode, required tool calls:**

1. **Layer 1:** `Glob` `**/llms.txt`, `**/llms-full.txt`, `**/robots.txt`. Quote. When an `llms.txt` exists, also check whether it is generated at build time from the same source of truth as the homepage hero and the docs index, or hand-maintained (drift-prone) — and whether `/llms-full.txt` is regenerated on content changes.
2. **Layer 2:** `Grep` content for explicit definitions of the brand's key terms ("X is...", "X means..."). Check schema.org coverage, `Organization` + `WebSite` + per-page `Article` / `Product` (cross-reference Cat 31 for presence and Cat 32 for per-type validation).
3. **Layer 3:** Verified via crawl-mode AI assistant queries (no source-only signal). Source mode can still check the per-assistant signal each profile in `references/assistant-profiles.md` names (clear authorship, founder presence on the social graph an assistant weights, primary-source links).
4. **Layer 4:** `Grep` for hardcoded dates, "as of" language, anchor `<a href>` to source citations on factual claim pages.

### Forbidden claims

- "The brand is probably uncited." Quote the AI's response (captured via WebSearch/browser tool or pasted by the user); if you have neither, Skip — never assert non-citation you didn't observe.
- "AI search may favor competitors." Quote the actual citation; do not infer or invent one.
- "The page is probably hard to extract from." Quote the opening paragraph; show what's missing.
- Any stable "AI ranking" claim from a single capture. In an industry study, over 45% of AI Overview citations changed between answer refreshes, and refreshes averaged every ~2 days — one capture is one draw from a distribution. Frame every citation finding as point-in-time and recommend the re-check cadence (monthly light, quarterly deep per `references/ai-visibility-gap-analysis.md`).
- "Content is too short to be cited." Across a study of 174,000+ AI-cited pages, word count was uncorrelated with citation (r = 0.04) and 53.4% of cited pages were under 1,000 words. Flag unanswered sub-questions or missing topic coverage, never raw length.

### Detection

Layer-by-layer surface read: crawler access and `llms.txt` (Layer 1), page extractability (Layer 2), sampled per-assistant test queries plus off-site authority (Layer 3), claim verifiability (Layer 4).

### What to Search For

**Layer 1 (Discoverability):**
- `llms.txt` / `llms-full.txt` files at site root — presence first, then quality.
  **Posture (this governs severity, and the file is scored here and nowhere else).** `llms.txt` is worth publishing — it's a one-file, low-cost map — but be honest about what it does. No major assistant vendor has published that it uses the file to decide citations, and independent AEO research corroborates the posture bluntly: `robots.txt` remains the file that actually governs access. So a *missing* file is Medium at most, deducted once in this layer; a file that exists but misleads is the more defensible finding, because it actively sends the crawlers that do read it to the wrong places. When `/llms.txt` returns 200, check:
  - **Format**, per the published convention: an `# {Brand name}` H1, then a `>` blockquote one-paragraph summary, then optional `##` sections whose entries read `- [Title](URL): one-line description`.
  - **Content type** — a markdown response, not an HTML 200 from a SPA fallback.
  - **Linked URLs resolve** (200) and are the canonical resource for their topic, not deprecated docs or removed posts.
  - **Coverage matches the real surface** — a file listing 3 docs sections on a site with 12, with no visible selection logic, is stale rather than curated.
  - **`/llms-full.txt` drift**, when it exists — its content date markers against the site's current content. The full variant is optional; its absence is not a finding.
  - **Provenance** — regenerated from the same source of truth as the homepage hero and docs index, or hand-maintained (drift is then a matter of time).
  - **Summary agrees with the homepage** — a one-paragraph summary that contradicts the site's own positioning is a brand-signal finding, not a formatting one.
  - `robots.txt` permitting the AI crawlers at all: a published `llms.txt` behind a crawler block is a contradiction, and the training-vs-retrieval split in `references/ai-crawler-registry.md` decides which block actually matters.
- `robots.txt` rules for the AI crawler fleet — check the full set, not just the well-known few (see `references/ai-crawler-registry.md` for the current user-agent set and the training-bot vs live-retrieval-bot distinction that decides the citation consequence). When a block is found on a Cloudflare-fronted or otherwise managed site, run the registry's provenance check — platform-injected default blocks are findings, not strategy.
- Server-rendered key pages (vs JS-only) — and name which platforms a JS-only page fails for, from each vendor's current crawler documentation rather than from memory: some assistants render JavaScript and some have documented that their crawlers do not. Verify before naming a platform, and never report a generic "AI can't render JS."
- Page weight/speed on key pages — during live retrieval the assistant fetches, parses, and chunks pages on the fly; a slow page can be dropped before it's scored, regardless of content quality. Existing CWV work (Cats 39-44) mostly covers this; the retrieval-timeout rationale is the addition.
- Observed AI-bot behavior where logs are available — pages repeatedly fetched by live-retrieval bots are likely answer sources right now; priority pages retrieval bots never visit are discoverability findings (see the behavioral-diagnostic section of `references/ai-crawler-registry.md`).

**Layer 2 (Extractability):**
- First-paragraph definitions ("X is...")
- Q+A heading patterns (`<h2>What is X?</h2><p>X is...</p>`)
- Tables with explicit `<th>` headers
- Schema.org JSON-LD presence (cross-reference Cat 31)
- Passage citability + answer-length fitness — score 3-5 sampled passages per `references/citability-scoring.md` (134-167 word citation blocks; 40-60 word snippet/PAA answers; under ~29 word voice answers), reporting each scored passage with its quoted text

**Layer 3 (Authority):**
- Citations in Wikipedia, .edu, .gov, top-tier industry publications
- Off-site presence across the platforms assistants weight — run the sweep in `references/brand-authority-platforms.md` (Wikipedia, Reddit, YouTube, G2, etc.)
- **Third-party mention footprint, weighted above the site's own link metrics.** In a 2026 industry study of 75,000 brands, branded web mentions had the strongest correlation with appearing in Google AI Overviews (0.664 — stronger than backlinks, referring domains, or domain authority; correlational, not a confirmed ranking factor). Unlinked mentions have standalone value: each mention on a credible page is a training example associating brand→topic. Capture mentions *without* links as a distinct evidence state — only roughly a quarter of AI mentions include a link, so auditing clickable citations alone misses most visibility events. Record three states per query: cited-and-linked, mentioned-but-not-linked, invisible.
- **Listicle / comparison presence for the category's commercial queries.** In cross-platform citation studies, listicles ("best X", "top X", comparisons, reviews) were 43.8% of all AI-cited pages (correlational). Check whether the brand appears in the listicles and review pages that surface for the predictable patterns (`best`, `top`, `versus`, `compare`, `review`, `alternative`, `worth it`). Competitor-present/brand-absent listicles are the highest-priority Influence targets (`references/ai-visibility-gap-analysis.md`). Data-driven content with original stats and X-vs-Y comparison pages are the other two formats that over-index in citations.
- E-E-A-T signals, Trust-first — map authority findings to the layer they strengthen per `references/eeat-assessment.md`
- Original research / data the brand owns and others cite
- **Brand-labeled frameworks and vocabulary.** LLMs flatten originality: an unlabeled original concept gets absorbed into generic knowledge without attribution. Check whether proprietary frameworks/metrics/methodologies are consistently brand-prefixed ("the {Brand} scoring matrix", not "a scoring matrix") and explicitly defined ("X is...") on an owned page. Unbranded original concepts are a Layer 3 finding — authority leaking into the commons.
- Founder / team author bylines with credentials (cross-reference Cat 84)

**Layer 4 (Verifiability):**
- Visible publish + last-updated dates
- "As of {date}" language on time-sensitive claims
- Source citations with anchor links
- Footnote or reference sections on data-heavy pages
- **Misinformation resistance: specific official facts crowding out fiction.** An industry experiment that planted contradictory fake sources about an invented brand found some assistants repeated the fabrications as verified fact in 37% of answers, while the assistant that stayed under 7% cited the brand's official FAQ in 84% of its answers. When AI must choose between vague truth and specific fiction, it tends to pick the specific fiction. Check: (1) an official FAQ directly answering the common factual questions about the brand (founding, pricing, locations, ownership); (2) brand-fact pages using specific numbers/dates/names, not vague claims; (3) whether anyone monitors what AI says about the brand for accuracy. Remediation order when misinformation is found: publish the owned contradiction first (fastest), then pursue third-party corrections — the longer misinformation stands, the more the models learn it.
- **Hallucinated-URL capture.** Assistants invent URLs: in industry data, visitors arriving from AI referrers hit 404s at 2.87x the rate of Google Search visitors. Cross-reference analytics/server logs for AI-referrer requests (chatgpt.com, perplexity.ai, claude.ai, gemini, copilot) returning 404; any hallucinated path with recurring traffic is recoverable — 301 it to the closest real page, with a genuinely useful 404 page as the fallback.

### Actually Hurts the Marketing Surface

**Layer 1 failures:**
- **`robots.txt` blocks AI crawlers** (intentionally or accidentally). Severity follows the crawler's role, per the training-vs-retrieval split in `references/ai-crawler-registry.md`: a blocked live-retrieval / search bot (`OAI-SearchBot`, `ChatGPT-User`, `PerplexityBot`, `Perplexity-User`, `Claude-User`) removes the site from answers being composed right now; a blocked training-only token (`GPTBot`, `ClaudeBot`, `CCBot`, `Google-Extended`, `Applebot-Extended`) keeps content out of future corpora but does not stop citation today.
  Evidence required: `Fetch /robots.txt` + the disallow rule + the crawler's role named.
- **Platform-injected AI-crawler block the site owner never chose** (managed-platform defaults — notably Cloudflare's default-enabled feature that rewrites `robots.txt` to signal AI-training opt-out; an industry study of 140M websites found ~5.9% block GPTBot, most via inherited templates and defaults rather than a decision).
  Evidence required: the `robots.txt` rule + the provenance check from `references/ai-crawler-registry.md` (platform detected, user asked whether the block was deliberate).
- **No `llms.txt` file** (the emerging AI-crawler convention). One finding, one deduction — the file is scored in this layer only.
  Evidence required: `Fetch /llms.txt` returning 404.
- **`/llms.txt` present but misleading** — wrong content type (an HTML 200 from a SPA fallback), invalid format (no H1, no summary, no link sections), linked URLs that 404 or point at deprecated resources, a link inventory that no longer matches the site's real surface, or an `/llms-full.txt` months behind the site.
  Evidence required: the fetched file quoted + the specific deviation (content type, the missing structural element, each dead URL and its status, or the date markers on both sides).
- **`robots.txt` blocks AI crawlers on a site that publishes `/llms.txt`** (a contradiction: the map is published and the door is shut).
  Evidence required: the `Disallow` rule + the `/llms.txt` 200, with the blocked crawler's role named.
- **`/llms.txt` hand-maintained with the same facts generated elsewhere** (homepage hero, docs index): drift is inevitable, and a stale map is worse than none.
  Evidence required: the static file + the absence of a build step regenerating it.
- **Key informational pages are JS-only** (an empty shell to the platforms that don't render JS — name them: ChatGPT's crawler cannot; Gemini and Copilot can).
  Evidence required: `curl` of page returns shell HTML; content only appears after hydration; affected platforms named.

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
- **Cited by some assistants, absent from others where the audience actually is** (the assistants share far less of their citation sets than their answers suggest, so a per-assistant gap is a real gap, not sampling noise).
  Evidence required: the same query's captured response from each assistant + the profile signal the absent one weights (`references/assistant-profiles.md`).
- **Absent from Google's AI surfaces despite ranking in regular Google search** (an extraction problem, not an authority one — route the fix to Layer 2).
  Evidence required: the organic ranking + the AI-surface response with the brand absent.
- **The page an assistant cites is stale or wrong** (the assistant is quoting outdated facts about the brand back to buyers).
  Evidence required: the citation quoted + the cited page's `dateModified` or the contradicted fact; refresh through Cat 97.
- **Per-assistant citation rate trending down across runs** (not merely absent — losing ground against a saved baseline).
  Evidence required: the baseline and the later capture, both dated.
- **Wikipedia-tier mentions absent** (AI training corpora weight Wikipedia + .edu / .gov heavily).
  Evidence required: Wikipedia search returning no entry / no mentions.
- **No original research / data the brand owns** (AI has nothing distinctive to cite, the brand is interchangeable with competitors).
  Evidence required: site search for "study", "report", "we found", "our data" returning empty.
- **Brand absent from the category listicles/comparisons competitors are on** (the page type that dominates AI citations; consensus is built from lists).
  Evidence required: the listicle URLs quoted, competitors named on them, brand absent.
- **Original frameworks/metrics published unbranded** (the concept gets absorbed into generic AI knowledge without attribution).
  Evidence required: the framework quoted from the site without a brand prefix or an explicit owned definition.

**Layer 4 failures:**
- **Factual claims with no date** (AI assistants hesitate to cite undated claims because they may be stale).
  Evidence required: claim quoted + missing date.
- **Third-party or comparative statistics without source links** (AI assistants prefer citing the original source over secondhand reportage). A **first-party** measurement is not this finding when the page states the conditions it was measured under — see NOT a Problem.
  Evidence required: stat quoted + the claim's origin (someone else's number, or a comparison against a competitor) + missing source citation.
- **No official brand-fact FAQ / vague brand facts** (information gaps that specific third-party fiction can fill; see the misinformation-resistance check above).
  Evidence required: the common factual queries about the brand + no owned page answering them with specific numbers/dates/names.
- **Recurring 404s from AI referrers (hallucinated URLs) with no redirect**.
  Evidence required: log/analytics rows showing AI-referrer requests to a non-existent path + the 404 response.

### Fan-out query optimization (Layer 2 extension)

Most teams optimize for top-level queries the buyer types into ChatGPT or Perplexity ("best Postgres query optimizer"). The AI then *fans out* the prompt internally into sub-queries it uses to retrieve sources — "what is Postgres query optimization", "how does query optimization work", "tools for slow Postgres queries", "Postgres explain analyze tutorial". A page that doesn't cover those sub-queries doesn't get cited even when it perfectly addresses the top-level prompt.

The mechanics, quantified (industry studies, correlational): the average prompt triggers 9-11 fan-out sub-queries, some up to 28; deep-research modes can run hundreds of searches for one question. Fan-out queries are synthetic — generated in the moment, inconsistent between runs, and over 95% have zero search volume. They are NOT a keyword list to optimize one-by-one; treat them as a window into which topics the AI considers essential for a question. They do, however, collapse into predictable **pattern classes**: "best X for Y", "best X in {year}", "top recommendations for {topic}", "X versus Y", "is X worth it", "alternatives to X" — visible in autosuggest, People-Also-Ask, and related searches.

Audit application:

1. For the 3-5 informational queries the brand should be cited for (from STEP 0.7 niche research), check coverage of the pattern classes above for each money topic — not an enumerated list of literal sub-queries, which won't reproduce between runs.
2. Check whether the brand's content addresses each pattern. The check is mechanical: does any URL on the brand's site have a `<h1>` or `<h2>` that maps to the pattern's intent? Do the page's headings + first paragraphs answer the sub-question concisely? And is the brand mentioned on the pages that *rank* for those patterns — ranking pages for fan-out patterns are what get stitched into the answer.
3. Findings: patterns not covered by any brand page are content gaps. Patterns covered but buried (the answer is in paragraph 7, not the page's H2 + first paragraph) are extractability gaps that bias the AI toward citing a competitor.
4. The coverage unit is the topic cluster, not the single page: one page covering only a topic's basics loses to a competitor cluster that also covers the adjacent sub-topics (equipment, hosting, promotion, pricing) the fan-out reaches for.
5. Persona-segmented comparisons are a fan-out multiplier: assistants know the user's role/context and personalize answers, so comparison content targeted to a persona ("X alternative for graphic designers", including the quotable persona-fit reasoning) supports the model's personalization step better than head-to-head-only pages. Check whether comparison content segments by persona/use-case at all; small brands can also enter the consideration set via three-way "X vs Y vs {Brand}" pages against two category giants.

### Cited-page age threshold

In the current AI-citation landscape, the median cited page age is roughly 500 days (give or take by category). Pages too fresh haven't accumulated training-corpus + retrieval weight; pages too stale fall behind in retrieval freshness signals.

There is an apparent tension with the freshness data — a study of 17M citations across seven AI platforms found AI-cited content is 25.7% *fresher* than what ranks in the traditional SERP, and ChatGPT/Perplexity skew heavily toward recently-updated pages (correlational). Both hold simultaneously because they measure different things: the **URL** should be old (accumulated corpus weight), the **content and `dateModified`** should be recent. RAG only fires when training data can't answer, so retrieval inherently favors recent documents — freshness is a *retrieval gate*, not just a ranking signal. The audit rule: old URL + recent meaningful update = ideal; new URL = too fresh; old URL + stale content = retrieval-loser. Content untouched ~6 months is already disadvantaged for AI citations on moving topics. Meaningful updates only (new stats, quotes, current facts, stale material removed) — date-only changes are detectable and ineffective; re-date only when the change is real. Refresh triage and cadence live in Cat 97.

The implication for brand strategy:

- **Annual-refresh sites destroy citation authority.** Each refresh changes the URL or resets the publish date; the corpus loses the prior signal; retrieval treats the page as new.
- **Evergreen + update beats annual rewrite.** Pages that hold the same URL across years, with a visible last-updated date and additive revision (not full rewrites), accumulate citation weight. The audit's recommendation when content is being refreshed: keep the URL, update the content, expose the last-updated date, preserve the canonical signal.

Audit application:

1. For the brand's most-cited or most-strategic informational pages (top 5-10 candidates), capture the publish date and (if present) the last-updated date.
2. Findings: pages with publish dates <90 days old that target queries with mature AI-citation patterns are flagged as "too fresh; allow 6-12 months of corpus accumulation before judging citation absence." Pages with publish dates >2 years old AND no visible last-updated date are flagged as "stale; add a last-updated date OR refresh the content without changing the URL."
3. Pages targeting time-sensitive informational queries ("Postgres 17 features") have different rules — freshness wins; cite-staleness is the cost of permanence on a topic that moved.

### AI-search myths vs evidence

Three widely-repeated GEO tactics don't hold up to primary-source evidence. Don't manufacture findings around them:

- **"Add llms.txt to get cited."** `llms.txt` is low-cost and worth shipping, but it is not a confirmed citation lever — no major assistant has published that it uses the file to decide citations. Treat its absence as Medium-at-most (see the Layer 1 posture above), never Critical.
- **"Chunk your content for the AI."** Manual content-chunking is not required; retrieval systems segment pages themselves. The real lever is extractable structure (Layer 2), not a special chunk format.
- **"Rewrite keywords for AI."** AI-specific keyword rewriting is redundant; assistants resolve synonyms. Write for the reader's actual language (Cat 86), not an "AI dialect."
- **"Schema markup earns AI citations."** A softer myth: there is no confirmed data that schema directly improves citation odds — even AEO-focused industry research concedes this. Keep schema for classic SEO (it aids machine understanding and doesn't hurt), but never prioritize schema work *specifically for AEO* over crawler access, freshness, structure, and mentions — and never tier a missing-schema finding above Medium on citation grounds alone.
- **"Longer content gets cited."** Word count is uncorrelated with citation (r = 0.04 across 174,000+ cited pages; 53.4% of cited pages under 1,000 words). Long-form-for-its-own-sake is a traditional-SEO habit that does not transfer; the lever is answer fitness (`references/citability-scoring.md`), not length.

When a competitor tool's report recommends one of these, reframe to the underlying real lever (crawler access, extractable structure, genuine authority) instead of repeating the myth.

### Per-assistant differentiation

The four layers are shared, but the assistants are not one surface. The divergence is measured, not hypothetical: in a cross-platform industry study of the top 50 most-cited domains across three major assistant surfaces, only 7 appeared on all three — 14% overlap, 86% unique per assistant (correlational). Even two surfaces inside the same vendor shared only ~13.7% of their citations while producing answers ~86% semantically similar: same answers, different sources. So a brand can be a fixture in one assistant and invisible in another, and single-assistant optimization leaves the rest untouched.

Per-assistant profiles — retrieval mechanism, citation style, trust hierarchy, the signals that earn a citation there, and the platform-specific link rates that decide what "cited" even means — live in `references/assistant-profiles.md`. Load it when the audit reaches Layer 3 and the brand cares about more than one assistant.

Audit application:

1. **Weight before you test.** Don't audit every assistant equally. Pick by (a) where the audience actually is and (b) overlap with existing strength — a brand that ranks well in classic search has a head start in the search-coupled assistants; a brand with an editorial-PR and forum footprint has a head start in the publisher-weighted ones.
2. **Same queries, run per assistant**, subject to the Layer 3 tooling caveat above — the declared Read/Grep/Fetch toolset cannot drive an assistant UI, so this is a browser/`WebSearch` tool, user-pasted answers, or a Skip-with-reason. Never infer one assistant's behavior from another's; they differ structurally.
3. **Record three states per query per assistant**: cited-and-linked, mentioned-but-not-linked, invisible. Link rates differ by roughly a factor of five between assistants, so counting only clickable citations under-reports visibility, worst of all on the surfaces that rarely link at all.
4. **Route the gap to its layer.** A per-assistant absence is a Layer 3 finding only when the foundations hold; if Layer 1 or Layer 2 is failing, fix that first — no per-assistant tactic recovers a page the crawler can't read or extract from.
5. **Baseline before trending.** Citation sets churn between refreshes, so "absent in assistant X" needs repeated runs or a saved baseline before it is a finding. Classification and cadence live in `references/ai-visibility-gap-analysis.md`.

### Feeds the GEO readiness score

When the optional GEO score renders (`references/geo-score.md`), this category's findings are its only input: crawler access and `llms.txt` (Layer 1), citability + answer fitness (Layer 2), brand authority and per-assistant coverage (Layer 3) each contribute deductions. Every input is scored once — a missing `llms.txt` is one deduction under Layer 1, never a second one under a separate file check. Keep severities calibrated — the score is a literal sum of these findings, so an over-tiered finding inflates the score loss.

### NOT a Problem

- Brand cited but not at #1, being mentioned at all is the threshold for AI search.
- Brand mentioned but not linked — that's a distinct visibility state with standalone value (word-of-mouth at scale, training-association signal), not a failure. Record it separately; don't report it as "uncited."
- No `llms.txt` if the site is fully crawlable + structured (the file is a hint, not a requirement; Layer 2 + 3 matter more).
- A clean, accurate, fresh `/llms.txt` — that is the pass state; report it as Pass-with-evidence and move on.
- `/llms-full.txt` absent while `/llms.txt` is present; the full variant is optional polish.
- `/llms.txt` 301-redirecting to `/llms` on a site with extensionless URLs, when the destination serves markdown.
- A small brand's `/llms.txt` listing only 3-5 links, when that is the brand's actual surface.
- Cited by one assistant only, when that is the one assistant the audience uses — coverage is weighted by audience, not counted.
- A brand under ~6 months old absent from the corpus-heavy assistants; revisit at 12 months.
- Brand not cited in queries irrelevant to its niche.
- AI crawler blocked intentionally (some brands explicitly opt out, that's strategy, not a finding) — but ONLY after the provenance check: confirm a human chose the block. Managed-platform default blocks (see Layer 1 failures) are findings, not strategy.
- Pages <90 days old with no AI-citation traction yet (corpus accumulation takes time; flag as "wait, don't rebuild").
- A single query run where the brand wasn't cited, when other runs cite it — citation sets churn heavily between refreshes (over 45% per refresh in industry data); a pattern across runs/queries is the finding, one draw is not.
- Short pages that answer their question — length alone is never a GEO finding (r = 0.04).
- A **first-party** measurement published with the conditions it was taken under ("median pickup latency: 40ms at 1,000 jobs/sec") and no external source link. The brand's own number has no third party to cite; the stated conditions are the substantiation. A date or a methodology link is owed only when the figure is presented as an industry statistic or a comparison against someone else.
- The brand not being cited today for a query where the currently-cited pages change every refresh — breadth of list presence is the durable play, not chasing the citation-of-the-day.

### Context Check

1. What queries does the brand's audience actually ask AI assistants? Test the real queries, not aspirational ones. Sourcing method: AI prompts run ~5x longer than search keywords and carry personal context, so exact-prompt optimization is futile — instead mine real audience conversations (sales-call transcripts, support email, live chat, Reddit threads) for recurring problems, situations, and vocabulary; map those to topic clusters and audit coverage per cluster. Visibility is built per-topic, not per-prompt. When picking which queries to test, apply the AI-satisfaction filter: if the AI answer alone satisfies the searcher, the query is an AEO target (goal = be *mentioned in* the answer); if the user must still act (tool/calculator/transactional intent), it stays a traditional click play — audit it under classic SEO cats instead.
2. Is the brand's positioning specific enough to be the answer to a specific query? Generic positioning gets generic non-citation. Also enumerate the branded entity map first (main brand, sub-brands, products, proprietary metrics, founder brands) — each entity has its own visibility profile and gets its own gap analysis (`references/ai-visibility-gap-analysis.md`).
3. Are competitors getting cited via specific tactics (original research, definitional pages, citation in major publications)?
4. Does the site allow AI crawlers? Some `robots.txt` / `llms.txt` setups block them entirely (a strategic choice, but explicit — verify a human made it; platform defaults don't count). And if an `llms.txt` is published, is it regenerated on content changes? A stale map is worse than none.
5. Which assistants does the audience actually use, and is per-assistant coverage tracked against a saved baseline? Without a baseline there is no trend, and a single capture is one draw from a distribution.
6. Does the brand have anything genuinely original to cite, research, data, methodology, vocabulary? Without it, Layer 3 is structurally hard. Apply the **deserve-to-show-up test**: would it be *odd* if this brand appeared as a cited source for this query? AI answers roughly reflect existing web consensus — if category-defining brands dominate a query and this brand adds nothing to the conversation, no tactic closes that gap durably. Gameable tactics (listicle spam) work today and are explicitly time-limited; when the test fails, reframe the tactical GEO findings — the primary gap is the offering/authority substrate, not optimization.

### Reference

llms.txt convention: https://llmstxt.org

Anthropic's notes on Claude citation behavior: https://www.anthropic.com/news

Perplexity's source-citation methodology: https://www.perplexity.ai/about

`references/ai-visibility-gap-analysis.md` — six-gap classification, Fix/Build/Influence triage, measurement stack, cadence.

`references/assistant-profiles.md` — per-assistant retrieval mechanics, trust hierarchies, citation and link rates, and the signal that earns a citation on each.

**Severity tagging:**
- Brand absent from AI citations on its own category queries (patterned across runs, not a single capture) → Critical (this is the new TOFU collapse).
- Competitor cited, brand absent → Critical.
- `robots.txt` blocks a live-retrieval / search bot (`OAI-SearchBot`, `ChatGPT-User`, `PerplexityBot`, `Perplexity-User`, `Claude-User`), including platform-injected default blocks → Critical.
- `robots.txt` blocks a training-only token (`GPTBot`, `ClaudeBot`, `CCBot`, `Google-Extended`, `Applebot-Extended`) while retrieval bots stay allowed → Medium, and the finding names the corpus consequence, not a citation one. A documented human opt-out is not a finding at all.
- No first-paragraph definition on key pages → High.
- Key informational pages JS-only with no SSR → High.
- Brand absent from the category listicles/comparisons competitors are on → High.
- No official brand-fact FAQ while AI misinformation about the brand is observed → High (Medium when no misinformation observed yet).
- Strategic pages stale (no meaningful update in 6+ months on a moving topic) → High on the AI-citation surface (route the refresh through Cat 97).
- Recurring hallucinated-URL 404s from AI referrers with no redirect → Medium.
- Original frameworks published unbranded → Medium.
- Cited by some assistants, absent from others where the audience is → High.
- Absent from Google's AI surfaces despite ranking organically → High.
- Per-assistant citation rate declining against a saved baseline → High.
- `robots.txt` blocks AI crawlers while `/llms.txt` is published → severity inherits the two rows above, by the blocked crawler's role: Critical when a live-retrieval bot is blocked, Medium when only training-only tokens are. The contradiction is named in the finding's Risk, not scored on its own.
- `/llms.txt` served with the wrong content type, or malformed → High (the file exists and misleads).
- `/llms.txt` linking to URLs that 404 or are stale → High.
- `/llms-full.txt` drift, or a `/llms.txt` summary contradicting the homepage → Medium.
- Hand-maintained `/llms.txt` with no build step → Low (advisory; flag the drift risk).
- An assistant citing a stale page about the brand → Medium.
- No `llms.txt` → Medium (advisory, not enforced), deducted once.
- No structured Q+A on key informational pages → Medium.
- Factual claims without dates / source links → Medium.
- Missing schema on citation grounds alone → never above Medium (see myths).

**Fix voice:** `intrinsic-web-engineer` (primary) | `content-shape-editor` (backup).

Read `souls/intrinsic-web-engineer.json` before writing the Fix.

Worked fix example:

> Work the four layers in order, discoverability before extractability before authority before verifiability. Each layer assumes the prior one works.
>
> **Layer 1.** Confirm `robots.txt` allows the bots that fetch a page while an answer is being composed: `OAI-SearchBot`, `ChatGPT-User`, `PerplexityBot`, `Claude-User`. The training-only tokens (`GPTBot`, `ClaudeBot`, `CCBot`, `Google-Extended`) are the owner's policy call, not a defect — blocking them costs future corpus inclusion, not today's citation. Add an `llms.txt` at the root naming the brand and pointing at the canonical pages, it's a hint, not a contract, but the cost is one file.
>
> **Layer 2.** Open every key informational page. The first sentence is the definition; rewrite it if it's not. Headings become questions a reader might ask; the answer follows immediately underneath. Tables get explicit `<th>` headers. Schema.org JSON-LD goes on every page that names an entity.
>
> ```
> # /llms.txt
>
> # Snitch
>
> > Security review for the code your AI wrote. An Agent Skill that runs in any
> > AI coding tool, evidence-backed findings, bring your own model.
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
>
> Then put it on a cadence. AI citation sets churn between answer refreshes, so a one-time check tells you almost nothing. Save a baseline the week the fixes land — share of voice, citing domains, topic coverage, mention sentiment — re-check it monthly, and re-run the competitive audit quarterly. The trend is the measurement; the snapshot never was.
