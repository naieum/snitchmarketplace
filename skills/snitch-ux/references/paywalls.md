# Paywalls & Upgrade Screens

> Gate first: `ethics-gate.md`. A paywall is where money, urgency and cancellation all meet, so
> the gate matters here more than anywhere else in the skill. Two techniques below are actively
> harmful on a surface that failed it — exit-intent interception on a page whose exit is already
> a trap, and "mark the one-time offer as a moment" when the offer is the fabrication.

The paywall asks for a financial commitment, and can behave differently from the rest
of the persuasion catalog — including one that contradicts it (sometimes *adding* friction
wins). Grounded in a study of ~3,000 production paywalls plus the tested observations of a
practitioner who has shipped 4,700+ of them. Evidence quality varies: named A/B results are
marked; single-designer observations are marked. The study's own conclusion applies: there
is no universal best paywall, only better experiments.

Treat the examples and reported lifts below as historical hypotheses, not expected outcomes
for this product. No missing timeline, card wall, wheel, trial or multi-page sequence is a
Finding by itself. Judge demonstrated confusion, hidden commitment or blocked completion;
do not add friction merely to match an anecdote. Generated claims require this product's
evidence, and all material costs and terms must precede commitment (`finding-rules.md`).

## The paywall is a flow, not a screen

Users often decide to pay *before* the paywall. The selling happens across onboarding; the
paywall just collects the decision.

- **Sell the outcome first.** One habit app spends onboarding quantifying the user's stake
  ("get 8 years of your life back") before showing any price — trial sign-ups went from 7%
  to 17%. By the time the paywall appears it reads as the natural next step ("your plan is
  ready"), not an interruption.
- **Multi-page beats single-page** (practitioner claim, consistent across their tests):
  information unfolds in steps — outcome, plan, social proof, then price — giving the user
  time to process instead of absorbing one dense screen.
- **Placement is lifecycle-wide.** Post-onboarding (strongest — ties to the user's stated
  goal), premium-feature unlock, settings, and win-back before churn. Later placements can
  be personalized with what the user has already done, and personalized placements convert
  better.

## Risk reduction beats pressure

The two silent hesitations at the pay moment are "will I forget to cancel?" and "is this the
right decision?" The best-performing interventions answer them structurally:

- **The trial timeline.** One reading app's users felt tricked by trial charges; replacing
  the pitch with a step-by-step timeline (today: full access → day 5: we remind you →
  day 7: charged) increased trial sign-ups, cut complaints, *and raised push-notification
  opt-in* — because the reminder became part of the promise.
- **"No commitment · cancel anytime"** as the CTA subtitle reliably nudges conversion up
  (practitioner observation across many tests).
- **Exit-intent downsell:** when the user moves to dismiss, offer the smaller commitment
  (monthly instead of annual) rather than losing them.
- **Prefer a longer trial to a bigger discount** for last-minute offers — same risk
  reduction, no price-integrity damage, and no app-review exposure (see guardrails below).

## Friction is a dial, not a sin

Two opposite moves both "work" — the audit question is which metric the screen should
optimize:

- **Qualifying friction:** requiring a card up front halved one app's trial sign-ups but
  multiplied paid conversion 5× and more than doubled paying customers — the friction
  filtered out users who were never serious. Trial-only-on-annual is the same filter.
- **Removing the wall:** another app replaced its paywall with a single "Redeem your free
  week" action — trial starts +25%.

Flag a mismatch, not a pattern: an app that needs subscriber quality running a
zero-friction wall, or an app that needs top-of-funnel volume running a card-wall.

## Packaging and price display — not this file's judge

How the plans are *merchandised* — tier order and count, charm pricing, a decoy column,
strike-through provenance, the annual-default nudge, loss-framed feature tables — is judged
against merchandising and traffic rather than against this user's decision path. **Call the
Skill tool with "snitch-marketing"** for that half. The *ethics* of pricing stays here and in
`ethics-gate.md`: whether the cost is stated where the decision is made, whether a "was" price
was ever charged, whether paid options are opt-in.

Two packaging-adjacent findings do belong to this file, because they are risk reduction rather
than merchandising:

- **Longer trials de-risk bigger plans.** In one meditation app's test of 7/14/30-day trials
  across plans, the 14-day trial on the *annual* plan won — the longer trial made the larger
  commitment feel safe.
- **Show the product working:** a short video of the app in action + a tight bullet list +
  one line of social proof (rating and review count) is a proven simple layout.

And one clarity finding: at the money moment, a wall of near-identical tiers is choice overload
in its most expensive place. Flag the *legibility* of the plan set; leave the ordering and the
price formatting to marketing.

## Micro-details worth testing (practitioner observations, not laws)

- A right-pointing chevron on the CTA button shows up on a disproportionate share of
  winning paywalls (untested in isolation — the practitioner says so themselves).
- CTA labeled with the action/outcome instead of "Continue" — hit or miss; test it.
- Animation + haptic feedback to mark a one-time offer as a moment.
- Radical redesigns beat micro-tweaks: "design tests move the needle the most" — test a
  video paywall against a table against a timeline against long-form, not button colors.
  Dense, "ugly" paywalls sometimes beat beautiful ones; the study cites two such cases.

## Guardrails (paywall-specific dark patterns)

- **Spin-the-wheel discounts and fake-urgency offers convert and corrode.** They train
  users to dismiss paywalls to fish for offers, saturate fast, and import
  dropshipping-store trust levels into your product. Long-term brands should skip them
  even though they test well short-term.
- **Platform risk is now real:** app-store review has begun rejecting misleading
  trial-toggle patterns; confusing paywall mechanics are a rejection risk, not just a
  trust cost.
- **Cancel asymmetry is the anti-pattern that defines the category:** the reported worst cases
  take a handful of screens to subscribe and several times that to cancel. Count the steps in
  each direction on the surface in front of you — if the flow in is short and the flow out is a
  maze, that's a finding, regardless of what it does for churn this quarter.
- The metrics that matter are **retention and LTV**, not trial starts. A paywall that
  wins sign-ups from people who cancel resentfully is a loss wearing a win's clothes. The
  study's closing question is the right one: not "how do I get people to pay?" but "how do
  I make something worth paying for?"
