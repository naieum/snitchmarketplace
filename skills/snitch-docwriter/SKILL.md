---
name: snitch-docwriter
description: Write or rewrite technical prose — docs, READMEs, PR descriptions, commit messages, error messages, release notes, runbooks, API docs, code comments, reports — in a controlled technical style adapted from ASD-STE100 Simplified Technical English, and score existing prose with a deterministic anti-slop linter (violations per 100 words). Triggers on make this not sound like AI, remove AI slop, plain English, simplify these docs, tighten this README / PR description, controlled language, Simplified Technical English, STE, rewrite this error message, does my writing sound like AI. Do NOT use for marketing copy, landing pages, brand voice, or UI microcopy judged for persuasion (use snitch-marketing / snitch-ux — their writing systems keep voice; this skill strips it on purpose), and never rewrite code, identifiers, or command syntax.
license: MIT with Commons Clause
compatibility: Standalone skill — runs in any AI coding tool that loads Agent Skills (Claude Code, Codex, Cursor, GitHub Copilot, Gemini CLI, Windsurf, Goose, Cline, Zed, OpenCode, and 60+ more). Pure guidance plus one optional local Python script; no server or external calls required.
metadata:
  author: Snitch
  version: 0.2.0
  homepage: https://snitchplugin.com
---

# Snitch: Docwriter

Write technical prose in a controlled style adapted from **ASD-STE100 Simplified Technical
English** — the aerospace maintenance-documentation standard (first issued 1986, free
official spec at https://asd-ste100.org). STE was built so a stressed, non-native reader
cannot misread an instruction: ~53 writing rules, a dictionary of about nine hundred
approved words, one meaning per word. This skill distills the machine-checkable core of
that standard into rules an agent can follow and a linter can score.

**Why this works.** A 2026 practitioner experiment (6 realistic engineer-writing tasks ×
4 conditions, two model families, scored by a heuristic linter at violations per 100
words) found that giving a model this writing system cut slop violations by **50–74%**
versus baseline — the best or tied-best condition on every model tested, and far more
reliable than the folk fix of banning words one at a time (which did almost nothing on
one model family). Directional evidence, not proof: heuristic linter, n=6 tasks. And it
fixes the **form** of slop, not the substance — it cannot make a hollow paragraph true.

## Scope

**Applies to:** documentation, READMEs, PR descriptions, commit message bodies, error
messages, release notes, runbooks, procedures, API reference prose, getting-started
guides, deprecation notices, code comments, report narrative.

**Never applies to:** code, identifiers, command syntax, quoted output — leave them
exactly as they are. Not for marketing copy, essays, UI microcopy judged for persuasion,
or anything that needs a voice: STE strips voice on purpose. For persuasive copy, use the
writing systems in snitch-marketing / snitch-ux instead; the boundary is that those keep
voice under mechanical discipline, this skill removes it.

## Modes

- **strict** — procedures, runbooks, safety-relevant text, error messages, deprecation
  notices: apply every rule and both sentence-length caps. Target **≤ 1.5 violations per
  100 words**, zero banned words.
- **flavored** — general prose (READMEs, PR descriptions, docs, release notes): apply the
  sentence, paragraph, active-voice, and plain-verb discipline; relax the ~900-word
  dictionary lockdown so the text keeps enough range to read naturally. Target **≤ 2.5
  violations per 100 words**, zero banned words.

Pick strict when ambiguity has a direct cost; flavored otherwise. Say which mode you used.

## Execution flow

1. **Classify the text** — strict or flavored (table above). If the text is marketing or
   UI copy, stop and hand off to snitch-marketing / snitch-ux.
2. **Write or rewrite** under the rules in `references/rules.md`. When rewriting, keep
   every fact, number, name, and code span; change only the prose. Write only the
   requested text — no preamble, no summary, no closing remarks.
3. **Score it.** Run the deterministic linter:
   ```
   python3 scripts/ste-lint.py file.md        # per-file summary table
   python3 scripts/ste-lint.py < draft.txt    # JSON detail on stdin
   ```
   If Python is unavailable, run the manual self-lint below instead — the rules are the
   same; the script is only the faster judge.
4. **Fix and re-score** until the mode's target band is met. Never clear a violation by
   deleting information; split, activate, or substitute instead.
5. **Report** the score (violations per 100 words, before → after when rewriting), the
   mode, and any rule you deliberately kept violated (quoted text, a term of art) with one
   line of justification.

## Self-lint (manual fallback — run before returning any text)

1. Any sentence over 20 words (instruction) / 25 words (descriptive)? Split it.
2. Any semicolon? Replace with a period. Any em dash? Rewrite the sentence.
3. Any contraction? Expand it.
4. Any passive voice with a known actor? Make it active.
5. Any "-ing" main verb, nominalization ("perform an analysis"), or phrasal verb
   ("spin up")? Replace with a plain verb.
6. Any banned or marketing word (`references/rules.md`, WORDS)? Substitute the plain word.
7. Same thing named two ways? Pick one name and use it everywhere.
8. Any paragraph over six sentences or with two topics? Split it.

## Audit direction

The same rules score prose you did not write. When asked "does this sound like AI" or to
audit docs, lint the files, report violations per 100 words per file, quote the worst
sentences with the specific rule each breaks, and offer the rewrite. Findings use
file:line evidence. The score is length-normalized, so it is comparable across files —
but it is noisy under ~50 words; trust longer samples more.

## Audit finding format

- **Impact:** [High / Medium / Low] — high when the prose can be misread or misexecuted
  (procedures, error messages), medium for credibility damage (slop tells in docs), low
  for polish.
- **Evidence:** file:line with the exact sentence, plus the rule ID it breaks.
- **Risk:** what the violation concretely costs (misread instruction, reader distrust,
  "written by AI" tell).
- **Fix:** the rewritten sentence, in the same mode as the surrounding text.

## Files

- `references/rules.md` — the full rule set: WORDS / VERBS / SENTENCES / PUNCTUATION /
  STRUCTURE, the substitution table, and what only human judgment can check.
- `references/before-after.md` — worked baseline → controlled rewrites with scores.
- `scripts/ste-lint.py` — deterministic scorer; implements exactly the machine-checkable
  rules, nothing more.
