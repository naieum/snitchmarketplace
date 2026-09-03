# Screen / Flow Review Checklist

Run this when auditing an existing UI or before shipping a new one. For each screen, first
answer the framing question, then scan the relevant checks. Not every check applies to every
screen. Each check ends as one of three outcomes: a **Finding** (with evidence), a **Pass**
(with the evidence that it ran), or a **Skip** (with the reason). Skipping an inapplicable
check is correct and costs nothing — recording it is what turns the skip into coverage.

> **Gate first: `ethics-gate.md`.** Run it before anything below, and before you reach for a
> single persuasion technique. It outranks every check in §2, §2.5, §3 and §7, and no config
> value turns it off.

## Contents
- 0. Framing · 0.5 Clarity — is it self-evident?
- 1. Cognitive load & friction
- 2. Motivation & commitment · 2.5 Paywalls & upgrade screens
- 3. Trust & persuasion
- 4. Visual hierarchy & craft
- 5. Feedback & delight · 5.5 Destructive actions, state & recovery
- 6. Mobile & reachability
- 7. Copy pass
- 8. Goodwill
- 9. Accessibility & inclusion

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
      Does the page name match the link that led here? (See `navigation.md`.)
- [ ] Is the **Back button** safe — nothing traps the user or strands them?

## 1. Cognitive load & friction
- [ ] Any blank fields that could carry a **smart default**?
- [ ] Any decision you could pre-make, remove, or stage (**choice reduction**)?
- [ ] Any content hidden behind an unnecessary tap/banner? Any dropdown that could be open
      swatches? Any free-text that could be selectable options?
- [ ] Is advanced complexity **progressively disclosed** rather than dumped upfront?
- [ ] Does the input control **match the context** (slider for setup, stepper for frequent)?
- [ ] Recognition over recall — are you showing, not making them remember?
- [ ] Did a simplification **move complexity onto the user** instead of removing it — a
      hidden gesture as the only route, a rule the form enforces but never states, a
      "clean" screen that requires remembering what it no longer shows? Complexity is
      conserved; check who's carrying it (`principles.md` §A).

## 2. Motivation & commitment
- [ ] If users aren't acting, which of **motivation / ability / prompt** is missing? (too
      hard → cut friction; not wanted enough → strengthen reason or timing; no cue → add/time
      the prompt). Easing effort usually beats pumping motivation. **A behavior happens only
      when all three converge in the same moment**, so exactly one of them is what to fix
      (`substrate.md`, the convergence model).
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
- [ ] Is the *number* of choices at the money moment kept small — the plan set legible rather
      than a wall of tiers? Pricing **display** tactics (tier order, charm pricing, decoy
      columns, strike-through provenance, the annual-default nudge) are judged against
      merchandising rather than the user's decision path: call the Skill tool with
      "snitch-marketing" for those.
- [ ] Does the friction level match the goal (qualifying card-wall for subscriber quality
      vs. one-tap trial for volume) — or is it accidental?
- [ ] **Ethics:** run `ethics-gate.md` on this surface — a paywall is where money, urgency and
      cancellation all meet. Paywall-specific shapes: fake-urgency wheels, misleading trial
      toggles (an app-store rejection risk), and cancellation that takes more steps than
      subscribing.

## 3. Trust & persuasion
- [ ] Any number/price shown **in isolation** with no anchor (%, reference price, total)?
- [ ] Is there honest **social proof** with specific, non-round figures? A status badge to
      set the halo?
- [ ] Do you **reveal the catch** proactively (transparency), and place **reassurance** at
      the moment of hesitation (near the CTA)?
- [ ] Does the CTA name the **outcome/total** and preempt the top objection?

## 4. Visual hierarchy & craft
- [ ] Are **values emphasized over labels**? Is importance encoded in size/weight/color/position?
- [ ] In any list, menu, or step sequence: are the items that matter **first or last**, not
      buried mid-list? First and last positions are remembered and reached best; the middle
      sags (`substrate.md`, serial position). One deliberate odd-one-out for
      the thing that matters most — if everything is emphasized, nothing is.
- [ ] **Real content** shown, not decorative filler?
- [ ] Shadows soft and tinted to background? Palette limited? Type doing hierarchy work?
- [ ] Is every element earning its place (minimalism), or is there decoration for its own sake?

## 5. Feedback & delight
- [ ] Does every tap/selection have a clear, satisfying **state change**?
- [ ] Do values/consequences update **live** (new total/balance shown immediately)? Does the
      response land fast enough to feel conversational (~400ms), and is any longer wait
      **acknowledged** — skeleton, optimistic update, determinate progress — rather than a
      silent pause? (`substrate.md` Part 2 has the thresholds.)
