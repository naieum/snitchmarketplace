## CATEGORY 07: Pointer gestures, cancellation, label in name, motion and target size

Everything here is about the **pointer**: the finger, the mouse, the stylus, the head-tracker, the spoken command that stands in for a click. A gesture that needs two fingers locks out anyone who has one. An action that fires the instant the pointer goes down cannot be aborted by a hand that shakes. A button whose visible label is not inside its accessible name cannot be spoken by a voice-control user. A 16 CSS pixel close control cannot be hit reliably with a tremor, on a moving train, or with large fingers.

Four of these six criteria are Level A. Two are new in WCAG 2.2, and they are the ones most codebases have never been checked against. All six leave a static signal in source, which makes this category cheap to run and hard to argue with.

**Boundary.** This category asks whether the pointer interaction meets its criterion. Whether a small or awkward target costs a specific user the task they came to do, or reads as friction on the decision path, is the sibling's judge — call the Skill tool with "snitch-ux". Same control, two judges: the criterion belongs here, the blocked task belongs there. When the same drag or slider is being judged as a conversion element, that is marketing's half — call the Skill tool with "snitch-marketing".

### Pre-flight

Run on any surface with interactive controls, which is nearly all of them. The static half needs only source or fetched HTML plus CSS.

Skip the whole category with reason `not applicable` only when the audited surface has no interactive controls at all (a plain text document, a feed endpoint). A page with a single link is in scope.

Before scanning, list the test scope: 5-10 representative pages covering home, content, conversion, post-conversion and error surfaces. Findings quote a page from that list.

### Rule table

One row per success criterion. A finding names its row. A pointer check with no row here is a Skip, never a finding under a borrowed SC.

| SC | Level | What must hold | Static signal (source / DOM) | Runtime-only? | Severity |
|---|---|---|---|---|---|
| 2.5.1 Pointer Gestures | A | All functionality using multipoint or path-based gestures can be operated with a single pointer without a path-based gesture, unless the gesture is essential | pinch-zoom map or image viewer, swipe-only carousel, slide-to-confirm, signature pad, two-finger tap handler, `touchmove` / `gesturestart` / `pointermove` path logic with no button, arrow-key or click equivalent in the same component | No | High |
| 2.5.2 Pointer Cancellation | A | Single-pointer functions do not execute on the down-event, or offer abort / undo, or reverse on up | `mousedown` / `pointerdown` / `touchstart` handlers that navigate, submit, delete, purchase or toggle, with no matching up-event, no abort control and no undo | No | Medium |
| 2.5.3 Label in Name | A | For components labeled with visible text, the accessible name **contains** that visible text | `aria-label` that differs from the rendered label text; icon plus text button where `aria-label` replaces the words; `aria-labelledby` pointing at a node that does not include the visible string | No | High |
| 2.5.4 Motion Actuation | A | Motion-operated functionality also works through UI components and motion response can be disabled | `devicemotion` / `deviceorientation` listeners, shake-to-undo, tilt-to-scroll, `DeviceMotionEvent.requestPermission` with no button equivalent and no off switch | No | Medium |
| 2.5.7 Dragging Movements (new in 2.2) | AA | Anything operated by dragging has a single-pointer alternative that does not require dragging | sortable list, kanban board, range slider, drag-to-reorder, drag-and-drop file zone, resize handle, with no click, tap, arrow-key or type-a-value path | No | Medium |
| 2.5.8 Target Size (Minimum) (new in 2.2) | AA | Pointer targets are at least **24 by 24 CSS pixels**, or undersized targets are spaced so a 24 CSS pixel diameter circle centred on each bounding box does not intersect another target's circle | declared width / height / padding / line-height resolving under 24×24; packed icon rows, footer link grids, close buttons, pagination, star ratings, table row actions with no gap | Partly — resolved size needs a render | High (primary CTA) / Medium (other) |

**One target floor.** 24×24 (2.5.8, AA, new in 2.2) is the only target-size threshold that emits a finding. 44 by 44 comes from 2.5.5 Target Size (Enhanced), a **Level AAA** criterion introduced in WCAG 2.1, and from platform design guidance. Report it as advisory only. A 32×32 control clears the floor and is a Pass, not a failure for being under the AAA number.

