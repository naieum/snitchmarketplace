## CATEGORY 114: Persuasion architecture (holistic psychology audit)

The whole-system view across the marketing surface. Tactical categories audit individual elements (alt text, schema, CTA presence). This category audits whether the persuasion architecture HOLDS: does the site move a visitor through First Impression → Trust → Motivation → Friction Reduction → Emotional Resonance → Decision Support → Follow-Through? A site can pass every tactical category and still fail here, because the elements don't compose.

**Every section resolves to one of three outcomes, and nothing else.** A **Finding** names the element, quotes the artifact (or its absence) at `file:line` or URL+selector, and carries a severity. A **Pass-with-evidence** names the surfaces that were read and what was found on them — a Pass with no cited surface is not a Pass. A **Skip-with-reason** says which surface could not be reached and why. There is no section score and no letter grade: a number like "Emotional Resonance 11/25" cannot be traced to evidence, and this skill only reports what it can trace.

### Pre-flight: always run

Persuasion architecture is universal. No skip at the category level; every commercial site is evaluated.

If the site is a pure marketing landing page (no checkout, no signup, no follow-through surfaces), Sections 4 and 7 will carry Skips. Record them as Skips with the reason; do not skip the category.

Read `references/mental-models.md` before the pass. The audit uses model names by reference and assumes the reader can look them up.

**Two layers — what you can actually claim (read first).** This category reports the **presence and quality** of persuasion patterns; those are observable from the page. Whether a pattern actually **lifts conversion for this audience is NOT knowable from inspection** — behavioral effects are context-dependent, audience-moderated, and can backfire (a six-country study found a textbook social-proof nudge *reduced* sign-ups in some markets). Frame impact as a **hypothesis to validate via the site's own A/B test** (Cat 73), never a guaranteed lift.

**Evidence-tier the models — don't cite shaky science as fact:**
- **Tier 1** (relatively robust, still context-dependent): anchoring, loss aversion, social proof, default effect.
- **Tier 2** (real but parameter/context-sensitive — qualify the claim): scarcity, reciprocity, commitment & consistency.
- **Tier 3** (contested / failed replication — do NOT assert as established science): ego depletion (the "decision-fatigue / willpower-as-fuel" framing), most unconscious priming. Only ~25% of social-psychology findings replicate; weight Tier 3 accordingly or drop it.

**Boundary with snitch-ux.** This category asks whether the *marketing surface* composes into a coherent argument. How a screen reads to a user mid-decision — the commitment weight of a CTA, the confirmation screen after the yes, the paywall's choice architecture — is judged against the user's decision path, which is the sibling's judge: call the Skill tool with "snitch-ux" for that half.

### Evidence required (do not skip)

**Source mode + crawl mode required:**

1. Fetch / read the homepage hero. Quote H1, sub-line, primary CTA.
2. Identify the seven persuasion-architecture surfaces on the site:
   - Hero + above-the-fold (Section 1)
   - Trust elements: testimonials, logos, certifications, third-party reviews (Section 2)
   - Motivation surfaces: outcome framing, identity copy, urgency signals (Section 3)
   - Conversion path: forms, CTAs, defaults, choice count (Section 4)
   - Emotional resonance: storytelling, brand voice, community signals (Section 5)
   - Decision-support: pricing page, FAQ, risk reversal, comparison content (Section 6)
   - Follow-through: onboarding, activation, exit flow, retention surfaces (Section 7)

   A page that is none of the seven is **outside the table**: it is not evidence for any section, in either direction. It cannot be a Finding, it cannot be a Pass, and it cannot corroborate one — a section's proved absence is proved on the seven surfaces alone. Leave it out of the report, or record it once as a Skip-with-reason ("not a persuasion-architecture surface"). Careers, legal, changelog and status pages are the usual out-of-table set.
3. For each section, work the checklist below. Every checklist line ends as a Finding (artifact quoted, or its absence proved by the read), a Pass (the surfaces read, named), or a Skip (the surface was unreachable, and why).
4. Report the seven sections as a coverage table: section, outcome, evidence. No totals.
5. Cross-reference findings to the tactical categories (60, 74, 81, 99, 115, 116) for fix-level detail.

