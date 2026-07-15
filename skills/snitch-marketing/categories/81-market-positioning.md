## CATEGORY 81: Market positioning (differentiation, value-prop strength, audience clarity)

The strategic foundation under everything else. Can a visitor in 5 seconds tell what the product is, who it's for, and why it's different? Does the positioning differentiate from competitors or sit in their shadow? Is the audience targeting specific enough to win a niche?

### Pre-flight: always run

This category is always relevant. No skip; positioning is universal.

### The 5-element positioning framework

Use this canonical structure to evaluate the brand's positioning. Each element is observable from the homepage, pricing page, and competitor research (STEP 0.7); each gap is a finding.

| Element | What it answers | Where to look |
|---|---|---|
| **1. Category** | What kind of thing is this? Which mental shelf does the buyer put it on? | Homepage hero category framing ("X for Y"; "the [category] for [audience]"). Often subtler than a literal label. |
| **2. Buyer** | Who specifically is this for? Not "everyone who needs X." | "For [segment]" copy on homepage; `/for/{audience}` pages; testimonial roles. |
| **3. Alternatives they'll consider** | What will the buyer compare this to? | Competitor research from STEP 0.7; the buyer's reflexive comparison from `references/feedback-signals.md`. |
| **4. Differentiation** | What does this do that the alternatives don't (and why does that matter to the buyer)? | Hero subhead + feature highlights + "vs X" comparison content. |
| **5. Proof** | What evidence makes the differentiation believable? | Trust artifacts (Cat 111), testimonials (Cat 74), case studies, demo videos. |
| **6. Sales motion** | How does the buyer actually buy? | Pricing page CTA path; signup flow; demo-call gating; sales-led vs self-serve choice. |

The audit checks each element and reports a finding for any element the brand has not made explicit. Generic "for everyone" / "the best at everything" / "feature-rich" copy fails on Buyer and Differentiation simultaneously.

### Constraint-shift positioning (the strongest framing pattern)

Most B2B positioning says "we make X better" (value-add). A stronger frame says "X is no longer your constraint; Y is now your constraint" (constraint shift).

Examples:
- Lead-gen brand for outdoor services: "You'll run out of crew before you run out of leads." The category is no longer lead generation; the category is operational scaling triggered by lead saturation.
- Dictation brand for sore-wrist users: "Typing isn't your problem anymore; your batch of unanswered emails is." The category shifts from input device to inbox triage.
- Security audit brand: "Your AI is shipping faster than you can review it." The category is no longer security tooling; the category is keeping pace with AI velocity.

The audit checks whether the homepage hero names a constraint shift or merely promises improvement. Constraint-shift positioning is rare and signals deep customer empathy: the brand has thought about what success creates, not just what failure looks like today.

Models in play: Loss Aversion (the new constraint becomes a future loss to avoid), JTBD (the constraint shift names the new job that arrives once the old job is solved), Second-Order Thinking (the brand has reasoned past the immediate outcome).

### Cost-of-inaction / value-of-action balance (messaging symmetry)

Strong positioning copy holds two frames at once: the **value of acting** (what improves when the buyer adopts) and the **cost of not acting** (what quietly degrades while they wait). Most homepages carry only one. Pure value-of-action reads as a feature pitch the buyer can defer indefinitely ("sounds nice, not now"). Pure cost-of-inaction reads as fear with no exit. The pages that move a decision name both: here's what you gain, and here's what staying put costs you, both grounded in the buyer's real situation rather than manufactured.

This is distinct from constraint-shift (which names the NEW problem success creates). CoI/VoA balance is about whether the page gives the buyer both a reason to move and an honest cost to standing still. The audit checks the hero, the section directly above the primary CTA, and the pricing page for both frames.

A finding fires when one frame is entirely absent. A separate, more serious finding fires when the cost-of-inaction frame is **manufactured** (fake countdown, invented scarcity, "prices rise Friday" with no real reason) rather than a true consequence; that crosses into dark-pattern territory and is owned by Cat 117 (copy lint) and the Cat 114 ethics overlay. Honest CoI names a real cost the buyer is already paying; manufactured CoI invents urgency to pressure them.

Models in play: Loss Aversion (the cost-of-inaction frame is a loss to avoid), Status-Quo Bias (the buyer's default is to do nothing; the cost frame is what dislodges it), Temporal discounting (a vague future gain loses to a concrete present cost, so the value frame needs a near-term proof point).

### The say-it-first sweep (differentiation lives in what is said)

Differentiation is claimed, not just built: if every competitor *does* something but none
*says* it clearly, the first brand to say it owns it in the buyer's mind ("Women make the
first move" was Bumble's whole differentiator — a sentence, enforced; Porsche had
build-to-order for years, but Slate *worded* customization — "We built it. You make it." —
and owns it). The sweep, run with the STEP 0.7 competitor set:

1. List what the brand and its competitors all actually do (guarantees, response times,
   processes, human support, data handling).
2. For each, check whether *anyone's* homepage says it plainly.
3. Anything true of the brand, valuable to the buyer, and unsaid by everyone is a free
   differentiation claim — a strength finding with a ready fix.

Two adjacent moves feed the same sweep: the **contrarian stock phrase** (find the word or
claim everyone in the category parrots that customers don't actually want — "unlimited"
washes when customers want *freedom* — and publicly push against it), and the **mission
formula** for brands whose about/mission copy is inward-facing: a mission is connected to the
customer's welfare or it rallies no one — "We exist so that [person] no longer has to
experience [pain]," derived by asking "who is worse off without this product, and how?"

### Evidence required (do not skip)

**Source mode + crawl mode required:**

1. Fetch / read the homepage hero (H1, sub-line, primary CTA). Quote.
2. Identify each of the 6 positioning elements above. Quote the source per element.
3. Pull from STEP 0.5 (Discovery) and STEP 0.7 (Competitor analysis) to compare positioning to competitor positioning.
4. Identify "differentiation deltas", specific claims the brand makes that no competitor makes.
5. For brands with high-severity positioning findings: generate three positioning statement drafts (see "Three drafts when severity is High" below).

### Forbidden claims

- "Positioning may be weak." Quote the H1 + sub-line. Compare to 3 competitors. Then judge.
- "Audience may be unclear." Show what the homepage says + who it implies as audience.

### Detection

Homepage analysis + competitor benchmarking.

### What to Search For

- H1 text on homepage
- Sub-headline / one-paragraph value prop
- Primary CTA label + destination
- "For X" audience-naming patterns ("For developers", "For SMBs", "For solo founders")
- "vs Competitor" comparison pages
- Counter-intuitive hook patterns ("the new problem success creates", "what happens after you win")
- Constraint-shift framing ("you'll run out of X before you run out of Y")
- Cost-of-inaction framing ("every month without X costs...", "while you wait, Y keeps...") paired with value-of-action framing (what improves on adoption)
- Manufactured urgency that masquerades as cost-of-inaction (fake countdowns, invented scarcity) — flag and route to Cat 117 / Cat 114

### Actually Hurts the Marketing Surface

- **Positioning is generic** ("The best AI tool for everyone", fits no specific audience).
  Evidence required: homepage hero + audience absence.
- **Positioning is identical to a competitor's** (no differentiation visible).
  Evidence required: brand H1 + competitor H1 comparison.
- **Audience is unspecified** (no "for X" naming on homepage).
  Evidence required: homepage content scan.
- **Value prop is feature-list, not outcome** ("We have 50 features" instead of "Solve X problem in 5 minutes").
  Evidence required: hero copy.
- **Multiple competing value props** (homepage hero says one thing; pricing page says another; about page says a third).
  Evidence required: each surface's positioning quoted.
