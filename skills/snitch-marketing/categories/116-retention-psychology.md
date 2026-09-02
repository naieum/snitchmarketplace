## CATEGORY 116: Retention psychology (activation, endowment, peak-end, exit)

Audits the parts of the marketing funnel past acquisition. Activation flow, ownership psychology, switching costs, peak-end design, cancellation handling.

A brand can pass every acquisition category and still leak customers because nothing is built to keep them.

**Boundary with snitch-ux.** This category audits the retention surfaces as **marketing artifacts**: do they exist, what do they say, is the exit as reachable as the entrance. How the confirmation screen reads to the person who just committed, and how the activation and cancellation screens sit on that user's decision path, is judged against the decision path itself — call the Skill tool with "snitch-ux" for that half. The sibling owns the confirmation screen and the paywall's choice architecture; this category owns whether the surface is there at all and what it claims.

### Pre-flight: requires a product surface

If the brand is pre-launch / pre-product (marketing site only, no actual product to retain customers on), **Skip** with reason `no product surface to audit retention against; revisit after product launches`.

If the product is a one-time purchase with no ongoing relationship (a digital download, a one-shot consulting engagement), audit only the parts that apply: activation (do they get a first win?), peak-end on the post-purchase experience, exit-of-relationship handling. Skip switching-cost and streak checks.

### Evidence required (do not skip, when product exists)

**Crawl mode + source mode:**

   - **Tooling caveat:** Steps 1-4 walk authenticated in-product flows. An audit has no account and cannot sign up, activate, or cancel on the user's behalf. Use a browser/Playwright or `WebSearch` tool IF one is present, else ask the user to paste or screenshot the signup, onboarding and cancellation screens (or grant a browser session), else **Skip-with-reason**; do not assert step counts, time-to-first-win, or what a cancellation flow offers you can't see (Rule 1).
   - Source mode is the fallback that usually works: onboarding, checklist, progress and cancellation surfaces are routes and components in the repo. Read them. Only the timed walk needs the live product.

1. Walk the signup → first-action path. Count steps, measure time-to-first-win.
2. Identify activation: what is the first moment the user gets value? Time it from signup to that moment.
3. Inspect onboarding for: peak-end design (delightful moments), goal-gradient (progress bars), commitment devices (set-up checklists, integration prompts).
4. Find the cancellation flow. Walk it. Count steps. Note what's offered (pause, downgrade, support reach-out, retention-only discount).
5. Check for streak / habit systems and audit ethics: encouragement vs pressure.
6. Identify switching costs: integrations, data accumulation, workflows the customer has built.

### Forbidden claims

- "Onboarding feels long." Time it. Cite step count. Compare against the <5min first-win bar.
- "Cancellation is rough." Walk it. Cite steps + recovery moves offered.
- "Switching costs are low." Identify what stickiness exists or doesn't. Quote the surfaces.

### Detection

Product onboarding flow + product cancellation flow + product retention surfaces (notifications, in-app prompts, lifecycle emails).

### What to Search For

**Activation:**
- Time from signup to first-win moment (under five minutes is the bar; ten is the danger zone; thirty+ is the cliff)
- Pre-filled examples, templates, or "try with sample data" options
- Forced empty-state vs guided-creation onboarding
- Quick-win surfaces ("Create your first X in 30 seconds")

**Endowment leveraging:**
- Whether customers can create / customize / save something before paying
- Trial signups that immediately let the user "own" something
- Save-state mechanisms that increase the cost of leaving

**Post-purchase dissonance (reassuring the decision after payment):**
- Order / signup confirmation surface: bare receipt vs value restated ("here's what you now have")
- What-happens-next clarity immediately after payment (timeline, first step, who to contact)
- Social proof placed after purchase ("join 4,000 teams who...") to validate the choice just made
- Welcome email tone: reassures the decision vs transaction summary only

**Peak-end moments:**
- Celebration animations on first success (confetti, "you did it!" screens)
- Surprise upgrades or unexpected value moments
- Strong endings on emails ("here's what you accomplished this week" recap)
- Cancellation flow as a final positive impression (last impression > most impressions in memory)

