## CATEGORY 03: Structure, headings, landmarks, tables and input purpose

A sighted reader gets structure for free. Size, weight, spacing and position tell them what is a
heading, what is a group, which label belongs to which field, and which column a cell sits under. A
screen-reader user gets none of that unless the structure is in the markup. This category judges the
programmatic structure of a page against **1.3.1 Info and Relationships (A)**, **1.3.2 Meaningful
Sequence (A)**, **1.3.3 Sensory Characteristics (A)**, **1.3.4 Orientation (AA)**, **1.3.5 Identify
Input Purpose (AA)** and **2.4.6 Headings and Labels (AA)**.

The failure mode is almost always one shape: a visual relationship that exists only in CSS. A list
built from `<div>`s, a table with no header cells, a label beside an input without being tied to it,
a column order produced by `order: -1`. Each reads correctly on screen and falls apart in the
accessibility tree.

**Boundary.** This category asks whether the structure is programmatically available and whether
headings and labels describe what they name. When headings and semantic HTML are judged as **search
signals** — the outline a crawler builds, the machine readability of the document —
call the Skill tool with "snitch-marketing". When the question is whether a confusing heading
**loses one person on their decision path**, call the Skill tool with "snitch-ux". The same `<h3>`
can be a finding in more than one skill; report the criterion here and cross-file the rest.

### Pre-flight

Always run. Structure is static, cheap to read, and 1.3.1 is the most-cited Level A row after 1.1.1.

1. **The template set.** Which templates produce the pages in scope, and which share a layout. A
   defect in a shared layout is one finding across many URLs, not many findings.
2. **Declared intent.** Read `BLUEPRINT.md` and `marketing/positioning.md` read-only. A `Decision`
   line does not excuse a Level A failure; it caps a contradicting best-practice fix at Medium, and
   neither file present is a Skip with that reason.

Skip with reason `no rendered document in scope` only when there is no markup to read.

### Rule table

One row per success criterion. A finding names its row. A check with no row here is a Skip.

| SC | Level | What must hold | Static signal (source / DOM) | Runtime-only? | Severity |
|---|---|---|---|---|---|
| 1.3.1 Info and Relationships | A | Structure and relationships conveyed visually are available programmatically: landmarks, headings, lists, tables, labels, groups | no `<main>`; more than one visible `<main>`; more than one `<nav>` with no distinguishing label; visual list built from `<div>`s; data table with no `<th>` or no `scope`; layout table with no `role="presentation"`; input with no associated `<label>`; radio or checkbox group with no `<fieldset>` + `<legend>`; heading levels skipped downward | no | Critical (input unlabeled) / High (landmarks, headings, tables, groups) |
| 1.3.2 Meaningful Sequence | A | When the reading sequence affects meaning, the DOM order carries it | `order:` or `flex-direction: row-reverse` / `column-reverse` reordering content whose sequence matters; `grid-row` / `grid-column` placement that inverts reading order; absolutely positioned content read out of place; `float: right` on a leading block | partial | High |
| 1.3.3 Sensory Characteristics | A | Instructions do not rely solely on shape, color, size, visual location, orientation or sound | copy containing "the button on the right", "the round icon", "the green box", "below", "click the icon", with no name or text reference | no | Medium |
| 1.3.4 Orientation | AA | Content is not locked to one display orientation unless that orientation is essential | `screen.orientation.lock(`; web-app manifest `"orientation"` set to a fixed value; CSS that hides or blocks content under `@media (orientation: portrait)` or `landscape`; a "please rotate your device" interstitial | partial | High |
| 1.3.5 Identify Input Purpose | AA | Inputs collecting information **about the user** carry the right `autocomplete` token | personal-data field with no `autocomplete`, with `autocomplete="off"`, or with a token that does not match the field | no | Medium |
| 2.4.6 Headings and Labels | AA | Headings and labels describe the topic or purpose | placeholder headings ("Section", "Untitled"); one templated `<h1>` repeated verbatim across routes; labels that name a data type rather than what to enter ("Text", "Field 2") | no | Medium |

