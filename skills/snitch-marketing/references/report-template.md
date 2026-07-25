# Report Template

Use this exact structure for the `SEO_AUDIT_REPORT.md` output. Fill in the variable parts in `{braces}`.

**Output path:** the report lands at `{working_directory}/snitchfindings/{target_slug}/SEO_AUDIT_REPORT.md` per `snitch-marketing.config.md`'s `report-output` setting. The `{target_slug}` is derived from the audited project (source mode) or domain (crawl mode). All audit outputs (this report, Strategic Recommendations, Cat 96 SERP addendum, JSON / CSV / HTML exports) land in the same per-target subfolder.

The structure is symmetric. "What needs work" and "What's working" get the same evidence rigor and the same depth. Don't open with praise; don't bury Critical findings under wins.

---

```markdown
# SEO Audit Report, {project_name OR domain}

> Audited by Snitch: Marketing on {date_iso}.
> Mode: {source / crawl / both}.
> Stack detected: {stack_name and version if known}.
> Categories scanned: {N} of {total_in_catalog}. Selection: {preset_name OR "Custom"}.
> Target: {working_directory_path OR url}.

## Executive snapshot

**The bottleneck:** {one sentence naming the load-bearing problem; e.g., "4 of 9 sitemap-listed URLs return the same soft-404 page while the homepage tells a story for nobody specific."}

**The fix:** {one sentence naming the highest-leverage move; e.g., "Fix the dead experiments and pick a wedge to rewrite the homepage hero around."}

**This week:** {one sentence with a concrete action and target completion; e.g., "Decide whether /community, /marketplace, /skins, /collection get revived or retired; ship a real 404 or real page for each by Friday."}

**Top 3 findings (read these first):**

1. {Finding ID + tier + one-line summary, e.g., "Finding 1, Critical, Cat 5: 4 of 9 sitemap-listed URLs return identical soft-404 placeholder content."}
2. {Finding ID + tier + one-line summary}
3. {Finding ID + tier + one-line summary}

**Read the rest of this report if:** you're triaging which fix to ship first ("What needs work" section), confirming what's already configured well ("What's working" section), or executing the recommendations (Recommendations section). The full report has the file:line / URL+selector evidence per finding.

---

## Severity counts

| Tier | Count |
|---|---|
| Critical | {N} |
| High | {N} |
| Medium | {N} |
| Low | {N} |
| Passing | {N} |
| Skipped | {N} |
| Total scanned | {N} |

## Comparison to previous audit

**INCLUSION RULE:** Only include this entire `## Comparison to previous audit` section if a previous `SEO_AUDIT_REPORT.md` exists in the same `snitchfindings/{target_slug}/` directory at audit start. If there is no previous report, OMIT THIS SECTION ENTIRELY (do not include the heading, the table, or any "no previous audit" placeholder).

When a previous audit exists, the section looks like:

| Metric | Previous | Current | Delta |
|---|---|---|---|
| Total findings | {prev} | {curr} | {+/-} |
| Critical | {prev} | {curr} | {+/-} |
| High | {prev} | {curr} | {+/-} |
| Resolved since previous | {N} | | |
| New since previous | {N} | | |

## GEO readiness score

**INCLUSION RULE:** Only include this entire `## GEO readiness score` section if Cat 82 (AI-search citation), Cat 102 (multi-LLM), or Cat 106 (llms.txt) were in scope for this scan. If none ran, OMIT THIS SECTION ENTIRELY (no heading, no placeholder). Mirrors the gating of `## Comparison to previous audit` and the field-CWV block. Methodology + the deduction model live in `references/geo-score.md`.

When in scope, the section shows the score with its full derivation (the reader must be able to add the deductions and reach the total):

GEO readiness: **{score}/100**

| Finding | Severity | Deduction |
|---|---|---|
| (start) | | 100 |
| {GEO finding title} | {Critical/High/Medium/Low} | {-20/-10/-5/-2} |
| ... | | ... |
| **Total** | | **{score}** |

Only GEO-surface findings feed the score (crawler access, llms.txt, citability/answer-fitness, extractability+schema, brand authority, multi-LLM). Never show the number without this itemized derivation — an unexplained score is the vanity metric this skill avoids.

## What needs work

{Group findings by SEO Impact: Critical first, then High, then Medium, then Low. Within each impact level, group by category number. Use the Finding Format from SKILL.md. Each finding has its own evidence block with file:line or URL+selector. No editorializing.}

### Critical

#### Finding 1: {short title}
{full Finding Format block}

#### Finding 2: {short title}
{...}

### High
{...}

### Medium
{...}

### Low
{...}

## What's working

{Every category that ran and produced no findings is listed here. Same depth as findings: each entry has the cat number, the cat name, and one line of factual evidence proving the check ran. No evaluative adjectives. No "best-in-class" or "textbook". State what is configured and where; the reader judges quality.}