**Goal-gradient / progress:**
- Onboarding checklists with completion percentages
- "You're 80% set up" prompts
- Tier-progression visualizations

**Zeigarnik / open loops:**
- Incomplete-profile reminders
- "Continue where you left off"
- Abandoned-action recovery (cart, draft, project)

**Streak systems (if applicable):**
- Day-streak counters
- "Don't break your streak" copy
- Grace mechanisms for missed days (one-day forgiveness)
- The ethical line: encouragement vs punishment

**Switching costs:**
- Integrations (each one is a switching cost)
- Data accumulation over time (each customer's data history is a switching cost)
- Workflow customization (saved views, templates, automations)
- Team adoption (each additional seat adds switching cost)

**IKEA effect surfaces:**
- Customization options (workspace branding, layout choices, custom fields)
- "Build your own" features
- Templates that customers can fork and modify

**Exit / cancellation flow:**
- Pause vs cancel options
- Downgrade alternatives
- "Reach out to support" offer
- Retention-only discount offer (sparing use; over-use trains gaming the cancellation flow)
- Survey on the way out
- The tone of the cancellation confirmation (dignified > guilt-trippy)

### Actually Hurts the Marketing Surface

- **Time to first-win exceeds five minutes** with no pre-filled examples / templates. Activation Energy too high.
  Evidence required: walked-flow timing + count of required actions.
  Severity: High.

- **No endowment leveraging in trial / onboarding.** Customer cannot create or own anything until paying. Skip-the-trial pattern.
  Evidence required: trial flow walk + observation that no save-state is granted pre-payment.
  Severity: Medium.

- **Cancellation = dead exit.** Customer clicks Cancel → success page → done. No pause, no downgrade, no support outreach.
  Evidence required: cancellation flow walked + recovery options absent.
  Severity: High.

- **Post-purchase surface is a bare receipt.** Confirmation page and welcome email confirm the transaction but do nothing to reassure the decision: no value restated, no what-happens-next, no social proof. Post-purchase dissonance left unresolved becomes refunds and early churn.
  Evidence required: confirmation surface + welcome email described (or noted absent).
  Severity: Medium (High when the product has a refund window or trial-to-paid step).

- **No peak-end design on first success.** First successful action is met with a plain confirmation (no celebration, no "what's next"). Misses the cheapest possible memorable moment.
  Evidence required: first-action flow + post-action screen description.
  Severity: Medium.

- **No goal-gradient on multi-step onboarding.** Setup flows with 6+ steps and no progress indicator.
  Evidence required: step count + indicator absence.
  Severity: Medium.

- **No Zeigarnik recovery on common abandoned actions.** Carts, drafts, half-set-up profiles all just disappear. No nudge to return.
  Evidence required: abandoned-flow observation + email/in-app absence.
  Severity: Medium.

- **Streak system with punitive design.** Streak resets to zero on any miss. Aggressive "you broke your streak" copy. Pressure framing.
  Evidence required: streak rule walked + copy quoted.
  Severity: Medium (ethical risk: High if the audience is vulnerable, e.g., mental-health app).

- **Switching cost = zero by deliberate-feeling design.** Product is purely transactional with no data accumulation, no integrations, no workflow customization, and the brand is competing in a category where retention matters. Strategic gap.
  Evidence required: product feature audit + competitive context.
  Severity: Low (sometimes intentional, but worth flagging for strategic discussion).

- **Confirmshaming cancellation copy.** "No thanks, I hate saving money." "Stay because you love us, right?" Anti-pattern.
  Evidence required: cancellation copy quoted.
  Severity: High (ethical violation regardless of conversion lift).

- **Retention discount offered on first cancellation attempt.** Trains customers to cancel-to-discount. Cobra Effect: the retention tactic creates the behavior it's designed to prevent.
  Evidence required: cancellation flow + discount-offer presence in the first step.
  Severity: Medium.

### NOT a Problem

- **One-time purchase product** with no expectation of retention. Switching-cost and streak checks don't apply.
- **B2B annual contracts** where retention happens through account management, not in-product surfaces. Audit account-management touchpoints instead.
- **Genuinely transactional category** where switching is part of the value (price-comparison tools, marketplaces). Low switching cost is the product.
- **Streak systems that are off by default** (opt-in, low-stakes, celebrative tone). Streaks aren't the problem; punitive streaks are.

### Context Check

1. What is the brand's primary retention metric (DAU, weekly active, monthly active, NRR, churn rate)?
2. What is the activation milestone? The brand should be able to name it.
3. How many steps from signup to that milestone? Time the path.
4. What's the cancellation flow? Walk it.
5. Are there ethical-risk patterns (confirmshaming, dark cancellation, punitive streaks)? Flag separately from optimization findings.
6. Cross-reference Cat 114 §7 (Follow-Through & Retention) for the holistic read of the same surfaces.
7. Is the question how the confirmation, onboarding or cancellation screen *reads* to the user in the moment, rather than whether it exists and what it claims? Call the Skill tool with `snitch-ux`.

### Reference

- `references/mental-models.md` Sections B, E, F (Endowment, IKEA, Peak-End, Activation Energy, BJ Fogg, Switching Costs, Streaks)
- Cat 114 §7 for the holistic retention read
- Cat 99 (conversion-funnel-deep) for the upstream conversion funnel
- The decision-path reading of the confirmation, onboarding and cancellation screens → call the Skill tool with "snitch-ux"

### Severity tagging

- Time-to-first-win > 5 minutes with no easing pattern → High
- Cancellation flow = dead exit → High
- Confirmshaming cancellation copy → High (ethical)
- Punitive streak design (vulnerable audience) → High (ethical)
- Retention discount on first cancellation step → Medium (trains the behavior)
- No peak-end on first success → Medium
- No goal-gradient on multi-step onboarding → Medium
- Zeigarnik recovery missing → Medium
- No endowment leveraging in trial → Medium
- Switching cost = zero in retention-relevant category → Low (strategic gap)

**Fix voice:** `brand-surface-designer` (primary, for peak-end design) | `permission-marketer` (backup, for retention strategy).

### Worked fix example

> A SaaS productivity tool. Audit findings:
>
> 1. **Time-to-first-win: ~12 minutes.** Signup → email verification (~2 min) → onboarding wizard with 8 steps (~6 min) → empty workspace (no examples, no templates) → user must figure out the first action themselves (~4 min). Severity: High.
>
>     Recommended fix: Pre-fill a sample project at signup (Endowment + Activation Energy). Reduce wizard to three essential questions, defer the rest to in-app contextual prompts. Add a "Create your first task in 30 seconds" CTA on the empty workspace.
>
> 2. **Cancellation flow: two clicks to a dead exit.** Click "Cancel subscription" → click "Confirm" → success page. No pause, no downgrade, no support outreach. Severity: High.
>
>     Recommended fix: After "Cancel subscription", offer three alternatives BEFORE confirmation: (a) Pause for 30 days, (b) Downgrade to free tier (if applicable), (c) Talk to someone (one-line text field, support reaches out within a business day). The customer can still cancel; the friction is one extra step in service of recovery. Survey on the final cancellation page. Confirmation tone: dignified ("Sorry to see you go. Here's how to come back when you're ready.").
>
> 3. **No peak-end on first success.** When a user completes their first task, they see a plain checkmark and the task moves to "Done". Severity: Medium.
>
>     Recommended fix: Add a one-time celebration on the first completed task. A confetti burst, a "Your first task. Many more to come." line, an email the next day saying "Hey, you got rolling yesterday. Here's what most users do next." Peak-end is the cheapest impression-multiplier in the product.
>
> 4. **No Zeigarnik on common abandons.** If a user starts setting up a project and leaves halfway, the project disappears on next login. Severity: Medium.
>
>     Recommended fix: Save partial state. On next login, show "You started setting up [Project Name]. Continue?" Send a one-line email 24 hours later if they don't return. (Don't spam; one email, no follow-up.)
>
> All four fixes ground in the model catalog: Endowment Effect, Activation Energy (1), Peak-End Rule + dignified exit (2 and 3), Zeigarnik Effect (4). The fix narrative names the model so the customer team understands the WHY, not just the WHAT.
