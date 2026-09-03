# Category Manifest

The single source of truth for category identity and attributes. Every rule elsewhere that
depends on "which categories" resolves against this table — never against a hardcoded number list.

**Rules derived from Type.** This skill's types classify **how a finding must be written**, because
the three judges it carries answer to three different authorities. Three types, each with one
obligation:

- `criterion` — every finding names a WCAG 2.2 success criterion row from the category's own rule
  table. A check with no row is a **Skip**, never silence and never a finding filed under a
  borrowed criterion. Every A/AA criterion is owned by exactly one criterion-typed category, so a
  criterion that appears in no rule table anywhere is a defect in `references/wcag-criterion-map.md`,
  not a judgment call at audit time.
- `compliance` — every finding names the law, regulation or standard it reports against, plus the
  observed pattern. It states **exposure, never a verdict**, and it carries a `Facts verified`
  hedge on anything that moves: dates, deadlines, population thresholds, standard versions. The
  verified facts live in `references/legal-landscape.md`; a fact that reference could not verify is
  written with an `(unverified — confirm at <URL>)` hedge rather than asserted.
- `i18n-readiness` — evidence is the code pattern at `file:line` in source mode, or the served page
  at URL + selector in crawl mode. It never asserts translation **quality**; that is judged against
  rendered content by snitch-marketing, not here.

Type is orthogonal to Groups. A group is what a user selects in one tap; a type is how the finding
must be written.

**Groups** are the preset audit selections. A preset resolves to *every active row whose Groups cell
contains that preset's slug*, read out of this table at scan time — never to a stored ID list. Six
slugs:

- `quick` — the cheap static checks that catch what demand letters cite most.
- `wcag-aa` — every criterion row, the full A/AA sweep.
- `legal` — exposure posture, the accessibility statement and overlays, linked documents.
- `i18n` — internationalization and localization readiness.
- `forms` — labels, errors, ARIA wiring, and the data assumptions behind input fields.
- `media` — time-based media and downloadable documents.

`full` is every active row and is therefore not listed per row. `references/scan-selection.md` owns
the menu and the alias table; it resolves against this manifest and stores no ID lists of its own.

**Standards** is the external authority a finding cites when one exists. `—` means the category is a
readiness judgment with no governing spec; those findings carry the pattern name from the category's
rule table and nothing more.

**Status.** Four values, and the ID is permanent under all four — a number is never reused,
reordered, or renumbered:

- `active` — auditable. The file exists and the audit runs it.
- `merged→NN` — the category's checks now live in category `NN` of this skill. The row stays so the
  number stays reserved and old reports remain readable; the file becomes a short redirect stub, no
  scan selects the ID, and cross-references are rewritten to point at `NN`.
- `moved→snitch-<skill>` — the judge for these findings belongs to a sibling skill, so the checks
  live there now. The row stays reserved; this skill hands off by calling the Skill tool with that
  skill rather than auditing it here.
- `deleted` — the checks were out of scope and no sibling took them. The row stays so the number
  stays reserved and old reports stay readable; the file is removed and no cross-reference to it
  survives.

A row's Status is what decides whether it runs. Nothing selects a category by number range, so a
row changing status needs no edit anywhere that reads this manifest by attribute. Anything stating a
category *count* is a separate manual update: the "Active categories" line below and `SKILL.md`.

Active categories: 22 of 22 rows.