- [ ] Does the flow **end on purpose**? People judge the whole experience by its worst
      moment and its ending — so the last screen is designed (a success state that confirms
      what happened and offers the next step), not just where the clicking stopped; and the
      worst moment (the error, the wait, the payment) gets the most design attention, not
      the least. A flow that works but just trails off is leaving its memory to chance.
- [ ] Is the **empty state** a CTA, not a dead end?
- [ ] Does **search** offer suggestions on focus?
- [ ] Is the experience **personalized** (name, lifecycle stage) where it can be?

## 5.5 Destructive actions, state & recovery (settings, admin, anything that deletes)

The failure modes of a working surface. Most of this file is written for surfaces that sell;
these are the ones that break surfaces that *do*. See `substrate.md` Part 2 for the underlying
model — slips vs. mistakes, constraints over warnings, and the gulf of evaluation.

- [ ] **Is the guard proportionate to the damage?** Match friction to reversibility, not to how
      scary the word sounds: reversible → do it, offer undo; slow to reverse → confirm; genuinely
      irreversible → a typed check or an equivalent constraint. A bare `onclick` that destroys
      data immediately is the Critical case in `finding-rules.md`'s severity rubric.
- [ ] **Does the confirmation name the blast radius?** "Are you sure?" tells the user nothing.
      Name what is destroyed, how much of it, and who else is affected — "permanently deletes this
      channel and its 4,200 messages for all 31 members." A confirmation that does not state the
      consequence is a speed bump, not a safeguard.
- [ ] **Is there an undo, and is undo the better answer than a dialog?** Undo beats confirmation
      for anything you can hold briefly — it costs the user nothing when they meant it. Check for
      a soft-delete or grace window before accepting a modal as the fix.
- [ ] **Can the user read the current state?** A control must say what it is *now*, not just what
      it does. Watch for negated labels ("Disable notifications" + a checked box), toggles whose
      polarity is ambiguous, and values that don't say whether they are the shipped default or
      this user's saved choice. If the reviewer cannot tell, neither can the user —
      state it as a finding, and say in Confidence which reading you could not resolve.
- [ ] **When does a change commit, and what confirms it?** Auto-save, explicit save, and
      save-on-blur all need a visible answer. On an auto-saving page, what does "Cancel" mean?
      Does the save notice actually cover the controls the user just touched, or only the block it
      sits in?
- [ ] **Does one user's action land on other people?** Shared workspaces, team plans, and admin
      settings change things for people who are not on the screen. Say who else is affected and
      whether they are told.
- [ ] **Does the failure path go anywhere?** An error code with no recovery route, a message
      announced to nobody (4.1.3), or a dead end after a failed destructive action leaves the
      user stuck at the worst possible moment. Explain what happened, why, and how to recover —
      without blaming them.

## 6. Mobile & reachability (if applicable)
- [ ] Primary actions inside the **thumb zone**; tap targets **44–48px** — 44pt (Apple HIG,
      and WCAG 2.2 AAA 2.5.5) to 48dp (Material). **24×24 CSS px is the conformance floor**
      (WCAG 2.2 AA, 2.5.8): passing, not comfortable — design to 44–48.
      **Check 2.5.8's exceptions before filing a failure below 24.** Spacing (a 24px-diameter
      circle centred on the target's bounding box intersects no other target, nor another
      undersized target's circle — it may overlap non-target content freely), Inline targets inside a sentence, an
      Equivalent control elsewhere on the page, **User-agent sizing** — a browser-default
      control the author never restyled is not an authored failure — and Essential
      presentation. An unstyled checkbox or radio is the common false positive here.
- [ ] Bottom nav: **3–5 tabs**, **≥2 active-state cues** (ideally incl. filled icon/pill),
      **separated from content**, **neutral colors**, **familiar single-line-labelled icons**,
      badges only where essential. (See `navigation.md`.)

## 7. Copy pass
- [ ] Run CTAs & microcopy through `copywriting.md`: specific numbers, possessive "my",
      right-stakes verb, conversational tone, objection preempted, needless words omitted.
- [ ] **Build the sentence like a control** — length caps, active voice, one idea per sentence,
      no stacked hedges, no banned filler; strict mode for microcopy, flavored for brand voice
      (`writing-system.md`, scored by `scripts/copy-lint.py`).
- [ ] **Brand-level surfaces only** (home hero, tagline, value prop, pricing, onboarding):
      does the message open with the *customer's problem* — not the company, category, or
      backstory? Is there one **controlling idea** a visitor could repeat back? Is the hero
      doing curiosity's job (make them say "tell me more"), not education's? Does the header
      weigh **zero pounds** of cognitive load, and does the page pass the **5-second test**
      (what problem? what's life after? how do I buy?) and the **Sharpie test** (10+ problem
      mentions)? (See `brand-message.md`.)
- [ ] **Taglines:** does the tagline survive the name-strip and stranger-guess tests? Is the
      CTA direct ("Buy now" / "Schedule a call"), never "Learn more"? (See
      `brand-message.md`.)

