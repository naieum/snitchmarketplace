## CATEGORY 06: Keyboard operability and focus management

The keyboard is the common denominator. A screen-reader user drives it, a switch user drives it
through an adapter, someone with a tremor or a repetitive strain injury drives it instead of a
mouse, and a power user drives it because it is faster. If a control cannot be reached, operated,
seen or left with a keyboard, it does not exist for a large group of people. This category judges
that against **2.1.1 Keyboard (A)**, **2.1.2 No Keyboard Trap (A)**, **2.1.4 Character Key Shortcuts
(A)**, **2.4.3 Focus Order (A)**, **2.4.7 Focus Visible (AA)** and **2.4.11 Focus Not Obscured
(Minimum) (AA, new in 2.2)**.

Two of these rows are the most common Level A failures in modern component code, and both come from
one habit: building a control out of a `<div>`, adding a click handler, and stopping. The element
gets no role, no tab stop, no key handling and no focus ring, and each is a separate criterion.

**Boundary.** This category asks whether the criterion holds. When the question is whether the
keyboard trap **stops one person finishing checkout**, or how the broken focus order reads on a
decision path, that is the sibling's judge; call the Skill tool with "snitch-ux". Dragging movements
(2.5.7) and target size (2.5.8) are Cat 07's rows: a drag-only interaction with no keyboard path is
a 2.1.1 finding here and a 2.5.7 finding there, cross-filed, not doubled.

### Pre-flight

Always run. Keyboard operability is Level A, the static signals are cheap, and these patterns are
the ones most often cited.

1. **The interactive inventory.** Every control on the representative pages: native elements,
   custom widgets, menus, modals, drawers, carousels, tabs, comboboxes, drag surfaces.
2. **Whether a human or runner is available** to walk the keyboard journey. Say which rows Skip
   without one.
3. **Declared intent.** Read `BLUEPRINT.md` and `marketing/positioning.md` read-only. A `Decision`
   does not excuse a Level A failure; it caps a contradicting best-practice fix at Medium. Neither
   file present is a Skip with that reason.

Skip with reason `no interactive content in scope` only when the inventory is genuinely zero.

### Rule table

One row per success criterion. A finding names its row. A check with no row here is a Skip.

| SC | Level | What must hold | Static signal (source / DOM) | Runtime-only? | Severity |
|---|---|---|---|---|---|
| 2.1.1 Keyboard | A | All functionality is operable through a keyboard interface without requiring specific timings for individual keystrokes | `<div>` or `<span>` with `onClick` / `@click` and no `role`, no `tabindex="0"` and no key handler; menus revealed only by `:hover` with no `:focus-within` or click path; drag-only reorder, slider or canvas interaction with no keyboard equivalent; `mousedown`-only handlers | partial | Critical |
| 2.1.2 No Keyboard Trap | A | Focus can move into and out of every component using the keyboard alone | modal, drawer, lightbox or embedded player that moves focus in and offers no Escape and no path back; a focus-trap implementation with no release; an embedded frame that captures arrow and Tab keys | partial | Critical |
| 2.1.4 Character Key Shortcuts | A | A shortcut using only letter, punctuation, number or symbol characters can be turned off, remapped, or is active only on focus | a global `keydown` listener matching single characters with no modifier check, no setting to disable or remap, and no scoping to a focused component | no | High |
| 2.4.3 Focus Order | A | Focusable components receive focus in an order that preserves meaning and operability | `tabindex` greater than 0; a focusable element placed away from its visual position by CSS; a modal appended to the end of the body with no focus move; a route change that leaves focus on the old page | partial | High |
| 2.4.7 Focus Visible | AA | The keyboard focus indicator is visible | `outline: none`, `outline: 0` or `outline-style: none` on a focusable selector with no `:focus-visible` (or `:focus`) replacement anywhere in the cascade | no | High |
| 2.4.11 Focus Not Obscured (Minimum) | AA (new in 2.2) | The focused component is not **entirely** hidden by author-created content | `position: fixed` or `sticky` headers, footers, cookie bars, chat launchers and promotional strips overlaying the scroll path; no `scroll-margin` on focus targets | yes | Medium |

