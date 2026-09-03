# WCAG 2.2 Criterion Map

Every WCAG 2.2 Level A and Level AA success criterion, the snitch-ada category that owns it, and
whether it can be evidenced statically. **This file is the source of the report's coverage block.**
Every criterion below appears there as Finding, Pass or Skip. A criterion missing from the coverage
block is the defect the block exists to prevent.

`Facts verified: 2026-09-03 against https://www.w3.org/TR/WCAG22/`

**WCAG 2.2 has 55 Level A and AA success criteria** — 31 at Level A, 24 at Level AA. Categories
01-12 partition them with no overlap and no gap.

**4.1.1 Parsing is removed in WCAG 2.2 — not audited.** It was removed from the standard, not
downgraded. Do not emit a finding under it, do not list it as a Pass, and list it in the coverage
block only as `removed in 2.2 — not audited`. A runner that still reports it (duplicate IDs,
unclosed tags) is reporting against WCAG 2.1; triage those results under 1.3.1 or 4.1.2 if the
markup defect actually breaks structure or an accessible name, and drop them otherwise.

**New in WCAG 2.2** at Level A or AA: 2.4.11, 2.5.7, 2.5.8, 3.2.6, 3.3.7, 3.3.8. Six criteria. A
site last audited against WCAG 2.1 has never been checked against any of them, which is where the
new findings usually are.

## Evidence column

- `static` — the criterion can produce a finding from source or served HTML alone. The cascade
  caveat in `anti-hallucination.md` still applies to anything CSS-derived.
- `static + runtime confirm` — a strong static signal can produce a finding, but the finding carries
  the caveat that the resolved behavior was not observed. Confidence is capped at Medium without
  observation.
- `runtime-only` — no static signal settles it. Without a runner or a human tester the criterion
  **Skips** with the verbatim wording `Skip — <check> requires a human or runner; not run`.

---

## Principle 1 — Perceivable

| SC | Name | Level | New in 2.2 | Category | Evidence |
|---|---|---|---|---|---|
| 1.1.1 | Non-text Content | A | | 01 text-alternatives | static |
| 1.2.1 | Audio-only and Video-only (Prerecorded) | A | | 02 time-based-media | static |
| 1.2.2 | Captions (Prerecorded) | A | | 02 time-based-media | static |
| 1.2.3 | Audio Description or Media Alternative (Prerecorded) | A | | 02 time-based-media | static |
| 1.2.4 | Captions (Live) | AA | | 02 time-based-media | runtime-only |
| 1.2.5 | Audio Description (Prerecorded) | AA | | 02 time-based-media | static + runtime confirm |
| 1.3.1 | Info and Relationships | A | | 03 structure-and-relationships | static |
| 1.3.2 | Meaningful Sequence | A | | 03 structure-and-relationships | static + runtime confirm |
| 1.3.3 | Sensory Characteristics | A | | 03 structure-and-relationships | static |
| 1.3.4 | Orientation | AA | | 03 structure-and-relationships | static |
| 1.3.5 | Identify Input Purpose | AA | | 03 structure-and-relationships | static |
| 1.4.1 | Use of Color | A | | 04 color-and-contrast | static |
| 1.4.2 | Audio Control | A | | 02 time-based-media | static |
| 1.4.3 | Contrast (Minimum) | AA | | 04 color-and-contrast | static + runtime confirm |
| 1.4.4 | Resize Text | AA | | 05 reflow-zoom-and-spacing | static + runtime confirm |
| 1.4.5 | Images of Text | AA | | 01 text-alternatives | static |
| 1.4.10 | Reflow | AA | | 05 reflow-zoom-and-spacing | static + runtime confirm |
| 1.4.11 | Non-text Contrast | AA | | 04 color-and-contrast | static + runtime confirm |
| 1.4.12 | Text Spacing | AA | | 05 reflow-zoom-and-spacing | static + runtime confirm |
| 1.4.13 | Content on Hover or Focus | AA | | 05 reflow-zoom-and-spacing | runtime-only |

## Principle 2 — Operable

| SC | Name | Level | New in 2.2 | Category | Evidence |
|---|---|---|---|---|---|
| 2.1.1 | Keyboard | A | | 06 keyboard-operability | static |
| 2.1.2 | No Keyboard Trap | A | | 06 keyboard-operability | static + runtime confirm |
| 2.1.4 | Character Key Shortcuts | A | | 06 keyboard-operability | static |
| 2.2.1 | Timing Adjustable | A | | 08 timing-and-motion | static + runtime confirm |
| 2.2.2 | Pause, Stop, Hide | A | | 08 timing-and-motion | static + runtime confirm |
| 2.3.1 | Three Flashes or Below Threshold | A | | 08 timing-and-motion | runtime-only |
| 2.4.1 | Bypass Blocks | A | | 09 navigation-and-consistency | static |
| 2.4.2 | Page Titled | A | | 09 navigation-and-consistency | static |
| 2.4.3 | Focus Order | A | | 06 keyboard-operability | static + runtime confirm |
| 2.4.4 | Link Purpose (In Context) | A | | 09 navigation-and-consistency | static |
| 2.4.5 | Multiple Ways | AA | | 09 navigation-and-consistency | static |
| 2.4.6 | Headings and Labels | AA | | 03 structure-and-relationships | static |
| 2.4.7 | Focus Visible | AA | | 06 keyboard-operability | static |
| 2.4.11 | Focus Not Obscured (Minimum) | AA | new | 06 keyboard-operability | runtime-only |
| 2.5.1 | Pointer Gestures | A | | 07 pointer-and-target-size | static |
| 2.5.2 | Pointer Cancellation | A | | 07 pointer-and-target-size | static |
| 2.5.3 | Label in Name | A | | 07 pointer-and-target-size | static |
| 2.5.4 | Motion Actuation | A | | 07 pointer-and-target-size | static |
| 2.5.7 | Dragging Movements | AA | new | 07 pointer-and-target-size | static |
| 2.5.8 | Target Size (Minimum) | AA | new | 07 pointer-and-target-size | static + runtime confirm |

