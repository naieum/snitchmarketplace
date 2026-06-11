# Mental models reference

A catalog of 70+ models from foundational thinking, behavioral psychology, and behavioral design. Cross-referenced by audit categories (especially Cat 114, 115, 116, 74, 81, 99) when a finding calls for a specific psychological mechanism.

Voice rule: no em-dashes. Use line breaks where commas would chain awkwardly.

## Psychology hierarchy (apply models in this order)

1. **Build genuine value.** Without this, every model below becomes manipulation. Marketing psychology is force-multiplier, not foundation.
2. **Establish credibility.** Authority, Social Proof, Consistency. Without trust, motivation moves no one.
3. **Reduce friction.** Hick's Law, Activation Energy, Defaults. Easy must come before motivated.
4. **Create motivation.** Loss Aversion, Reciprocity, Identity. After credibility and ease, motivation lands.
5. **Guide decisions.** Anchoring, Framing, Nudges. The choice architecture stage. Last, not first.

Findings that recommend a model from rows 4 or 5 without first auditing rows 1 through 3 are out of order. Fix friction before adding scarcity.

## Reality-check questions (apply before recommending any model)

1. Does this actually make sense in context? Would a real customer of this product understand and appreciate this approach?
2. Could this backfire? What unintended consequences (Cobra Effect, second-order) might occur?
3. Is it authentic to the brand? A scarcity tactic on a brand built around abundance reads dishonest.
4. Is the timing right? Some tactics work in awareness, others in consideration, others in decision.
5. Have you tested it with real customers, or are you cargo-culting from an article?

## Ethical guardrails

These models describe how people think, not how to trick them. Refuse or downgrade severity when an audit finding recommends:

- False scarcity (fake stock counts, fake timer urgency)
- Hidden default opt-ins (subscription tricks)
- Dark-pattern cancellation flows (cancellation requires a phone call)
- Pressure tactics aimed at vulnerable groups (medical, financial-distress, recently-bereaved audiences)
- "Confirmshaming" copy ("No thanks, I hate saving money")
- Streak / habit systems designed to punish absence rather than celebrate consistency

When a brand's existing site uses any of the above, the audit names them as ethical risk findings (not optimization findings) regardless of conversion lift.

---

## A. Foundational thinking models

Models that sharpen strategy before tactics.

### First Principles
Break problems down to basic truths and rebuild from there. Use the 5 Whys to tunnel through assumptions.
**Application:** Don't add content marketing because competitors do. Ask why, what problem it solves, whether a better lever exists.
**Relevant categories:** 81 (positioning), 70 (content strategy)

### Jobs to Be Done (JTBD)
People hire products to get a job done. Focus on the outcome the customer wants, not the features the brand ships.
**Application:** A drill buyer wants a hole. Frame around the job, surface the outcome, only then list features.
**Relevant categories:** 81, 114 §3 (motivation)

### Circle of Competence
Know what you do well. Venture outside only with proper learning or expert help.
**Application:** Don't chase every channel. Double down where you have genuine expertise.
**Relevant categories:** 70, 81

### Inversion
Instead of asking "how do I succeed", ask "what would guarantee failure". Then avoid those things.
**Application:** List what would make a campaign fail (confused messaging, wrong audience, slow page) and systematically prevent each.
**Relevant categories:** 114 (full audit)

### Occam's Razor
The simplest explanation is usually correct. Don't overcomplicate.
**Application:** If conversions dropped, check obvious causes (broken form, page speed) before complex attribution theories.
**Relevant categories:** 73 (CRO signals), 60

### Pareto Principle (80/20)
Roughly 80% of results come from 20% of efforts. Find and focus on the vital few.
**Application:** Identify the 20% of channels, customers, or pages driving 80% of results. Cut the rest.
**Relevant categories:** 70, 73, 99

