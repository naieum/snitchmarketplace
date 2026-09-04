# Finding rules — evidence, severity, confidence

Read this before writing any review finding. It carries the whole discipline: what a finding
has to prove, how absence is evidenced, how defects merge and split, and how Severity and
Confidence are assigned.

> Gate first: `ethics-gate.md`.

## The three evidence rules

A design opinion costs nothing to state, which is exactly why an unevidenced one is worth
nothing. In review mode these three hold without exception; break them and the audit becomes
prose the user can't check, argue with, or act on.

1. **No finding without evidence.** You must have actually read the component (Read/Grep the
   file) or actually looked at the screen before you say anything about it — and you must cite
   what you looked at: file path + line, or screen/URL + the specific element. Evidence for a
   UX finding is that citation *plus* what the user is trying to do at that moment; a label is
   only confusing relative to a task.
2. **No summary claims.** "Several issues with the onboarding" is not a finding, it's a
   feeling. Every issue gets its own entry with its own evidence. If you can't name the surface
   and quote the copy, markup, or interaction — **or demonstrate its absence** — you haven't
   found anything yet.
3. **Verify before you claim it.** After reading, check that the component actually does what
   you just said it does — that the button really is unlabelled, that the default really isn't
   pre-selected, that the price really is shown with nothing to compare it to. If the code or
   the screen doesn't support the claim, drop it. A retracted guess costs you one line; a wrong
   finding costs the user a change they didn't need.

The same discipline applies in generative mode whenever you critique existing code you're
building on.

**Evidence outranks the catalog.** Reference patterns are review prompts, not mandatory UI
features. No anchor, no testimonial, a round count, an honest 0% meter, or a different headline
shape is not by itself a Finding. Name the task-specific defect and its causal mechanism.
An optional improvement without that evidence is a test hypothesis, outside the Findings list.
No quota of Findings or required persuasion techniques applies, even on acquisition surfaces.

**Do not manufacture evidence in the Fix.** Preserve verified product facts and commitments.
Never invent a trial, discount, review count, deadline, performance result, integration,
cancellation promise, or completed step to improve the copy or a lint score. If a rewrite
needs a missing fact, give a clearly marked template and name the fact needed before use.
State behavioral predictions as risks or hypotheses; measured lift requires cited analytics
or study evidence relevant to this surface. A screenshot can prove visible copy without
proving an interaction, and source can prove a branch without proving it ran in a browser.

## The finding format

```
- **Surface:** path/to/Component.tsx:47  — or —  /signup step 2, button[data-testid="continue"]
- **Evidence:** [the actual copy, markup, or described interaction — quoted]
- **Principle:** [the clarity or persuasion principle it violates]
- **Risk:** [what the user or the funnel actually loses — name a behaviour or a number, not the principle restated. "The decision gets deferred at the moment of highest intent" is a Risk; "violates anchoring" is the Principle field again]
- **Fix:** [the specific change]
- **Severity:** Critical | High | Medium | Low
- **Confidence:** High | Medium | Low — lower axis first
```

**Risk** is the family's shared term (CONTEXT.md: a Finding is Impact/Severity, Evidence, Risk,
Fix). Earlier versions of this skill called the same field **Cost**; the two names mean one
field, and new output uses **Risk**.

## Evidencing absence (rule 2's hard half)

Absence is evidenced, not asserted: name the search, its scope, and what would satisfy the
requirement. A missing token proves only that token is missing. Check equivalent mechanisms:
wrapping labels and `aria-labelledby` can label inputs; `role="status"` and `role="alert"`
have implicit live behavior; native forms can submit without JavaScript. Persistence and
destructive guards may live in imports, shared handlers, or the server. Trace those before
calling a control dead, a draft unsaved, or a deletion unguarded. If unavailable, record a
Skip for the unresolved behavior and report only the visible defect you can support.

Some valuable absences are semantic — no total before commitment, no usable location cue —
rather than missing strings. A semantic absence is evidenced by
naming **what you read in full, and what would have satisfied it**: "Read all 34 lines of the
summary block; it lists three line items and a shipping method, and no element states a total —
the largest number on the page is the $89 line item." That is checkable: a reader can open the
same block and produce the total if it is there. What is never acceptable is the unscoped
assertion — "there's no clear value proposition" names no sweep and no satisfying condition, so
nobody can prove it wrong.

