---
name: snitch-ux
description: Apply behavioral-design / UX-psychology and usability principles when designing, building, or reviewing any user-facing interface — landing pages, onboarding, sign-up, paywalls & pricing, forms, checkout, dashboards, empty states, navigation, mobile nav — or when asked to improve conversion, retention, engagement, reduce drop-off, 'make this clearer / feel premium / more polished', or write UI copy, CTAs, and microcopy, or judge the on-page hero, one-liner, tagline, and value prop against the visitor's decision path. Encodes two lenses — clarity (self-evident pages, scanning, conventions) and persuasion (defaults, anchoring, social proof, loss aversion, friction reduction, visual hierarchy) — as checkable moves, behind a blocking ethics gate that reports dark patterns instead of optimising them. The split across siblings is what the finding is judged against: ux owns what is evaluated against the user's decision path. Do NOT use for security review (use snitch-security), SEO / marketing audits or accessibility conformance and legal exposure (use snitch-marketing — it judges against search, traffic and conformance), one page's persuasion structure (use snitch-focusedcopy), drafting the hero, one-liner, and tagline options that fall out of positioning, plus brand story, naming, sales collateral, brand strategy, positioning docs and off-site channel content (use snitch-cmo — snitch-cmo drafts those options, this skill judges the one on the page and rewrites the microcopy around it), technical prose, READMEs and error-message style systems (use snitch-docwriter), or build-time decisions about what should exist at all (use snitch-blueprint).
license: MIT with Commons Clause
compatibility: Standalone skill — runs in any AI coding tool that loads Agent Skills (Claude Code, Codex, Cursor, GitHub Copilot, Gemini CLI, Windsurf, Goose, Cline, Zed, OpenCode, and 60+ more). Pure guidance; no server, tools, or external calls required.
metadata:
  author: Snitch
  version: 0.10.0
  homepage: https://snitchplugin.com
---

# UX Psychology

A field guide for making interfaces people actually finish, trust, and come back to. Two
lenses, in this order:

1. **Clarity — "don't make me think."** Users scan, satisfice, and muddle through. Make the
   page self-evident and remove every question mark you left behind (*is that a link? where
   am I? what does this mean?*). A confusing screen cannot be persuasive. (`clarity.md`)
2. **Persuasion — people don't decide logically.** Once a screen is clear, shape the choice:
   defaults read as recommendations, the first number sets the anchor, a gift creates a debt,
   building something makes it yours. (`principles.md`)

Both rest on one substrate — System 1 decides first, working memory holds about four things,
people run on mental models, and every "user error" is usually a design failure. When no
specific rule covers the situation, reason up from `substrate.md`.

**The one mental model:** every element on the screen is asking the user a question, and the
question you pose decides whether they act or hesitate. "Is this worth $19/mo?" is hard, and
its easy answer is "later." "Can I try this free?" is easy. Same product. Name the question
the screen really asks, then make it easy. When a call turns into an argument, stop debating
and watch three people use it (`usability-testing.md`).

## When to use this

Whenever you are shaping or critiquing a user-facing surface — building a page or flow,
writing CTA/microcopy, designing onboarding or a paywall, laying out a form or dashboard,
choosing a mobile nav, or answering "how do I make this convert / feel premium / stop people
bouncing." Use it **generatively** while building and as a **review lens** on existing UI.

A review covers the **whole product surface**, not the first screen you land on. Scope it
first (Step 0). A thorough pass over an agreed scope is the job; a skim of a few pages is the
failure mode.

## Findings

Read `finding-rules.md` before writing any finding. It holds the three evidence rules
(no finding without a citation, no summary claims, verify before you claim it), how absence is
evidenced, when defects merge or split, the severity bands, the two confidence axes, and the
worked example. Do not assign a Severity or Confidence value from memory.

```
- **Surface:** path/to/Component.tsx:47  — or —  /signup step 2, button[data-testid="continue"]
- **Evidence:** [the actual copy, markup, or described interaction — quoted]
- **Principle:** [the clarity or persuasion principle it violates]
- **Risk:** [what the user or the funnel actually loses — a behaviour or a number, not the Principle restated]
- **Fix:** [the specific change]
- **Severity:** Critical | High | Medium | Low
- **Confidence:** High | Medium | Low — report the lower axis and name which one limits
```

Every check ends as one of three outcomes: a **Finding** (evidenced), a **Pass** (carrying the
evidence that it ran), or a **Skip** (carrying the reason and what would unblock it). "Looked
fine" is none of the three.

**Report before you edit.** The review phase is read-only. Never rewrite a user's components
or copy mid-review — not the obvious ones, not even when they said "just fix everything."
Present the complete findings list, *then* offer to apply changes, confirming each one.

## Workflow

Two modes — **generative** (building) and **review** (auditing) — both starting at Step 0. Do
not skip it and start critiquing the first page you open; that is the main way this skill
under-delivers.

### Step 0 — Scope the surface and confirm intent

