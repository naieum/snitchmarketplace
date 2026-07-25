# Paywalls & Upgrade Screens

> **The ethics gate outranks everything in this file. Run it first.**
> `review-checklist.md` §10 and SKILL.md Workflow Step 3.5 come *before* any technique here —
> this file's Guardrails section is at the end, and reading top-to-bottom reaches every pressure
> technique first. A paywall is where money, urgency, and cancellation all meet, so the gate
> matters here more than anywhere else in the skill: is the total cost stated where the decision
> is made, is every countdown and scarcity claim **true**, are paid options opt-in, and is
> leaving as easy as joining? **If any answer is no, those are findings and you do not optimise
> them, whatever was asked for.** Two techniques below are actively harmful on a surface that
> failed the gate — exit-intent interception on a page whose exit is already a trap, and
> "mark the one-time offer as a moment" when the offer is the fabrication.
>
> The gate is not subject to the `lenses` config key. `lenses: persuasion` removes the clarity
> pass, never the gate.

The paywall is the only screen that makes money, and it obeys different rules than the rest
of the persuasion catalog — including one that contradicts it (sometimes *adding* friction
wins). Grounded in a study of ~3,000 production paywalls plus the tested observations of a
practitioner who has shipped 4,700+ of them. Evidence quality varies: named A/B results are
marked; single-designer observations are marked. The study's own conclusion applies: there
is no universal best paywall, only better experiments.

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

## Pricing & packaging on the screen

- **Show at most two plans**; default to the annual plan (highest lifetime value) and hide
  further options behind a "view all plans" sheet. Choice reduction applies hardest at the
  money moment.
- **Longer trials de-risk bigger plans.** In one meditation app's test of 7/14/30-day
  trials across plans, the 14-day trial on the *annual* plan won — the longer trial made
  the larger commitment feel safe.
- **Feature tables sell by loss.** A free-column/paid-column table shows what the user
  *loses* by not subscribing — loss framing in layout form, and consistently
  strong-performing.
- **Anchor the price to something already bought:** break it into weekly cost, or compare
  to a coffee / a therapy session (see anchoring in `principles.md`).
- **Show the product working:** a short video of the app in action + a tight bullet list +
  one line of social proof (rating and review count) is a proven simple layout.

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
- **Cancel asymmetry is the anti-pattern that defines the category:** one fitness
  marketplace takes 5 screens to subscribe and 17 to cancel. If the flow in is short and
  the flow out is a maze, that's a finding — regardless of what it does for churn this
  quarter.
- The metrics that matter are **retention and LTV**, not trial starts. A paywall that
  wins sign-ups from people who cancel resentfully is a loss wearing a win's clothes. The
  study's closing question is the right one: not "how do I get people to pay?" but "how do
  I make something worth paying for?"
