# Brand-voice audit framework

A structured way to audit whether a brand's content actually sounds like the brand — and whether
the brand has even defined what that is. Cat 75 (brand consistency) uses this to move from "the
copy feels off" to a specific, evidence-backed finding: which voice attribute is violated, on
which page, with the quoted line.

This audits the CUSTOMER's brand voice. It is unrelated to `references/voice-mapping.md` /
`voiced-remediations.md`, which govern how WE write remediation prose. Never name a practitioner
or our internal "souls" in a brand-voice finding (see the no-designer-names rule).

## When surfaced

Loaded when Cat 75 (brand consistency) runs, and referenced by Cat 81 (positioning) and Cat 117
(copy lint) when a finding turns on voice rather than mechanics.

## Step 1 — does a documented voice exist?

Before judging consistency, check whether the brand has a voice to be consistent with. Look for a
brand/voice/style guide (in the repo: `BRAND.md`, `/style-guide`, a CMS "voice" doc; or the
persisted `.snitch-marketing-context.md` brand-voice section from discovery). Findings:

- **No documented voice** → the finding is "voice is undefined, so consistency can't be enforced;
  every writer guesses." Recommend defining it (the artifacts below). Severity Medium — it's the
  root cause of most consistency drift.
- **Voice documented** → audit the live content against it (Step 3).

## Step 2 — the three artifacts a good voice definition has

Recommend (or, if present, audit against) these. They're the deliverable for a "no documented
voice" finding:

1. **"We are / We are not" table** — each attribute paired with its negation, which is what makes
   it usable. Vague ("friendly") becomes auditable ("warm, not chummy"; "direct, not blunt";
   "expert, not academic").

   | We are | We are not |
   |---|---|
   | Direct | Blunt |
   | Confident | Boastful |
   | Plain-spoken | Dumbed-down |

2. **Voice constants vs. tone flexes** — the constants hold everywhere (e.g., "always concrete,
   never hype"); the flexes adapt by context (more playful in social, more precise in docs). A
   finding distinguishes a *constant* violation (always wrong) from a *flex* mismatch (wrong for
   this surface).

3. **Tone-by-context matrix** — how the voice shifts across surfaces. Columns are the dials
   (formality, energy, technical depth, humor); rows are the surfaces.

   | Surface | Formality | Energy | Technical depth | Humor |
   |---|---|---|---|---|
   | Homepage hero | mid | high | low | light |
   | Docs | mid | low | high | none |
   | Error / 404 | low | mid | low | light |
   | Sales email | mid | mid | mid | none |

## Step 3 — audit live content against it

Sample 3-5 representative pages across surfaces (home, a product/feature page, docs, an email or
social post if available). For each, quote a line and judge it against the constants + the matrix
row for that surface. A finding names: the surface, the violated attribute, the quoted line, and
a before/after.

## Confidence scoring + open questions

Voice is partly subjective, so tier each finding's confidence and surface what you couldn't
resolve, rather than overclaiming:

- **High** — violates a documented constant (quote the guide + the line).
- **Medium** — inconsistent across pages with no documented guide to arbitrate (quote both lines).
- **Low** — a defensible stylistic choice you'd flag for review, not a clear error.

End a brand-voice section with an **Open questions** list when the guide is silent on a surface
(e.g., "no tone guidance exists for error messages — recommend defining it"). Don't invent the
brand's intent; name the gap.

## Forbidden claims

- "The voice is inconsistent" without quoting ≥2 lines that diverge.
- "This is off-brand" without naming the specific attribute (from the table) it violates.
- Asserting the brand's intended voice when no guide exists — that's an open question, not a finding.
- Naming a practitioner/soul or our internal voice system in the finding.

---

*Framework adapted from concepts in the Apache-2.0 `anthropics/knowledge-work-plugins`
(marketing/brand-review and the partner-built brand-voice skills), reimplemented under Snitch's
evidence-first constraints. Internal reference only; not surfaced in reports.*
