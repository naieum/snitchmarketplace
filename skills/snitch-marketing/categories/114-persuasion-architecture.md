## CATEGORY 114: Persuasion architecture (holistic psychology audit)

The whole-system view across the marketing surface. Tactical categories audit individual elements (alt text, schema, CTA presence). This category audits whether the persuasion architecture HOLDS: does the site move a visitor through First Impression → Trust → Motivation → Friction Reduction → Emotional Resonance → Decision Support → Follow-Through? A site can pass every tactical category and still fail here, because the elements don't compose.

### Pre-flight: always run

Persuasion architecture is universal. No skip; every commercial site should be evaluated.

If the site is a pure marketing landing page (no checkout, no signup, no follow-through surfaces), Sections 4 and 7 may be partial. Note coverage in the finding. Do not skip the category.

Read `references/mental-models.md` before scoring. The audit uses model names by reference and assumes the reader can look them up.

**Two layers — what you can actually claim (read first).** This category scores the **presence and quality** of persuasion patterns; those are observable from the page and you assert them with rubric evidence. Whether a pattern actually **lifts conversion for this audience is NOT knowable from inspection** — behavioral effects are context-dependent, audience-moderated, and can backfire (a six-country study found a textbook social-proof nudge *reduced* sign-ups in some markets). Frame impact as a **hypothesis to validate via the site's own A/B test** (Cat 73), never a guaranteed lift.

**Evidence-tier the models — don't cite shaky science as fact:**
- **Tier 1** (relatively robust, still context-dependent): anchoring, loss aversion, social proof, default effect.
- **Tier 2** (real but parameter/context-sensitive — qualify the claim): scarcity, reciprocity, commitment & consistency.
- **Tier 3** (contested / failed replication — do NOT assert as established science): ego depletion (the "decision-fatigue / willpower-as-fuel" framing), most unconscious priming. Only ~25% of social-psychology findings replicate; weight Tier 3 accordingly or drop it.

### Evidence required (do not skip)

**Source mode + crawl mode required:**

1. Fetch / read the homepage hero. Quote H1, sub-line, primary CTA.
2. Identify the seven persuasion-architecture sections on the site:
   - Hero + above-the-fold (Section 1)
   - Trust elements: testimonials, logos, certifications, third-party reviews (Section 2)
   - Motivation surfaces: outcome framing, identity copy, urgency signals (Section 3)
   - Conversion path: forms, CTAs, defaults, choice count (Section 4)
   - Emotional resonance: storytelling, brand voice, community signals (Section 5)
   - Decision-support: pricing page, FAQ, risk reversal, comparison content (Section 6)
   - Follow-through: onboarding, activation, exit flow, retention surfaces (Section 7)
3. Score each section 0-25 using the rubrics below.
4. Sum the seven section scores into a total (0-175). Map to letter grade.
5. Cross-reference findings to specific tactical categories (60, 74, 81, 99, 112, 115, 116) for fix-level detail.

### Forbidden claims

- "The hero may be unclear." Quote it. Apply Section 1 rubric. Score it.
- "Trust signals seem weak." List what's there + what's missing. Apply Section 2 rubric.
- "Friction is high." Count form fields, CTAs above fold, choices on pricing. Apply Section 4 rubric.

Every section score requires the rubric-row evidence quoted. A section cannot be scored without naming the specific element evaluated.

### Detection

Whole-site audit. The category runs after individual tactical categories have run (so their findings inform the section scores) but produces its own holistic output independently.

### The seven sections

Each section scores 0-25 across four elements. Scoring rubric per row:

| Score | Rating | Meaning |
|---|---|---|
| 0-5 | Critical | Major psychological barrier; likely causing significant drop-off |
| 6-10 | Poor | Key element missing or counterproductive; needs urgent attention |
| 11-15 | Moderate | Basic element present but not optimized; room for improvement |
| 16-20 | Good | Well-implemented with minor optimization opportunities |
| 21-25 | Excellent | Strong implementation; refinement only |

