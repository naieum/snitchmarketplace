# Brand-authority platform sweep

Off-site presence is a load-bearing AI-citation signal: assistants weight whether a brand/entity
is discussed across the open web, not just what the brand says on its own site. This is the
authority layer of Cat 82 (AI-search citation, layer 3) and the off-site half of Cat 96
(brand-SERP defense, social + sameAs).

This is a presence/recency/sentiment checklist, not a weighted score. Snitch does not assign its
own correlation coefficients to platforms — fabricating one violates Rule 1. Published
industry-study correlations (cited below with their study sizes) may be used as *context* for why
a surface matters, always hedged as correlational, never presented as confirmed ranking factors
or converted into a scoring formula. Report what is present, how recent, and whether it is
brand-owned or third-party.

## Why mentions outrank the site's own link metrics

In a 2026 industry study of 75,000 brands, branded web mentions had the strongest correlation
with appearing in Google AI Overviews — 0.664, stronger than backlinks, referring domains, or
domain authority (correlational). The proposed mechanism: every brand mention on a credible page
is a training example associating brand→topic; consensus across many consistent sources raises
citation probability. Unlinked mentions therefore have standalone value — word-of-mouth at scale
plus a training signal — and the sweep below should weigh the third-party mention footprint above
the site's own link metrics.

Page-quality split from the same study (correlational): mentions on **highly-linked pages**
correlate at 0.7 with AI Overview visibility — higher than general mentions. Targeting rule:
mentions on highly-linked pages track Google AIO visibility; mentions on high-traffic pages track
ChatGPT/Perplexity visibility. Pick outreach targets by which platform matters for the brand.

## The three-tier mention-source model

Not all mentions are equal; classify mention-earning targets into three tiers with different
tactics:

- **Tier 1 — third-party editorial** (industry publications, review sites, authoritative
  listicles/comparisons, YouTube reviewers): hardest to earn, most valuable — these are the page
  types AI already cites. Tool-agnostic target discovery: find listicles/comparison posts in the
  niche that (a) do NOT mention the brand (search `title:best` / `title:versus` minus the brand
  name) and (b) already have many referring domains. Don't wait for AI to cite a page before
  pitching it — well-linked topical pages are likely future citation sources.
- **Tier 2 — UGC/community** (Reddit, Quora, niche forums): contribute genuine answers where the
  product fits; spamming backfires. Target discovery: threads already ranking top-5 in Google for
  niche terms.
- **Tier 3 — owned secondary properties** (other domains, YouTube channel, podcast, LinkedIn):
  all indexed, all additional training examples.

**Recurring mention audit:** mentions silently disappear when lists get refreshed. On re-audit,
check mention-volume drops, sentiment, and accuracy. Fix misinformation by updating owned content
first (fastest), then requesting publisher corrections — the longer it stands, the more the
models learn it.

## When surfaced

Loaded when Cat 82 layer 3 (authority) runs or when Cat 96 layer 4 (social + sameAs) audits the
off-site footprint.

## Tooling caveat (Critical)

Most of these platforms are consent-walled or JS-app surfaces that a plain `Fetch`/`curl` cannot
read. Capture method per platform is noted below. When a platform needs a tool not present this
run, mark that platform **Skip** with reason `off-site presence check requires a WebSearch/browser
tool or user-supplied evidence` — never assert a presence/absence you did not observe (Rule 1).

## The sweep

| Platform | What to check | Capture method |
|---|---|---|
| **Wikipedia** | Entity page exists; facts current; not flagged for notability/sources | Plain Fetch (article is server-rendered) |
| **YouTube** | Brand channel + third-party videos discussing the category; recency. See the dedicated section below — this is a scored surface, not a sweep item. | WebSearch / browser |
| **Reddit** | Brand mentioned in relevant subreddits; sentiment; unanswered complaints | WebSearch / browser |
| **LinkedIn** | Company page complete; founder/exec presence; post recency | WebSearch / browser (auth-walled) |
| **Quora** | Category questions where the brand is (or should be) named | WebSearch / browser |
| **Stack Overflow** | For dev tools: tag presence, answered questions, official account | Plain Fetch (questions are server-rendered) |
| **GitHub** | For dev/OSS brands: org presence, stars, active repos, README quality | Plain Fetch |
| **Crunchbase** | Company profile present and current (funding, team, links) | WebSearch / browser |
| **Product Hunt** | Launch presence + reviews (relevant for SaaS/tools) | WebSearch / browser |
| **G2** | Category listing, review volume/recency, response coverage | WebSearch / browser |
| **Trustpilot** | Review volume, rating trend, response coverage | WebSearch / browser |

Not every platform applies to every brand — a local plumber needs Trustpilot/Reddit/Wikipedia far
more than Stack Overflow. Use STEP 0 niche definition to pick the 4–6 that matter and skip the rest
with reason `not applicable to this brand's category`.

## YouTube: the highest-leverage single surface

YouTube is both AI input and output: major models have trained on large volumes of video
transcripts, and YouTube is the most-cited domain in Google's AI Overviews and AI Mode (~5.6% of
all AIO citations, per cross-platform industry studies). In the same 75,000-brand study, YouTube
mentions had a 0.737 correlation with ChatGPT visibility — the strongest single factor measured —
with YouTube mention *impressions* (views) second (correlational). What to audit:

- **Search hits over viral hits.** Videos answering queries people search monthly (stable,
  citation-prone, clear titles) beat interest-graph spikes that die. Discovery: find niche terms
  where YouTube videos already rank top-3 in Google — those are proven video-SERP topics; videos
  ranking in Google are the AIO citation pool.
- **Video ranking checklist** (for owned channels): exact search keyword in the title (creativity
  goes in the thumbnail); description opens with a genuine summary containing the keyword;
  timestamps → chapters (deep-linkable for fan-out sub-queries); **the keyword is spoken aloud**
  (Google parses the audio); the format matches what already ranks for the query (tutorial vs
  listicle).
- **No channel ≠ no YouTube presence.** For brands without channels, being mentioned/reviewed in
  *others'* videos is the play (e.g., free product to reviewers) — mention frequency in videos
  plus views were the strongest-correlating pair in the study.
- Findings map to the format-gap dimension of `references/ai-visibility-gap-analysis.md` when AI
  cites video for the brand's queries and the brand has no video presence at all.

## What a finding looks like

- "No Wikipedia entity page (Fetched `en.wikipedia.org/wiki/{Brand}` → 404); competitors {X},{Y}
  have current entries. Authority gap on the surface assistants weight most." (presence)
- "G2 listing exists but last review is 14 months old and 3 negative reviews are unanswered."
  (recency + sentiment + response coverage)
- "`sameAs` in Organization schema lists a LinkedIn URL that 404s." (cross-checks Cat 96 / Cat 37)

## Forbidden claims

- Any platform weighting Snitch invents, or a published correlation presented as a confirmed
  ranking factor / converted into a score. The study figures above are correlational context only,
  always cited with their study size and hedge.
- "The brand has no Reddit presence" without the search query run and its result.
- Asserting sentiment without quoting representative posts/reviews.
- "Earning mention X will get the brand cited." Mentions shift probabilities; never promise a
  citation outcome.

---

*Platform set adapted from the MIT-licensed geo-seo-claude and claude-seo projects; the correlation
weights those projects publish are intentionally NOT imported (unsourced). Internal reference only;
not surfaced in reports.*
