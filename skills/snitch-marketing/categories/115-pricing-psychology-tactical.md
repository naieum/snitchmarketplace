## CATEGORY 115: Pricing psychology (tactical display)

Tactical pricing display checks. The auditable mechanics: charm vs rounded prices, decoy tier presence, anchoring order, mental accounting frames, discount math, strike-through provenance.

Distinct from Cat 112 (pricing-strategic-read), which audits whether the pricing positioning aligns with brand and target buyer. Cat 112 is "do you charge the right amount for the right audience"; Cat 115 is "given your prices, are you displaying them in a way that converts."

### Pre-flight: only run when a pricing page exists

If the brand has no public pricing page (sales-led, custom-quote, contact-form-only pricing), **Skip** with reason `no public pricing surface to audit; tactical display checks require visible prices`. The strategic question (should pricing be public?) belongs in Cat 112.

If pricing is shown only in checkout flow (e-commerce per-item), audit the checkout's price-display tactics. Same checks, different surface.

### Evidence required (do not skip)

**Source mode + crawl mode:**

1. Fetch the pricing page. Quote every visible price + the surrounding label.
2. Count pricing tiers. Note which is visually emphasized (size, color, "most popular" badge).
3. Quote any strike-through prices, "save X%" claims, or original-price anchors.
4. Quote any per-period framings ("per month", "per year", "per seat").
5. Identify the order tiers appear in (left-to-right, cheapest-to-most-expensive or reverse).
6. For SaaS: identify annual vs monthly toggle behavior, default selection, savings highlight.

### Forbidden claims

- "Pricing may be confusing." Quote tiers + count fields + score against Hick's Law.
- "Anchoring could be better." Identify the current anchor (highest-tier-first or cheapest-first) and quote.
- "Decoy is missing." Show the tier structure. A decoy is intentional, not accidental; absence is a specific finding.

### Detection

Pricing page + checkout flow.

### What to Search For

**Charm vs rounded match:**
- Price endings: .99, .95, .97 (charm-pricing tradition)
- Round endings: $50, $100, $500 (premium / fluency)
- The brand's claimed positioning: is the pricing format aligned?

**Rule of 100:**
- For prices < $100, percentage discounts read larger ("20% off" > "$16 off" on a $80 item)
- For prices > $100, absolute discounts read larger ("$50 off" > "20% off" on a $500 item)
- Audit which framing is used and whether it matches the price magnitude.

**Decoy effect:**
- 3-tier pricing where one tier is clearly worse value compared to its neighbors. Done well: the decoy makes the target tier obvious. Done poorly: the decoy is too obvious (looks like a typo) or absent (no anchoring inside the price set).

**Anchoring order:**
- Enterprise / highest tier on the LEFT or visually first: anchors expectations high, makes lower tiers feel like a deal.
- Cheapest tier first: anchors low, makes higher tiers feel expensive.

**Mental accounting frames:**
- "$1/day" / "less than a cup of coffee" / "per use" / "per project" reframings.
- Especially important for commodity-feeling SaaS where the monthly total feels arbitrary.

**Annual discount math:**
- "Save 20%" when annual is shown
- "Save $X" calculated explicitly
- Default selection (annual selected by default = nudge toward higher LTV)

**Strike-through provenance:**
- "$199 ~~$299~~" with an explanation of what $299 represents (original price, competitor price, list price)
- Strike-throughs without provenance read as fake-sale and erode trust
- Some jurisdictions (FTC, EU, UK CMA) treat unprovenanced strike-through as legal risk

### Actually Hurts the Marketing Surface

- **Anchoring failure: cheapest tier shown first** on a multi-tier pricing page (left side, top of stack, or visually emphasized). Inverts the anchor, makes premium tiers feel expensive instead of feeling like a deal.
  Evidence required: tier order quoted, with visual position.
  Severity: High.

- **No decoy / no "most popular" emphasis** on a 3+ tier pricing page. Visitors face Paradox of Choice without guidance.
  Evidence required: tier structure quoted, absence of visual emphasis or "recommended" badge.
  Severity: Medium.

- **Strike-through price with no provenance.** "$199 ~~$299~~" without explaining what $299 is. Reads as fake-sale.
  Evidence required: strike-through quoted, surrounding context (no original-date stamp, no source, no MSRP reference).
  Severity: Medium (legal risk: High in EU/UK/some US states).

- **Charm vs positioning mismatch.** Premium-positioned brand using $99 (value signal) or value-positioned brand using $100 (premium signal).
  Evidence required: brand claimed positioning + price format mismatch.
  Severity: Low (refinement, not break).

- **Rule of 100 violation.** Sub-$100 item showing absolute discount ("$16 off") or super-$100 item showing percentage ("20% off") when the alternative would feel larger.
  Evidence required: price + discount framing.
  Severity: Low.