**The four exceptions to 2.5.8, verbatim in effect.** Spacing (the 24 CSS pixel circle test above); Equivalent (the same function is available through another control on the page that meets the criterion); Inline (the target sits in a sentence, or its size is constrained by the line-height of non-target text); User Agent Control (the size is set by the browser and not modified by the author); Essential (a particular presentation is essential or legally required). An inline link inside body copy and an unstyled native checkbox are both out of scope by these exceptions.

**2.5.1's exception** is essential gestures only: a drawing canvas, a handwriting field, a map that genuinely needs free panning. "Our carousel is nicer with swipe" is not essential.

### Evidence required

A finding needs an observation and a criterion. The observation is a quoted element at `file:line` (source mode) or URL plus selector with the rendered HTML (crawl mode), or a runner rule id with its offending node.

**Source mode, cheapest first:**

1. `Grep` for down-event handlers: `onMouseDown`, `onPointerDown`, `onTouchStart`, `addEventListener\(['"](mousedown|pointerdown|touchstart)`. For each hit, `Read` the component and record whether the effect completes there (2.5.2).
2. `Grep` for gesture and drag surfaces: `onTouchMove`, `onPointerMove`, `draggable=`, `onDragStart`, `dnd`, `sortable`, `swipe`, `pinch`, `gesturestart`, `type="range"`. `Read` each component for a click, tap, arrow-key or numeric-entry alternative in the same component (2.5.1, 2.5.7).
3. `Grep` for `aria-label=` and `aria-labelledby=` on elements that also render visible text. Compare the attribute string to the rendered string character by character. The accessible name must **contain** the visible text (2.5.3).
4. `Grep` for `devicemotion`, `deviceorientation`, `DeviceMotionEvent`, `shake`, `accelerometer`. Record the UI equivalent and the disable control, or their absence (2.5.4).
5. Approximate target dimensions for every icon button, close control, pagination link, rating star, table row action and footer link: sum declared `width` / `height`, or `font-size` plus `padding` plus `border`, or `line-height` for text-only controls. Record the declared `gap` / `margin` between adjacent undersized targets (2.5.8).

**Crawl mode:**

1. `Fetch` each page in the test scope. Quote the control's rendered HTML plus its selector.
2. Resolve the target box from the served stylesheet the same way, and say the value is approximated.
3. Where a runner is available, quote its target-size and label-in-name rule ids alongside the element.

**Cascade caveat, applies to every CSS-derived check here.** Source reads and fetches return declarations, not the resolved cascade. The computed box can differ from the approximation because of a later rule, a media query, a `transform`, or a pseudo-element that extends the hit area. Say so in the finding, give the declaration you read, and mark Confidence Medium unless the rendered box was measured.

**Runtime checks (need a human or a runner; the bundle ships neither):**

1. Measure the rendered bounding box of each flagged target at the default zoom and at a ~320 CSS pixel viewport.
2. Operate every gesture surface with a single pointer and with the keyboard only.
3. Confirm the down-event behaviour by pressing, dragging off the control, and releasing.
4. Speak the visible label into a voice-control tool and confirm the control activates (2.5.3).

If none is available: `Skip — target-box measurement requires a human or runner; not run`, `Skip — single-pointer gesture walk requires a human or runner; not run`, and report only the static findings.

### Forbidden claims

- "Touch targets may be too small." Quote the element, its approximated dimensions, the declarations they came from, and state that the resolved size may differ.
- "Targets should be at least 44 by 44 pixels to meet AA." They should not. 24×24 is the AA floor (2.5.8). Write 44 only as "2.5.5 Target Size (Enhanced), Level AAA, from WCAG 2.1 — advisory".
- "The carousel is probably not keyboard accessible." That is 2.1.1 and a different category. Here, quote the gesture handler and the absent single-pointer path, or Skip.
- "Drag and drop is inaccessible." Name the component, quote the drag binding, and name the missing alternative (2.5.7).
- "The label does not match." Quote both strings: the visible text and the accessible name, and state which one fails to contain the other (2.5.3).
- Never write "compliant", "conformant" or "non-compliant" as a verdict. Conformance follows a complete audit. Write "fails SC 2.5.8 at these elements" and let the reader draw the line.

