# Principle Catalog

> Gate first: `ethics-gate.md`. This is the file SKILL.md calls the loaded tool: applied to a
> surface that failed the gate, several of these principles make the page measurably worse.
> If the gate failed, the finding is the dishonesty, not the wording.

Each entry: **the rule**, *why it works* (the psychology), and concrete **Do / Don't**.
Grouped by the job it does. Apply the few that fit the surface — not all at once.

These are the *actionable* moves; the cognitive mechanisms they draw on (System 1/2,
anchoring, loss aversion, working-memory limits, social imitation, dopamine/variable
reward) live in `substrate.md`. When a principle here needs justifying, or a
case isn't covered, reason up from that file.

---

## Contents
- A. Reduce the thinking (cognitive load)
- B. Create motivation & commitment
- C. Persuade & build trust
- D. Direct attention (visual hierarchy)
- E. Feedback, personalization & delight
- F. Conversation & framing (meta)

## A. Reduce the thinking (cognitive load)

### Smart defaults
**Rule:** Offer a known, appropriate, reversible default when it helps the task. Leave a field
blank when its value is unknown or requires an explicit choice. Do not guess identity,
sensitive information, paid add-ons, or consent; popularity is not permission.
*Why:* most users never change a default and read it as a recommendation ("this is what
most people pick"). The effect is large and well-replicated across very different contexts
— retirement enrollment, organ-donor registration, privacy and cookie settings, app
permissions — but the exact share that sticks depends on the population and on how
consequential and reversible the default is, so treat it as a strong tendency, not a fixed
number. A blank form is a pile of decisions → decision fatigue → no choice → they leave.
- **Do:** pre-fill dates/quantities/options; show the pre-filled state as "scan & adjust,"
  not "fill from scratch"; let the primary button preview the result ("Show 12 results,"
  not "Search").
- **Don't:** present five empty fields when sensible defaults exist.

### Choice reduction
**Rule:** More options means harder, not better. Reduce, group, or stage choices; one
clear primary action per screen.
*Why:* the classic jam study found 3% of shoppers who stopped at a 24-jam display bought,
versus ~30% at a 6-jam display — though the larger display drew more people to stop in the
first place, and the wider choice-overload literature does not replicate reliably. It shows up
when options are hard to tell apart, the task is complex, or the user has no formed preference,
and washes out otherwise. Treat "fewer options" as a move that works on a genuinely confusing
choice, not as a law. (Hick's Law proper is about *reaction time* rising with option count, not
about whether people buy — don't cite it for conversion.)
- **Do:** limit visible choices; use a recommended/"most popular" pick to collapse the decision.
- **Don't:** show every option with equal weight and let the user sort it out.

### Reduce interaction cost
**Rule:** Every unnecessary action you remove improves the experience. Fewer steps to value.
*Why:* friction compounds; each tap is a chance to drop off.
- **Do:** expose content directly (not behind a banner/extra tap); offer tappable common
  options instead of free-text (+ an "other" escape hatch); show choices as open swatches,
  not dropdowns (a dropdown makes users click just to see basic options).
- **Do:** count *travel*, not just steps — time-to-target grows with distance and shrinks
  with size, so put the next action where the pointer or thumb already is, make
  frequently-paired controls adjacent (the field and its submit, the item and its primary
  action), and give the important target the big hit area. Big-and-near beats
  small-and-far; a confirmation flung to the opposite corner of the screen is a tax on
  every single use.
- **Don't:** add a step "for cleanliness" that costs the user a tap.

### Complexity is conserved — decide who carries it
**Rule:** Every task has a floor of complexity that cannot be removed, only moved. The
design choice is *who absorbs it*: the system, or the user.
*Why:* "simplifying" a screen by deleting the control doesn't delete the need — it relocates
the work into the user's head (a memorized gesture, a magic default they must guess, a
convention that lives nowhere on screen). The complexity bill always gets paid; good design
pays it on the system side once, instead of charging every user on every use.
- **Do:** absorb complexity with smart defaults, inference, and remembered state (the
  address parsed from a paste, the account it almost certainly means); when you
  progressively disclose, make sure the disclosed path still *exists* and is findable.
- **Don't:** ship minimalism that pushes the floor below what the task needs — an
  undiscoverable swipe as the only route, a "clean" form that fails opaquely because the
  rule it enforces is invisible. If users must learn a hidden rule to succeed, the design
  didn't get simpler; the user got the job.

### Progressive disclosure
**Rule:** Keep the initial interface clean; reveal advanced/extra options only when asked.
*Why:* upfront complexity overwhelms; a click is cheap and signals intent.
- **Do:** hide power-user settings behind "More options"; reward the click with real value
  (e.g., extra money-saving tiers appear after the user engages).
- **Don't:** dump every control on the first screen.

### Recognition over recall
**Rule:** Let users recognize instead of remember.
*Why:* recognition is far lower-effort than recall and prevents errors.
- **Do:** show profile photos/logos/icons, recent items, and clear source/target labels so
  the user never has to remember an id, code, or which account.
- **Don't:** force users to recall specifics you could display.

### Match input to context
**Rule:** Choose the input control by how the value is used, not just its data type.
*Why:* casual one-time inputs and frequent precise inputs want different affordances.
- **Do:** sliders / scroll-wheels / pickers for one-time low-stakes setup (age, height);
  steppers / number fields for frequent, precise, repeated entry (quantities, amounts).
- **Don't:** make a daily precise task a slider, or a one-time casual setup a keyboard chore.

---

## B. Create motivation & commitment

### Goal-gradient / honest progress
**Rule:** Show meaningful progress and the remaining work accurately.
*Why:* a visible next step can make an unfinished task easier to resume. A granted loyalty
bonus is not the same as falsely reporting completed work.
- **Do:** count completed steps against a clear denominator; label any granted bonus as a
  bonus. An untouched task can correctly start at 0%.
- **Don't:** inflate completion, change the denominator to manufacture momentum, or file a
  Finding just because a truthful meter is empty.

### Endowment / build-it effect
**Rule:** Let users build, choose, or customize *before* you ask for commitment.
*Why:* people value what they helped make; even just *feeling* ownership is enough
(endowment effect). Once they've invested effort, leaving feels like abandoning something
theirs.
- **Do:** let them pick name/goal/style/first item pre-signup; label the button "Continue,"
  not "Sign up"; use possessive "my."
- **Don't:** open with "email / password / sign up" before they've created anything.

### Loss aversion & status-quo bias
**Rule:** Explain real consequences when relevant; do not manufacture stakes for declining.
*Why:* potential loss can influence a decision, but its effect varies by context and person.
- **Do:** state what will be lost and when, with evidence, alongside a neutral exit action.
- **Don't:** use "I'll risk it" as a default improvement, imply an unproven loss, or shame a
  refusal. Necessary factual warnings are different from pressure to convert.

### Commitment & consistency
**Rule:** Surface the small decision the user already made so the remaining choice shrinks.
*Why:* people act consistently with prior commitments; a big decision reframed as a small
follow-on gets made.
- **Do:** "You're going to X — which option?" instead of "should you go at all?"

### Reciprocity
**Rule:** Give real, useful value *before* asking for anything.
*Why:* receiving creates an unconscious debt — ranked among the strongest drivers of
behavior. Free samples can lift purchases dramatically.
- **Do:** show a genuinely useful partial result, then ask ("Save your full report");
  offer a real trial/sample before the wall.
- **Don't:** blur the result and demand signup before delivering any value (results walled
  off before you've given anything = users leave).

---

## C. Persuade & build trust

### Anchoring / contrast effect
**Rule:** Make price, units, total commitment and relevant comparisons clear. A single price
can be sufficient; an anchor is optional, not a Finding condition.
*Why:* comparison can help when the user is choosing between materially different offers.
- **Do:** use verified comparisons when useful and retain the actual total and billing term.
  Preserve ranges when the final price genuinely varies; explain what determines it.
- **Don't:** invent a reference price, discount, annual plan or savings claim. Do not make
  a large commitment look small by replacing its total with a per-day equivalent.

### Decoy & the power of free
**Rule:** People judge options against the nearest comparison, and treat "free" as a
category of its own.
*Why:* a deliberately weaker third option makes the target look like the obvious deal; a
zero price pulls disproportionately harder than any discount.
- **Do:** arrange a choice set so the option you want sits in a clearly dominant position
  (the "$X print-only" that makes "$X print + digital" look like a steal); make a genuine
  free tier/sample/shipping the headline where you have one.
- **Don't:** leave a stray option that accidentally makes your best offer look worse; label
  something "free" that isn't.

### Authority
**Rule:** Signals of credible expertise lower resistance — borrow trust from a legitimate source.
*Why:* people defer to perceived authority and competence, especially under uncertainty.
- **Do:** show real credentials, certifications, expert/endorsement quotes, "as used by,"
  security/compliance marks — where they're true and relevant to the decision.
- **Don't:** fake authority or borrow irrelevant prestige; hollow badges erode trust when seen through.

### Liking
**Rule:** People say yes to what (and who) feels familiar, similar, and warm.
*Why:* similarity, genuine praise, and shared goals raise cooperation and conversion.
- **Do:** speak the user's language, reflect their context back, use a human and warm tone,
  show real people the user can relate to.
- **Don't:** mistake flattery for liking; insincerity reads instantly.

### Unity (shared identity)
**Rule:** "People like me / people who are *us*" is stronger than "people who are similar."
*Why:* a sense of shared identity — the same group, cause, or role — is among the deepest
drivers of action.
- **Do:** frame belonging honestly ("built for indie founders," "join 12k designers");
  co-create so the user feels part of the thing, not marketed to.
- **Don't:** claim a shared identity you haven't earned or a community that isn't real.

### Social proof, halo & specificity
**Rule:** Use substantiated social proof when relevant to the decision; it is not required.
*Why:* other people's experience can reduce uncertainty when its source and relevance are clear.
- **Do:** preserve the verified count, timeframe, population and rounding convention.
- **Don't:** infer truth from precision or fabrication from a round number. Never substitute
  an odd number to make a claim seem real; missing substantiation needs verification.

### Transparency bias
**Rule:** Proactively reveal a downside; it *builds* trust, not doubt.
*Why:* a company that surfaces the catch feels like it's on your side.
- **Do:** "On day 5 we'll remind you before your trial ends"; a clear 3-step timeline of
  what happens and when.
- **Don't:** hide the charge and hope they don't notice (they do, and bounce).

### Sell safety, not the pitch
**Rule:** Make the moment feel reassuring, not sold-to.
*Why:* people buy from safety nets, not sales pitches. Reassurance placed at the exact
second of hesitation converts.
- **Do:** "free cancellation," "cancel anytime," money-back — inside/next to the decision
  element; preempt the #1 objection right by the CTA.
- **Don't:** stack more persuasion where a reassurance would do.

### Reassure after the yes (post-purchase dissonance)
**Rule:** Treat the confirmation screen and welcome email as decision-reassurance surfaces,
not receipts.
*Why:* the moment someone commits, doubt returns — people re-litigate a purchase right
after making it, and unresolved doubt becomes refunds, disputes, and day-one churn. The
persuasion job isn't over at the click.
- **Do:** restate what they now have ("Your team plan is active — here's what unlocked"),
  show the concrete next step, and validate the choice ("you're in good company" social
  proof placed *after* payment).
- **Don't:** end the flow on a bare transaction summary, or worse, use the confirmation
  screen to immediately upsell before the decision they just made feels safe.

---

## D. Direct attention (visual hierarchy)

### Emphasize values, not labels
**Rule:** Rank elements by importance to the user *before* designing; make the key data
prominent and its label quiet.
*Why:* uniform presentation kills scannability; users came for the value, not the caption.
- **Do:** big bold number, small muted label; the most critical info dominates.
- **Don't:** style value and label the same.

### Differentiate deliberately
**Rule:** Use size, weight, color, position, and icon cues to direct attention.
- **Do:** vary type weight/size/color with intent; add an icon to speed comprehension.
- **Don't:** present everything at one visual level.

### Show real content, not decoration
**Rule:** You can't commit to what you can't visualize — show the actual thing in context.
- **Do:** the real product/screen/room; large imagery that reads as "a place you might go";
  contextual use shots that close the "imagination gap."
- **Don't:** abstract hero art that looks nice but answers nothing.

### Craft details that read as "premium"
- **Soft shadows**, tinted toward the background color (not harsh gray/black on color).
- **Cards** over plain vertical text lists (more scannable, interactive, digestible).
- **Bold/oversized typography** as a hierarchy device (can even replace imagery).
- **Minimalism** — every element has a clear purpose; no decoration for its own sake →
  faster loads, clearer message, more trustworthy feel.
- **Glow / accent color** to guide the eye toward a CTA or key section.
- **Limited color palette** so content, not chrome, holds attention.

---

## E. Feedback, personalization & delight

### System feedback
**Rule:** Every action gets an immediate, legible, satisfying response.
*Why:* feedback tells users their input registered and gives a sense of control. The pace
matters as much as the presence: ~0.1s reads as instant, ~400ms keeps the exchange feeling
conversational, and past ~1s the wait itself needs acknowledging (thresholds and the
perceived-performance moves in `substrate.md` Part 2).
- **Do:** distinct selected states (color + size change), live-updating values, instant
  consequences (show the new balance/total right away), error *prevention* via clarity;
  where real work takes longer, respond instantly anyway — optimistic update, skeleton,
  determinate progress.
- **Don't:** leave a tap ambiguous, or let a silent second pass after one.

### Micro-interactions
**Rule:** Once fundamentals are solid, add small motion that makes the UI feel alive.
- **Do:** tap feedback (scale/ripple/color), animated active states (sliding underline),
  soft screen transitions (fade/slide).
- **Don't:** animate so much it slows the task.

### Empty states as opportunities
**Rule:** An empty state is a chance to educate, engage, and convert — never a dead end.
- **Do:** explain the value, add an illustration, give a concrete CTA ("Create your first X").
- **Don't:** ship "You have no items."

### Smart search
**Rule:** Tapping search is a moment of intent — meet it with suggestions.
- **Do:** recent searches, popular items, and personalized recommendations before they type.
- **Don't:** show a blank screen.

### Lifecycle personalization
**Rule:** Don't show every user the same screen; adapt to new / returning / power users.
- **Do:** new users → simple setup/goal; returning → today's task; power users → advanced
  stats + tailored suggestions. Use the person's name.

### Emotional & sensory language
**Rule:** Descriptive, sensory copy activates imagination before the user weighs cost.
- **Do:** "beachside escape, steps from the sand" over a flat literal title.

---

## F. Conversation & framing (meta)

- **Every element asks a question** — make it an easy one. Reframe hard, high-commitment
  questions into low-stakes ones ("try free?" beats "worth $19/mo?").
- **Don't turn a decision into homework** — asking users to weigh feature bullets before
  they've felt any value invites "I'll think about it" (= never). Let them experience first.
- **Reframe the axis** — turn a cost decision into a convenience/step decision
  ("2 min away," "start my journey" instead of "add to cart").
- **One-word categorization does the thinking** — a tiny "cheaper" / "best value" tag tells
  the brain which to pick.

See also: `copywriting.md`, `navigation.md`, `review-checklist.md`.

---

*Provenance: distilled from established behavioral-design and UX principles — choice
reduction, defaults, goal-gradient, anchoring, endowment, loss aversion, social proof,
reciprocity, authority, liking, unity. Framework-agnostic; apply in any stack.*
