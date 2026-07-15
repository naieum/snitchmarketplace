## CATEGORY 104: Keyboard navigation + focus management

Keyboard navigation is one of the highest-leverage a11y surfaces because it's the entry point for users on assistive tech (screen readers route through keyboard navigation), users with motor impairments, power users on every platform, and any user when their mouse fails. It's also one of the most commonly broken because devs build with a mouse and rarely audit without one. Cat 48 (ARIA labels) covers labeling; this category covers the journey itself: focus order, focus visibility, focus management on dynamic UI, keyboard traps, and the common patterns (modals, menus, tabs, custom widgets) that consistently break.

This is the Operable step (step 2) of `references/accessibility-audit-workflow.md`; run it as part of that sequence when a full a11y pass is in scope.

### Pre-flight: relevance check

Run on every site that has more than a static landing page. Skip with reason `not applicable` only for single-page brand sites with no interactive elements beyond a single CTA link.

### The framework: 5 audit dimensions

| Dimension | What's tested | Common failure |
|---|---|---|
| **1. Focus order** | Tab order matches visual + semantic flow | Tab jumps wildly across the page; tab skips an interactive element |
| **2. Focus visibility** | Focused element is visually identifiable | `outline: none` without replacement; low-contrast focus ring |
| **3. Focus management on dynamic UI** | Modals, drawers, route changes move focus appropriately | Modal opens, focus stays on trigger button behind modal |
| **4. Keyboard traps** | Focus can move into AND out of every interactive region | Modal trap with no escape; embedded video player traps focus |
| **5. Keyboard parity** | Every mouse-operable action also keyboard-operable | Hover-only menu; drag-to-reorder without keyboard alternative |

### Evidence required (do not skip)

The static checks below run directly against source/CSS. The actual keyboard walk (tabbing, opening modals, pressing Escape, triggering route changes) needs a live browser driven by a human or an external runner — the bundle ships neither. Do the static checks; for each runtime step, run it only if a human tester or runner is available, otherwise Skip-with-reason (e.g. `keyboard walk requires a human or runner — not run`). Static signals often strongly imply a break (e.g. `<div onClick>` with no handler), but don't assert the live behavior you didn't observe.

**Static checks (perform directly on source / CSS):**

1. `Grep` for focus-suppressing CSS: `outline:\s*none`, `outline:\s*0`. Quote each. Confirm whether a `:focus-visible` replacement exists.
2. `Grep` for `tabindex` usage. `tabindex="0"` is fine; `tabindex="-1"` is fine for programmatically-focused elements; `tabindex="N"` (N>0) is almost always wrong (forces focus order).
3. `Grep` for hover-only patterns: `:hover` styles on dropdowns / menus without `:focus-within` equivalent.
4. `Grep` for `onClick` on non-button / non-link elements (`<div onClick={...}>` with no role + no keyboard handler).
5. Read modal/drawer/popover components. Check for focus-trap library usage (`focus-trap-react`, `react-focus-lock`, or hand-rolled equivalent). Check for `Escape` key handler.
6. Read route change handler (TanStack Router / Next.js / etc.). Check whether focus is moved to `<main>` or page heading on route change.

**Runtime checks (requires a human or external runner; otherwise Skip-with-reason):**

1. Tab through the entire homepage. Quote the focus order vs visual order. Note any focusable element skipped or any non-focusable element receiving focus.
2. Open modals / drawers. Check focus moves into the modal AND can be closed by Escape AND focus returns to trigger on close.
3. Activate dropdown menus. Check keyboard activation works (Enter / Space / Arrow keys).
4. Trigger route changes. Check focus is moved to a meaningful target (skip-link, main heading, page-level focus target).

Crawl mode carries the same split: static checks apply to the fetched HTML/CSS; the keyboard walk is a runtime step — Skip-with-reason unless a human or runner performs it.

### Forbidden claims

- "Keyboard navigation may have gaps." Either quote the static signal (e.g. `<div onClick>` with no handler, `tabindex` > 0), or — if a human/runner walked it — quote the gap. If neither, Skip-with-reason; don't guess.
- "Focus indicator may be suppressed." Quote the CSS rule (`outline:none`/`outline:0` with no `:focus-visible` replacement).
- "Modal may trap focus." Quote the static signal (missing focus-trap / no Escape handler in the component); for the live behavior, test it and quote it, or Skip-with-reason.

### What to Search For

- `outline: none` / `outline: 0` CSS rules
- `tabindex="N"` where N > 0
- `<div>` / `<span>` with `onClick` (non-semantic interactive)
- Hover-only state changes
- Modal / drawer / popover components without focus-trap
- Route handlers without focus management
- Skip-link presence (Cat 103 cross-ref)

### Actually Hurts the Marketing Surface

- **Focus indicator suppressed globally** (`*:focus { outline: none }` without replacement).
  Evidence required: CSS rule + visual focus test.
- **Tab order skips important elements** (a CTA button is non-focusable, or focus jumps from header to footer past the main content).
  Evidence required: tab walk + element skipped.