## One defect, one entry (merging and splitting)

When the same defect appears across N elements from one cause — a row of `onclick` spans with
no keyboard handler, a gallery of images sharing an empty alt — that is one finding with the
instances listed, not N findings. **The fix is the test**: one replacement that resolves them
all is one finding; genuinely different fixes are separate findings even from a shared cause.
It runs in reverse too: several defects on a single element can merge when one replacement
resolves all of them — shared cause is not required in that direction. **When the tests above
disagree, Risk is the tiebreak — one risk, one entry.** Merge the parts that cost the user the
same thing; if writing the Risk field honestly needs an "and" joining two different losses,
that is two findings however co-located the edit. An "Erase device" control with no
confirmation, no statement of what is wiped, and an unassociated label is one finding — every
part costs the user the same thing, destroying something without being told what. Bad copy,
failing contrast and a dead link on one element are three — misread the offer, can't read it at
all, click goes nowhere. Two claims that are separately untrue are separately findings, even
when one deletion removes both. **Never settle a close call by dropping a defect**: when you
still can't tell, file it as its own entry. Over-splitting costs a line; silent deletion costs
the finding.

**A merged finding takes the highest severity of its parts**, and its lesser parts travel with
it: they are never demoted or dropped by `min-severity`, because merging must not become a way
to lose a finding quietly. List each merged defect as its own bullet with its own evidence so a
conformance pass can still recover it.

## Severity rubric

The bands rate what the defect does to the user, not how much it bothers you.

- **Critical** — blocks task completion, excludes people, hides the cost, or destroys something
  irreversibly: the flow can't be finished, the control is unreachable by keyboard / screen
  reader / thumb, an essential task has no completion
  path for some users (**on-screen or off** — a required step routed through a channel some people
  cannot use, or available only in a window they cannot reach, is still a blocked task even though
  nothing on screen looks broken — the test is **no path at all for that person, not a degraded
  one**; a target that is small, or text that is hard to read, is a **barrier**: Medium by default,
  High when it actually stops someone finishing, and never Critical unless it leaves no route at
  all), or **the user cannot determine what they will be charged**.
  Where options carry cost, total up what the *current defaults* produce and check the page states
  that figure rather than a lower headline one; where a trial precedes it, check both moments are
  stated. Reserve the money clause for that: a cost that is absent,
  contradicted, or disclosed below legibility. A dishonest-but-legible claim (fake countdown,
  proven-false social proof) is an ethics-gate finding at High — real, reportable, and not the same
  as the user not knowing the price.
  **Also Critical — irreversible destruction**: a single step irreversibly destroys or exposes
  data or access the user **already has** — a delete, wipe, revoke, or make-public that commits
  **immediately**, with no confirmation, no typed check, and no undo. The test is the **guard,
  not how bad the outcome would be**: no guard at all, not a weak one. Three carve-outs keep this
  narrow. The same action behind a proportionate constraint is not a finding. A setting that
  merely governs *future* destruction — a retention window, a default visibility — is not this
  clause: rate it by what its **current value** does to the user. High if the shipped default
  silently destroys or exposes something later (backups switched off, an auto-purge interval, a
  sharing scope that publishes by default); Medium if it only removes friction from a path the
  user still has to choose deliberately. And this clause covers data and access, not money:
  an unknowable charge is the money clause's business, and a purchase is not destruction however
  hard it is to reverse.
  **Calibration.** If several findings on one page all read Critical, the band has stopped ranking
  anything. Re-check each against the one clause it claims: is someone actually left with *no*
  route through, is the charge actually undeterminable, is the destruction actually one step from
  here with nothing in the way? Findings that survive that check keep the band however many there
  are — a genuinely broken page can carry several, and this is a test of each claim against its
  clause, not a quota.
- **High** — a large, avoidable loss the design could have prevented, or a fabricated persuasion
  claim: real confusion at a decision point, a cost revealed late, a dead end on a path users
  have to take, an ethics-gate failure that misleads without hiding the price, a control whose
  current state is unreadable, a change **the user themselves made** that commits with no
  acknowledgement, or an outcome the interface never confirms. (That last pair is High, not
  Critical: the destruction clause above is about wiping data or access the user **already had**,
  not about a change they chose going unconfirmed.) Outside a funnel there is no drop-off to measure, so read "loss" as
  the user giving up, guessing, or getting it wrong — the band is sized by what that costs them,
  not by whether money was involved.