### Local vs Global Optima
Optimizing the wrong thing locally doesn't help globally.
**Application:** Optimizing email subject lines (local) won't help if email is the wrong channel (global). Zoom out first.
**Relevant categories:** 99, 70

### Theory of Constraints
Every system has one bottleneck. Find and fix that first.
**Application:** If the funnel converts but traffic is low, more CRO work won't help. Fix traffic.
**Relevant categories:** 99, 114

### Opportunity Cost
Every yes is a no to something else.
**Application:** Time on a low-ROI channel is time not on a high-ROI one. Compare against the alternative.
**Relevant categories:** 70

### Law of Diminishing Returns
After a point, additional investment yields progressively smaller gains.
**Application:** The 10th blog post won't have the impact of the first. Diversify before doubling down past the diminishing point.
**Relevant categories:** 70

### Second-Order Thinking
Consider the effects of the effects.
**Application:** A flash sale boosts revenue (first order) but trains customers to wait for discounts (second order).
**Relevant categories:** 112, 114 §6

### Map ≠ Territory
Models represent reality but aren't reality. Don't confuse the dashboard with the customer experience.
**Application:** A persona is a model. Real customers are messier. Stay in touch with actual users.
**Relevant categories:** 110 (ICP), 74

### Probabilistic Thinking
Think in probabilities, not certainties.
**Application:** Don't bet everything on one campaign. Spread risk, plan for the case where the primary strategy underperforms.
**Relevant categories:** 70

### Barbell Strategy
Combine extreme safety with small high-risk bets. Avoid the mediocre middle.
**Application:** 80% of budget into proven channels, 20% into experimental bets.
**Relevant categories:** 70, 99

---

## B. Understanding buyers

Models that explain how customers think, decide, and behave.

### Fundamental Attribution Error
People attribute others' behavior to character, not circumstance. "They didn't buy because they're not serious" instead of "the checkout was confusing."
**Application:** When customers don't convert, audit the process before blaming them.
**Relevant categories:** 60, 99

### Mere Exposure Effect
People prefer things they have seen before. Familiarity breeds liking.
**Application:** Consistent brand presence across channels builds preference even without direct conversion.
**Relevant categories:** 75 (brand consistency), 68 (organic social)

### Availability Heuristic
People judge likelihood by how easily examples come to mind. Recent and vivid feel common.
**Application:** Case studies and testimonials make success feel achievable. Make positive outcomes easy to imagine.
**Relevant categories:** 74

### Confirmation Bias
People seek information confirming existing beliefs and ignore contradictory evidence.
**Application:** Understand what the audience already believes. Align messaging with their existing frame. Fighting beliefs head-on rarely works.
**Relevant categories:** 81

### Lindy Effect
The longer something has survived, the longer it is likely to continue.
**Application:** Proven principles (clear value props, social proof) outlast trendy tactics. Don't abandon fundamentals for fads.
**Relevant categories:** 70, 81

### Mimetic Desire
People want things because others want them.
**Application:** Show that desirable people want your product. Waitlists, exclusivity, social proof trigger mimetic desire.
**Relevant categories:** 74, 81

### Sunk Cost Fallacy
People continue investing in something because of past investment, even when it is no longer rational.
**Application:** Know when to kill underperforming campaigns. Past spend should not justify future spend without signal.
**Relevant categories:** 70

### Endowment Effect
People value things more once they own them.
**Application:** Free trials, samples, freemium models let customers "own" the product before deciding to pay. Loss aversion does the rest.
**Relevant categories:** 116 (retention), 99

### IKEA Effect
People value things more when they have invested effort in creating them.
**Application:** Let customers customize, configure, or build. Their investment increases perceived value and commitment.
**Relevant categories:** 116

### Zero-Price Effect
Free is not just cheap. It is psychologically different. "Free" triggers irrational preference.
**Application:** Free tiers, free trials, free shipping have disproportionate appeal. The jump from $1 to $0 is bigger than $2 to $1.
**Relevant categories:** 112, 115

