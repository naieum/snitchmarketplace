# Objection-Killer Checklist (5-Point Landing Page Audit)

Cross-cutting checklist for landing-page diagnosis. Loaded by Cat 81 (Market positioning), Cat 114 (Persuasion architecture), Cat 60 (Conversion & Trust), and Cat 111 (Trust artifact audit). Used during STEP 4.5 strategic recommendations when a copy or landing-page rewrite is the load-bearing fix.

Every landing page that fails to convert is closing on one (or more) of five buyer objections. The fix isn't "rewrite the page from scratch"; the fix is "identify which of the five objections the page failed to close, then close it specifically." Surgical beats sweeping.

## The five objections

| # | Objection | What the buyer is thinking | What closes it |
|---|---|---|---|
| 1 | **Credibility** | "Are these people real? Is this a real business?" | Trust artifacts (founder face, named testimonials, real company info, public status page, real reviews on third-party platforms) |
| 2 | **Complexity** | "Will I understand what I'm buying / how to use it?" | Concrete demos, screen recordings, single-sentence value prop, clear pricing, plain-language feature explanations |
| 3 | **Effort** | "How much work is it for me to get the result?" | Time-to-first-value indicators ("under 5 minutes"), free starter / free trial / freemium, "we handle X" reassurance, simplified onboarding flow |
| 4 | **Doubt** | "Will this actually work for my specific situation?" | Use-case-specific case studies, "not for" disclaimers (counter-intuitive trust), conditional language ("if you're X, this fits; if you're Y, look at Z"), industry-specific proof |
| 5 | **Delay / Urgency** | "Why now? Why not later?" | Real deadline (limited-time pricing closing, sunsetting feature, seasonal demand window), opportunity cost articulation, peer-action proof ("3 teams shipped this week") |

Audit application: read each landing page through the lens of the five objections. For each objection, identify whether the page closes it, leaves it open, or actively opens it (e.g., a vague hero compounds credibility doubt rather than closing it).

## Detection patterns per objection

### Credibility — what to look for

**Page closes credibility when it has:**

- Founder name + photo on the homepage or About page
- At least 3 testimonials with name + role + company + photo or social handle
- Real company information visible (address, phone, founding year)
- Third-party proof links (G2, Trustpilot, Google reviews, Better Business Bureau when relevant)
- Recent changelog or "shipped this week" signal
- Press / customer logos when real

**Page leaves credibility open when it has:**

- Stock photography of people no one can verify
- Anonymous "Sarah W., happy customer" testimonials with no role / company / photo
- A "Trusted by thousands" claim with no count, no logos, no link to evidence
- Missing About page or About page with no founder identification
- Logo wall with no context (no testimonials, no case studies, no count)
- Generic "Founded with passion to revolutionize X" mission statement

**Cross-references:** Cat 111 (Trust artifact audit) — full inventory. Cat 117 (Site copy lint) — weak social proof patterns.

### Complexity — what to look for

**Page closes complexity when it has:**

- A one-sentence value prop the buyer can repeat after reading the hero
- A 30-60-second demo video or interactive product tour above the fold
- Pricing visible without a sales call (for self-serve products)
- Plain-language feature explanations (no jargon-heavy bullet lists)
- A "Quick start" or "5-minute setup" indicator

**Page leaves complexity open when it has:**

- Hero copy that requires three readings to parse ("the AI-native unified platform for ...")
- Feature list with no use-case grounding ("Real-time sync. Multi-tenant. Advanced analytics.")
- No demo, no screenshots, no recording — the buyer has to imagine the product
- Pricing hidden behind "Contact us" on a self-serve product (cross-reference Cat 117 hidden-price pattern)
- Feature names instead of feature outcomes ("Smart Sync Engine 2.0" instead of "Your data updates everywhere in seconds")

**Cross-references:** Cat 81 (Positioning — clarity), Cat 117 (Site copy lint — vague adjectives, buzzword density), Cat 99 (Conversion funnel deep — pricing-page transition).

### Effort — what to look for

**Page closes effort when it has:**

- Concrete time-to-first-value (TTFV) signal: "Working setup in 5 minutes" or "First report in under 10 minutes"
- Free starter / free trial / freemium tier visible at the conversion decision
- "We handle X for you" reassurance for setup steps
- Minimum-friction first action (one-click OAuth, sample dataset, demo project)
- Onboarding-flow preview (screenshot or video of the actual first session)

**Page leaves effort open when it has:**

- No TTFV signal — the buyer guesses how long setup takes
- "Setup is easy" claim without specificity (the buyer has heard this from products that took weeks)
- Required steps before value (multi-step questionnaire, mandatory team-size estimate, sales-call gate on a self-serve product)
- Onboarding only described in marketing language; no actual screenshots of the in-product flow
- "Get a demo" CTA on a product that should be self-serve

