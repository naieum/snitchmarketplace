# Field Core Web Vitals (free CrUX / PageSpeed)

This skill audits the **contributors** to Core Web Vitals from source (render-blocking
resources Cat 40, image weight 43, bundle weight 44, font loading 39, CLS-prevention 28,
lazy-load 29, image format 27, critical CSS 41). What it historically could NOT do is
state the **real field outcome** (the LCP/INP/CLS users actually experience). This
reference adds that, using only free Google data — so a contributor finding can be
corroborated with "and the field p75 confirms it."

This is **optional and gated**: when no key / no field data is available, the audit
degrades to the contributor findings alone and says so. Never block on it.

## Sources (both free)

| Source | Endpoint | Key | Gives |
|---|---|---|---|
| **CrUX API** (field) | `POST https://chromeuxreport.googleapis.com/v1/records:queryRecord?key=KEY` | **required** (free CrUX/PSI key) | 28-day p75 LCP/INP/CLS/FCP/TTFB + FAST/AVERAGE/SLOW distribution |
| **CrUX History API** (field trend) | `POST .../v1/records:queryHistoryRecord?key=KEY` | required | up to **25 weekly** periods (the leading-indicator trend) |
| **PageSpeed Insights v5** (lab + sometimes field) | `GET https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=URL&strategy=mobile` | **optional** (recommended for quota) | Lighthouse lab scores; lab fallback when field is absent |

Get a free key at the Google Cloud console (enable "PageSpeed Insights API" — the same
key works for CrUX). Store it in the env var **`CRUX_API_KEY`** (also accepted:
`GOOGLE_PSI_KEY`). The key is optional: without it, field CWV is skipped with a reason and the
audit reports contributor cats only.

## Invocation (agent runs this in crawl mode)

CrUX field (URL-level; fall back to origin-level on 404):

```sh
curl -s -X POST \
  "https://chromeuxreport.googleapis.com/v1/records:queryRecord?key=$CRUX_API_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"url":"https://example.com/","formFactor":"PHONE"}'
```

25-week trend (the leading indicator): same body against `:queryHistoryRecord`.
Lab fallback when field is missing: PSI `runPagespeed?url=...&strategy=mobile`.

## Parsing gotchas (these cause false findings if missed)

- **CLS p75 is a STRING** (e.g. `"0.05"`), not a number. Cast before comparing.
- **HTTP 404 = "not enough Chrome traffic for this URL," NOT an auth error.** On 404,
  retry at origin level (`{"origin":"https://example.com"}`); if still 404, the site is
  below the CrUX traffic threshold — that's a "no field data" skip, not a finding.
- Field data is a **28-day rolling p75**; it lags. A fix shipped yesterday won't show
  yet. Say "field data reflects the trailing 28 days" so nobody reads a stale number as current.
- Thresholds (Google, p75): **LCP** good ≤2.5s / poor >4.0s · **INP** good ≤200ms / poor >500ms · **CLS** good ≤0.1 / poor >0.25.

## Assessment methodology (changes how findings are verified)

- **Lab to iterate, field to confirm.** Because of the 28-day window above, never declare a
  CWV fix "verified" from field data less than ~28 days post-deploy — iterate on lab numbers,
  then confirm against the field p75 (the History trend shows the turn earliest).
