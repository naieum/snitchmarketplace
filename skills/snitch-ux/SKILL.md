---
name: snitch-ux
description: Apply behavioral-design / UX-psychology and usability principles when designing, building, or reviewing any user-facing interface — landing pages, onboarding, sign-up, paywalls & pricing, forms, checkout, dashboards, empty states, navigation, mobile nav — or when asked to improve conversion, retention, engagement, reduce drop-off, 'make this clearer / feel premium / more polished', or write UI copy, CTAs, taglines, value props, or brand messaging. Encodes two lenses — clarity (self-evident pages, scanning, conventions) and persuasion (defaults, anchoring, social proof, loss aversion, friction reduction, visual hierarchy) — as checkable moves, behind a blocking ethics gate that reports dark patterns instead of optimising them. Do NOT use for security review (use snitch-security) or SEO / marketing audits (use snitch-marketing) — the split is what the finding is judged against — marketing owns what is evidenced against search and traffic, ux owns what is evaluated against the user's decision path.
license: MIT
compatibility: Standalone skill — runs in any AI coding tool that loads Agent Skills (Claude Code, Codex, Cursor, GitHub Copilot, Gemini CLI, Windsurf, Goose, Cline, Zed, OpenCode, and 60+ more). Pure guidance; no server, tools, or external calls required.
metadata:
  author: Snitch
  version: 0.3.0
  homepage: https://snitchplugin.com
---

# UX Psychology

A field guide for making interfaces people actually finish, trust, and come back to. It
works on two lenses, in this order:

1. **Clarity — "don't make me think."** Before anyone can be persuaded, they have to
   understand. Users scan, they don't read; they pick the first reasonable option, not the
   best; they muddle through without reading instructions. So make the page **self-evident**
   — every question mark you leave in their head ("Is that a link? Where am I? What does this
   mean?") spends a little of their attention and their goodwill. Get rid of the question
   marks. (Depth in `references/clarity.md`.)
2. **Persuasion — users don't decide logically.** Once a screen is clear, shape the choice:
   defaults read as recommendations, the first number sets the anchor, a gift creates a
   debt, building something makes it yours, and even fake progress creates real momentum.

Both lenses rest on one **substrate — how the mind actually works.** People run on System 1
(fast, automatic, emotional) and spend System 2 (slow, effortful) as little as possible;
they perceive top-down, hold only ~4 things in working memory, decide emotionally then
rationalize, and build a *mental model* of how each thing works. Every rule in this skill is
a consequence of that. When a situation isn't covered by a specific rule, reason up from the
substrate: `references/psychology-foundations.md` (how the mind works) and
`references/interaction-model.md` (how a mind and a designed thing work together).

Design for how people actually think, not how you wish they thought — and when a decision
turns into an argument, **stop debating and watch three people use it**
(`references/usability-testing.md`).

## When to use this

Reach for this whenever you're shaping or critiquing a user-facing surface:
building/redesigning a page or flow, writing CTA/microcopy, designing onboarding or a
paywall, laying out a form or dashboard, choosing a mobile nav, or answering "how do I
make this convert / feel premium / stop people bouncing." Use it both **generatively**
(while building) and as a **review lens** (auditing an existing screen).

When it's a review, treat it as covering the **whole product surface**, not the first screen
you land on: scope it first (Workflow Step 0), and when the target, goal, or audience is
unclear, **ask the user rather than guessing**. A thorough pass over an agreed scope is the
job — a quick skim of a few pages is the failure mode to avoid.

## Evidence rules — what a finding has to carry

A design opinion costs nothing to state, which is exactly why an unevidenced one is worth
nothing. In review mode these three rules hold without exception; break them and the audit
becomes prose the user can't check, argue with, or act on.

1. **No finding without evidence.** You must have actually read the component (Read/Grep the
   file) or actually looked at the screen before you say anything about it — and you must
   cite what you looked at: file path + line, or screen/URL + the specific element. Evidence
   for a UX finding is that citation *plus* what the user is trying to do at that moment; a
   label is only confusing relative to a task.
2. **No summary claims.** "Several issues with the onboarding" is not a finding, it's a
   feeling. Every issue gets its own entry with its own evidence. If you can't name the
   surface and quote the copy, markup, or interaction — **or demonstrate its absence** — you
   haven't found anything yet.
   Absence is evidenced, not asserted: name what you searched and what came back empty — the
   search, the scope, and the count. "Grepped the template for `aria-live`; no matches, so the
   async result is announced to nobody." "No `<label>` or `aria-label` on any of the six inputs."
   "Read every handler in the file; nothing writes to storage, so the draft is lost on reload." Some of the most valuable findings in a UX review are things that
   are missing — no total shown before the charge, no tagline, no "you are here". A rule that
   only accepts quotable text would delete all of them.
   Those three examples are **lexical** absences: there is a token to search for, so the search
   *is* the evidence. The most valuable absences are usually **semantic** — no total, no tagline,
   no "you are here" — and nothing can be grepped for them, because what is missing is a meaning,
   not a string. Do not let that difference quietly delete them. A semantic absence is evidenced by
   naming **what you read in full, and what would have satisfied it**: "Read all 34 lines of the
   summary block; it lists three line items and a shipping method, and no element states a total —
   the largest number on the page is the $89 line item." That is checkable: a reader can open the
   same block and produce the total if it is there. What is never acceptable is the unscoped
   assertion — "there's no clear value proposition" names no sweep and no satisfying condition, so
   nobody can prove it wrong.
   **One defect, one entry.** When the same defect appears across N elements from one cause —
   a row of `onclick` spans with no keyboard handler, a gallery of images sharing an empty alt — that is
   one finding with the instances listed, not N findings. **The fix is the test**: one replacement
   that resolves them all is one finding; genuinely different fixes are separate findings even from
   a shared cause. It runs in reverse too: several defects on a single element can merge when one
   replacement resolves all of them — shared cause is not required in that direction. **When the
   tests above disagree, Cost is the tiebreak — one cost, one entry.** Merge the parts that cost the
   user the same thing; if writing the Cost field honestly needs an "and" joining two different
   losses, that is two findings however co-located the edit. An "Erase device" control with no
   confirmation, no statement of what is wiped, and an unassociated label is one finding — every
   part costs the user the same thing, destroying something without being told what. Bad copy, failing contrast and a dead link
   on one element are three — misread the offer, can't read it at all, click goes nowhere. Two
   claims that are separately untrue are separately findings, even when one deletion removes both.
   **Never settle a close call by dropping a defect**: when you still can't tell, file it as its own
   entry. Over-splitting costs a line; silent deletion costs the finding.

   **A merged finding takes the highest severity of its parts**, and its lesser parts travel with it:
   they are never demoted or dropped by `min-severity`, because merging must not become a way to
   lose a finding quietly. List each merged defect as its own bullet with its own evidence so a
   conformance pass can still recover it.
3. **Verify before you claim it.** After reading, check that the component actually does what
   you just said it does — that the button really is unlabelled, that the default really
   isn't pre-selected, that the price really is shown with nothing to compare it to. If the
   code or the screen doesn't support the claim, drop it. A retracted guess costs you one
   line; a wrong finding costs the user a change they didn't need.

The same discipline applies in generative mode whenever you critique existing code you're
building on.

### Finding format

```
- **Surface:** path/to/Component.tsx:47  — or —  /signup step 2, button[data-testid="continue"]
- **Evidence:** [the actual copy, markup, or described interaction — quoted]
- **Principle:** [the clarity or persuasion principle it violates]
- **Cost:** [what the user or the funnel actually loses — name a behaviour or a number, not the principle restated. "The decision gets deferred at the moment of highest intent" is a cost; "violates anchoring" is the Principle field again]
- **Fix:** [the specific change]
- **Severity:** Critical | High | Medium | Low
- **Confidence:** High | Medium | Low — lower axis first. When the two axes below differ, write both and say which limits: "Medium — High that the string is hardcoded and unsourced, Medium that the underlying claim is false"
```

**Severity rubric** — rate what it does to the user, not how much it bothers you:
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
  round social proof) is an ethics-gate finding at High — real, reportable, and not the same
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
- **Medium** — friction most users push through: extra taps, a blank field you could pre-fill,
  an unanchored number, a weak ask.
- **Low** — polish: tone, spacing, a label that could be sharper. Craft items live here — shadow
  tinting, card treatment, palette discipline, a glow that could guide the eye better. The page
  works and could read better.

**Where hierarchy rates — read this as part of the bands above, not as a footnote to Low.**
The word "hierarchy" covers two very different things in this skill, and they rate nowhere near
each other:

- **The reader cannot find where to start, or is pointed at the wrong thing → rate by effect,
  typically High.** Scanning is one of the three facts this whole skill rests on, so a page whose
  headings and body are all one size has no entry point, and that is not polish. Neither is
  **inverted hierarchy, which is the commoner failure**: emphasis pointed at the wrong element,
  rated by what the user misses rather than by how tidy the page looks. Ask which element the
  styling would have you act on, then whether that is the one that matters — a newsletter banner
  set larger than the field the user came to fill in; a "Skip" affordance heavier than the step it
  skips; a summary line that whispers the part the reader is accountable for.