**Cross-references:** Cat 60 (Conversion & Trust — CTA friction), Cat 99 (Conversion funnel deep — Stage 1 entry friction), Cat 55 (North-star metric — activation event proxy).

### Doubt — what to look for

**Page closes doubt when it has:**

- Use-case-specific case studies (not generic testimonials — "Plumber in Plano grew bookings 40%" vs "Great product!")
- "Not for" / "If you need X, look at Y" disclaimers (counter-intuitive trust signal)
- Conditional language: "If you're a solo founder, here's the path. If you're a 20-person team, this is the path."
- Industry-specific proof: testimonials, case studies, integrations, schema all matching the buyer's vertical
- Documentation, support, SLA — visible answers to "what if I have a problem after I buy?"

**Page leaves doubt open when it has:**

- One-size-fits-all positioning that the buyer can't see themselves in
- Testimonials all from one industry but the brand sells to many
- No "not for" / disclaimers — the page claims to fit everyone
- Comparison pages absent (the buyer compares to competitors and the brand provides no help)
- Support and documentation buried (the buyer wants to know about edge cases)

**Cross-references:** Cat 95 (Comparison pages), Cat 81 (Positioning — buyer specificity), Cat 110 (ICP wedge scoring), Cat 111 (Trust artifact audit — "not for" section as artifact #5).

### Delay / Urgency — what to look for

**Page closes urgency when it has:**

- A real deadline (limited-time pricing, sunsetting tier, seasonal demand window, beta closing)
- Opportunity cost articulated: "Every week without X costs Y"
- Peer-action proof: "3 teams shipped this week" or "127 customers joined in May"
- Trigger-tied language: "Before {seasonal moment}", "Before {regulatory change}", "Before {price increase}"
- Limited-quantity offer that's genuinely limited (not a fake countdown)

**Page leaves urgency open when it has:**

- No deadline anywhere; the page reads as "buy whenever"
- Fake urgency that the audit can verify is fake (countdown timer that resets on page reload, "only 3 left!" inventory claims for digital products, perpetual "ends today" banners)
- "Buy now" with no reason now matters more than later
- No peer-action proof; the buyer doesn't see other people moving
- Generic "Get started today" without any answer to "why today?"

**Cross-references:** Cat 117 (Site copy lint — dark-pattern urgency without real deadline), Cat 60 (Conversion & Trust — CTA timing), Cat 96 (Brand SERP defense — "is this real?" signals adjacent to urgency).

## Scoring a page against the five

For each landing page audited:

1. Score each of the 5 objections: `closed`, `open`, or `compounded` (the page actively makes the objection worse).
2. The order of fix: close the `compounded` objections first (they cost the most), then the `open` objections, then look for incremental tightening of the `closed` objections.
3. A page that closes 4 of 5 but compounds 1 (e.g., perfect credibility, complexity, effort, doubt, but the hero uses three vague adjectives that compound the complexity objection) still loses conversion at the compounded step. The chain is only as strong as the weakest link.

## Output shape

In the audit report's recommendation block, the objection-killer score for a high-leverage landing page (homepage, pricing, primary product page) is captured as:

```
Page: /pricing
Objection scoring:
- Credibility: closed (named testimonials + founder face on homepage; trust strip present)
- Complexity: open (pricing tiers visible but no demo above the fold; buyer doesn't know what they're buying)
- Effort: closed ("Free 14-day trial, no card" CTA + sample-project signal)
- Doubt: open (no use-case-specific case studies; testimonials all from one vertical)
- Delay/Urgency: open (no deadline; "Get started today" with no reason now)

Highest-priority fix: close the Complexity objection. Add a 30-second product tour above the pricing table. Cite Cat 60 + Cat 99 fix patterns.
```

## When the five aren't the right lens

Some pages serve goals other than direct conversion (brand awareness, recruiting, press, partnerships). The five-objection lens is calibrated for conversion pages — homepages, pricing pages, product pages, signup flows, comparison pages. For non-conversion surfaces, use the lens loosely (credibility still matters; effort and urgency less so). Cat 84 (Founder-led brand) and Cat 70 (Content strategy) cover non-conversion surfaces directly.

## Pairs with

- Cat 81 (Market positioning — the offer side of the 5 objections; positioning sets up which objections matter most)
- Cat 114 (Persuasion architecture — holistic 7-section score; the 5 objections are the conversion-specific subset)
- Cat 60 (Conversion & Trust — surface-level CTA + trust signals)
- Cat 111 (Trust artifact audit — credibility close)
- Cat 117 (Site copy lint — language that compounds objections)
- Cat 99 (Conversion funnel deep — the funnel-stage view of where objections kill conversion)
- Cat 95 (Comparison pages — closing doubt for buyer-vs-competitor research)
- references/decision-trees.md (Tree 4: which test should we run first? — when "hero copy weak" is the answer, this checklist is the diagnostic tool)
