# Meta Ads Account Health

Cross-cutting playbook for brands running paid Meta ads (Facebook + Instagram + Messenger + Audience Network). Loaded by Cat 120 (Meta ads account structure health) and surfaced from Strategic Recommendations when the component inventory detects Meta Pixel / Conversions API.

Most ad-account problems aren't creative problems. The brand's creative agency or in-house team can produce excellent ads and still lose money because the account structure prevents the algorithm from learning. The patterns below are the structural rules that let the algorithm work.

## The 40/40/20 attribution model

Performance against the target outcome breaks down roughly as:

- **40% audience.** Who Meta shows the ad to. The single biggest lever.
- **40% offer.** What the ad asks the prospect to do — the deal, the urgency, the call-to-action.
- **20% creative + copy.** The visual + text execution. Important; not the lion's share.

Teams over-invest in the 20% (endless creative iteration) and under-invest in the 40s (audience definition and offer construction). The audit's job is to surface the brand's investment allocation and recommend rebalancing when creative is being polished while audience and offer are vague.

Audit application: when an audit produces multiple ad-performance findings, prioritize audience-specificity findings (Cat 110 ICP wedge scoring + this category) and offer findings (Cat 81 positioning + Cat 91 / 112 pricing) before creative findings (Cat 117 copy lint).

## One CBO per business goal

The temptation to "test by splitting" produces over-segmented accounts: 12 campaigns running simultaneously, each at $10/day, none ever accumulating enough conversions to exit learning. Meta's learning phase requires roughly 50 conversion events at the optimization goal before the algorithm commits to a delivery direction. An ad set at $10/day with a $50 target CPA reaches 50 conversions in approximately... never.

The healthy structure:

- **One Campaign Budget Optimization (CBO) campaign per business goal.** If the brand has one goal (lead generation), that's one campaign. If the brand sells two products with distinct buyer journeys, that's two campaigns — not 12.
- **Multiple ad sets inside the campaign** for meaningfully-different audience hypotheses. "Cold lookalike of converters" + "Cold interest stack" + "Warm retargeting of site visitors" + "Warm retargeting of video viewers" — four ad sets, each with a distinct hypothesis about who the ad reaches.
- **Multiple ads per ad set** for creative variation testing — but variation within a stable structure, not new ad sets per variation.

Audit application: count active campaigns per business goal. >3 is a finding. >6 is a critical finding (the account is structurally split too thin to learn).

## Ad-set budget = 3-5× target CPA

The math: Meta's learning phase needs ~50 conversions per ad set before the algorithm exits learning and stabilizes delivery. At a $40 target CPA, that's $2,000 to clear learning in one week. Daily budget needs to be roughly 3-5× target CPA (or $120-200/day in this example) to give the learning phase a 7-10 day timeline.

Under-budgeted ad sets ($5-20/day at a $40 target CPA) never exit learning. The algorithm has no stable signal; delivery never optimizes; CPA stays bouncy. Killing those ad sets at day 7 with 5 conversions and concluding "creative didn't work" is the wrong inference; the budget didn't work.

Audit application: capture daily budget per ad set. Compare to target CPA (from STEP 0.5.1 assumptions or pricing model). Flag when daily budget < 3× target CPA.

## The 7-day learning-phase lock

Edits applied to an ad set during the learning phase reset the learning. The signals accumulated to date are discarded; the algorithm starts over. Edits that trigger a reset include: budget changes >20%, optimization event change, audience change, creative change.

Healthy operation: launch the ad set, walk away for 7 days minimum, judge at 50 conversions or 14 days (whichever comes first). Helicopter-edits at day 2 — "CPM looks high, let me change targeting" — destroy the learning before the algorithm has signal.

Audit application: when ad-account access is available, check edit history. Edits inside the 7-day window are findings.

## Audience psychographic specificity

Demographic-only targeting ("Adults 25-55, USA, interested in [category]") makes the brand interchangeable with every competitor in the category. The auction prices every advertiser the same; the brand has no specificity to bid for.

The healthy pattern:

