# The Writing System — prose mechanics for every line of copy

`copywriting.md` owns **what the copy says** — specificity, verbs, framing, the swap table.
This file owns **how the sentences are built** — length, voice, construction, the banned
lists. A line can pass every swap in `copywriting.md` and still read as slop because the
sentence itself is bloated, hedged, or passive; that failure is this file's business. The two
files run together in Workflow Step 1, move 6, and neither substitutes for the other.

The method is adapted from controlled-language systems used in safety-critical technical
documentation — writing standards built so that a stressed, non-native reader cannot misread
an instruction. Their useful property here is repeatability: **machine-checkable rules
surface candidates for judgment**, not proof of quality or user harm. Their vocabulary
restrictions do not transfer — those systems ban persuasive writing outright, and interface
copy has to persuade — so this file keeps the *method* (checkable rules, a two-mode split,
a violations-per-100-words score) and rebuilds the rule set for UX copy.

> Gate first: `ethics-gate.md`. A sentence can score 0.0 violations and still be a dark
> pattern — fabricated urgency written in clean active voice is *more* dangerous, not less.
> The `writing-system` config key narrows this file's scored lens; it never touches the gate.

**Adjudicate before rating or rewriting.** The script reports lexical candidates. Its score
does not establish truth, task failure, or severity. Exempt justified technical terms, quoted
language, and constructions whose rewrite would lose meaning; name the rule and reason.
Keep the raw score reproducible, and distinguish accepted hits from dismissed ones. The
shipping targets below apply to actionable hits; never erase necessary uncertainty, safety
information, or brand rhythm merely to lower a number. `finding-rules.md` decides Findings
and severity; a high raw score alone is not a Finding and zero hits is not a usability Pass.

## The two modes

Every piece of copy is linted in one of two modes. The mode is chosen by surface type, never
by how much slack the writer wants.

**strict** — copy the user acts on under time pressure or stress, where ambiguity has a
direct cost:

- Microcopy: buttons, labels, tooltips, form hints, menu items
- CTAs and their supporting objection-handlers
- Error messages, warnings, confirmation dialogs
- Empty states, loading states, system feedback
- This skill's own report prose (the review narrative, finding fields, coverage block)

All rules apply at the tight thresholds. Strict copy ships under **2.0 violations per 100
words**, and every individually-banned phrase (W4, W6, W7) is removed regardless of score.

**flavored** — copy where voice is the point and rhythm carries meaning:

- Taglines, hero headlines, value props
- Brand narrative, onboarding story beats, pitch copy
- Any line written to a brand's documented voice

Mechanics rules stay fully on — banned phrases, hedge stacking, vague adjectives,
superlatives, em-dash density. Rhythm rules relax: the sentence-length cap loosens, and the
repetition rule (W12) switches off because anaphora is a legitimate device. Flavored copy
ships under **4.0 violations per 100 words**, banned phrases still at zero.

**Voice precedence.** Where flavored copy is written to a voice — a brand voice, a founder's
cadence — the voice owns **rhythm**: fragments, sentence-length variation, repetition for
emphasis, where the stress lands. The writing system owns **mechanics**: the banned lists,
hedge stacking, active voice, one name per concept. When a flavored-mode hit lands on voiced
copy, rewrite the hit *in the voice* — never flatten the voice to clear the score. The
converse holds too: no voice authorizes a mechanics violation. "Robust, world-class
platform" is not a cadence; it is three W-rule hits wearing one.

## Machine-checked rules (W1–W14)

These are the rules `scripts/copy-lint.py` implements — exactly these, nothing more. Each
violation the script reports carries its rule ID, so a score is arguable line by line.