- **The entry point is findable and the emphasis is right, but the craft could be better → Low.**
  Untinted shadows, a list that would read better as cards, an unremarkable palette. These sit
  under "visual hierarchy" in the cheat sheet and in `principles.md`, and they are not what the
  High rule above is about. Do not rate a shadow like a missing entry point.

The test between them: **can the reader tell where to start and what matters?** If no, High. If
yes and it could simply look better, Low.

Confidence is a separate axis, and it has **two** things to separate. State which you mean
when they differ:
- *Artifact confidence* — how well you could see the thing. **High** when you read the
  component and the behavior is unambiguous, **Medium** when it depends on data or state you
  couldn't see, **Low** when you're inferring from a screenshot or a partial render.
- *Judgement confidence* — how sure you are the claim is true given what you saw. You can read
  `Only 2 spots left` perfectly (artifact High) and still not know whether it's false, because
  that depends on a business fact you can't check (judgement Medium). Report the lower of the
  two and name which one is doing the limiting — "High that the string is hardcoded and
  unsourced; Medium that the underlying claim is false" tells the reader what to go check.

A low-confidence Critical is still
worth reporting — it just gets reported as one.

Worked example:
```
## Finding: Plan price shown with nothing to compare it to
- **Surface:** app/pricing/PlanCard.tsx:64
- **Evidence:** `<span className="price">$19/mo</span>` — the only number on the card: no
  second plan, no crossed-out reference, no per-day breakdown.
- **Principle:** Anchoring / contrast — never show a cost in isolation.
- **Cost:** The user answers "is this worth $19?" (hard question, easy answer "later")
  instead of "which plan?" — the decision gets deferred at the moment of highest intent.
- **Fix:** Render the annual plan beside it as the default-selected option with the monthly
  equivalent struck through, so $19 is read against a number you chose.
- **Severity:** High — this is the decision point the whole funnel feeds.
- **Confidence:** High
```

### Report before you edit

The review phase is read-only. **Never rewrite a user's components or copy mid-review** — not
the obvious ones, not even when they said "just fix everything." The design is theirs until
they say otherwise, and a review that quietly mutates the thing it's reviewing leaves the
user unable to tell what you found from what you changed.

Present the complete findings list first. *Then* offer to apply changes, and confirm each one
before touching a file. Reviewing and changing are two phases, always in that order.

## The one mental model

> **Every element on the screen is asking the user a question.** The question you pose
> determines whether they act or hesitate.

Before touching a screen, name the question it's really asking. Then make that question
*easy*. "Is this worth $19/mo?" is a hard question with the easy answer "later" (= never).
"Can I try this free?" is an easy question with the answer "yes." Same product — different
question. That reframe is most of the game.

Two kinds of questions live on a screen, and they map to the two lenses. There are the
questions *you pose on purpose* (the persuasion above). And there are the ones you leave by
accident — the **question marks** you leave behind: *Is that clickable? What does this label
mean? Where am I? Did I land on the right page?* Those are pure friction. **First remove the
accidental questions (clarity), then make the intentional one easy (persuasion).**

### How people really use interfaces

Design for the real user, not the attentive one you imagine. Three facts (detail in
`references/clarity.md`):

- **They scan, they don't read** — glancing for words that match their task, like a
  billboard at 60 mph. So *design great billboards*: strong visual hierarchy, few words.
- **They satisfice** — they click the *first reasonable* option, not the best. Make the
  first plausible label the right one.
- **They muddle through** — they don't read instructions or build a mental model, and stick
  with whatever works. So make it self-evident; don't rely on explanation.

Corollary: the **Back button is the lifeboat** — never break it or strand the user.

## Workflow

This runs in two modes — **generative** (building something new) and **review** (auditing
existing UI). Both start by establishing scope. **Do not skip Step 0 and start critiquing the
first page you open** — that's the main way this skill under-delivers.

### Step 0 — Scope the surface and confirm intent (always do this first)

**Read the config first.** Optional settings live in `snitch-ux.config.md` — look for it at the
project root, falling back to the copy shipped next to this SKILL.md (which holds the defaults).
It can change what you do next, so read it before enumerating anything:

| Key | Effect |
|---|---|
| `tool-name`, `report-title` | White-label the name and heading used throughout the output |
| `min-severity` | Findings below this severity move to a **Minor** section at the end of the report — never dropped silently. Nothing is deleted for being small |
| `lenses` | Restrict the review to clarity, persuasion, or both. **Never restricts the Step 3.5 ethics gate** — the gate runs at every setting, and no config value can turn it off |
| `platform` | Which conventions apply — web, iOS, Android |
| `report-output` | Where the report is written |
| `confirm-scope` | Whether to confirm the surface list with the user before reviewing |
| `high-stakes` | Forces the `inclusive-design.md` pass regardless of what scoping concluded |