**Multiple `<h1>` elements are not a failure by themselves.** WCAG sets no rule about how many
`<h1>`s a page carries. 1.3.1 asks that heading levels reflect the real structure and do not skip
downward (an `<h2>` followed by an `<h4>`). Never report a second `<h1>` as a criterion failure; the
document outline a crawler builds is the sibling's judge. **Multiple `<main>` elements where all but
one carry `hidden` are also permitted** — only the visible one is exposed, so flag only more than
one *visible* `<main>`.

**Autocomplete token reference (1.3.5).** The criterion reaches only fields collecting information
about the user. These are the tokens the audit checks against:

| Field purpose | Token |
|---|---|
| Name, whole or in parts | `name`, `given-name`, `additional-name`, `family-name`, `honorific-prefix`, `honorific-suffix`, `nickname` |
| Account and credentials | `username`, `current-password`, `new-password`, `one-time-code` |
| Work | `organization`, `organization-title` |
| Address | `street-address`, `address-line1`, `address-line2`, `address-line3`, `address-level2` (city), `address-level1` (region), `postal-code`, `country`, `country-name` |
| Payment card | `cc-name`, `cc-number`, `cc-exp`, `cc-exp-month`, `cc-exp-year`, `cc-csc` |
| Contact | `email`, `tel`, `tel-national`, `impp` |
| Personal detail | `bday`, `sex`, `url`, `photo` |

Two rules follow from the criterion's own scope. **`autocomplete="off"` on a field that collects
personal data is the failure**, because the purpose is then not programmatically determinable. And
**a field that is not about the user needs no token**: a search box, a quantity, a coupon code, a
message body, a gift recipient's note. Never report a missing token on those.

### Evidence required

A finding needs an observation and a criterion. The observation is the quoted element at
`file:line` (source mode) or URL + selector (crawl mode).

**Source mode, cheapest first:**

1. `Grep` for `<main`, `<nav`, `<header`, `<footer`, `<aside` and the equivalent `role=` values.
   Build the landmark inventory per template, recording whether each `<nav>` carries `aria-label`.
2. `Grep` for `<h1`..`<h6` and `role="heading"`. Build the outline in document order, look for
   downward skips, and read heading and label strings against what they name (2.4.6).
3. `Grep` for repeated sibling `<div>`s that render as a list (cards, steps, nav items) and check
   whether `<ul>` / `<ol>` / `<li>` was used. `Grep` for `<table` and read whether each holds data
   or lays out a page: data tables need `<th>` with `scope`, plus a `<caption>` when the table needs
   a name; layout tables need `role="presentation"`.
4. Read every form. For each control, resolve the label: `<label for>` matching the control `id`, a
   wrapping `<label>`, `aria-label`, or `aria-labelledby` pointing at an existing id; a
   `placeholder` is not a label. Check every radio and checkbox group for a `<fieldset>` +
   `<legend>`, or a container with `role="group"` and a name.
5. `Grep` the CSS for `order:`, reverse flex directions, explicit `grid-row` / `grid-column`
   placement, `position:\s*absolute` and `float:\s*right` in layout regions, and compare the visual
   order they produce with the DOM order (1.3.2).
6. `Grep` copy for sensory instructions: `on the right`, `above`, `the round`, `the green`,
   `click the`. Read each in context (1.3.3).
7. `Grep` for `screen.orientation.lock`, `"orientation":` in the web-app manifest and
   `@media (orientation:` in CSS (1.3.4), then `autocomplete=` across every form, checking each
   personal-data field against the token table above (1.3.5).

**Crawl mode:** `Fetch` each page, quote the landmark inventory and heading outline from the
rendered HTML, then re-run steps 3 to 7 against the rendered DOM with URL + selector per element.
Compare the `<h1>` string across templates before reporting a repeated templated heading.

**Cascade caveat (every CSS-derived check):** a `Grep` or `Fetch` returns declarations, not the
resolved cascade. A reordering rule may be scoped to a breakpoint, overridden downstream, or applied
to a container holding no sequence-bearing content. Say so when the cascade is ambiguous, and
confirm the rendered order before asserting a 1.3.2 failure.

**Runtime confirmations.** 1.3.2 at a breakpoint, and 1.3.4 on a device, need a render. With no
runner or human, write `Skip — rendered reading order and orientation behavior require a human or
runner; not run`.

### Forbidden claims