**Read the config first.** `snitch-ux.config.md` at the project root, falling back to the copy
beside this file (the defaults). It changes what you do next: the report's name and
destination, the minimum severity, which lenses run, the platform conventions, whether the
surface list is confirmed, whether the inclusion pass is forced, and how the copy pass's
scored lens runs. Read that file for the keys and their valid values — never assume a default.

**No config value touches the ethics gate.** `lenses` narrows what gets optimised;
`writing-system` narrows the scored copy lens; the gate runs at every setting.

- **Enumerate the full surface.** *In a codebase:* find every screen/page/flow — routes,
  page/view components, templates, layouts — **and** the states each has (default, empty,
  loading, error, success, logged-out). *On a live site:* walk the primary navigation and list
  the reachable pages and key flows.
- **Read the declared intent, if the workspace has one.** `BLUEPRINT.md` and
  `marketing/positioning.md` are read-only inputs; a best-practice fix that contradicts a recorded
  Decision is a **Decision tension**, an on-surface claim missing from the claim inventory is a
  finding, and neither file present is a Skip, never an interview. The rule is CONTEXT.md's
  Declared intent entry; the ux-specific step is in `finding-rules.md`.
- **Ask when scope or intent is unclear — ask, don't guess.** Which surfaces, the goal
  (conversion? clarity? accessibility? reduce a specific drop-off?), generative or review, and
  the audience/stakes (vulnerable users or high-stakes decisions? → `inclusive-design.md`).
  Present the enumerated list back and let the user confirm or narrow it.
- **When you cannot ask, state and proceed — never stop with nothing delivered.** In a
  non-interactive run, or with `confirm-scope: false`, write the assumption into the report's
  scope block, review everything you enumerated, and say so. **Assume up, never down** — if
  stakes are ambiguous, run the inclusion pass anyway and say you assumed the higher reading.
- **Set the coverage bar out loud.** Cover every in-scope surface; if it is too large, propose
  a prioritized subset and get agreement. Never silently truncate.

### Step 1 — For each in-scope surface, run the pass

**First, triage the surface type — most of this catalog does not apply to most screens.** The
catalog is dominated by acquisition moves, which primes a reviewer to go hunting for a number
to anchor and a count to make non-round. On a surface with no funnel, that pressure produces
invented findings. Name the type before you start:

- **Acquisition surfaces** — landing, pricing, paywall, checkout, sign-up, onboarding. The
  full catalog applies; run every move.
- **Working surfaces** — settings, admin, dashboards, editors, configuration, destructive
  actions. The persuasion half applies mainly *in reverse*: honest defaults, symmetry of exit,
  persuasion dialled **down**. Run clarity, friction, feedback and error design, defaults,
  state disclosure, the accessibility checks and the gate — and read `substrate.md` Part 2,
  the most useful file on this kind of screen. Anchoring, scarcity, social proof,
  goal-gradient, the brand message, taglines and paywall packaging are usually **not
  applicable**; recording them as Skips with that reason is the correct output.
- **Content surfaces** — docs, help, blog, empty states. Clarity, scanning, navigation and
  copy; most of the persuasion catalog is inert.

**A short review of a clean surface is a correct review.** The coverage bar is about not
skipping *surfaces*, not a quota of findings per surface. Five findings plus an explicit
not-applicable list beats twelve where seven were reached for.

The moves, in order. Cite them as "Step 1, move N".

1. **Locate the moment.** What is the user trying to do here, and what one question does the
   screen ask? Then check the primary action actually **works** — does the main control have a
   handler, does the form have an action, does the flow collect what it claims to? A button
   wired to nothing is a conversion defect before it is a design one, and everything else on
   the page is downstream of it. Grep for the handler rather than assuming.
2. **Clarity pass.** Is the page self-evident at a glance — obvious what it is, what's
   clickable, where you are? Remove the accidental question marks first (`clarity.md`).
3. **Diagnose friction & framing.** Where is the user doing unpaid work (blank fields, extra
   taps, decisions you could pre-make)? Is any number shown in isolation, with no anchor?
4. **Run the ethics gate — before you reach for a single persuasion technique.**
   `ethics-gate.md`, now, not at the end. If any check fails, those items are findings and you
   do not optimise them, whatever the user asked for — say so plainly in your first two
   sentences, then complete the review. The persuasion catalog is a loaded tool and this move
   decides whether the surface has earned it.
5. **Apply the relevant principles** (`principles.md`). Prefer the highest-leverage 2–4 for
   this surface; don't cram all of them. Everything from here assumes move 4 passed.
