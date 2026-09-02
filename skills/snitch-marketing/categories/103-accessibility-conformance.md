## CATEGORY 103: Accessibility conformance (WCAG 2.2 AA + legal exposure)

The single accessibility category. It judges the site against **WCAG 2.2 Level AA and the legal exposure that attaches to it** — the Americans with Disabilities Act (ADA), Section 508, and the European Accessibility Act (EAA, applicable since 2025-06-28). Touch targets, readable text, accessible names, contrast, color-only meaning, keyboard operability and screen-reader semantics are all criteria inside this one pass; they were separate categories until they were collapsed here, because every one of them was judged against the same standard. The criterion table below is the exact subset this pass covers; every A/AA criterion outside it is reported as a Skip, never as silence and never as a pass.

**Boundary.** This category asks "does the surface meet the criterion, and what is the exposure if it doesn't". When the question is instead whether a barrier **blocks a specific user from finishing a task**, or how a pattern reads for a **vulnerable user** on their decision path, that is the sibling's judge — call the Skill tool with "snitch-ux". The same broken element can be a finding in both skills; the criterion belongs here, the blocked task belongs there.

Cat 45 (viewport), Cat 25/26 (image alt as an SEO signal), Cat 52 (`lang`) and Cat 134 stay separate because they are judged against search and machine-readability, not against conformance. When their evidence also fails a criterion, cross-file it here with the criterion number.

### Pre-flight: relevance check

Always run when the brand is in healthcare, education, public sector, banking or large-enterprise B2B; sells into the EU under the EAA; has received an accessibility demand letter or audit request; or markets accessibility as a value. Otherwise still run the static pass on any public-facing surface — AA is best practice everywhere and the static checks are cheap.

Skip with reason `not applicable` only when there is no public-facing surface and no legal obligation.

### The pass sequence (cheapest signal first)

Each step catches what the previous cannot. Automated tooling catches only a fraction of the criteria, so the manual steps are not optional — they are either performed or Skipped with a reason.

1. **Automated scan** — axe-core / Pa11y / Lighthouse a11y over the rendered DOM: missing `alt`, unlabeled controls, missing `lang`, empty links and buttons, duplicate IDs, missing `<title>`.
2. **Keyboard pass** (Operable) — Tab through every interactive element: visible focus ring, logical order, no traps, skip link, custom widgets operable with Enter / Space / arrows, modal focus moved in and restored on close, route changes moving focus.
3. **Screen-reader semantics** (Perceivable + Robust) — landmarks, heading outline, list and table semantics, accessible names, ARIA used as structure rather than as a band-aid over non-semantic HTML, live-region announcements.
4. **Color** (Perceivable) — contrast ratios *and* whether meaning survives without color.
5. **Reflow, zoom and targets** (Perceivable + Operable) — 200% zoom and a ~320px viewport: no horizontal scroll, nothing clipped or overlapping, targets still 24×24.

Report the findings grouped under the four principles (Perceivable / Operable / Understandable / Robust) so a missing principle — zero Operable findings because the keyboard pass was skipped — is visible rather than implied.

### The criterion table

One row per criterion this category emits findings against. A finding names its row; a check with no row is not a WCAG finding.