## Principle 3 — Understandable

| SC | Name | Level | New in 2.2 | Category | Evidence |
|---|---|---|---|---|---|
| 3.1.1 | Language of Page | A | | 12 language-of-content | static |
| 3.1.2 | Language of Parts | AA | | 12 language-of-content | static |
| 3.2.1 | On Focus | A | | 09 navigation-and-consistency | static + runtime confirm |
| 3.2.2 | On Input | A | | 09 navigation-and-consistency | static + runtime confirm |
| 3.2.3 | Consistent Navigation | AA | | 09 navigation-and-consistency | static |
| 3.2.4 | Consistent Identification | AA | | 09 navigation-and-consistency | static |
| 3.2.6 | Consistent Help | A | new | 09 navigation-and-consistency | static + runtime confirm |
| 3.3.1 | Error Identification | A | | 10 forms-and-errors | static |
| 3.3.2 | Labels or Instructions | A | | 10 forms-and-errors | static |
| 3.3.3 | Error Suggestion | AA | | 10 forms-and-errors | static |
| 3.3.4 | Error Prevention (Legal, Financial, Data) | AA | | 10 forms-and-errors | static + runtime confirm |
| 3.3.7 | Redundant Entry | A | new | 10 forms-and-errors | static + runtime confirm |
| 3.3.8 | Accessible Authentication (Minimum) | AA | new | 10 forms-and-errors | static |

## Principle 4 — Robust

| SC | Name | Level | New in 2.2 | Category | Evidence |
|---|---|---|---|---|---|
| 4.1.1 | Parsing | — | | — | removed in 2.2 — not audited |
| 4.1.2 | Name, Role, Value | A | | 11 name-role-value-and-status | static |
| 4.1.3 | Status Messages | AA | | 11 name-role-value-and-status | static + runtime confirm |

---

## Counts, for the coverage block

| Principle | Level A | Level AA | Total |
|---|---|---|---|
| 1 Perceivable | 9 | 11 | 20 |
| 2 Operable | 14 | 6 | 20 |
| 3 Understandable | 7 | 6 | 13 |
| 4 Robust | 1 | 1 | 2 |
| **All** | **31** | **24** | **55** |

Each criterion is counted under the principle its number belongs to, which is not always the
principle of the category that audits it: 1.4.2 Audio Control is a Perceivable criterion audited by
Cat 02, and 2.4.6 Headings and Labels is an Operable criterion audited by Cat 03. The coverage block
reports by criterion, so 55 is the number that must reconcile.

**Runtime-only criteria: 1.2.4, 1.4.13, 2.3.1, 2.4.11.** Four criteria can never produce a finding
without a runner or a human. When no runner is available, all four appear in every coverage block as
Skip with the verbatim wording, and the report says so in the skipped-checks list. That is not a gap
in the audit; it is the audit reporting its own limits.

---

## AAA criteria commonly mistaken for AA — advisory only, never a finding

These are Level AAA. They are worth reporting as an **advisory** note when the evidence is already
in hand, clearly labeled as AAA, and they are **never** written as a Level AA failure and never
counted in the coverage block.

| SC | Name | Level | Why it gets confused |
|---|---|---|---|
| 1.4.6 | Contrast (Enhanced) | AAA | The 7:1 ratio. AA is 4.5:1 for normal text and 3:1 for large text and non-text UI. Report 7:1 as advisory only. |
| 2.3.3 | Animation from Interactions | AAA | `prefers-reduced-motion` is good practice and widely expected, but no AA criterion requires it. 2.2.2 covers auto-playing motion, which is different. |
| 2.4.9 | Link Purpose (Link Only) | AAA | "Read more" is judged at AA under 2.4.4 **in context** — surrounding text and the enclosing element count. Only AAA requires the link text to stand alone. |
| 2.5.5 | Target Size (Enhanced) | AAA | The 44×44 figure, introduced in WCAG 2.1 and often quoted as if it were the 2.2 requirement. **One target floor: 24×24 CSS px under 2.5.8 (AA) is the only threshold that emits a finding.** |
| 3.1.5 | Reading Level | AAA | Readability scores. Plain language is worth advising; no AA criterion sets a reading level. |

Also AAA and also new in 2.2, so also not AA findings: **2.4.12 Focus Not Obscured (Enhanced)**,
**2.4.13 Focus Appearance**, and **3.3.9 Accessible Authentication (Enhanced)**. The AA halves of
those pairs are 2.4.11 and 3.3.8, which are in the tables above.

One more line that is not a criterion at all: **the 16px body-text floor is a readability advisory**.
Body text under 16px on mobile, line-height under 1.4 on paragraphs, and reading columns beyond ~80
characters are worth reporting as advisory findings with the CSS rule quoted. They are not 1.4.4,
which is about scaling to 200%, and attaching a criterion number to them is a forbidden claim.

---

## Reference

WCAG 2.2 specification: https://www.w3.org/TR/WCAG22/

Understanding WCAG 2.2 (per-criterion intent, techniques and failures):
https://www.w3.org/WAI/WCAG22/Understanding/

What's new in WCAG 2.2: https://www.w3.org/WAI/standards-guidelines/wcag/new-in-22/

W3C ARIA Authoring Practices, for the canonical keyboard and landmark patterns:
https://www.w3.org/WAI/ARIA/apg/
