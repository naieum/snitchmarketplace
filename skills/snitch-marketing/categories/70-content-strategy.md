## CATEGORY 70: Content marketing strategy

In 2026 the content game changed. AI overviews zero-click most informational queries, generic "what is X" / "how to X" content rarely earns the visit even when it ranks. The strategies that work now:

- **Distribution-first, not ranking-first**: assume Google won't send you the visitor; plan distribution (newsletter, LinkedIn, X, podcast, community) on day one of writing. The post that lives only on your blog reaches no one in 2026.
- **AI-extraction-aware**: write content that LLMs can lift cleanly (clear definitions in opening paragraph, structured tables, explicit Q+A). Cross-reference Cat 82.
- **Commercial-intent + comparison content** still earns clicks (queries with high commercial intent: `<competitor> alternative`, `best X for Y`, `X vs Y`, AI overviews don't fully displace these).
- **Original data + research** earns links and citations the AI can't fabricate.
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

### Actually Hurts the Marketing Surface

- **Cadence collapsed** (2 posts in last 90 days vs 12 in the prior 90).
  Evidence required: date counts.
- **All posts on one narrow topic** when the audience cares about a broader set.
  Evidence required: topic distribution + audience analysis.
- **No distribution beyond own blog** (no LinkedIn cross-posts, no X threads, no newsletter, no Hacker News submissions).
  Evidence required: post analysis + missing distribution signals.
- **Posts have no email-capture CTA** (every post should at minimum offer the newsletter).
  Evidence required: post template content + missing signup form.
- **Single-author content** when team has multiple subject-matter experts.
  Evidence required: author distribution.

### NOT a Problem

- Low cadence on a brand that publishes deep / quarterly content (Stripe, GitHub-style). Quality > quantity.
- Narrow-topic blog if the niche is intentionally narrow.

### Context Check

1. What's the team's content capacity? Don't recommend cadence the team can't sustain.
2. Where does the audience consume content (RSS, email, social, podcast)?
3. Is there a content team or is the founder writing? Affects realistic cadence.
4. Is content the primary acquisition channel or a secondary signal?

### Reference

Animalz on content frameworks: https://www.animalz.co/blog/

**Severity tagging:**
- Cadence dropped >50% in last 90 days → High.
- Missing newsletter capture on blog → High.
- No distribution beyond own site → Medium.
- Topic concentration too narrow → Medium.

**Fix voice:** `frank-chimero` (primary) | `mike-monteiro` (backup).

Read `souls/frank-chimero.json` before writing the Fix.

Worked fix example:

> Pick a sustainable cadence. Once a week is more than most teams can hold; once every two weeks usually wins long-term over weekly that breaks in three months.
>
> Topics: cluster around 4-6 themes the audience cares about, not 20. Each post earns its place in one cluster. Over a year you build authority on those clusters; Google rewards depth.
>
> Distribution: every post gets cross-posted somewhere. LinkedIn, X thread, newsletter at minimum. The post that lives only on your blog reaches your existing readership; the post that exists across three surfaces compounds.
>
> Capture: every post has a newsletter signup mid-page or at the bottom. The casual reader who liked the post becomes a recurring reader.