- **Cat 3, Canonical URL**: declared on `src/routes/blog.tsx:18` as `links: [{ rel: 'canonical', href: ... }]`. Pattern repeats across all 14 indexable routes (verified via grep).
- **Cat 9, Title tag**: each of 14 routes sets a unique `<title>` via the framework's `head()` function (verified per route file).
- **Cat 31, JSON-LD presence**: homepage, blog-post, pricing, and docs all emit `application/ld+json` blocks (verified in respective route files).

## Needs review (low confidence)

{Findings the audit flagged but couldn't fully verify. Same Finding Format. The user can decide whether to treat as confirmed.}

## Coverage

Required in every report. The denominator behind every negative claim in the audit.

```markdown
## Coverage

| Surface | Discovered | Checked | Completeness |
|---|---|---|---|
| Sitemap URLs | 412 | 50 | partial — `crawl-max-pages: 50` |
| Route files (source mode) | 38 | 38 | complete |
| Off-site surfaces | 6 | 6 | complete |

**Crawl-bound categories:** 9 (title), 10 (meta description), 19 (internal links), 20 (broken links)
were computed over the 50 URLs fetched, not all 412 discovered. Their negative results read
"none found in the 50 URLs fetched" — not "none". Raise `crawl-max-pages` in
`snitch-marketing.config.md` to widen the denominator.

**Deferred:** <surface> — <reason>
```

Rules:
- Completeness is `complete` only when checked == discovered. A sampled or capped surface is
  `partial`, never `complete`.
- Every deferral is listed with its reason. A surface that was never reached and never mentioned is
  the failure this section exists to prevent.
- If nothing was capped or deferred, say so in one line — an explicit "complete, 38/38 routes" is
  more useful than an absent section.

## Skipped categories

{Categories selected but not run, with reason. State the evidence that produced the skip.}

- **Cat 38, VideoObject schema**: skipped, no `<video>` tags or third-party video embeds found on audited pages (verified via grep).
- **Cat 50, Hreflang correctness**: skipped, single-locale site (no `<link rel="alternate" hreflang>` patterns and no internationalization signals in framework config).

## Suppressed

{Findings that matched the patterns but were silenced by `.snitch-marketing-ignore` or inline `<!-- snitch-marketing-ignore -->` comments. Include path:line+CAT for each.}

- `src/routes/legacy.tsx:14` (Cat 9: Title tag), suppressed by inline comment
- `src/routes/dashboard/$.tsx:8` (Cat 4: Indexability), suppressed by `.snitch-marketing-ignore`

## Audit metadata

```yaml
audit_mode_detected: {source/crawl/both}
stack_detected: {stack name + version}
components_detected: [homepage, /pricing, /docs, /faq, ...]   # output of STEP 0.8
categories_scanned: [1, 2, 3, 9, 10, 11, 15, 25, 31]
target: {working_directory OR URL}
duration_seconds: {N}
provider: {AI provider used for this audit, e.g. "claude-sonnet-4-6"}
images_enumerated: {N}                                          # required for Cat 25 if a Pass / Finding outcome
images_sampled: {K of N}                                        # alternative to enumerated; pairs with Skip outcome
routes_enumerated: {N}                                          # for sitemap / link-graph / cross-route categories
voice_reads_completed: [internal_only]                          # tracked internally for verification; do not surface in user-visible output
```

The `voice_reads_completed` array is INTERNAL. Track every soul slug whose voice informed any Fix during this audit. Do not display this array in the visible report; it lives in the metadata block as a verification mechanism only. The audit's output never names a practitioner.

---

Audited by Snitch: Marketing
Get the latest version: https://snitchplugin.com/marketing
```

## Concrete copy drafts (required when applicable)

When a Critical or High finding is about hero copy, CTA wording, FAQ structure, or any user-visible language, the report must include CONCRETE COPY DRAFTS, not just a diagnosis. The customer's question after reading the finding is "what should it say instead?", and a finding without an answer to that question is incomplete.

The drafts go in the Fix block of the relevant finding, formatted as fenced text:

```
Current copy: {quoted from source}

Draft A (pain-led):
{actual replacement copy, headline + subhead + CTA + microcopy}

Draft B (substitute attack):
{actual replacement copy}

Draft C (quiet confidence):
{actual replacement copy}

Recommended start: {pick one, with one-sentence reasoning}
```

When multiple drafts make sense (positioning is genuinely a tradeoff), provide three. When only one direction fits the brand's stage and constraints, provide one and say so explicitly. Pull the structural patterns from `references/copy-bank-templates.md`, and follow `references/remediation-generator.md` for the full audit→fix workflow: ground every draft in `.snitch-marketing-context.md` (ICP, objections, Four Forces, verbatim customer language), generate non-copy fixes too (JSON-LD, llms.txt, meta), and run generated copy through the AI-boilerplate + report-lint pass before emitting.

This applies to: hero rewrites (Cat 81), FAQ rewrites (Cat 35 + Cat 81), CTA rewrites (Cat 60), trust-strip rewrites (Cat 111), comparison-page positioning sentences (Cat 95 + Cat 81), email subject-line rewrites (Cat 62).

## Verification / leading indicator (required on Critical + High findings)

Every Critical and High finding carries one extra line: **how the user confirms the
fix worked (or that the finding was wrong) without re-running the whole audit.** This
is the falsifiability discipline: no invisible bets. It names a single observable
metric and a rough time-to-signal, not a promise of ranking.

Format (one line in the Fix block, after the action):

```
Verify: { observable signal + where to watch it + rough time-to-signal }
```

Examples:
- Cat 5 (soft-404): `Verify: the bad URL returns 404/410 (curl -I) immediately; Search Console "soft 404" count trends to 0 over ~2-4 weeks.`
- Cat 40/43 (CWV contributor): `Verify: CrUX field LCP p75 trend (references/field-cwv.md) moves toward the FAST bucket (<2.5s) within ~4-8 weeks; Lighthouse lab LCP drops immediately.`
- Cat 60 (CTA rewrite): `Verify: A/B the new CTA; watch click-through on the primary button. The lift is a hypothesis until the test reads (Cat 73), so ship it as a test.`
- Cat 9 (title rewrite): `Verify: Search Console impressions/CTR for the target query over ~2-4 weeks; the title renders as written in the SERP.`

Rules: name a metric the user can actually see; never claim a specific ranking gain
("Verify: you'll hit #1"); for conversion/persuasion findings the verification IS an
A/B test (the lift is unprovable from inspection, per Cat 73 / Cat 114). Medium and
Low findings may include a Verify line but are not required to.

## Closing summary (required at end of STRATEGIC_RECOMMENDATIONS.md)

Every Strategic Recommendations document closes with a single paragraph titled "The single most important thing." If the customer reads only one paragraph of the entire deliverable, this is the one.

The paragraph names: the bottleneck (in one sentence), the highest-leverage move that addresses it (in one sentence), the action the customer takes this week (in one sentence). No qualifications, no "depending on..." Distilled to the load-bearing point.

Format:

```markdown
## The single most important thing

The bottleneck is {one specific reason, e.g., "the homepage tells a story for nobody, and there's no proof the product is real"}. The highest-leverage move is {one specific action, e.g., "pick the wedge in §3, rewrite the hero around it, and put the founder's face on the homepage"}. This week, do {one concrete action with a target completion date, e.g., "ship the wedge-aligned hero by Friday and email 10 customers asking 'why'd you stick with it' or 'why'd you stop'."}.
```

The closing paragraph is the answer to "if I do nothing else, what should I do?". Customer should be able to act on it without re-reading the rest of the document.

## Voice rules for the report

- Plain and factual. The CLAUDE.md voice rules apply: no em dashes (use commas, semicolons, colons, parens), customer-first.
- No designer / practitioner names anywhere in user-visible output. The voice mechanism is internal; the prose carries authority on its own.
- No sycophantic adjectives. Forbidden: "best", "best-in-class", "excellent", "great", "amazing", "world-class", "textbook", "textbook-correct", "comprehensive", "strong foundation", "well-architected", "thoughtful", "reference example".
- "What's working" is symmetric to "What needs work". Same depth. Same evidence rigor. Same factual tone.
- Findings should answer "what does this cost me" before "what's the technical issue". Quantify where possible: "average loss in test corpus: 1-2 ranking positions" beats "may impact rankings".
- Never claim "you'll rank #1 if you fix this." Say what's likely: "Eligible for rich-result rendering after fix."
- Use file:line for source mode evidence. Use URL + CSS selector for crawl mode. Never mix.
- Quote real code / HTML in fenced blocks. Tracking IDs / customer data redacted to X's per Rule 5.

## Failure modes to never produce

- A report with zero findings AND zero passing checks (means the audit didn't run; show why in the metadata block instead).
- "I scanned X pages and found 47 SEO opportunities", vague summary claim, violates anti-hallucination Rule 2.
- Findings with no evidence, violates Rule 1.
- Auto-fixed code in the report, violates Rule 9.
- Editorializing adjectives in pass-evidence ("textbook-correct font setup", "best-in-class llms.txt"), violates Rule 10.
- Naming a practitioner in any user-visible passage, violates the no-designer-names rule in VOICED REMEDIATIONS.
- "Bonus observation" sections that re-praise a passing check already in the "What's working" list. If a passing check is unusual, describe what it does in detail; don't separate it into a praise section.
- Opening preambles ("Atlas has a strong foundation but..."). The report opens with severity counts and gets straight to findings.
