# The Writing System — how it applies to marketing prose

**`snitch-ux` owns the writing system.** The rule set (W1–W14 machine-checked, A1–A7
agent-judged), the two-mode split, the thresholds, and the score bands are defined once, inside
that skill. For a full copy pass on any surface — a hero line, a CTA, microcopy, a rewrite —
**call the Skill tool with "snitch-ux"** and score it there.

This file records only what is specific to this skill: which prose runs in which mode, where the
pass sits in the audit, and how a score becomes evidence in a finding.

Three files police prose here, and they divide the work cleanly. `report-lint.md` owns report
*hygiene* — redaction, practitioner and source names, sycophancy, negative-evidence shape.
Cat 117 owns the user's *claims* — what the copy asserts and whether it substantiates.
The writing system owns **sentence construction** — length, voice, hedging, the banned phrase
lists.

> **The honesty rules outrank every mechanics rule.** The anti-hallucination rules and the
> dark-pattern findings in Cat 117 come first. A sentence can score 0.0 violations and still be a
> dark pattern — fabricated urgency written in clean active voice is *more* dangerous, not less.
> A lint-clean dark pattern is still a finding: if the claim is dishonest, the finding is the
> dishonesty, not the mechanics.

## Which mode each surface runs in

**strict** (ships under 2.0 violations per 100 words, banned phrases at zero):

- This skill's own report narrative: executive snapshot, finding prose, coverage statements
- Instructional copy the skill drafts: error messages, microcopy, CTA labels, meta descriptions
- Any numbered fix procedure

**flavored** (ships under 4.0, banned phrases still at zero):

- Voiced Fix prose (`voiced-remediations.md` — the soul's cadence is the point)
- Strategic Recommendations narrative
- Hero lines, taglines, and brand copy the skill drafts or rewrites for the user
- The user's own marketing copy, when scored as a lens under Cat 117 / Cat 59

Mechanics rules stay fully on in flavored mode; only the rhythm rules relax, because anaphora and
fragments are legitimate voiced devices.

**Soul precedence** — when a flavored-mode hit lands on voiced prose, the precedence between the
soul's rhythm and the system's mechanics is fixed, and `voiced-remediations.md` ("Mechanics vs
cadence") is the single owner of that rule. Read it there.

## Running the linter

```
python3 ${CLAUDE_SKILL_DIR}/scripts/copy-lint.py --mode strict report-draft.md
cat hero-copy.txt | python3 ${CLAUDE_SKILL_DIR}/scripts/copy-lint.py --mode flavored -
python3 ${CLAUDE_SKILL_DIR}/scripts/copy-lint.py --mode flavored --json extracted.txt   # for audit_metadata
```

The script is the authority for the count: it names each rule it fires, reports weighted
violations per 100 words, reads a file or stdin, and **never writes a file**. It strips code
blocks, URLs, frontmatter, and `audit_metadata` blocks before counting, and keeps heading and
table-cell text, because that is where hero lines and CTAs live. Same input, same mode, same
output, every time. `--json` emits the result for `audit_metadata.lint.copy_lint` (schema in
`report-lint.md`).

**If python3 is unavailable**, call the Skill tool with "snitch-ux", apply W1–W14 by hand from
its rule table, and record `runner: manual` in `audit_metadata.lint.copy_lint` — the same
degradation contract as the HTML render. A hand pass loses the exact score but keeps the rules;
never skip the pass because the script could not run.

**Mention is not use.** A Fix that quotes the banned phrase it removes ("cut every 'seamlessly'
from the hero") registers as a hit but is not a violation — adjudicate and discount those. When
writing such a Fix yourself, put the quoted phrase in backticks: the preprocessor strips inline
code, so the mention never enters the count.

## Score bands, as used in an audit

| Score | Reading | In an audit (Cat 117 / Cat 59) |
|---|---|---|
| < 2.0 | Clean | Mention as a pass — clean copy is a result |
| 2.0 – 5.0 | Mechanics drag | Medium finding: quote the worst hits with their rule IDs |
| > 5.0 | Slop-dense | High finding: the copy is working against the page |

The severity mapping for audit findings stays with the category files; the bands calibrate, the
category decides.

**The bands assume a denominator of at least 50 words.** Below that, a per-100-word rate is noise —
one em dash in a 25-word line scores 4.0/100w. For any sample under 50 words (a section fragment, a
CTA block, a proposed rewrite), report the raw rule hits and the word count instead
(`W10 ×1, n=25`), never the rate and never a band. The same floor applies to a Verify step: verify a
short rewrite against **zero hits of the rules the finding named**, not against a density threshold
the sample is too small to carry.

## How this composes with the rest of the skill

- **Report generation (STEP 3)**: after the `report-lint.md` pass and before the grader, the
  drafted report's narrative prose runs through the linter in strict mode; worst offenders are
  rewritten and the pass repeats until under the configured threshold
  (`snitch-marketing.config.md`, `copy-lint.max-report-score`). The result lands in
  `audit_metadata.lint.copy_lint`.
- **Cat 117 / Cat 59 (audit lens)**: each audited surface's extracted visible copy is scored in
  flavored mode, and the score joins the finding's evidence — `copy-lint: 7.3 violations/100w
  (n=412) — top: W8 vague adjectives ×6, W9 superlatives ×2`. The category files own the failure
  modes and severity; the score makes the density claims countable.
- **Voiced Fixes** (`voiced-remediations.md`): flavored mode, soul precedence as above.
- **Copy drafts and rewrites** the skill produces for the user — a hero-line alternative, a meta
  description, a `copy-bank-templates.md` instantiation — pass the linter before they are shown,
  strict or flavored by the surface they target.
- **Config** (`snitch-marketing.config.md`, `copy-lint` block): `enabled`, `report-mode`,
  `audit-mode`, `max-report-score`. Disabling the block skips the scored lens; the
  anti-hallucination rules and Cat 117's dark-pattern findings are untouched at every value.
