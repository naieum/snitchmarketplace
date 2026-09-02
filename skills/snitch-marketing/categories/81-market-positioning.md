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
| **5. Proof** | What evidence makes the differentiation believable? | Trust artifacts (Cat 60), testimonials (Cat 74), case studies, demo videos. |
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

`souls/positioning-strategist.json` for the positioning frame this category scores against (internal voice reference).

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

### Producing a replacement positioning (not audited here)

This category grades the positioning the site currently shows, against the 5-element framework above
and the surfaces that carry it. Producing the replacement is a different job: running the positioning
workshop that picks the category and the buyer, and writing the sales-narrative arc a homepage
scroll or demo should follow. When a Cat 81 finding is High or Critical — conflicting positioning,
an umbrella hero naming three buyer types, a homepage that is a feature list rather than an
argument — say so in the finding, then call the Skill tool with "snitch-cmo" to decide the
replacement. The remediation this skill still writes is the copy artifact for the positioning the
customer lands on (`references/copy-bank-templates.md` Pattern 5 for hero variants, Pattern 12 for
the scroll structure), measured afterwards with the events from Cat 53.

Cross-reference: `references/objection-killer-checklist.md` for scoring which buyer objection the hero leaves open, and `references/brand-voice-framework.md` when the positioning finding turns on voice rather than on claim.

**Fix voice:** soul slug per `references/voice-mapping.md`.

Worked fix example:

> The hero is a billboard. Three lines, ten seconds, that's all. The 5-element positioning framework runs once, on the homepage as it stands, to name what is missing.
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
> Each unanswered element is the finding: quote the hero line that fails it and say which element it leaves blank. Which category, buyer and wedge the answers should be is the strategy call — call the Skill tool with "snitch-cmo". Write the hero variants for whatever it lands on from `references/copy-bank-templates.md` Pattern 5, ship one for 30 days, and measure it with the events from Cat 53.