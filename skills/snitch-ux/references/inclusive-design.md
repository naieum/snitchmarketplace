# Who the User Really Is — inclusive design & vulnerable moments

The rest of this skill describes how minds work in general. This file corrects a default the
other files quietly assume: the calm, capable, Western, left-to-right-reading, neurotypical
user with a fast connection and full attention. That person is rare. Designing only for them
is how good psychology turns exclusionary — and how persuasion turns harmful for the people
least able to push back.

Two jobs here: **widen the range of people you design for**, and **know when the persuasion
half of this skill should be dialed *down*.**

## The range is wider than you think

Most "special cases" aren't rare — they're everyone, sometimes.

- **Ability is a spectrum, and it's often situational or temporary, not just permanent.** One
  hand may mean an amputation, a broken wrist, or holding a baby. "Can't hear the audio" may
  mean deafness, a dead earbud, or a noisy train. Low vision may mean blindness, aging eyes,
  or bright sun on a phone. → Design that works for the permanent case works for the far more
  common temporary and situational ones — the value compounds, it isn't charity.
- **Attention and calm are usually in short supply.** Assume distracted, rushed, one-handed,
  small-screen, interrupted. The person at their worst moment is the realistic user, not the
  edge case. (See the stress-case guardrail in `SKILL.md`.)

## Cognitive inclusion — the psychology has a duty attached

The mind-works facts in `psychology-foundations.md` (tiny working memory, scanning not
reading, cognitive load) hit some people much harder. Designing for the tighter end of each
helps everyone:

- **Plain language, short sentences, concrete words.** Low literacy, a second language,
  dyslexia, stress, and cognitive load all pull the same direction: simpler is more
  inclusive, not dumbed-down.
- **Don't lean on memory.** Working-memory limits are smaller under anxiety, aging, ADHD, or
  fatigue. Keep steps short, carry state, show don't recall.
- **Don't rely on a single channel.** Never carry meaning by color alone, or by sound alone,
  or by a fast animation someone may not catch. Reinforce with text, shape, and position.
- **Numbers are hard.** Low numeracy is widespread; express risk/price/quantity in more than
  one way (a bar, a plain-language comparison, the total) rather than a bare percentage.
- **Motion and novelty can hurt.** What reads as "delightful" can trigger vestibular
  discomfort or distract someone with attention differences. Respect reduced-motion; make
  animation optional and non-blocking.

## Cross-cultural & localization — your conventions aren't universal

A "convention" is only a convention inside a culture. Before assuming one:

- **Reading direction** — right-to-left languages mirror layout, flow, and progress
  direction; a left-to-right "next/forward" is backwards for them.
- **Color and symbol meaning** — colors carry different (sometimes opposite) meanings across
  cultures; icons, gestures, and metaphors don't always translate. Verify, don't assume.
- **Formats and identity** — names (no first/last split, single names, non-Latin scripts),
  dates, addresses, phone numbers, currency, and units vary widely. Don't hard-code one
  shape, and don't force a gender or title you don't need.
- **Text expands and contracts** — translated strings can run much longer or shorter; layouts
  that assume English length break. Copy that depends on wordplay usually doesn't survive
  translation.

## Vulnerable users & high-stakes moments — dial persuasion down

The persuasion half of this skill assumes an adult making a low-stakes, reversible choice.
When that assumption breaks, the same techniques can cause real harm, and the ethical
default shifts from "nudge toward the good choice" to "get out of the way and inform."

Treat these as high-care contexts:

- **Who:** children and teens; older adults; people in crisis, grief, illness, or financial
  distress; anyone impaired, exhausted, or under acute pressure.
- **What:** decisions about health, money, safety, legal rights, or anything hard to undo.

In those contexts:

- **Drop urgency, scarcity, and variable-reward loops.** Pressure tactics on someone already
  under pressure are predatory, even when the numbers are "true."
- **Lead with clarity and honest defaults**, not conversion. Make the reversible, cautious
  option the easy one; make consequences and costs unmissable.
- **Make saying no, leaving, and undoing as easy as saying yes.** Symmetry of exit is the
  clearest test that you're informing rather than trapping.
- **Ask less, disclose more.** Minimize data collected; over-explain what happens next.

## The test

Two questions extend the skill's core guardrail to this file:

1. **Would this still work for someone with half the attention, literacy, vision, motor
   control, or cultural context I assumed?**
2. **If the person on the other side were tired, worried, young, or elderly, would I be proud
   of how this treats them?**

If either answer is no, the design isn't done — no matter how well it converts.