**2.4.11 asks about "entirely hidden".** A component partly covered by a sticky header passes the
minimum row; only one completely hidden by author content fails it. Never report a partial overlap
as a 2.4.11 failure; that stricter threshold belongs to a criterion outside AA.

**Focus indicator contrast is a different row.** A visible indicator below 3:1 against its
neighbours is 1.4.11, Cat 04; a suppressed indicator with no replacement is 2.4.7, here. And
**`tabindex="-1"` is not a failure by itself**: it is the correct way to make a container
programmatically focusable, and it fails only on something a person must *reach* by tabbing.

### Evidence required

A finding needs an observation and a criterion. The observation is the quoted element or rule at
`file:line` (source mode) or URL + selector (crawl mode), or a walked step a human or runner
recorded.

**Source mode, cheapest first:**

1. `Grep` for `onClick`, `onclick`, `@click`, `v-on:click`, `(click)` on `div`, `span`, `li`, `td`
   and `img`, and check each for `role`, `tabindex="0"` and a `keydown` or `keyup` handler.
2. `Grep` for `outline:\s*none`, `outline:\s*0`, `outline-style:\s*none`, and for each search the
   whole CSS for a `:focus-visible` or `:focus` replacement. The finding needs **both** the
   suppressing rule quoted and the absence of a replacement stated.
3. `Grep` for `tabindex="[1-9]` and `tabIndex={[1-9]`: any positive value is the 2.4.3 signal. Then
   `Grep` `tabindex="-1"` and read its target: a container is correct, a button a person must reach
   is a finding.
4. `Grep` for `:hover` rules that reveal a menu, and check whether a `:focus-within`, `:focus` or
   click handler does the same. `Grep` for `draggable`, `dragstart`, `pointerdown`, `mousedown` and
   `touchstart` on interactive surfaces, and check for a keyboard path beside each.
5. Read every modal, drawer, dialog, popover and lightbox for four things: focus moved in on open,
   held while open, Escape closes, focus restored on close. Name which is missing.
6. `Grep` for `addEventListener('keydown'` and `onKeyDown` at document or window scope, reading
   whether the handler matches a bare character with no `ctrlKey` / `metaKey` / `altKey` check, and
   whether a setting exists to disable or remap it (2.1.4).
7. `Grep` router hooks for a focus move to the new page's heading (2.4.3), plus `autofocus` and
   load-time `.focus()` calls, and `position:\s*(fixed|sticky)` on headers, cookie bars and chat
   launchers, noting those as 2.4.11 candidates for the runtime walk.

**Crawl mode:** `Fetch` each page, quote the interactive elements and their attributes from the
rendered HTML, quote the served CSS for focus suppression and sticky overlays, and record URL and
selector per finding.

**Cascade caveat (every CSS-derived check):** a `Grep` or `Fetch` returns declarations, not the
resolved cascade. An `outline: none` may be overridden by a later `:focus-visible` rule in another
file, and a sticky header may be sticky only above a breakpoint. Say so when the cascade is
ambiguous, and confirm the rendered behavior first.

**Runtime checks (need a human or runner; the bundle ships neither):**

1. **Walk the keyboard journey.** Tab through every interactive element on each page, recording
   whether the focus ring is visible at each stop, whether the order follows the visual flow, and
   whether anything is skipped or trapped.
2. **Operate every custom widget** with Enter, Space and the arrow keys its pattern expects, then
   **open and close every modal**: focus in, held, Escape, restored to the trigger. Change routes
   and confirm where focus lands, and scroll a focused element under each sticky region, where it
   must not be entirely hidden (2.4.11).

With no runner or human, write `Skip — keyboard walk requires a human or runner; not run` and
report only the static findings. Never assert walked behavior nobody observed.

### Forbidden claims

- "Keyboard navigation may have gaps." Quote the static signal, the walked gap, or Skip. Likewise
  "this is probably a focus trap": quote the implementation and the absent release, or Skip.
- "Focus is invisible." Quote the suppressing rule **and** state the absence of a replacement; one
  without the other is not evidence. "The tab order is wrong": quote the positive `tabindex`, or
  the walked order against the visual one.