- **Medium** — evidenced friction users can work around: avoidable repeated entry, confusing
  units, or extra steps that obstruct this task. A blank field or unanchored price alone
  does not meet this band.
- **Low** — polish: tone, spacing, a label that could be sharper. Craft items live here — shadow
  tinting, card treatment, palette discipline, a glow that could guide the eye better. The page
  works and could read better.

## Where hierarchy rates — read this as part of the bands above, not as a footnote to Low

The word "hierarchy" covers two very different things in this skill, and they rate nowhere near
each other:

- **The reader cannot find where to start, or is pointed at the wrong thing → rate by effect,
  typically High.** Equal heading and body styles can weaken scanning cues, but do not alone
  prove there is no entry point. Consider grouping, position, whitespace and other emphasis;
  rate the supported task cost rather than a CSS pattern. Also inspect
  **inverted hierarchy, which is the commoner failure**: emphasis pointed at the wrong element,
  rated by what the user misses rather than by how tidy the page looks. Ask which element the
  styling would have you act on, then whether that is the one that matters — a newsletter banner
  set larger than the field the user came to fill in; a "Skip" affordance heavier than the step it
  skips; a summary line that whispers the part the reader is accountable for.
- **The entry point is findable and the emphasis is right, but the craft could be better → Low.**
  Untinted shadows, a list that would read better as cards, an unremarkable palette. These sit
  under "direct attention" in `principles.md`, and they are not what the High rule above is
  about. Do not rate a shadow like a missing entry point.

The test between them: **can the reader tell where to start and what matters?** If no, High. If
yes and it could simply look better, Low.

## Confidence — two axes

Confidence is a separate axis, and it has **two** things to separate. State which you mean
when they differ:

- *Artifact confidence* — how well the evidence supports the precise claim. **High** for
  clearly visible screenshot text or unambiguous source behavior; **Medium** when relevant
  state is partly available; **Low** when the artifact only indirectly supports the claim.
  Do not downgrade visible evidence merely because it is a screenshot, or upgrade inferred
  runtime behavior merely because you read source.
- *Judgement confidence* — how sure you are the claim is true given what you saw. You can read
  `Only 2 spots left` perfectly (artifact High) and still not know whether it's false, because
  that depends on a business fact you can't check. Record claim verification as a Skip,
  not a speculative dishonesty Finding. Report the lower axis on supported Findings and name
  its limit. A claim excluded by a supplied claim inventory is independently reportable as
  unsupported declared intent; that still does not prove the underlying statement false.

Confidence never substitutes for evidence: a conjecture does not become a Critical Finding
by attaching "Low confidence."

## Decision tensions — when the workspace declares its own intent

Step 0 reads a checked-in `BLUEPRINT.md` or `marketing/positioning.md` when one exists (see
SKILL.md Step 0). Those files record decisions the team already made, and a best-practice fix
that contradicts a recorded decision is not the same kind of finding as one that contradicts
nothing.

**The rule is CONTEXT.md's *Declared intent* entry** — which sections are read, the
Decision-tension Finding capped at **Medium** citing `BLUEPRINT.md:line`, the uncapped
unsupported-claim Finding against the claim inventory, the **Skip** when neither file exists (never
an interview), and read-only always. Apply it as written; do not restate it here.

This skill's step: the read happens in Step 0 scoping, and the result reshapes findings rather
than scope — a surface that follows a recorded `Decision` still gets audited, it just gets the
capped Decision-tension write-up instead of a plain defect. The ethics gate outranks a recorded
Decision: a Decision to hide the recurring price is not a trade-off to respect; it is an
`ethics-gate.md` finding.

## Worked example

```
## Finding: Confirmation amount excludes the selected add-on
- **Surface:** app/checkout/Confirm.tsx:64; app/checkout/charge.ts:18
- **Evidence:** Confirmation says "$24 total"; the selected $6 add-on is included by the
  charge handler. Read the full confirmation block: it contains no $30 total.
- **Principle:** Cost transparency at commitment.
- **Risk:** The user approves $24 but is charged $30.
- **Fix:** Show the calculated $30 total beside the final action, with its itemized charges.
- **Severity:** Critical — the stated charge contradicts the amount collected.
- **Confidence:** High
```
