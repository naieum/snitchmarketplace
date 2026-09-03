## CATEGORY 11: Accessible name, role, state and status messages (ARIA)

Two criteria, and between them they cover everything a screen reader is told about a control. 4.1.2 asks whether each component exposes a **name**, a **role**, and any **state or value** the user can change. 4.1.3 asks whether a message that appears without moving focus — "Saved", "3 items in cart", "Enter a valid card number" — is announced at all.

This is where hand-built widgets fail. A `<div>` with a click handler is announced as nothing. An icon button with no text is announced as "button". A tab list built from spans has no tabs in it. A toast that fades after four seconds and carries no live region simply never happened, for anyone not watching that corner of the screen.

**Boundary.** This category asks whether the component exposes its name, role and state, and whether status is announced. Whether the widget is operable by keyboard at all is Category 06's criterion set (2.1.1, 2.1.2, 2.4.3, 2.4.7). Whether the visible label is contained in the accessible name is 2.5.3, in Category 07. Whether the missing announcement leaves a user stuck mid-task is the sibling's judge — call the Skill tool with "snitch-ux".

**Overlap with Category 10.** An unlabeled `<input>` fails both 3.3.2 and 4.1.2. Report it **once**, in Category 10, under 3.3.2, citing 4.1.2 in the same finding. This category owns everything that is not a natively labelable form control: icon-only buttons and links, custom widgets, ARIA wiring, and live regions.

**4.1.1 Parsing is removed.** WCAG 2.2 removed 4.1.1 Parsing as obsolete. Duplicate IDs, unclosed tags and stray attributes are no longer a criterion failure on their own. Report a duplicate ID **only** when it breaks a name or label reference — two elements sharing an `id` that an `aria-labelledby` or a `<label for>` points at — and report it under 4.1.2, because the failure is the broken name, not the markup. `wcag-criterion-map.md` lists 4.1.1 as removed in 2.2 and not audited.

### Pre-flight

Run on any surface with interactive components, which is nearly all of them. The static half needs only source or fetched HTML.

Skip with reason `not applicable` only when the surface has no interactive component and no dynamic content.

Before scanning, inventory the component library in use. A design system that already ships correct ARIA turns most of this category into Passes with evidence, and the findings collapse to the hand-rolled exceptions.

### Rule table

One row per success criterion. A finding names its row. An ARIA check with no row here is a Skip, never a finding under a borrowed SC.

| SC | Level | What must hold | Static signal (source / DOM) | Runtime-only? | Severity |
|---|---|---|---|---|---|
| 4.1.2 Name, Role, Value | A | For every user interface component, the name and role can be programmatically determined; states, properties and values the user can set can be programmatically set; and changes to these are notified to user agents | icon-only `<button>` / `<a>` with no text, no `aria-label`, no `aria-labelledby` and no `<title>` in the SVG; image link whose only content is an `<img>` with `alt=""`; custom tabs, accordions, menus, comboboxes, switches or dialogs missing `role`, `aria-expanded`, `aria-selected`, `aria-checked`, `aria-controls` or `aria-modal`; `role="button"` on a `<div>` with **neither** `tabindex` **nor** a key handler, so the role announces an interaction the element has no way to perform; invalid or abstract roles; `aria-hidden="true"` on an element that is focusable or contains a focusable descendant; `aria-labelledby` or `aria-describedby` pointing at an ID that does not exist; duplicate IDs that break a name reference; `aria-describedby` carrying what should be the name | Partly — announcement order needs a screen reader | Critical (control exposes no name at all) / High (role or state missing on an operable widget) |
| 4.1.3 Status Messages | AA | Status messages can be programmatically determined through role or properties, so assistive technology presents them without focus moving | toast, snackbar, validation summary, cart counter, search-results count, "Saved" or "Copied" indicator, or a loading state that renders with no `aria-live`, no `role="status"` and no `role="alert"`; a live-region container inserted into the DOM at the same moment as its message; `aria-live="assertive"` applied to routine, non-urgent updates | Partly — whether it announces needs a screen reader | Medium |

