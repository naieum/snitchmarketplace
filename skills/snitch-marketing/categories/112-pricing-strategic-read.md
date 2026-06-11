## CATEGORY 112: Pricing strategic read

Pricing pages get audited for the technical things (does the schema mention the price, does the canonical exist, is the title set). This category audits the pricing STRATEGY: is the brand's pricing mix structurally producing the cash flow and signal the team needs, or is it leaving money on the table or scaring buyers off?

The output is a three-bucket synthesis: What's working / What's worth changing / Don't do. Specific moves, with reasoning, for each bucket.

### Pre-flight: relevance check

Skip with reason `not applicable` for free-only products (open source, content sites without a paid tier, free directories). Run on every brand with a paid tier.

### Evidence required (do not skip)

**Source mode:**

1. Read `/pricing` (or equivalent). Quote the tier structure: number of tiers, prices, billing intervals (monthly / annual / lifetime), free tier shape (limited / time-limited / unlimited).
2. Compare to STEP 0.7 competitor research: where does the brand's price fall relative to the named competitor set? Cheapest? Mid-pack? Premium?
3. Check for annual discount: is there a billed-annually option? At what discount?
4. Check for lifetime offer: present? capped? framed as "early supporter" or as ongoing pricing?
5. Check for team / business / enterprise tier: present, "Contact us", or absent?
6. Check the pricing page's hero copy and CTA: is there a "no card required" / "free forever" / "money-back guarantee" trust signal at the conversion moment?
7. Check tier complexity: how many tiers? With how many feature differentiators each?
8. Check for usage caps and cap honesty: does "unlimited" mean unlimited, or is it bounded by fair-use language?

**Crawl mode:**

1. `Fetch` the pricing page. Quote the same.
2. Check competitor pricing pages for direct comparison (cross-reference STEP 0.7).

### Forbidden claims

- "Pricing is probably too high." Compare to the actual competitor set with quoted competitor prices.
- "The brand should add a team plan." Justify with evidence of demand (multi-seat customer requests, enterprise inbound, sales-led sister-brands in category) before recommending.
- "Free tier is too generous." Check unit economics; if per-user variable cost is meaningfully positive, flag with the math; otherwise the generous free tier may be the correct customer-acquisition strategy.

### What to Search For

- Tier structure (number of paid tiers, prices, intervals)
- Annual discount existence + size
- Lifetime offer presence + cap + framing
- Team / Enterprise tier presence
- Free tier shape (unlimited time / limited usage / time-limited trial / no free tier)
- Money-back guarantee or "no card required" trust signal
- Tier-complexity ratio: tiers x feature-differentiators per tier
- Cap-honesty signals (does "unlimited" come with fine-print fair-use language)

### Actually Hurts the Marketing Surface

(Each finding fits into one of the three buckets: What's working / What's worth changing / Don't do.)

**What's worth changing:**

- **No annual plan on a sticky product**, missing the LTV uplift.
  Evidence required: pricing page lists monthly only.
  Recommendation: add annual at a small discount (typically 15-20%). Wispr's annual is 20% off; mid-market is 17%.
- **Permanent discount displayed as the price** (banner says "50% off forever"; looks like the actual price).
  Evidence required: pricing page banner content.
  Recommendation: discounts train customers to wait. If it's a launch promotion, time-bound it explicitly. If it's the price, remove the discount framing.
- **Team / business plan offered before the brand can support it** (no billing infrastructure for multiple seats, no SSO, no invoicing, no shared admin).
  Evidence required: team-plan signup flow tested OR support-page commitments quoted.
  Recommendation: add a team SKU only when the support, billing, and compliance posture (SOC 2 / SAML / DPA) is real.
- **Tier inflation** (free, Lite, Pro, Premium, Enterprise = 5 tiers).
  Evidence required: pricing page tier count.
  Recommendation: indie SaaS rarely needs more than 3 tiers (free, paid, lifetime / annual). Each tier costs explanation tokens.
- **No first-month-low offer when conversion from free to paid is the bottleneck** ($1 first month, no card needed, beats forever-free for some funnel shapes).
  Evidence required: free-to-paid conversion data (from Cat 55) showing the bottleneck.
  Recommendation: instrument before testing; ship the offer once the bottleneck is identified.
- **No "no card required" / "money-back" / trust signal at the conversion moment**.
  Evidence required: pricing page CTA area content quoted.
  Recommendation: add the missing reassurance.
- **Lifetime offer is open-ended, not capped** (or worse, "lifetime" as a permanent SKU).
  Evidence required: lifetime tier framing on the page.
  Recommendation: cap lifetimes explicitly ("first 1,000 buyers, then we close it"). Open-ended lifetime is a future-cash problem.
- **Competitor parity pricing without competitor parity proof** (priced same as the leader, but without testimonials, case studies, brand recognition, or differentiation that justify it).
  Evidence required: pricing comparison vs competitor + missing proof artifacts.
  Recommendation: either lower price OR ship the proof; charging premium without proof loses both.

**What's working** (still findings; surface these so the team doesn't accidentally remove them in a redesign):

