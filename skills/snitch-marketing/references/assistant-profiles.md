# Assistant profiles — how each AI surface picks its sources

Cat 82 audits one shared substrate (crawler access, extractable passages, authority,
verifiability). This file is the per-assistant layer on top of it: what each major assistant
retrieves from, what it trusts, how it cites, and which signal actually earns a citation there.
A brand cited heavily by one assistant can be invisible in another, and the fix differs per
surface — so the profile is what turns "absent from assistant X" into a routed finding.

## When surfaced

Loaded when Cat 82 reaches Layer 3 (authority) and the brand cares about more than one
assistant. Everything here is diagnostic input, never evidence on its own: a per-assistant
finding still needs a captured response, under Cat 82's Layer 3 tooling caveat (a browser or
`WebSearch` tool, or answers the user pasted — otherwise Skip-with-reason). Never assert or
fabricate a per-assistant outcome you did not observe; non-determinism across assistants makes
invented results especially misleading.

## Reading the profiles

Vendors change retrieval, rendering, and licensing without announcement. Every profile below is
a *starting hypothesis* drawn from correlational industry citation studies, not a spec: check
the vendor's current model card and crawler documentation before stating any of it as fact in a
Finding. Where a profile and an observed capture disagree, the capture wins.

**Prioritization rule.** Don't audit every assistant with equal weight. Pick by (a) audience
market share — the general-purpose assistants and the search engine's own AI surfaces dominate
usage — and (b) overlap with existing strength: a brand that ranks well in classic search has a
head start on the search-coupled assistants; a brand with an editorial-PR and forum footprint
has a head start on the publisher-weighted ones.

## Profile 1: the publisher-weighted general assistant (ChatGPT with web search)

- **Training cutoff**: moves with each model release; check the vendor's current model card
  rather than quoting a version.
- **Retrieval**: the Bing search index for live queries, plus the vendor's own curated browsing
  layer.
- **Citation style**: inline numbered citations linking the source domain.
- **Trust hierarchy**: weights Wikipedia, .edu and major publications heavily. Industry citation
  studies (correlational) profile it as publisher- and forum-heavy — Reddit, Wikipedia, Amazon,
  major business press — with a median domain rating around 90 among top-cited pages (partly a
  consequence of content-licensing deals), and only 8-10% overlap with Google's top-10 for the
  same queries; Reddit is currently its most-cited domain. Strongly freshness-biased: ~90% of its
  top-cited pages were updated within the year, ~76% within the last 30 days.
- **Earns a citation**: presence in the Bing index, a Wikipedia entry, original research worth
  quoting, recent timestamps, editorial/press coverage and Reddit discussion. Google ranking
  transfers here least of all.
- **Rendering caveat**: this vendor's crawlers have been documented as not executing JavaScript,
  which would make a JS-only page an empty shell to this surface specifically (Cat 82 Layer 1).
  Rendering support changes without announcement — verify before naming it in a Finding.

## Profile 2: the primary-source assistant (Claude with web search)

- **Training cutoff**: varies per model; web search supplements it.
- **Retrieval**: the vendor's own web-search tool, when enabled.
- **Citation style**: inline citations with source links; favors primary sources over
  aggregators.
- **Trust hierarchy**: weights official documentation, vendor engineering blogs and first-party
  posts; skeptical of SEO-spam-shaped content.
- **Earns a citation**: original analysis rather than aggregation, clear authorship (Person
  schema, validated under Cat 32), primary-source links, well-structured and well-attributed
  writing.

## Profile 3: the live-retrieval answer engine (Perplexity)

- **Training cutoff**: effectively none — live retrieval per query, minimal reliance on a
  training corpus.
- **Retrieval**: its own index plus multiple search APIs.
- **Citation style**: heavy citation density; a numbered sources panel is always visible;
  orders citations newest-first.
- **Trust hierarchy**: authoritative + recent + on-topic, and comparatively fair to indie,
  niche and regional sources. The most search-aligned assistant in industry studies: roughly
  28.6% of its citations come from Google's top-10 for the query (correlational).
- **Earns a citation**: comprehensive on-topic coverage, recency, structured headings and Q+A
  patterns, and Google ranking — which transfers here more than anywhere else.

