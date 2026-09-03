# Report Template

The exact structure of `ADA_I18N_AUDIT_REPORT.md`. Read this before drafting the report. Fill in
every part in `{braces}`.

**Output path:** `{working_directory}/snitchfindings/{target_slug}/ADA_I18N_AUDIT_REPORT.md`. The
`{target_slug}` derives from the audited project in source mode or the domain in crawl mode. The
JSON and CSV exports land in the same folder as `ada_i18n_audit.json` and `ada_i18n_audit.csv`.

Three blocks are gates and cannot be skipped, degraded or reordered: the **executive snapshot**, the
**redaction gate**, and the **coverage block**. A report missing any of them does not save.

The structure is symmetric. Findings and passes get the same evidence rigor and the same depth. Do
not open with praise, and do not bury a Critical finding under a summary.

---

## Structure

```markdown
# Accessibility, Legal Exposure & i18n Readiness Audit, {project_name OR domain}

> Audited by Snitch: ADA on {date_iso}.
> Mode: {source / crawl / both}. Target: {working_directory OR url}.
> Standard: WCAG 2.2 Level AA. Categories run: {N} of {M} active.

## Executive snapshot

**Impact counts:** Critical {n} - High {n} - Medium {n} - Low {n} - Passes {n} - Skips {n}

**Principles covered:** Perceivable {findings}/{criteria checked} - Operable {...} - Understandable {...} - Robust {...}
{One line naming any principle with zero criteria checked, and why.}

**Exposure, in two sentences:** {Sentence 1: the regimes the STEP 0.5 answers put in play, each with
its verified date. Sentence 2: the Level A failures found, by criterion number, as the pattern those
regimes are judged on. No verdict, no prediction.}

**i18n readiness:** {One line: locales in scope, the source locale, and the single biggest gap -
or "Skipped: BLUEPRINT.md:{line} records the Decision '{quoted decision}'."}

**The three findings to read first:**

1. {Impact, Cat NN, SC or rule, one-line summary with its evidence location}
2. {...}
3. {...}
```

### Redaction gate (blocking, always on)

Before the draft becomes a file, sweep every line of it -- findings, passes, skips, snapshot,
metadata -- against `anti-hallucination.md` Rule 8. Personal data becomes `<redacted>`, tracking and
account identifiers become X's of the same shape, live secrets become X's and are flagged for a
security review. Locale catalogs and form fixtures are the two places real personal data hides;
re-read anything quoted from them.

The gate is not a step the report reports on. It produces no section. It either passed or the file
does not exist.

### Findings, grouped by principle then category

```markdown
## Findings

### Perceivable

#### Cat 04 - Use of color and contrast

##### Finding 1: {short title}
{full Finding Format block}

##### Finding 2: {short title}
{...}

#### Cat 01 - Text alternatives for non-text content
{...}

### Operable
{...}

### Understandable
{...}

### Robust
{...}

### Legal exposure
{compliance-typed findings from Cats 13, 14, 15 - outside the four principles}

### i18n readiness
{i18n-readiness-typed findings from Cats 16-22 - outside the four principles}
```

Group by principle **first**, category second, then by Impact within a category. A principle with no
findings still gets its heading and one line saying whether that is because its criteria passed or
because they were skipped:

```markdown
### Operable

No findings. 6 of 20 Operable criteria were checked and passed; 14 were skipped -
see the coverage block. The keyboard walk was not run, so this heading is not evidence
that the site is keyboard-operable.
```

That line is why the grouping is by principle. A skipped principle must be visible, not implied.

### The contrast verification table

Every contrast finding carries this table. A ratio is never asserted without both color values it
was computed from.

