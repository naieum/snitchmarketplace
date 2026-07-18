## CATEGORY 70: Content marketing strategy

In 2026 the content game changed. AI overviews zero-click most informational queries, generic "what is X" / "how to X" content rarely earns the visit even when it ranks. Baseline assumption: Google optimizes for satisfying searchers on-platform (featured snippets, AI overviews, meta descriptions rewritten to answer the query) — any strategy premised on "good content gets rewarded with traffic" is built on a false premise. The strategies that work now:

- **Business-potential scoring**: score every candidate topic 0-3 by how indispensable the product is to solving the problem the topic covers. 3 = the product is an irreplaceable solution; 2 = it helps but isn't essential; 1 = it can only be mentioned fleetingly (purely educational, nobody's ready to buy); 0 = no way to mention it. Prioritize by traffic potential × business potential. Traffic that can't move the business is a traffic source, not a strategy. Prerequisite: deep product knowledge — the hardest part of product-led content.
- **Product-led weaving, never hard-selling**: in posts on 2-3-scored topics, place the product inside the step where it's actually used, framed as why that step gets easier. The mention must survive the removal-of-brand test (the advice stays complete without it). E-commerce variant: the product link sits adjacent to the specific advice that implies it, so need and purchase are seconds apart.
- **Distribution-first, not ranking-first**: assume Google won't send you the visitor; plan distribution (newsletter, LinkedIn, X, podcast, community) on day one of writing. The post that lives only on your blog reaches no one in 2026. Checkable form — the promotion-before-creation gate: before a piece is written, three questions need answers: (1) who can we share this with? (2) who's going to link to it? (3) how will it rank, step by step? No answers → the piece gets deferred. Content doesn't rank itself, especially on low-backlink sites.
- **AI-extraction-aware**: write content that LLMs can lift cleanly (clear definitions in opening paragraph, structured tables, explicit Q+A). Cross-reference Cat 82.
- **Commercial-intent + comparison content** still earns clicks (queries with high commercial intent: `<competitor> alternative`, `best X for Y`, `X vs Y`, AI overviews don't fully displace these).
- **Original data + research** earns links and citations the AI can't fabricate.
- **Experience-driven content**: tactics are copyable; lived experience isn't. Do something worth talking about, then tell that story — first-hand experiments, real numbers, a story only this team could tell. A content set of purely synthesizable material has no moat and is increasingly indistinguishable from AI output.
- **Founder-led essays** > faceless blog posts (cross-reference Cat 84).

Audit covers: cadence, topic coverage, distribution surfaces, capture infrastructure (newsletter signup), AI-extraction-friendliness.

### Pre-flight: content presence check

If the site has zero blog/article/post content (no `/blog/`, no `/posts/`, no `/articles/` route, no MDX files in `content/`), **Skip** with reason `no published content yet; content strategy is a build-from-scratch question, see STEP 5 recommendations`. Don't run Evidence Required.

### Evidence required (do not skip, only when content exists)

**Source mode, required tool calls:**

1. `Glob` blog post files. Sort by date. Compute publish cadence over last 90 days, last year.
2. `Read` posts: extract topics. Cluster by theme.
3. Check distribution channels: is each post syndicated to LinkedIn / X / dev.to / Hacker News / newsletter?
4. Check author diversity: one voice or many?

**Crawl mode, required tool calls:**

1. `Fetch /blog` or equivalent index. Extract post titles, dates, authors.
2. Same cadence + topic + author analysis.

### Forbidden claims

- "Content cadence may be inconsistent." Quote dates.
- "Topics may be scattered." Show the topic clusters.

### Detection

Blog file enumeration + frontmatter analysis.

### What to Search For

Frontmatter fields:
- `date`, `publishedAt`, `pubDate` (date)
- `author`, `by` (author)
- `tags`, `categories`, `topics` (topical clustering)
- `description`, `excerpt` (intent / hook)

Distribution patterns:
- Cross-post links in posts ("originally published on dev.to")
- RSS feed presence (`/rss.xml`, `/feed.xml`)
- Newsletter signup CTA on every post (capture for distribution)

Business-potential patterns:
- Product mentions inside informational posts (woven into the relevant step vs bolted-on pitch vs absent)
- Conclusion internal links: does each post route the reader anywhere (related post, comparison/roundup piece, product page), or dead-end?
- First-hand material: experiments, real numbers, screenshots of the team's own results vs recycled synthesizable advice

### Actually Hurts the Marketing Surface

- **Cadence collapsed** (2 posts in last 90 days vs 12 in the prior 90).
  Evidence required: date counts.
- **All posts on one narrow topic** when the audience cares about a broader set.
  Evidence required: topic distribution + audience analysis.
- **No distribution beyond own blog** (no LinkedIn cross-posts, no X threads, no newsletter, no Hacker News submissions).
  Evidence required: post analysis + missing distribution signals.
- **Posts have no email-capture CTA** (every post should at minimum offer the newsletter).
  Evidence required: post template content + missing signup form.
- **Content CTAs scatter across many different assets** (each post points at a different
  download / signup / offer). Repetition is the mechanism: people act on the sixth-to-eighth
  exposure to the *same* asset, and one funnel's follow-up can be tuned where ten can't.
  Evidence required: post CTA inventory showing 4+ distinct destination assets with no primary.
- **All attention content, no conversion content** (broad, viral-shaped topics with no deep
  tactical content serving the actual buyer) — reach without buyers. Or the inverse: all
  niche conversion content with nothing that opens the top of the funnel. A working engine
  runs both layers on purpose.
  Evidence required: topic clusters mapped to funnel role, showing one layer entirely absent.
- **Content set skews to business-potential-0/1 topics** — the topics rank or could rank, but
  the product can't be mentioned beyond a fleeting aside, so the traffic can't convert. This is
  the scored, per-topic form of "all attention, no conversion."
  Evidence required: topic inventory scored 0-3 against the product, showing the skew (quote
  representative titles per score).
- **Dead-end posts on business-potential-2/3 topics** — an informational post on a topic where
  the product genuinely helps, but with no pathway to commercial content: no product woven into
  the step where it's used, no internal links in the conclusion, no bridge via a
  comparison/roundup piece. (When a direct product plug would feel unnatural, the bridge is the
  fix: informational → comparison → product, each hop natural.)
  Evidence required: the post's ending quoted + the absent links/pathway.
- **No first-hand experience anywhere in the content set** — zero experiments, real numbers, or
  stories only this team could tell; every post could have been synthesized from the existing
  top results.
  Evidence required: content sample (3+ posts) showing only recycled/synthesizable material.
- **Every title opens a new intellectual loop; none closes a loop the audience already
  carries.** Content that explodes closes an emotionally charged question readers already
  have ("how do I deal with X" beats "three interesting facts about X"). Same rule for lead
  magnets: if the team can't answer "what problem does this asset solve?", it won't convert.
  Evidence required: title inventory + absence of problem-shaped/loop-closing titles.
- **Single-author content** when team has multiple subject-matter experts.
  Evidence required: author distribution.

### NOT a Problem

- Low cadence on a brand that publishes deep / quarterly content (Stripe, GitHub-style). Quality > quantity.
- Narrow-topic blog if the niche is intentionally narrow.
- Some business-potential-0/1 topics in the mix — deliberate top-of-funnel reach is fine; the finding is the *skew*, not the presence.
- Posts with no product mention where none fits naturally. A hard-sold mention that fails the removal-of-brand test is worse than no mention.
- Product-led scoring on a business it doesn't fit: it works when the product solves common searchable problems; a local pub or chiropractor should weight local SEO instead. Skip the scoring lens there.

### Context Check

1. What's the team's content capacity? Don't recommend cadence the team can't sustain.
2. Where does the audience consume content (RSS, email, social, podcast)?
3. Is there a content team or is the founder writing? Affects realistic cadence.
4. Is content the primary acquisition channel or a secondary signal?
5. Does the product solve common searchable problems (business-potential scoring applies), or is this a local/relationship business (it doesn't)?

### Reference

Animalz on content frameworks: https://www.animalz.co/blog/


**Severity tagging:**
- Cadence dropped >50% in last 90 days → High.
- Missing newsletter capture on blog → High.
- Content CTAs scattered across 4+ assets with no primary lead generator → Medium.
- Attention/conversion layer entirely missing (either direction) → Medium.
- Content set skewed to business-potential-0/1 topics (where the scoring lens applies) → Medium; High when content is the primary acquisition channel.
- Dead-end posts on business-potential-2/3 topics (no product weave, no conclusion links, no commercial bridge) → Medium.
- No first-hand experience anywhere in the content set → Medium.
- No loop-closing / problem-shaped titles anywhere in the content set → Medium.
- No distribution beyond own site → Medium.
- Topic concentration too narrow → Medium.

**Fix voice:** `frank-chimero` (primary) | `mike-monteiro` (backup).

Read `souls/frank-chimero.json` before writing the Fix.

Worked fix example:

> Pick a sustainable cadence. Once a week is more than most teams can hold; once every two weeks usually wins long-term over weekly that breaks in three months.
>
> Topics: cluster around 4-6 themes the audience cares about, not 20. Each post earns its place in one cluster. Over a year you build authority on those clusters; Google rewards depth.
>
> Then score every candidate topic 0-3: can the product be the natural hero of the solution (3), a helper (2), a footnote (1), or nothing at all (0)? Order the roadmap by traffic potential × business potential, and let the 0s go. When you write a 2 or a 3, put the product inside the step where it's actually used — the advice must stay complete if the brand name were deleted. And no post ends at a dead end: the conclusion links somewhere, and posts on scored topics get a path to commercial content, directly or through a comparison piece.
>
> Before any piece gets written, make it pass the gate: who will you share it with, who will link to it, how will it rank — step by step. If nobody can answer, the piece isn't ready to exist yet. "If you build it, they will come" fails hardest on low-backlink sites.
>
> If you're a low-authority site in a competitive niche, don't swing at head terms owned by big-brand sites — the problem isn't your content, it's the battlefield. Ladder in: target low-difficulty keywords that still score on business potential, compete only where the currently-ranking sites are your authority peers, and re-tier upward as authority grows. Fresh keyword spaces come from unusual seed terms (an LLM will list 20-40 niche-adjacent phrases the obvious seeds miss), from enumerating structural patterns in keywords you've already found, and from harvesting the top pages of low-authority competitors who already win those terms. A page stuck around position 30+ for months despite tweaks usually means wrong battlefield, not bad content.
>
> Distribution: every post gets cross-posted somewhere. LinkedIn, X thread, newsletter at minimum. The post that lives only on your blog reaches your existing readership; the post that exists across three surfaces compounds. Include places where traffic already flows: forum and Reddit threads that already rank for your niche keywords carry proven, recurring traffic — a helpful answer there (especially in ranking threads with few comments, or early in new threads) compounds into recognition.
>
> Capture: every post has a newsletter signup mid-page or at the bottom. The casual reader who liked the post becomes a recurring reader.
>
> Run two layers on purpose: broad attention content that keeps opening the top of the funnel, and deep tactical content that serves the person who will actually pay. And point everything at one lead generator — the reader who has seen the same asset offered six times downloads it; the reader offered six different assets downloads none.