- Never write **compliant**, **conformant** or **non-compliant** as a verdict. Write "fails SC
  2.1.1 at this control" and let the reader draw the line.
- A 2.4.11 finding for a partially covered element; a 2.4.7 finding where a `:focus-visible`
  replacement exists elsewhere in the cascade; a 2.1.4 finding for a shortcut that requires a
  modifier or is scoped to a focused component; a 2.4.3 finding for `tabindex="-1"` on a
  programmatically focused container; screen-reader announcement behavior asserted from source,
  which is Cat 11's material.

### Detection

Static read of component source, event handlers and CSS across the representative page set, in
source or crawl mode, plus a keyboard walk where a human or runner is available. 2.1.4 and 2.4.7
resolve statically; 2.1.1, 2.1.2 and 2.4.3 give signals a walk confirms; 2.4.11 is runtime-only.

### What to Search For

- `onClick` / `@click` on `div`, `span`, `li`, `td`, `img` with no role, tab stop or key handler;
  `:hover`-revealed menus with no `:focus-within`, `:focus` or click path
- `outline: none` / `0` with no `:focus-visible` replacement; `tabindex` above 0 or `-1` on things
  a person must reach
- `draggable`, `dragstart`, `pointerdown`, `mousedown`, `touchstart` with no keyboard path; modals
  and popovers (focus in, held, Escape, restored); focus-trap utilities that never release; frames
  and players that capture Tab or arrow keys
- Window-scoped `keydown` listeners matching bare characters with no modifier check and no disable
  setting; router hooks with no focus move; `autofocus` and `.focus()` calls
- `position: fixed` / `sticky` headers, cookie bars and chat launchers on the scroll path, and
  `scroll-margin-top` on focusable elements

### Actually Fails

- **Non-semantic element with a click handler and no role, tab stop or key handler, or a hover-only
  menu with no focus or click path.** Evidence: the element and handler at `file:line`, or the CSS
  rule and absent focus rule. 2.1.1, Critical.
- **Drag-only interaction with no keyboard equivalent.** Evidence: the handlers and the absent
  keyboard path. 2.1.1, Critical. Cross-file the 2.5.7 half with Cat 07.
- **Modal, drawer or frame that traps focus with no Escape and no path out.** Evidence: the trap
  implementation and the absent release, or the walked trap. 2.1.2, Critical.
- **Single-character shortcut with no modifier, no way to turn it off or remap, and no scoping to a
  focused component.** Evidence: the listener and the missing setting. 2.1.4, High.
- **`tabindex` above 0**, which reorders the document's tab sequence, or **`tabindex="-1"` on a
  control a person must reach.** Evidence: the element. 2.4.3, High.
- **Modal opened with focus left behind, closed without restoring it to the trigger, or a route
  change leaving focus on the previous page.** Evidence: the handler. 2.4.3, High.
- **`autofocus` skipping essential content, or a focus indicator suppressed with no replacement.**
  Evidence: the attribute (2.4.3, Medium), or the CSS rule **and** the stated absence of a
  replacement in the cascade (2.4.7, High).
- **Focused element entirely hidden by a sticky header, cookie bar or chat widget**, confirmed by a
  walk. Evidence: the rule and the observation. 2.4.11, Medium.

### NOT a Failure

- A non-semantic element with `role="button"`, `tabindex="0"` and Enter plus Space handling; native
  `<button>`, `<a href>`, `<input>` or `<select>` with no added `tabindex`; `autofocus` on the first
  field of a single-purpose form.
- `outline: none` paired with a visible `:focus-visible` replacement, and a focus ring unlike the
  browser default; the criterion asks for visible, not default.
- `tabindex="-1"` on a programmatically focused container; a hover menu that also opens on focus or
  click; a modal that holds focus **and** closes on Escape, which is the dialog pattern.
- A shortcut requiring a modifier key; one active only while a component has focus; one with a
  setting to disable or remap it. A focused element only **partially** covered by a sticky header,
  and skip links hidden until focused.

### Context Check

1. Is the control native or custom? A native element carries role, tab stop and key handling free;
   a custom one needs all three, and each missing piece is its own criterion.