### Hyperbolic Discounting (Present Bias)
People strongly prefer immediate rewards over future ones.
**Application:** Emphasize immediate benefits ("Start saving time today") over future ones ("You'll see ROI in 6 months").
**Relevant categories:** 81, 60

### Status-Quo Bias
People prefer the current state of affairs. Change requires effort and feels risky.
**Application:** Reduce switching friction. Make the transition feel safe. "Import your data in one click."
**Relevant categories:** 81, 116

### Default Effect
People accept pre-selected options. Defaults are powerful.
**Application:** Pre-select the plan the brand wants chosen. Opt-out beats opt-in (when applied ethically).
**Relevant categories:** 60, 114 §4, 115

### Paradox of Choice
Too many options overwhelm and paralyze.
**Application:** Three pricing tiers beat seven. Recommend a single "best for most" option.
**Relevant categories:** 60, 115, 114 §4

### Goal-Gradient Effect
People accelerate effort as they approach a goal.
**Application:** Progress bars, completion percentages, "almost there" messaging drives completion.
**Relevant categories:** 116, 99

### Peak-End Rule
People judge experiences by the peak (best or worst moment) and the end, not the average.
**Application:** Design memorable peaks (surprise upgrades, delightful moments) and strong endings (thank-you pages, follow-up emails, even cancellation flows).
**Relevant categories:** 116, 99

### Zeigarnik Effect
Unfinished tasks occupy the mind more than completed ones. Open loops create tension.
**Application:** "You are 80% done" creates pull to finish. Incomplete profiles, abandoned carts, cliffhangers leverage this.
**Relevant categories:** 116, 99

### Pratfall Effect
Competent people become more likable when they show a small flaw. Perfection is less relatable.
**Application:** Admitting a weakness ("We are not the cheapest, but here is why...") can increase trust and differentiation.
**Relevant categories:** 81, 74

### Curse of Knowledge
Once you know something, you cannot imagine not knowing it.
**Application:** Your product seems obvious to you and confusing to newcomers. Test copy with people unfamiliar with the space.
**Relevant categories:** 81, 70

### Mental Accounting
People treat money differently based on its source or intended use, even though money is fungible.
**Application:** Frame costs favorably. "$3/day" feels different than "$90/month" even when identical.
**Relevant categories:** 115, 112

### Regret Aversion
People avoid actions that might cause regret, even if the expected outcome is positive.
**Application:** Address regret directly. Money-back guarantees, free trials, no-commitment messaging reduce regret fear.
**Relevant categories:** 111 (trust artifacts), 60

### Social Proof / Bandwagon Effect
People follow what others do. Popularity signals quality and safety.
**Application:** Customer counts, testimonials, logos, reviews, "trending" indicators create confidence.
**Relevant categories:** 74, 111

---

## C. Influencing behavior

Models for ethical persuasion in marketing.

### Reciprocity Principle
People feel obligated to return favors.
**Application:** Free content, free tools, generous free tiers create reciprocal obligation. Give value before asking.
**Relevant categories:** 70, 71 (lifecycle email)

### Commitment & Consistency
Once people commit, they want to stay consistent.
**Application:** Get small commitments first (email signup, free trial). People who took one step are more likely to take the next.
**Relevant categories:** 99, 116

### Authority Bias
People defer to experts and authority figures.
**Application:** Feature expert endorsements, certifications, "featured in" logos, thought leadership content.
**Relevant categories:** 74, 111

### Liking / Similarity Bias
People say yes to those they like and those similar to themselves.
**Application:** Relatable spokespeople, founder stories, community language. "Built by marketers for marketers" signals similarity.
**Relevant categories:** 84 (founder-led brand), 74

### Unity Principle
Shared identity drives influence. "One of us" is powerful.
**Application:** Position the brand as part of the customer's tribe. Insider language, shared values.
**Relevant categories:** 72 (community), 84

