## CATEGORY 97: Content decay & refresh audit

Content decays. A post that ranked #1 two years ago may sit at position 12 today, not because Google penalized it, but because competitors published better, the topic shifted, the data went stale, or AI overviews zero-clicked the query. Content decay is the silent largest source of organic traffic loss for content-heavy sites. The fix is a disciplined refresh-or-prune cadence: identify decaying posts, decide per-post (update / merge / redirect / delete), and ship the change.

This category audits the discipline (or absence of one) around content decay.

### Pre-flight: relevance check

Skip with reason `not applicable` if the site has fewer than 30 published posts/articles OR all content is <12 months old (decay hasn't had time to set in). Otherwise: required.

### The framework: 4 stages

Move through in order.

#### Stage 1: Inventory

Assemble the catalog of all published content with publish date + last-modified date + topic + author. From source mode: `Glob` MDX/MD files, parse frontmatter, sort by date. From crawl mode: parse the sitemap + each URL's `<time>` / publish-date markup.

#### Stage 2: Performance overlay

For each piece, attach performance signal from the highest-confidence source available:

- **GSC clicks/impressions/position** for the URL, best signal.
- **GA4 organic sessions** for the URL, second-best.
- **Internal link count** as a proxy when GSC absent, weak signal.
- Without any of these, the audit is partial, flag explicitly.

Compute decay: clicks/sessions in last 90 days vs prior 90 days, and vs 365 days ago. A piece that earned 100 sessions/month a year ago and earns 12 today is decaying.

#### Stage 3: Per-post triage

For each decaying piece, decide one of four actions:

| Action | When | What it looks like |
|---|---|---|
| **Update** | The topic still matters, the data is stale, the angle is still valid | Refresh stats, add current-year context, update screenshots, re-publish with new `dateModified` |
| **Merge** | Two or more weak posts cover overlapping ground; one strong consolidated post would be better | Pick the canonical URL, merge content, 301 the others to it |
| **Redirect** | The topic no longer matters but the URL has backlinks | 301 to the closest still-relevant page |
| **Delete** | The topic doesn't matter AND the URL has no value | 410 (gone), better than 404 for crawl signals |

**Four gates before Update.** Refresh a page only when all four hold; a failed gate reroutes the piece to a different action:

1. **Age**: the page has had 6-12 months to rank since publish or last major update. Younger pages are still climbing; too early to call decay.
2. **Meaningful target**: the topic has real traffic potential. Estimate it from the current top-ranking pages' total organic traffic, not a single keyword's volume — a page ranks for many queries (Cat 86 Stage 4).
3. **Not already top 3**: a full rewrite of a top-3 page risks losing the ranking it holds; minor updates only. Find candidates by filtering to average position ≥4 (GSC position filter, or any rank source with current positions).
4. **Content, not links, is the bottleneck**: compare the page's referring domains and site authority against the top 10. Competitive on links but outranked by link-weaker pages = a content/intent problem a refresh can move — position 7 → 2-3 is a realistic goal even when #1 is link-untouchable. A page that never had referring domains fails this gate: a refresh won't recover it; route to link building or Merge instead.

Gate 4 doubles as the sleeper-page filter: pages that once ranked, have declined, and retain a meaningful referring-domain count already have the authority — they lack only freshness, which makes them the fastest refresh wins for organic rankings and AI-assistant citations alike (see the freshness note under Stage 4).

Program prerequisite: republishing assumes basic technical health and some site authority; it does nothing for a link-less new site. When the gates hold, the upside is real and fast — one content team reported having republished 61 of its 250 posts at least once, with nearly all showing sustained traffic growth and several showing immediate post-republish spikes (practitioner-reported).

Document each decision per piece in a refresh ledger.

#### Stage 4: Cadence

Refresh isn't a one-time pass, it's a rolling cadence. Audit how often the team reviews content for decay (quarterly is reasonable for high-volume publishers; semi-annually for lower-volume).

The cadence case is stronger now than classic decay alone: freshness is a retrieval gate for AI assistants, not just a ranking signal. A large-scale industry study of ~17M citations across 7 AI platforms found AI-cited content 25.7% fresher than what ranks in the traditional SERP (correlational); on one major assistant, roughly 90% of top-cited pages had been updated within the current year and 76% within the last 30 days, and two major assistants tend to order citations newest-first. The mechanism fits: retrieval fires when training data can't answer, so it inherently favors recent documents. Consequences: on moving topics, content untouched ~6 months is already disadvantaged for AI citations, and the winning shape is an old URL with recently-updated content — the URL keeps its accumulated corpus weight, the content carries the freshness. A brand-new URL lacks the weight; an old URL with stale content loses the retrieval. Cross-reference Cat 82.

Freshness is query-dependent, though: if the top-ranking titles carry the current year or the SERP shows recent dates, the query is freshness-sensitive and the page needs periodic republishing; a stable evergreen SERP ("how to tie a tie") doesn't reward updating for its own sake.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` content files (`**/*.mdx`, `**/*.md`, `content/**/*`, `posts/**/*`). Quote total count + date range.
2. Parse frontmatter for each: `date` / `publishedAt` + `updatedAt` / `dateModified`. Compute distribution of last-modified dates: how many posts haven't been touched in >12 months / >24 months?
3. If GSC export is available, cross-reference with declining queries.
4. Check for a `redirects.json` / `_redirects` / Cloudflare-rules file showing previously-pruned content.

**Crawl mode, required tool calls:**

1. Fetch the sitemap. Quote total content URL count + age distribution if dates available.
2. Sample 10-20 older posts. Check for last-modified date markup. Note any posts with stale year references in the title or first paragraph.
3. Search 5-10 known query targets. Quote where the brand's content ranks now vs where it should.

### Forbidden claims

- "Most posts are probably stale." Compute the last-modified distribution.
- "Traffic is probably declining on old posts." Quote GSC data or note the audit is partial.
- "These posts should probably be deleted." Per-post triage with evidence per action.
- "A refresh will recover this traffic." Only if content is the bottleneck (gate 4): a page that never had referring domains needs links or a merge, not a rewrite.

### Detection

Content inventory by publish and last-modified date, then a per-URL decay read against whatever performance signal is available.

### What to Search For

- Content files / sitemap entries with `last-modified` >12 months
- Posts with stale year references in title / H1 / first paragraph (a `"Best X for <year>"` title two or more years behind the current year)
- Multiple posts on the same topic with no canonical / merge
- Posts with prior backlinks (per `referring_domains` in Ahrefs/Semrush) that have decayed
- Absence of a `redirects.json` / `_redirects` / equivalent, suggests no pruning has happened
- Decayed posts that retain a meaningful referring-domain count (sleeper pages) — the highest-leverage refresh candidates

### Backlink-reason preservation + republish mechanics

Before rewriting any page that has backlinks, find out WHY people linked to it — often one specific statistic, chart, or claim. Pull the page's backlinks with anchor + surrounding text, search for repeated phrases and numbers, and keep anything cited by multiple linking pages in the rewrite (refreshed if the data went stale) so the existing links stay contextually valid and the element keeps earning new ones. In one documented case, ~60 unique pages linked to a single guide because of one statistic; a rewrite deleting that stat would have orphaned the anchor context of all 60 links. Preservation isn't hoarding — elements that are outdated or off-topic go.

Republish mechanics after a substantive update: change the modification date only for real content changes (a date bump on an untouched page is freshness-faking — detectable, ineffective, and it pairs with the sitemap lastmod-honesty rules elsewhere in this skill), then request re-indexing (GSC → URL inspection → request indexing). Recrawl is typically near-immediate; waiting for a natural recrawl has the same effect, slower.

### Actually Hurts the Marketing Surface

- **No documented refresh cadence** (no internal record of which posts were last reviewed; no scheduled review process).
  Evidence required: missing process docs, stale `dateModified` distribution.
- **Posts with stale year references in title / H1** (a `"Best React Frameworks for <year>"` post still ranking while its title names a year two or more behind).
  Evidence required: quoted title + current year.
- **Posts on the same topic competing for the same query** (cannibalization).
  Evidence required: 2+ URLs + the shared query they target.
- **Long-form posts (1500+ words) untouched in 24+ months on competitive topics** (the topic moved; the post hasn't).
  Evidence required: post URL + last-modified date + competitive topic.
- **Pruned content returning 404 instead of 410 / redirect** (lost backlinks; lost crawl signal).
  Evidence required: 404 URL + prior backlink evidence (if available).
- **Decaying posts identified but no triage decision** (the team knows the post is decaying but hasn't decided update / merge / redirect / delete).
  Evidence required: decay signal + missing decision record.
- **Refresh ledger absent** (no record of what was changed when).
  Evidence required: missing ledger file/doc.
- **Sleeper pages ignored** (significant traffic decline + meaningful referring-domain count, no refresh scheduled).
  Evidence required: decline data + referring-domain count + the absence of a triage decision.
- **Rewrite that removes the elements external links point to** (the stat/chart/claim multiple linking pages cite).
  Evidence required: the linked-to element + backlink anchors/context citing it + the rewrite dropping it.
- **Full rewrite of a page ranking top 3** (risking the ranking a minor update would have kept).
  Evidence required: pre-rewrite position + the rewrite's scope.
- **Refresh chosen for a page whose bottleneck is links** (never had referring domains; content was not the problem).
  Evidence required: the page's referring-domain count vs the top 10 + the update-only decision.
- **Modification dates bumped without substantive changes** (freshness-faking).
  Evidence required: date diff + content diff showing no meaningful change.

### NOT a Problem

- Evergreen post (`How to write a resume`) untouched in 24 months and still ranking, the content is genuinely evergreen; updating for the sake of updating may hurt.
- Recently-published posts (<6 months) not yet decaying, too early to triage.
- Pruned content with proper 301 redirects to relevant successors, correct.
- Annually-refreshed posts that include the year in the URL slug (`best-tools-<year>/`), common pattern, just ensure year-old slugs are redirected to the current year.

### Context Check

1. Is GSC integration available? Without it, decay detection is approximate.
2. Has the team set up a review cadence? Quarterly review of posts last touched >12 months prior is reasonable.
3. Does the team have writing capacity to refresh, or only to delete? Capacity affects which actions are realistic.
4. Are pruned URLs returning 410 (gone, indexable signal to drop) vs 404 (not found, ambiguous)?
5. Is the refresh ledger versioned somewhere (a markdown doc in the repo, a Notion page, a Google Sheet)? If not, future refreshers can't see what's been done.
6. Is backlink data available (referring domains per URL)? Without it, gate 4 and sleeper-page selection are approximate — flag those calls as partial.

### Reference

Google's Helpful Content System (decay-aware ranking): https://developers.google.com/search/blog/2022/08/helpful-content-update

Animalz's content decay framework: https://www.animalz.co/blog/content-decay/

**Severity tagging:**
- No documented refresh cadence → High.
- Posts with stale year in title still ranking → High.
- Topic cannibalization with no canonical / merge → High.
- Long-form competitive posts untouched 24+ months → Medium.
- Pruned content returning 404 instead of 410 / redirect → Medium.
- Decay identified but no triage → Medium.
- Sleeper page (decayed + retained referring domains) with no refresh scheduled → High.
- Rewrite removing the elements external links cite → High.
- Full rewrite of a top-3 page → Medium.
- Refresh applied where links are the bottleneck → Medium.
- Modification dates bumped without substantive change → Medium.
- Refresh ledger absent → Low (process gap).

**Fix voice:** `content-shape-editor` (primary) | `honest-design-critic` (backup).

Read `souls/content-shape-editor.json` before writing the Fix.

Worked fix example:

> Content decays the way buildings decay, slowly, then all at once. The discipline isn't to write more; it's to look at what was written, decide what still matters, and shape the rest into something useful or honestly retire it.
>
> Three things to put in place.
>
> **A refresh ledger.** A simple markdown table per quarter listing every post reviewed, its decay signal, and the decision made. Update / merge / redirect / delete, with a one-line reason each. The ledger is the team's memory; without it, refreshers six months from now will redo the same triage.
>
> **A quarterly cadence.** Pick a window each quarter (one week is enough). Pull GSC data for last 90 days vs prior 90. Sort by clicks-lost. Triage the top 20-30 declining posts. Ship the decisions.
>
> **A pruning convention.** When a post is deleted, return 410 (gone), clearer signal to Google than 404. When a post is merged, 301 to the canonical successor. When a post is updated, change `dateModified` (not `datePublished`) and re-cross-post the refreshed version to the same distribution surfaces it originally ran on.
>
> The best content strategy isn't writing the next post. It's making sure the posts that already exist still earn their place.