**This table is a covered subset, not all of WCAG 2.2 AA.** It carries the criteria this pass can evidence from source, DOM or runner output. The remaining A/AA criteria — 1.2.1, 1.2.3, 1.2.4, 1.2.5, 1.3.2, 1.3.3, 1.3.4, 1.4.2, 2.1.4, 2.2.1, 2.2.2, 2.3.1, 2.4.4, 2.4.5, 2.5.1, 2.5.2, 2.5.3, 2.5.4, 3.1.2, 3.2.1, 3.2.2, 3.2.3, 3.2.4, 3.3.4 — are **not audited here**, and every audit's coverage block lists them as `Skip — outside this category's criterion table; needs a full manual audit`, so their absence reads as unchecked rather than clean. (3.1.1 Language of page is Cat 52's row; vague link and CTA text is judged in Cat 60 against conversion, not against 2.4.4 here.) A site can fail one of them and produce zero findings in this pass, which is why the Forbidden claims below rule out any conformance verdict.

| SC | Level | What must hold | Static signal (source / DOM) | Severity |
|---|---|---|---|---|
| 1.1.1 Non-text content | A | Every `<img>` / `<svg>` / `<canvas>` / `<video>` carries an accessible alternative, or is marked decorative | missing `alt` / `aria-label` / `aria-labelledby` / `<title>`; decorative image with a non-empty `alt` | Critical (informative image silent) / Low (decorative announced) |
| 1.2.2 Captions (prerecorded) | A | Prerecorded video with audio carries synchronized captions | `<video>` or embed with no `<track kind="captions">` and no caption track configured on the player | High |
| 1.3.1 Info and relationships | A | Structure is in the markup: landmarks, heading order, real lists, `<th scope>`, label association | `<div>` soup with no `<main>`; skipped heading levels; visual list built from `<div>`s; data table with no `<th scope>`; more than one `<main>` lacking `hidden` | High |
| 1.3.5 Identify input purpose | AA | Personal-data inputs carry the right `autocomplete` token | missing `autocomplete`, or `autocomplete="off"` on name / email / tel / address / card fields | Medium |
| 1.4.1 Use of color | A | No state, status, link, error or category is signalled by color alone | `.error` / `.required` / status-pill classes with a color change and no icon, text, asterisk, weight or pattern; `text-decoration: none` links distinguished only by hue; chart series differentiated only by color | Critical (form error / required marker) / High (links, status pills, charts) |
| 1.4.3 Contrast (minimum) | AA | Body text ≥ 4.5:1; large text (≥24px, or ≥18.66px bold) ≥ 3:1 | computed foreground / background pairs below threshold | High |
| 1.4.4 Resize text | AA | Text scales to 200% without loss of content or function | fixed-px containers that clip at 200%; `user-scalable=no` / `maximum-scale=1` in the viewport meta (Cat 45 cross-ref) | Medium |
| 1.4.5 Images of text | AA | Words are real text, not baked into an image | headline, pricing or CTA shipped as an `<img>` with the words only in `alt`; text-bearing hero or banner images | Medium |
| 1.4.10 Reflow | AA | No horizontal scroll at a ~320px viewport | fixed widths wider than the viewport on the conversion path | Medium |
| 1.4.11 Non-text contrast | AA | UI components and meaningful graphics ≥ 3:1 | button / input borders and icons below 3:1 against their background | High |
| 1.4.12 Text spacing | AA | Content survives user-applied line-height 1.5, paragraph spacing 2×, letter spacing 0.12em, word spacing 0.16em | fixed-height text containers, `overflow: hidden` on text blocks, `!important` line-height or letter-spacing | Medium |
| 1.4.13 Content on hover or focus | AA | Hover / focus content is dismissible, hoverable and persistent | tooltips and popovers bound to `:hover` alone, dismissed on pointer move, with no Escape handler (runtime confirmation needed) | Medium |
| 2.1.1 Keyboard | A | Every mouse action has a keyboard equivalent | `<div>` / `<span>` with `onClick` and no `role` + no key handler; hover-only menus with no `:focus-within`; drag-only reorder with no keyboard path | Critical |
| 2.1.2 No keyboard trap | A | Focus can enter and leave every region | modal / drawer / embedded player with a focus trap and no Escape handler | Critical |
| 2.4.1 Bypass blocks | A | A skip link or landmark structure lets a keyboard user reach content | no skip link and no `<main>` | Medium |
| 2.4.2 Page titled | A | Every page carries a unique `<title>` describing its topic | missing or empty `<title>`; one templated title repeated across routes (Cat 09 cross-ref) | High |
| 2.4.3 Focus order | A | Tab order follows the visual and semantic flow | `tabindex` greater than 0; focusable element ordered away from its visual position | High |
| 2.4.6 Headings and labels | AA | Headings and labels describe the topic or purpose | placeholder headings ("Section", "Untitled"), labels that do not say what to enter, one `<h1>` repeated verbatim across templates | Medium |
| 2.4.7 Focus visible | AA | The focused element is visibly identifiable | `outline: none` / `outline: 0` with no `:focus-visible` replacement | High |
| 2.4.11 Focus not obscured (minimum) | AA (new in 2.2) | The focused element is not fully hidden by sticky headers, cookie bars or chat widgets | sticky elements overlaying the focus path (runtime confirmation needed) | Medium |
| 2.5.7 Dragging movements | AA (new in 2.2) | Anything draggable has a single-pointer alternative | drag handlers with no click / keyboard equivalent | Medium |
| 2.5.8 Target size (minimum) | AA (new in 2.2) | Interactive targets are at least **24×24 CSS pixels**, or spaced so a 24px circle fits | icon buttons, close controls and packed footer link grids under 24×24; adjacent targets with no spacing buffer | High (primary CTA) / Medium (other) |
| 3.2.6 Consistent help | A (new in 2.2) | A help mechanism offered on multiple pages appears in the same relative order on each | contact, chat or help link present on some templates and moved or dropped on others (rendered order needs runtime confirmation) | Medium |
| 3.3.1 Error identification | A | Errors are described in text, not by color or position alone | submit-only errors with no `role="alert"` / `aria-live` and no `aria-describedby` link | High |
| 3.3.2 Labels or instructions | A | Every input has a programmatic label | `<input>` / `<select>` / `<textarea>` with no `<label for>`, wrapping label, `aria-label` or `aria-labelledby`; placeholder used as the label | Critical |
| 3.3.3 Error suggestion | AA | When an input error is detected and the correction is known, the correction is offered | validation copy that only says "Invalid" or "Error" with no expected format, no allowed range and no suggested value | Medium |
| 3.3.7 Redundant entry | A (new in 2.2) | Information already entered is auto-filled or selectable | multi-step flows re-asking for the same value (runtime confirmation needed) | Medium |
| 3.3.8 Accessible authentication (minimum) | AA (new in 2.2) | Auth does not require a cognitive function test with no alternative | CAPTCHA-only or puzzle-only auth step with no alternative path | Critical |
| 4.1.2 Name, role, value | A | Every control exposes an accessible name, its role and its state | icon-only `<button>` / `<a>` with no accessible name; image link with empty `alt`; custom widget with no `aria-expanded` / `aria-controls` / role | Critical (unlabeled input) / High (icon-only control) |
| 4.1.3 Status messages | AA | Dynamic status is announced without moving focus | toasts, validation summaries and "Saved!" states with no `aria-live` / `role="status"` / `role="alert"` | Medium |

**The 16px body-text floor is a readability heuristic, not a criterion.** Body text under 16px on mobile, `line-height` under 1.4 on paragraphs, and reading columns beyond ~80 characters are worth reporting as advisory findings, but they are **not** WCAG 1.4.4 and must never be written as a criterion failure. Report them as `readability (advisory)` with the CSS rule quoted; 1.4.4 is about *scaling to 200%*, which is the row above.

**One target floor.** 24×24 (2.5.8, AA, new in 2.2) is the only threshold that emits a conformance finding. 44×44 comes from **2.5.5 Target Size (Enhanced), a AAA criterion introduced in WCAG 2.1** — not new in 2.2 — and from platform design guidance; report it as advisory, never as an AA failure.

### Evidence required (do not skip)

**A finding needs two things: an observation and a criterion.** The observation is either (a) automated-runner output — the axe-core / Pa11y / Lighthouse rule id plus the offending node — or (b) a DOM / source read quoting the element at `file:line` (source mode) or URL + selector (crawl mode). The criterion is the SC number from the table above. Output with no criterion, or a criterion with no quoted element, is not a finding.

**Static checks (perform directly on source / CSS / fetched HTML):**

1. List the test scope: 5-10 representative pages covering homepage, content, conversion, post-conversion and error surfaces.
2. `Grep` images, SVGs and video for accessible alternatives (1.1.1); decorative images for non-empty `alt`.
3. `Grep` landmarks (`<main`, `<nav`, `<header`, `<footer`, `<aside`), heading levels, list elements, and table markup (1.3.1). Flag more than one `<main>` lacking `hidden`.
4. Read every form on the conversion path: label association, `type` / `inputmode` / `autocomplete`, error markup and its ARIA wiring (1.3.5, 3.3.1, 3.3.2).
5. `Grep` CSS color declarations, pair each text color with its background, and compute the ratio (1.4.3, 1.4.11).
6. `Grep` state classes, link styling and chart configuration for meaning carried by color alone (1.4.1).
7. `Grep` `outline:\s*(none|0)`, `tabindex="[1-9]`, `onClick` on non-semantic elements, `:hover`-only menus, and modal components for a focus trap plus an Escape handler (2.1.1, 2.1.2, 2.4.3, 2.4.7).
8. Approximate interactive-element dimensions from declared CSS width / height / padding (2.5.8), and body type metrics for the readability advisory.
9. `Grep` live regions (`aria-live=`, `role="status"`, `role="alert"`) against the components that render dynamic status (4.1.3).
10. Read the head of every page in the test scope for a unique, descriptive `<title>` (2.4.2); `Grep` `<video>` and player embeds for a caption track (1.2.2); `Grep` heroes, pricing blocks and CTAs for text carried in an image (1.4.5); `Grep` text containers for fixed heights, `overflow: hidden` or `!important` spacing (1.4.12); read heading and label text against the content it names (2.4.6); compare the help / contact / chat entry point across templates (3.2.6); and read validation copy for a suggested correction (3.3.3).