- **Cheapest priced paid tier in the competitor set** (the brand is the value option).
  Evidence required: brand price vs competitor set; brand is lowest.
- **No-card free tier** (removes the biggest signup-conversion objection).
  Evidence required: free-tier signup flow tested; no card prompted.
- **Flat-rate, no usage caps on paid tier** (a real trust signal vs throttling competitors).
  Evidence required: pricing page language quoted.
- **No annual lock-in** (a real choice when competitors require annual).
  Evidence required: pricing page billing options.

**Don't do:**

- **Don't raise the price toward the leader's price** unless the proof to support it has shipped.
- **Don't add tiers** when the existing set isn't producing differentiation pressure.
- **Don't run permanent discounts**; they train customers to wait.
- **Don't add a team plan** without the support / billing / compliance posture.
- **Don't price experiment** (A/B different prices to different visitors) without explicit dunning + revenue-protection logic. The downside risks legal exposure and customer trust if discovered.

### NOT a Problem

- A genuinely premium-priced product backed by proof (named testimonials, case studies, category leadership).
- A free-only product (no paid tier) that derives value from another channel (community, brand, lead-gen).
- A pricing-page hero that names competitors directly ("Y costs $15. We cost $6.") if the comparison is honest. This is a positioning move, not a pricing problem.
- Discount framing on launch ("Launch week: 50% off") with explicit end date.

### Context Check

1. What's the team's current Cash Flow vs Acquisition tradeoff? A pre-revenue / early-stage brand benefits from cash via lifetime; a mature brand benefits from MRR via annual.
2. Is the team's support / compliance posture ready for the recommended tier?
3. What's the competitor set's pricing distribution? The brand's price needs to fit a defensible position in that distribution.
4. What's the funnel bottleneck? Free-to-paid? Pricing-page-to-signup? Different bottlenecks call for different fixes.
5. Has the team committed to a 60-day pricing change (price changes have whiplash effects on existing customers and trust)?

### Reference

Patrick Campbell on pricing experimentation: https://www.priceintelligently.com
Specific pricing competitor data: cross-reference STEP 0.7 niche research output.

**See also:** Cat 115 (Pricing psychology tactical) for the display-level audit (charm vs rounded, decoy effect, anchoring order, mental accounting frames, Rule of 100, strike-through provenance). Cat 112 audits whether the brand charges the right amount for the right audience; Cat 115 audits whether the brand displays its prices in a way that converts. Both categories run together on any pricing surface.

**Severity tagging:**

- Pricing tier inflation (5+ tiers on indie SaaS) → Medium.
- No annual plan on sticky product → High.
- Permanent discount displayed as price → High.
- Team plan offered without compliance posture → Critical (commitment without backing).
- Open-ended lifetime offer → Medium (future-cash risk).
- Premium pricing without proof → High.
- No "no card" / money-back / trust signal at conversion moment → Medium.

**Fix voice:** soul slug per `references/voice-mapping.md`.

Worked fix example:

> Pricing strategy is three buckets, not a list of findings. Each move is justified or it doesn't ship.
>
> **What's working** (preserve in any redesign): The brand is the value-priced option in the competitor set by 25%. The free tier is no-card. There's no annual lock-in. These are real positions the buyer reads in 30 seconds and they justify the price point. Don't accidentally remove them.
>
> **What's worth changing:**
> 1. Add an annual plan at ~17% discount ($5/mo if paid annually = $60/year). Serious users lock in for the discount; LTV rises; the choice doesn't scare monthly buyers.
> 2. Ship a $99 lifetime tier, capped at 1,000 buyers, framed as "early supporter, closes when the cap hits." Three benefits: cash, testimonial-eligible power users, and the lifetime price-comparison work happens for the brand on Reddit organically.
> 3. Don't add a team plan yet. The support, billing, and compliance posture isn't there. Adding the SKU creates an obligation to support it.
>
> **Don't do:**
> - Don't raise the price toward the leader's price. The proof to justify it hasn't shipped. Stay value-priced until the proof exists.
> - Don't run permanent discount banners. Time-bound launch promotions are fine; "50% off forever" trains buyers to wait.
> - Don't ship a fourth or fifth tier. The market is confused enough; one free, one paid, one lifetime is the maximum complexity.
