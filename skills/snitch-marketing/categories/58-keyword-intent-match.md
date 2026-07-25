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
- Intent classified from titles or snippets alone. Titles and URLs misrepresent pages — a SERP that reads as all lead-gen landing pages from its titles can actually be won by informational content. Open at least the top 3 ranking pages and classify from what each page actually tries to do (its content intent), not its SERP presentation.

### Detection

Read title + H1 + content. Identify the expected intent for the targeted keyword. Identify mismatch.

Intent types:
- **Informational**: "what is X", "how to X", content should explain
- **Commercial investigation**: "best X", "X review", content should compare
- **Transactional**: "buy X", "X pricing", content should sell
- **Navigational**: brand searches, content should be the brand's home for that thing

### The three C's: type, format, angle

Bucketing intent isn't enough to judge (or write) the page. Decompose the query's top 10 into three concrete content decisions:

- **Content type** — blog post vs product page vs category page vs landing page/tool. Tally the top 10; the majority type is near-mandatory to match.
- **Content format** — how-to, step-by-step tutorial, listicle, opinion piece, comparison; for landing pages: tool, calculator. The majority format is near-mandatory too.
- **Content angle** — the dominant hook in the titles: freshness/current year, thoroughness ("ultimate guide"), for-beginners, price ("cheap"). Angle is where differentiation is allowed; type and format are not.

This turns "match intent" from a judgment into a checklist a page passes or fails: a page whose type or format differs from the SERP majority is an intent mismatch even when the topic matches. The angle tally also reveals the audience — a SERP where beginner "what is X" posts outrank link-heavy advanced guides is the engine saying the searchers are beginners, and the fix for an advanced page is a beginner on-ramp, not more depth.

### SERP features as intent evidence

SERP features are the engine publishing its own read of intent — treat them as classification evidence, not decoration:

| Feature | Reads as |
|---|---|
| Image / video pack | Visual-format informational — a text listicle mismatches the format even when the topic matches |
| Shopping results, ads | Commercial-transactional layer confirmed |
| Local pack | Local intent |
| Knowledge panel | Navigational / entity layer (a query that looks generic may name a real entity) |
| Featured snippet | Informational or commercial-investigation |
| People Also Ask | Sub-intents + audience level ("cheap ways to…" = budget-conscious buyers; "principles of…" = DIY beginners) |

Features are clues to weigh, not verdicts — several can co-exist, and most map to more than one bucket. Record which features appear as part of the intent evidence.

### Fractured SERPs: dominant, common, minor

When one SERP serves multiple intents (a product name that is also a how-to topic and a brand), don't force a single bucket. Rank the interpretations dominant > common > minor by how many top results serve each. Build the page for the dominant intent; fall back to a common intent only when the dominant one is unservable by this site type (e.g., a partially navigational query when the brand isn't that brand); otherwise skip the keyword. Don't burn hours debating secondary buckets — dominant intent is the only classification that must be right, and it's reliably identifiable even when the full classification isn't (in a practitioner exercise, three analysts classifying the same keywords diverged on secondary intents but all picked the same dominant intent).

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
2. What's the typical content shape for that keyword's SERP? (Manually check the SERP — logged out, de-personalized, from the target geography — and open the top 3-5 pages; classify from page content, not titles.)
3. Does the page's content shape match — type and format against the SERP majority, per the three C's?
4. How old is the intent read? SERPs re-shape when the world changes, so a page that matched intent at publish can silently stop matching — nothing on the page broke; the SERP moved. For traffic-drop diagnosis: re-inspect today's SERP and diff its majority type/format/angle against the page; a SERP that changed shape is the finding. Intent classifications carry a freshness date — schedule periodic re-checks on money keywords.

### Reference

Google on understanding search intent: https://developers.google.com/search/docs/fundamentals/seo-starter-guide

**Severity tagging:**
- Title/content intent mismatch on commercial keyword → High.
- Title promises X, content doesn't deliver X → High.
- Pricing page with no prices → Critical.
- Page's content type or format differs from the SERP-majority type/format → High.

**Fix voice:** `aaron-draplin` (primary) | `mike-monteiro` (backup).

Read `souls/aaron-draplin.json` before writing the Fix.

Worked fix example:

> The page title says "How to install the Snitch security skill." That's an informational query. The user wants steps. Right now the content has two paragraphs about why security matters and a link to the other two skills. That's a cross-sell, not a how-to.
>
> Match the title's promise:
>
> 1. Quick step-by-step (run the installer, then ask your agent for an audit).
> 2. Each common environment / framework's gotchas.
> 3. Sample output so the user knows what success looks like.
> 4. Link to deeper docs at the end.
>
> The page can point to the other skills once at the bottom for users who finish the tutorial. The promise was instructions; deliver instructions. That's how the page ranks for the query and how the visitor leaves satisfied.