1. **Start with a real customer.** From the brand's top 20% of customers by LTV, define a single avatar with name-level specificity. Not "DFW homeowners" — "Highland Park homeowner planning a summer party who searches for landscaping after a competitor's quote came in high."
2. **Translate to Meta's targeting.** Lookalike of the top-20% LTV customer list (1-2% size for US). Interest stacks adjacent to the avatar's actual life (publications they read, organizations they're members of, behaviors they exhibit). Behavioral signals (recent home purchasers, frequent travelers, etc.) when relevant.
3. **Set the audience size for learning.** US cold targeting: 500k-1M is the sweet spot. <100k is too narrow to learn against; >5M is too broad to differentiate.

Audit application: capture the audience definition. Flag when targeting is demographic-only. Flag when audience size is outside 500k-5M for US cold.

## Creative testing via hook stacking

Creative testing means varying ONE thing at a time, not launching ten unrelated ads and calling it a test. The discipline that produces signal:

1. **One base creative.** A 30-45 second video (or a still image with full message) that carries the offer end-to-end. This is the production-grade creative.
2. **Five to ten hook re-records.** Re-record the first 3 seconds of the base creative. Different opening line, different B-roll, different framing. The base script + body + offer stays identical. Each hook variation is a fresh ad to Meta's fatigue algorithm.
3. **Launch all hooks in one ad set.** Three to six ads at launch; expand to 10-20 ads over time as winners surface.
4. **Refresh the hook stack every 3-4 weeks** for local audiences, every 6-8 weeks for broader audiences. When CTR drops or frequency climbs >3, the stack is fatigued.

Audit application: inspect the brand's Meta Ad Library entries. Count the number of distinct base scripts vs the number of hook variations on the same script. One base script + 5 hook re-records is healthy; 5 unrelated scripts is structureless testing.

## The Marketing Rule of Seven

The buyer rarely converts on first touch. The conventional estimate is 7 touchpoints between awareness and conversion. The healthy account structure bakes this in:

1. **Cold prospecting.** Top-of-funnel video or image ad targeting lookalikes + interest stacks. Goal: drive video views or site visits.
2. **25% video retargeting.** Custom audience of users who viewed 25% of the cold video. Mid-funnel ad with social proof.
3. **50% video retargeting.** Same audience cut at 50% viewership. More aggressive offer.
4. **75% video retargeting.** Same audience cut at 75% viewership. Direct-response CTA.
5. **Site-visitor retargeting.** Custom audience of site visitors (pixel + CAPI). Testimonial-heavy creative.
6. **Form-abandoner retargeting.** Custom audience of Instant Form openers who didn't submit. The highest-intent retargetable cohort.
7. **Existing-customer LTV expansion.** Custom audience of converted customers; cross-sell, upsell, referral asks.

Audit application: capture the brand's funnel-stage ad coverage. A brand running cold ads only is leaving 5-10x retargeting compounding on the table. Flag missing funnel stages.

## Form-abandoner retargeting (the highest-intent free audience)

Meta Instant Form openers who didn't submit are the single highest-intent retargetable cohort in the account. They demonstrated intent (opened the form), saw the form fields, decided not to submit. The retargeting cost per re-engaged lead is typically half the cost per cold lead.

The custom audience: "People who opened Lead Form: {form_name} in the last 90 days, excluding people who submitted Lead Form: {form_name} in the last 90 days." Run a retargeting ad with testimonial-heavy creative + a friction-reducer (simplified form, shorter quote, free consult).

Audit application: when ad-account access is available, check whether the form-abandoner custom audience exists. Absence is a finding.

## Conversions API alongside Pixel

iOS 14.5+ App Tracking Transparency cost Pixel-only tracking roughly 20-30% of iOS conversions. The signal loss is not recoverable in the Pixel; server-side Conversions API (CAPI) is required to fill the gap. Healthy installs run both:

- **Pixel** fires client-side for the canonical conversion events.
- **CAPI** fires server-side from the brand's backend (after form submission, after payment, after activation) for the same conversion events.
- **Deduplication** via shared `event_id` between Pixel and CAPI events; Meta deduplicates server-side so the conversion isn't double-counted.

Without CAPI, the brand bids against a depleted signal. The auction sees fewer conversion events, optimizes less precisely, and burns budget on iOS traffic Pixel can't fully attribute.

Audit application: site-scan for Pixel install (Cat 107 will have already verified this). Then scan for CAPI presence (server-side endpoint or third-party integration like Meta Conversions API Gateway, Segment, Stape, Stripe events). Pixel-only is a high-severity finding for any brand with non-trivial iOS traffic.

## Custom audience freshness (the 180-day window)

Custom audiences built on Pixel events expire at 180 days from the event date. A custom audience defined as "all site visitors in the last 180 days" rolls forward continuously; one defined as "site visitors as of 2025-01-15" decays and shrinks. Audiences built on lookalikes built on stale source audiences inherit the decay.

The healthy pattern: every custom audience definition is bounded by a relative date window ("last 180 days"), not an absolute date. Lookalikes are rebuilt every 90 days from the freshest source audience available.

Audit application: when ad-account access is available, capture each custom audience's source + age. Flag audiences with absolute date bounds or sources older than 180 days.

## Lead form field discipline

Every required field on an Instant Form costs roughly 5-15% of completions. The Cat 60 conversion principle applies in spades. The minimum-viable form:

- **Email.** Mandatory.
- **Phone.** Mandatory. Enables SMS retargeting + bot filtering (bots that auto-submit forms with fake emails often skip the phone field; the SMS gate quickly identifies real leads).
- **Name.** Optional; useful for personalization but not load-bearing for follow-up.
- **Custom qualifier question.** One question that filters serious from casual ("Service area zip code?" or "Budget range?"). Adds a friction layer that bots skip.

Every additional required field costs more than it adds. The audit's recommendation is the minimum-viable form; the brand's instinct to capture more should be tested rather than accepted.

Audit application: capture the brand's Instant Form configuration. Field count >4 with all required is a finding.

## Optimization event matches the business goal

Meta optimizes delivery for the conversion event the brand selects. Picking the wrong event causes the algorithm to drive volume on the wrong outcome:

- **Lead** — optimizes for form submissions. Right when the goal is leads at any quality.
- **Purchase** — optimizes for completed purchases. Right when the goal is direct revenue.
- **Add to Cart / Initiate Checkout** — proxy events for shallow funnels. Sometimes useful when conversion volume is too low to optimize directly.
- **Custom Conversion: Qualified Lead** — optimizes for backend-qualified leads (when CAPI fires a custom event after the brand's CRM scores the lead). The single most powerful optimization choice for B2B brands with sales-team filtering.

When the optimization event drives volume of unqualified leads, the brand's sales team burns time on bad fits. The fix is upstream: define "qualified" via a custom CAPI event and optimize for that.

Audit application: capture the active optimization event. Compare to the business goal from STEP 0.5. Mismatches are critical findings.

## Operational cadence checklist

Weekly:

- Refresh hook variations on the highest-spend ad set if frequency >2.5.
- Add 1-2 fresh ads to the test ad set (new hooks, not new concepts).
- Check Instant Form lead quality with the sales team; identify spam patterns.

Monthly:

- Refresh the testimonial-based retargeting creative.
- Rebuild lookalike audiences from the freshest source.
- Review custom audience age; sunset audiences older than 180 days.

Quarterly:

- Re-launch the cold prospecting concept with a new base creative (full re-shoot).
- Update CAPI event mapping if the brand's CRM definition of "qualified" has shifted.
- Run a campaign-topology audit (consolidate over-split campaigns; sunset dormant ad sets).

## Pairs with

- Cat 67 (Paid social channel presence)
- Cat 107 (Pixel install completeness)
- Cat 108 (UTM hygiene)
- Cat 109 (Paid social measurement)
- Cat 120 (Meta ads account structure health)
- Cat 60 (Conversion & Trust — landing-page conversion architecture)
- Cat 110 (ICP wedge scoring — audience specificity)
- Cat 81 (Positioning) + Cat 91 / 112 (Pricing) — the offer side of 40/40/20
- Cat 117 (Site copy lint — ad copy passes the same vague-adjective rules as site copy)
- references/strategic-recommendations.md (paid-acquisition readiness tree — Tier 3 deferral until activation and wedge are working)
- references/decision-trees.md (Tree 3: should we test paid acquisition yet?)
