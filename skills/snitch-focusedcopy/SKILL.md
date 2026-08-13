---
name: snitch-focusedcopy
description: Structure persuasive on-page copy — landing pages, pricing pages, sales/waitlist pages, cold emails, ad or VSL scripts — around the CLOSER framework (Clarify why they're here, Label the right visitor, Overview the pain, Sell the outcome before the mechanism, Explain objections, Reinforce the decision), adapted from Alex Hormozi's live-sales-call structure to written pages. Audits an existing page's section order and stage coverage, then reorders sections and tightens copy to close gaps, verifying every claim against the actual product before it is written. Triggers on "structure this page like a sales call", "apply the CLOSER framework", "this page isn't converting", "reorder these sections for persuasion", "who is this landing page for", "handle objections on this page", "make this pitch land", "sell the outcome not the mechanism". Do NOT use for SEO / technical marketing audits (use snitch-marketing), broader UX / interaction / dark-pattern review (use snitch-ux), or plain technical prose (use snitch-docwriter) — this skill owns persuasive narrative STRUCTURE and stage-by-stage copy only, and it must never invent a claim just to fill a stage.
license: MIT with Commons Clause
compatibility: Standalone skill — runs in any AI coding tool that loads Agent Skills (Claude Code, Codex, Cursor, GitHub Copilot, Gemini CLI, Windsurf, Goose, Cline, Zed, OpenCode, and 60+ more). Pure guidance; no server, tools, or external calls required.
metadata:
  author: Snitch
  version: 0.1.0
  homepage: https://snitchplugin.com
---

# Snitch: Focused Copy

A structure system for persuasive copy, built on **CLOSER** — the six-stage sales-call
framework Alex Hormozi teaches in *$100M Leads* (Clarify, Label, Overview, Sell, Explain,
Reinforce). A live sales call and a landing page do the same job — take a stranger from "why
am I here" to "I'm in" — but a call has a human on the other end asking questions and
handling objections turn by turn. A page has none of that: every stage has to happen through
copy and layout alone, in the order the reader scrolls. That's the adaptation this skill
makes: six stages a rep would walk through out loud, rebuilt as six jobs a page's *sections*
have to do, in order.

Most pages that "aren't converting" already have four or five of the six stages somewhere on
them. They're just out of order (mechanism explained before the reader has a reason to care),
duplicated (three sections all doing Overview, none doing Reinforce), or missing outright
(no stage ever tells the reader "you're the right fit," so unqualified traffic never
self-selects and never leaves either). The fix is usually reordering and trimming what's
already there, not a rewrite.

## Scope

**Applies to:** landing pages, pricing pages, sales/waitlist pages, onboarding pitches,
cold emails, ad copy, VSL/UGC video scripts, pitch decks — any single piece of copy or short
funnel whose job is to move a stranger toward a specific decision.

**Never applies to:** technical docs, READMEs, error messages, or anything that should read
as neutral instruction, not persuasion (use snitch-docwriter). Not a substitute for
snitch-marketing (search/AI-citation/schema mechanics) or snitch-ux (interaction design,
usability, dark-pattern review across a whole product) — this skill only owns whether a
specific piece of persuasive copy tells its story in the right order, using true claims.

snitch-marketing's category 114 ("Persuasion architecture") also touches this territory but
does a different job: it's a whole-site, evidence-tiered research audit that *scores* seven
psychology surfaces against academic literature (0–175, letter grade). This skill doesn't
score or research — it applies one named, practical framework (CLOSER) to reorder and rewrite
a specific page or funnel directly. Reach for cat 114 when you want a holistic, cited audit
of a whole site; reach for this skill when you just need one page's persuasion arc fixed.

## The six stages

Adapted for written copy, not a live call:

- **C — Clarify.** State plainly what this is and why the reader is here, in language they
  could repeat back. On a page this is almost always the headline + subhead. If a stranger
  can't answer "what is this and is it for me?" from the first screen, nothing later matters.
- **L — Label.** Tell the reader whether they're the right fit *before* you try to sell them
  anything — a short "this is for you if / not the fit if" block works well. A call does this
  by asking questions; a page has to do it by stating who it's for and, ideally, who it
  isn't. Disqualifying some readers is what makes the qualification credible.
- **O — Overview the pain.** Name the specific situation the reader is in, in words they'd
  use themselves, before presenting the solution. Concrete and recognizable beats generic
  ("we solve inefficiency"). This is where a fair, specific comparison against the status quo
  or a named alternative belongs.
- **S — Sell the outcome, not the mechanism.** Hormozi's line for this is "sell the vacation,
  not the plane ride": lead with the transformation the reader gets, then explain how it
  works. The most common bug in SaaS copy is doing this backward — opening with architecture,
  model names, or feature lists before the reader has a reason to care what powers any of it.
  Outcome first, mechanism second, always.
  - The mechanism explanation still belongs on the page. It answers "how" for a reader who
    is already sold on "why" — it just runs after the Sell stage, not before it.
- **E — Explain away objections.** Answer the specific reasons a reader would talk themselves
  out of the decision — price, trust, switching cost, "what's the catch," "is this too good
  to be true" — proactively. An FAQ is the natural home for this stage, but only if the
  questions are the reader's *real* objections, not softballs.
- **R — Reinforce the decision.** At the point of action, confirm they're making a smart
  choice. Real urgency or scarcity if it's true, a plain restatement of the deal, social proof
  if you have it. This is the stage most pages skip entirely, going straight from features to
  a bare CTA button with nothing reinforcing the click.

A single page rarely needs to force all six stages into six separate sections — a strong
hero can do Clarify and half of Sell at once, and a long page can spread the arc across
several screens or, for a funnel, several separate pages (ad → landing page → pricing page →
email). What matters is that the *order* holds: nothing from a later stage should have to
appear before an earlier one has done its job, and no stage should be skipped without a
reason.

## The anti-fabrication gate (read this before writing any copy)

**Every claim placed under Overview, Sell, or Reinforce must be checked against the actual
product before it is written down.** This is not optional and it is not a style note — it is
the difference between a persuasive page and a false one. Concretely:

- Before writing an absence claim ("no X," "never Y," "unlimited Z"), search the actual
  implementation (code, config, contract, pricing sheet) for whatever would make that claim
  false. A limit that exists anywhere in the system means the claim is false, even if it's
  generous. State the true, favorable version instead ("a substantial 5-hour window," not
  "no 5-hour windows") — being honest about a real limit that happens to be generous is still
  a strong claim; a false absence is a liability the moment anyone checks.
- Before writing a comparison ("more than X," "faster than Y," "cheaper than the
  alternative"), confirm the comparison is one you can actually source — a real price, a real
  measured number, a real doc. If you can't verify it, either drop the specific comparison or
  soften it to what you *can* stand behind.
- Before writing a number (a cap, a percentage, a count, a price), read it out of the source
  of truth (config, database schema, pricing table) rather than recalling it from memory or
  from other marketing copy, which may itself be stale or wrong.
- When a claim can't be verified in the time available, prefer omission or a hedged, true
  statement over a specific, unverified one. A vaguer honest sentence beats a punchier false
  one every time — the reader who catches one fabricated claim stops trusting all the others.
- This gate applies to *editing* existing copy too, not just new copy: an audit pass should
  flag any claim already on the page that isn't backed by something checkable, the same way
  it flags a missing stage.

## Execution flow

1. **Identify the copy in scope** — one page, a funnel of several pages, or a single
   email/ad/script. Read it in full before touching anything.
2. **Map the current structure.** Go section by section (or paragraph by paragraph for short
   copy) and label each one with the CLOSER stage it's actually doing, or "none" if it isn't
   doing any of the six jobs (nav, footer, legal — that's fine, not everything has to serve
   the arc).
3. **Diagnose against the map:**
   - A stage that never appears anywhere = **missing**.
   - A later-stage section (Sell, Explain, Reinforce) appearing before an earlier one
     (Clarify, Label, Overview) has finished its job = **out of order** — mechanism-before-
     outcome is the single most common instance of this.
   - A stage repeated in three sections while another stage has zero = **imbalanced**.
   - Any claim under O/S/R that isn't backed by something checkable = **unverified claim**
     (see the anti-fabrication gate above — this is not a lesser finding, it blocks the fix).
4. **Verify every claim you intend to write or keep**, per the gate above, against the actual
   product/codebase/pricing source before it goes on the page.
5. **Propose the fix as a stage-labeled outline first** — the new section order with each
   section's CLOSER stage marked, and a one-line note on what copy changes (if any) each
   section needs. Get this outline right before touching prose; most of the fix is reordering
   sections that already exist, not writing new ones.
6. **Apply the edits.** Reorder sections, tighten or add copy only where a stage is genuinely
   missing or weak, and leave design, visual style, and brand voice untouched — this is a
   structure and claims pass, not a redesign. When editing code (a marketing site's route/
   component files), keep diffs minimal: reorder existing components before rewriting their
   internals.
7. **Verify the result renders correctly** if it's a live page (start the dev server, view
   it) before reporting the work as complete.

## Finding format

- **Stage:** which of C / L / O / S / E / R the section is (or should be), or `Missing` /
  `Out of order` / `Unverified claim` for the diagnosis categories above.
- **Evidence:** file:line (source) or URL + selector (a live page), with the exact current
  copy.
- **Risk:** what it concretely costs — a reader who can't self-qualify keeps reading past
  copy that isn't for them; mechanism-first copy loses skimmers before they know why to care;
  a missing Reinforce stage leaves last-second doubt unanswered at the CTA; an unverified
  claim is a false statement waiting to be noticed.
- **Fix:** the specific reorder or copy fix, with the corrected text and, for an unverified
  claim, the source that was checked to confirm the replacement is true.

## Files

- `references/worked-example.md` — a full before/after CLOSER pass on a fictional SaaS
  pricing page: the stage map of the original, the diagnosis, and the reordered result.