**Caveat that applies to every CSS-derived check:** `Fetch` and source reads return declarations, not the resolved cascade — the computed size, color or ratio can differ from the approximation. Say so in the finding when the cascade is ambiguous, and verify the rendered value before asserting a failure.

**Runtime checks (need an external runner or a human; the bundle ships neither):**

1. Run axe-core / Pa11y / Lighthouse a11y per representative page and quote each violation. Automated tools carry a meaningful false-positive rate — triage, don't paste.
2. Walk the keyboard journey: focus order, focus visibility, modal focus in and back out, Escape, route-change focus.
3. Walk the screen-reader journey (VoiceOver, NVDA, Orca): announcement order, silent or mis-announced elements, error and status announcements.
4. Confirm the runtime-only criteria: 2.4.11, 3.2.6 Consistent help, 3.3.7, and the live behavior of 4.1.3.
5. Check contrast and color-only meaning against a vision-deficiency simulation (deuteranopia / protanopia / tritanopia) and at 200% zoom / 320px reflow.

If a runner or human tester is available, run these and quote the result. If not, **Skip-with-reason** (`keyboard walk requires a human or runner — not run`) and report only the static findings. Never assert live behavior nobody observed.

### Contrast verification table (evidence format)

Quote contrast findings as a table so each ratio can be re-checked. Required ratios: normal text **4.5:1**, large text (≥24px, or ≥18.66px bold) **3:1**, non-text UI and meaningful graphics **3:1**.