| ID | Rule | strict | flavored |
|---|---|---|---|
| W1 | **Sentence length.** Long sentences hide the actor and bury the instruction. | > 24 words | > 32 words; > 40 flags in both modes |
| W2 | **Clause pile-up.** ≥ 2 semicolons in one sentence, or ≥ 3 commas plus a coordinating conjunction — the deterministic proxy for "one idea per sentence" (A3). | on | on |
| W3 | **Passive voice.** Be-verb + past participle. The actor disappears and the instruction goes soft ("the file will be deleted" — by whom, on what?). Heuristic; adjectival participles false-positive, the agent adjudicates. | density > 1 per 100 words | > 2 per 100 words |
| W4 | **Nominalization pairs.** Fixed list: "make a decision", "perform/conduct an analysis", "provide a recommendation", "come to a conclusion", "take into consideration", "make an assumption", "give an indication", "carry out an evaluation". The verb was always there: decide, analyze, recommend, conclude, consider, assume, indicate, evaluate. | any | any |
| W5 | **Hedge stacking.** ≥ 2 of may / might / could / perhaps / possibly / likely / somewhat / arguably / appears to / seems to / tends to in one sentence. One hedge is a probability claim; two is the writer ducking. | + density > 2 per 100 words | stacking only |
| W6 | **Filler and inflators.** "in order to", "utilize", "leverage" (as a verb), "very", "really", "simply", "basically", "actually" (adverbial), "needless to say", "at the end of the day", "it's worth noting". | any | any |
| W7 | **AI-tell phrases.** "delve", "tapestry of", "in today's fast-paced world", "it's important to note", "navigate the complexities", "harness the power", "unlock the potential", "elevate your", "supercharge", "seamlessly", "game-changing" (any inflection), "in the ever-evolving", "dive into", "look no further", "let's explore". | any | any |
| W8 | **Vague adjectives.** powerful, seamless, robust, world-class, best-in-class, cutting-edge, next-gen, revolutionary, innovative, intuitive, user-friendly, enterprise-grade, state-of-the-art, frictionless, effortless, amazing, game-changing, premier, leading-edge. | full weight | half weight — a *qualified* flavor word ("powerful at the workloads you actually run") is legitimate; the script can't judge qualification, so flavored downweights and the agent adjudicates each hit |
| W9 | **Superlative needing review.** "the best / the fastest / the only / #1 / leading [noun]" with no digit and no proper noun within 50 words. Nearby digits/names suppress this heuristic, but do not prove the claim; inspect substantiation separately. | on | on |
| W10 | **Em-dash density** > 1 per 200 words. Em dashes are fine as punctuation, not as connective filler. | on | on |
| W11 | **Transition-opener density.** Sentences opening with Furthermore / Additionally / Moreover / However: > 15% of sentences, or ≥ 3 occurrences. | on | on |
| W12 | **Sentence-start repetition.** 3+ consecutive sentences opening with the same word. | on | **off** — anaphora is a legitimate flavored device |
| W13 | **Exclamation marks.** | any | > 1 per 100 words |
| W14 | **Vague social-proof wording.** "thousands of", "millions of users", "countless". The script's historical rule label is round-number social proof; these matches establish neither fabrication nor a need for odd numbers. | on | on |

## Agent-judged rules (A1–A7)

These need judgment the script does not have. They are part of the copy pass, not the score.

- **A1 — One name per concept.** One term per thing per surface. A flow that alternates
  "plan", "tier", and "package" for the same object makes the user re-derive the mapping at
  every occurrence. Pick one, use it everywhere, including in this skill's own report.
- **A2 — Concrete over abstract.** Every claim carries something the reader can check — a
  number, a name, an artifact. "Faster checkout" is a hope; "checkout in 2 taps" is a claim.
- **A3 — One idea per sentence.** W2 catches the worst pile-ups mechanically; the real test
  is whether the sentence answers one question or three.
- **A4 — List discipline.** Parallel structure, one sentence per bullet, at most 7 items,
  one nesting level. A list that needs sub-sub-bullets is a structure problem, not a list.