- "The heading structure is a mess." Quote the outline in document order and name the skip.
- "Semantic HTML is missing." Name the element and the relationship it fails to express.
- "Forms may be unlabeled." Quote the control and the failed label lookup.
- "The reading order is wrong." Quote the CSS rule and the DOM order it contradicts, or Skip.
- Screen-reader announcement order asserted from source. Skip with the reason instead.
- Never write **compliant**, **conformant** or **non-compliant** as a verdict. Write "fails SC
  1.3.1 at these controls" and let the reader draw the line.
- A 1.3.1 finding for a second `<h1>`, or a 1.3.5 finding on a field that does not collect
  information about the user. Neither is reached by its criterion.
- A 1.3.3 finding for copy naming a control **and** its position. The criterion bans position as
  the *only* channel.

### Detection

Static read of markup, component source and CSS across the representative template set, in source or
crawl mode. Landmarks, headings, lists, tables, labels, groups and tokens resolve statically;
rendered reading order and orientation need a runtime confirmation.

### What to Search For

- Landmark inventory per template, and whether more than one `<nav>` shares an unlabeled role
- Heading sequence in document order, downward skips, and repeated sibling `<div>`s rendering as a
  list, steps, cards or breadcrumbs
- `<table>` markup: `<th>`, `scope`, `<caption>`, `headers`/`id`, `role="presentation"`
- Every form control and its label source, `placeholder` used as the only label, and radio or
  checkbox groups with no `<fieldset>` + `<legend>` and no named `role="group"`
- `order:`, reverse flex directions, grid placement, absolute positioning, floats; and copy that
  instructs by shape, color, size, position or sound alone
- `screen.orientation.lock(`, manifest `"orientation"`, orientation media queries that hide content
- `autocomplete` tokens on personal-data fields, `autocomplete="off"` on them, placeholder headings
  and labels, and one `<h1>` string repeated verbatim across routes

### Actually Fails

- **Form control with no programmatic label, including `placeholder`-as-label.** Evidence: the
  control and the failed lookup for `<label for>`, a wrapping label, `aria-label` or
  `aria-labelledby`. 1.3.1, Critical. The name half is 4.1.2 in Cat 11; cross-file it.
- **No `<main>`, more than one visible `<main>`, or two `<nav>` elements with no distinguishing
  `aria-label`.** Evidence: the landmark inventory, and for a duplicate `<main>`, both elements with
  neither carrying `hidden`. 1.3.1, High.
- **Heading level skipped downward** (an `<h2>` then an `<h4>`), **a visual list built from
  `<div>`s, or a data table with no `<th>` or no `scope`.** Evidence: the outline in document order,
  or the markup plus the CSS that renders the divs as a list. 1.3.1, High.
- **Radio or checkbox group with no `<fieldset>` + `<legend>` and no named `role="group"`.**
  Evidence: the group markup and the question it answers. 1.3.1, High.
- **Content reordered in CSS so the DOM sequence contradicts the meaningful order.** Evidence: the
  CSS rule, the DOM order, the rendered order. 1.3.2, High.
- **Layout table with no `role="presentation"`.** Evidence: the table markup. 1.3.1, Medium.
- **Instruction relying on shape, color, size, position or sound alone.** Evidence: the copy and
  the control it does not name. 1.3.3, Medium.
- **Orientation locked** by `screen.orientation.lock`, a fixed manifest `"orientation"`, or CSS
  hiding content in one orientation. Evidence: the call or declaration. 1.3.4, High.
- **Personal-data field with no `autocomplete` token, or with `autocomplete="off"`.** Evidence: the
  field markup and the token it should carry. 1.3.5, Medium.
- **Placeholder heading or non-descriptive label.** Evidence: the string. 2.4.6, Medium.

### NOT a Failure

- More than one `<h1>` on a page. Not a criterion.
- Multiple `<main>` elements where all but one carry `hidden`; a semantic `<main>` or `<nav>` with
  no redundant `role`; heading levels that climb back up (an `<h4>` then an `<h2>` starting a new
  section), since 1.3.1 reaches downward skips within a section, not the return.