| Element (URL + selector) | Foreground | Background | Ratio | Required | Pass |
|---|---|---|---|---|---|
| Hero subhead `/#hero p.sub` | `#9aa0a6` | `#ffffff` | 2.6:1 | 4.5:1 | fail |
| Primary button `/.btn-primary` | `#ffffff` | `#c9a84c` | 2.1:1 | 4.5:1 | fail |

Never assert a ratio without the two colors it was computed from.

### Legal exposure (how to write it, and what never to claim)

State the exposure, never a verdict. WCAG 2.2 AA is the threshold referenced by ADA settlements and Section 508 procurement in the US and by the EAA in the EU (applicable since 2025-06-28); Level A failures — 1.1.1, 1.3.1, 1.4.1, 2.1.1, 3.3.2, 4.1.2 — are the lowest bar and the ones that appear most often in demand letters. Two rules:

- **Never write "compliant", "conformant" or "non-compliant".** Conformance is a legal determination that follows a complete audit, not a partial static scan. Write "fails SC 1.4.3 at these elements" and let the reader draw the line.
- **Name the exposure factually**: the brand's sector, whether it sells into the EU, whether an accessibility statement and a feedback channel exist (both are EAA remediation signals), and which Level A criteria failed. That is the exposure paragraph; predictions of litigation outcomes are not.