```markdown
| Element (file:line OR URL + selector) | Foreground | Background | Ratio | Required | Result |
|---|---|---|---|---|---|
| Hero subhead `src/components/Hero.tsx:34` | `#9aa0a6` | `#ffffff` | 2.64:1 | 4.5:1 | fail |
| Primary button `src/styles/buttons.css:12` | `#ffffff` | `#c9a84c` | 2.13:1 | 4.5:1 | fail |
| Body text `src/styles/base.css:8` | `#767676` | `#ffffff` | 4.54:1 | 4.5:1 | pass |
```

Required ratios: **4.5:1** normal text, **3:1** large text (24px or larger, or 18.66px or larger
bold) and non-text UI and meaningful graphics. 7:1 is 1.4.6, AAA, advisory only.

Compute each row with `python3 "${CLAUDE_SKILL_DIR}/scripts/contrast.py" '<fg>' '<bg>'`. Without
python3, write `not computed - python3 unavailable` in the Ratio cell rather than an estimate.
When either value came from a CSS variable or a theme token, resolve it first; if it could not be
resolved, say so in the row and cap the finding's confidence at Medium per the cascade caveat.

### Coverage block (blocking)

The denominator behind every claim in the report. **Every one of the 55 WCAG 2.2 Level A and AA
success criteria appears here, exactly once**, resolved against `wcag-criterion-map.md`.

```markdown
## Coverage

WCAG 2.2 Level A and AA: 55 criteria. Findings on {f} - Passed {p} - Skipped {s}.
4.1.1 Parsing: removed in 2.2 - not audited.

| SC | Name | Level | Cat | Outcome | Detail |
|---|---|---|---|---|---|
| 1.1.1 | Non-text Content | A | 01 | Finding (2) | see Findings 3, 7 |
| 1.2.1 | Audio-only and Video-only (Prerecorded) | A | 02 | Skip | not applicable: no audio-only or video-only media in the page set; established via grep for `<audio`, `<video` and known embed hosts across 8 pages |
| 1.2.4 | Captions (Live) | AA | 02 | Skip | Skip - live-caption verification requires a human or runner; not run. Unblock: none needed, no live media exists in the page set |
| 1.4.3 | Contrast (Minimum) | AA | 04 | Finding (6) | see the contrast table under Perceivable |
| 2.4.11 | Focus Not Obscured (Minimum) | AA | 06 | Skip | Skip - 2.4.11 requires a human or runner; not run. Unblock: focus each control with the sticky header and chat widget present |
| ... | ... | ... | ... | ... | ... |
```

Rules for the block:

- **A criterion whose category was not selected is a Skip**, with the reason
  `category NN not in this scan's selection`. It is never omitted and never a Pass.
- **A Pass carries the evidence it ran.** "Nothing found" is not a Pass; "verified via `<search>`
  returning 0 matches across `<scope>`" is.
- **A Skip carries the reason and the unblock condition.** The four runtime-only criteria - 1.2.4,
  1.4.13, 2.3.1, 2.4.11 - Skip with the verbatim wording whenever no runner or human tester ran.
- The three totals must add to 55. If they do not, the block is wrong and the report does not save.

### Legal exposure paragraph

```markdown
## Legal exposure

**Inputs (from discovery):** sector - {answer} - EU market presence - {answer} -
public-sector or federal-procurement customer - {answer} - prior demand letter or audit request -
{answer} - published accessibility commitment - {answer}

{Regime paragraphs, one per regime the inputs put in play. Each names the regime, what it binds,
its technical standard and version, its date, and the observed pattern from this audit. Each
carries its own "Facts verified: <date> against <URL>" line copied from legal-landscape.md.}

**Level A failures found:** {list by criterion number, or "none found in the criteria checked".}
{One sentence: Level A is the lowest bar and the tier most often cited in demand letters. Factual,
no prediction.}
```

Rules: never a verdict; never a litigation prediction; never a scope decision the inputs do not
support. A regime whose facts are unverified in `legal-landscape.md` carries the same
`(unverified - confirm at <URL>)` hedge here. A version mismatch is stated, not smoothed over: if
a finding is against a criterion new in WCAG 2.2 and the regime adopted an earlier version, say so.

