## CATEGORY 57: Topical depth & content gaps

Content depth is whether a page actually covers its topic comprehensively or just touches it. Google's helpful-content systems reward depth; thin or hedged content gets demoted. This is the AI-judgment category, quantify what you can (word count, related-topic coverage), but the call requires reading the content in context.

Add a readability check to the quantitative side: compute the Flesch-Kincaid score per `references/content-intelligence.md` and report it against the brand's actual audience (`references/context-file.md`). The finding is a mismatch — a consumer page reading at grade 16, or a technical reference dumbed below its audience — not a universal target grade.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Read` the page's content fully (article body, MDX content, CMS-driven copy).
2. Identify the page's claimed topic (from title, H1, URL).
3. Check whether the content addresses the typical sub-questions a reader of that topic would have. (E.g., a "Next.js SEO checklist" page should cover: meta tags, canonical, sitemap, structured data, performance, mobile, at minimum.)
4. Quote the heading list + a sample of body content.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Extract main content. Word count + heading list.
2. Apply same topic-coverage heuristic.

### Forbidden claims

- "The content may be shallow." Be specific, what's missing for the topic.
- "Topic coverage is probably weak." List the missing sub-topics.

### Detection

Read the content. Then derive the topic's expected coverage from the SERP three ways and triangulate — "deep enough" is defined by what wins the query, not by word count:

1. **Headings**: extract the heading structure of the top 3 ranking pages that share the page's angle. Any subtopic covered by 2+ of them is mandatory: the page covers it, or the depth finding stands.
2. **PAA + related searches**: the sub-questions and audience segments the engine has already observed for the query.
3. **Shared ranking overlap**: the keywords the top 3 ranking URLs ALL rank for (a content-gap or shared-rankings report with the auditee's side blank). Shared keywords expose subtopics and — as important — the exact language searchers use.

Shortcut: feed the top URLs (or the shared-terms export) to an LLM and ask for commonalities plus an outline for the identified audience — the same triangulation, faster.

Validity rules: compare only against pages that share the page's angle (a beginner "what is X" post's headings are not the benchmark for an advanced guide, or vice versa). And this is not copying — the engine ranking similar pages at the top is it declaring what searchers expect; angle and examples are where the page differs.

### What to Search For

Substantive content vs filler:
- Headings that promise content but bodies that say little
- "Coming soon" placeholders
- Generic AI-generated paragraphs that hedge ("There are many ways to...")
- Lack of concrete examples / code / data

### Cluster-level depth: hubs and pillars

Depth also lives at the cluster level. A content hub = one pillar page on a broad topic + subpages going deep on its facets, connected bidirectionally: the pillar links to each subpage from the relevant section, and every subpage links back to the pillar (Cat 19 carries the link mechanics). The payoff is twofold: the semantic relationships build topical authority, and backlinks earned by ANY page in the hub lift the whole group through the internal links — one documented B2B hub earned 500+ referring domains in about seven months and grew to roughly 6,000 monthly search visits (practitioner-reported, single case).

A topic qualifies as a pillar only if:

1. **5-20 genuine subtopics fit under it.** Fewer = too narrow to be a hub; more = too broad to be one page's topic.
2. **The pillar targets a popular head query**, not a long-tail one.
3. **The site type can match the pillar SERP's intent** (Cat 58).

Subpage test: a good subpage is a subsection of the pillar that deserves its own depth. Tangentially related pages (a "delete your account" how-to under an advertising hub) are out. Subtopic sources: "list of X" pages, an encyclopedia's section structure for the topic (a pre-organized taxonomy), phrase-match keyword expansion filtered to informational intent. Not every site should build hubs — micro-niche sites often lack enough subtopics to clear the floor.

### Actually Hurts SEO

- **Page on topic X covers fewer sub-topics than competing top-10 results**.
  Evidence required: page's heading list + competitor pages' heading lists for comparison (limited in source-only audit; at minimum identify obvious gaps).
- **Page hedges instead of providing concrete answers**.
  Evidence required: quoted hedging language ("could", "might", "depends", "varies").
- **Page is shorter than the natural depth of the topic** (e.g., a "complete guide" at 400 words).
  Evidence required: title promise + word count.
- **Hub/pillar built on the wrong foundation** (pillar targets a long-tail query, has fewer than ~5 genuine subtopics, or its subpages are only tangentially related).
  Evidence required: pillar URL + its target query + the subpage list.

### NOT a Problem

- Short, focused pages on narrow topics (a single-step tutorial). Depth = enough to do the one thing.
- Reference pages that are intentionally terse (API docs, glossary entries).
- Pages that link out to deeper resources for the sub-topics they don't cover internally.

### Context Check

1. What's the topic's natural depth?
2. Is the page positioned as a comprehensive guide or a quick reference?
3. Are competitors covering more? (Manual or automated SERP analysis can inform. Compare same-angle pages only.)
4. Do the topic's SERPs show rank inversions — a topically focused, lower-authority domain outranking stronger generalists? That's evidence topical authority matters for this query class, and it raises the weight of a cluster-focus recommendation.

### Reference

Google on helpful, reliable content: https://developers.google.com/search/docs/fundamentals/creating-helpful-content

**Severity tagging:**
- "Complete guide" with thin coverage → High.
- Heavy hedging language throughout → Medium.
- Missing 50%+ of expected sub-topics → High.
- Subtopic covered by 2+ of the top-3 same-angle pages absent from the page → High.
- Pillar page targeting a long-tail query, or a hub with <5 genuine subtopics → Medium.

**Fix voice:** `content-shape-editor` (primary) | `honest-design-critic` (backup).

Read `souls/content-shape-editor.json` before writing the Fix.

Worked fix example:

> The page promised a "Complete Next.js SEO checklist" and delivered six bullet points. The reader who clicked from a SERP wanted the full thing, not a teaser, not a cliffhanger to a paid product, the actual checklist.
>
> Cover what the title promised. For each top sub-topic of the field:
>
> 1. Name it as a heading.
> 2. Explain what it is in plain language.
> 3. Show the wrong way (with code if applicable).
> 4. Show the right way.
> 5. Note the gotchas specific to the framework / context.
>
> Length follows substance. If the topic warrants 3,000 words, write 3,000. If 800 cover it well, stop at 800. Padding to hit a word count produces the same shallow content from the other direction.
