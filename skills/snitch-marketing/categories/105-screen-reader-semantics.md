## CATEGORY 105: Screen reader semantics audit

Screen readers (NVDA on Windows, JAWS, VoiceOver on Mac/iOS, TalkBack on Android, Orca on Linux) are the highest-stakes a11y surface, used by blind users, low-vision users, users with cognitive processing differences, and an increasing share of multitasking sighted users (drivers, hands-busy contexts). The screen reader experience is determined by HTML semantics + ARIA roles + announcement order + dynamic update behavior. Cat 48 covers ARIA labels; Cat 17 covers semantic HTML; this category audits the actual screen-reader-perceived journey: heading hierarchy as navigation map, landmark structure, dynamic updates announced via live regions, form errors announced inline, table semantics for data, list semantics for groups.

### Pre-flight: relevance check

Run on every site that has any informational or interactive content. Skip with reason `not applicable` only for very small static brand pages with no headings, lists, forms, or dynamic content.

### The framework: 6 audit dimensions

| Dimension | What screen reader users rely on | Common failure |
|---|---|---|
| **1. Landmark structure** | `<main>`, `<nav>`, `<header>`, `<footer>`, `<aside>` for jumping around | Single `<div>` soup; no landmarks; more than one `<main>` lacking `hidden` |
| **2. Heading hierarchy** | H1-H6 as navigation map (jump-to-heading shortcut) | Skipped levels; multiple H1s; visual heading sizes that don't match semantic level |
| **3. List semantics** | `<ul>` / `<ol>` / `<dl>` announce item count + position | Visual list using `<div>`s; no role; user can't tell it's a list |
| **4. Form labels + errors** | Field purpose announced + error announced inline | Floating labels not associated; errors visual-only |
| **5. Live regions** | `aria-live` / `role="status"` / `role="alert"` for dynamic updates | Toast notifications appear visually only |
| **6. Image text alternatives** | `alt`, `aria-label`, or `aria-labelledby` for images conveying info | Decorative images announced; informative images silent |

### Evidence required (do not skip)

