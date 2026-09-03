# Audit→fix remediation generator

The audit's job is to find problems with evidence. This reference defines the
**fix** half: turning a finding into a ready-to-ship artifact, grounded in the
site's actual buyer. It extends the "Concrete copy drafts" rule in
`references/report-template.md` from copy-only to all generatable fixes, and keeps
the skill's identity (evidence-first audit, not a generic copy tool): every
generated artifact traces back to a specific finding + the persisted ICP context.

This is a **post-audit, opt-in** step (post-scan menu "generate fixes", or inline
on a Critical/High finding with a generatable fix). The skill **emits** the
artifact; the user applies it (never auto-write, per anti-hallucination Rule 9).

## Color-fix safeguard (applies to post-scan `[2]` and `[3]`)

Any fix that touches a color value — any rewrite of a color token, hex, or `oklch/hsl/rgb` value —
requires **per-finding confirmation even in batch mode**. Color values are brand identity, and a mathematically better ratio is still a brand change
the customer did not ask for.

Before applying one:

1. Show before / after, plus the measured contrast ratio (SC 1.4.3 / 1.4.11) or the redundant channel
   being added (SC 1.4.1).
2. Ask "Apply this color change? [Yes / Skip]" and wait.

A **color-only-meaning fix (SC 1.4.1) adds a redundant channel** — icon, text, pattern, weight, position — rather than
rewriting a color. If the only proposed fix is a palette swap, the category was misread; flag it as
a misclassified color rewrite instead of applying it. Never substitute a "CVD-safe palette" for the
customer's brand palette unless they explicitly ask for one.

## Grounding (read first)

1. Read `.snitch-marketing-context.md` (`references/context-file.md`). Copy fixes
   draw from its ICP/anti-persona, JTBD Four Forces, top objections, **verbatim
   customer language**, brand voice, proof points. If the file is absent, draft
   from on-page inference and **label the assumption** ("assuming the ICP is X").
2. Pull structural patterns from `references/copy-bank-templates.md` (the 12
   templates) and headline/CTA formulas below. Schema types come from
   `references/standards-table.md`.

## Finding → fix-artifact map

| Finding (cat) | Generated artifact | Source of truth |
|---|---|---|
| Weak/"everyone" hero, value-prop (81, 114 §1) | Headline + subhead + CTA, Draft A/B/C | context ICP + Pull/Push forces + verbatim language |
| Vague CTA (60, 114 §4) | CTA via `[Action verb] + [What they get] + [Qualifier]` | context primary conversion |
| No objection handling (32 FAQPage row, 60) | FAQ / objection block | context **top-3 objections** + Anxiety force |
| Weak/absent trust strip (60, 74) | Trust-strip copy + placement | context **proof points** (real metrics/customers only) |
| Title/meta (9, 10) | `<title>` + meta description per route | target query + context language |
| Missing/invalid schema (31, 32, 94) | Valid JSON-LD for the detected type | `standards-table.md` per-type row + on-page facts |
| Missing llms.txt (106) | A drafted `/llms.txt` | site structure + context one-liner |
| robots/sitemap gap (1, 2) | The directive/snippet | crawl findings |
| Message mismatch (109) | Rewritten landing headline to match the ad | the ad copy + context Pull |

## Copy formulas (author these; the widely circulated swipe files are headline-only)

**Headline formulas:** outcome (`{achieve outcome} without {pain}`), problem
(`Never {bad event} again` / `{question naming the pain}`), audience (`The {category}
for {audience}`), differentiation (`The {opposite-of-usual} way to {outcome}`),
proof (`{N} {people} use {product} to {outcome}`).

**CTA formula:** `[Action verb] + [What they get] + [Qualifier]` → "Get my free audit",
"Start my trial, no card required".

**PAS / AIDA** (not in any swipe file — author these here):
- **PAS:** Problem (name it in the buyer's words) → Agitate (the cost of inaction, the Anxiety/Push force) → Solve (your differentiated answer + proof).
- **AIDA:** Attention (hero hook) → Interest (the job, Cat-114 §3) → Desire (proof + outcome) → Action (the CTA). Map each to a page section.

## Output contract

For each generated fix:
1. **Current** (quoted from source) → **Fix** (the artifact). For copy findings,
   provide **Draft A/B/C** when positioning is a genuine tradeoff, else one and say so.
2. **Rationale** — one line naming the finding it resolves + the model/force it
   leverages (cite `mental-models.md`).
3. **Verify** line (per `report-template.md` A2): the observable signal. For copy/
   conversion fixes the verification IS an A/B test (the lift is a hypothesis, not a
   claim, per Cat 73 / Cat 114).

## Lint generated copy before emitting (do not skip)

Run every generated string through:
1. **Report-lint** (`references/report-lint.md`): no em-dashes, no sycophantic
   adjectives, no practitioner names.
2. **AI-boilerplate avoid-list** (regenerate any line that contains): "That being
   said", "It's worth noting that", "At its core", "In today's digital landscape",
   "Let's delve into", "In conclusion", and "Moreover"/"Furthermore" as openers.
3. **Verbatim-language check**: prefer the context file's customer words over
   jargon the ICP doesn't use.
4. **Ethics**: never generate a dark pattern (fabricated scarcity, fake counts,
   confirmshaming) even if asked, per `mental-models.md` ethical guardrails + Cat 114
   ethics overlay.

Cross-refs: `references/report-template.md` (Concrete copy drafts + Verify),
`references/context-file.md`, `references/copy-bank-templates.md`,
`references/standards-table.md`, `references/report-lint.md`,
`references/mental-models.md`, Cat 73 / Cat 114 (lift is a hypothesis).