### Forbidden claims

- "The hero may be unclear." Quote it, then Finding or Pass.
- "Trust signals seem weak." List what's there and what's missing, then Finding or Pass.
- "Friction is high." Count the form fields, the CTAs above the fold, the choices on pricing; then Finding or Pass.
- Any adjective standing in for evidence — "irresistible", "compelling", "delightful", "best-in-class". If a claim cannot be traced to a quoted artifact, it is not reportable. Describe what is on the page and let the reader judge it.
- Any numeric section score, total or letter grade. The outcome vocabulary is Finding / Pass-with-evidence / Skip-with-reason.

### Detection

Whole-site audit. The category runs after individual tactical categories have run (so their findings inform the section reads) but produces its own holistic output independently.

### What to Search For

Each element below is judged from a quoted artifact, never from an impression. Search for the artifact first; an element with no artifact to quote is judged from absence, and the absence is what gets quoted.

**First impression (Section 1):** the first-viewport heading, subhead and CTA in the page source; the hero image / video element; any interstitial, cookie wall or modal that renders before them.

**Trust (Section 2):** testimonial blocks (name, title, company, quantified result), customer-logo bars, third-party review badges, guarantee / refund / "cancel anytime" strings, security seals near payment fields, the About / team route.

**Motivation (Section 3):** outcome language in headings vs feature nouns, before/after or use-case sections, pricing-page value framing, comparison or alternatives routes.

**Friction (Section 4):** every `<form>` on the conversion path — field count, required vs optional marking, `label` association, `autocomplete` tokens, card-required-for-trial copy, number of steps between the primary CTA and completion.

**Emotional resonance (Section 5):** narrative sections (founder story, origin, mission), first- vs third-person voice, imagery of people vs stock abstraction, any free artifact given before the ask.

**Decision support (Section 6):** FAQ blocks, comparison tables, plan-difference copy, objection-handling sections near the CTA, docs / demo / sandbox routes.

**Follow-through (Section 7):** post-signup or post-purchase surfaces reachable from source (confirmation route, onboarding route, transactional email templates), unsubscribe and cancellation routes.

When a surface is not reachable with Read / Grep / Fetch, Skip that element with the reason rather than judging it from assumption.

### The seven sections

Each section is a short checklist. Every line is answerable from an artifact; a line that cannot be answered from one is a Skip, not a guess.

**Each section's "Finding when" list is closed.** It names every condition that makes that section a Finding, and nothing else does. An observation the list does not name is not a Finding for that section however true it is: route it to the tactical category that owns it, and let the section resolve on its own checklist. A section whose checklist checks out is a Pass-with-evidence — never a Finding built from a homeless observation.

#### Section 1: First impression & attention

- Does the first-viewport heading name what this is and who it is for? Quote the H1 and subhead.
- Is there a primary CTA in the first viewport, and does its label name an outcome? Quote it.
- Does anything render before the hero — interstitial, cookie wall, newsletter modal? Quote the component.
- Is the hero's visual a specific artifact (product, result, person) or generic stock? Quote the element and its source.

**Finding when:** no value proposition in the first viewport; no primary CTA above the fold on a commercial page; a modal or interstitial covers the hero on first load.
**Pass reads like:** "Pass — `/` hero (`src/routes/index.tsx:22-48`): H1 names the audience and the outcome, one primary CTA labeled 'Get my free audit', no interstitial in the source."

**Models in play:** hero clarity ties to JTBD. Cognitive load ties to Hick's Law and the curse of knowledge. Familiarity (mere exposure) trades against distinctiveness.

Cross-reference: Cat 81 (positioning), Cat 9 (title tag), Cat 60 (CTA design).

#### Section 2: Trust & credibility

- Are testimonials attributed (name, role, company, photo or handle) and do any carry a quantified result? Quote one.
- Is there a customer-logo bar or third-party review badge near the primary CTA? Quote it or prove its absence.
- Is there a guarantee, refund or "cancel anytime" string at the paid CTA? Quote it, and record it as a first-party assertion — it is risk reversal, graded in Section 6, and it does not answer this section's question.
- Is there security emphasis at the payment step, and is the About / team route real (named people) rather than a stock page?