**A status message, as the specification defines it.** A change in content that is not a change of context, telling the user about the success or result of an action, a waiting state, the progress of a process, or the existence of errors. A message that moves focus is not a status message; it is a change of context and belongs to 3.2.1 or 3.2.2.

**The live-region timing rule.** A live region must exist in the DOM, empty, **before** the message goes into it. A container mounted with its text already inside is usually never announced, because the assistive technology had nothing to observe changing. This is the single most common way a correctly-attributed `role="status"` still fails in practice, and it is visible in source: look for the region and the message rendering under the same condition.

**Assertive is for interruptions only.** `aria-live="assertive"` and `role="alert"` cut across whatever the user is currently hearing. Use them for errors and for anything that stops the task. Everything else takes `aria-live="polite"` or `role="status"`. A page that marks every update assertive is a page that shouts, and it is worth a finding under 4.1.3 in its own right.

### Evidence required

A finding needs an observation and a criterion. The observation is a quoted element at `file:line` (source mode) or URL plus selector with the rendered HTML (crawl mode), or a runner rule id with its node.

**Source mode, cheapest first:**

1. `Grep` for `<button` and `<a` and read each for text content, `aria-label`, `aria-labelledby`, or an SVG child carrying a `<title>`. Record the name lookup, not just its absence (4.1.2).
2. `Grep` for links whose only child is an `<img>`, and check the `alt` value. An image link with `alt=""` and nothing else has no name (4.1.2).
3. `Grep` for `role="` and check every value against the ARIA role list. Flag misspellings, abstract roles (`widget`, `input`, `structure`, `roletype`, `section`, `sectionhead`, `landmark` used as a role) and roles applied to elements that cannot carry them (4.1.2).
4. `Grep` for hand-rolled widget names: `Tabs`, `Accordion`, `Dropdown`, `Menu`, `Combobox`, `Autocomplete`, `Switch`, `Toggle`, `Modal`, `Dialog`, `Popover`, `Tooltip`, `Disclosure`. `Read` each and check for the pattern's required role plus its required state attribute (4.1.2).
5. `Grep` for `aria-expanded`, `aria-selected`, `aria-checked`, `aria-pressed`, `aria-current` and confirm each is bound to a value that changes with the state, not hardcoded (4.1.2).
6. `Grep` for `aria-labelledby=` and `aria-describedby=` and resolve every referenced ID to exactly one element in the same document. Zero matches breaks the name; two matches makes it ambiguous (4.1.2).
7. `Grep` for `aria-hidden="true"` and check each subtree for focusable descendants: links, buttons, inputs, `tabindex="0"` (4.1.2).
8. `Grep` for `role="button"`, `role="link"`, `role="checkbox"` on non-semantic elements and record both halves of the keyboard contract: `tabindex="0"` and an Enter or Space handler. **The 4.1.2 finding here is the role with neither half** — the element is not reachable and not operable, so the role announces an interaction that cannot happen. An element carrying the role, `tabindex="0"` and a name, missing only the key handler, is Category 06's 2.1.1 and is cross-referenced, not filed here (4.1.2).
9. `Grep` for status surfaces: `toast`, `snackbar`, `notification`, `Alert`, `flash`, `banner`, `cartCount`, `resultsCount`, `Saved`, `Copied`, `Loading`, `Spinner`. `Read` each for `aria-live`, `role="status"` or `role="alert"`, and record whether the region renders unconditionally or only alongside its message (4.1.3).
10. `Grep` for `aria-live="assertive"` and `role="alert"` and record what each announces. Routine updates marked assertive are a finding (4.1.3).

**Crawl mode:**