If the five questions went unanswered, write one line: `Exposure could not be scoped - the discovery
questions were not answered. The regimes in legal-landscape.md are listed generically below.` Then
list them without attaching any of them to this site.

### i18n readiness section

```markdown
## i18n readiness

Locales in scope: {list} - Source locale: {locale} - i18n library / format: {name or "none detected"}

| Cat | Category | Findings | Passes | Skips | Note |
|---|---|---|---|---|---|
| 16 | String externalization | 4 | 2 | 0 | |
| 17 | Message format and plurals | 1 | 3 | 1 | ICU plural categories beyond `one`/`other` not exercised |
| 18 | Locale formatting | 0 | 5 | 0 | |
| 19 | Text direction and layout | 2 | 1 | 1 | no RTL locale served; bidi checks are forward-looking |
| 20 | Locale routing and switching | 0 | 4 | 0 | |
| 21 | Translation catalog integrity | 6 | 1 | 0 | from catalog-diff over 4 catalogs |
| 22 | Input and data assumptions | 3 | 2 | 0 | |
```

One row per i18n category that was selected. A category not selected is omitted from the table and
named in the skipped-checks list instead. When a recorded `Decision` in `BLUEPRINT.md` made these
categories Skip, the whole section is one line quoting the decision and its `BLUEPRINT.md:{line}`.

### Skipped checks

```markdown
## Skipped checks

| What | Why | What would unblock it |
|---|---|---|
| Keyboard walk (2.1.1, 2.1.2, 2.4.3, 2.4.7) | requires a human or runner; not run | Tab through the 8-page set, recording order, traps, and modal focus in and out |
| Screen-reader pass (1.3.1, 4.1.2, 4.1.3) | requires a human or runner; not run | Walk the page set with a screen reader and record announcement order |
| SC 1.4.13 Content on Hover or Focus | runtime-only | Hover and focus each tooltip; confirm dismissible, hoverable, persistent |
| Cat 15 Documents and downloads | not in this scan's selection | Re-run with the `legal` or `media` group |
| Locale `ar-EG` | not served; no catalog present | Add the catalog, then re-run Cat 19 and Cat 21 |
```

Every Skip in the audit appears here. This table plus the coverage block is what makes the report's
limits legible; without them a partial audit reads like a full one.

### Suppressed

List every inline `snitch-ada-ignore` comment and every `.snitch-ada-ignore` entry that matched
something this run, with its rule and its reason, plus any entry that matched nothing as stale. A
suppression the reader cannot see is a suppression they cannot review.

### Footer and metadata block

```markdown
---

Audited by Snitch: ADA, 22 categories. Get the latest version: https://snitchplugin.com/ada

## Audit metadata

| | |
|---|---|
| Date | {date_iso} |
| Mode | {source / crawl / both} |
| Pages in scope | {the 5-10 page set, listed} |
| Locales in scope | {list, or "one locale; no i18n library detected"} |
| Stack detected | {framework and version, or "hosted builder: crawl only"} |
| Automated runner | {name and version, or "none; runtime-only criteria skipped"} |
| Categories run | {IDs, and the preset that selected them} |
| Criteria covered | {f} findings, {p} passes, {s} skips of 55 |
| Declared intent | {BLUEPRINT.md and marketing/positioning.md read, or "neither file present - skipped"} |
| Scripts used | {contrast.py / catalog-diff.py, or "python3 unavailable"} |
| Aborted at | {"category N of M" if the user stopped the audit, otherwise omit this row} |
```

---

## A worked finding

This is the shape every finding takes. Nothing in it is optional on a Critical or High.

