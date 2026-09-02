# Voiced Remediations (Internal Mechanism)

Every **Fix** in every finding is written in a discipline-specific voice: the cadence and priorities of the practice that owns that problem. The voice is an INTERNAL writing prompt for the AI, not a label that surfaces in user-facing output. The customer reads a fix that has clear authority. The customer does not read where the cadence came from.

The voice library lives at `souls/` next to SKILL.md, as JSON files. Each file is a role profile — `disciplines`, `philosophy`, `principles`, `cadence_samples`, `aesthetic`, `critique_style`, `would_approve`, `would_reject`, `modern_web_take` — named for a discipline, never for a person, and carrying no biography. These files are internal data, never displayed to the user.

## Strict: the voice mechanism stays internal

No practitioner name, book, or vendor tool appears in:

- The audit report (`SEO_AUDIT_REPORT.md`)
- The Strategic Recommendations document
- Chat output to the customer
- Worked-fix prose (the prose may use the cadence; it must not attribute it to anyone)

No soul slug appears in any emitted artifact either — not in the markdown report's metadata block,
not in the JSON or CSV export, not in the HTML render. There is no `voice_reads_completed` field
and no `fix.voice` field; the audit does not record which voices it read.

The slug DOES appear in:

- `souls/{slug}.json` (the data files themselves)
- `references/voice-mapping.md` (the cat-to-slug master table, internal mechanism)
- Each category file's "**Fix voice:** `slug`" line (an internal directive to the AI; not surfaced in the report)
- The "Read `souls/{slug}.json` before writing the Fix" directives in category files (a tool-call instruction, not customer copy)

## How to use a soul when writing a Fix

1. Look up the category's assigned voice in `references/voice-mapping.md`. Each category has a primary voice and 0-2 backup voices for nuanced sub-cases.
2. **`Read` the soul JSON file before writing any voiced Fix.** This is a required tool call, not optional. Read the FULL file (`philosophy`, `principles`, `cadence_samples` minimum). The voice is in the rhythm of those, not just the topical knowledge.
3. **Internalize the material; do NOT cite a source.** Each voiced Fix paraphrases a specific principle from the soul JSON, woven into the prose, never attributed. The discipline of the writing carries the authority.
4. Write the Fix as if that discipline's most exacting practitioner is reviewing this finding over the user's shoulder. Use that cadence, those priorities, that framing.
5. **Do not paste `cadence_samples` verbatim.** They are paraphrased tone calibration, not content to drop into prose. Forced quote-dropping reads like a fortune cookie.
6. **Do not blend voices.** One Fix, one soul. Blending produces mush, neither voice comes through, the writing reads as generic.
7. **Stay accurate to the soul's stated principles.** If the assigned soul's POV doesn't fit the fix, escalate to a backup voice rather than forcing a mismatch.

## What this looks like in a finding

Without voice (generic):

> **Fix:** Add `<link rel="canonical" href="https://example.com/page">` to the page head.

With voice (the prose carries the discipline; the name is absent):

> **Fix:** Add one canonical, absolute, self-referencing. The page already declares its OG URL and its sitemap entry — three signals where one would do. Pick the canonical, drop the OG URL declaration, and let the sitemap echo the canonical instead of fight it.
>
> ```tsx
> head: () => ({
>   links: [{ rel: 'canonical', href: `https://example.com${pathname}` }],
> })
> ```

The customer reads a fix with a clear point of view. The customer does not need to know who informed the cadence; the cadence does the work.

## Mechanics vs cadence

This section is the single owner of the soul-vs-writing-system precedence rule; other references
cite it rather than restating it.

Voiced Fix prose is also subject to the writing system (`references/writing-system.md`), in
**flavored** mode, and the precedence between the two is fixed:

- **The soul owns rhythm** — fragments, sentence-length variation, repetition for emphasis,
  where the stress lands. Flavored mode is built so none of these register as violations.
- **The writing system owns mechanics** — the banned phrase lists (W4/W6/W7), hedge stacking,
  vague adjectives, superlatives, em-dash density, one name per concept.

When a flavored-mode lint hit lands on voiced prose, rewrite the hit **in cadence** — never
flatten a fragment or de-voice a sentence to clear a score. The converse holds with equal
force: no soul authorizes a mechanics violation. No soul in `souls/` would write
"robust, world-class platform"; a banned phrase inside a voiced Fix is a voice failure *and*
a lint failure, and the fix for both is the same rewrite.

## Voice fidelity rules (anti-hallucination, voice edition)

- **You may not invent a quotation** or attribute one to anyone. `cadence_samples` are paraphrases, so nothing in a soul file is quotable. Any quotation marks inside a Fix must be quoting the audited site's own copy, not a voice.
- **You may not assign a voice to a soul that the JSON doesn't authorize.** If a soul JSON has no field about a topic, do not have that voice opine on the topic; use a more relevant soul.
- **You may not change a soul's stated principles to fit a fix.** If the principle is "less, but better" and your fix is "add three more meta tags", the voice mismatch is on you. Pick a different soul whose principles tolerate the action.
- **You may not name a practitioner, book, or vendor tool in user-visible output.** This rule supersedes any flourish or attribution impulse. The fix prose is authoritative without the byline. `references/report-lint.md` scans for it before the report can be saved.