### Forbidden claims

- "WCAG 2.2 AA is probably not met." Report the criteria you proved failed and Skip-with-reason the rest. No verdict without the pass.
- "Contrast may be insufficient." Compute and quote the ratio with both hex values.
- "Keyboard navigation may have gaps." Quote the static signal, or the walked gap, or Skip.
- "Screen-reader inaccessible", inferred from source when the check needed a render. Skip-with-reason instead.
- "Touch targets may be too small." Quote the element and its approximated dimensions, and say the resolved size may differ.
- Any criterion number attached to the 16px readability floor. It is not a criterion.

### Detection

Source or rendered-DOM audit of markup, CSS and component code across the representative page set, plus automated-runner output where a runner exists.

### What to Search For

- Images, SVGs, icons and video with no accessible alternative, and decorative images with non-empty `alt`
- Landmark inventory, heading sequence, visual lists built from `<div>`s, tables with no `<th scope>` or `<caption>`
- Forms: label association, `autocomplete` tokens, required / optional marking, error markup and its ARIA wiring
- `outline: none` / `outline: 0` without a `:focus-visible` replacement; `tabindex` greater than 0
- `<div>` / `<span>` with `onClick`; hover-only dropdowns; drag-only interactions
- Modal / drawer / popover components: focus trap library or hand-rolled equivalent, Escape handler, focus restore
- Route-change handlers with no focus move
- Text and UI color pairs; state classes and chart series that carry meaning in hue alone
- Icon-only buttons and image links with no accessible name; custom widgets missing their ARIA pattern
- Toast / validation / status components with no live region
- Interactive element dimensions and spacing; body font-size, line-height and column width (advisory)
- Accessibility statement page and a feedback channel for reporting barriers

### Actually Hurts the Marketing Surface

- **Form field with no programmatic label** (3.3.2 / 4.1.2). Evidence: the input element plus the failed label lookup.
- **Non-keyboard-operable control** — `<div onClick>`, hover-only menu, drag-only action (2.1.1). Evidence: the source location plus the handler.
- **Keyboard trap** — modal or embed that focus cannot leave, no Escape handler (2.1.2). Evidence: the component source, or the walked trap.
- **Focus indicator suppressed** (2.4.7). Evidence: the CSS rule and the absence of a replacement.
- **Modal opens without moving focus, or does not restore it on close** (2.4.3 / 2.1.1). Evidence: the component source, or the walked cycle.
- **Authentication requires a cognitive puzzle with no alternative** (3.3.8). Evidence: the auth step.
- **Informative image with no text alternative** (1.1.1). Evidence: the image and its purpose.
- **Body text below 4.5:1, or a UI component below 3:1** (1.4.3 / 1.4.11). Evidence: the verification-table row.
- **Meaning carried by color alone** — form error with no icon or text, required marker that is only a red label, status pills separated only by hue, chart series with no marker or direct label (1.4.1). Evidence: the element and the missing redundant channel.
- **Heading hierarchy skipped, no `<main>`, or more than one `<main>` lacking `hidden`** (1.3.1). Evidence: the heading sequence or landmark inventory.
- **Status message not announced** — toast or validation summary with no live region (4.1.3). Evidence: the component source.
- **Errors surfaced only on submit with no announcement** (3.3.1). Evidence: the error component and its missing ARIA wiring.
- **Interactive target under 24×24, or adjacent targets with no buffer** (2.5.8). Evidence: the element and its approximated size or spacing.
- **Personal-data field with no `autocomplete` token** (1.3.5). Evidence: the field markup.
- **No skip link and no landmark structure** (2.4.1). Evidence: page source.
- **Page with no `<title>`, or one templated title across every route** (2.4.2). Evidence: the head markup per URL.
- **Prerecorded video with no caption track** (1.2.2). Evidence: the `<video>` or embed markup and the absent track.
- **Headline, price or CTA rendered as an image of text** (1.4.5). Evidence: the `<img>` and its `alt`.
- **Text container that clips under user text spacing, or a tooltip that cannot be dismissed or hovered** (1.4.12 / 1.4.13). Evidence: the CSS rule or the component source.
- **Heading or label that does not describe its topic** (2.4.6). Evidence: the heading or label text and what the section actually contains.
- **Help mechanism in a different place on different templates** (3.2.6). Evidence: the two templates and the two positions.
- **Error message with no suggested correction when the expected format is known** (3.3.3). Evidence: the validation copy and the field's real constraint.
- **Body text under 16px on mobile, line-height under 1.4, or a reading column beyond ~80 characters** — readability advisory, not a criterion. Evidence: the CSS rule.