```markdown
##### Finding 3: Checkout email input has no programmatic label

- **Impact:** Critical
- **Rule:** WCAG 2.2 SC 3.3.2 Labels or Instructions (Level A)
- **Surface:** Source
- **Evidence:** `src/routes/checkout/ContactStep.tsx:41`

  ```tsx
  <input
    type="email"
    className="field field--wide"
    placeholder="Email address"
    onChange={handleEmail}
  />
  ```

  No `<label for>`, no wrapping `<label>`, no `aria-label`, no `aria-labelledby`. Verified via
  `grep -nE "aria-label|aria-labelledby|<label" src/routes/checkout/` returning 0 matches for this
  input across the 3 files in that route. The placeholder is not a label: it disappears on focus and
  is not exposed as the accessible name by every assistive technology.

- **Risk:** A screen-reader user reaching this field hears "edit text, blank" and has no way to know
  what to enter, on the one required step of the purchase path. Unlabeled inputs are a Level A
  failure and one of the patterns cited most often in web accessibility demand letters.
- **Fix:** Give the input a real label and keep the placeholder as a format hint, not as the name.

  ```tsx
  <label htmlFor="checkout-email">Email address</label>
  <input
    id="checkout-email"
    type="email"
    name="email"
    autoComplete="email"
    className="field field--wide"
    placeholder="you@example.com"
    onChange={handleEmail}
  />
  ```

  `autoComplete="email"` also satisfies 1.3.5 Identify Input Purpose for this field.

- **Confidence:** High
- **Verify:** Re-run an automated pass and confirm the label-association rule reports zero
  violations on `/checkout`; then Tab to the field with a screen reader running and confirm it
  announces "Email address, edit text".
```

Notes on the shape:

- **Evidence** is the quoted element plus, for any negative claim, the search that ran and its scope.
- **Risk** names who is blocked and what exposure attaches. It never predicts a lawsuit.
- **Fix** opens with the action. It carries the corrected snippet. It never opens with a framing
  sentence about why accessibility matters.
- **Verify** is required on Critical and High: a runner rule, a keyboard-walk step, or a catalog
  diff, something the reader can run.
- **Any fix touching a color value or a brand token** additionally carries the before value, the
  after value and both ratios, and takes per-finding confirmation even in a batch apply.

---

## Export columns

### JSON, `ada_i18n_audit.json`

```json
{
  "tool": "snitch-ada",
  "version": "{skill metadata.version}",
  "date": "{date_iso}",
  "mode": "source|crawl|both",
  "target": "{path or url}",
  "pages_in_scope": ["..."],
  "locales_in_scope": ["..."],
  "categories_run": ["01", "04", "10"],
  "runner": "{name or null}",
  "counts": {"critical": 0, "high": 0, "medium": 0, "low": 0, "pass": 0, "skip": 0},
  "coverage": [
    {"sc": "1.1.1", "name": "Non-text Content", "level": "A", "category": "01",
     "outcome": "finding|pass|skip", "detail": "..."}
  ],
  "findings": [
    {"id": 3, "impact": "Critical", "rule": "WCAG 2.2 SC 3.3.2 (A)", "category": "10",
     "principle": "Understandable", "surface": "source",
     "evidence_location": "src/routes/checkout/ContactStep.tsx:41",
     "evidence_snippet": "...", "risk": "...", "fix": "...", "fix_snippet": "...",
     "confidence": "High", "verify": "...", "touches_color_token": false}
  ],
  "skipped": [{"what": "...", "why": "...", "unblock": "..."}],
  "suppressed": [{"rule": "...", "reason": "...", "source": "inline|ignore-file", "matched": true}],
  "exposure": {"inputs": {}, "regimes": [{"name": "...", "facts_verified": "...", "source": "..."}]}
}
```

The exposure block carries the `facts_verified` date and source URL per regime. An export that drops
them turns a hedged fact into a bare assertion, which is the failure Rule 4 exists to prevent.

### CSV, `ada_i18n_audit.csv`

One row per finding. Header, in this order:

```
id,impact,rule,sc,level,category_id,category_slug,principle,surface,evidence_location,evidence_snippet,risk,fix,confidence,verify,touches_color_token
```

`evidence_snippet` and `fix` are quoted and newline-escaped. Passes and skips do not appear in the
CSV; they live in the coverage block and the skipped-checks table, which the JSON export carries in
full.
