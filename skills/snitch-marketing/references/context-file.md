# Persisted ICP / positioning context file

The audit's psychology, CRO, copy, and positioning findings are only as sharp as
its model of *who the site is for*. Today the discovery phases (STEP 0.5-0.8,
`phases/assumptions.md`, `phases/discovery.md`, `phases/niche-research.md`) capture
this into the report, but it isn't **persisted** or **consumed** by the per-category
checks. This reference defines a single persisted artifact —
**`.snitch-marketing-context.md`** — that discovery writes once and the relevant
categories read first, so findings judge the site against its *actual* ICP, not
generic best practice.

Naming is consistent with the skill's other dotfiles (`.snitch-marketing-ignore`,
`.snitch-marketing-triage.json`).

## When it's written / read

- **Written** at the end of discovery (STEP 0.8), or on demand. If a file already
  exists, offer to reuse/update rather than regenerate. Migration-aware path search,
  first hit wins: `.snitch-marketing-context.md` (canonical) → `.snitch-marketing/context.md` → the discovery output already in the report.
- **Read first** by these categories before they score: 60, 73, 81, 99, 109, 110,
  111, 112, 114, 115, 116, 117 (the persuasion / CRO / copy / positioning / pricing
  cluster). If the file is absent, those cats fall back to on-page inference and
  **note the assumption** (per the anti-hallucination assumptions rule) rather than
  asserting ICP facts.

## Format

YAML frontmatter for provenance, then markdown sections. Keep it lean (one screen).

```markdown
---
generated_by: snitch-marketing discovery
source: skill-inferred        # skill-inferred | user-confirmed | mixed
generated_at: { iso-date }
target: { domain or repo }
---

# Product
One-liner · category · business model · primary conversion action.

# ICP & personas
Who it's for (company type, role, decision-maker vs end-user). The **anti-persona**
(who it is explicitly NOT for) — load-bearing for flagging copy that chases everyone.

# JTBD — the Four Forces
- **Push** (what frustrates them about the status quo)
- **Pull** (what attracts them to a new solution)
- **Habit** (what keeps them on the status quo)
- **Anxiety** (what makes them hesitate to switch)

# Top objections (+ responses)
The 3 objections a real buyer raises, and how the site should answer each.

# Verbatim customer language
Exact words customers use for the problem and the solution (from reviews, tickets,
calls). NOT polished marketing prose. This is the yardstick for copy findings.

# Brand voice
Tone, do/don't words, personality.

# Proof points
Real metrics, named customers, quantified outcomes available as evidence.
```

The load-bearing sections for an evidence-first audit are **ICP/anti-persona**,
**the Four Forces**, **top objections**, and **verbatim customer language** — they
turn vague findings into grounded ones.

## How categories use it (examples)

- **Cat 81 / 110 (positioning / ICP wedge):** does the hero match the ICP + anti-persona, or does it try to address everyone? Cite the divergence.
- **Cat 114 §3 / §4 (motivation / friction):** does the page address the **Anxiety** and **Push** forces? A missing Anxiety-reducer near the CTA is a grounded finding, not a guess.
- **Cat 60 / 117 (conversion copy / copy-lint):** does the site's wording match the **verbatim customer language**, or is it jargon the ICP doesn't use? Quote both.
- **Cat 111 / 74 (trust artifacts / social proof):** are the **proof points** actually on the page where the decision happens?
- **Cat 109 (message match):** does the landing copy match the ad *and* the ICP's Pull?

## Provenance discipline

`source: skill-inferred` means the audit drafted the ICP from the site itself —
findings built on it must be framed as "assuming the ICP is X (inferred from the
homepage), …". `source: user-confirmed` (the user reviewed/edited the file) lets
those findings drop the hedge. This mirrors the assumptions rule in
`references/anti-hallucination.md`: never assert an ICP fact the audit only inferred.

Cross-refs: `phases/discovery.md` (writes it), `references/mental-models.md`
(the Four Forces / model lenses), `references/anti-hallucination.md` (assumptions),
`references/customer-discovery-script.md` + `references/feedback-signals.md` (how to
gather verbatim language), `INDEX.md`.
