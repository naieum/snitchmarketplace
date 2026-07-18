# AI-visibility gap analysis

A classification-and-prioritization framework for AI-visibility findings. Instead of one
undifferentiated "brand not visible in AI answers" finding, every observed miss is bucketed into
one of six gap dimensions, because each dimension routes to a different fix — and every
remediation is one of three action types. This turns Cat 82 / Cat 102 citation findings into a
prioritized plan rather than a list of 50 undifferentiated recommendations.

All quantitative claims here trace to correlational industry studies (a 2026 study of 75,000
brands; a study of 17M AI citations across seven platforms); none are confirmed ranking factors.
Present them as correlations with hedged language, never as guarantees.

## When surfaced

Loaded when Cat 82 (AI-search citation) or Cat 102 (multi-LLM) produces Layer 3 / per-platform
findings that need classification and prioritization; when STEP 4.5 strategic recommendations
synthesize GEO work into a plan; or when the user asks "where do we stand in AI search?" and the
answer needs more structure than a citation list.

## Step zero: the branded entity map

Before measuring anything, enumerate every entity the brand is known by — each has its own
visibility profile:

1. **List entities:** main brand, sub-brands, product names, proprietary features, proprietary
   metrics/frameworks, and personal brands (founders, known staff — cross-reference Cat 84).
2. **Per entity, list the topics + attributes it should own.** LLMs infer meaning from how an
   entity is *described* across the corpus, not from the name alone.
3. **Mine keyword / review data for the descriptive phrases actually in use** ("affordable",
   "enterprise-grade") — recurring modifiers define the benchmark for what the brand should be
   known for.
4. **Run the gap analysis per entity**, not just for the top-level brand.

## The six gap dimensions

Bucket every observed prompt/citation miss into exactly one:

| # | Gap | What it looks like | Primary fix surface |
|---|---|---|---|
| 1 | **Visibility** | Brand appears less often than competitors in search/AI results for its category | Cat 82 Layers 1-3 |
| 2 | **Narrative** | How AI/media describes the brand contradicts desired positioning (a premium tool called a "budget alternative") | Cat 81 positioning + owned brand-fact pages (Cat 82 Layer 4) |
| 3 | **Topic** | Topics the brand should be associated with but isn't (a PM tool never mentioned for "remote team collaboration") | Content coverage (Cat 57 / Cat 82 fan-out) |
| 4 | **Format** | AI cites content types (guides, videos, reviews, comparisons) the brand doesn't produce | Content strategy (Cat 70) + YouTube/review surfaces |
| 5 | **Web mentions** | External listicles / review sites / forums mention competitors but not the brand | Off-site outreach (`references/brand-authority-platforms.md`) |
| 6 | **Demand** | Branded/awareness queries in the space where the brand's name never comes up | Brand marketing; longest-horizon gap |

## Fix / Build / Influence triage

Every remediation is one of three actions:

- **Fix** — improve something that exists (a ranking page with a topic gap needs an update).
- **Build** — create new content/pages for uncovered opportunities.
- **Influence** — off-site outreach for mentions (the brand is missing from a listicle every
  competitor is on).

Weigh each opportunity by three questions: how much demand could it drive? does it support brand
credibility? does it improve citation odds? Start with quick wins — an existing ranking page plus
a content update is low effort / high impact. Never ship the findings as an unweighted list.

## The three-pillar measurement stack

AI visibility cannot be read from one instrument; each pillar is partial, and any single-pillar
number needs its undercount caveat stated.

1. **AI referral traffic** — a custom analytics channel matching AI referrer sources
   (`chat.openai.com|chatgpt.com`, `perplexity`, `gemini.google.com`, `copilot.microsoft.com`,
   `claude.ai`, `deepseek.com`). **Known leakage (report this caveat with any AI-traffic
   finding):** several platforms strip referrer data, so analytics undercount — ChatGPT search
   source-links pass a referrer, but in-content links on paid accounts use `no-referrer` and land
   in Direct; Claude passes; Perplexity passes on web but not its desktop app; Copilot passes on
   web but not the Windows app; Grok passes nothing. Two reads once live: which pages get AI
   traffic (keep those fresh, accurate, with CTAs — stale recommended pages get dropped) and
   which key pages get zero AI referrals (route to content/crawl/topic investigation).
2. **AI bot activity** — server-log / bot-analytics segmentation by the training-vs-retrieval
   split in `references/ai-crawler-registry.md`. Pages repeatedly fetched by live-retrieval bots
   are likely answer sources right now; priority pages never visited are Layer 1 findings.
3. **Self-reported attribution** — a "How did you hear about us?" question with AI-assistant
   options at signup/checkout. AI-driven discovery mostly converts via later direct or
   branded-organic visits that analytics attribute elsewhere, so this pillar catches what the
   other two structurally miss.

Scale framing for reports: industry data (correlational/self-reported) puts AI referrals around
0.25% of average site traffic — but with materially higher conversion rates than organic reported
by multiple vendors, because the assistant has already argued the fit before the click. Present
both halves; never let a small traffic share read as "ignore this channel," and never present a
vendor's conversion multiple as the customer's expected outcome.

## Trend metrics + cadence

GEO progress is measured against a saved baseline on a fixed cadence, across four trend metrics:

1. **AI share of voice** vs competitors.
2. **New citing domains** (did the mention-earning work pay off?).
3. **Topic-coverage gap closure** + new topics appearing.
4. **Mention sentiment/accuracy** (misinformation drift is a narrative-gap regression).

Cadence: **monthly** light check of the four metrics; **quarterly** full competitive re-audit.
Any metric flat while a competitor's grows is a dig-in trigger. A single capture is one draw from
a distribution — citation sets churn heavily between answer refreshes, so trends over a baseline
are the only defensible read (see Cat 82's volatility calibration).

## First-week action order

For a new engagement, sequence the opening moves:

1. `robots.txt` AI-bot check (5 minutes; the most common blocker — including platform-injected
   default blocks, per `references/ai-crawler-registry.md`).
2. AI analytics channel + the attribution question live from day one (baselines can't be
   backfilled).
3. Refresh the top 5-10 pages meaningfully (new stats, current facts — not date-only edits).
4. Run the gap-analysis baseline (entity map → six-gap classification).
5. Pick the top 10 mention-earning targets (`references/brand-authority-platforms.md` tiers).

## Forbidden claims

- Presenting any study correlation as a confirmed ranking factor. Hedge every figure.
- A gap classification without the observed evidence (quoted answer, quoted listicle, quoted
  description) that put the miss in that bucket.
- An AI-traffic number without the referrer-leakage undercount caveat.
- "Share of voice dropped" from a single capture — trend claims require a saved baseline.

---

*Framework synthesized from 2026 industry AEO practice and correlational studies (75,000-brand
visibility study; 17M-citation cross-platform study), expressed tool-agnostically. Internal
reference only; not surfaced in reports.*
