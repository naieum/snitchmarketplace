---
name: snitch-docwriter
description: Write or rewrite technical prose — docs, READMEs, PR descriptions, commit messages, error messages, release notes, runbooks, API docs, code comments, reports — in a controlled technical style adapted from ASD-STE100 Simplified Technical English, and score existing prose with a deterministic anti-slop linter (violations per 100 words). Triggers on make this not sound like AI, remove AI slop, plain English, simplify these docs, tighten this README / PR description, controlled language, Simplified Technical English, STE, rewrite this error message, does my writing sound like AI. Do NOT use for marketing copy, brand voice, or off-site channel content (use snitch-cmo), one page's persuasion structure (use snitch-focusedcopy), or UI microcopy, CTAs, and the on-page hero, one-liner or tagline (use snitch-ux). Those systems keep voice under mechanical discipline. This skill strips voice on purpose. Never rewrite code, identifiers, or command syntax.
license: MIT with Commons Clause
compatibility: Standalone skill — runs in any AI coding tool that loads Agent Skills (Claude Code, Codex, Cursor, GitHub Copilot, Gemini CLI, Windsurf, Goose, Cline, Zed, OpenCode, and 60+ more). Pure guidance plus one optional local Python script; no server or external calls required.
metadata:
  author: Snitch
  version: 0.4.1
  homepage: https://snitchplugin.com
---

# Snitch: Docwriter

Write technical prose in a controlled style adapted from **ASD-STE100 Simplified
Technical English**. STE is the aerospace maintenance-documentation standard, first
issued in 1986 (free official spec at https://asd-ste100.org). It was built so a
stressed, non-native reader cannot misread an instruction. It defines about 53 writing
rules and a dictionary of about nine hundred approved words, one meaning per word. This
skill distills the machine-checkable core of that standard into rules an agent can
follow and a linter can score.

**Why this works.** A 2026 practitioner experiment tested 6 realistic engineer-writing
tasks across 4 conditions and two model families, scored by a heuristic linter at
violations per 100 words. Giving a model this writing system cut slop violations by
**50–74%** versus baseline. That was the best or tied-best condition on every model
tested, and far more reliable than the folk fix of banning words one at a time, which did
almost nothing on one model family. This is directional evidence, not proof: a heuristic
linter, six tasks. The system also fixes the **form** of slop, not the substance. It
cannot make a hollow paragraph true.

## Scope

**Applies to:** documentation, READMEs, PR descriptions, commit message bodies, error
messages, release notes, runbooks, and procedures. It also covers API reference prose,
getting-started guides, deprecation notices, code comments, and report narrative.

**Never applies to:** code, identifiers, command syntax, and quoted output. Leave them
exactly as they are. This skill also does not cover marketing copy, essays, or UI
microcopy judged for persuasion, or anything that needs a voice, because STE strips voice
on purpose. Marketing copy and brand voice belong to snitch-cmo, landing-page persuasion
structure to snitch-focusedcopy, and UI microcopy to snitch-ux. The boundary: those
systems keep voice under mechanical discipline, and this skill removes voice entirely.

## Modes (full rule set and the mode-difference table: `references/rules.md`)

- **strict**: procedures, runbooks, safety-relevant text, error messages, deprecation
  notices. Target **≤ 1.5 violations per 100 words**.
- **flavored**: general prose (READMEs, PR descriptions, docs, release notes). Target
  **≤ 2.5 violations per 100 words**.

Both modes ban W4 (marketing adjectives) and W5 (filler frames) outright: zero, not a
budget item. Pick strict when ambiguity has a direct cost. Use flavored otherwise. Say
which mode you used.

## Execution flow

1. **Classify the text**: strict or flavored (Modes above). If the text is marketing or
   UI copy, stop and hand off. Call the Skill tool with "snitch-cmo" for marketing copy
   and brand voice, "snitch-focusedcopy" for landing-page persuasion structure, or
   "snitch-ux" for UI microcopy. One skill per call.
2. **Write or rewrite** under the rules in `references/rules.md`. When rewriting, keep
   every fact, number, name, and code span. Change only the prose. Write only the
   requested text: no preamble, no summary, no closing remarks.
3. **Score it.** Run the deterministic linter:
   ```
   python3 ${CLAUDE_SKILL_DIR}/scripts/ste-lint.py file.md                    # flavored, per-file table
   python3 ${CLAUDE_SKILL_DIR}/scripts/ste-lint.py --evidence file.md         # file:line, rule ID, sentence
   python3 ${CLAUDE_SKILL_DIR}/scripts/ste-lint.py --mode strict file.md       # strict thresholds
   python3 ${CLAUDE_SKILL_DIR}/scripts/ste-lint.py --mode strict < draft.txt   # JSON detail on stdin
   ```
   The output is keyed by the rule ID it breaks (W2, W4, W5, V1, V2, V4, V5, S2, S3, P1,
   P2, T1). Cite that ID in findings. If Python is unavailable, run the manual self-lint
   below (Self-lint, manual fallback) instead: same rules, a human judge instead of the
   script.
4. **Fix and re-score** until the mode's target band is met and `banned_word_hits` is 0.
   Never clear a violation by deleting information. Split, activate, or substitute
   instead.
5. **Report** the score: violations per 100 words, and before → after when rewriting.
   Also report the mode, and any rule you deliberately kept violated (quoted text, a term
   of art), with one line of justification.

## Self-lint (manual fallback, no Python)

Walk the text against each linted rule ID in `references/rules.md`'s table, in order:
W2, W4, W5, V1, V2, V4, V5, S2, S3, P1, P2, T1. Then check the unlinted IDs by judgment:
W1, W3, W6, S1, S4, S5, V3, T2, T3.

## Audit direction

The same rules score prose you did not write. When asked "does this sound like AI" or to
audit docs, lint the files and report violations per 100 words per file. Quote the worst
sentences with the specific rule each breaks, and offer the rewrite. Findings use
file:line evidence. Run the linter with `--evidence`: it prints one line per hit, with
the file, the line number, the rule ID, and the sentence. The score is length-normalized,
so it is comparable across files. It is noisy under ~50 words, though, so trust longer
samples more.

## Audit finding format

- **Finding.** Report each part on its own line:
  - **Impact:** High, Medium, or Low. High means the prose can be misread or
    misexecuted (procedures, error messages). Medium means credibility damage (slop
    tells in docs). Low means polish only.
  - **Evidence:** file:line with the exact sentence, plus the rule ID it breaks.
  - **Risk:** what the violation concretely costs, such as a misread instruction, reader
    distrust, or a "written by AI" tell.
  - **Fix:** the rewritten sentence, in the same mode as the surrounding text.
- **Pass**: the file scores under its mode's band with zero `banned_word_hits`. Evidence:
  the score line (words, total, per100w, mode).
- **Skip**: no `python3` on the system, or the sample is under 50 words (too short for
  the score to mean anything). Say which, and fall back to the manual self-lint above
  (Self-lint, manual fallback) when Python is the reason.

## Files

- `references/rules.md`: the full rule set (WORDS / VERBS / SENTENCES / PUNCTUATION /
  STRUCTURE), the substitution table, and what only human judgment can check.
- `references/before-after.md`: worked baseline to controlled-rewrite pairs, with scores.
- `scripts/ste-lint.py`: the deterministic scorer. It implements exactly the
  machine-checkable rules, nothing more.
