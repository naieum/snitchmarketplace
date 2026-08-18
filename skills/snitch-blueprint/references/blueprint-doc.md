# BLUEPRINT.md — schema

The checked-in decisions document. One file at the repo root (or where the user names),
short enough to stay maintained — a working doc agents load before building, not a strategy
deck. Every line is one of the four record types from the decisions gate: **Fact** (with
`file:line` / URL evidence), **Decision**, **Default** (labeled, with reason), or **Open
question**. Prose that is none of these doesn't belong in the file.

## Required sections

```markdown
# Blueprint — <project name>

<!-- snitch-blueprint v0.1.0 — decisions doc. Records: Fact / Decision / Default / Open.
     Re-run the blueprint interview after a pivot; let git diffs show strategy changes. -->

## Identity
Archetype (primary + secondary), business/product name, domain, locale(s), stack.
Facts carry evidence; e.g. `Stack: Next.js App Router (Fact — package.json:12)`.

## Audience & wedge
Who buys (the person and the moment), what they use today instead, the one-sentence
wedge. Verbatim user language where possible — later copy passes mine this section.

## Conversion action
The ONE action, its rank-2 fallback if any, and HOW it is instrumented (the event name,
the analytics destination). An uninstrumented conversion action is an open question,
not a decision.

## Claim inventory
Everything surfaces may claim, each with its evidence or owner. Anything absent from
this list is unwritable anywhere in the build. An empty inventory is valid and means:
no social-proof sections yet.

## Surfaces & build order
Numbered list of surfaces (pages / screens / docs) in build order. Each entry:
status (built / next / deferred), one-line purpose, link to its spec below.
The DEFERRED sublist is mandatory and carries the reason + the trigger that promotes
it ("city pages for Tier-2 cities — deferred until Tier-1 ranks; trigger: 3-pack
presence in prove-out city").

## Surface specs
One short block per built-or-next surface:
- **Job:** what a visitor should know/do after this surface, in one sentence.
- **Section order:** the ordered sections (persuasive surfaces default to the CLOSER
  arc — see the archetype file; utility surfaces default to task order).
- **Conversion presence:** where the conversion action appears on this surface.
- **Claims used:** which claim-inventory lines this surface draws on.
- **Wiring:** metadata, schema.org type, and any surface-specific instrumentation.

## Day-one wiring
The cross-cutting checklist from references/build-defaults.md, with each item marked
done (evidence) / next / n-a (reason). This is what the later audits will find already
in place.

## Constraints
Budget posture, maintainer, timeline, refused channels/tactics.

## Open questions
Everything unresolved, each with what it blocks. The blueprint is usable with open
questions; it is not usable with silent guesses.
```

## Done-when

- Every section present; every line typed as Fact / Decision / Default / Open.
- The conversion action is singular, ranked, and instrumented (or its instrumentation is
  the top open question).
- The build order has at least one DEFERRED entry. A blueprint that defers nothing hasn't
  made choices — it's a wishlist, and wishlists are what audits later flag as ten
  half-built surfaces.
- The claim inventory contains zero unverified numbers.
- The user has seen the diff and confirmed. The blueprint is theirs; the skill drafts it.

## Maintenance

- New surface requested → add it to Surfaces & build order + write its spec *before*
  writing its code. The spec-then-code order is the whole point of the skill.
- Pivot / new service line / re-platform → re-run the interview delta, update, commit. The
  git history of BLUEPRINT.md is the strategy changelog.
- Audit skills, when run later, should be pointed at this file: findings that contradict a
  recorded Decision are surfaced as "decision vs. best practice" tensions for the user, not
  auto-fixes.