**Two classes of trust copy — sort them before you pick a severity.** *Attributed proof* is a third party vouching: a testimonial carrying a real name and role, a customer-logo bar, a review badge or link to a review platform, a named case study, a real About / team route. *First-party assertion* is the brand vouching for itself: a guarantee or refund string, a "cancel anytime" line, a founder quote, a self-reported number. First-party assertions are legitimate copy and are graded elsewhere (Section 5 for voice, Section 6 for risk reversal) — they are never counted as proof here, and their presence does not turn an absence of attributed proof into a Pass.

**Finding when:** no proof of either class on a commercial page; no attributed proof on a commercial page even though first-party assertions are present — quote the assertions that are there, then prove the absence of the attributed class; anonymous-only testimonials (a quote with no name, role or company); a claim on the page that nothing on the site substantiates (route it to Cat 117 for the specific line).
**Pass reads like:** "Pass — `/`, `/pricing`, `/about` read: three named testimonials with role and company (`components/Testimonials.tsx:14-52`), G2 badge above the pricing CTA. The 30-day guarantee string at the paid CTA is recorded as first-party and graded in Section 6; the Pass rests on the attributed items."

**Models in play:** social proof. Authority bias. Liking / similarity. Availability (a vivid case study lands harder than an abstract claim).

Cross-reference: Cat 74 (customer feedback), Cat 60 (trust artifacts), Cat 75 (brand consistency).

#### Section 3: Motivation & desire

- Do the headings name a job to be done, or list features? Quote two headings.
- Does the page state the cost of the status quo anywhere (before/after, "what it costs to keep doing it manually")? Quote it.
- Is there identity language naming who this is for? Quote it.
- Is any urgency signal present, and is it backed by a real deadline or a real count? Quote the mechanism, not just the copy.

**Finding when:** every heading is a feature noun with no outcome; urgency is asserted with no enforcing mechanism (a timer that resets on reload, a stock count that never changes) — that is a dark pattern and takes the overlay below, not a section note.
**Pass reads like:** "Pass — `/` and `/for/agencies` read: headings state outcomes ('Ship the audit in an afternoon'), the comparison section quantifies the manual alternative, no urgency mechanism present (nothing to verify)."

**Models in play:** JTBD. Loss aversion / prospect theory. Identity / unity. Scarcity — only when genuine.

Cross-reference: Cat 81 (positioning). Segment definition and wedge scoring are strategy generation, not a site audit — call the Skill tool with "snitch-cmo" when the fix is "decide who this is for".

#### Section 4: Friction & conversion

- How many fields does the primary conversion form require, and are they all necessary? Quote the form.
- Is there one obvious primary action per viewport, or several equal-weight ones? Quote the CTA set.
- How many steps sit between the primary CTA and completion? Trace them from the routes.
- Are defaults pre-selected, and does each pre-selection favor the user or the business? Quote the default.
- Does a multi-step flow show progress? Quote the indicator or prove its absence.

**Finding when:** required fields the flow does not need; competing equal-weight CTAs; a consequential checkbox pre-checked in the business's favor (dark pattern — see the overlay); a card required for a "free" trial with no disclosure before the final step.
**Pass reads like:** "Pass — signup form (`app/signup/page.tsx:31-77`) asks for email only, one primary CTA, two steps to completion, no pre-checked boxes."

**Models in play:** Hick's Law. Default effect. Paradox of choice. Goal gradient. Activation energy.

Cross-reference: Cat 60 (conversion-trust), Cat 99 (conversion-funnel-deep). Whether the ask is too heavy for this point in the decision path → call the Skill tool with "snitch-ux".

#### Section 5: Emotional resonance

- Is there a narrative anywhere on the marketing surface (founder story, origin, mission), and is it on the path a visitor actually walks? Quote it and name the route.
- Is the voice first-person or corporate third-person? Quote a sentence.
- Does the imagery show real people, real product, or abstract stock? Name the assets.
- Is anything given before the ask — a free tool, a template, an open-source utility, a useful teardown? Quote the artifact.
- Is a community surfaced anywhere a visitor would see it? Quote the link.