- **`<div onClick>` instead of `<button>`** (no keyboard activation; not announced by screen readers).
  Evidence required: source location + the click handler.
- **Modal opens without moving focus into it** (focus stays on the trigger button behind the modal; user can tab "behind" the modal).
  Evidence required: modal open + focus location.
- **Modal close (Escape key) not handled** (user must tab to close button, slow).
  Evidence required: open modal + Escape press behavior.
- **Modal close doesn't return focus to trigger** (focus is lost; assistive tech users disoriented).
  Evidence required: open + close cycle + final focus location.
- **Focus trap missing on modal** (focus tabs out of the modal into background content).
  Evidence required: tab from inside modal + reaches background element.
- **Hover-only menus** (mouse hovers reveal submenu; keyboard cannot trigger).
  Evidence required: CSS `:hover` rule without `:focus-within` equivalent.
- **Drag-and-drop without keyboard alternative** (reorder, resize, move).
  Evidence required: drag-only UI + missing keyboard handler.
- **Custom widget without ARIA pattern** (a custom dropdown that lacks `aria-expanded`, `aria-controls`, role="listbox", etc.).
  Evidence required: widget + missing ARIA pattern per W3C ARIA Authoring Practices.
- **Route change doesn't move focus** (SPA navigation feels like a page jump for keyboard users; new content not announced).
  Evidence required: route handler + missing focus shift.

### NOT a Problem

- `outline: none` on a custom focus-styled element WITH a visible replacement (`:focus-visible { box-shadow: 0 0 0 2px var(--focus-color) }`).
- `tabindex="-1"` on programmatically-focused elements (modal containers, error summary regions), correct pattern.
- Non-semantic `<div>` with `role="button"` + `onKeyDown` for Enter/Space + `tabindex="0"`, semantically equivalent to `<button>`, just verbose.
- Hover menu that ALSO opens on focus or click, keyboard parity present.

### Context Check

1. Has a developer walked the entire site without a mouse? Single best test.
2. Are modals / drawers / popovers using a battle-tested focus-trap library, or hand-rolled (often broken)?
3. Is route-change focus management handled? Frameworks (Next.js, TanStack Router) don't do this by default.
4. Are custom widgets following W3C ARIA Authoring Practices patterns? "It looks like a dropdown" isn't enough; the keyboard contract has to match.
5. Are skip-links present + visible on focus?

### Reference

W3C ARIA Authoring Practices (the canonical patterns for keyboard widgets): https://www.w3.org/WAI/ARIA/apg/

WAI-ARIA Authoring Practices on focus management: https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/

WCAG 2.2 SC 2.1.1 Keyboard, 2.4.3 Focus Order, 2.4.7 Focus Visible, 2.4.11 Focus Not Obscured, 2.4.13 Focus Appearance.

react-focus-lock: https://github.com/theKashey/react-focus-lock

focus-trap-react: https://github.com/focus-trap/focus-trap-react

**Severity tagging:**
- Focus indicator suppressed globally → Critical.
- `<div onClick>` for primary actions → Critical.
- Modal opens without focus management → Critical.
- Modal close doesn't return focus → High.
- No Escape handler on modal → High.
- Focus trap missing on modal → Critical.
- Tab order skips important elements → High.
- Hover-only menus → High.
- Drag-and-drop without keyboard alternative → High.
- Route change without focus management → Medium.

**Fix voice:** `don-norman` (primary) | `aarron-walter` (backup).

Read `souls/don-norman.json` before writing the Fix.

Worked fix example:

> Keyboard navigation is the canonical test of whether the interface respects the user. The mouse is one input method among many; users who rely on keyboard, voice, switch, or assistive tech all route through the same focus model. If the focus model is broken, the interface is broken for everyone who isn't a sighted mouse user, and that population is far larger than most teams realize.
>
> Three commitments to make.
>
> **1. Visible focus, always.** Suppress no focus indicators. If the default browser outline is ugly, replace it with a custom one, `:focus-visible` lets you style focus only when keyboard-driven. Non-negotiable: every interactive element shows where focus currently is.
>
> ```css
> *:focus-visible {
>   outline: 2px solid var(--focus-color);
>   outline-offset: 2px;
>   border-radius: 4px;
> }
> ```
>
> **2. Focus management on every UI transition.** Modal opens → focus moves into the modal's first focusable element AND a focus trap holds it inside. Modal closes → focus returns to the trigger. Route changes → focus moves to `<main>` or the page heading. Errors → focus moves to the error summary.
>
> **3. Semantic elements first; ARIA only when no semantic exists.** A `<button>` does the right thing for keyboard activation, screen reader announcement, focus management, and disabled state. A `<div role="button" onClick onKeyDown tabindex>` is the same thing but worse. Reach for the semantic element first; ARIA is a fallback for cases where no semantic equivalent exists.
>
> The discipline pays back across every assistive-tech user, every power user who tabs through forms, every user whose mouse battery dies. Build the keyboard model right and you've built the foundation for everything else accessibility cares about.