#### Section 1: First Impression & Attention (0-25)

| Element | 0 | 5 | 10 | 15 | 20 | 25 |
|---|---|---|---|---|---|---|
| Hero message | No clear value prop | Generic value prop | Specific benefit stated | Clear outcome-focused | Emotionally compelling | Creates immediate curiosity |
| Visual hierarchy | Chaotic | Confusing | Basic clarity | Clear flow | Optimal scanning pattern | Guides perfectly |
| Cognitive load | Overwhelming | High | Moderate | Low | Minimal | Effortless |
| Novelty factor | Generic / repetitive | Slightly unique | Moderately fresh | Distinctive | Memorable | Standout |

**Assessment questions:**
- Does the hero communicate what this is and who it is for in three seconds?
- Can a visitor understand the primary benefit before scrolling?
- Is the visual hierarchy intuitive on first scan?
- Does the design read fresh or templated?

**Models in play:** Hero clarity ties to JTBD (Cat B). Cognitive load ties to Hick's Law and Curse of Knowledge. Novelty ties to Mere Exposure (need familiarity) balanced against Pratfall (some distinctive imperfection).

Cross-reference: Cat 81 (positioning), Cat 9 (title tag), Cat 60 (CTA design).

#### Section 2: Trust & Credibility (0-25)

| Element | 0 | 5 | 10 | 15 | 20 | 25 |
|---|---|---|---|---|---|---|
| Social proof | None | Name only | Names + generic quote | Specific results | Detailed case studies | Quantified outcomes with faces |
| Authority signals | None | Mentioned once | Credentials shown | Expert endorsements | Media mentions | Multiple authority layers |
| Visual trust | Stock imagery | Generic professional | Some real images | Real team / office | Behind-the-scenes | Transparent operations |
| Specificity | Vague claims | Some specifics | Verified claims | Data-backed | Third-party verified | Audit-ready evidence |

**Assessment questions:**
- Can visitors verify claims independently?
- Does the site feel like a real business with real customers?
- Are credentials displayed?
- Is there enough detail to reduce uncertainty?

**Models in play:** Social Proof / Bandwagon. Authority Bias. Liking / Similarity. Availability Heuristic (vivid case studies > abstract claims).

Cross-reference: Cat 74 (customer feedback), Cat 111 (trust artifacts), Cat 75 (brand consistency).

#### Section 3: Motivation & Desire (0-25)

| Element | 0 | 5 | 10 | 15 | 20 | 25 |
|---|---|---|---|---|---|---|
| Jobs-to-be-Done clarity | Not addressed | Product-feature focus | Outcome mentioned | Job clearly defined | Multiple jobs shown | Mastery of job framing |
| Loss aversion framing | No loss mention | Minimal | Moderate loss | Strong loss | Compelling loss | Future-self visualization |
| Identity alignment | No identity | Generic audience | Specific segment | Strong fit | Community belonging | Shared mission |
| Urgency mechanisms | None | Weak / fake | Occasional | Appropriate | Strategic | Creates genuine urgency |

**Assessment questions:**
- Is the core job-to-be-done clearly articulated?
- Does messaging frame what the visitor will lose by not acting?
- Do visitors feel like this is "for people like them"?
- Is urgency genuine or artificial? (If artificial, flag as ethical risk regardless of score.)

**Models in play:** JTBD. Loss Aversion / Prospect Theory. Unity Principle / Identity. Scarcity (only when genuine; false scarcity downgrades to Critical regardless of element score).

Cross-reference: Cat 81 (positioning), Cat 110 (ICP wedge).

#### Section 4: Friction & Conversion (0-25)

| Element | 0 | 5 | 10 | 15 | 20 | 25 |
|---|---|---|---|---|---|---|
| Form / CTA design | No clear action | Multiple confusing | Single clear | Optimized copy | Psychological triggers | Irresistible design |
| Default effects | Not utilized | Minimal | Moderate | Good defaults | Smart pre-selection | Personalized defaults |
| Paradox of choice | Overwhelming | Many options | Some options | Limited | Curated | Recommended path clear |
| Progress indicators | None | Minimal | Basic | Visual | Gamified | Achievement system |