**Finding when:** the brand has a story that exists only on `/about` and never appears on the conversion path; nothing is given before the ask on a brand whose category expects it; the entire visual layer is stock abstraction on a people-facing product.
**Pass reads like:** "Pass — `/` includes a two-line founder note under the hero (`index.tsx:64`), free calculator at `/tools/roi`, Discord link in the footer and in the hero sub-line."

**Models in play:** peak-end rule. Reciprocity. Unity / community. Narrative structure.

Cross-reference: Cat 84 (founder-led brand), Cat 70 (content strategy), Cat 72 (community). Writing the story is generation — call the Skill tool with "snitch-cmo".

#### Section 6: Decision support

- Is there more than one price on the page, and what does the highest one anchor against? Quote the tier set in display order.
- Is one plan marked as recommended, and does the marking match what the copy says is best for the buyer? Quote the badge.
- Is there a risk-reversal (guarantee, trial, refund window, cancel-anytime) at the point of commitment? Quote it.
- Does an FAQ or objection block sit near the CTA, and does it answer the objections the page raises? Quote two questions.

**Finding when:** a single unanchored price with no comparison; a "most popular" badge on the tier that is best for the business and worst for the stated buyer; no risk reversal at a paid CTA; an FAQ that answers only questions the buyer never asked. That list is closed: when the tier set, the badge, the risk reversal and the FAQ all check out, Section 6 is a Pass-with-evidence, and anything else the pricing page could improve is routed to its own category rather than written into this row.
**Pass reads like:** "Pass — `/pricing` read: three tiers in ascending order with the middle marked recommended, 14-day refund line under the CTA, FAQ answers the two objections the comparison page raises."

**Models in play:** anchoring. Decoy effect. Regret aversion. Framing. Contrast.

Cross-reference: Cat 115 (pricing display tactics), Cat 60 (trust artifacts). A CTA whose label does not match where it goes — "Talk to sales" pointing at the self-serve signup route — is a CTA and message-match defect, not decision support: it belongs to Cat 60 (CTA design), or Cat 109 when the surface is an ad landing page. Report it there and leave Section 6 on its own four questions. Whether the *price itself* is right for the segment is strategy — call the Skill tool with "snitch-cmo".

#### Section 7: Follow-through & retention

- What does the confirmation surface after signup or purchase actually say? Quote the route or the template.
- Is there an onboarding path with a first win, and is it reachable from the source? Trace it.
- Is the cancellation or unsubscribe route as easy to reach as the subscribe route? Quote both.
- Is there a reason to come back (recap email, saved state, progress)? Quote the mechanism.

**Finding when:** subscribe is one click and cancel is a support ticket (asymmetry — dark pattern, see the overlay); the confirmation surface is a bare receipt that restates nothing; the unsubscribe link is missing from a transactional template.
**Pass reads like:** "Pass — confirmation route (`app/welcome/page.tsx`) restates what the buyer now has and names the next step; cancellation is a self-serve route at `/settings/billing`."
**Skip reads like:** "Skip — the post-signup product is behind auth; no browser session or pasted screens available, so the activation path was not walked."

**Models in play:** activation energy. Commitment & consistency. Endowment. Peak-end (the cancellation flow is the last impression).

Cross-reference: Cat 116 (retention psychology), Cat 71 (lifecycle email). How the confirmation screen reads to the user who just committed is judged against their decision path — call the Skill tool with "snitch-ux".

### Ethics & dark-pattern overlay (blocking)