2. Did anyone walk the keyboard? If not, the static signals are the findings and the walk is a Skip.
3. Does the modal hold focus **and** release it? Holding without releasing is a trap; releasing
   without holding is a focus-order failure. Name which.
4. Is the suppressing rule overridden downstream? Search the cascade before asserting 2.4.7. Is
   the shortcut scoped to a focused component (2.1.4's third condition)? Is the drag interaction
   also missing a single-pointer alternative? Cross-file that half with Cat 07.

### Severity

- **Critical** — non-keyboard-operable control, hover-only menu, drag-only action (2.1.1); keyboard
  trap in a modal, drawer or embed (2.1.2). Level A failures making functionality unreachable, and
  the rows demand letters cite most often.
- **High** — single-character shortcut with no escape hatch (2.1.4); positive `tabindex`, modal
  focus not moved or restored, route change with no focus move, `tabindex="-1"` on a reachable
  control (2.4.3); focus indicator suppressed with no replacement (2.4.7).
- **Medium** — focused element entirely obscured (2.4.11); `autofocus` skipping essential content.
- **Low** — keyboard advisories with no criterion, such as a correct but needlessly long tab order.
  Report as `keyboard (advisory)`, no SC number.

### Fix guidance

**1. Use the element that already works.** When a native element genuinely cannot be used, all three
pieces are required together: `role`, `tabindex="0"` and key handling for Enter and Space.

```jsx
/* Fails 2.1.1 and 2.4.7: no tab stop, no key handling, no focus ring */
<div className="card-action" onClick={openDetails}>View details</div>
/* Passes: native button, native focus, native Enter and Space */
<button type="button" className="card-action" onClick={openDetails}>Details</button>
```

**2. Keep the indicator, and manage the focus.**

```css
a:focus, button:focus { outline: none; }   /* fails 2.4.7: replaced nowhere */
*:focus-visible { outline: 2px solid var(--focus-color); outline-offset: 2px; }
/* 2.4.11: keep the focused element out from under the sticky header */
a, button, input, select, textarea, [tabindex] { scroll-margin-top: 5rem; }
```

```js
function openDialog(trigger) {        // 2.4.3 and 2.1.2, the dialog contract
  lastTrigger = trigger;
  dialog.showModal();                 // focus moves in, and is held
  dialog.querySelector('h2').focus();
}
dialog.addEventListener('close', () => lastTrigger.focus());   // and comes back
// Escape closes a <dialog> natively; a hand-rolled modal must handle it itself.
```

A route change is a new page, so a router hook moves focus to the new `<main>` heading (2.4.3).

**3. Give a single-key shortcut an off switch** (2.1.4).

```js
document.addEventListener('keydown', (e) => {
  if (!settings.singleKeyShortcuts) return;   // turn off; offer a remap in settings
  if (e.target.closest('input, textarea, [contenteditable]')) return;
  if (e.key === '/') openSearch();
});
```

The rule under all three: a keyboard user should see where they are, get everywhere they need, and
always get back out. Nothing here touches a color value. Report first; apply nothing unconfirmed.

### Reference

WCAG 2.2, SC 2.1.1 Keyboard, Level A: https://www.w3.org/TR/WCAG22/#keyboard · SC 2.1.2 No Keyboard
Trap, Level A: https://www.w3.org/TR/WCAG22/#no-keyboard-trap · SC 2.1.4 Character Key Shortcuts,
Level A: https://www.w3.org/TR/WCAG22/#character-key-shortcuts · SC 2.4.3 Focus Order, Level A:
https://www.w3.org/TR/WCAG22/#focus-order

SC 2.4.7 Focus Visible, Level AA: https://www.w3.org/TR/WCAG22/#focus-visible · SC 2.4.11 Focus Not
Obscured (Minimum), Level AA, new in 2.2: https://www.w3.org/TR/WCAG22/#focus-not-obscured-minimum

W3C ARIA Authoring Practices, canonical keyboard interaction per widget pattern:
https://www.w3.org/WAI/ARIA/apg/patterns/ · MDN `:focus-visible`:
https://developer.mozilla.org/en-US/docs/Web/CSS/:focus-visible · MDN `<dialog>`:
https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/dialog · axe-core rules:
https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md