### Scarcity / Urgency
Limited availability increases perceived value.
**Application:** Limited-time offers, low-stock warnings, exclusive access. Only when genuine. False scarcity is an ethical violation.
**Relevant categories:** 114 §3, 60 (ethical risk if fake)

### Foot-in-the-Door
Start with a small request, escalate. Compliance with small leads to compliance with larger.
**Application:** Free trial then paid then annual then enterprise. Each step builds on the last.
**Relevant categories:** 99, 116

### Door-in-the-Face
Start with an unreasonably large request, then retreat to what you actually want.
**Application:** Show enterprise pricing first, then reveal the affordable starter plan. Contrast makes the smaller ask feel reasonable.
**Relevant categories:** 112, 115

### Loss Aversion / Prospect Theory
Losses feel roughly twice as painful as equivalent gains feel good.
**Application:** Frame in terms of what they will lose by not acting. "Don't miss out" beats "you could gain". Most universally applicable model in marketing.
**Relevant categories:** 114 §3, 60, 81

### Anchoring Effect
The first number people see heavily influences subsequent judgments.
**Application:** Show the higher price first (original price, competitor price, enterprise tier) to anchor expectations.
**Relevant categories:** 115, 112

### Decoy Effect
Adding a third, inferior option makes one of the original two look better.
**Application:** A decoy pricing tier that is clearly worse value makes the preferred tier the obvious choice.
**Relevant categories:** 115

### Framing Effect
How something is presented changes how it is perceived. Same facts, different frame.
**Application:** "90% success rate" vs "10% failure rate" are identical and feel different. Frame the gain side.
**Relevant categories:** 81, 60

### Contrast Effect
Things seem different depending on what they are compared to.
**Application:** Show the "before" state clearly. The contrast with the "after" makes improvements vivid. (See also Cat 74 symmetric Before/With panels.)
**Relevant categories:** 74

---

## D. Pricing psychology

Models specific to price perception. Detailed audit in Cat 115.

### Charm Pricing (Left-Digit Effect)
Prices ending in 9 feel significantly lower than the next round number. $99 reads much cheaper than $100.
**Application:** Use .99 or .95 endings for value-tier products.
**Relevant categories:** 115

### Rounded-Price Fluency
Round numbers feel premium and process easily. $100 signals quality, $99 signals value.
**Application:** Round prices for premium tiers, charm prices for value tiers. Audit mismatch.
**Relevant categories:** 115

### Rule of 100
For prices under $100, percentage discounts read larger ("20% off"). For prices over $100, absolute discounts read larger ("$50 off").
**Application:** $80 product → "20% off" beats "$16 off". $500 product → "$100 off" beats "20% off".
**Relevant categories:** 115

### Good-Better-Best
Three tiers where the middle is the target. Expensive tier makes middle look reasonable, cheap tier anchors.
**Application:** Most B2B SaaS pricing pages should follow this structure. Decoy tier intentional.
**Relevant categories:** 115, 112

### Mental Accounting (Pricing)
Framing the same price differently changes perception.
**Application:** "$1/day" feels cheaper than "$30/month". "Less than your morning coffee" reframes the expense.
**Relevant categories:** 115

---

## E. Design and delivery models

Models for designing effective conversion systems.

### Hick's Law
Decision time increases with the number of choices.
**Application:** Simplify choices. One clear CTA beats three. Fewer form fields beat more.
**Relevant categories:** 60, 99, 115

### AIDA Funnel
Attention → Interest → Desire → Action. Classic customer journey.
**Application:** Structure pages and campaigns to move through each stage. Capture attention before building desire.
**Relevant categories:** 99, 81

### Rule of 7
Prospects need roughly seven touchpoints before converting.
**Application:** Build multi-touch campaigns. Retargeting, email sequences, consistent presence compound.
**Relevant categories:** 70, 71