**Assessment questions:**
- Is the primary action obvious within three seconds?
- Are choices simplified or overwhelming?
- Does completion feel achievable?
- Are defaults set ethically and optimally?

**Models in play:** Hick's Law. Default Effect. Paradox of Choice. Goal-Gradient. Activation Energy. BJ Fogg B=MAP.

Cross-reference: Cat 60 (conversion-trust), Cat 99 (conversion-funnel-deep).

#### Section 5: Emotional Resonance (0-25)

| Element | 0 | 5 | 10 | 15 | 20 | 25 |
|---|---|---|---|---|---|---|
| Peak-end experience | No memorable moments | One moment | Some moments | Positive peaks | Delightful moments | Emotional journey |
| Storytelling | None | Basic | Narrative present | Engaging story | Multi-layer narrative | Coherent brand story |
| Reciprocity | Take only | Minimal give | Some value | Valuable free resource | Generous offering | Progressive value |
| Community / social | None | Mentioned | Basic | Active community | User-generated | Movement building |

**Assessment questions:**
- Is there a memorable experience the visitor will recall?
- Does the brand tell a compelling story or only list features?
- Does the site give before asking?
- Is there a sense of belonging?

**Models in play:** Peak-End Rule. Reciprocity. Unity / Community. Storytelling (foundational, no single model owns this).

Cross-reference: Cat 84 (founder-led brand), Cat 70 (content strategy), Cat 72 (community).

#### Section 6: Decision Support (0-25)

| Element | 0 | 5 | 10 | 15 | 20 | 25 |
|---|---|---|---|---|---|---|
| Anchoring | No reference | One price | Comparison exists | Good comparison | Strategic positioning | Optimal price framing |
| Decoy effect | Not used | Weak decoy | Clear decoy | Effective decoy | Optimal tier | Subtle influence |
| Risk reversal | None | Basic guarantee | Standard terms | Strong guarantee | Multiple guarantees | Risk-free experience |
| FAQ / objections | None | Minimal | Basic | Addressed | Comprehensive | Anticipatory |

**Assessment questions:**
- Are prices framed effectively?
- Is there a clear "best choice"?
- Are all doubts addressed?
- Does the site anticipate objections?

**Models in play:** Anchoring. Decoy Effect. Regret Aversion. Framing Effect. Contrast Effect.

Cross-reference: Cat 112 (pricing-strategic-read), Cat 115 (pricing-psychology-tactical), Cat 111 (trust artifacts).

#### Section 7: Follow-Through & Retention (0-25)

| Element | 0 | 5 | 10 | 15 | 20 | 25 |
|---|---|---|---|---|---|---|
| Activation energy | High friction | Moderate | Basic ease | Easy | Very easy | Instant success |
| Commitment devices | None | Minimal | Some | Multiple | Strong | Identity-based |
| Switching costs | None | Minimal | Moderate | Strong | Very strong | Ecosystem lock-in |
| Exit intent | None | Weak attempt | Basic | Good | Strategic | Delightful alternative |

**Assessment questions:**
- Can visitors achieve a first win quickly (under five minutes)?
- Are there hooks for return visits?
- What makes them come back?
- Is leaving positioned as loss, or handled with dignity?

**Models in play:** Activation Energy. Commitment & Consistency. Endowment Effect. Switching Costs. IKEA Effect. Peak-End (cancellation flow).

Cross-reference: Cat 116 (retention-psychology), Cat 71 (lifecycle email).

### Ethics & dark-pattern overlay (caps the score)

