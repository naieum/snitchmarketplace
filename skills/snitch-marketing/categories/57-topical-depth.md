## CATEGORY 57: Topical depth & content gaps

Content depth is whether a page actually covers its topic comprehensively or just touches it. Google's helpful-content systems reward depth; thin or hedged content gets demoted. This is the AI-judgment category, quantify what you can (word count, related-topic coverage), but the call requires reading the content in context.

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

Read the content. Compare to topic expectations. Identify gaps.

### What to Search For

Substantive content vs filler:
- Headings that promise content but bodies that say little
- "Coming soon" placeholders
- Generic AI-generated paragraphs that hedge ("There are many ways to...")
- Lack of concrete examples / code / data

### Actually Hurts SEO

- **Page on topic X covers fewer sub-topics than competing top-10 results**.
  Evidence required: page's heading list + competitor pages' heading lists for comparison (limited in source-only audit; at minimum identify obvious gaps).
- **Page hedges instead of providing concrete answers**.
  Evidence required: quoted hedging language ("could", "might", "depends", "varies").
- **Page is shorter than the natural depth of the topic** (e.g., a "complete guide" at 400 words).
  Evidence required: title promise + word count.

### NOT a Problem

- Short, focused pages on narrow topics (a single-step tutorial). Depth = enough to do the one thing.
- Reference pages that are intentionally terse (API docs, glossary entries).
- Pages that link out to deeper resources for the sub-topics they don't cover internally.

### Context Check

1. What's the topic's natural depth?
2. Is the page positioned as a comprehensive guide or a quick reference?
3. Are competitors covering more? (Manual or automated SERP analysis can inform.)

### Reference

Google on helpful, reliable content: https://developers.google.com/search/docs/fundamentals/creating-helpful-content

**Severity tagging:**
- "Complete guide" with thin coverage → High.
- Heavy hedging language throughout → Medium.
- Missing 50%+ of expected sub-topics → High.

**Fix voice:** `frank-chimero` (primary) | `mike-monteiro` (backup).

Read `souls/frank-chimero.json` before writing the Fix.

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