| ID | Slug | Title | Type | Groups | Standards | Status |
|----|------|-------|------|--------|-----------|--------|
| 01 | text-alternatives | Text alternatives for non-text content | criterion | quick, wcag-aa | WCAG 2.2 1.1.1, 1.4.5 | active |
| 02 | time-based-media | Captions, transcripts and audio control | criterion | wcag-aa, media | WCAG 2.2 1.2.1–1.2.5, 1.4.2 | active |
| 03 | structure-and-relationships | Structure, headings, landmarks, tables and input purpose | criterion | quick, wcag-aa, forms | WCAG 2.2 1.3.1, 1.3.2, 1.3.3, 1.3.4, 1.3.5, 2.4.6 | active |
| 04 | color-and-contrast | Use of color and contrast | criterion | quick, wcag-aa | WCAG 2.2 1.4.1, 1.4.3, 1.4.11 | active |
| 05 | reflow-zoom-and-spacing | Resize, reflow, text spacing and hover content | criterion | wcag-aa | WCAG 2.2 1.4.4, 1.4.10, 1.4.12, 1.4.13 | active |
| 06 | keyboard-operability | Keyboard operability and focus management | criterion | quick, wcag-aa | WCAG 2.2 2.1.1, 2.1.2, 2.1.4, 2.4.3, 2.4.7, 2.4.11 | active |
| 07 | pointer-and-target-size | Pointer gestures, cancellation, label in name, motion and target size | criterion | wcag-aa | WCAG 2.2 2.5.1, 2.5.2, 2.5.3, 2.5.4, 2.5.7, 2.5.8 | active |
| 08 | timing-and-motion | Timing, moving content and flashes | criterion | wcag-aa | WCAG 2.2 2.2.1, 2.2.2, 2.3.1 | active |
| 09 | navigation-and-consistency | Bypass blocks, titles, link purpose, multiple ways, predictable behavior, consistent help | criterion | wcag-aa | WCAG 2.2 2.4.1, 2.4.2, 2.4.4, 2.4.5, 3.2.1, 3.2.2, 3.2.3, 3.2.4, 3.2.6 | active |
| 10 | forms-and-errors | Labels, error identification and suggestion, redundant entry, accessible authentication | criterion | quick, wcag-aa, forms | WCAG 2.2 3.3.1, 3.3.2, 3.3.3, 3.3.4, 3.3.7, 3.3.8 | active |
| 11 | name-role-value-and-status | Accessible name, role, state and status messages (ARIA) | criterion | quick, wcag-aa, forms | WCAG 2.2 4.1.2, 4.1.3 | active |
| 12 | language-of-content | Language of page and of parts | criterion | quick, wcag-aa, i18n | WCAG 2.2 3.1.1, 3.1.2 | active |
| 13 | legal-exposure | Legal exposure (ADA Titles II / III, Section 508, EAA, AODA, UK PSBAR) | compliance | quick, legal | ADA; Section 508 / EN 301 549; EAA 2019/882 | active |
| 14 | accessibility-statement-and-overlays | Accessibility statement, feedback channel and overlay widgets | compliance | legal | EAA 2019/882; EN 301 549; UK PSBAR | active |
| 15 | documents-and-downloads | Accessibility of linked documents (PDF, Office) | compliance | legal, media | PDF/UA (ISO 14289); WCAG 2.2 1.1.1, 1.3.1 | active |
| 16 | string-externalization | User-facing strings live in message catalogs, not code | i18n-readiness | i18n | — | active |
| 17 | message-format-and-plurals | Plural, gender, select and sentence assembly | i18n-readiness | i18n | Unicode CLDR plural rules; ICU MessageFormat | active |
| 18 | locale-formatting | Dates, times, numbers, currency, units and time zones | i18n-readiness | i18n | ECMA-402 (Intl); Unicode CLDR | active |
| 19 | text-direction-and-layout | Bidi / RTL, logical properties, text expansion, script-aware typography | i18n-readiness | i18n | Unicode Bidirectional Algorithm (UAX #9); CSS Logical Properties | active |
| 20 | locale-routing-and-switching | Locale negotiation, the language switcher and locale persistence | i18n-readiness | i18n | RFC 9110 Accept-Language; BCP 47 | active |
| 21 | translation-catalog-integrity | Catalog completeness, placeholder parity, stale and invalid entries | i18n-readiness | quick, i18n | Unicode CLDR plural rules | active |
| 22 | input-and-data-assumptions | Names, addresses, phone, Unicode handling, collation and case | i18n-readiness | i18n, forms | Unicode UAX #15 (normalization), UAX #29 (grapheme clusters); ECMA-402 Intl.Collator | active |

**Criterion ownership.** Categories 01-12 partition every WCAG 2.2 Level A and Level AA success
criterion — 55 of them — with no overlap and no gap. `references/wcag-criterion-map.md` is the
authoritative mapping and the source of every report's coverage block. 4.1.1 Parsing was removed in
WCAG 2.2 and is listed there as removed, never audited.

**Boundary with siblings.** Cat 01 judges alt against 1.1.1; image alt as a search signal is
snitch-marketing's. Cat 12 judges `lang` against 3.1.1 and 3.1.2; `lang` as a machine-readability
signal is snitch-marketing's. Cat 20 judges whether a person can reach and stay in their language;
hreflang and locale canonicals, which is how search engines are told, are snitch-marketing's. Cat 21
judges the catalog files in source; the content quality of a rendered translated page is
snitch-marketing's. Any barrier judged against one user finishing a task is snitch-ux's. Each
category file states its own half in one Boundary paragraph.