1. `Fetch` each page in the test scope. Quote the control's rendered HTML with its selector and the name lookup performed against the served DOM.
2. Resolve `aria-labelledby` and `aria-describedby` references against the served document and report unresolved ones.
3. Live regions injected after hydration will not appear in a plain fetch. Say so, and Skip that half with `client-rendered live region not verifiable without a JS-rendering fetch`.

**Runtime checks (need a human or a screen reader; the bundle ships neither):**

1. Walk the page with a screen reader (VoiceOver, NVDA, Orca) and record the announcement for every control: name, role, state, in that order.
2. Trigger each status message and record whether it is announced, once, without focus moving.
3. Open and close every custom widget and confirm the state attribute changes with the visual state.
4. Confirm that nothing important is inside an `aria-hidden` subtree.

If none is available: `Skip — screen-reader walk requires a human or runner; not run`, `Skip — live-region announcement requires a human or runner; not run`, and report only the static findings. Never assert what a screen reader said when no screen reader ran.

### Forbidden claims

- "The site is not screen-reader accessible." Nothing static establishes that. Name the control, name the missing name or role, or Skip.
- "This widget probably is not announced correctly." Quote the markup and the absent attribute, or Skip with the screen-reader walk named as the unblock.
- "ARIA is used incorrectly." Quote the attribute, the element it sits on, and the rule it breaks.
- "Duplicate IDs fail WCAG." They no longer do on their own. 4.1.1 Parsing is removed in WCAG 2.2. Report a duplicate ID only where it breaks a name reference, and report it under 4.1.2.
- "The toast is not accessible." Quote the component and the missing `aria-live` / `role="status"` / `role="alert"`.
- "Adding `role="button"` fixes it." A role is a promise about behaviour. Say what else the element needs to keep that promise.
- Never write "compliant", "conformant" or "non-compliant" as a verdict. Write "fails SC 4.1.2 at these controls" and let the reader draw the line.

### Detection

Source or rendered-DOM audit of every interactive component's accessible name, role and state wiring, every ARIA reference, and every dynamic status surface, across the representative page set, plus screen-reader or runner output where one exists.

### What to Search For

- `<button>` and `<a>` with no text content and no naming attribute
- Links whose only content is an image, and the image's `alt`
- SVG icons used as the whole content of a control, and whether they carry `<title>` or `aria-hidden`
- Every `role=` value, checked against the ARIA role list; abstract and misspelled roles
- Hand-rolled tabs, accordions, menus, comboboxes, switches, dialogs, disclosures, tooltips, and their required state attributes
- `aria-expanded` / `aria-selected` / `aria-checked` / `aria-pressed` hardcoded rather than bound to state
- `aria-labelledby` and `aria-describedby` targets, resolved against the document
- Duplicate `id` values, and whether any of them is a name-reference target
- `aria-hidden="true"` wrapping focusable content
- `role="button"` on `<div>` / `<span>` with no `tabindex` and no key handler
- Toasts, snackbars, validation summaries, cart and result counters, "Saved" / "Copied" states, loading indicators, and their live-region attributes
- Live-region containers that mount together with their message
- `aria-live="assertive"` and `role="alert"` on routine updates

### Actually Fails