### Detection

Source or rendered-DOM audit of interactive components, their event bindings, their accessible names and their declared box metrics, across the representative page set, plus runner output where a runner exists.

### What to Search For

- `mousedown` / `pointerdown` / `touchstart` bindings that complete an action
- `touchmove` / `pointermove` path logic, pinch and multi-finger handlers, swipe-only carousels, slide-to-confirm controls
- `draggable`, drag-and-drop libraries, sortable lists, kanban columns, resize handles, `input[type=range]`, file drop zones
- `aria-label` / `aria-labelledby` on elements that also render visible text
- `devicemotion`, `deviceorientation`, shake and tilt handlers, and whether motion response can be turned off
- Icon buttons, close and dismiss controls, pagination, breadcrumbs, star ratings, table row actions, packed footer link grids, and the `gap` between them
- Controls sized by `font-size` and `line-height` alone with no padding

### Actually Fails

- **Multipoint or path-based gesture with no single-pointer path** (2.5.1). Evidence: the gesture handler and the component's full control surface, showing no button, arrow-key or click equivalent.
- **Action completed on the down-event with no abort and no undo** (2.5.2). Evidence: the `pointerdown` handler and the effect it triggers. A delete, a purchase or a navigation on down-event is the sharp case.
- **Visible label text absent from the accessible name** (2.5.3). Evidence: the rendered label string and the `aria-label` value side by side. `aria-label="Submit form"` on a button reading "Send" fails: a voice-control user says "Send" and nothing happens.
- **Motion-only function with no UI equivalent and no way to disable motion response** (2.5.4). Evidence: the motion listener and the absent control.
- **Drag-only interaction with no click or keyboard path** (2.5.7). Evidence: the drag binding and the missing alternative. A sortable list with no "move up" / "move down" control is the common shape.
- **Target under 24×24 CSS pixels with adjacent targets closer than the spacing exception allows** (2.5.8). Evidence: the element, the declarations the box was approximated from, and the measured or declared gap to its neighbour.

### NOT a Failure

- A gesture surface that also exposes buttons or arrow keys for the same function: a carousel with previous and next buttons, a map with zoom controls, a slider with a typed value field.
- An action bound to the up-event, or to a down-event that a drag-away-and-release reverses, or one paired with a visible undo.
- An accessible name that **extends** the visible text: a button reading "Delete" with `aria-label="Delete invoice 4021"` passes, because the name contains the visible string. Only a name that omits or replaces the visible words fails.
- A motion shortcut that duplicates a control the user can also press, with motion response disabled in settings or by `prefers-reduced-motion` handling.
- Inline links inside a sentence at their natural size. The Inline exception covers them, and enlarging them would break the line box.
- A native, unstyled checkbox, radio or `select` whose size the browser sets. The User Agent Control exception covers it.
- An undersized icon whose function is also available through a full-size control on the same page. The Equivalent exception covers it.
- A 24×24 to 44×44 target. It clears the AA floor. Any 44-related remark is advisory under 2.5.5 (AAA, WCAG 2.1), never an AA failure.
- Decorative, non-interactive icons of any size. They are not targets.

### Context Check

1. Is the gesture essential to the function (drawing, handwriting, free map panning), or a nicety layered over a list?
2. Does the component library already ship the keyboard and click alternative, unused because the wrapper never rendered it?
3. Does the visible label come from a translated string? Then the accessible name must be translated from the same key, or it will drift out of containment per locale.
4. Is the down-event handler doing a preview (hover-like highlight) rather than completing the function? Previews are fine.
5. Was the target box measured, or approximated from declarations? Say which, every time.
6. Does a parent stretch the hit area past the icon (a padded wrapper, an `::after` overlay)? Check before flagging.
7. Is the same control also being judged for whether it blocks a user's task? Hand that half over — call the Skill tool with "snitch-ux".

### Severity