### Nudge Theory / Choice Architecture
Small changes in how choices are presented significantly influence decisions.
**Application:** Default selections, strategic ordering, friction reduction. Guide without restricting.
**Relevant categories:** 60, 115

### BJ Fogg Behavior Model (B = MAP)
Behavior = Motivation × Ability × Prompt. All three must be present.
**Application:** High motivation + hard to do = won't happen. Easy + no prompt = won't happen. Design for all three.
**Relevant categories:** 116, 114 §4

### EAST Framework
Make desired behaviors Easy, Attractive, Social, Timely.
**Application:** Reduce friction (easy), make appealing (attractive), show others doing it (social), ask at the right moment (timely).
**Relevant categories:** 60, 116

### COM-B Model
Behavior requires Capability, Opportunity, Motivation.
**Application:** Can they do it (capability)? Is the path clear (opportunity)? Do they want to (motivation)? Address all three. More complete than Fogg for product onboarding.
**Relevant categories:** 116

### Activation Energy
The initial energy required to start something. High activation energy prevents action even when the overall task is easy.
**Application:** Pre-fill forms, offer templates, show quick wins. Make the first step trivially easy.
**Relevant categories:** 116, 60

### North Star Metric
One metric that best captures the value delivered to customers.
**Application:** Identify the North Star (active users, completed projects, revenue per customer). Align all efforts toward it.
**Relevant categories:** 73, 99

### Cobra Effect
When incentives backfire and produce the opposite of intended results.
**Application:** Test incentive structures. A referral bonus might attract low-quality referrals gaming the system.
**Relevant categories:** 78 (affiliate referral)

---

## F. Growth and scaling

Models for how marketing compounds.

### Feedback Loops
Output becomes input. Positive loops accelerate growth. Negative loops accelerate decline.
**Application:** Build virtuous cycles. More users → more content → better SEO → more users. Identify and strengthen positive loops.
**Relevant categories:** 70, 80 (product-led growth)

### Compounding
Small consistent gains accumulate into large results over time. Early gains matter most.
**Application:** Consistent content, SEO, brand-building compound. Start early.
**Relevant categories:** 70, 75

### Network Effects
Product becomes more valuable as more people use it.
**Application:** Design features that improve with more users. Shared workspaces, integrations, marketplaces, communities.
**Relevant categories:** 80, 72

### Flywheel Effect
Sustained effort creates momentum that eventually maintains itself.
**Application:** Content → traffic → leads → customers → case studies → more content. Each element powers the next.
**Relevant categories:** 70, 99

### Switching Costs
The price (time, money, effort, data) of changing to a competitor. High switching costs create retention.
**Application:** Increase switching costs ethically. Integrations, data accumulation, workflow customization, team adoption.
**Relevant categories:** 116

### Exploration vs Exploitation
Balance trying new things (exploration) with optimizing what works (exploitation).
**Application:** Don't abandon working channels for shiny new ones. Don't get stuck optimizing channels at diminishing returns.
**Relevant categories:** 70

### Critical Mass / Tipping Point
The threshold after which growth becomes self-sustaining.
**Application:** Focus resources on reaching critical mass in one segment before expanding.
**Relevant categories:** 80, 110

### Survivorship Bias
Focusing on successes while ignoring invisible failures.
**Application:** Study failed campaigns, not just successful ones. The viral hit you copy had 99 failures you didn't see.
**Relevant categories:** 70

---

## G. 2026 research: modern behavioral design

### Persuasive design evolution
Behavioral design has shifted from scattered tactics to systematic strategy. Three current threads:

1. **From triggers to context.** Fogg's B=MAP remains foundational. Modern research emphasizes that prompts alone cannot fix capability or opportunity deficits. COM-B is the more complete framework.
2. **Self-Determination Theory integration.** The most effective systems distinguish extrinsic motivators (points, badges, leaderboards, rewards) from intrinsic drivers (autonomy, competence, relatedness). Game mechanics only work when supporting intrinsic motivation; surface gamification fails fast.
3. **Systems thinking.** Behavior is shaped by feedback loops, not single triggers. A change improving this week's conversion might weaken next month's retention. Design for complete journeys, not isolated funnels.

