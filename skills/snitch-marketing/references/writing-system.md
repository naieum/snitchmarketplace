# The Writing System — prose mechanics for the copy this skill reads and writes

Three files police prose in this skill, and they divide the work cleanly. `report-lint.md`
owns report *hygiene* — redaction, practitioner names, sycophancy, negative-evidence shape.
Cat 117 owns the user's *claims* — what the copy asserts and whether it substantiates.
This file owns **sentence construction** — length, voice, hedging, the banned phrase lists —
for both directions: the prose this skill writes (report narrative, Fix prose, copy drafts,
rewrites) and, as a scored lens, the user's marketing copy under Cat 117 and Cat 59.

The method is adapted from controlled-language systems used in safety-critical technical
documentation — writing standards built so that a stressed, non-native reader cannot misread
an instruction. Their core insight transfers to marketing prose: **machine-checkable rules
outperform style advice**, and a deterministic score outperforms both. Their vocabulary
restrictions do not transfer — those systems ban persuasive writing outright — so this file
keeps the *method* (checkable rules, a two-mode split, a violations-per-100-words score) and
rebuilds the rule set for marketing copy.

> **The honesty rules outrank every rule in this file.** The anti-hallucination rules and the
> dark-pattern findings in Cat 117 come first. A sentence can score 0.0 violations and still
> be a dark pattern — fabricated urgency written in clean active voice is *more* dangerous,
> not less. A lint-clean dark pattern is still a finding, and this file never launders one:
> if the claim is dishonest, the finding is the dishonesty, not the mechanics.

## The two modes

**strict** — prose where ambiguity has a direct cost and no voice is in play:

- This skill's own report narrative: executive snapshot, finding prose, coverage statements
- Instructional copy the skill drafts: error messages, microcopy, CTA labels, meta
  descriptions
- Any numbered fix procedure

All rules at tight thresholds. Strict prose ships under **2.0 violations per 100 words**,
and every individually-banned phrase (W4, W6, W7) is removed regardless of score.

**flavored** — prose where voice carries the authority:

- Voiced Fix prose (`voiced-remediations.md` — the soul's cadence is the point)
- Strategic Recommendations narrative
- Hero lines, taglines, and brand copy the skill drafts or rewrites for the user
- The user's own marketing copy, when scored under Cat 117 / Cat 59

Mechanics rules stay fully on — banned phrases, hedge stacking, vague adjectives,
superlatives, em-dash density. Rhythm rules relax: the length cap loosens and the
repetition rule (W12) switches off, because anaphora and fragments are legitimate voiced
devices. Flavored prose the skill ships stays under **4.0 violations per 100 words**,
banned phrases at zero.

**Soul precedence.** The soul owns **rhythm** — fragments, sentence-length variation,
repetition for emphasis, where the stress lands. The writing system owns **mechanics** —
the banned lists, hedge stacking, active voice, one name per concept. When a flavored-mode
hit lands on voiced prose, rewrite the hit *in cadence* — never flatten the voice to clear
the score. The converse holds too: no soul authorizes a mechanics violation. No
practitioner in `souls/` ever wrote "robust, world-class platform"; a banned phrase in a
voiced Fix is a voice failure *and* a lint failure. (`voiced-remediations.md`, "Mechanics
vs cadence".)

## Machine-checked rules (W1–W14)

These are the rules `scripts/copy-lint.py` implements — exactly these, nothing more. Each
violation the script reports carries its rule ID, so a score is arguable line by line. The
word lists for W7 and W8 are supersets of Cat 59's AI-tell list and Cat 117's
vague-adjective regex; the category files remain authoritative for the audit *judgment*,
this table for the *count*.

| ID | Rule | strict | flavored |
|---|---|---|---|
| W1 | **Sentence length.** Long sentences hide the actor and bury the point. | > 24 words | > 32 words; > 40 flags in both modes |
| W2 | **Clause pile-up.** ≥ 2 semicolons in one sentence, or ≥ 3 commas plus a coordinating conjunction — the deterministic proxy for "one idea per sentence" (A3). | on | on |
| W3 | **Passive voice.** Be-verb + past participle. The actor disappears and the claim goes soft. Heuristic; adjectival participles false-positive, the agent adjudicates. | density > 1 per 100 words | > 2 per 100 words |
| W4 | **Nominalization pairs.** Fixed list: "make a decision", "perform/conduct an analysis", "provide a recommendation", "come to a conclusion", "take into consideration", "make an assumption", "give an indication", "carry out an evaluation". The verb was always there: decide, analyze, recommend, conclude, consider, assume, indicate, evaluate. | any | any |
| W5 | **Hedge stacking.** ≥ 2 of may / might / could / perhaps / possibly / likely / somewhat / arguably / appears to / seems to / tends to in one sentence. One hedge is a probability claim; two is the writer ducking. (Distinct from the negative-evidence hedges `report-lint.md` forbids outright — those fail regardless of count.) | + density > 2 per 100 words | stacking only |
| W6 | **Filler and inflators.** "in order to", "utilize", "leverage" (as a verb), "very", "really", "simply", "basically", "actually" (adverbial), "needless to say", "at the end of the day", "it's worth noting". | any | any |
| W7 | **AI-tell phrases.** "delve", "tapestry of", "in today's fast-paced world", "it's important to note", "navigate the complexities", "harness the power", "unlock the potential", "elevate your", "supercharge", "seamlessly", "game-changing" (any inflection), "in the ever-evolving", "dive into", "look no further", "let's explore". Superset of Cat 59's list. | any | any |
| W8 | **Vague adjectives.** powerful, seamless, robust, world-class, best-in-class, cutting-edge, next-gen, revolutionary, innovative, intuitive, user-friendly, enterprise-grade, state-of-the-art, frictionless, effortless, amazing, game-changing, premier, leading-edge. Cat 117's list. | full weight | half weight — Cat 117's "NOT a problem" carve-out (a qualified flavor word in a concrete sentence) needs judgment the script lacks, so flavored downweights and the agent adjudicates each hit |
| W9 | **Unsupported superlative.** "the best / the fastest / the only / #1 / leading [noun]" with no digit and no proper noun within 50 words — Cat 117's 50-word proof window, made deterministic. | on | on |
| W10 | **Em-dash density** > 1 per 200 words — the same threshold `report-lint.md` and Cat 59 state; one number, three citations. | on | on |
| W11 | **Transition-opener density.** Sentences opening with Furthermore / Additionally / Moreover / However: > 15% of sentences, or ≥ 3 occurrences (Cat 59's "generic transitions"). | on | on |
| W12 | **Sentence-start repetition.** 3+ consecutive sentences opening with the same word. | on | **off** — anaphora is a legitimate voiced device |
| W13 | **Exclamation marks.** | any | > 1 per 100 words |
| W14 | **Round-number social proof.** "thousands of", "millions of users", "countless" — the phrase-level tell of Cat 117's weak-social-proof failure mode. | on | on |

## Agent-judged rules (A1–A7)

These need judgment the script does not have. They apply to everything the skill writes and
inform the audit lens; they are not part of the score.

- **A1 — One name per concept.** One term per thing per report or page. Alternating "plan",
  "tier", and "package" for the same object makes the reader re-derive the mapping.
- **A2 — Concrete over abstract.** Every claim carries something the reader can check — a
  number, a name, an artifact. This is Cat 117's substantiation test at sentence scale.
- **A3 — One idea per sentence.** W2 catches pile-ups mechanically; the real test is whether
  the sentence answers one question or three.
- **A4 — List discipline.** Parallel structure, one sentence per bullet, at most 7 items,
  one nesting level.
- **A5 — Front-load actor and verb.** No throat-clearing openers ("It should be noted that
  the sitemap…" → "The sitemap…"). The reader scans the first three words.
- **A6 — Imperative mood for fixes.** A fix states the action ("Add one canonical,
  absolute, self-referencing"), not the possibility ("a canonical could be added").
- **A7 — Verbs over nominalizations, beyond W4's fixed list.** Whenever an action hides
  inside a noun ("perform validation of"), restore the verb.

## Score bands

The score is **weighted violations per 100 words**, computed by the linter.

| Score | Reading | In an audit (Cat 117 / Cat 59) |
|---|---|---|
| < 2.0 | Clean | Mention as a pass — clean copy is a result |
| 2.0 – 5.0 | Mechanics drag | Medium finding: quote the worst hits with their rule IDs |
| > 5.0 | Slop-dense | High finding: the copy is working against the page |

Generation side, the bands are a shipping bar: report prose (strict) under 2.0, voiced and
brand prose (flavored) under 4.0, banned phrases at zero in both. The severity mapping for
audit findings stays with the category files; the bands calibrate, the category decides.

## Running the linter

```
python3 scripts/copy-lint.py --mode strict report-draft.md
cat hero-copy.txt | python3 scripts/copy-lint.py --mode flavored -
python3 scripts/copy-lint.py --mode flavored --json extracted.txt   # for audit_metadata
```

The script reads a file or stdin, prints the score and per-rule breakdown to stdout, and
**never writes a file**. It strips code blocks, URLs, frontmatter, and `audit_metadata`
blocks before counting, and keeps heading and table-cell text, because that is where hero
lines and CTAs live. Same input, same mode, same output, every time — a before/after
comparison of a rewrite is meaningful, and `--json` emits the result for
`audit_metadata.lint.copy_lint` (schema in `report-lint.md`).

**If python3 is unavailable**, apply W1–W14 by hand from the table above and record
`runner: manual` in `audit_metadata.lint.copy_lint` — the same degradation contract as the
HTML render. A hand pass loses the exact score but keeps the rules; never skip the pass
because the script could not run.

**Mention is not use.** A Fix that quotes the banned phrase it removes ("cut every
'seamlessly' from the hero") registers as a hit but is not a violation — adjudicate and
discount those. When writing such a Fix yourself, put the quoted phrase in backticks: the
preprocessor strips inline code, so the mention never enters the count.

## How this composes with the rest of the skill

- **STEP 3 (report generation)**: after the `report-lint.md` pass and before the grader, the
  drafted report's narrative prose runs through the linter in strict mode; worst offenders
  are rewritten and the pass repeats until under the configured threshold
  (`snitch-marketing.config.md`, `copy-lint.max-report-score`). The result lands in
  `audit_metadata.lint.copy_lint`.
- **Cat 117 / Cat 59 (audit lens)**: each audited surface's extracted visible copy is scored
  in flavored mode, and the score joins the finding's evidence — `copy-lint: 7.3
  violations/100w (n=412) — top: W8 vague adjectives ×6, W9 superlatives ×2`. The category
  files own the failure modes and severity; the score makes the density claims countable.
- **Voiced Fixes** (`voiced-remediations.md`): flavored mode, soul precedence as above —
  hits rewritten in cadence, never by flattening the voice.
- **Copy drafts and rewrites** the skill produces for the user — a hero-line alternative, a
  meta description, a `copy-bank-templates.md` instantiation — pass the linter before they
  are shown, strict or flavored by the surface they target.
- **Config** (`snitch-marketing.config.md`, `copy-lint` block): `enabled`, `report-mode`,
  `audit-mode`, `max-report-score`. Disabling the block skips the scored lens; the
  anti-hallucination rules and Cat 117's dark-pattern findings are untouched at every value.