The static checks below run directly against source. Driving an actual screen reader (announcement order, what's silent or mis-announced, live-region behavior) needs a human or an external runner — the bundle ships neither. Do the static checks; for each runtime step, run it only if a human tester or runner is available, otherwise Skip-with-reason (e.g. `screen-reader walk requires a human or runner — not run`). Static structure can reveal likely failures (no `<th scope>`, missing live region), but don't assert what a screen reader announces unless someone listened.

**Static checks (perform directly on source):**

1. `Grep` for landmark elements: `<main`, `<nav`, `<header`, `<footer`, `<aside`. Quote count per page (flag more than one `<main>` lacking the `hidden` attribute).
2. `Grep` for heading levels: `<h1` through `<h6`. Confirm hierarchy per page (Cat 16 cross-ref).
3. `Grep` for list elements: `<ul`, `<ol`, `<dl`. Identify visual lists built with `<div>`s instead.
4. Read form components. Check `<label htmlFor>` association OR `aria-labelledby`. Check error rendering markup (`aria-describedby`, live region presence).
5. `Grep` for live regions: `aria-live=`, `role="status"`, `role="alert"`. Check if dynamic UI uses them.
6. `Grep` for table elements. Tables with tabular data need `<th>` with `scope`, `<caption>`, optionally `<thead>` / `<tbody>`.

**Runtime checks (requires a human or external runner; otherwise Skip-with-reason):**

1. Test with a screen reader (VoiceOver on Mac is built-in: Cmd+F5; NVDA on Windows is free; Orca on Linux). Walk the page.
2. Quote screen reader announcements vs visual content. Note any element that's silent OR mis-announced.
3. Trigger a form error. Note whether the error is announced or only visible.
4. Trigger a dynamic update (notification, toast, status change). Note whether announced.

Crawl mode carries the same split: static structure checks apply to the fetched HTML; the screen-reader walk is a runtime step — Skip-with-reason unless a human or runner performs it.

### Forbidden claims

- "Screen reader experience may be poor." Quote the static signal (missing landmark, no `<th scope>`, no live region); for announcement quality, test with a screen reader and quote it, or Skip-with-reason.
- "Form errors may not be announced." Quote the static signal (error markup with no `aria-describedby` / live region); for the live announcement, trigger an error and record it, or Skip-with-reason.
- "Headings may be wrong." Quote the heading sequence from source (skipped levels are visible statically); for the screen-reader heading walk, Skip-with-reason unless a human/runner did it.

### What to Search For

- Landmark coverage (one `<main>`, one or more `<nav>`, etc.)
- Heading hierarchy + levels
- Visual lists implemented as `<div>`s
- Form `<label>` associations + error announcement patterns
- Live region usage for dynamic content
- Table semantics (`<th scope>`, `<caption>`)
- Image text alternatives matched to image purpose

### Actually Hurts the Marketing Surface

- **No landmark structure** (`<main>` missing; user can't skip nav).
  Evidence required: page source + landmark inventory.
- **More than one `<main>` lacking `hidden`** (HTML5 permits multiple `<main>` only if all but one carry the `hidden` attribute; two visible `<main>` elements make landmark navigation ambiguous and screen readers behave inconsistently).
  Evidence required: count + which `<main>` elements lack `hidden`.
- **Heading hierarchy skipped** (H1 → H4 with no H2/H3 between).
  Evidence required: heading sequence.
- **Visual list rendered as `<div>`s** (screen reader user can't perceive item count).
  Evidence required: visible list-shaped content + missing semantic list.
- **Form label not associated** (the `<label>` is visual but `htmlFor` doesn't match the input id).
  Evidence required: label + input source.
- **Form error visual only** (red text + icon, no `aria-describedby` linking input to error, no live region announcing error).
  Evidence required: error component without ARIA association.
- **Toast / notification appears without `role="alert"` or `aria-live`** (silent for screen reader).
  Evidence required: toast component source + missing ARIA.
- **Decorative image announced** (image has `alt="image-decorative-flourish"` instead of `alt=""`).
  Evidence required: image source.
- **Informative image silent** (image conveys data, chart, graph, infographic, with empty alt and no description).
  Evidence required: image + missing description.
- **Data table without `<th scope>`** (rows + columns ambiguous to screen reader).
  Evidence required: table source.
- **Layout tables (using `<table>` for layout, not data)**, deprecated pattern that confuses screen readers.
  Evidence required: table with no `<th>` and no semantic data.
- **`aria-label` on a `<button>` whose visible text is sufficient** (overrides visible label; sometimes incorrectly).
  Evidence required: button with visible text + redundant or contradicting `aria-label`.

### NOT a Problem

- Decorative SVGs with `aria-hidden="true"` (correctly silent).
- Single `<main>` per page (correct).
- Multiple `<main>` elements where all but one carry the `hidden` attribute (correct; the spec permits this, common in SPA/tab UIs where inactive views are hidden). Only the visible `<main>` is exposed as a landmark.
- Heading levels that match visual hierarchy AND semantic structure (correct).
- `aria-live="polite"` for non-urgent updates; `aria-live="assertive"` only for critical alerts.
- Image alt text that matches the image's role (decorative empty; informative descriptive; functional describes the action).

### Context Check

1. Has a screen reader user (or a developer using a screen reader) walked the site? The acid test.
2. Is the heading hierarchy used as the navigation map by screen reader users? Many screen reader users navigate by heading shortcut; broken hierarchy = broken navigation.
3. Are dynamic updates (notifications, validation errors, status changes) announced via live regions?
4. Are images differentiated by purpose (decorative / informative / functional) in their alt text?
5. Are tables semantic (data tables) or layout tables (avoid)?

### Reference

WebAIM screen reader survey: https://webaim.org/projects/screenreadersurvey10/

WAI-ARIA live regions: https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/ARIA_Live_Regions

WCAG 2.2 SC 1.1.1, 1.3.1, 2.4.6, 4.1.2, 4.1.3.

ARIA Authoring Practices on landmarks: https://www.w3.org/WAI/ARIA/apg/practices/landmark-regions/

VoiceOver shortcuts (Mac): Cmd+F5 to start; Ctrl+Opt+Right Arrow to navigate.

NVDA (Windows, free): https://www.nvaccess.org/

**Severity tagging:**
- No `<main>` landmark → High.
- More than one `<main>` lacking `hidden` → High.
- Heading hierarchy skipped → High.
- Visual list as `<div>`s → Medium.
- Form label not associated → Critical.
- Form error visual only → Critical.
- Toast without live region → High.
- Decorative image announced → Low.
- Informative image silent → Critical.
- Data table without `<th scope>` → High.

**Fix voice:** `aarron-walter` (primary) | `don-norman` (backup).

Read `souls/aarron-walter.json` before writing the Fix.

Worked fix example:

> A screen reader user moves through your page using the structure you provided, landmarks, headings, lists, tables. If the structure is missing or wrong, the user is wandering in fog. The fix isn't a layer of ARIA on top; it's getting the underlying structure right.
>
> Three priorities, in order.
>
> **1. Semantic structure first.** One `<main>` per page. `<nav>` for the primary navigation, `<header>` for the masthead, `<footer>` for the colophon, `<aside>` for sidebars. Headings used by meaning (the H1 is the page title; H2s are sections; H3s are subsections; never skip levels).
>
> **2. Form errors announced + associated.** Every error message is linked to its input via `aria-describedby`. The error region is a live region (`role="alert"` or `aria-live="polite"` per urgency). The input gets `aria-invalid="true"` when invalid.
>
> ```jsx
> <label htmlFor="email">Email</label>
> <input
>   id="email"
>   type="email"
>   aria-invalid={hasError}
>   aria-describedby={hasError ? "email-error" : undefined}
> />
> {hasError && (
>   <span id="email-error" role="alert">
>     Please enter a valid email address.
>   </span>
> )}
> ```
>
> **3. Dynamic UI announced via live regions.** Toasts, notifications, status changes, route announcements, all live regions. `role="status"` for non-critical (saved, copied), `role="alert"` for critical (error, warning).
>
> ```jsx
> <div role="status" aria-live="polite" aria-atomic="true">
>   {toastMessage}
> </div>
> ```
>
> Then test with a screen reader. Cmd+F5 on Mac (VoiceOver), free NVDA download on Windows. Walk the page. Where the announcements feel disorienting or silent, the structure tells you what to fix. The screen reader is a precise instrument; learning to use it as a developer surfaces accessibility issues automated tools never catch.