Persuasion becomes a **dark pattern** when it stops being truthful or stops leaving the user a free, informed choice. A dark pattern is not just a low section score — it is a **ceiling on the whole category**, flagged regardless of how polished the surface is. Several are now **illegal**, not merely unethical. (Genuine, truthful persuasion — real scarcity, an available anchor price, honest social proof — is **not** penalized; that's the point of the test.)

**The boundary test (apply per suspected pattern):**
1. **Veracity** — is the claim true and substantiable? Countdown maps to a real enforced deadline; "only 3 left" reflects real stock; "12 viewing" ties to real telemetry. *Fabrication signals:* timer resets on reload, stock count never changes, viewer number randomized client-side.
2. **Material distortion** — does the tactic add real information, or only pressure on a false premise?
3. **Symmetry** — is the user-preferred / cheaper / privacy-protective path no harder than the business-preferred one? One-click subscribe + ten-step cancel, or giant "Accept all" + buried "Reject" → dark.
4. **Disclosure** — are all mandatory costs / recurring charges shown *before* commitment, not dripped at the final step?
5. **Mathur 5-attribute tag** — asymmetric / covert / deceptive / information-hiding / restrictive. Zero = legitimate persuasion; one or more (especially *deceptive* or *covert*) = dark, severity scaling with the count.

**Detect (cross-ref Cat 117 copy-lint):** fabricated scarcity/urgency, fake social proof, confirmshaming, hidden costs / drip pricing, preselected consequential checkboxes, hard-to-cancel / roach-motel, forced account creation, disguised ads, nagging, trick wording.

**Regulatory state (law vs ethics — current as of 2026; flag for staleness):**
- **US (FTC §5):** the "Bringing Dark Patterns to Light" report anchors enforcement; the **Unfair or Deceptive Fees ("junk fees") rule is in force (May 2025)** — hidden mandatory fees are illegal in covered sectors; *FTC v. Vonage* ($100M) shows hard-to-cancel is actionable. The 2024 **"click-to-cancel" rule was vacated (July 2025)** — do NOT cite it as binding; cite §5 + the 1973 Negative Option Rule.
- **EU:** **DSA Article 25** expressly **prohibits** dark patterns on platforms (since Feb 2024); under **GDPR/EDPB**, consent obtained via deceptive design is **invalid**. A **Digital Fairness Act** is pending (2025-26) — watch.
- **California (CPRA):** dark-pattern consent is **not** consent; the CPPA test is **effect, not intent**, with a core **symmetry-of-choice** requirement.

**Scoring effect:** any confirmed dark pattern **caps the category at C or lower** and is surfaced as its own High/Critical finding with the boundary-test evidence + the relevant law — even if every section rubric scores well. (Section 3 already downgrades false scarcity to Critical; this overlay generalizes that rule across all sections.)

Sources: deceptive.design (Brignull taxonomy) · Mathur et al., "What Makes a Dark Pattern… Dark?" (arxiv.org/pdf/2101.04843) · FTC "Bringing Dark Patterns to Light" (ftc.gov) · EU DSA Art. 25 · CPPA Enforcement Advisory 2024-02.

### Scoring output

Sum the seven section scores. Map to grade:

| Total | Grade | Summary |
|---|---|---|
| 0-35 | F | Critical psychological barriers; major overhaul needed |
| 36-70 | D | Significant gaps; substantial work required |
| 71-105 | C | Basic implementation; competitive but undifferentiated |
| 106-140 | B | Good implementation; solid and improvable |
| 141-165 | A | Excellent; strong psychological design |
| 166-175 | A+ | Best-in-class; refinements only |

Report format:

```
Persuasion architecture score: 117 / 175 (B)

Section 1 (First Impression): 18 / 25
Section 2 (Trust): 14 / 25
Section 3 (Motivation): 12 / 25
Section 4 (Friction): 20 / 25
Section 5 (Emotional Resonance): 11 / 25
Section 6 (Decision Support): 22 / 25
Section 7 (Follow-Through): 20 / 25

Priority recommendations:
- Section 5 is the weakest. Specific fixes: ...
- Section 3 is the second weakest. Specific fixes: ...
```

### Forbidden claims (additional to general)

- "The site lacks emotional resonance." Score Section 5 with rubric evidence.
- "Decision support is weak." Score Section 6 with rubric evidence.
- "Conversion friction is high." Score Section 4 with rubric evidence.

A category-114 finding never asserts a quality without a numeric score backed by the rubric.

### Priority recommendations framework

After the score is computed, recommend fixes in this order:

1. **Critical (any section scoring 0-10):** Remove psychological barriers immediately. Address before any other work.
2. **High (any section scoring 11-15):** Optimize the existing elements. Add specific psychological triggers from the relevant models.
3. **Medium (any section scoring 16-20):** Fine-tune. Add advanced techniques from the model catalog. A/B test improvements.
4. **Low (any section scoring 21-25):** Maintain. Document what works. Test for further optimization.

The audit always recommends working on the lowest-scoring section first, regardless of which section it is. A site with strong trust (Section 2: 22) and weak motivation (Section 3: 8) gets motivation-first fixes, not trust polish.

### NOT Vulnerable (the model passes)

- Holistic score above 140 with no section below 15.
- Lowest-scoring section already has a documented optimization plan and a test running.
- Site is pre-launch with no customers (Section 2 and 7 will be partial; full score is premature).
- Internal tool / B2B-only relationship-sold product where the marketing site is a placeholder, not a conversion surface.

### Context check

1. What is the site's primary commercial goal (signup, demo, purchase, lead)? Score against THAT goal, not a generic one.
2. Which section's score most directly affects the primary goal?
3. Has the brand already worked on this surface (signs of testing, A/B history, conversion data)?
4. Where does the audit's lowest-scoring section overlap with tactical categories that already flagged findings?

### Severity tagging

The total grade maps to overall severity:
- F or D total → Critical
- C total → High
- B total → Medium
- A or A+ → Low (refinement only)

Per-section severity follows the same scale (0-10 → Critical, 11-15 → High, 16-20 → Medium, 21-25 → Low). The lowest section drives the priority, not the average.

### Reference

`references/mental-models.md` for the full model catalog with cross-references back to this category's sections.

### Worked fix example

> A SaaS marketing site scored 117 / 175 (B). The lowest section was Section 5 (Emotional Resonance) at 11. The audit recommended starting there.
>
> Specific Section 5 findings:
> - Storytelling element scored 5: the homepage is a feature list. No narrative arc. The brand has a founder story that lives in the About page and never surfaces on the homepage.
> - Reciprocity element scored 10: the only free thing on the site is a 14-day trial that requires a credit card. Nothing is given before being asked.
> - Peak-end scored 10: there are no delightful moments in the signup flow. Activation is functional, not memorable.
> - Community / social scored 15: the brand has a Discord and 800 members but the homepage doesn't mention it.
>
> Recommended fixes (in order):
>
> 1. Add a one-line founder-story hook to the homepage, just below the hero. "I built this because I was burning out on..." in the founder's voice. (Storytelling → 10 → 15)
> 2. Add a genuinely useful free tool to the homepage (a calculator, a template, an open-source utility). Reciprocity asks before take. (Reciprocity → 10 → 18)
> 3. Add a single delightful animation to the post-signup screen. A confetti burst when the first project is created. A handwritten welcome email on day 1. Peak-end matters. (Peak-end → 10 → 16)
> 4. Surface the Discord on the homepage. "Join 800 [audience] in our community." (Community → 15 → 20)
>
> Section 5 projected score after these fixes: ~16-18. Total projected: ~123-125, still B but trending toward A. The next section to address is Section 2 (Trust) at 14.
>
> Voice: each fix recommendation is grounded in the model that applies (Storytelling foundational, Reciprocity, Peak-End, Unity). The model names go in the fix narrative so the customer understands the WHY, not just the WHAT.

**Fix voice:** soul slug per `references/voice-mapping.md`. Default: `seth-godin` (foundational marketing voice) for the narrative; `tobias-van-schneider` for the visual / peak-end design recommendations.
