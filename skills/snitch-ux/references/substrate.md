# The Substrate — how the mind works, and how a mind and a designed thing work together

Every rule elsewhere in this skill is a *consequence* of what is in this file. Part 1 is the
**why** underneath the **what** — how people perceive, remember, decide, and feel, distilled
from established cognitive and behavioral psychology. Part 2 is the **model of interaction
itself** — the conceptual models, gulfs, and errors that explain why a thing feels obvious or
feels broken. Read it to reason from first principles when a situation isn't covered by a
specific rule — not to memorize facts.

Treat these models and approximate numbers as prompts for hypotheses, not universal laws,
audience measurements, or automatic Finding thresholds. Observed behavior and task context
outrank a model. A user declining an offer can be a successful, informed outcome.

On **working surfaces** (settings, admin, editors, destructive actions) Part 2 is the most
useful material in the skill: most of the persuasion catalog is inert there, and what breaks
those screens is a bad conceptual model, a missing signifier, or an unbridged gulf of
evaluation.

> Gate first: `ethics-gate.md`.

## Contents

**Part 1 — How the mind works**
- The master frame: two systems (System 1 / System 2)
- How people SEE · READ · REMEMBER · THINK · FOCUS ATTENTION
- What MOTIVATES people · When behavior actually happens — the convergence model
- People are SOCIAL animals · How people FEEL · People make MISTAKES · How people DECIDE

**Part 2 — How interaction works**
- Conceptual models: three of them
- The two gulfs — the core loop of every action
- The tools that bridge the gulfs
- Knowledge in the head vs. knowledge in the world
- Human error is a design problem
- Using Part 2 to diagnose

---

# Part 1 — How the mind works
## The master frame: two systems

One useful abstraction distinguishes two kinds of processing:

- **System 1 — fast and automatic.** Pattern recognition, first impressions and habitual
  responses can shape how a person reads a screen.
- **System 2 — deliberate and effortful.** Reasoning, comparison and careful reading matter
  when the decision calls for them. These are not literal isolated brain systems.

**Design consequence:** reduce avoidable decoding while supporting informed deliberation.
Do not make a consequential decision faster by removing the information needed to consider it.

---

## How people SEE

- **We see what we expect to see.** Perception is top-down — the brain predicts from prior
  experience (schemas) and fills in the rest. → Match conventions and mental models;
  surprising layouts get misread, not admired.
- **Peripheral vision does the triage.** People use blurry peripheral vision to decide
  where to point their sharp central vision. → What's in the corner of the eye determines
  where attention goes; motion and high contrast in the periphery pull the gaze.
- **The brain groups automatically (Gestalt).** Proximity, similarity, common region,
  continuity, closure — things near or alike are read as *related*. → Grouping *is*
  meaning; whitespace and alignment communicate structure before a single word is read.
- **Faces get special hardware.** A dedicated region detects faces instantly, and we
  follow a depicted person's **eye gaze** to whatever they're looking at. → Faces draw the
  eye; a face looking *at* the thing that matters directs the user there.
- **~8% of men (and ~0.5% of women) are color-blind.** → Never encode meaning in color
  alone; pair it with shape, position, or label.

## How people READ

- **People don't read, they scan** — jumping for words that match their goal, often in an
  F-shaped path on text-heavy pages. → Front-load meaning; use headings, bold keywords,
  short chunks. (This is the mechanism behind "design for scanning.")
- **Reading is fragile.** Small type, low contrast, decorative fonts, ALL CAPS (no word
  shape), and busy backgrounds all slow decoding and raise cognitive load. → Legibility is
  not aesthetics; it's whether comprehension happens at all.
- **Comprehension ≠ reading.** People fill in and predict text, so they routinely "read"
  something other than what's there. → Say the important thing plainly and once; don't bury
  it in prose.

## How people REMEMBER

- **Working memory is tiny — about 4 chunks, not the 7 of folklore.**
  → Never make someone hold more than a few things in mind to complete a step; carry state
  for them across screens.
- **Recognition beats recall.** Seeing options is far easier than remembering them. → Show
  choices, recents, and thumbnails; don't make people remember a code, a path, or what they
  typed two screens ago.
- **Memory is reconstructed, not recorded.** It's rebuilt (and subtly rewritten) each time,
  so it's unreliable and gist-only. → Don't rely on users remembering instructions,
  earlier steps, or prior state — put the knowledge in front of them.
