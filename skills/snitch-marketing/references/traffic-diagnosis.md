# Traffic Diagnosis Workflow (on-demand lane, outside the numbered audit flow)

Use this when something happened to traffic and the team needs an answer fast. Distinct from a routine audit — diagnostic, reactive, narrow scope.

## When to use this workflow

- Organic traffic dropped sharply (>20% week-over-week, sustained)
- Organic traffic has been flat for months despite content investment
- Just after a known Google algorithm update, with traffic moving
- Just after a migration, replatform, framework change, redirect deploy
- Just after a deploy that touched routing, rendering, or `<head>` content
- A competitor visibly took share (their content ranks where yours used to)
- A single page dropped from a held-rank position
- A stakeholder needs an answer to "what happened to our traffic?" by EOD

## When NOT to use

- Routine performance reporting (use the analytics dashboard or run Cat 53).
- Pre-emptive content planning (use Cat 70 + Cat 86).
- A backlink-only investigation (use Cat 69).
- A general "audit my site" request (run the full audit instead).

## Required inputs

- Description of the symptom: what changed, when, magnitude.
- The exact date the change started (best estimate).
- Recent SEO history: deploys, migrations, content changes, link campaigns, anything else that touched the site in the last 30 days.
- Access to: Google Search Console, the site's analytics (GA4 / Plausible / Fathom / etc.), the deploy log if available.
- Confirmation that the change is real (not a tracking artifact).

## Forbidden claims (anti-hallucination, diagnosis-flavored)

- "It's probably a Google algorithm update." Confirm via Google's algorithm-update history (Search Status Dashboard, Sistrix, Semrush Sensor) AND via the change's onset date matching a confirmed update window. Don't blame "an update" without dates.
- "It's probably a content quality issue." Quote the affected pages + show the quality signal (thin content, AI tells, mismatched intent) before claiming.
- "Competitors probably took the rankings." Show a SERP screenshot with the competitor in the position the brand used to hold.
- "It's likely a JavaScript hydration regression." Either reproduce the regression in the rendered HTML diff before/after, or don't claim it.

## The framework: 5 stages

Move through in order. Stop when you have enough evidence to point at one root cause + a recovery plan. Don't skip stages — the wrong root cause produces the wrong fix and wastes another month.

### Stage 1: Confirm the change is real

Before diagnosing, rule out tracking artifacts:

- Tracking gaps (analytics outage, broken GA4 install, GTM container error)
- Bot traffic shift (a competitor's bot stopped scraping = appears as traffic loss; an AI training crawler started = appears as traffic gain)
- Date-range comparison errors (comparing last 7d vs prior 7d when the prior 7d included a holiday)
- Seasonality (compare year-over-year, not just period-over-period)
- Day-of-week effects (the change started on a Sunday — was it really a change or just a slow day)

Cross-check Search Console **clicks** against analytics **organic sessions**. Significant divergence (>10%) usually points to a tracking issue, not a real traffic change. If the two diverge, fix the tracking before diagnosing further.

**Stop condition:** if the change isn't real, the diagnosis ends here. Document the tracking issue + how to fix it; close the ticket.

### Stage 2: Localize the change

Where is the change happening? Segment by:

- **Country / language** (one country dropped vs all)
- **Device** (mobile dropped, desktop flat — points to mobile-specific regression)
- **Page or section** (homepage, blog, product, category dropped vs site-wide)
- **Query type** (branded vs non-branded — branded drop = brand-level issue; non-branded drop = algorithmic ranking issue)
- **Landing page** (one specific URL dropped vs many)

| Pattern | Likely cause |
|---|---|
| One country dropped | Local algorithm update, hreflang issue, geo-redirect issue |
| Mobile dropped, desktop flat | Mobile usability or page-speed regression (Core Web Vitals, viewport, render-blocking) |
| One section dropped | Topical algorithm update OR section-specific quality regression |
| Branded queries dropped | Brand-level: site outage, reputation event, manual action, brand SERP feature change |
| Non-branded dropped | Algorithmic ranking issue (broad core update, helpful content update, spam update) |
| Single page dropped | Page-level: content edit, technical regression, competitive pressure on that page |
| Sitewide dropped uniformly | Sitewide: penalty, technical (e.g., robots.txt change), migration regression, algorithm |

Each pattern routes to a different Stage 3.

### Stage 3: Identify the trigger

What event caused this? The 5 most common, in rough probability order:

#### 3a. A deploy

Check the deploy log for changes in the 7 days before the drop began:

- Routing changes (route renamed, removed, redirected)
- `<head>` content changes (canonical, robots meta, hreflang)
- Render changes (added client-only rendering for previously SSR'd content)
- Internal linking changes (navigation restructure removed inbound links to the dropped page)
- Sitemap regeneration (dropped page removed from sitemap)
- Performance regression (bundle size jumped, Core Web Vitals tanked)

Single biggest source of self-inflicted traffic drops. Check the deploy log first.

#### 3b. A Google algorithm update

Cross-reference the drop date with confirmed update history. Start with the curated lookup
in `references/google-updates.md` (which window contains the onset, and what that update
type re-weights), then confirm the exact dates against the primary sources:
- Google Search Status Dashboard: https://status.search.google.com/
- Sistrix Visibility Index updates: https://www.sistrix.com/google-updates/
- Semrush Sensor: https://www.semrush.com/sensor/

If the drop onset matches a confirmed update window, identify the update type:
- **Core update**: broad ranking re-shuffling, often quality + topical authority signals
- **Helpful content update**: content depth + originality + author authority signals
- **Spam update**: link-spam, content-spam (AI slop), thin/duplicate content
- **Reviews update**: review-flavored content quality
- **Product reviews update**: e-commerce review quality

Each routes to different Stage 4 root-cause hypotheses.

#### 3c. A migration / replatform / domain change

Common regressions:
- 301 redirects missed for old URL paths (404 epidemic)
- Redirect chains introduced (Cat 6)
- Canonical changes (Cat 3)
- New domain doesn't have inbound link equity from old domain
- Sitemap not regenerated

#### 3d. A competitor moved

Search the SERP for the queries that dropped. Did a competitor's page enter the top-3 / top-5 positions the brand previously held? If so:
- Read the competitor's page; what's it doing better?
- Check the competitor's domain authority delta (new backlinks, new content depth)
- Did the competitor launch / relaunch around the date?

#### 3e. A site outage / technical regression

- Was the site down for any extended period in the affected window?
- Did robots.txt change to disallow important paths?
- Did `noindex` accidentally ship to important pages?
- Did `X-Robots-Tag: noindex` get added in middleware?
- Did the canonical change to point at a different URL?

### Stage 4: Diagnose root cause

Combine Stage 2 (where) + Stage 3 (trigger) into a specific root cause hypothesis. Then verify with evidence.

Hypothesis format: `<segment> dropped because of <trigger> which caused <mechanism>`.

Examples:

- **"Blog section dropped because of the helpful-content update which deemed AI-generated thin posts low-quality."** Verify: list affected posts, sample for AI tells (Cat 59), thin content (Cat 18), and intent mismatch (Cat 58).
- **"All pages dropped non-branded because of the deploy 3 days prior which added `noindex` to the layout component for staging."** Verify: read the layout file, find the unconditional `noindex`, check git blame for the offending commit.
- **"Mobile dropped sitewide because Core Web Vitals fell out of "good" threshold after a third-party script was added."** Verify: PSI report from before vs after, identify the script, measure its blocking time.
- **"One product page dropped because a competitor relaunched a comparison page and is now ranking #1 with a 4000-word piece + Product schema + 12 customer testimonials."** Verify: SERP screenshot, competitor URL, content comparison.

### Stage 5: Recovery plan + measurement

For each confirmed root cause, define:

1. **The fix.** Specific. Code change, content change, link-building action.
2. **The expected recovery timeline.** Realistic — Google reindexes most fixes in 2-6 weeks; backlink recovery takes months; algorithm-driven drops often don't recover until the next algorithm update reverses the signal.
3. **The measurement.** What to track to know it's working. GSC clicks for the affected segment, position for the affected queries, organic sessions in analytics.
4. **The monitoring cadence.** Daily for the first 2 weeks; weekly thereafter for 90 days.

Document everything in a `TRAFFIC_DIAGNOSIS_REPORT.md` so the team can reference what was diagnosed, what was tried, what worked.

## Output template

```markdown
# Traffic Diagnosis Report — {brand} — {date}

## Symptom

- What changed: {clicks / sessions / impressions, segment}
- Magnitude: {-X% over Y days}
- Onset date: {YYYY-MM-DD}
- Confirmed real (not tracking): {yes/no, evidence}

## Localization

- Segment(s) affected: {country / device / page / query type}
- Pattern matched: {one of the rows in Stage 2's table}

## Trigger identified

- Likely trigger: {deploy / algorithm update / migration / competitor / outage}
- Evidence: {commit hash / update name + date / migration date / SERP screenshot / outage log}

## Root cause

- Hypothesis: {one sentence}
- Verifying evidence: {specific findings + file:line or URL}

## Recovery plan

- Fix(es): {specific action(s)}
- Expected timeline: {weeks-to-months}
- Measurement: {metric, baseline, target}
- Monitoring cadence: {daily / weekly schedule}

## Open questions

- {anything you couldn't conclusively diagnose, with the evidence needed to close it}
```

## Voice for diagnosis output

`solutions-architect` (primary) — read `souls/solutions-architect.json` before writing the report.

The diagnosis output is fundamentally architectural: identifying where the system's behavior diverged from its intended behavior, isolating the cause, defining the rollback or fix. SA's voice for "explicit tradeoffs, reversible decisions, and observable measurement" fits the diagnostic surface.

## Failure modes to avoid

- **Confirming the team's existing hypothesis without checking it.** If the team came in saying "it's the algorithm update" and you go straight to confirming that, you may miss a deploy regression that happened the same week.
- **Stopping at one root cause when there are multiple.** Sometimes traffic drops have stacked causes (a deploy AND an algorithm update in the same week). Check Stage 3 across all 5 trigger types before settling.
- **Recommending a fix without evidence the diagnosis is right.** A fix to the wrong root cause wastes another month and erodes team trust.
- **Promising a recovery timeline you can't deliver.** Algorithm-driven drops often take months and may not fully recover. Honest expectations beat optimistic ones that fail.