### Streak systems and habit formation
Streaks leverage Loss Aversion + Zeigarnik + Fogg simultaneously. Effective when designed for celebration of progress, not threat of loss.

**Design principles:**
- Required actions minimal (effortless to maintain)
- Visual progress feedback clear
- Prompts at contextually appropriate timing
- Celebrate meaningful milestones
- Grace mechanisms for edge cases (one missed day doesn't wipe the streak)

**Ethical line:**
- Habit: automatic, goal-aligned, allows imperfection
- Compulsion: anxiety-driven, fear-based, punishes failure

Audit findings flag compulsion patterns as ethical risks regardless of engagement lift.

### Behavioral empathy mapping
Discovery technique for understanding psychological barriers. Map four quadrants:
1. Thinking and feeling
2. Seeing
3. Saying and doing
4. Hearing

Identify barriers (what makes behavior harder) vs enablers (what helps). Cluster insights. Feed into behavioral journey mapping.

### From-To-By-Why hypothesis framing
Transform vague ideas into testable behavioral hypotheses.

> "From [current behavior] to [target behavior], by [doing X], because of [barrier Y]."

Example: "From abandoned-cart users not returning, to abandoned-cart users completing checkout, by sending a one-hour follow-up email, because of distraction (not price objection)."

---

## Quick reference: challenge → model index

| Challenge | Models to consider |
|---|---|
| Low conversions | Hick's Law, Activation Energy, BJ Fogg, Friction reduction |
| Price objections | Anchoring, Framing, Mental Accounting, Loss Aversion |
| Building trust | Authority, Social Proof, Reciprocity, Pratfall Effect |
| Increasing urgency | Scarcity (only if genuine), Loss Aversion, Zeigarnik |
| Retention / churn | Endowment, Switching Costs, Status-Quo Bias, Peak-End |
| Growth stalling | Theory of Constraints, Local vs Global Optima, Compounding |
| Decision paralysis | Paradox of Choice, Default Effect, Nudge Theory |
| Onboarding | Goal-Gradient, IKEA Effect, Commitment & Consistency |
| Habit formation | Streaks (ethical), Loss Aversion, COM-B, Self-Determination |
| Pricing display | Charm vs Rounded, Rule of 100, Decoy, Anchoring |
| Hero copy | JTBD, Hyperbolic Discounting, Mimetic Desire, Loss Aversion |
| "Everyone" hero / no ICP focus | JTBD, ICP + anti-persona (Cat 110), Curse of Knowledge |
| No risk reversal near CTA | Regret Aversion, Loss Aversion, Status-Quo Bias |
| Hesitation to switch | JTBD Four Forces (Push/Pull/Habit/**Anxiety**), Switching Costs |

**Using this in an audit (not just for recommending).** Read the column right-to-left:
when a finding names a site problem, the model column is the **diagnostic lens you
cite** to justify the severity and the fix direction. Ground the lens in the site's
actual buyer via `references/context-file.md` (the persisted ICP / Four Forces /
verbatim customer language) rather than generic best practice. Per Cat 114's validity
note, the lens explains *why* a fix should help; whether it *does* is an A/B
hypothesis, not a claimed lift.

---

## Questions to surface when context is unclear

When the audit lacks context to recommend a specific model:

1. What specific behavior is the brand trying to influence?
2. What does the customer believe before encountering the marketing?
3. Where in the journey (awareness, consideration, decision, retention) is the surface being audited?
4. What is currently preventing the desired action?
5. Has the brand tested this with real customers, or is it cargo-culted?

These five questions get added to the discovery output when the auditor flags a finding but is unsure which model best applies.