- **No mental accounting frame for commodity SaaS.** $50/month for a tool that competes with "the price of a coffee" framing alternatives. Missed opportunity.
  Evidence required: pricing context + commodity comparable absent.
  Severity: Medium (when commodity), Low (when bespoke).

- **Annual discount unstated.** Monthly and annual tiers shown, but the annual savings aren't quantified ("save $X" or "save Y%").
  Evidence required: pricing toggle quoted, savings absent.
  Severity: Medium.

- **Pricing tiers exceed five.** Beyond five tiers triggers Paradox of Choice and slows decisions.
  Evidence required: tier count.
  Severity: Medium.

- **All-features list under every tier.** Each tier lists every feature with checks/dashes; the differences hide in a sea of sameness. Inverts the decision-support goal.
  Evidence required: feature grid quoted; differentiating features not visually emphasized.
  Severity: Medium.

### NOT a Problem

- **Single-tier flat pricing.** No anchoring or decoy to audit; the question is whether the price is right (Cat 112).
- **Pay-what-you-want / sliding scale.** Different psychology; audit against Cat 112 strategic, not 115 tactical.
- **Hand-quoted enterprise pricing.** Not a public-pricing surface; goes through sales.
- **Genuine sale with provenance.** Strike-through prices with clear original-date stamps and source aren't fake-sale findings.
- **Decoy absent on 2-tier pricing.** Decoys require three tiers to function. 2-tier pricing is fine without one.
- **Round pricing on premium product.** $500/month for an enterprise tool isn't a charm-pricing violation; it's the premium signal working.

### Context Check

1. What is the brand's claimed positioning (premium, value, mass-market)? Does the price format align?
2. How many tiers does the pricing page show?
3. Which tier is visually emphasized (badge, color, size)? Is that the target tier or a default?
4. What is the magnitude of prices ($10s, $100s, $1000s)? Does the discount-framing match Rule of 100?
5. Are there strike-throughs / "was $X" anchors? Are they provenanced?
6. Is annual / longer-term pricing shown? Is the savings quantified?
7. Is there a recurring frame (per-month, per-year, per-seat)? Could a per-day frame reduce sticker shock?

### Reference

- `references/mental-models.md` Section D for the pricing-specific models
- Cat 112 (pricing-strategic-read) for strategic alignment questions
- April Dunford on pricing positioning: https://www.aprildunford.com/

### Severity tagging

- Anchoring failure (cheapest first) → High
- Annual discount unstated → Medium
- Decoy absent on 3+ tier page → Medium
- Strike-through without provenance → Medium (jurisdictional: up to High)
- Charm / positioning mismatch → Low
- Rule of 100 violation → Low
- Mental accounting frame missing on commodity SaaS → Medium
- Pricing tiers exceed five → Medium
- All-features-list-under-every-tier → Medium

**Fix voice:** `april-dunford` (primary) | `seth-godin` (backup).

Read `souls/april-dunford.json` before writing the Fix.

### Worked fix example

> The brand has 4 pricing tiers in this order (left-to-right): Starter $19, Pro $49, Business $99, Enterprise "Contact us". The Business tier carries a "most popular" badge.
>
> Findings:
>
> 1. **Anchoring is correctly oriented.** Highest visible tier on the right; "Contact us" sits as an anchor above the visible numbers, but barely. Score: 18 / 25 on the Cat 114 §6 Anchoring sub-element.
>
> 2. **Decoy is unclear.** Pro at $49 sits between Starter ($19) and Business ($99). Feature differences between Starter and Pro are small; Pro looks like a low-effort middle tier rather than an intentional decoy steering buyers to Business. Recommendation: either widen the Pro / Business feature gap so Business is the obvious step up (Pro becomes the decoy), or remove Pro entirely and run a clean 3-tier.
>
> 3. **Annual discount unstated.** The page shows monthly prices. An annual toggle exists at the top but defaults to monthly, and the savings are shown as "Save 17%" with no dollar conversion. Recommendation: default to annual, show both "Save 17%" AND "Save $X/year" calculations next to each tier.
>
> 4. **Mental accounting absent.** $49/month for a productivity tool reads as a recurring spend the buyer needs to justify to a manager. A "$1.60/day" sub-line under the Pro tier, or "Less than your team's monthly coffee budget" framing, would help. Severity: Medium. Test it.
>
> 5. **Rule of 100 misapplied on the annual discount.** "Save 17%" on a $588 / year price ($49 × 12) feels small. "Save $99" (the same number) reads larger because dollar > percentage for prices > $100. Same offer, different framing. Severity: Low.
>
> Voice grounded in the models: Anchoring is correctly positioned (Section 6 rubric, 18 / 25). The Decoy weakness is a Paradox of Choice + Decoy-effect combination. The annual-discount findings combine Default Effect (default to annual nudges higher LTV) + Rule of 100 (frame as $99 not 17%). The mental-accounting frame is Cat 115 §E from the catalog.