- **High** — path-based or multipoint gesture with no single-pointer alternative (2.5.1); visible label absent from the accessible name (2.5.3); primary-CTA or conversion-path target under 24×24 (2.5.8).
- **Medium** — action completed on the down-event with no abort or undo (2.5.2); motion-only function (2.5.4); drag-only interaction (2.5.7); secondary target under 24×24 or an undersized cluster failing the spacing exception (2.5.8).
- **Low** — a target between 24×24 and 44×44, reported as advisory under 2.5.5 (AAA, from WCAG 2.1) and never as an AA failure.

No Critical tier in this category. Critical is reserved for Level A failures that stop a task outright, and every failure shape here leaves some path to the function, however painful.

### Fix guidance

Four fixes, in the order the criteria bite hardest.

**1. Give every gesture a single-pointer twin** (2.5.1, 2.5.7). Keep the gesture. Add the plain control beside it. The gesture is a shortcut for the people it works for, not the only door.

```tsx
// Fails 2.5.7: the only way to reorder is to drag
<li draggable onDragStart={startDrag} onDrop={drop}>{item.name}</li>

// Passes: the drag stays, and two buttons do the same job
<li draggable onDragStart={startDrag} onDrop={drop}>
  {item.name}
  <button onClick={() => move(item.id, -1)} aria-label={`Move ${item.name} up`}>↑</button>
  <button onClick={() => move(item.id, +1)} aria-label={`Move ${item.name} down`}>↓</button>
</li>
```

**2. Move the effect to the up-event** (2.5.2). Down-event actions are how a shaking hand deletes the wrong row. Complete on release, and let a drag-away cancel it.

```jsx
// Fails 2.5.2
<button onPointerDown={deleteInvoice}>Delete</button>
// Passes: fires on click (the up-event), and the press can be dragged off and abandoned
<button onClick={deleteInvoice}>Delete</button>
```

**3. Let the name contain the label** (2.5.3). Write the accessible name as the visible text plus any clarifier, in that order, never instead of it.

```tsx
// Fails 2.5.3: the user says "Send" and nothing happens
<button aria-label="Submit form">Send</button>
// Passes: the visible words are inside the name
<button aria-label="Send message">Send</button>
```

**4. Size the target, then space the cluster** (2.5.8). A 16px glyph can sit inside a 24px hit area through padding. The user sees the icon and hits the padding.

```css
/* Floor for AA: 24 CSS px in both axes */
.icon-button { min-inline-size: 24px; min-block-size: 24px; padding: 4px; }
/* Or keep them small and satisfy the spacing exception instead */
.icon-row { display: flex; gap: 12px; }
```

Larger is better where the layout allows it, and 44 by 44 is the enhanced target under 2.5.5 (AAA, from WCAG 2.1). Treat that as advice, not as the bar this audit measures against. Confirm the resolved box in the browser before closing the finding: the declaration is not the rendered size.

### Reference

WCAG 2.2 specification: https://www.w3.org/TR/WCAG22/

2.5.1 Pointer Gestures: https://www.w3.org/WAI/WCAG22/Understanding/pointer-gestures.html · 2.5.2 Pointer Cancellation: https://www.w3.org/WAI/WCAG22/Understanding/pointer-cancellation.html · 2.5.3 Label in Name: https://www.w3.org/WAI/WCAG22/Understanding/label-in-name.html · 2.5.4 Motion Actuation: https://www.w3.org/WAI/WCAG22/Understanding/motion-actuation.html

2.5.7 Dragging Movements (AA, new in 2.2): https://www.w3.org/WAI/WCAG22/Understanding/dragging-movements.html · 2.5.8 Target Size (Minimum) (AA, new in 2.2): https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html · 2.5.5 Target Size (Enhanced) (AAA, from WCAG 2.1): https://www.w3.org/WAI/WCAG22/Understanding/target-size-enhanced.html

W3C ARIA Authoring Practices, for the keyboard patterns that replace a gesture: https://www.w3.org/WAI/ARIA/apg/

Pointer events: https://developer.mozilla.org/en-US/docs/Web/API/Pointer_events · Device motion: https://developer.mozilla.org/en-US/docs/Web/API/Window/devicemotion_event

axe-core rule descriptions, for the runner rule ids quoted alongside an element: https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md
