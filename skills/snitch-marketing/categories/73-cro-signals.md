## CATEGORY 73: CRO (conversion-rate optimization) signals

Is the team measuring funnel performance, running A/B tests **with statistical rigor**, gathering qualitative data (heatmaps, session recordings, surveys), prioritizing tests, and iterating? Cat 60 covers point-in-time conversion *design*; Cat 99 covers the funnel *journey*; Cat 53 covers *event taxonomy*; Cat 74 covers *voice-of-customer / social proof*. This category covers the team's CRO **discipline**.

Two layers are assessable, and they have different evidence rules — do not conflate them:

- **(A) Tooling & measurement integrity** — source/crawl-detectable. What's installed, whether it's stacked/legacy, whether it harms performance (anti-flicker), whether consent biases the data. Assert these from `file:line` or rendered-DOM evidence.
- **(B) Experimentation rigor** — process discipline (sample sizing, peeking, SRM, guardrails, hypotheses, prioritization, shipping). This is **NOT visible in source**; it's assessable only from a shared test archive / planning doc / dashboard / interview. When that evidence isn't available, these become Context Check questions, **never asserted findings** (see Forbidden claims).

### Pre-flight: traffic + tooling check

If the site has <100 visitors/day (estimable from analytics if accessible, or assumed for new domains <90d old per STEP 0.6), CRO is premature — A/B tests can't reach statistical significance. **Skip** with reason `traffic too low for meaningful CRO; revisit after sustained 100+ daily visitors, see STEP 4 recommendations`. Don't run Evidence Required. (Layer-A tooling-integrity findings like a leftover anti-flicker snippet still apply even on low traffic, because they tax performance regardless.)

### Evidence required (do not skip, only when traffic is meaningful)

**Source mode, required tool calls:**

1. `Grep` for experiment / feature-flag / personalization tools (see What to Search For for signatures): Optimizely, VWO, AB Tasty, Kameleoon, Convert, GrowthBook, Statsig, LaunchDarkly, Eppo, Mutiny, Dynamic Yield, Intellimize / Webflow Optimize, Unbounce / Instapage, and **Google Optimize (sunset 2023-09-30 — a live install is itself a finding)**.
2. `Grep` for **anti-flicker / page-hiding snippets** (the highest-value source-detectable signal — see What to Search For). These hide the page until a client-side test mutates the DOM and directly delay LCP.
3. `Grep` for session-replay / heatmap tools: Hotjar, Microsoft Clarity, FullStory, LogRocket, Contentsquare, Smartlook, PostHog replay, Mouseflow.
4. `Grep` for on-site survey / VoC tools: Hotjar surveys, Sprig (legacy alias `UserLeap`), Qualaroo, Survicate, Typeform embeds, Refiner.
5. `Grep` for consent CMP + Consent Mode (gating that biases CRO data): OneTrust/Optanon, Cookiebot, Osano, `gtag('consent', ...)`. Presence or absence is what this category needs; whether the consent wiring is correct is not audited here — call the Skill tool with "snitch-adsready".
6. `Grep` for funnel-event tracking (cross-reference Cat 53): per-step signup/checkout events, drop-off measurement.
7. `Grep` for the healthy modern substrate: GA4 (`G-`) + signs of warehouse export / server-side assignment (see NOT a Problem — absence of a client tester is not automatically a gap).
8. `Read` analytics setup for funnel definitions / dashboard names.

**Crawl mode, required tool calls:**

1. Inspect the **rendered** DOM + network: anti-flicker style nodes (`#_vis_opt_path_hides`, `.async-hide`, `#at-body-style`, inline `body{opacity:0}`), variant attributes (`data-experiment`, `data-variant`), and outbound request hosts. Many tools are injected via GTM, so static grep under-reports — corroborate with a rendered crawl.
2. Count **stacked** tools: ≥2 client-side testers, or ≥2 session-replay tools, firing on the same page.
3. Check **consent order**: does any replay/experiment tag fire *before* consent? (legal/privacy risk), or is the experiment tool gated *behind* consent on a low-traffic site? (biased, under-powered sample).

**Process / team-evidence mode (Layer B — only when a test archive, planning doc, experiment dashboard, or interview answer is shared):**

Look for: a pre-launch **sample-size / MDE** calc per test; a predetermined **duration** (whole business cycles); a **peeking** policy (or a sequential/always-valid/Bayesian method that licenses early stops); an automatic **SRM** (sample-ratio-mismatch) check; a **single primary metric** + correction when many metrics/segments are scanned; declared **guardrail metrics / OEC**; structured **hypotheses**; a **prioritization framework** (ICE/PIE/PXL/RICE); ship-winners/kill-losers + a **learning repository** + **holdout** groups; a realistic **win rate**.

