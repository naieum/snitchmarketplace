# The ethics gate — the canonical statement

This file is the **only** full statement of the gate in this skill. Every other file says one
line — "Gate first: `ethics-gate.md`" — and points here. If a paraphrase anywhere disagrees
with this file, this file wins.

**Run it before you reach for a single persuasion technique**, not at the end of the review.
The persuasion catalog is a loaded tool, and this step decides whether the surface has earned
it.

## The general test

**Any design that gets the tap by making the user believe something untrue, or by hiding what
it costs them to say yes, fails.**

The five checks below are illustrations of that test, not the list to match against. A pattern
that appears nowhere here still fails the gate if it meets the test. Fabricated urgency, fake
scarcity, hidden recurring costs, confirmshaming, and phone-only cancellation are the common
shapes, not the boundary.

## The five checks

Each is evidenceable from the surface itself — you can cite the markup, the copy, or the
absence, the same as any other finding.

1. **Is every persuasion claim true?** Every countdown, scarcity claim, social-proof number
   and loss frame reflects something real — no fabricated deadlines, no round invented counts,
   no fake reviews, no buried cancellation. Would the user thank you if they saw how this was
   built? If not, it is a finding.
2. **Is the cost stated where the decision is made — including what the current defaults add?**
   Total up what the pre-selected options actually produce and check the page shows *that*
   figure, not a lower headline one. Where a trial precedes a charge, both moments are stated.
3. **Is anything true, but positioned to displace the number that matters?** The commonest
   honest-inputs / dishonest-output failure, and the one the other checks miss because every
   individual claim passes. `Today: $0.00` set at 22px bold above a 9px `$89/mo` is *true* —
   and it is the mechanism burying the price. Ask which number the layout would have the user
   act on, and whether that is the number they will actually be charged. A genuinely free tier
   is worth leading with; a free *first period* leading at four times the type size of the
   recurring charge is the price hidden in plain sight. Same test for a discount anchored to a
   "was" price nobody paid, and for a total that appears only after the commitment.
4. **Are paid options opt-in, and is leaving as easy as joining?** A charge the user did not
   choose is a charge they did not consent to, whatever the checkbox says. And a flow that
   takes three taps in and a phone call out is asymmetric by design — count the steps both
   ways.
5. **Vulnerable / high-stakes:** if the user could be a child, an elder, or someone in
   crisis / illness / financial distress — or the decision touches health, money, safety, or is
   hard to undo — is persuasion **dialed down** (no urgency, no scarcity, no variable reward),
   with honest defaults and an exit as easy as the yes? (`inclusive-design.md`.)
   **This is the check that fires on surfaces with no funnel and no dark patterns** — settings,
   admin, destructive actions — where the first four all come back clean and a reviewer stops
   reading. A page with nothing to sell can still fail the gate here.

## What a failure does to the review

**If any answer is no, those items are findings, and you do not optimise them — whatever the
user asked for.** Say so plainly in the first two sentences of your response, and say why.
Then complete the review: report the failures as findings and give the honest conversion work
instead.

The gate does not halt the review; it reshapes it. Nothing in `snitch-ux.config.md` turns it
off — `lenses` narrows what gets *optimised*, `writing-system` narrows the scored copy lens,
and neither touches this file. A lint-clean dark pattern is still a finding.

Several persuasion moves actively make a failed surface **worse**: softening a commitment verb
on a page that hides its price removes the user's last warning; exit-intent interception on a
page whose exit is already a trap deepens the trap. When the gate fails, the finding is the
dishonesty, not the wording.

**The convenient truth, most of the time:** the dishonest items are *also* the conversion
problems. A charge the user only discovers at renewal is both the ethics failure and the reason
the funnel leaks at renewal. You will rarely have to choose between being honest and being
useful.

## Recording the result

The gate produces one of the three outcomes per check, like everything else in this skill:
a **Finding** (with evidence), a **Pass** (with the evidence that it ran — what you read and
what came back clean), or a **Skip** (with the reason and what would unblock it). "The gate
ran" with nothing behind it is not a result.

Judging the metric behind the surface — whether the number the team optimises only improves
when the user is better off — is a real question, but it cannot be evidenced from the surface,
so it is not a gate check. It lives in `usability-testing.md`.