- **Control with no accessible name at all** (4.1.2). Evidence: the element, its empty text content, and the failed lookup for `aria-label`, `aria-labelledby` and an SVG `<title>`. An icon-only close button is the canonical case.
- **Image link with an empty `alt` and no other name** (4.1.2). Evidence: the anchor and its only child.
- **Custom widget missing its role or its state attribute** (4.1.2). Evidence: the component source and the pattern's required attributes, named. An accordion trigger with no `aria-expanded` never tells anyone whether the panel is open.
- **Role whose required interaction the element has no way to perform** (4.1.2). Evidence: the element, the role, and **both** absences — no `tabindex` and no key handler. A role plus `tabindex="0"` plus a name, missing only the key handler, is not this finding: that is 2.1.1 in Category 06, cross-referenced from here.
- **Invalid, misspelled or abstract role** (4.1.2). Evidence: the attribute value and the role list it fails against.
- **`aria-labelledby` or `aria-describedby` pointing at a missing ID** (4.1.2). Evidence: the attribute and the resolution attempt returning nothing.
- **Duplicate ID that breaks a name reference** (4.1.2, not 4.1.1). Evidence: both elements sharing the ID and the attribute that points at it.
- **`aria-hidden="true"` on focusable content** (4.1.2). Evidence: the hidden subtree and the focusable descendant inside it. The control stays in the tab order and announces nothing.
- **`aria-describedby` carrying what should be the name** (4.1.2). Evidence: the control with a description and no name. Descriptions are supplementary and may not be announced at all.
- **Status message with no live region** (4.1.3). Evidence: the component that renders the message and the absence of `aria-live`, `role="status"` and `role="alert"`.
- **Live region created at the same moment as its message** (4.1.3). Evidence: the render condition showing the container and the text appearing together.
- **Routine updates marked assertive** (4.1.3). Evidence: the attribute and what it announces.

### NOT a Failure

- A native `<button>` with no `role="button"`. The first rule of ARIA is to use the native element; a redundant role adds nothing and its absence is correct, not a defect. The same holds for `<nav>` without `role="navigation"`, `<main>` without `role="main"`, and `<a href>` without `role="link"`.
- A native `<input type="checkbox">` with no `aria-checked`. The browser exposes the state.
- An icon inside a control that also has visible text, with the icon marked `aria-hidden="true"`. That is the correct pattern.
- A decorative SVG marked `aria-hidden="true"` with no `<title>`.
- An `aria-label` that extends the visible text rather than replacing it. Note that containment of the visible words is 2.5.3, in a different category.
- `tabindex="-1"` on a container that receives focus programmatically: a modal, an error summary, a route-change target.
- A verbose but complete non-semantic control: `role="button"` plus `tabindex="0"` plus Enter and Space handling. Equivalent, and not a finding.
- A `role="button"` element that is focusable (`tabindex="0"`) and named but has no Enter or Space handler. The name and the role are exposed, so 4.1.2 holds; the missing key handler is 2.1.1 and belongs to Category 06.
- A duplicate ID that no `aria-labelledby`, `aria-describedby`, `aria-controls` or `<label for>` points at. 4.1.1 is removed; the markup defect alone is not a criterion failure.
- A live region that exists empty on mount and receives its text later. That is the working pattern.
- `role="alert"` on a genuine error that must interrupt.
- A component library's widget that already ships the full ARIA pattern. Quote it as a Pass with evidence.

### Context Check

1. Does a design-system component supply the ARIA, with this call site simply not passing the prop? Read the component before flagging the call site.
2. Is the icon's name supplied by an SVG `<title>` or a `<use>` reference the grep missed? Resolve it.
3. Is the role redundant-but-harmless, or is it overriding a native role with a different contract? Only the second is a finding.
4. Which half of the keyboard contract is missing? Neither `tabindex` nor a key handler is this category's 4.1.2 finding: the role names an interaction the element cannot perform at all. A missing key handler alone, on an element that is focusable and named, is Category 06's 2.1.1 — cross-reference it there rather than filing it here.
5. Does the live region already exist in a layout above the component that renders the message? Trace upward before reporting its absence.
6. Is the message a status, or a change of context? A message that moves focus is not 4.1.3.
7. Was the announcement observed, or inferred from markup? Say which, every time, and mark Confidence accordingly.
8. Is the same element also failing a form criterion? Report the label failure once, in Category 10, citing 4.1.2 there.
9. Is the question whether the missing announcement leaves a user stuck mid-task? Hand that half over — call the Skill tool with "snitch-ux".

### Severity

