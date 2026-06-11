## CATEGORY 97: Content decay & refresh audit

Content decays. A post that ranked #1 in 2024 may sit at position 12 by 2026, not because Google penalized it, but because competitors published better, the topic shifted, the data went stale, or AI overviews zero-clicked the query. Content decay is the silent largest source of organic traffic loss for content-heavy sites. The fix is a disciplined refresh-or-prune cadence: identify decaying posts, decide per-post (update / merge / redirect / delete), and ship the change.

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
| **Update** | The topic still matters, the data is stale, the angle is still valid | Refresh stats, add 2026 context, update screenshots, re-publish with new `dateModified` |
| **Merge** | Two or more weak posts cover overlapping ground; one strong consolidated post would be better | Pick the canonical URL, merge content, 301 the others to it |
| **Redirect** | The topic no longer matters but the URL has backlinks | 301 to the closest still-relevant page |
| **Delete** | The topic doesn't matter AND the URL has no value | 410 (gone), better than 404 for crawl signals |

Document each decision per piece in a refresh ledger.

#### Stage 4: Cadence

Refresh isn't a one-time pass, it's a rolling cadence. Audit how often the team reviews content for decay (quarterly is reasonable for high-volume publishers; semi-annually for lower-volume).

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

### What to Search For

- Content files / sitemap entries with `last-modified` >12 months
- Posts with stale year references in title / H1 / first paragraph (`"Best X for 2023"` in 2026)
- Multiple posts on the same topic with no canonical / merge
- Posts with prior backlinks (per `referring_domains` in Ahrefs/Semrush) that have decayed
- Absence of a `redirects.json` / `_redirects` / equivalent, suggests no pruning has happened

### Actually Hurts the Marketing Surface

- **No documented refresh cadence** (no internal record of which posts were last reviewed; no scheduled review process).
  Evidence required: missing process docs, stale `dateModified` distribution.
- **Posts with stale year references in title / H1** (`"Best React Frameworks for 2023"` still ranking + still listed as 2023 in 2026).
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

### NOT a Problem

- Evergreen post (`How to write a resume`) untouched in 24 months and still ranking, the content is genuinely evergreen; updating for the sake of updating may hurt.
- Recently-published posts (<6 months) not yet decaying, too early to triage.
- Pruned content with proper 301 redirects to relevant successors, correct.
- Annually-refreshed posts that include the year in the URL slug (`best-tools-2026/`), common pattern, just ensure year-old slugs are redirected to the current year.

### Context Check

1. Is GSC integration available? Without it, decay detection is approximate.
2. Has the team set up a review cadence? Quarterly review of posts last touched >12 months prior is reasonable.
3. Does the team have writing capacity to refresh, or only to delete? Capacity affects which actions are realistic.
4. Are pruned URLs returning 410 (gone, indexable signal to drop) vs 404 (not found, ambiguous)?
5. Is the refresh ledger versioned somewhere (a markdown doc in the repo, a Notion page, a Google Sheet)? If not, future refreshers can't see what's been done.

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
- Refresh ledger absent → Low (process gap).

**Fix voice:** `frank-chimero` (primary) | `mike-monteiro` (backup).

Read `souls/frank-chimero.json` before writing the Fix.

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