**Trigger (when the rigor checklist fires).** When Layer A detects an experiment tool installed *and* traffic is meaningful, the team is running experiments — so surface this rigor checklist **proactively as Context Check questions / recommendations (items 2–10)** even with no archive shared: the detected tooling is the evidence that warrants asking. Asking is not asserting — **escalate a question to a graded Layer-B finding only when the shared archive/doc actually shows the failure** (do not claim it otherwise). When no experiment tool is detected, the rigor checklist is premature; the relevant finding is the Layer-A "no experimentation infrastructure" item instead.

### Forbidden claims

- "The team probably doesn't run A/B tests." `Grep` and show what's installed or absent.
- "CRO discipline may be lacking." Show specific evidence.
- "They're probably peeking / stopping tests early." Peeking is **not source-detectable** — only claim it from a shared test log showing an early stop without a sequential method. Otherwise make it a Context Check question.
- "Their win rate is too high, so they're p-hacking." Only from the actual archive; otherwise ask.
- "Tests are underpowered." Requires the sample-size/MDE evidence; otherwise ask.
- Calling a **server-side / warehouse-native** setup "no CRO tooling" because nothing shows in client HTML — verify before claiming absence (see NOT a Problem).

### Detection

Source/crawl-detectable tooling + measurement integrity (Layer A); process discipline only from shared team evidence (Layer B).

### What to Search For

**Experiment / flag / personalization tools:**
- `cdn.optimizely.com`, `window.optimizely`
- `_vwo_code`, `window.VWO`, `_vis_opt_path_hides`
- `try.abtasty.com`, `window.ABTasty`
- `kameleoon`, `convertexperiments.com`, `window._conv_q`
- `cdn.growthbook.io`, `@statsig/js-client`, `launchdarkly` / `LDClient`
- `mutinycdn.com` / `data-mutiny-loading`, `dynamicyield.com`, `intellimize`
- `google_optimize`, `optimize_id`, `.async-hide` (**Google Optimize — sunset; any live install is a finding**)
- `experiment_id`, `variant_id`, `ab_test`, `data-experiment`, `data-variant`

**Anti-flicker / page-hiding (LCP tax — cross-ref Cat 40 render-blocking, Cat 44 bundle weight):**
- `.async-hide` (Google Optimize), `#_vis_opt_path_hides` (VWO), `#at-body-style` (Adobe Target), `data-mutiny-loading`, inline `body{opacity:0}` / `visibility:hidden` tied to a test snippet, hide timeouts (`3000`/`4000`)

**Session replay / heatmap:**
- `static.hotjar.com` / `_hjSettings` / `hj(`, `clarity.ms` / `clarity(`, `_fs_org` / `edge.fullstory.com`, `LogRocket.init` / `lr-ingest`, `contentsquare` / `_uxa`, `smartlook`, `posthog.init` / `phc_`, `_mfq` / `mouseflow`

**Survey / VoC:**
- `cdn.sprig.com` / `window.Sprig` / `UserLeap` (legacy), `_kiq` (Qualaroo), `survicate` / `_sva`, `embed.typeform.com` / `data-tf-`, `refiner.io`

**Consent gating (presence only; correctness belongs to snitch-adsready):**
- `cookielaw.org` / `OneTrust` / `Optanon`, `consent.cookiebot.com` / `data-cookieconsent`, `osano`, `type="text/plain"` category-gated tags, `gtag('consent', ...)`, `ad_user_data` / `ad_personalization`

**Funnel events (cross-ref Cat 53):**
- `signup_started`, `signup_completed`, `step_1`, `checkout_started`, `checkout_completed`, `drop_off_step_X`

### Actually Hurts the Marketing Surface

**Layer A — source/crawl-detectable (assert with evidence):**

- **Whole-page anti-flicker / page-hiding snippet present** (`body{opacity:0}` / `.async-hide` / `#_vis_opt_path_hides` / `#at-body-style`), especially with a long timeout — the page is blank until the client-side test reveals it, collapsing FCP/LCP. Cross-ref Cat 40 / Cat 44.
  Evidence required: the style node / snippet + the test tool it belongs to.
- **Legacy Google Optimize install** (sunset 2023-09-30). The product is gone, so its hiding snippet now taxes Core Web Vitals for a test that no longer runs — pure cost, zero benefit.
  Evidence required: `google_optimize` / `optimize_id` / `.async-hide` present.
- **Stacked client-side testers** (≥2 of Optimizely/VWO/AB Tasty/etc. firing together) — they fight over the DOM, compound flicker, and inflate payload.
  Evidence required: ≥2 distinct tester signatures in rendered HTML/network.
- **Stacked session-replay tools** (≥2 of Hotjar/Clarity/FullStory) — redundant payload weight and multiplied privacy exposure.
  Evidence required: ≥2 replay signatures.
