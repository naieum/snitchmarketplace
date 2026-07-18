# Screen / Flow Review Checklist

Run this when auditing an existing UI or before shipping a new one. For each screen, first
answer the framing question, then scan the relevant checks. Not every check applies to
every screen — skip what's irrelevant, flag what's violated with a concrete fix.

## Contents
- 0. Framing · 0.5 Clarity — is it self-evident?
- 1. Cognitive load & friction
- 2. Motivation & commitment · 2.5 Paywalls & upgrade screens
- 3. Trust & persuasion
- 4. Visual hierarchy & craft
- 5. Feedback & delight
- 6. Mobile & reachability
- 7. Copy pass
- 8. Goodwill
- 9. Accessibility & inclusion
- 10. Ethics gate (blocking)

## 0. Framing (always)
- [ ] What single question is this screen asking the user? Is it the *easy* version of that
      question, or a hard one you could reframe?
- [ ] What's the one primary action? Is it unmistakably the most prominent thing?

## 0.5 Clarity — is it self-evident? (do this before the rest)
- [ ] Would an average first-time user "get it" at a glance — what this is and what to do —
      without thinking? Any leftover **question marks** (*is that a link? what's this label?
      where am I?*)?
- [ ] Does it survive **scanning** — clear visual hierarchy, defined page areas, few words —
      not just careful reading?
- [ ] Is it **obvious what's clickable**? Buttons look like buttons, links like links?
- [ ] Are you **using conventions** where one exists, or reinventing the wheel without a
      clearly-better reason?
- [ ] Any needless words to cut — **happy talk**, **instructions** for things that should be
      self-explanatory? (See `copywriting.md`.)
- [ ] **Navigation parachute test:** on a deep page, can you instantly answer — what site is
      this, what page am I on, what are the sections/options, where am I, how do I search?
      Does the page name match the link that led here? (See `site-navigation.md`.)
- [ ] Is the **Back button** safe — nothing traps the user or strands them?

## 1. Cognitive load & friction
- [ ] Any blank fields that could carry a **smart default**?
- [ ] Any decision you could pre-make, remove, or stage (**Hick's Law**)?
- [ ] Any content hidden behind an unnecessary tap/banner? Any dropdown that could be open
      swatches? Any free-text that could be selectable options?
- [ ] Is advanced complexity **progressively disclosed** rather than dumped upfront?
- [ ] Does the input control **match the context** (slider for setup, stepper for frequent)?
- [ ] Recognition over recall — are you showing, not making them remember?

## 2. Motivation & commitment
- [ ] If users aren't acting, which of **motivation / ability / prompt** is missing? (too
      hard → cut friction; not wanted enough → strengthen reason or timing; no cue → add/time
      the prompt). Easing effort usually beats pumping motivation.
- [ ] Any progress indicator that starts at **0%** instead of a head start?
- [ ] For sign-up/commitment: do users **build/own something first** (endowment)? Is the CTA
      "Continue/Start my…" rather than "Sign up"?
- [ ] Is anything framed as a **gain** that would be stronger as avoiding a **loss** (if true)?
- [ ] Do you deliver **value before the ask** (reciprocity), or gate everything behind a wall?

## 2.5 Paywalls & upgrade screens (when the surface sells a subscription — see `paywalls.md`)
- [ ] Is the outcome sold *before* the price appears (onboarding → "your plan is ready" →
      paywall), or does the wall interrupt cold?
- [ ] Are the two silent fears answered structurally — a **trial timeline** (what happens
      day by day) and a **"cancel anytime"** line at the CTA?
- [ ] Two plans max, annual default, rest behind "view all plans"? Price anchored to
      something already bought?
- [ ] Does the friction level match the goal (qualifying card-wall for subscriber quality
      vs. one-tap trial for volume) — or is it accidental?
- [ ] **Ethics:** no fake-urgency wheels or misleading trial toggles (app-store rejection
      risk); is cancellation as short a path as subscribing?

## 3. Trust & persuasion
- [ ] Any number/price shown **in isolation** with no anchor (%, reference price, total)?
- [ ] Is there honest **social proof** with specific, non-round figures? A status badge to
      set the halo?
- [ ] Do you **reveal the catch** proactively (transparency), and place **reassurance** at
      the moment of hesitation (near the CTA)?