Before building or reviewing anything, work out *exactly* what you're covering and why. Do
not sample a couple of screens and proceed.

- **Enumerate the full surface.** Build the actual list of user-facing surfaces in scope,
  don't assume it's one or two:
  - *In a codebase:* find every screen/page/flow — route definitions, page/view components,
    templates, layouts — **and** the states each one has (default, empty, loading, error,
    success, logged-out). Search the routing/pages directory; don't stop at the first file.
  - *On a live site/app:* walk the primary navigation and list the reachable pages and key
    flows (signup, checkout, onboarding, settings).
- **When you cannot ask, state and proceed — never stop with nothing delivered.** "Ask, don't
  guess" assumes a host that can pause for an answer. In a non-interactive or batch run — no
  question tool, no one there, or `confirm-scope: false` — do not stall and do not silently pick:
  write the assumption into the report's scope block ("Assumed scope: the single file supplied;
  goal assumed to be a general review; not confirmed with the user"), review everything you
  enumerated, and say so. The same applies to any Step 0 question you could not put to anyone,
  including audience and stakes: if the domain is ambiguous and you cannot ask, run the
  `inclusive-design.md` pass anyway and note that you assumed the higher-stakes reading. Assume up,
  never down — the cost of an unnecessary inclusion pass is a few paragraphs; the cost of skipping
  a needed one lands on the user.
