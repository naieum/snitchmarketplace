## CATEGORY 110: ICP wedge scoring

A site's positioning is downstream of its ICP. Brands stuck on "we're for everyone who needs X" produce homepage copy that lands for nobody. The fix is not "narrow your audience"; it's a scored shortlist of candidate segments, the rigorous decision of which segment to lead with for the next 60 days, and the explicit pivot conditions for when that wedge isn't producing signal.

This category audits the discipline (or absence) around ICP selection. It outputs a scored matrix of 3-6 candidate segments, a primary wedge recommendation with backups, and the pivot conditions that would change the recommendation.

### Pre-flight: relevance check

Skip with reason `not applicable` when the brand has a single, obviously correct audience and serves it directly (a local dentist, a B2B vertical SaaS with a named buyer persona already on the homepage). Run when:

- Homepage copy uses umbrella language ("for professionals", "for developers", "for content creators", "for small businesses") naming 3+ buyer types in one sentence
- Multiple `/for/{audience}` pages exist with no apparent priority order
- The brand sells one product across 4+ visibly distinct buyer profiles
- A founder or marketing lead asks "who should we be for?" in any form

### The framework: 4 dimensions, 1-5 scale

For each candidate segment, score on:

| Dimension | What it measures | Score 5 | Score 1 |
|---|---|---|---|
| **Pain** | Is there a costly, recurring problem the segment will pay to fix? | Daily problem with measurable cost (lost time, lost revenue, physical discomfort, regulatory risk) | Mild annoyance; segment can ignore the problem indefinitely |
| **Reach** | Can a small team find this segment without paid ads or a sales team? | Concentrated in named communities (subreddits, Slack groups, professional associations, conference attendee lists) | Diffuse; only reachable through paid ads or warm intro |
| **Switching cost** | Can they install / sign up / feel value within 5 minutes, no IT approval? | Self-serve, no enterprise gate, no migration | Requires IT approval, data migration, training, or vendor evaluation cycle |
| **WTP fit** | Does the brand's price land at "obvious yes" for them? | Below their existing tool / habit budget; subsidized by employer / health / category norm | At or above pain threshold; requires consideration |

Sum the four columns. Top score is 20. Recommend the highest-scoring segment as the primary wedge, the next two as backups (or one parallel narrow landing page per backup if bandwidth exists). Skip segments scoring below 12 unless one dimension is so high (e.g., Pain = 5 due to compliance) that downstream investment unlocks the segment later.

### The "care a lot" lens (overlay on the matrix)

A segment that genuinely cares about the value the brand offers exhibits all four traits below. The matrix's four dimensions are necessary; this lens is sufficient. Apply it to the top-scoring segments to confirm the wedge before committing.

