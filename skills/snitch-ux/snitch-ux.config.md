# Snitch: UX — config

Edit this file to tune the review behavior. The skill reads it at Step 0, before it enumerates
the surface list.

## tool-name

Name the skill uses for itself in report headings and prose. Change it to white-label the output.

```
tool-name: Snitch
```

## report-title

Heading written at the top of the review report.

```
report-title: UX Review
```

## min-severity

Findings below this level land in a "Minor" section at the end of the report instead of the main
body. Nothing is dropped silently — the count of demoted findings is stated.

```
min-severity: Low
```

Valid values: `Low` (default — everything in the main body), `Medium`, `High`, `Critical`.

## lenses

Which of the skill's two lenses run. Clarity findings are the accidental question marks (is that
clickable? where am I?); persuasion findings are the intentional ones (defaults, anchoring, framing,
social proof).

```
lenses: both
```

Valid values: `both` (default), `clarity` (clarity pass only — use when the brief is "make it
understandable," or when persuasion moves are out of scope for the team), `persuasion` (assumes the
clarity pass already happened; rarely the right choice on a first review).

**This key never disables the ethics gate.** `references/ethics-gate.md` (Workflow Step 1,
move 4) runs at every value of `lenses`, including `clarity`. The gate is not a persuasion technique — it is the
check that decides whether persuasion techniques may be used at all, so restricting the lenses
narrows what gets *optimised*, never what gets *checked*.

## writing-system

How the prose-mechanics lens (`references/writing-system.md` + `scripts/copy-lint.py`) runs during
the copy pass (Workflow Step 1, move 6).

```
writing-system: auto
```

Valid values: `auto` (default — strict mode for microcopy / CTAs / errors / empty states, flavored
for hero / tagline / brand narrative, chosen per surface type), `strict` (force strict everywhere),
`flavored` (force flavored everywhere — rare), `off` (skip the scored lens on the user's copy
entirely).

`off` narrows the *review*, not the skill's own writing: any replacement copy the skill proposes,
and the report's own prose, still meet the writing-system bar. And like `lenses`, this key never
touches the ethics gate — a lint-clean dark pattern is a finding at every value.

## platform

Which platform conventions apply. Governs which mobile review prompts (tab count, reachability,
platform-specific target sizing — `references/navigation.md`) apply, and which
familiar-pattern set counts as "the convention."

```
platform: auto
```

Valid values: `auto` (default — infer from the codebase or the rendered viewport), `web`, `ios`,
`android`. Set explicitly when the repo holds more than one target and auto-detection would guess.

## report-output

Where the markdown report is written. Default: a `snitchfindings/` subdirectory of the working
directory, with a per-target subfolder.

```
report-output: snitchfindings/{target_slug}/UX_REVIEW.md
```

The `{target_slug}` token is derived from the `package.json` `name` field if present, otherwise from
the working-directory basename; for a live-site review, from the target domain's second-level name
(`https://www.atlasforms.app` → `atlasforms`). Set this to a literal path to override, e.g.
`report-output: docs/ux-review.md`.

Add `snitchfindings/` to `.gitignore` if review output should stay local.

## confirm-scope

Whether Step 0 asks the user to resolve an unclear surface boundary before the pass starts.
Default `true`; an explicitly named page, component or flow is already scoped. Set to `false`
for batch runs — the skill states its scope assumption, reviews the enumerated in-scope
surfaces, and marks any unknown inventory or unreviewed states as partial coverage.

```
confirm-scope: true
```

## high-stakes

Set `true` when the audience includes vulnerable users or the flow carries high stakes (children,
elders, health, money, crisis). The skill then always loads `references/inclusive-design.md` and
dials the persuasion half *down* rather than up — no urgency, no loss framing, no friction on the
exit. Default `false` (the skill still applies the inclusive-design gate in the review checklist).

```
high-stakes: false
```