- **Ask the user when anything about scope or intent is unclear — ask, don't guess.** Use a
  direct clarifying question (the host's question tool) *before* starting if you don't know:
  which surfaces to cover, the **goal** (conversion? clarity? accessibility? "make it feel
  premium"? reduce a specific drop-off?), whether this is generative or a review, the
  **audience/stakes** (any vulnerable users or high-stakes decisions? → `inclusive-design.md`),
  or which single flow matters most. Present your enumerated surface list back and let the
  user confirm or narrow it.
- **Set the coverage bar out loud.** State which surfaces you will review. Cover **every**
  in-scope surface against the passes below — not a representative few. If the surface is too
  large to cover fully, propose an explicit prioritized subset and get agreement; never
  silently truncate and imply you covered everything.

### Step 1 — For each in-scope surface, run the pass

Work the list surface by surface. For a real review, **actually open the relevant reference
files** — don't work from the cheat sheet alone.

**First, triage the surface type — most of this catalog does not apply to most screens.** This
skill's cheat sheet is dominated by acquisition moves, and its worked example is a pricing card,
which primes a reviewer to go hunting for a number to anchor and a count to make non-round. On a
surface with no funnel, that pressure produces invented findings. Name the type before you start:

- **Acquisition surfaces** — landing, pricing, paywall, checkout, sign-up, onboarding. The full
  catalog applies. Run every step below.
- **Working surfaces** — settings, admin, dashboards, editors, configuration, destructive actions.
  Here the persuasion half applies mainly *in reverse*: honest defaults, symmetry of exit,
  persuasion dialled **down** (`inclusive-design.md`). Run clarity, friction, feedback and error
  design, defaults, state disclosure, §9 and §10 — and read `references/interaction-model.md`,
  which is the most useful file on this kind of screen and is otherwise easy to miss because it
  is filed as background. Anchoring, scarcity, social proof, goal-gradient, brand messaging,
  taglines and paywall packaging are usually **not applicable**, and recording them as such is
  the correct output.
- **Content surfaces** — docs, help, blog, empty states. Clarity, scanning, navigation and copy;
  most of the persuasion catalog is inert.

**A short review of a clean surface is a correct review.** The coverage bar in Step 0 is about not
skipping *surfaces*; it is not a quota of findings per surface. Five findings plus an explicit
not-applicable list beats twelve where seven were reached for. If a whole section of the catalog
did not apply, say which and why — that is coverage, not thinness. Padding a working surface with
acquisition findings is the failure mode this triage exists to prevent.

1. **Locate the moment.** What is the user trying to do here, and what's the one question this
   screen asks? (sign up? pay? pick? log? trust you?)
   Then check the primary action actually **works**: does the main control have a handler, does the
   form have an action, does the flow collect what it claims to collect? A button wired to nothing
   and a checkout that takes no payment details are conversion defects before they are design
   ones, and every other finding on the page is downstream of them. Grep for the handler rather
   than assuming the button does something.
2. **Clarity pass first.** Is the page **self-evident** at a glance — obvious what it is,
   what's clickable, where you are? Remove the accidental question marks before anything else
   (`references/clarity.md`). A confusing screen can't be persuasive.
3. **Diagnose friction & framing.** Where are they doing unpaid work (blank fields, extra
   taps, decisions you could pre-make)? Is the framing a gain (weak) or a loss (strong)? Is
   any number shown in isolation (no anchor)?
3.5. **Run the ethics gate — before you reach for a single persuasion technique.**
   Check `references/review-checklist.md` §10 now, not at step 6. Does every countdown,
   scarcity claim, social-proof number, and loss frame already on the surface reflect
   something **true**? Is the cost stated where the decision is made? Is leaving as easy as
   joining? Are paid options opt-in rather than pre-checked?
   **If any answer is no, those items are findings, and you do not optimise them — whatever
   the user asked for.** The test is general — **any** design that gets the tap by making the
   user believe something untrue, or by hiding what it costs them to say yes — and these are
   illustrations of it, not the list to match against: fabricated urgency, fake scarcity, hidden
   recurring costs, confirmshaming, phone-only cancellation. A pattern that is not named here
   still fails the gate if it meets the test. When someone says "improve conversion" on such a
   surface, say plainly in your first two sentences that you are not going to tune those, and why. Then do the review: report them as findings and give the honest
   conversion work instead. This ordering is not optional — the persuasion catalog at step 4
   is a loaded tool, and this step decides whether the surface has earned it.
   The convenient truth, most of the time: the dishonest items are *also* the conversion
   problems. A charge the user only discovers at renewal is both the ethics failure and the reason the funnel leaks
   at renewal. You will rarely have to choose between being honest and being useful.
4. **Apply the relevant principles** (cheat-sheet below; depth in `references/principles.md`).
   Everything from here on assumes Step 3.5 passed. These techniques make an honest offer
   legible; they do not make a dishonest one acceptable, and several of them actively worsen a
   surface that failed the gate — softening a commitment verb on a page that hides its price
   removes the user's last warning. If the gate failed, the finding is the dishonesty, not the
   wording.
   Prefer the highest-leverage 2–4 for this surface — don't cram all of them.
5. **Pass the copy** through `references/copywriting.md` (specificity, possessive, verbs, and
   omit needless words). For **brand-level surfaces** — home hero, tagline, value prop,
   pricing page, onboarding sequence, pitch copy — also check the *message* against
   `references/brand-messaging.md` (problem-first, five sound bites, one controlling idea);
   for taglines, names, and headline-scale lines use `references/taglines-and-naming.md`,
   and for funnel collateral (lead magnets, pricing framing, CTAs/closes, sales emails) use
   `references/messaging-campaign.md`.
6. **Review** against `references/review-checklist.md` before you call the surface done —
   including the accessibility/inclusion and ethics gates.
7. **Validate, don't debate.** When a call is contested or risky, don't argue from opinion —
   frame it as "put this in front of 3 users" (`references/usability-testing.md`). Run the
   **parachute test** on any page with navigation.

For anything with a **bottom tab bar / mobile navigation**, read
`references/mobile-navigation.md` — hard rules (tab count, sizes, active states). For
**site-level navigation, page names, breadcrumbs, tabs, and home-page big-picture**, see
`references/site-navigation.md`.

### Step 2 — Report coverage honestly

Every review states its coverage in the report itself — surfaces **reviewed** against surfaces
**discovered** — and carries a label:

```
Coverage: 3 of 11 surfaces reviewed — PARTIAL
Reviewed: /signup, /signup/verify, /onboarding/step-1
States seen: default only — empty / loading / error not reachable from static source
Not reviewed: /pricing, /checkout, /settings (+5) — out of agreed scope
```

**Count states as well as surfaces.** Step 0 enumerates the states each surface has, so the
coverage block has to be able to say which ones you actually saw — a review of the default state
of one page is not a review of that page. Where a state exists but you could not reach it (needs
data, needs auth, only rendered by JS you did not run), name it in `States seen` rather than
letting it pass as covered. Where a surface genuinely has one state — a static file, a fragment —
say that too; "one state, and that is all there is" is a result, whereas silence is not
distinguishable from not having looked.

Write the report to the path in `report-output` (see the config table in Step 0) when the host can
write files, and say in your final message where you put it. This is the one write the review
phase makes: the report is yours to create, the user's design is not yours to touch. If you cannot
write a file, or the caller gave you a different destination, deliver the same report inline and
say which happened.

- *Discovered* is the Step 0 enumeration. *Reviewed* is what you actually opened and ran the
  pass on. Label the review **complete** only when those two numbers match; otherwise it is
  **partial**, and a partial review names what was left out and why (out of agreed scope,
  unreachable, needs credentials, ran out of room).
- **No silent sampling.** Looking at three screens and writing a report that reads like a
  product-wide audit is the failure mode this whole skill exists to avoid. If you sampled, say
  you sampled, and say what you'd cover next.
- List **every surface you reviewed** with its findings, *including the ones that came back
  clean*. A surface you checked and found nothing wrong with is a result — it's the only way
  the user can tell coverage from silence.

## Cheat sheet — the principles

**Make it self-evident (clarity — do this first)** — see `references/clarity.md`
- **Don't make me think** — a page should be understood at a glance; kill every question mark (*is that a link? where am I? what does this mean?*).
- **Design for scanning (billboard)** — strong visual hierarchy (prominence + grouping + nesting), few words, clearly defined page areas. People scan, they don't read.
- **Obvious clickability** — buttons look like buttons, links like links; never make users wonder what's clickable.
- **Use conventions** — the familiar pattern (logo top-left links home, hamburger, cart icon) needs no explaining; innovate only when your idea is clearly better and everyone says "wow."
- **Mindless clicks > few clicks** — the 3-click rule is a myth; ambiguity tires people, not clicks. Three mindless clicks beat one that makes you stop and think.
- **Minimize noise** — treat every element as visual clutter until it earns its place.
- **Navigation is the site** — Site ID, sections, a way home, a search box; page names that match the link clicked; obvious "you are here." Pass the **parachute test** (`references/site-navigation.md`).
- **Convey the big picture** — a first-time visitor knows *what is this, what can I do, why here* from the tagline + welcome blurb (`references/site-navigation.md`).

**Reduce the thinking (cognitive load)**
- **Smart defaults** — pre-select the most common choice; most people never change a default and read it as a recommendation (a strong tendency, not a fixed rate — it depends on how consequential and reversible the choice is). Never show a blank form you could pre-fill. **Never pre-select a charge or a consent** — that is an ethics-gate failure, not a default.
- **Choice reduction** — cut, group, or stage choices; one obvious primary action per screen. Works when the options are genuinely hard to tell apart; it is not a law that fewer always converts better.
- **Reduce interaction cost** — every removed tap/field/step improves UX. Surface content directly instead of behind banners; offer selection over free-text; show options as visible swatches, not dropdowns.
- **Progressive disclosure** — keep the first view clean; reveal advanced options on demand (reward the click).
- **Recognition over recall** — show faces/icons/thumbnails/recents so users recognize instead of remember.
- **Match input to context** — sliders/pickers for casual one-time setup; steppers/number fields for frequent, precise, repeated entry.

**Create motivation & commitment**
- **The convergence model (diagnostic)** — a behavior happens only when *motivation + ability + a prompt* line up at once. When a user doesn't act, exactly one is missing: too hard (fix ability/friction), not wanted enough (fix motivation/timing), or no clear cue (fix the prompt). Easing effort usually beats pumping motivation. (`references/psychology-foundations.md`.)
- **Goal-gradient / never start at zero** — give an artificial head start; a progress meter that begins at ~20% and is never empty. Count something they've already done.
- **Endowment / build-it effect** — let users build/choose/customize *before* you ask for commitment; people value what they made. Button says "Continue," not "Sign up."
- **Loss aversion** — losing hurts ~2× more than gaining pleases. Frame the cost of *inaction* ("you'll lose X"), not the gain — **only where the loss is real**. Dismiss reads "I'll risk it," not "Maybe later" — but a dismiss *names a consequence*, it never mocks the person choosing it. "No thanks, I don't want to save money" is confirmshaming, which is this rule turned abusive (`copywriting.md`).
- **Commitment & consistency** — surface the small decision they already made so the remaining one feels tiny.
- **Reciprocity** — give real value *before* asking for anything (partial result, free sample, trial). The ask never feels like a wall.

**Persuade & build trust**
- **Anchoring / contrast** — never show a cost in isolation; control the first number. Show a % of a larger whole, a crossed-out reference price, or the total up front.
- **Social proof & halo** — specific, non-round counts ("4.9 ★, 221 reviews," "500+ this week") and status badges ("best-seller") shift risk perception. Round numbers feel fake.
- **Transparency bias** — proactively revealing a downside (upcoming charge, reminder before trial ends) *increases* trust and conversion.
- **Specificity = trust** — exact numbers kill doubt ("start in 2 taps," "23 min") better than adjectives ("quick," "fast"). Doubt is the most expensive thing in your UI.
- **Sell safety, not the pitch** — people convert from a safety net (free cancellation, money-back, "cancel anytime") placed *at the moment of hesitation*, not from harder selling.

**Message the brand as a story (brand-level surfaces: hero, tagline, value prop, pitch)** — see `references/brand-messaging.md`
- **Customer is the hero, you are the guide** — never open with the company, category, or backstory. A product is a rope, and a rope is only valuable to someone in a hole: lead with the customer's problem or the product has no value.
- **Five sound bites (PEACE)** — Problem, Empathy, Answer, Change, End result. Five zero-nuance, repeatable lines that each work alone as an ad and together read as one sentence ("Have you ever worried about money? We know how you feel. Download the app and get good at money — so you'll never worry about money again."). The full script adds: a three-step plan, a direct CTA, stakes (success *and* failure), and the customer's villain.
- **The one-liner** — the memorized answer to "what do you do?": problem → concrete product → specific result, closing the exact story loop the problem opened.
- **Controlling idea** — people carry away *one* thing; be known for something specific ("get good at money," "best serve in the game"), make it the tagline, and let it govern every downstream asset. Marketing is an exercise in memorization: repeat it verbatim for years.
- **Curiosity, not education** — the first touch's only job is "that sounds like me — tell me more." Explanation, proof, and nuance belong deeper in the funnel, never in the hero (`references/messaging-campaign.md` for the full funnel collateral, pricing framing, and closing scripts).
- **Weigh the copy; audit the leaks** — the header weighs zero pounds of cognitive load; run the Sharpie test (10+ problem mentions on the homepage) and the 5-second test (what problem? what's life after? how do I buy?). Taglines and names get their own tests (`references/taglines-and-naming.md`).

**Direct attention (visual hierarchy)**
- **Emphasize values, not labels** — rank elements by importance first; make the data big and the label quiet.
- **Differentiate with size / weight / color / position** — uniform styling kills hierarchy; vary deliberately, add an icon cue.
- **Show real content, not decoration** — people can't commit to what they can't visualize; show the actual thing in context over abstract hero art.
- **Cards over plain lists**, **soft shadows tinted to the background**, **bold type as hierarchy**, **minimalism** (every element earns its place), **glow/color to guide the eye**.

**Working surfaces — settings, admin, anything destructive** — see `references/review-checklist.md` §5.5
- **Match the guard to the damage** — reversible → undo; slow to reverse → confirm; irreversible → a typed check or a real constraint. Warnings are weaker than constraints (`references/interaction-model.md`).
- **Name the blast radius** — "Are you sure?" says nothing; "permanently deletes this channel and its 4,200 messages for all 31 members" says what is lost, how much, and who else it hits.
- **Make the current state readable** — no negated labels over checked boxes, no toggle whose polarity you have to guess, no value that won't say whether it's the default or the user's saved choice.
- **Say when it commits** — auto-save, explicit save, and save-on-blur each need a visible answer, and "Cancel" must mean something on an auto-saving page.
- **Undo beats confirmation** wherever the action can be held briefly — it costs nothing when the user meant it.

**Feedback, personalization & delight**
- **System feedback** — every action gets an immediate, satisfying response (state change, live-updating value, instant consequence like a new balance).
- **Micro-interactions** — tap feedback (scale/ripple), animated active states, soft screen transitions.
- **Empty states as opportunities** — never a dead end; explain the value, add an illustration, give a CTA.
- **Smart search** — on focus, offer recents / popular / personalized suggestions instead of a blank box.
- **Lifecycle personalization** — new vs returning vs power users see different first screens; use their name.
- **Emotional / sensory copy** — descriptive language ("beachside escape, steps from the sand") activates imagination before price.

**Paywalls & upgrade screens** — see `references/paywalls.md`
- **The paywall is a flow, not a screen** — sell the outcome during onboarding so the price screen collects a decision already made; multi-page beats single-page.
- **Risk reduction beats pressure** — a step-by-step trial timeline ("day 5: we remind you"), a "cancel anytime" CTA subtitle, and an exit-intent downsell outperform urgency.
- **Friction is a dial** — a card-wall halves trials but can 5× paid conversion; removing the wall entirely can lift trial starts. Match the friction to the metric that matters.
- **Two plans max, annual default, table sells by loss** — and anchor price to something already bought (weekly cost, "less than a coffee").

**Mobile & reachability** (see `references/mobile-navigation.md`)
- **Thumb zone** — put primary actions where a thumb reaches one-handed.
- **Tap targets** — the conformance *floor* is 24×24 CSS px (WCAG 2.2 AA, 2.5.8). The criterion
  carries exceptions, so a smaller target can still conform: most often Spacing (a 24px-diameter
  circle centered on the target's bounding box intersects no other target, nor another undersized
  target's circle — overlapping non-target content is fine), but also Inline targets in a sentence,
  an Equivalent control elsewhere on the page, user-agent-controlled sizing, and Essential
  presentation. Check the exception before calling it a failure. The *target* to design to is
  44×44 (Apple HIG 44pt, WCAG 2.2 AAA 2.5.5) or 48×48dp on Material. Cite 24 when you're stating
  a standard, 44–48 when you're giving advice.
- **Bottom nav: 3–5 tabs; ≥2 active-state cues; separate it from content; neutral colors; badges sparingly.**

## References
- `references/psychology-foundations.md` — the substrate: how the mind works (System 1/2, perception, memory, attention, motivation, emotion, error, decision). The *why* under every rule.
- `references/interaction-model.md` — how interaction works: conceptual models, the gulfs of execution & evaluation, affordances vs. signifiers, mapping, feedback, constraints, slips vs. mistakes.
- `references/clarity.md` — the clarity lens: the three laws of clarity, scanning/satisficing/muddling, billboard design, conventions, the reservoir of goodwill, accessibility quick wins.
- `references/site-navigation.md` — site-level navigation (persistent nav, page names, "you are here", breadcrumbs, tabs), the parachute test, and the home-page big picture (tagline vs. motto).
- `references/usability-testing.md` — validate don't debate: cheap testing (3 users, one morning a month), get-it vs. task testing, triage, the myth of the average user, and measuring honestly.
- `references/inclusive-design.md` — who the user really is: the full range of ability/culture/attention, cognitive inclusion, localization, and when to dial persuasion *down* for vulnerable users and high-stakes moments.
- `references/principles.md` — full persuasion catalog: each principle with the psychology, the rule, and do/don't.
- `references/copywriting.md` — CTA & microcopy patterns (verbs, possessives, numbers, framing, omit needless words).
- `references/brand-messaging.md` — brand-level message, adapted from a widely used
  story-structure framework for brand narrative: customer-as-hero / brand-as-guide, the five PEACE sound bites plus the full script (three-step plan, CTA, stakes), the one-liner, the villain rules, the controlling idea, message audits (cognitive-load weighing, Sharpie test, 5-second test), where the founder's story belongs, and the funnel zones.
- `references/taglines-and-naming.md` — taglines (offer-not-vibe, name-strip and stranger-guess tests, category+twist, command taglines, name/tagline division of labor), naming rules (bullseye test, outcome-not-mechanism, bridge words, feature naming), and billboard-scale copy rules for any 3-second surface.
- `references/messaging-campaign.md` — deploying the message as a campaign: the 5-3-3 structure (curiosity → enlightenment → commitment), staged disclosure, lead generators, entry offers and product ladders, pricing/premium framing, the decision-trigger close and sales-copy structures, repetition discipline, and the bad-news/crisis playbook.
- `references/mobile-navigation.md` — bottom-nav / tab-bar hard rules (the mobile component).
- `references/paywalls.md` — paywalls & upgrade screens: paywall-as-flow, risk-reduction patterns (trial timeline, cancel-anytime, exit-intent downsell), qualifying friction vs. pay-ramps, packaging rules (two plans, annual default, loss-framed tables), and paywall-specific dark patterns (fake-urgency wheels, cancel asymmetry).
- `references/review-checklist.md` — a screen/flow audit to run before shipping.

## Guardrails
These techniques are for helping users decide and act with less friction — not for
tricking them. Loss framing, urgency, and social proof must reflect something **true**
(a real streak, a real deadline, real counts). Fabricated scarcity, fake reviews, or
buried cancellation are dark patterns: they win the tap and lose the trust.

Think of every user as arriving with a **reservoir of goodwill**: each friction and
each broken promise lowers it, a single bad move (a giant required form, a hidden fee
sprung late) can empty it, and honest, considerate design refills it. Persuasion wins the
tap; goodwill decides whether they come back — never spend the reservoir to close one
conversion. **Do right by the user:** tell people what they want to know up front, don't ask
for what you don't need, and when in doubt, apologize. The test stays the same: "would the
user thank me if they saw how this was built?"

Three more habits keep the psychology honest:

- **There is no neutral layout — so choose deliberately.** Every default, order, and
  emphasis nudges the decision whether you intend it or not. Since you can't *not* influence,
  own it: arrange things toward the choice that's genuinely best for the user, and be able to
  defend the arrangement out loud.
- **Design for the person at their worst moment, not their best.** The real user may be
  stressed, distracted, on a bad connection, in a crisis, or an edge case you find
  inconvenient. Techniques that assume a calm, ideal user (dense forms, urgency, buried
  escape hatches) turn cruel under stress. Pressure-test the flow against the anxious user.
- **Design for the full range of people, and know when to dial persuasion down.** The calm,
  capable, Western, neurotypical user this skill quietly assumes is rare. For the real range
  of ability, culture, literacy, and attention — and for vulnerable users and high-stakes
  moments (children, elders, health/money/crisis) where the persuasion half should *reduce*,
  not intensify — see `references/inclusive-design.md`.
- **Watch your own biases.** The same shortcuts these techniques rely on run in *you* — you
  overweight the vivid demo, assume users are like you, and see the pattern you hoped to
  find. Treat your instinct as a hypothesis, and let watching real people (see
  `references/usability-testing.md`) overrule it.