- **Chunking expands capacity.** Grouping (a phone number in 3 blocks) makes more fit. →
  Structure information into meaningful units.
- **The odd one out is remembered (isolation).** An item that visually breaks from its
  peers is recalled far better than the ones that blend in. → Make the single thing that
  matters look *unlike* everything around it; if everything is emphasized, nothing is.
- **First and last stick, the middle sags (serial position).** In any sequence, the
  beginning and the end are remembered best. → Put the most important items or steps first
  and last; don't bury the key one in the middle of a list or flow.

## How people THINK

- **The mind hoards attention and hates load.** There are three loads: *intrinsic* (the
  task's real difficulty), *germane* (useful effort toward learning), and *extraneous*
  (effort your design wastes). → Ruthlessly cut extraneous load; reveal complexity
  progressively; give information in small, staged, need-to-know pieces.
- **People run on mental models.** Everyone has a model of "how this kind of thing works,"
  built from past experience. When your design's model matches theirs, it feels obvious;
  when it clashes, it feels broken. (Deep dive in Part 2.)
- **Time is subjective.** Perceived duration depends on expectation and feedback, not the
  clock. → Progress indicators, immediate response, and something to watch make a wait feel
  shorter; a blank pause feels broken.
- **The novel captures the mind.** Anything new or unexpected grabs attention — useful for
  onboarding a key feature, costly when novelty is just decoration.
- **We want more options than we can handle.** People *ask* for more choices/info than they
  can actually process, then stall on them. → Don't take "give me everything" at face value.

## How people FOCUS ATTENTION

- **Attention is selective and lossy.** We filter aggressively and miss the unattended —
  inattentional blindness (the "invisible gorilla"). → You cannot assume anything outside
  the user's current focus was seen; put the critical thing *in* the path.
- **Multitasking is a myth.** The brain task-switches at a cost; interruptions destroy
  performance. → Protect flow; don't interrupt a focused task with unrelated demands.
- **Sustained attention lasts ~7–10 minutes**, and then only if the person stays engaged. →
  Break long tasks into segments with a sense of progress.
- **We're wired to notice specific things:** movement, faces, our own name, and primal
  cues (a threat, food, attraction). → These are powerful and easily misused; use honestly.
- **Habituation → banner blindness.** Repeated or ad-like stimuli get tuned out. → The
  more something looks like an ad, the less it's seen — even when it isn't one.

## What MOTIVATES people

- **Dopamine is about *wanting*, not liking.** It fires on *anticipation* and is
  supercharged by **unpredictable, variable rewards** (the slot-machine / pull-to-refresh
  loop). → Extremely potent for engagement, and the sharpest edge of the ethics line.
- **Progress motivates; small wins compound.** People push harder as a goal nears
  (goal-gradient), and a head start they didn't earn still works (endowed progress). →
  Show accurate progress, including zero when nothing is complete; label granted bonuses
  separately. (See goal-gradient in `principles.md`.)
- **Intrinsic beats extrinsic — and extrinsic can *destroy* intrinsic.** Paying/rewarding
  someone for something they already enjoyed reduces their internal drive (over-justification
  effect). Autonomy, mastery, and purpose sustain motivation; generic points and badges
  often don't. → Reward carefully; don't bolt extrinsic carrots onto intrinsic joy.
- **Reference points can influence value judgments.** They do not replace the product's
  merits or make comparison pricing mandatory (`principles.md`).
- **Scarcity raises perceived value** — but only when real.
- **Habits form through a loop.** A behavior becomes automatic by repeating a cycle: a
  **trigger** (an external cue, or increasingly an *internal* one like boredom, loneliness,
  or anxiety) → an easy **action** → a **variable reward** → a small **investment** the user
  puts in (data, content, followers, preferences) that both improves the product for them
  and loads the next trigger. Each turn makes the behavior more automatic and the product
  more "theirs." → Powerful for retention, and the single place to be most honest: a loop
  built on an internal trigger of anxiety, aimed at time-on-app rather than the user's goal,
  is the definition of a manipulative design.
- **Open loops nag until closed (the Zeigarnik effect).** An unfinished task or an
  unclaimed, almost-complete reward stays active in the mind and creates a small tension to
  resolve it. → "1 step left," a half-finished profile, or a started-but-incomplete state
  pulls people back — use it toward *their* goal, not busywork.

## When behavior actually happens — the convergence model

Motivation, memory, and attention are the ingredients; this is the model that ties them into
action. **A behavior happens only when three things line up in the same moment:**

- **Motivation** — the person *wants* the outcome enough right now.
- **Ability** — the action is *easy* enough to do right now (time, effort, steps, cost,
  thinking required).
- **A prompt** — something *tells them to act* right now, and they notice it.

Use these as possible explanations, not a diagnosis from non-action alone. More than one
factor can be missing, and the user may reasonably choose not to act. Check the explanation
against observed behavior and the person's goal before proposing a fix.

- Motivated and prompted but didn't act? **Ability** was too low — the action was too hard,
  too many steps, too costly. Reduce the effort (this is the whole "reduce friction" half of
  the skill). Making something easier is usually cheaper and more reliable than pumping up
  motivation.
- Able and prompted but didn't act? **Motivation** was too low — they didn't want it enough
  at that moment. Strengthen the reason, or move the ask to a moment when motivation is
  naturally higher.
- Motivated and able but didn't act? **The prompt** was missing, badly timed, or unseen —
  add a clear call to action, or time it to when they're both willing and able.

**Timing is the quiet lever.** The same prompt lands or fails depending on whether it arrives
when motivation *and* ability are both high (a good moment) or when either is low (nagging,
resented). Put the ask where the two curves peak — right after a win, right when the need is
felt — not on a fixed schedule that ignores the person's state. Honestly applied, this means
helping people do what they already want; misused, it means prompting at moments of low
willpower, which is where it crosses into manipulation.

## People are SOCIAL animals

- **We imitate, automatically.** Mirror systems mean watching someone do a thing partially
  activates *our* doing it; we copy what others do, especially under uncertainty. → Social
  proof works because uncertainty routes decisions to "what are others doing?"
- **We're built for reciprocity.** An unearned gift creates a felt obligation to return it.
  → Give real value before asking. (See reciprocity in `principles.md`.)
- **Stories are how the mind makes sense of things.** Narrative is processed more deeply and
  remembered better than facts or stats. → Frame value as a small story, not a spec sheet.
- **Faces and people build trust.** Testimonials, real photos, and named people carry more
  weight than anonymous claims.
- **~150 stable relationships is the natural ceiling.** Strong vs. weak ties behave
  differently — relevant to any social feature.

## How people FEEL

- **Emotion comes first and drives the decision.** Feelings are faster than reasoning and
  set the frame the reasoning then serves. → How a screen *feels* in the first 50ms shapes
  everything after.
- **Aesthetic–usability effect.** Attractive interfaces are *perceived* as easier to use
  and are forgiven more — visual quality literally buys usability goodwill and patience.
- **Emotion runs on three levels — design for all three.** The **visceral**: the immediate,
  pre-thought gut reaction to how something looks, moves, and sounds (a striking first
  impression). The **behavioral**: the feeling *of using it* — the quiet competence or
  frustration of the flow itself. The **reflective**: the slower story afterward — what
  owning or using this says about me, whether it was worth it, whether I'd tell someone. A
  great experience needs all three: a strong first hit, a smooth middle, and a meaning worth
  retelling. Miss the reflective level and you get something pleasant but forgettable.
- **Peak–end rule.** People judge an experience by its most intense moment and
  its ending, not the average. → Engineer a strong peak and a clean, positive ending
  (confirmation, success state) rather than smoothing everything to bland.
- **Doubt returns right after the yes (post-purchase dissonance).** The moment someone
  commits — pays, subscribes, signs up — the mind starts re-litigating the decision, and
  the bigger or less reversible the commitment, the louder the second-guessing. →
  Confirmation and welcome screens must *reassure the decision*, not just log the
  transaction: restate what they now have, show the concrete next step, and let them feel
  in good company. A bare receipt leaves the doubt to fester into refunds and regret.
- **Anecdotes move people; statistics don't.** One vivid, specific case outweighs a big
  number emotionally.
- **Mood colors everything.** A positive mood broadens thinking and raises tolerance for
  friction; anxiety narrows it. → Reduce anxiety (reassurance, clarity) at high-stakes
  moments.

## People make MISTAKES

- **There is no error-free user; design for error.** Errors rise sharply under stress and
  cognitive load. → Assume mistakes will happen and make them cheap.
- **Slips vs. mistakes:** a **slip** is the right intention executed wrong
  (autopilot); a **mistake** is the wrong intention from a wrong model. They need different
  fixes — slips want constraints and confirmations, mistakes want a clearer conceptual
  model. (Detail in Part 2, "Human error is a design problem".)
- **Prevent, then forgive.** Prevent with good defaults, constraints, and forgiving input
  (accept the card number with or without spaces); forgive with easy undo and non-destructive
  actions. → Blame the design, not the user.
- **Error messages should say what happened, why, and how to fix it** — in plain language,
  never blaming the person.

## How people DECIDE

Decisions are mostly **unconscious and emotional**, justified after the fact. The practical
levers (each detailed in `principles.md`) all work through predictable System-1 shortcuts:

- **Defaults** — the pre-set option is taken as the recommendation and rarely changed.
- **Choice overload** — too many *hard-to-distinguish* options can reduce action and satisfaction
  (the jam study). A real effect under the right conditions — complex options, no formed
  preference — not a reliable general one; meta-analysis puts the average effect near zero.
- **Anchoring** — the first number seen frames every judgment after it.
- **Loss aversion** — a loss hurts about twice as much as the equivalent gain pleases.
- **Framing** — the same fact stated as a gain vs. a loss flips the decision.
- **Endowment** — people overvalue what they already have or built.
- **Satisficing** — people take the first option that's *good enough*, not the best.
- **Confidence-seeking** — people decide to *stop feeling uncertain*; remove doubt and the
  decision gets easier. (Why "doubt is the most expensive thing in your UI.")
- **Free is its own category.** A zero price triggers a disproportionate emotional pull —
  people will over-choose something free over a paid option that's objectively a better
  deal. → A genuine free tier, sample, or shipping is a lever unlike any discount; "free"
  beats "almost free."
- **A third option reframes the other two (decoy).** Placing a deliberately weaker option
  next to the one you want chosen makes that one look like the obvious deal — people don't
  judge in isolation, they judge against the nearest comparison. → Structure a choice set so
  the target sits in a clearly-dominant position; conversely, watch that a stray option
  isn't accidentally making your best offer look bad.
- **Favors and payments are different worlds.** People treat "help me out" (social norms)
  and "here's money" (market norms) as separate moral frames, and mixing them backfires —
  offering a small payment for what felt like a favor is more offensive than asking for it
  free. → Decide which frame a moment lives in (community/goodwill vs. transaction) and don't
  blend them.
- **Paying registers as pain.** Spending money produces a small, real sting that colors the
  surrounding experience, sharpest when the cost is salient and itemized at the moment of
  use. → Reduce that pain honestly (bundling, flat subscriptions, pre-commitment) — but
  never by *hiding* cost, which trades a moment's comfort for the goodwill in the reservoir.

**The throughline:** people don't compute the optimal answer; they follow feelings and
shortcuts to a *good-enough, low-doubt* choice. Good design makes the choice you want to be
the one that feels easiest and safest to System 1 — and, per this skill's Guardrails, only
when that choice is genuinely in the user's interest.

---

# Part 2 — How interaction works

Where Part 1 is *how the mind works*, this part is *how a mind and a designed thing work
together*. This model is the spine that explains why something feels obvious or feels broken.
## Conceptual models: three of them

There are always three models in play, and trouble lives in the gaps between them:

- **The designer's model** — how the designer *thinks* it works.
- **The user's model** — how the user *believes* it works (built from past experience).
- **The system image** — everything the product actually presents: the interface, wording,
  behavior, docs. It's the *only* channel between the other two.

The designer never talks to the user directly. **All communication happens through the
system image.** If the system image doesn't convey the designer's model clearly, the user
builds a wrong model — and then behaves "wrong," which is really the design's failure. Good
design makes a **good conceptual model discoverable** from the interface alone.

## The two gulfs — the core loop of every action

Every interaction crosses two gaps between the person and the system:

- **The Gulf of Execution** — "How do I do the thing I want?" The distance between the
  user's *intention* and the actions the system allows. Wide when it's unclear what's
  possible or how to do it.
- **The Gulf of Evaluation** — "Did it work? What state am I in now?" The distance between
  the system's *actual state* and the user's ability to perceive and understand it. Wide
  when feedback is missing, delayed, or cryptic.

**Design bridges the two gulfs.** The seven stages of an action name where a design can
fail:

1. **Goal** — form the goal ("I want to pay").
2. **Plan** — decide the approach.
3. **Specify** — work out the exact action sequence.
4. **Perform** — do it.
   — *(the execution side — bridged by clear affordances, signifiers, mapping, constraints)*
5. **Perceive** — notice what happened.
6. **Interpret** — make sense of it.
7. **Compare** — check it against the goal.
   — *(the evaluation side — bridged by feedback and a visible system state)*

When you diagnose a confusing flow, ask *which stage breaks*: do they not know it's
possible (execution), or not know whether it worked (evaluation)?

## The tools that bridge the gulfs

- **Affordances** — the *possible* actions given the relationship between a person and a
  thing (a gap affords stepping over; a control affords being operated). A property of the
  relationship, not the object.
- **Signifiers** — the perceivable *cues that tell you where and how to act*. This is
  the key refinement: affordances say what's possible; **signifiers communicate it.**
  A door you can't tell whether to push or pull has the affordance but a broken signifier.
  → Most "unclear what's clickable / where do I start" problems are signifier problems.
- **Mapping** — the correspondence between a control and its effect. **Natural mapping**
  uses spatial or cultural analogy so the relationship needs no learning (a volume slider
  that goes up for louder). → Arrange controls so their layout mirrors what they affect.
- **Feedback** — immediate, informative confirmation of the result of an action. Must be
  prompt (delayed feedback reads as "nothing happened") and proportionate (not so much it
  becomes noise). → Feedback is what closes the Gulf of Evaluation.
  The thresholds are known numbers, so cite them: **~0.1s** reads as instantaneous — no
  acknowledgment needed beyond the state change; **~400ms** is the pace that keeps an
  exchange feeling conversational — under it people stay engaged and productive, over it
  attention starts to wander; by **~1s** the wait itself is noticed and needs an
  acknowledgment (spinner, skeleton, optimistic update); by **~10s** the user's focus is
  gone unless there's determinate progress and a way to do something else. A response that
  will run long is a design moment, not a delay to apologize for.
- **Constraints** — physical, cultural, semantic, and logical limits that *reduce the set
  of possible actions* so the wrong move is hard or impossible. → Prevent errors by design
  rather than warning about them afterward.

## Knowledge in the head vs. knowledge in the world

Behavior is guided by a combination of what's in memory (**in the head**) and what's visible
in the environment (**in the world**). Knowledge in the world is easier — you don't have to
remember it, you just perceive it — but only if the design puts it there.

- → Lean on **knowledge in the world**: make the options, current state, and next step
  visible, so users recognize rather than recall (ties directly to working-memory limits and
  recognition-over-recall in Part 1).
- → Every time you require the user to *remember* something across steps, you've moved
  knowledge into the head — a tax. Carry it for them.

## Human error is a design problem

The stance here: **most "user error" is a design failure.** People are not the unreliable
component — the mismatch between the design and how humans actually work is. Two kinds, with
different remedies:

- **Slips** — the right intention, the wrong action; failures of *execution*, usually on
  autopilot. Subtypes worth knowing: **capture** (a more-practiced action takes over from
  the intended one), **description** (right action, wrong object — the two looked alike),
  **mode** (correct action in the wrong mode/state), **memory-lapse** (a step forgotten
  mid-sequence). → Fix with constraints, sensible defaults, confirmations on the destructive,
  clear mode indicators, and making similar-but-different things *look* different.
- **Mistakes** — the wrong intention from a wrong model; failures of *planning*. → Fix by
  making the conceptual model clearer, not by adding a warning.

**Design for error as the normal case:**
- Prevent it (constraints, good defaults, forgiving input, confirmation only where it
  matters).
- Make actions **reversible** (undo) and destructive actions hard to trigger by accident.
- When it happens, explain **what happened, why, and how to recover** — in plain language,
  never blaming the user.
- Don't over-warn: constant confirmations train people to click through them, so the one
  that matters gets ignored too.

## Using Part 2 to diagnose

Given any "this is confusing" screen, run the model:

1. **Which model is wrong?** Does the system image convey the intended conceptual model, or
   is the user building a false one?
2. **Which gulf, which stage?** Can't figure out how to act (execution) or can't tell what
   happened (evaluation)?
3. **Which tool is missing?** A signifier (what's actionable), a mapping (which control does
   what), feedback (did it work), or a constraint (stop the wrong move)?
4. **If they erred — slip or mistake?** Constrain/forgive the slip; clarify the model for
   the mistake.

This is the psychology-level diagnosis. The concrete UI moves that implement each fix live in
`principles.md` and `review-checklist.md` §5.5.
