# The rule set: controlled technical English

A compact controlled-language system: machine-checkable preferences plus the judgment
calls a linter cannot make. Meaning, safety conditions, exact labels, and technical terms
outrank substitutions and score targets. Token matches need contextual adjudication.
Rule IDs (W/V/S/P/T) are what audit findings cite.

## WORDS

- **W1: one name for one thing.** Do not call the same item by two different names in one
  document. If it is `the config file` in line 3, it is not `the settings file` in line 40.
- **W2: the short common word wins.** Substitution table:

  | Write | Not |
  |---|---|
  | start | begin, commence, initiate |
  | use | utilize, leverage |
  | help | facilitate |
  | make sure | ensure |
  | before | prior to |
  | after | subsequent to |
  | about | regarding, concerning |
  | get | obtain, acquire |
  | show | demonstrate |
  | also | additionally, furthermore, moreover |
  | many | numerous, myriad, a plethora of |
  | to | in order to |
  | while | whilst |
  | among | amongst |
  | full | comprehensive |

- **W3: one meaning per word.** `fall` means to move down, not to decrease. `test` is a
  noun or a verb in one document, not both.
- **W4: no marketing adjectives.** Reject promotional use in both modes, after adjudication: `seamless`, `robust`,
  `powerful`, `cutting-edge`, `effortless`, `world-class`, `next-generation`,
  `revolutionary`, `blazing`, `lightning-fast`, `elegant`, `delightful`, `turnkey`,
  `best-in-class`, `state-of-the-art`, `game-changing`, `first-class`, `battle-tested`,
  `enterprise-grade`, `supercharge`, `unlock`, `unleash`, `empower`.
- **W5: no filler frames.** Remove unnecessary framing in both modes, preserving meaning: `it is important to note`,
  `it should be noted`, `it is worth noting`, `please note that`, `due to the fact that`,
  `in the event that`, `a variety of`, `aforementioned`, `henceforth`, `therein`.
- **W6: consistent spelling.** Follow the user's dialect or established project style;
  use American spelling only when neither specifies one. Preserve literal commands.

## VERBS

- **V1: active voice.** `The parser reads the file`, not `the file is read by the
  parser`. Passive is acceptable only when the actor is unknown or irrelevant.
- **V2: a verb for an action.** `Analyze the log`, not `perform an analysis of the log`.
  Nominalizations (`perform`/`conduct`/`carry out`/`make use of` + noun, `___tion of`)
  hide the action.
- **V3: remove redundant framing, preserve uncertainty.** Replace `it is important to
  note that this may help improve X` with `this may help improve X`, not `this improves X`.
  Never strengthen may/can/should into will/must or drop a safety condition.
- **V4: no "-ing" main verb where a simple tense works.** `The server logs each request`,
  not `the server is logging each request` (unless the progressive is the point).
- **V5: no phrasal verbs where a plain verb exists.** start (not `spin up`), contact (not
  `reach out`), examine (not `dive into`), start (not `kick off`), deploy (not `roll
  out`), remove (not `tear down`), increase (not `ramp up`).

## SENTENCES

- **S1: one instruction per sentence.**
- **S2: length caps.** Max 20 words for an instruction, max 25 for a descriptive
  sentence. Both modes. Split long sentences. Do not comma-splice them.
- **S3: no contractions.**
- **S4: use articles.** Keep a, an, the, this, these. Telegraphic prose (`run command,
  check output`) reads faster but misreads easier.
- **S5: condition before command.** `If the test fails, read the log`, not `read the log
  if the test fails`. The reader must know the condition before they act.

## PUNCTUATION

- **P1: no semicolons.** Write two sentences.
- **P2: prefer simpler punctuation.** Replace an unnecessary em dash with a period,
  comma, or parentheses when meaning stays intact. Punctuation cannot identify authorship.

## STRUCTURE

- **T1: one topic per paragraph, max six sentences.**
- **T2: steps are a numbered vertical list**, one action per item, imperative form.
- **T3: warnings and conditions come first**, before the step they modify, never after.

## Mode differences

Both modes apply every rule above. They differ in two concrete, checkable ways:

- **S2's cap.** Strict enforces the 20-word instruction cap on every sentence, including
  descriptive ones. Flavored allows an occasional 25-word descriptive sentence when
  splitting it would damage meaning. Count it, report it, and keep it under the mode's
  score band.
- **W2's table.** Flavored treats it as a preference: the short word wins, but an
  occasional longer word that reads naturally is a scored violation, not a blocker.
  Strict prefers the substitution, except when it changes an exact term, label, dialect,
  meaning, or necessary condition.

Both modes target zero substantiated W4/W5 violations; legitimate technical terms, exact
labels, and quoted examples are not promotional use. Keep raw linter counts separate. The score bands themselves (strict ≤ 1.5/100w, flavored ≤ 2.5/100w) are in
`SKILL.md`.

## Which rules the linter checks

`scripts/ste-lint.py` scores 12 of the 21 rule IDs above mechanically. The rest need
human judgment. A script can spot a semicolon. It cannot judge whether a sentence "makes
good sense."

V1 and V4 skip the look-alikes. A form of `be` plus an adjective or a noun is neither a
passive nor a progressive: `the light is red`, `there is nothing here`, `the file is
missing`. A named actor overrides that and counts, because `the value is fixed by the
migration` is a real passive.

| ID | Rule | Linted |
|---|---|---|
| W1 | one name for one thing | no |
| W2 | short word wins | yes |
| W3 | one meaning per word | no |
| W4 | no marketing adjectives | yes |
| W5 | no filler frames | yes |
| W6 | consistent requested/project spelling | no |
| V1 | active voice | yes |
| V2 | a verb for an action | yes |
| V3 | no stacked auxiliaries or hedges | no |
| V4 | no "-ing" main verb where a simple tense works | yes |
| V5 | no phrasal verbs where a plain verb exists | yes |
| S1 | one instruction per sentence | no |
| S2 | length caps | yes (see Mode differences above) |
| S3 | no contractions | yes |
| S4 | use articles | no |
| S5 | condition before command | no |
| P1 | no semicolons | yes |
| P2 | no em dashes | yes |
| T1 | one topic per paragraph, max six sentences | yes (length only; "one topic" is judgment) |
| T2 | steps are a numbered vertical list | no |
| T3 | warnings and conditions come first | no |

## What only judgment can check

A zero-violation score means only that the implemented heuristics found no matches.
It certifies neither form nor content. Judgment must check the right technical noun,
clarity, and whether a paragraph is true. When rewriting, the
fact-preservation rule (keep every fact, number, name, and code span) is the judgment
half of the job.