6. **Pass the copy — twice, because *what it says* and *how it is built* fail independently.**
   `copywriting.md` for specificity, verbs, possessives and needless words; then
   `writing-system.md` for prose mechanics, with its deterministic linter (Claude Code sets `${CLAUDE_SKILL_DIR}` to
   this skill bundle's own directory, the folder that contains this SKILL.md; in other hosts
   substitute the path where the bundle was loaded):
   ```
   python3 ${CLAUDE_SKILL_DIR}/scripts/copy-lint.py --mode strict -    # microcopy, CTAs, errors, empty states
   python3 ${CLAUDE_SKILL_DIR}/scripts/copy-lint.py --mode flavored -  # hero, tagline, brand narrative
   ```
   It reads stdin or a file and never writes one, so running it keeps the review read-only.
   The score goes in the finding's Evidence field. If python3 is unavailable, apply rules
   W1–W14 by hand and say so. For **brand-level surfaces** — hero, tagline, value prop,
   pricing, onboarding sequence — also check the *message* against `brand-message.md`.
   **Whatever copy you propose passes the same
   bar**, including the report's own prose (strict); note the result in one line near the
   coverage block.
7. **Review against `review-checklist.md`** before calling the surface done.
8. **Validate, don't debate.** When a call is contested or risky, frame it as "put this in
   front of 3 users" (`usability-testing.md`). Run the **parachute test** on any page with
   navigation (`navigation.md`).

### Step 2 — Report coverage honestly

```
Coverage: 3 of 11 surfaces reviewed — PARTIAL
Reviewed: /signup, /signup/verify, /onboarding/step-1
States seen: default only — empty / loading / error not reachable from static source
Not reviewed: /pricing, /checkout, /settings (+5) — out of agreed scope
Skipped checks: §9 conditionals — drag, auth (no such interaction); persuasion catalog on /settings (working surface)
```

- *Discovered* is the Step 0 enumeration; *Reviewed* is what you opened and ran the pass on.
  Label it **complete** only when the two numbers match, otherwise **partial**, naming what was
  left out and why.
- **Count states as well as surfaces.** The default state of one page is not that page. Name
  the states you could not reach, and say when a surface genuinely has only one.
- **List every surface you reviewed, including the ones that came back clean.** A Pass is a
  result; silence is not distinguishable from not having looked.
- **Record the Skips by name** — per surface and per conditional check. Skipping an
  inapplicable check is correct and costs nothing; not recording it is what turns coverage
  into a guess.
- **No silent sampling.** If you sampled, say you sampled, and say what you'd cover next.

Write the report to the path in `report-output` when the host can write files, and say where
you put it. That is the one write the review phase makes. If you cannot write a file, deliver
the same report inline and say which happened.

## References — and when to read each

| File | Read it when |
|---|---|
| `ethics-gate.md` | Always, at Step 1 move 4, before any persuasion move. The canonical gate; every other file states it in one line |
| `finding-rules.md` | Before writing any finding — evidence, absence, merge/split, severity, confidence, Decision tensions |
| `review-checklist.md` | At Step 1 move 7, on every surface. The operative audit tool |
| `clarity.md` | Step 1 move 2, and any "is this understandable" brief |
| `principles.md` | Step 1 move 5 — the persuasion catalog, indexed by its own Contents |
| `substrate.md` | When no rule covers the case, and on every working surface (Part 2: models, gulfs, signifiers, feedback thresholds, slips vs mistakes) |
| `navigation.md` | Any site with more than one screen (structure, page names, parachute test) or any bottom tab bar (the mobile component) |
| `copywriting.md` | Step 1 move 6 — what the copy says |
| `writing-system.md` | Step 1 move 6 — how the sentences are built, plus the linter and score bands |
| `paywalls.md` | Any surface that sells a subscription |
| `inclusive-design.md` | Vulnerable users, high-stakes decisions, `high-stakes: true`, or whenever stakes are ambiguous |
| `usability-testing.md` | A contested call, a novel pattern, or a question about whether a metric is honest |
| `brand-message.md` | Brand-level surfaces: hero, tagline, value prop, welcome blurb, onboarding narrative |

## Guardrails

The test: **would the user thank me if they saw how this was built?** Persuasion wins the tap;
the reservoir of goodwill decides whether they come back, and it empties faster than it fills
(`clarity.md`). Never spend it to close one conversion.

Three habits keep the psychology honest:

- **There is no neutral layout — so choose deliberately.** Every default, order, and emphasis
  nudges the decision whether you intend it or not. Since you cannot *not* influence, own it:
  arrange things toward the choice that is genuinely best for the user, and be able to defend
  the arrangement out loud.
- **Design for the person at their worst moment, not their best** — stressed, distracted, on a
  bad connection, in a crisis. Techniques that assume a calm ideal user turn cruel under
  stress, and the persuasion half should *reduce* for vulnerable users and high-stakes moments
  (`inclusive-design.md`).
- **Watch your own biases.** The shortcuts these techniques rely on run in *you*. Attractive
  designs are rated more usable than they are and reviewed less skeptically, so never let
  visual quality stand in for task success — the flows on the beautiful page get the same
  scrutiny as the plain one. Treat your instinct as a hypothesis and let watching real people
  overrule it (`usability-testing.md`).