- **Critical** — a control that exposes no accessible name at all: an icon-only button or link, an image link with empty `alt` and nothing else, a focusable element inside an `aria-hidden` subtree (4.1.2).
- **High** — a custom widget missing its role or its state attribute; a role on an element with neither `tabindex` nor a key handler; an invalid or abstract role; an `aria-labelledby` reference that resolves to nothing, including one broken by a duplicate ID (4.1.2).
- **Medium** — a status message with no live region; a live region mounted together with its message; routine updates marked assertive (4.1.3); `aria-describedby` standing in for a missing name where a visible label is still present nearby.
- **Low** — redundant ARIA that adds noise without changing the exposed name, role or state.

### Fix guidance

Four fixes, and the first one is usually "delete the ARIA and use the element".

**1. Prefer the native element** (4.1.2). Native controls arrive with a role, a keyboard contract and a focus behaviour already correct. Every ARIA attribute you add is a promise you now have to keep by hand.

```tsx
// Fails 4.1.2: announced as nothing, not in the tab order, no keyboard path
<div className="btn" onClick={submit}><SendIcon /></div>

// Passes: real button, real name, icon out of the accessibility tree
<button type="submit" onClick={submit} aria-label="Send message">
  <SendIcon aria-hidden="true" />
</button>
```

**2. Name every control that has no words** (4.1.2). Icon-only controls need a name from somewhere: an `aria-label`, a visually hidden span, or a `<title>` inside the SVG.

```tsx
// Fails 4.1.2: "link" is all the screen reader has
<a href="/cart"><CartIcon /></a>

// Passes, and the count comes along
<a href="/cart" aria-label={`Cart, ${count} items`}>
  <CartIcon aria-hidden="true" />
</a>
```

**3. Give the widget its role and its state** (4.1.2). A disclosure needs `aria-expanded` bound to the same state the CSS reads. Hardcoding it is worse than omitting it, because it lies.

```tsx
// Fails 4.1.2: the state never reaches the accessibility tree
<button onClick={toggle}>Shipping details</button>
<div className={open ? "panel open" : "panel"}>…</div>

// Passes: role by element, state by attribute, relationship by id
<button onClick={toggle} aria-expanded={open} aria-controls="shipping-panel">
  Shipping details
</button>
<div id="shipping-panel" hidden={!open}>…</div>
```

The same shape carries the rest: `aria-selected` on a tab, `aria-checked` on a switch, `aria-modal="true"` plus a labelled `role="dialog"` on a modal.

**4. Announce status without stealing focus** (4.1.3). The region exists first, empty. The message goes into it afterwards.

```tsx
// Fails 4.1.3: the container and the text mount together, so nothing changed to observe
{toast && <div className="toast">{toast}</div>}

// Passes: the region is always present; only its contents change
<div role="status" aria-live="polite" aria-atomic="true" className="toast-region">
  {toast}
</div>
```

Reserve `role="alert"` and `aria-live="assertive"` for messages that must interrupt: a validation failure, a session about to end, a payment declined. Everything else is polite. A page where every update is urgent is a page where none of them is.

### Reference

WCAG 2.2 specification: https://www.w3.org/TR/WCAG22/

4.1.2 Name, Role, Value: https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html · 4.1.3 Status Messages: https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html

Status message, defined: https://www.w3.org/TR/WCAG22/#dfn-status-messages · 4.1.1 Parsing, obsolete and removed in WCAG 2.2: https://www.w3.org/TR/WCAG22/#parsing

W3C ARIA Authoring Practices, the canonical widget patterns and their required attributes: https://www.w3.org/WAI/ARIA/apg/patterns/

Accessible Rich Internet Applications (WAI-ARIA), the normative role and state list: https://www.w3.org/TR/wai-aria-1.2/ · Using ARIA, including the rules of ARIA use: https://www.w3.org/TR/using-aria/

Accessible name computation: https://www.w3.org/TR/accname-1.2/ · ARIA live regions: https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/ARIA_Live_Regions

axe-core rule descriptions, for the runner rule ids quoted alongside an element: https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md · NVDA: https://www.nvaccess.org/