## 8. Goodwill — does it do right by the user?
- [ ] Are the things people want up front (price, shipping/fees, support contact) visible,
      not hidden? **Judge each against the decision this surface asks for, and only against a
      surface that could carry it.** Price and fees belong wherever the user commits, so a
      missing or late cost is a finding at the CTA. A support path is owed where support is
      the user's next step — inside the product, at checkout, on a help or contact surface —
      not on every marketing page that hands off to a sign-up or login flow. A page that
      mentions its support standard without linking a contact form is a Pass unless the
      visitor's task on *this* page is to reach a human. "Hidden" means present-but-buried or
      disclosed too late, not "lives on the surface that owns it."
- [ ] Are you asking only for what you need — no giant required form, no needless optional
      fields, no fussy input formatting you could just parse?
- [ ] Any sizzle (splash screen, forced intro, slow animation) delaying someone in a hurry?
- [ ] When something goes wrong or you inconvenience the user, do you tell them plainly /
      apologize? (See the reservoir of goodwill in `clarity.md`.)

## 9. Accessibility & inclusion (see `inclusive-design.md`)
Plain language first, WCAG 2.2 criterion number after it — so a finding is conformance, not
opinion. These are criteria an AA target has to meet; most are Level **A** and the rest AA, with
the one marked AAA (2.3.3) included as the design target rather than the floor. Quote the
criterion number, not a level, unless you have checked the level.

**Run the first seven on every surface** — alt text and labels, keyboard, skip link, contrast,
single-channel meaning, viewport and reflow, `lang` and landmarks and focus. **The rest are
conditional and task-blocking**: check each only if the surface has the thing it governs (a real
control behind a click handler, an error message, a repeated field, an auth step, a drag
interaction). **Record every conditional check by name as Finding, Pass, or Skip** — "§9
conditionals: drag n/a (no drag interaction), auth n/a (no sign-in on this surface)" is
coverage; silence is not distinguishable from not having looked.

**What this list is judged against:** whether *this person can finish the task*. Conformance
pass-fail across a whole site, legal exposure (EAA / ADA), and an audit graded against a
Lighthouse accessibility score are evidenced against something else — call the Skill tool with
"snitch-ada" for those. The same fact can be a finding in both skills; the judge is what
differs.

**The criterion number is a locator, not a verdict.** It tells a reader where to look up the
rule; it is never the cost. Before writing any §9 finding, name the person and the task it
stops: who is blocked, at which step, with what left as their route. **If the only cost you can
state is "it fails the criterion," it is not a ux finding** — record it as a Pass or a Skip
with one line saying conformance is snitch-ada's judge, and move on. This is where §9
padding comes from: a criterion the surface technically misses while every user still finishes
the task is a conformance result wearing a barrier's clothes.

**Always, on every surface:**
- [ ] Alt text on every image (empty for decorative); form fields tied to `<label>`s.
      (1.1.1 Non-text Content, 3.3.2 Labels or Instructions)
- [ ] Usable by keyboard; text resizes without breaking. (2.1.1 Keyboard, 1.4.4 Resize Text)
- [ ] A **"skip to main content" link where the repeated block is long enough to trap someone**
      — a header, nav, or sidebar of roughly ten or more tab stops that a keyboard user has to
      cross on every page to reach the content. (2.4.1 Bypass Blocks) On a short header — a
      logo and two or three links — the tab cost is a second, nobody is blocked, and a missing
      skip link is a **Pass, not a finding**; the conformance view of it belongs to
      snitch-ada. Count the tab stops before you write this one up.
- [ ] Contrast: **4.5:1 for normal text, 3:1 for large text** (≥24px, or ≥18.5px bold) **and
      for UI components and meaningful graphics** — icons, input borders, focus rings, chart
      strokes. (1.4.3 Contrast (Minimum), 1.4.11 Non-text Contrast)
      **How to get a ratio from a hex value**, so this is evidence and not "looks a bit light":
      for each channel take `c = value/255`, then `c <= 0.04045 ? c/12.92 : ((c+0.055)/1.055)^2.4`;
      luminance `L = 0.2126R + 0.7152G + 0.0722B`; ratio `= (Llighter + 0.05) / (Ldarker + 0.05)`.
      Two anchors worth memorising rather than a lookup table: `#767676` ≈ 4.54:1 is the lightest
      grey that passes on white, and `#949494` ≈ 3.0:1 is the large-text floor. Anything lighter
      than `#767676` behind normal-size text misses AA — compute the actual ratio and quote it. Quote the computed ratio and
      the two colors in the Evidence — "`color:#8e8e8e` on `#fff` ≈ 3.2:1 against a 4.5:1 requirement"
      is checkable; "low contrast" is not. Light grey small text is the standard way a cost
      disclosure gets buried, so this arithmetic often *is* the finding.
      **Missing the threshold is not automatically a ux finding — read the computed ratio
      against what it costs the reader.** At or under **3:1** for normal text, people with
      low vision cannot read it: that is a barrier, and a finding, every time. **Between 3:1
      and 4.5:1** the text is legible to most readers, so it is a ux finding only when
      something else compounds it — small or thin type, a cost or consent disclosure, an
      error message, a high-stakes surface, or a missing viewport tag that shrinks it further.
      Absent one of those, a near-miss ratio on ordinary body copy is a **conformance result,
      not a barrier**: record it as a Pass with the ratio quoted and hand the conformance
      sweep to snitch-ada. Do not open a Medium on 4.4:1 body text that everyone on the
      page can read.