- **Replay / experiment tag firing *before* consent** — privacy + legal exposure (session-replay-before-consent has driven a wave of CIPA "wiretap" suits on checkout pages). The ad-pixel side of the same order problem is not audited here: call the Skill tool with "snitch-adsready".
  Evidence required: tag fires pre-consent in the rendered consent order.
- **Experiment / replay tool gated *behind* consent on a low-traffic site** — the sample is selection-biased toward consenters and under-powered, quietly invalidating the A/B math.
  Evidence required: `text/plain`-gated tester/replay tag + low traffic.
- **No experiment / CRO tool at all when traffic warrants it** — analytics tells *what*, CRO tells *why*. (First verify it isn't server-side/warehouse-native — see NOT a Problem.)
  Evidence required: full source + rendered scan, no client tester AND no server-side/warehouse signal.
- **Funnel events not defined** (analytics fires pageviews only). Cross-ref Cat 53.
  Evidence required: analytics install + no custom funnel events.
- **Heatmap / session-recording installed but never reviewed** (recordings pile up; no rage-click / dead-click / u-turn analysis feeding the backlog).
  Evidence required: tool install + no review cadence in shared docs.
- **Un-maintained VoC install** (e.g., legacy `window.UserLeap` alias for Sprig) — signals a fire-and-forget setup.
  Evidence required: legacy alias present.

**Layer B — process discipline (only with a shared test archive / docs; else → Context Check):**

- **No pre-launch sample-size / MDE** — tests run "until they look done"; underpowered tests over-state effects. (Defaults: 80% power, α 0.05.)
  Evidence required: test plan with no documented sample-size calc.
- **Peeking / early stopping without a sequential method** — calling a test the moment p<0.05 appears inflates false positives ~5× (≈26% vs 5%). Only a flag when *not* using a sequential/always-valid/Bayesian method built for it.
  Evidence required: test log showing an early stop on a fixed-horizon test.
- **Tests not run in whole business cycles** (<1 week, or partial weeks) — weekday/weekend mix skews the result.
  Evidence required: durations <7 days or non-whole-week.
- **No SRM (sample-ratio-mismatch) check** — a 50/50 split that lands 52/48 means randomization/logging is broken and the result is invalid regardless of significance (chi-square, flag p<0.001).
  Evidence required: no SRM gate in the test process.
- **Many metrics/segments scanned with no correction and no single primary metric** — run 20 tests at 5% and ~1 false "winner" is pure chance; post-hoc segment mining is worse.
  Evidence required: multi-metric/segment reporting without a declared primary + correction (Benjamini-Hochberg / Bonferroni).
- **No guardrail metrics / OEC** — optimizing a local metric (clicks/signups) while revenue, retention, latency, refunds, or unsubscribes silently degrade.
  Evidence required: tests with a single success metric and no declared counter-metrics.
- **Unstructured hypotheses** ("let's try a green button") with no "because we observed [data]" grounding — a win or loss teaches nothing.
  Evidence required: backlog items with no research-grounded, falsifiable hypothesis.
- **No prioritization framework** (ICE / PIE / PXL / RICE applied consistently) — backlog ordered by the loudest voice (HiPPO).
  Evidence required: no documented prioritization scoring.
- **Ship-everything / no learning repository / no holdout** — shipping flat or marginal results, no searchable archive of past tests, and no holdout group, so the team can't measure true cumulative impact (summing per-test lifts over-states reality).
  Evidence required: no losers killed / no test archive / no holdout group.
- **Implausible win rate (sustained >50%)** — real ideas mostly don't win (healthy ≈10-35%); a high win rate signals peeking, underpowering, or shipping flats as wins.
  Evidence required: archive win rate >50% with the rigor gaps above.

### NOT a Problem

- Pre-launch site without CRO tooling. Premature.
- Single-purpose simple landing page where CRO ROI is low.
- **Server-side / warehouse-native experimentation** invisible in client HTML (Eppo, Statsig Warehouse Native, LaunchDarkly/Optimizely Full Stack server-side, edge tests, GA4→BigQuery). This is *healthier* than client-side, not "no tooling" — it eliminates flicker. Verify before claiming absence.
- **Overlapping / concurrent experiments** when the team has a deliberate traffic-layering or interaction-detection policy. Mature programs overlap by default; "one test at a time" is a velocity failure, not rigor. Only flag uncontrolled collisions on the same surface.
- **Early stopping via a sequential / always-valid / Bayesian method** designed for it — licensed peeking, not a violation.
- **Element-scoped hiding** (a single test element, not the whole page) for a client-side test — far smaller LCP cost than full-page hiding.

### Context Check

Items 2–10 are the experimentation-rigor checklist. Per the Layer-B trigger above, surface them **proactively as questions / recommendations whenever an experiment tool was detected and traffic is meaningful** — the install is the evidence that they apply. Escalate any item to an asserted finding only with shared team evidence.

1. Does the team have a designated CRO owner?
2. Is traffic high enough for A/B tests to reach significance, and do they compute sample size / MDE before launching?
3. Is the primary conversion well-defined, with a declared OEC + guardrail metrics?
4. Is there a peeking policy — fixed horizon, or a sequential/always-valid/Bayesian method?
5. Do they run an SRM check and treat a failure as a hard stop?
6. Are hypotheses structured ("because we observed [data], we believe [change] causes [effect], measured by [metric]")?
7. Is there a consistent prioritization framework (ICE/PIE/PXL/RICE)?
8. Do they kill losers, keep a learning repository, and run a holdout to measure cumulative impact?
9. Is experimentation client-side (flicker risk) or server-side/warehouse-native?
10. Does the consent setup bias the experiment/replay sample (gated behind consent), or leak it (firing before consent)?
11. Is there a review cadence for qualitative data (replay/heatmap/surveys)?

### Reference

The experiment-rigor rules in this category — fixed sample sizes computed before the test, no
peeking at running results, sample-ratio-mismatch checks, and a written prioritization rubric —
are the settled consensus of the online-controlled-experiments literature and of a large body of
published CRO practice. The rules that matter are stated inline above; no external read is
required to apply them.

Holdouts / cumulative impact, Eppo: https://www.geteppo.com/blog/holdouts-measuring-experiment-impact-accurately

Anti-flicker snippets & Core Web Vitals: https://www.speedcurve.com/blog/web-performance-anti-flicker-snippets/

PostHog product analytics: https://posthog.com/docs · CXL Institute on CRO: https://cxl.com/institute/

**Severity tagging:**
- Whole-page anti-flicker snippet on a live test → High (Critical if a long timeout on a money page); legacy Google Optimize hiding snippet (sunset) → High.
- Replay/experiment tag firing before consent → High (legal exposure).
- Experiment/replay sample biased by consent gating → High (invalid data).
- No funnel-step events on primary conversion → High.
- No SRM check / peeking on fixed-horizon tests / no sample-size calc → High (invalid results), but only with archive evidence.
- No guardrail metrics / OEC → Medium.
- Stacked client-side testers or stacked replay tools → Medium.
- No prioritization framework / unstructured hypotheses → Medium.
- A/B infra installed but unused (false confidence) → Medium.
- Heatmap/recording installed but never reviewed → Medium.
- No CRO tool at all → Medium (depends on traffic; verify not server-side).
- Implausible win rate (>50%) → Medium (signal, not proof).

**Fix voice:** `analytics-engineer` (primary) | `indie-commerce-founder` (backup).

Read `souls/analytics-engineer.json` before writing the Fix.

Worked fix example — instrumentation:

> Define the funnel before instrumenting it. Decision question: where do we lose people in signup?
>
> Events:
> ```ts
> trackEvent('signup_started', { source: utmSource });
> trackEvent('signup_step_email', {});      // user typed email
> trackEvent('signup_step_password', {});   // user set password
> trackEvent('signup_step_oauth', { provider: 'google' });
> trackEvent('signup_completed', {});
> ```
>
> Now PostHog / Mixpanel / GA4 show conversion per step. The drop-off step is the one to A/B test. Run one test at a time on that step; ship the winner; move to the next worst step.
>
> Without funnel events, you're optimizing blind.

Worked fix example — rigor (when tests run but the results aren't trustworthy):

> A test you can't trust is worse than no test — it ships the wrong thing with false confidence. Pre-register four things before any variant goes live:
>
> 1. **MDE + sample size.** Pick the smallest lift worth shipping (say +5% relative), plug baseline rate + 80% power + α 0.05 into a sample-size calculator, and get the N per arm. That N and the calendar duration (whole weeks, ≥1 full business cycle) are fixed before launch.
> 2. **One primary metric + guardrails.** Name the OEC (e.g., revenue per visitor, not raw clicks). List counter-metrics that block a ship if they degrade: revenue, latency, refunds, unsubscribes.
> 3. **Don't peek.** Don't call it early at the first green p-value — that turns a 5% error rate into ~26%. Either wait for the pre-set N, or switch to a sequential/always-valid engine that's built to let you stop early.
> 4. **SRM gate.** Before reading results, check the split landed as designed (chi-square, fail at p<0.001). A 50/50 that came in 53/47 means the randomization is broken — throw the test out, don't interpret it.
>
> Then ship winners, kill losers, write the learning down so nobody re-runs it, and keep a small holdout so you can prove the program actually moved the number. If your win rate is above ~50%, that's not a flex — it's a symptom.