1. **Frequent and visceral pain** — the segment feels the problem often (daily or near-daily) and cares about it strongly enough to talk about it. Already captured in the Pain dimension; this is just the reminder that infrequent or abstract pain produces lukewarm wedges.
2. **Already attempting to solve** — the segment is currently spending time, money, or attention on the problem. They've bought related tools, read articles, joined communities, complained on social platforms, hired contractors. Existing behavior to redirect is much easier than creating new behavior. A high-Pain segment that has NEVER tried to solve the problem is a demand-creation segment, which is much harder for indie SaaS.
3. **Frame of reference for value** — the segment can compare offerings; they know what good looks like in the category. Without a frame of reference, the buyer can't evaluate the brand's differentiation. Educating buyers from zero is a content-marketing investment that takes 12-24 months minimum.
4. **Has a budget** — financial, time, or attention budget allocated to this category. Financial budget is best (they pay for partial solutions today). Time budget is acceptable (they spend hours weekly on the problem). Attention budget alone is weak (they care, but they won't pay).

A segment with all four is a wedge. Three of four is borderline; investigate which is missing. Two or fewer is not yet a wedge; consider deferring until the missing trait develops, or pick a different segment.

### Re-scoring rule for high-Pain-but-no-prior-art segments

If a segment scores 5 on Pain in the matrix but trait #2 (already attempting to solve) is absent, drop the score by 1-2 points. The buyer doesn't yet recognize the pain as solvable, which means the brand is doing demand creation rather than offering an alternative. Demand creation requires content investment, category education, and patience that indie SaaS rarely has. The "switching" wedge wins faster.

The flag for this case: when STEP 0.7 niche research can't find a community, subreddit, professional association, or competitor's customer base where the segment is already discussing the problem, the segment is a demand-creation segment. Re-score and likely defer.

### Evidence required (do not skip)

**Source mode plus crawl:**

1. Identify candidate segments. Sources:
   - The brand's own homepage / `/for/*` pages (the audiences they currently claim to serve)
   - Customer testimonials on the site (the audiences they actually serve)
   - Niche research from STEP 0.7 (competitor audience claims, gap-audit output)
   - Discovery in STEP 0.5 (business model + audience signal)
2. For each candidate, score 1-5 across the four dimensions. Justify each score with an evidence pointer (a SERP search showing community concentration, a Reddit thread frequency check, a competitor pricing comparison, a customer testimonial quoted, etc.). No score without evidence.
3. Compute totals. Sort. Recommend.
4. Define pivot conditions: at what point does the audit recommend abandoning the wedge?

**Notes:**

- Run before STEP 4.5 (Strategic Recommendations) so the synthesis can inherit the wedge.
- A wedge is a 60-90 day commitment, not a permanent choice. The pivot conditions exist to allow the team to change wedges without sunk-cost loyalty.

### Forbidden claims

- "The brand should target X." Score the candidates first; show your work.
- "X is underserved by competitors." Either the niche research in STEP 0.7 confirms this with a quoted competitor positioning, or the claim is removed.
- Don't recommend a wedge that scores below 12 total unless explaining the exception.

### What to Search For

- Existing audience claims on the site (`/for/`, hero copy)
- Customer testimonials by named role / industry
- Community concentration signals (named subreddits, Slack groups, professional associations, conference lists)
- Reachability signals (paid-only segment vs organically findable)
- Switching-cost signals (auth complexity, data migration burden, IT-approval requirement)
- Price comparison vs the segment's existing budget
- Competitor positioning (does any competitor already target this segment specifically? if yes, what's the differentiation?)

### Actually Hurts the Marketing Surface

- **Homepage names 3+ distinct buyer types in one sentence** ("professionals, content creators, developers, and anyone seeking faster input methods").
  Evidence required: hero copy quoted with the conjoined audience list.
- **No scored ICP analysis on file** (the team picks audiences by pattern-match, not by evidence).
  Evidence required: missing process artifact; informal audience-discussion patterns.
- **Wedge changes every 30 days without pivot rules** (positioning churn).
  Evidence required: hero copy diff history (if available) showing audience changes within 90 days.
- **Underserved high-pain segment ignored in favor of crowded segment** (the team is going where every competitor is, not where the gap is).
  Evidence required: niche research from STEP 0.7 + scored candidate segments showing the brand picked the crowded one.
- **Wedge picked but homepage copy not aligned to it** (the strategy says X, the page says everyone).
  Evidence required: documented wedge + hero copy contradiction.

### NOT a Problem

- Single-audience brand serving one obvious buyer (local dentist, vertical-specific SaaS) without a scored matrix; not needed.
- Multi-audience brand with explicit landing pages per audience AND a named primary wedge (each `/for/*` page has its own targeted hero, the homepage names the primary).
- Brand running an explicit experiment (one wedge for 60 days, measure, decide) is the correct posture; not a finding.

### Context Check

1. How many distinct buyer types does the homepage name? More than 1 = ICP audit applies.
2. Does the brand have customer-discovery data (10+ interviews) confirming the highest-pain segment?
3. Are pivot conditions defined? Without them, the team will sunk-cost a bad wedge.
4. Is the wedge defensible without a sales team / paid ads / enterprise sales motion? Indie SaaS wedges have to be self-serve.
5. Is there a parallel path for the two backup segments (a separate landing page, an audience-specific offer) without diluting the homepage?

### Reference

April Dunford on positioning + ICP selection (Obviously Awesome).
Customer-discovery patterns: see `references/customer-discovery-script.md`.
Niche + competitor research: STEP 0.7 produces the input data.
Strategic synthesis: STEP 4.5 inherits the wedge from this category's output.

**Severity tagging:**

- Homepage names 3+ distinct buyer types in one sentence → High.
- Wedge picked but homepage copy not aligned → Critical (positioning lies to the page).
- No scored ICP analysis on a multi-audience brand → High.
- High-pain underserved segment ignored → High.
- Wedge changing more than once per quarter → Medium.

**Fix voice:** soul slug per `references/voice-mapping.md`.

Worked fix example:

> Stop saying "for everyone who types." It's the same as "for no one." The homepage gets one buyer in mind for the next 60 days, and the copy aligns to that buyer.
>
> Score the candidates rigorously: Pain, Reach, Switching cost, WTP fit, each at 1-5 with evidence per cell. The total surfaces the wedge. The top score becomes the primary; second and third become backups (one as a parallel landing page if bandwidth exists, one as a content / channel angle).
>
> Define the pivot conditions before launching. "After 60 days, if the primary wedge produces less than 20% of paid signups, pivot to the backup that's organically producing more than 30%." The conditions are non-negotiable; they exist to break sunk-cost loyalty. The team that names them up front saves itself a quarter of dithering when the data comes in.
>
> Then ship one homepage that says one thing for one buyer for 60 days. Other buyers can still install. The install flow is the same. But the story on the page is for one person. That's how positioning becomes legible.