### NOT a Problem

- Decorative images with `alt=""` and `aria-hidden="true"`; decorative SVGs marked `aria-hidden`.
- `<button>` without a redundant explicit `role`; a semantic `<main>` / `<nav>` without a redundant landmark role.
- Multiple `<main>` elements where all but one carry `hidden` — the spec permits it, and only the visible one is exposed.
- `outline: none` paired with a visible `:focus-visible` replacement.
- `tabindex="-1"` on programmatically focused containers (modals, error summaries).
- A non-semantic element with `role="button"`, `tabindex="0"` and Enter / Space handling — verbose, but equivalent.
- A hover menu that also opens on focus or click.
- Color used **alongside** a redundant channel (a check icon next to "Approved"), and underlined links with a color shift.
- Inline links inside body text at their natural size; decorative non-interactive icons under 24×24.
- Caption, footnote and single-purpose UI labels at 12-14px; headings at any size.
- Intentionally low-contrast disabled states and decorative wordmarks or watermarks.

### Context Check

1. What is the legal exposure? Sector, EU market presence, prior demand letter, published accessibility commitment.
2. Is there an accessibility statement, and a channel for users to report barriers? Both are EAA remediation signals.
3. Does the site carry user-generated content? Then conformance extends to what users publish (headings, alt text).
4. Are automated results triaged into must-fix versus false positive, or pasted whole?
5. Which criteria could not be checked, and why? A Skip with a reason is a finding about coverage.
6. Do the form criteria here (label association, error announcement) also appear in the Cat 60 conversion report? Cross-file rather than double-count.
7. Does the fix touch a color value? Contrast fixes rewrite brand tokens — surface the before / after / ratio and get explicit approval per finding (see SKILL.md Post-Scan flow and `references/remediation-generator.md`).
8. Is the failure blocking a specific user from finishing a task, or does the pattern need a vulnerable-user reading? Hand that half over — call the Skill tool with "snitch-ux".

### Reference

WCAG 2.2 specification: https://www.w3.org/TR/WCAG22/

Understanding 2.5.8 Target Size (Minimum), AA, new in 2.2: https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html · 2.5.5 Target Size (Enhanced), AAA, from WCAG 2.1: https://www.w3.org/WAI/WCAG22/Understanding/target-size-enhanced.html

WCAG 1.4.1 Use of Color: https://www.w3.org/WAI/WCAG21/Understanding/use-of-color.html · 1.4.3 Contrast (Minimum): https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html · 4.1.2 Name, Role, Value: https://www.w3.org/WAI/WCAG21/Understanding/name-role-value.html

W3C ARIA Authoring Practices (canonical keyboard-widget and landmark patterns): https://www.w3.org/WAI/ARIA/apg/

