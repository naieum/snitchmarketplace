## CATEGORY 102: Multi-LLM citation differentiation

ChatGPT cites differently than Claude differently than Perplexity differently than Gemini differently than Grok. Each LLM has different training corpora, different retrieval mechanics, different citation styles, different recency biases, different domain trust hierarchies. A brand cited heavily by Perplexity might be invisible in ChatGPT. A brand recommended by Claude might be passed over by Gemini. Treating all LLMs as one surface (per Cat 82 AI-search citation) misses the differentiation that matters most for diagnostic + tactical work.

This category audits per-LLM citation coverage and identifies the LLM-specific signals that earn citation. It's a 2027-aware extension of Cat 82.

### Pre-flight: relevance check

Skip with reason `not applicable` if the brand has zero presence in any LLM (in which case Cat 82's foundational work needs to happen first). Otherwise: required, especially when the brand is cited in some LLMs but absent from others.

### The framework: 5 LLM-specific lenses

For each major LLM the brand wants to be cited by, audit:

#### Lens 1: ChatGPT (with web search enabled)
- **Training cutoff**: most current at GPT-5 / GPT-5.5 era (2025+)
- **Retrieval mechanism**: Bing search index for live queries; OpenAI's curated browsing
- **Citation style**: inline numbered citations with link to source domain
- **Trust hierarchy**: weighs Wikipedia + .edu + major publications heavily; recency-aware via Bing index
- **Best signals to earn citation**: be in Bing index, have Wikipedia entry, original research worth quoting, recent timestamps

#### Lens 2: Claude (with web search)
- **Training cutoff**: knowledge cutoff varies per model; web search supplements
- **Retrieval mechanism**: Anthropic's web search tool (when enabled)
- **Citation style**: inline citations with source links; tends to favor primary sources over aggregators
- **Trust hierarchy**: weights primary sources (official docs, vendor blogs, founder posts); skeptical of SEO-spam-shaped content
- **Best signals to earn citation**: original analysis (not aggregation), clear authorship (Cat 93 Person schema), primary-source links, Anthropic-friendly content (well-structured, well-attributed)

#### Lens 3: Perplexity
- **Training cutoff**: live retrieval per query; minimal reliance on training corpus
- **Retrieval mechanism**: own search index + multiple search APIs
- **Citation style**: heavy citation density; numbered sources prominent; "Sources" panel always visible
- **Trust hierarchy**: weights authoritative + recent + on-topic; comparatively fair to indie / niche sources
- **Best signals to earn citation**: comprehensive on-topic content, recency, structured headings + Q+A patterns, `llms.txt` advisory

#### Lens 4: Gemini (Google AI Overviews)
- **Training cutoff**: Google's web index + curated training
- **Retrieval mechanism**: Google Search index (full Google graph)
- **Citation style**: AI Overview at top of SERP; sources listed in expandable panel
- **Trust hierarchy**: weights Google's existing ranking signals (authority, relevance, freshness) PLUS AI-extraction friendliness
- **Best signals to earn citation**: rank well in regular Google search + structured content per Cat 82 + clear topic ownership

#### Lens 5: Grok / niche LLMs
- **Training cutoff**: varies; Grok favors X/Twitter content heavily
- **Retrieval mechanism**: X social graph + web
- **Citation style**: mixes social posts with web sources
- **Trust hierarchy**: weights real-time social signal + technical depth
- **Best signals**: founder + brand presence on X (Cat 84), technical content depth, recent posting cadence

### Shared substrate: passage citability

All five lenses sit on one substrate: a passage the LLM can lift cleanly. Before per-LLM tactics, score the brand's key passages for citability + answer-length fitness per `references/citability-scoring.md`. A passage that fails extractability fails in every LLM, so fix it once rather than per-lens; the per-LLM differentiation below only matters once the underlying passages are extractable.

### Evidence required (do not skip)

**Crawl mode, required tool calls (most of this is off-site):**

**Tooling caveat (Critical — the declared Read/Grep/Fetch toolset CANNOT drive ChatGPT / Claude / Perplexity / Gemini / Grok UIs).** A plain `Fetch` of those products returns a login wall or a JS app shell, not an assistant answer; there is no way to run these queries live with Fetch alone. For each step below: use a `WebSearch` tool or a browser/Playwright tool IF one is present this session, and quote the captured response. Otherwise, ask the user to paste each assistant's actual answer per query. Otherwise, mark the per-LLM capture **Skip** with reason `live multi-LLM citation capture requires a WebSearch/browser tool or user-pasted responses; not available this run`. **Never assert or fabricate a per-LLM citation outcome you did not observe (Rule 1)** — non-determinism across LLMs makes invented results especially misleading.

1. Test 5 informational queries the brand should be cited for in EACH of: ChatGPT (with web), Claude (with web), Perplexity, Google AI Overview, Grok. Quote each response + whether the brand is cited.
2. For LLMs that cite the brand: capture which page(s) were cited, the citation rank position, the snippet quoted.
3. For LLMs that don't cite the brand: capture which competitors WERE cited and their cited pages.
4. Per LLM: identify which Cat 82 signals seem most predictive of the citation outcome (per-LLM analysis from the lenses above).

**Source mode, required tool calls:**

1. Re-verify Cat 82 foundations are in place (Discoverability, Extractability, Authority, Verifiability layers). If any are weak, fix Cat 82 before pursuing Cat 102 differentiation.
2. Per-LLM, check the brand's posture on the LLM-specific signal (e.g., for Grok: founder posting cadence on X per Cat 84; for Claude: clear authorship per Cat 93).

### Forbidden claims

- "Brand is probably cited by some LLMs but not others." Quote each LLM's response (captured via WebSearch/browser tool or pasted by the user); if you have neither, Skip — never assert a per-LLM split you didn't observe.
- "ChatGPT may favor a competitor." Quote the actual ChatGPT response; do not infer or invent one.
- Don't extrapolate from one LLM's behavior to another, they differ structurally.

### What to Search For

- LLM-specific citation patterns per query
- Cited pages per LLM (often different per LLM for the same query)
- LLM-specific signal gaps (e.g., no X presence weakens Grok citation; no Wikipedia entry weakens ChatGPT-via-Bing citation)

### Actually Hurts the Marketing Surface

- **Brand cited in Perplexity but absent from ChatGPT** (suggests weak Bing index presence + missing Wikipedia entry + thin authority signals).
  Evidence required: Perplexity citation + ChatGPT non-citation + analysis of the gap.
- **Brand absent from Google AI Overview despite ranking in regular Google search** (suggests AI-extraction-unfriendly content per Cat 82 Layer 2).
  Evidence required: Google search ranking + AI Overview absence.
- **Brand cited by Claude but the cited page is outdated / has wrong info** (Claude is citing stale content; refresh per Cat 97 + update sitemap signal).
  Evidence required: Claude citation + cited page's `dateModified` or content showing staleness.
- **No founder / brand presence on X, but category is X-active** (Grok citation is structurally hard without X presence, affects niches like AI tools, dev tools, finance).
  Evidence required: empty X presence + active competitor X presence.
- **Per-LLM citation rate trending DOWN** quarter-over-quarter (not just absent, actively losing ground).
  Evidence required: tracked citation rate over time.

### NOT a Problem

- Brand cited in 1 of 5 LLMs but only 1 LLM is meaningful for the brand's audience (e.g., a B2B dev tool cited in Claude only, most dev users use Claude; absence from Gemini may not matter).
- Brand cited inconsistently per query, LLM behavior is non-deterministic; one off-prompt non-citation isn't a finding without a pattern.
- New brand (<6 months) absent from training-corpus-heavy LLMs, they may not have indexed yet; revisit at 12 months.

### Context Check

1. Which LLMs does the brand's audience actually use? Don't optimize for Gemini if the audience is on Claude.
2. Are foundational Cat 82 signals in place? If not, fix Cat 82 before per-LLM differentiation.
3. Is per-LLM citation tracked over time? Without a baseline, trending is impossible.
4. Are LLM-specific signals (X presence, Wikipedia entry, primary-source authorship) deliberate parts of the brand's strategy?
5. Has the team identified WHICH page each LLM is most likely to cite for a given query? Different LLMs may cite different pages on the same site for the same query.

### Reference

OpenAI ChatGPT search docs: https://help.openai.com/en/

Anthropic Claude documentation: https://docs.anthropic.com

Perplexity citation methodology: https://www.perplexity.ai/about

Google AI Overview / SGE updates: https://blog.google/products/search/

Cat 82 (AI-search citation), foundational layer for everything in Cat 102.

**Severity tagging:**
- Brand cited in some LLMs, absent from others where audience exists → High.
- Absent from Google AI Overview despite Google ranking → High.
- Cited content stale (Claude citing old data) → Medium.
- No X presence in X-active category → Medium.
- Citation rate declining quarter-over-quarter → High.

**Fix voice:** `jen-simmons` (primary) | `analytics-engineer` (backup).

Read `souls/jen-simmons.json` before writing the Fix.

Worked fix example:

> Treat each LLM as its own retrieval system with its own quirks, not as a generic "AI" surface. The signals that earn citation in Perplexity are not the same as the signals that earn citation in Claude.
>
> Three operating principles.
>
> **1. Foundational signals first (Cat 82).** Discoverability, extractability, authority, verifiability. If any layer is weak, no per-LLM tactic recovers it. Fix the foundation before optimizing per LLM.
>
> **2. Per-LLM testing is the audit.** Run the same 5 queries in each LLM you care about. Quote each response. Patterns surface, Perplexity cites your blog deep-page; ChatGPT cites your homepage; Claude cites your docs; Gemini doesn't cite you at all. Each pattern routes to a different fix.
>
> **3. Per-LLM signal investment, weighted by audience.** If the audience is on Claude, invest in primary-source authorship + clear Person schema (Cat 93). If the audience is on Perplexity, invest in comprehensive content depth + structured Q+A. If the audience is on Grok, invest in founder X presence (Cat 84). Don't spread effort across all LLMs equally; weight by where the actual audience lives.
>
> The compounding payoff: a brand consistently cited across 4 of 5 LLMs becomes the obvious answer to category questions. AI overviews zero-click most informational queries; the brands cited in those overviews are the new top-of-funnel.
