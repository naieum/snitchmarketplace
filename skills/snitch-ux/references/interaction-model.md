# How Interaction Works — the interaction model

Where `psychology-foundations.md` is *how the mind works*, this file is *how a mind and a
designed thing work together*. This model is the spine that explains why something feels
obvious or feels broken. It's still psychology — it's about the models, expectations, and
errors in the user's head — not about specific UI components (that comes later).

## Contents
- Conceptual models: three of them
- The two gulfs — the core loop of every action
- The tools that bridge the gulfs
- Knowledge in the head vs. knowledge in the world
- Human error is a design problem
- Using this file to diagnose

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
- **Constraints** — physical, cultural, semantic, and logical limits that *reduce the set
  of possible actions* so the wrong move is hard or impossible. → Prevent errors by design
  rather than warning about them afterward.

## Knowledge in the head vs. knowledge in the world

Behavior is guided by a combination of what's in memory (**in the head**) and what's visible
in the environment (**in the world**). Knowledge in the world is easier — you don't have to
remember it, you just perceive it — but only if the design puts it there.

- → Lean on **knowledge in the world**: make the options, current state, and next step
  visible, so users recognize rather than recall (ties directly to working-memory limits and
  recognition-over-recall in `psychology-foundations.md`).
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

## Using this file to diagnose

Given any "this is confusing" screen, run the model:

1. **Which model is wrong?** Does the system image convey the intended conceptual model, or
   is the user building a false one?
2. **Which gulf, which stage?** Can't figure out how to act (execution) or can't tell what
   happened (evaluation)?
3. **Which tool is missing?** A signifier (what's actionable), a mapping (which control does
   what), feedback (did it work), or a constraint (stop the wrong move)?
4. **If they erred — slip or mistake?** Constrain/forgive the slip; clarify the model for
   the mistake.

This is the psychology-level diagnosis. The concrete UI moves that implement each fix are a
later layer of this skill.