axe-core rule descriptions: https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md · WebAIM contrast checker: https://webaim.org/resources/contrastchecker/ · NVDA: https://www.nvaccess.org/

European Accessibility Act: https://ec.europa.eu/social/main.jsp?catId=1202 · Section 508: https://www.section508.gov/

Color-vision simulation: Chrome DevTools Rendering panel ("Emulate vision deficiencies"), or Color Oracle: https://colororacle.org/

**Severity tagging:**
- Form field with no label / non-keyboard-operable control / keyboard trap / CAPTCHA-only auth / informative image silent / color-only form error or required marker → Critical.
- Focus indicator suppressed / focus order broken / modal focus not managed / body text below 4.5:1 / UI component below 3:1 / missing landmark or skipped headings / color-only links, status pills or chart series / primary CTA under 24×24 / missing or duplicated page title (2.4.2) / prerecorded video with no captions (1.2.2) → High.
- Submit-only errors with no announcement, status message not announced, target under 24×24 on a secondary control, missing `autocomplete`, no skip link, reflow or resize failures, text baked into an image (1.4.5), text-spacing or hover-content failures (1.4.12 / 1.4.13), non-descriptive headings or labels (2.4.6), help mechanism that moves between templates (3.2.6), error copy with no suggested correction (3.3.3), 2.4.11 / 2.5.7 / 3.3.7 failures → Medium.
- Decorative image announced, target between 24×24 and 44×44 (advisory under 2.5.5 AAA), readability advisories (16px floor, line-height, column width) → Low.

**Fix voice:** `emotional-design-lead` (primary) | `usability-scientist` (backup) | `typography-master` for the readability advisories | `less-but-better-designer` for contrast work.

Read `souls/emotional-design-lead.json` before writing the Fix. Accessibility is design, not a compliance layer bolted onto a finished product — and the same discipline that makes the product usable for one blocked user makes it better for everyone.

Worked fix example:

> Four fixes, in the order the criteria fail hardest.
>
> **1. Give every control a name and a keyboard path** (4.1.2, 2.1.1).
>
> ```tsx
> // Fails 4.1.2: the screen reader announces "button"
> <div onClick={close}><CloseIcon /></div>
>
> // Passes: real button, accessible name, icon hidden from the a11y tree
> <button onClick={close} aria-label="Close dialog">
>   <CloseIcon aria-hidden="true" />
> </button>
> ```
>
> **2. Keep focus visible and managed** (2.4.7, 2.4.3). Never suppress the indicator without a replacement; move focus into a modal on open, hold it there, return it to the trigger on close, and move it to `<main>` on route change.
>
> ```css
> *:focus-visible { outline: 2px solid var(--focus-color); outline-offset: 2px; }
> ```
>
> **3. Fix the ratio, then add the second channel** (1.4.3, then 1.4.1). Contrast is "can it be read"; color-only meaning is "does the meaning survive without the hue". They fail independently.
>
> ```css
> /* 1.4.3: 2.85:1 fails AA for body text */
> .body-text { color: #999; background: #fff; }
> /* 1.4.3: 4.6:1 passes */
> .body-text { color: #767676; background: #fff; }
>
> /* 1.4.1: keep the brand color, add the redundant channel */
> .pill-failed::before { content: "✕ "; }
> ```
>
> The palette stays the brand's; what changes is that hue is no longer carrying the whole message. Never propose a palette rewrite as the fix for 1.4.1.
>
> **4. Size the target and announce the state** (2.5.8, 4.1.3). A 24px icon can carry a 44×44 hit area through padding — the user sees the icon and hits the padding.
>
> ```css
> button, .button { min-height: 44px; min-width: 44px; padding: 12px 16px; }
> .button-group { gap: 12px; }
> ```
>
> ```jsx
> <div role="status" aria-live="polite" aria-atomic="true">{toastMessage}</div>
> ```
>
> Then publish an accessibility statement: what was audited, what was fixed, what is known and not yet fixed, and how to report a barrier. It is not legal cover; it is the brand saying accessibility is part of the product.