- **A5 — Front-load actor and verb.** No throat-clearing openers ("It should be noted that
  the export button…" → "The export button…"). The reader scans the first three words.
- **A6 — Imperative mood for instructions.** Fixes and instructions state the action
  ("Rename the label", not "the label could be renamed"). Consistent tense and person per
  surface.
- **A7 — Verbs over nominalizations, beyond W4's fixed list.** The pattern generalizes:
  whenever an action hides inside a noun ("perform validation of"), restore the verb.

## Score bands

The raw score is **weighted violations per 100 words**, computed by the linter. Use the
bands to prioritize inspection, not to assign severity:

| Score | Reading | In a review |
|---|---|---|
| < 2.0 | Few lexical hits | Still check meaning, claims and task clarity |
| 2.0 – 5.0 | Review candidates | Adjudicate hits and explain any task cost |
| > 5.0 | Dense candidates | Prioritize inspection; no automatic High Finding |

Generation side, the bands are a shipping bar, not a rating: strict prose ships under 2.0,
flavored under 4.0, and every individually-banned phrase is removed regardless of score.

**The bands assume a denominator of at least 50 words.** Below that, a per-100-word rate is
noise — one em dash in a 25-word line scores 4.0/100w. For any sample under 50 words (a CTA
block, an empty-state string, an error message, a proposed rewrite), report the raw rule hits
and the word count instead (`W10 ×1, n=25`), never the rate and never a band. The same floor
applies when you re-lint a rewrite: verify a short rewrite against **zero hits of the rules the
finding named**, not against a density threshold the sample is too small to carry.

## Running the linter

Claude Code sets `${CLAUDE_SKILL_DIR}` to this skill bundle's own directory, the folder that
contains `SKILL.md`; in other hosts substitute the path where the
bundle was loaded.

```
python3 ${CLAUDE_SKILL_DIR}/scripts/copy-lint.py --mode strict extracted-copy.txt
cat draft.md | python3 ${CLAUDE_SKILL_DIR}/scripts/copy-lint.py --mode flavored -
python3 ${CLAUDE_SKILL_DIR}/scripts/copy-lint.py --mode strict --json -   # for embedding the result
```

The script reads a file or stdin, prints the score and per-rule breakdown to stdout, and
**never writes a file** — running it is a read, so it is safe inside the review phase, which
is read-only (SKILL.md, "Report before you edit"). It strips code blocks, URLs, and
frontmatter before counting, and keeps heading and table-cell text, because that is where
CTAs live. Same input, same mode, same output, every time — a before/after comparison of a
rewrite is meaningful.

**If python3 is unavailable**, apply W1–W14 by hand from the table above and note in the
report: `copy-lint: script unavailable; rules applied by hand`. A hand pass loses the exact
score but keeps the rules; never skip the pass because the script could not run.

**Mention is not use.** A sentence that quotes a banned phrase in order to remove it ("cut
every 'seamlessly' from the hero") registers as a hit but is not a violation — adjudicate
and discount those. When writing such a sentence yourself, put the quoted phrase in
backticks: the preprocessor strips inline code, so the mention never enters the count.

## How this composes with the rest of the skill

- **Workflow Step 1, move 6** runs this file alongside `copywriting.md`: extract the
  surface's visible copy, lint it (strict or flavored per the surface-type table above),
  and adjudicate the score's hits before rating any copy-mechanics finding. The score goes in the
  finding's **Evidence** field: `copy-lint: 6.1 violations/100w (n=214) — top: W8 vague
  adjectives ×4, W5 hedge stacking ×2`. **Every rule the run reported gets named somewhere in
  the finding.** Truncating to "top hits" is fine for readability, but then say how many you
  cut (`top 3 of 7 rules`) and carry the remainder in a trailing list — a sub-tell you scored
  and then dropped is a gap a reader cannot see.
- **Mode by surface type**: microcopy, CTAs, errors, empty states → strict. Hero, tagline,
  brand narrative → flavored, and the *message* on those surfaces still belongs to
  `brand-message.md` — this file only guards the sentences the message is delivered in.
  **Strict is for functional UI strings only.** Marketing prose on a marketing page is
  brand narrative and scores flavored — the hero paragraph, the sub-head, the "how it works"
  or "why we built this" block, the section intros. Length does not make a block strict; the
  job it does decides. **A surface is usually mixed:** score each block in its own mode
  rather than picking one for the page, and **name the mode beside every score you report**
  (`23.6/100w flavored`) so the reader can check the call. Scoring a marketing block strict
  inflates it against rules flavored mode deliberately relaxes; the disposition may survive,
  the number does not.
- **Anything this skill writes passes the linter before it is shown**: a proposed rewrite in
  a Fix field, a suggested error message, a hero-line alternative — strict or flavored per
  the surface it targets. The review report's own narrative prose passes strict. **When the
  request asks for rewrites, a rewrite is the replacement text, not a direction.** "Cut this
  to two concrete sentences and name what it integrates with" is a brief; the deliverable is
  the two sentences, scored, in the Fix field. Every prose block you open a finding on gets
  one — if it is worth flagging, it is worth showing the fix, and the fix is what proves the
  bar is reachable.
- **The `writing-system` config key** (`snitch-ux.config.md`): `auto` (default — mode by
  surface type), `strict`, `flavored`, or `off`. `off` skips the scored lens on the user's
  copy; the generation-side bar on this skill's own prose still applies, and the ethics gate
  is untouched at every value.