- **The p75 is a pass rule, not an average.** A page passes a metric only when ≥75% of its
  page loads are "good" for that metric. Report the p75 framing ("75% of mobile loads had
  LCP ≤ X"), never averages — an average hides the failing tail that assessment actually
  measures.
- **Mobile and desktop are assessed separately, and mobile is what matters for ranking**
  (mobile-first indexing). Quote mobile numbers (`formFactor: PHONE`, `strategy=mobile`) as
  the finding; desktop is supplementary.
- **CLS is windowed, not truly cumulative**: it reports the worst ~5-second burst of layout
  shifts in the session, not the sum across the whole visit. A single bad late-loading widget
  can own the score.
- **When the shifting element isn't obvious**, a lab filmstrip with layout-shift highlighting
  (0.1s-interval frames, webpagetest-style) localizes the exact element that moved — quote it.

## Severity framing: tiebreaker, not make-or-break

Ranking-wise, CWV acts as a **tiebreaker among similar-quality results** — per Google's John
Mueller, content quality comes first and page experience matters more when multiple results
are otherwise comparable. So never tag a CWV finding as if it decides #1 vs #15. Escalate when
(a) SERP competitors are content-comparable, or (b) conversion is the stated goal — Google's
own data found sites meeting all three thresholds saw users ~24% less likely to abandon page
loads (22% fewer abandonments on news sites, 24% on shopping sites). The conversion case is
usually the stronger business argument than the ranking one.

Sequencing for fixes: page-experience basics first (mobile-friendliness, HTTPS, no intrusive
interstitials), then baseline speed hygiene (hosting, caching, CDN, image discipline), and
only then per-metric CWV micro-optimization.

## How it feeds findings (evidence + leading indicator)

- **Corroborate a contributor finding.** A Cat 40 render-blocking finding gets stronger
  when paired with field evidence: `Evidence: 3 render-blocking <script> in <head> (index.html:12-14); CrUX field LCP p75 = 4.3s (SLOW, mobile, trailing 28d).` Cite both.
- **Supply the leading indicator (A2).** The CrUX **History** p75 trend is the metric the
  user watches to confirm a fix worked without re-running the audit: `Leading indicator: CrUX LCP p75 trend (currently 4.3s, 25-wk history flat); target the FAST bucket (<2.5s) within ~4-8 weeks of shipping the fix.`
- **Don't invent causation.** Field CWV is an *outcome*; the source contributors are the
  *hypotheses*. Report "likely contributors" + "confirm with the field trend after the fix" — not "this script causes your 4.3s LCP."

## LCP decomposition (which subpart to fix)

A slow LCP is one number hiding four subparts. Decomposing it points the fix at the right
contributor cat instead of guessing. The four subparts and where each comes from:

| Subpart | What it is | Source | Routes to |
|---|---|---|---|
| **TTFB** | Time to first byte (server + network) | CrUX field (experimental `experimental_time_to_first_byte`) **and** PSI lab | hosting / CDN / SSR cost — outside the contributor cats; note it |
| **Resource load delay** | Gap between TTFB and the LCP resource starting to load | PSI / Lighthouse lab | Cat 40 render-blocking, Cat 41 critical CSS, late-discovered LCP image (preload) |
| **Resource load duration** | How long the LCP resource takes to download | PSI / Lighthouse lab | Cat 43 image weight, Cat 27 image format, Cat 44 bundle weight |
| **Element render delay** | Gap between resource loaded and pixel painted | PSI / Lighthouse lab | Cat 40 render-blocking JS, hydration cost (Cat 44) |

The subpart breakdown is a **lab** signal (PSI / Lighthouse) — CrUX field supplies the p75
outcome plus a field TTFB to corroborate the TTFB subpart, but it does NOT itself return the
four-way split. Say "lab decomposition" when you cite the split, and pair it with the field p75
as the outcome. The payoff: a finding can say *which* subpart dominates ("LCP 4.3s, ~2.8s of it
is render delay → the fix is the render-blocking bundle, Cat 40, not the image") instead of
listing every CWV contributor at once.

## Graceful degradation (no key / no field data)

1. No `CRUX_API_KEY` → run contributor cats only; note "field CWV not fetched (set `CRUX_API_KEY` to corroborate)."
2. Key present but URL+origin both 404 → "below CrUX traffic threshold; field CWV unavailable for this domain" (a skip, with the contributor findings still standing).
3. Key present, field data present → attach the p75s + history trend to the relevant CWV-contributor findings as corroborating evidence + leading indicator.

Cross-refs: Cat 27/28/29/39/40/41/43/44 (CWV contributors), `references/grader.md`
(leading-indicator element), `SKILL.md` setup (the optional `CRUX_API_KEY`).
