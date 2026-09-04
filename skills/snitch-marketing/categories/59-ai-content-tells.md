## CATEGORY 59: AI-content tells

The historical category name describes an editing lens, not an authorship detector. Audit
specific clarity and evidence defects regardless of who wrote the page. Vocabulary,
punctuation, a missing byline, or a voice shift cannot establish AI authorship or a search
penalty. Google's published guidance focuses on content quality, not whether AI produced it.

### Evidence required (do not skip)

1. Read the selected page content fully, including linked support for disputed claims.
2. Run the optional deterministic linter per `references/writing-system.md`:
   `python3 {skill_dir}/scripts/copy-lint.py --mode flavored page-content.txt`.
   If unavailable, inspect manually and record that limitation.
3. Adjudicate each candidate in context. Preserve technical terms, exact labels, necessary
   uncertainty, and purposeful punctuation. Quote actual defects with file:line or URL+selector.
4. Name the reader cost and distinguish raw matches from accepted violations. Under 50 words,
   report counts only, not a density band. No minimum quota of sentences or Findings.

### Forbidden claims

- AI authorship or an algorithmic penalty inferred from stylistic patterns.
- “Fabricated statistic” based only on a missing citation. Missing visible substantiation is
  different from a disproven statistic; unavailable verification is Skip for truth.
- A measured ranking or conversion loss without measurements.
- A high score as automatic High severity, or zero hits as automatic Pass.

### Detection

Read source or actual rendered text. A static HTTP response is not necessarily the complete
rendered page. Search patterns nominate candidates, then inspect their use and linked evidence.

### What to Search For

- Generic transitions or filler obscuring the subject or actionable information.
- Empty lists and claims that provide no specific answer to the page's stated question.
- Statistics and study claims without identifiable, relevant support.
- Punctuation that creates a genuine ambiguity; punctuation frequency alone is not a defect.

### Actually Hurts SEO

- A page promises an answer but supplies only interchangeable platitudes. Quote both the
  promise and the content gap; describe the risk to usefulness, not an assumed search penalty.
- A statistic lacks available visible support after the scoped page/link check. Report a
  substantiation gap, not known fabrication.
- A claim contradicts its source. Quote both and match population, method, release, and units.
- Wording obscures a material condition or task. Quote the condition and explain the ambiguity.

### NOT a Problem

- Useful, supported content, whether human-written, AI-assisted, or of unknown provenance.
- Substantive numbered lists, legitimate technical terms, or exact UI labels.
- Necessary may/can qualifiers and conditions that prevent overstatement.
- Em dashes and transitions that improve clarity without creating an evidenced defect.

### Context Check

1. What question does the page promise to answer, and does it answer it concretely?
2. Is the disputed wording a claim, an exact name, a quotation, or a term of art?
3. Is relevant support available on the page or through its links? What was actually checked?
4. Is a factual claim contradicted, unsubstantiated on the inspected surface, or unverified?
5. Would the proposed rewrite preserve every condition, number, and uncertainty?
6. Is the reported impact evidenced, or merely inferred from a raw score?

### Severity tagging

- Calibrate to the substantiated effect on the reader's decision and the claim's stakes.
- A material contradiction can justify High; Critical requires demonstrated critical impact,
  not just a missing citation. Minor clarity issues are Low; repeated material confusion may
  justify Medium. Explain the chosen tier.
- No accepted defect after inspection → scoped Pass with evidence; unavailable truth/runtime
  evidence → Skip with what would unblock it.

### Fix voice

`honest-design-critic` (primary) | `content-shape-editor` (backup).
Read `souls/honest-design-critic.json` before writing the Fix. Keep the critique specific:
replace empty framing with the actual answer, preserve qualifications, and repair or remove
unsupported claims. A before/after score is mechanical evidence, not proof of factual accuracy
or improved ranking.

### Reference

Google Search guidance, checked 2026-09-04:
https://developers.google.com/search/blog/2023/02/google-search-and-ai-content

For E-E-A-T assessment rather than stylistic inference, use `references/eeat-assessment.md`.