## Profile 4: the search engine's own AI surfaces (AI Overviews and AI Mode)

Treat these as two sub-surfaces, not one. They produce answers that are ~86% semantically
similar while sharing only ~13.7% of their citations.

- **Retrieval**: Google's full index and graph.
- **Citation style**: AI Overviews render above the results with sources in an expandable
  panel; AI Mode is a separate conversational surface with its own citation behavior.
- **Trust hierarchy**: Google's existing ranking signals (authority, relevance, freshness) *plus*
  extraction-friendliness. Per-surface profiles from industry studies (correlational):
  **AI Overviews** favor authoritative/encyclopedic sources and Google properties, and cite
  YouTube heavily (~5.6% of all its citations) along with Reddit. **AI Mode** cites YouTube most
  of all by a wide margin, then Google properties and Wikipedia; it pulls Quora ~3.5x more than
  AI Overviews and reaches into Facebook and Instagram more.
- **The ranking coupling is weakening**: earlier studies put ~76% of AI Overview citations
  inside Google's top-10; newer data puts it near 38%, and ~14% of cited pages don't rank in
  Google's top 100 at all. Ranking helps; it is no longer the whole story.
- **Earns a citation**: ranking in regular Google search, structured extractable content per
  Cat 82 Layer 2, clear topic ownership, and a YouTube presence on the topics where video
  already ranks.

## Profile 5: the social-graph assistant (Grok and niche assistants)

- **Training cutoff**: varies; Grok weights X content heavily.
- **Retrieval**: the X social graph plus the web.
- **Citation style**: mixes social posts with web sources.
- **Trust hierarchy**: real-time social signal and technical depth.
- **Earns a citation**: founder and brand presence on X (Cat 84), technical content depth,
  recent posting cadence. Structurally hard without that presence, which matters most in the
  niches that live on the platform (dev tools, AI, finance).

## Mention ≠ citation: link rates differ per assistant

Record three states per query per assistant: **cited-and-linked** (clickable traffic),
**mentioned-but-not-linked** (the brand is named with no link — word-of-mouth at scale that
feeds brand-name search and training associations), and **invisible**.

Only ~28% of AI mentions include a link on average, and the rate is assistant-specific
(industry study, correlational): Perplexity links ~51.6% of mentions, AI Mode ~36.8%, ChatGPT
~26.9%, and AI Overviews ~10.7%. Impression-weighted, the picture shifts again — links
concentrate on high-volume queries (Perplexity links appear in ~78% of impressions; Gemini links
in ~71% of impressions despite linking a sixth of mentions).

Two consequences for the audit:

1. Auditing clickable citations alone misses most visibility events, worst of all on the
   surfaces that rarely link. A mention on a low-link-rate surface is the platform behaving
   normally, not a brand failure.
2. The tool-agnostic metric set per assistant is mentions, citations (linked), impressions, and
   share of voice against competitors — and **the gap between impressions and mentions is the
   opportunity**: the assistant is answering questions about the brand's topic without naming
   it. A response-type lens routes the fix: step-by-step guides suit service and how-to brands,
   direct factual answers suit publishers (authority without clicks), video citations suit
   creators.

Full measurement stack (referral leakage, bot activity, self-reported attribution) and the
monthly/quarterly cadence live in `references/ai-visibility-gap-analysis.md`. Passage-level
scoring — the substrate every profile sits on, because a passage that fails extractability
fails on every assistant — lives in `references/citability-scoring.md`; fix it once rather than
per assistant.

## Turning a profile into a finding

| Observed | Likely layer | Route to |
|---|---|---|
| Cited by Perplexity, absent from ChatGPT | Layer 3 | Wikipedia entry, editorial/press coverage, Reddit presence, Bing index coverage |
| Absent from Google's AI surfaces while ranking organically | Layer 2 | Extractability: leading definition, Q+A headings, table headers |
| Cited, but the cited page is stale or wrong | Layer 4 | Refresh through Cat 97, keeping the URL |
| Absent from Grok in an X-native niche | Layer 3 | Founder/brand presence and cadence (Cat 84) |
| Named everywhere, linked nowhere | not a finding | Record the mention state; check the assistant's link rate first |

None of these is reportable without the captured response that shows it.