- [ ] Does the CTA name the **outcome/total** and preempt the top objection?

## 4. Visual hierarchy & craft
- [ ] Are **values emphasized over labels**? Is importance encoded in size/weight/color/position?
- [ ] **Real content** shown, not decorative filler?
- [ ] Shadows soft and tinted to background? Palette limited? Type doing hierarchy work?
- [ ] Is every element earning its place (minimalism), or is there decoration for its own sake?

## 5. Feedback & delight
- [ ] Does every tap/selection have a clear, satisfying **state change**?
- [ ] Do values/consequences update **live** (new total/balance shown immediately)?
- [ ] Is the **empty state** a CTA, not a dead end?
- [ ] Does **search** offer suggestions on focus?
- [ ] Is the experience **personalized** (name, lifecycle stage) where it can be?

## 6. Mobile & reachability (if applicable)
- [ ] Primary actions inside the **thumb zone**; tap targets **≥ 44×44px**.
- [ ] Bottom nav: **3–5 tabs**, **≥2 active-state cues** (ideally incl. filled icon/pill),
      **separated from content**, **neutral colors**, **familiar single-line-labelled icons**,
      badges only where essential. (See `mobile-navigation.md`.)

## 7. Copy pass
- [ ] Run CTAs & microcopy through `copywriting.md`: specific numbers, possessive "my",
      right-stakes verb, conversational tone, objection preempted, needless words omitted.
- [ ] **Brand-level surfaces only** (home hero, tagline, value prop, pricing, onboarding):
      does the message open with the *customer's problem* — not the company, category, or
      backstory? Is there one **controlling idea** a visitor could repeat back? Is the hero
      doing curiosity's job (make them say "tell me more"), not education's? Does the header
      weigh **zero pounds** of cognitive load, and does the page pass the **5-second test**
      (what problem? what's life after? how do I buy?) and the **Sharpie test** (10+ problem
      mentions)? (See `brand-messaging.md`.)
- [ ] **Taglines & names:** does the tagline survive the name-strip and stranger-guess
      tests? Is the CTA direct ("Buy now" / "Schedule a call"), never "Learn more"? (See
      `taglines-and-naming.md`, `messaging-campaign.md`.)

## 8. Goodwill — does it do right by the user?
- [ ] Are the things people want up front (price, shipping/fees, support contact) visible,
      not hidden?
- [ ] Are you asking only for what you need — no giant required form, no needless optional
      fields, no fussy input formatting you could just parse?
- [ ] Any sizzle (splash screen, forced intro, slow animation) delaying someone in a hurry?
- [ ] When something goes wrong or you inconvenience the user, do you tell them plainly /
      apologize? (See the reservoir of goodwill in `clarity.md`.)

## 9. Accessibility & inclusion (see `inclusive-design.md`)
- [ ] Alt text on every image (empty for decorative); form fields tied to `<label>`s.
- [ ] Usable by keyboard; a "skip to main content" link; text resizes without breaking.
- [ ] Sufficient contrast; meaning never carried by color/sound/motion alone; source order =
      reading order; reduced-motion respected.
- [ ] Plain language, short sentences — works for low literacy, a second language, stress,
      or cognitive load, not just a focused native reader?
- [ ] No unstated cultural assumption — reading direction, color/symbol meaning, name/date/
      currency formats, translated-text length?
- [ ] Would it still work for someone with half the attention, vision, motor control, or
      context you assumed?

## 10. Ethics gate (blocking)
- [ ] Every loss frame, countdown, scarcity, and social-proof number reflects something
      **true**. No fake reviews, fake scarcity, or buried cancellation. Would the user
      thank you if they saw how this was built? If not, change it.
- [ ] **Vulnerable / high-stakes check:** if the user could be a child, an elder, or someone
      in crisis/illness/financial distress — or the decision touches health, money, safety,
      or is hard to undo — is persuasion **dialed down** (no urgency/scarcity/variable-reward),
      with honest defaults and an exit as easy as the yes? (`inclusive-design.md`.)
- [ ] **Honest measurement:** if you'll judge this by a metric, does that metric only improve
      when the *user* is better off — not a vanity number a dark pattern could lift while
      goodwill drains? (`usability-testing.md`.)