- [ ] Meaning never carried by color/sound/motion alone; source order = reading order;
      reduced-motion respected. (1.4.1 Use of Color, 1.3.2 Meaningful Sequence,
      2.3.3 Animation from Interactions, AAA)
- [ ] **Renders on a phone at all.** `<meta name="viewport" content="width=device-width,
      initial-scale=1">` present; no fixed pixel widths that force horizontal scrolling; content
      reflows at 320px CSS width without a second scroll direction; pinch-zoom not disabled
      (`user-scalable=no` / `maximum-scale=1` are failures). (1.4.10 Reflow, 1.4.4 Resize Text)
      Check this *before* rating any small-text or small-target finding: without the viewport tag
      a mobile browser lays out at ~980px and scales down, so 9px text renders nearer 3px and an
      already-marginal tap target becomes unhittable. It escalates several findings by a band at
      once, so establish it first. (Escalates — it does not automatically make them Critical:
      small targets and hard-to-read text are barriers, which `finding-rules.md`'s rubric rates
      Medium by default, High when they actually stop someone finishing, and Critical only when
      they leave no route at all.)
- [ ] `<html lang>` set; landmark elements (`header`, `nav`, `main`) present so screen-reader
      users can skip; focus is visible on every interactive element.
      (3.1.1 Language of Page, 1.3.1 Info and Relationships, 2.4.7 Focus Visible)

**Conditional — run each only if the surface has the thing, and record the ones you skipped:**
- [ ] Anything with an `onclick` is a real control: a `<button>` or `<a href>`, not a `<span>`
      or `<div>`. A click handler alone gives no keyboard focus, no Enter/Space activation, and
      no announced role — the element simply does not exist for keyboard and screen-reader
      users. (2.1.1 Keyboard, 4.1.2 Name, Role, Value)
- [ ] **Every error names the field and the problem, in text.** Not color or position alone —
      "Enter a valid email address," tied to the field it is about. A floating word or a red
      border is not an error message. (3.3.1 Error Identification)
- [ ] **Never ask twice for what the user already gave.** Email, address, code, card — inside
      one flow it must be auto-filled or selectable, not retyped. This is the same rule as
      "smart defaults, never a blank form" (§1), now a conformance requirement.
      (3.3.7 Redundant Entry)
- [ ] **Sign-up and login don't demand a cognitive-function test.** No memorizing, no
      transcribing, no puzzle, with no way around it; paste and password managers work; if a
      test is unavoidable, offer an alternative method or a mechanism that assists.
      (3.3.8 Accessible Authentication (Minimum))
- [ ] **Nothing works only by dragging.** Reorder, slider, swipe-to-delete, map pan, drag-
      to-upload each need a single-pointer alternative (tap, buttons, menu, field).
      (2.5.7 Dragging Movements)

**Inclusion — judgement, not a criterion number:**
- [ ] Plain language, short sentences — works for low literacy, a second language, stress,
      or cognitive load, not just a focused native reader?
- [ ] No unstated cultural assumption — reading direction, color/symbol meaning, name/date/
      currency formats, translated-text length?
- [ ] Would it still work for someone with half the attention, vision, motor control, or
      context you assumed?

*This list is a starter set covering what this skill's own subject matter touches most often —
it is not the whole of WCAG, and it is deliberately narrower than a conformance audit. Where a
surface does something these items don't reach, go to the criterion rather than assuming silence
means pass, or hand the conformance sweep to snitch-ada. Criteria this list no longer
carries but a full pass would: machine-readable field purpose (1.3.5), status messages (4.1.3 —
§5.5 covers the failure-path case), focus not obscured (2.4.11), error prevention on
consequential submissions (3.3.4 — §5.5 covers the guard), content on hover (1.4.13), headings
and labels (2.4.6), images of text (1.4.5), consistent help (3.2.6), keyboard traps in modals
(2.1.2), session timeouts (2.2.1), unexpected changes on focus or input (3.2.1 / 3.2.2),
orientation locking (1.3.4), text spacing (1.4.12), and sensory-only instructions (1.3.3).*