- **Positioning names current pain but not the constraint shift** (the brand promises improvement but doesn't articulate the new constraint success creates). This is a strength gap, not a critical break, but it's the difference between "good positioning" and "memorable positioning".
  Evidence required: hero copy + absence of post-success narrative.
- **Only one of cost-of-inaction / value-of-action is present** (pure upside reads as deferrable; pure downside reads as fear with no exit). This is a strength gap.
  Evidence required: hero + pre-CTA copy quoted, showing which frame is missing.
- **Cost-of-inaction is manufactured** (fake countdown / invented scarcity rather than a real consequence the buyer is already paying). This is a dark-pattern crossover, not a positioning strength.
  Evidence required: the urgency copy quoted + the absence of a real underlying reason. Route the fix to Cat 117 / Cat 114.
- **Brand does something differentiating but never says it** (the say-it-first sweep finds a
  true, buyer-valuable claim absent from every surface — the brand's *and* competitors').
  This is a strength gap with a free fix: word the claim and lead with it.
  Evidence required: the practice verified (site/docs/policy quoted) + homepage/pricing scan showing it unstated + competitor homepages also silent.
- **Mission/about copy is inward-facing** ("our mission is to build the best X" / shareholder
  or founder-centric framing) with no customer-welfare version anywhere.
  Evidence required: mission copy quoted, showing no customer outcome named.

### NOT a Problem

- Bold positioning that some find polarizing (better than safe and forgettable).
- Niche positioning that excludes most visitors (intentional; stronger conversion in the niche).
- Multiple-audience positioning when the product genuinely serves multiple personas (clearly segmented, e.g., "for developers" / "for marketers" tabs).

### Context Check

1. What does STEP 0.5 say the audience is? Does the homepage match?
2. What does STEP 0.7 say competitors claim? Is the brand differentiated?
3. Does the positioning hold up at 5-second test? (Show homepage to someone unfamiliar; can they explain what it is?)
4. Is there a "category" the brand can own (vs fight for share in an existing category)?
5. Does the positioning articulate a constraint shift (what NEW problem the brand creates) or only promise improvement?
6. Does the page give the buyer both a reason to act (value of action) and an honest cost to waiting (cost of inaction), or only one? Is any urgency real or manufactured?
7. Are the relevant mental models from `references/mental-models.md` applied (JTBD, First Principles, Mimetic Desire, Status-Quo Bias, Loss Aversion)?

### Reference

April Dunford on positioning: https://www.aprildunford.com/

**Severity tagging:**
- Generic / no-differentiation positioning → Critical.
- Identical to competitor positioning → High.
- Audience unspecified → High.
- Feature-list instead of outcome → Medium.
- Conflicting positioning across surfaces → High.
- Positioning names current pain only, no constraint-shift articulation → Medium (strength gap, not a break).
- Only one of cost-of-inaction / value-of-action present → Medium (strength gap).
- Manufactured cost-of-inaction (fake scarcity / urgency) → High, and cross-ref Cat 117 / Cat 114 dark-pattern.
- True differentiator unstated by brand and competitors alike (say-it-first opportunity) → Medium (strength gap with an unusually cheap fix).
- Mission copy inward-facing, no customer-welfare framing → Low.

### The 10-step positioning workshop

The 5-element framework above evaluates the brand's CURRENT positioning. The 10-step workshop produces the brand's NEXT positioning when the current positioning is misaligned. The audit walks through steps 1-7 from observable evidence; the customer's team completes steps 8-10 internally.

1. **List true competitive alternatives.** What would the customer actually do if the brand didn't exist? Often the honest answer is "do nothing", "use Excel", "use the OS built-in tool", or "hire a junior person." Direct competitors are sometimes the right answer; often they aren't. The customer's reflexive comparison (per `references/feedback-signals.md`) is the input for this step.
2. **Isolate unique attributes.** What can the brand do that none of the alternatives can? Be honest. "We're cheaper" is fragile (substitute position). "We integrate with [specific platform] in a specific way nothing else does" is durable. Strip the attributes nobody else can match.
3. **Map attributes to value.** What does the unique attribute actually do for the customer? "We use Whisper" is an attribute. "Hands-free typing for 8 hours a day without wrist pain" is the value. The audit checks whether the brand's marketing surfaces value or stops at attributes.
4. **Find customers who care a lot about that value.** Not everyone who could use the product. The buyers for whom this value is non-trivially better than the alternatives. Cross-reference Cat 110 (ICP wedge scoring); the workshop's step 4 IS the ICP scoring exercise.
5. **Find a market category that frames the brand's strengths as the buyer's evaluation criteria.** This is the load-bearing step. The same product framed as "the cheapest dictation app" loses on price-driven evaluation; framed as "voice typing for hands that hurt" wins on a different axis. The category choice determines which competitors the buyer compares to and which criteria they apply.
6. **Layer on a relevant trend (optional).** When a market trend is genuinely shifting in the brand's favor, layering it onto the positioning amplifies the message. AI-related trends, remote-work shifts, regulatory changes (EAA, GDPR), creator-economy growth. Trends are decoration when the foundation is solid; they're not foundation themselves.
7. **Capture the positioning as a structured statement.** A one-paragraph statement that names: market category, target buyer, the specific value, the differentiating attribute, the proof, the comparison set. The statement is internal; the messaging derived from it is what the customer reads.
8. **Align the team around the positioning.** Internal alignment first. The team that disagrees on positioning produces inconsistent marketing surfaces.
9. **Translate into messaging.** Hero copy, FAQ, comparison pages, sales pitch, social bios. All derived from the statement.
10. **Use the messaging consistently.** Across surfaces and time. Positioning churn (changing the hero every 30 days) destroys the compounding effect.

The audit's job is steps 1-7 from observable evidence. Findings flag where the brand's current homepage / pricing / about reflect a misalignment with the workshop output (e.g., the brand's competitive alternatives in step 1 don't match what the homepage's hero implies; the value in step 3 isn't surfaced on the page; the market category in step 5 differs from what the meta description claims).

### Sales narrative arc (when high-severity finding affects the sales narrative, not just the positioning)

A brand can have correct positioning but a weak narrative arc on the homepage scroll, demo video, or pitch deck. The narrative arc that consistently outperforms feature-list scrolls follows 6 parts:

1. **Insight.** Start with a market shift or tension the buyer recognizes. "Cookies are over." "AI generation makes the old SEO playbook obsolete." "Cloud transcription is fast but creates privacy debt." The insight is something the buyer ALREADY believes; you're naming the world they live in.
2. **Alternatives.** What has the buyer already tried? Why does it fall short? Honest naming of competitive alternatives plus their specific failure modes. The buyer trusts you more when you name the alternatives accurately.
3. **Perfect world.** What would be true if the buyer's problem were solved? The brand isn't introduced yet; this is the world the buyer wants to live in. Pure outcome.
4. **Introducing the solution.** Now the brand. How it delivers the perfect-world outcome via the unique attributes from positioning workshop step 2.
5. **Proof points.** Testimonials, case studies, demo, screen recording, customer logos. Without proof, the previous four steps are claims.
6. **Asking for the sale.** Specific ask. Time-bound. "Try free for 14 days, no card." "Book a demo this week." "Buy the lifetime tier before the cap closes." Generic CTAs ("learn more") fail this step.

When a Cat 81 finding is High severity AND the homepage's structure is "feature list" rather than narrative arc, the audit recommends restructuring the homepage scroll to match the 6-part narrative.

### Three drafts when severity is High

When positioning severity is High or Critical, the audit produces THREE positioning statement drafts as A/B candidates. Each draft is a complete hero (headline + subhead + CTA) that solves the same gap from a different angle, all grounded in the workshop output (the competitive alternatives from step 1, the value from step 3, the market category from step 5). The customer picks one to start; the others are alternatives if the first underperforms after 30 days.

**Draft A: pain-led.** Names the buyer's specific pain in the first sentence; introduces the product as the relief.

**Draft B: substitute attack.** Names what the buyer has already tried that didn't work; positions the brand against that prior-art rather than against direct competitors. Most durable for indie SaaS because the alternative is "nothing worked."

**Draft C: quiet confidence.** Describes the mechanism plainly without dramatic framing. Lets the price + the trust signal close.

**Draft D: constraint shift.** Names the NEW problem the prospect will have if the brand succeeds at solving the current one. Most credible because it forecasts a real operational consequence rather than claiming a pure win. Use when the prospect's category is operationally complex (B2B services, ops tools, anywhere "success creates new work").

Example: "You don't have a lead problem. You have a crew problem coming. [Product] is the AI agent that handles every inbound call and books the work, so your only remaining problem is hiring fast enough."

Default recommendation: ship Draft B first for most indie SaaS (substitute attack is the durable wedge). For operationally complex B2B (services, multi-step ops, hire-to-grow categories), ship Draft D first instead. The constraint-shift framing converts higher in those categories because it pre-answers the "will this break my ops?" objection. Drafts A and C remain alternatives if Draft B or D doesn't produce signal.

See `references/copy-bank-templates.md` Pattern 5 for the structural templates each draft fills.

**Fix voice:** soul slug per `references/voice-mapping.md`.

Worked fix example:

> The hero is a billboard. Three lines, ten seconds, that's all. The 5-element positioning framework runs once to identify what's missing; the three drafts run once to give the customer A/B options.
>
> Run the 5-element framework on the current homepage:
>
> 1. **Category** (mental shelf): is this a "form backend" or a "no-code form tool" or a "conversion-flow tool"? The category positions the buyer's expectation set.
> 2. **Buyer**: which specific buyer? Webflow users? Solo developers? Marketing agencies?
> 3. **Alternatives they'll consider**: probably Formspree, Basin, FormKeep, or rolling their own.
> 4. **Differentiation**: what specific thing does this do that those don't? (Be honest. If the answer is "cheaper" alone, that's a fragile substitute position; durable differentiation needs more.)
> 5. **Proof needed**: what evidence makes the differentiation believable? Customer testimonials? A clear pricing comparison? An honest comparison page?
> 6. **Sales motion**: self-serve free-to-paid? Or sales-led? The pricing page CTA path is the answer.
>
> Then the three drafts:
>
> **Draft A (pain-led):** "Your hands hurt. You still have 47 emails to write. [Product] types them for you. $X/mo, no card to try."
>
> **Draft B (substitute attack):** "You bought the $200 split keyboard. You bought the $150 vertical mouse. Your wrists still hurt at 4pm. The thing you haven't tried is not typing. [Product] is voice dictation that works in any app, on Windows or Mac, for $X."
>
> **Draft C (quiet confidence):** "Voice dictation that gets out of your way. One hotkey. Any app. Words appear at your cursor. $X a month. Try it free, no card, transcripts not stored."
>
> Ship Draft B for 30 days. Measure with the events from Cat 55. If conversion lifts, the substitute-attack frame is the homepage. If conversion is flat, swap to Draft A. If both fail, Draft C runs as the safety. The point is not perfection in the first hero; it's a structured comparison that names the wedge audience and produces measurable signal.