Persuasion becomes a **dark pattern** when it stops being truthful or stops leaving the user a free, informed choice. A dark pattern is not a weak section: it is a **blocking finding** on the whole category, reported regardless of how polished the surface is. Several are now **illegal**, not merely unethical. (Genuine, truthful persuasion — real scarcity, an available anchor price, honest social proof — is **not** penalized; that's the point of the test.)

**The boundary test (apply per suspected pattern):**
1. **Veracity** — is the claim true and substantiable? A countdown maps to a real enforced deadline; "only 3 left" reflects real stock; "12 viewing" ties to real telemetry. *Fabrication signals:* timer resets on reload, stock count never changes, viewer number randomized client-side.
2. **Material distortion** — does the tactic add real information, or only pressure on a false premise?
3. **Symmetry** — is the user-preferred / cheaper / privacy-protective path no harder than the business-preferred one? One-click subscribe with a ten-step cancel, or a giant "Accept all" beside a buried "Reject" → dark.
4. **Disclosure** — are all mandatory costs and recurring charges shown *before* commitment, not dripped at the final step?
5. **Five-attribute tag** (the taxonomy the dark-pattern research literature converged on) — asymmetric / covert / deceptive / information-hiding / restrictive. Zero = legitimate persuasion; one or more (especially *deceptive* or *covert*) = dark, severity scaling with the count.

**Detect (cross-ref Cat 117 copy-lint):** fabricated scarcity/urgency, fake social proof, confirmshaming, hidden costs / drip pricing, preselected consequential checkboxes, hard-to-cancel / roach-motel, forced account creation, disguised ads, nagging, trick wording.

**Regulatory state (law vs ethics — current as of 2026; flag for staleness):**
- **US (FTC §5):** the "Bringing Dark Patterns to Light" report anchors enforcement; the **Unfair or Deceptive Fees ("junk fees") rule is in force (May 2025)** — hidden mandatory fees are illegal in covered sectors; *FTC v. Vonage* ($100M) shows hard-to-cancel is actionable. The 2024 **"click-to-cancel" rule was vacated (July 2025)** — do NOT cite it as binding; cite §5 + the 1973 Negative Option Rule.
- **EU:** **DSA Article 25** expressly **prohibits** dark patterns on platforms (since Feb 2024); under **GDPR/EDPB**, consent obtained via deceptive design is **invalid**. A **Digital Fairness Act** is pending (2025-26) — watch.
- **California (CPRA):** dark-pattern consent is **not** consent; the CPPA test is **effect, not intent**, with a core **symmetry-of-choice** requirement.

**Reporting effect:** a confirmed dark pattern is its own High or Critical finding carrying the boundary-test evidence and the relevant law, and it caps what the rest of the category can say — a surface with a dark pattern is not reported as a strong persuasion architecture no matter how the other sections read.

The pattern names and the five-attribute tag come from the published dark-pattern research literature and its widely used public taxonomy. The regulatory anchors are the primary sources and stay citable by name: FTC "Bringing Dark Patterns to Light" (ftc.gov), EU DSA Art. 25, CPPA Enforcement Advisory 2024-02.

### Reporting output

Report the seven sections as a coverage table, then the findings in severity order. No totals, no grade.

```
Persuasion architecture — coverage

| Section | Outcome | Evidence |
|---|---|---|
| 1 First impression | Pass | `/` hero src/routes/index.tsx:22-48 — H1 names audience + outcome, one CTA
| 2 Trust | Finding (High) | `/pricing` — a 14-day guarantee at the paid CTA is the only trust copy; no attributed proof on any page read
| 3 Motivation | Pass | `/`, `/for/agencies` — outcome headings, quantified status-quo cost
| 4 Friction | Finding (Medium) | signup form app/signup/page.tsx:31-77 — 7 required fields, 3 unused downstream
| 5 Emotional resonance | Finding (Medium) | founder story lives only at /about:12-40, absent from the conversion path
| 6 Decision support | Pass | /pricing — three tiers, recommended tier marked, 14-day refund at the CTA
| 7 Follow-through | Skip | post-signup product behind auth; no session or pasted screens available

Dark-pattern overlay: none detected on the surfaces read.
Outside the table: /careers, /legal — not persuasion-architecture surfaces, not graded into a section.
```

Fix order: dark patterns first (they are blocking and, in places, illegal), then Critical and High findings, then Medium. Sections that Passed need no work; sections that Skipped need access, not fixes — say so plainly rather than implying a defect.

### NOT a Problem

- A section that Passes with cited evidence. Do not manufacture an improvement to fill the row.
- A section that Skips because the surface is genuinely unreachable (authenticated product, unbuilt onboarding). A Skip is a coverage statement, not a finding.
- Pre-launch sites with no customers: Sections 2 and 7 will carry Skips, and that is the correct output.
- Internal tools and relationship-sold B2B products where the marketing site is a placeholder rather than a conversion surface.
- Absent urgency mechanisms. No urgency is never a finding; fake urgency always is.
- A page outside the seven surfaces — careers, legal, changelog, status. A thin jobs page is not a Trust or Emotional-resonance defect; it is a page this category's table does not cover.
- A first-party assertion standing where third-party proof would be stronger. It is graded as what it is (Section 5 voice, Section 6 risk reversal); the missing attributed proof is the Section 2 Finding, and the assertion is not a second one.
- A deliberate one-tier price with no anchor, where the pricing page says why.

### Context check

1. What is the site's primary commercial goal (signup, demo, purchase, lead)? Judge against THAT goal, not a generic one.
2. Which section most directly serves that goal? Its findings lead the report.
3. Has the brand already worked this surface (visible test harness, A/B history, conversion data)? Weight their data over these heuristics.
4. Where does a finding here overlap a tactical category that already flagged it? Cross-file; never double-count.
5. Which sections Skipped, and what access would turn each Skip into a read?

### Severity tagging

Severity attaches to the finding, not to a section total:

- Dark pattern confirmed by the boundary test → Critical (or High when the attribute count is one and it is not deceptive or covert).
- No value proposition in the first viewport, or no primary CTA on a commercial page → Critical.
- No proof of either class on a commercial page, **or** no attributed proof on a commercial page when only first-party assertions (a guarantee, a founder quote, a self-reported number) carry the trust load; card required for a "free" trial with no pre-commitment disclosure → High.
- Attributed proof exists somewhere on the site but not on the page carrying the paid CTA; anonymous-only testimonials (quotes with no name, role or company) → Medium.
- Story, community or free artifact absent from the conversion path when the brand has one elsewhere → Medium.
- Unnecessary required fields, competing equal-weight CTAs, unmarked recommended tier, bare confirmation surface → Medium.
- Missing progress indicator, FAQ that misses the page's own objections → Low.

### Reference

`references/mental-models.md` for the full model catalog with cross-references back to this category's sections.

`references/objection-killer-checklist.md` for the five-objection scoring of any single landing page a finding names.

### Worked fix example

> A SaaS marketing site. Seven sections read; five Passed or Found, two Skipped.
>
> **Section 5 (Emotional resonance) — Finding, Medium.** Surfaces read: `/` (`src/routes/index.tsx`), `/about` (`src/routes/about.tsx`), footer component, `/pricing`.
>
> - The founder story exists at `about.tsx:12-40` and appears nowhere on the conversion path — the homepage is a feature list from hero to footer.
> - The only free artifact is a 14-day trial that requires a card (`pricing.tsx:88`). Nothing is given before the ask.
> - The brand has a Discord with 800 members (`footer.tsx:31`), linked only in the footer's third column.
>
> Fixes, in order:
>
> 1. Lift one line of the founder story to the homepage under the hero, in the founder's voice. Evidence it fixes: the narrative is now on the path the visitor walks.
> 2. Publish one genuinely useful free artifact — a calculator, a template, an open-source utility — reachable from the homepage. Reciprocity before the ask.
> 3. Surface the community where a visitor sees it: "Join 800 [audience]" in the hero sub-line, not only the footer.
>
> **Section 7 (Follow-through) — Skip.** The post-signup product is behind auth. No browser session and no pasted screens were provided, so the activation path, the confirmation surface and the cancellation flow were not walked. To turn this Skip into a read: grant a session, or paste the confirmation screen and the cancellation flow.
>
> Each fix names the model it rests on (narrative, reciprocity, unity) so the team understands the WHY — and each is framed as a hypothesis to test (Cat 73), not a promised lift.

**Fix voice:** soul slug per `references/voice-mapping.md`. Default: `permission-marketer` (foundational marketing voice) for the narrative; `brand-surface-designer` for the visual and peak-end design recommendations.