- A layout table marked `role="presentation"`; `placeholder` alongside a real label, as a hint.
- A field not collecting information about the user with no `autocomplete` token: search, quantity,
  coupon, message body, a gift recipient's details. Likewise `autocomplete="off"` where the field
  holds none of the user's own stored personal data.
- Copy naming a control **and** its position; a single-orientation experience where that
  orientation is essential; visual reordering that does not change meaning; a `<div>` group that is
  genuinely not a list.

### Context Check

1. Is the defect in a shared layout or on one page? A layout defect is one finding, cited once,
   listing the affected routes.
2. Does the visual grouping match a programmatic group? A question with four radios is a group,
   and the question is its legend.
3. Does the reordering rule apply at the breakpoint audited? Quote the media query.
4. Does the field collect information about the user? If not, 1.3.5 does not reach it.
5. Which rows needed a render and did not get one? A Skip with a reason is coverage evidence.

### Severity

- **Critical** — form control with no programmatic label, including `placeholder`-as-label. A Level
  A failure that stops a person completing a form, and one demand letters cite often.
- **High** — missing or duplicated visible `<main>`; unlabeled duplicate `<nav>`; skipped headings;
  list or table semantics absent; group with no legend; sequence contradicted by CSS; locked
  orientation.
- **Medium** — layout table with no presentation role; sensory-only instruction; missing or wrong
  `autocomplete` token; placeholder or non-descriptive headings and labels.
- **Low** — structural advisories with no criterion. Report as `structure (advisory)`, no SC number.

### Fix guidance

**1. Tie every label to its control, and every group to its question.**

```html
<!-- Fails 1.3.1: the placeholder is not a label -->
<input type="email" name="email" placeholder="Email address">
<!-- Passes: label associated, purpose declared, hint kept as a hint -->
<label for="email">Email address</label>
<input id="email" type="email" name="email" autocomplete="email"
       placeholder="you@company.com">
<!-- A group's visible question becomes its legend -->
<fieldset><legend>How should we contact you?</legend> ... </fieldset>
```

**2. Let the element carry the relationship the CSS is currently faking.**

```html
<!-- Fails 1.3.1: <div class="steps"><div class="step">Connect the repo</div></div> -->
<!-- Passes: a list is announced as a list, with its length -->
<ol class="steps"><li class="step">Connect the repo</li></ol>

<!-- Data table: a caption names it, every header declares its scope -->
<table>
  <caption>Plan comparison</caption>
  <thead><tr><th scope="col">Plan</th><th scope="col">Seats</th></tr></thead>
  <tbody><tr><th scope="row">Team</th><td>10</td></tr></tbody>
</table>
```

**3. Write instructions that survive without sight, and let the device rotate.** "Press the round
button on the right" fails 1.3.3; "Press **Continue**, at the top right" passes, because the control
is named and position is a bonus. Delete any `screen.orientation.lock()` call and set the manifest
`"orientation"` to `"any"` (1.3.4).

The rule under all three: the accessibility tree should reconstruct the page from the markup alone.
If it takes the stylesheet to understand the content, the structure is in the wrong file. Report
first; apply nothing unconfirmed.

### Reference

WCAG 2.2, Level A: SC 1.3.1 Info and Relationships
https://www.w3.org/TR/WCAG22/#info-and-relationships · SC 1.3.2 Meaningful Sequence
https://www.w3.org/TR/WCAG22/#meaningful-sequence · SC 1.3.3 Sensory Characteristics
https://www.w3.org/TR/WCAG22/#sensory-characteristics

WCAG 2.2, Level AA: SC 1.3.4 Orientation https://www.w3.org/TR/WCAG22/#orientation · SC 1.3.5
Identify Input Purpose https://www.w3.org/TR/WCAG22/#identify-input-purpose (token list:
https://www.w3.org/TR/WCAG22/#input-purposes) · SC 2.4.6 Headings and Labels
https://www.w3.org/TR/WCAG22/#headings-and-labels

W3C tutorials: page structure https://www.w3.org/WAI/tutorials/page-structure/ · tables
https://www.w3.org/WAI/tutorials/tables/ · forms https://www.w3.org/WAI/tutorials/forms/ · ARIA
Authoring Practices https://www.w3.org/WAI/ARIA/apg/ · MDN `autocomplete`
https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/autocomplete
