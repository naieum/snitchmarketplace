## CATEGORY 58: Keyword targeting / intent match

The page should match the search intent of the keywords it's targeting. Targeting "best running shoes" with a page that's actually a brand history is a mismatch, Google figures it out, the page ranks for nothing, the visitor bounces.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Read` the page. Identify the title + H1 + meta description (the page's stated topic + intent signals).
2. Read the actual content. Compare to the stated topic.
3. Identify intent shape (informational, commercial, transactional, navigational).
4. Quote the mismatch if present.

**Crawl mode, required tool calls:**

1. Same as source.

### Forbidden claims

- "The page may not match search intent." Quote the title + content for comparison.
- "Targeting may be off." Be specific.

### Detection

Read title + H1 + content. Identify the expected intent for the targeted keyword. Identify mismatch.

Intent types:
- **Informational**: "what is X", "how to X", content should explain
- **Commercial investigation**: "best X", "X review", content should compare
- **Transactional**: "buy X", "X pricing", content should sell
- **Navigational**: brand searches, content should be the brand's home for that thing

### What to Search For

Common mismatches:
- Title promises a product page; content is an article (or vice versa)
- Title promises pricing; content has no pricing
- Title promises a tutorial; content is a sales pitch
- Title is a question; content doesn't answer it

### Actually Hurts SEO

- **Title says "How to X" but content doesn't show steps**.
  Evidence required: title + content showing missing steps.
- **Title says "Best X" but content covers only one option**.
  Evidence required: title + content sample.
- **Title says "X pricing" but content has no prices**.
  Evidence required: title + content showing missing prices.
- **Page targeting a commercial keyword with informational content** (and vice versa).
  Evidence required: keyword intent + content actual.

### NOT a Problem

- Pages with intentionally broad scope (e.g., a glossary or a portal page).
- Pages where the title is poetic / metaphorical and the content is strong (the title isn't keyword-targeted).

### Context Check

1. What keyword does the page target (per title, H1, meta)?
2. What's the typical content shape for that keyword's SERP? (Manually check the SERP for the top 5.)
3. Does the page's content shape match?

### Reference

Google on understanding search intent: https://developers.google.com/search/docs/fundamentals/seo-starter-guide

**Severity tagging:**
- Title/content intent mismatch on commercial keyword → High.
- Title promises X, content doesn't deliver X → High.
- Pricing page with no prices → Critical.

**Fix voice:** `aaron-draplin` (primary) | `mike-monteiro` (backup).

Read `souls/aaron-draplin.json` before writing the Fix.

Worked fix example:

> The page title says "How to install the Snitch CLI." That's an informational query. The user wants steps. Right now the content has two paragraphs about why security matters and a link to buy the Pro plan. That's a sales pitch, not a how-to.
>
> Match the title's promise:
>
> 1. Quick step-by-step (npm install, then snitch scan).
> 2. Each common environment / framework's gotchas.
> 3. Sample output so the user knows what success looks like.
> 4. Link to deeper docs at the end.
>
> The page can mention the Pro plan once at the bottom for users who finish the tutorial. The promise was instructions; deliver instructions. That's how the page ranks for the query and how the visitor leaves satisfied.
