## CATEGORY 48: ARIA labels on interactive elements

Interactive elements without text content (icon-only buttons, image links, custom controls) need an accessible name via `aria-label`, `aria-labelledby`, or alt text. Without it, screen readers announce "button" with no context. This is an accessibility/UX requirement (WCAG 4.1.2; Lighthouse a11y flags it) with only indirect SEO value — Google's Mobile Usability report was retired Dec 1 2023, so there's no live mobile-usability test that scores these signals.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `<button`, `<a` elements. For each, inspect the children + `aria-label` / `aria-labelledby` attribute.
2. Identify icon-only patterns: button containing only `<svg>`, `<img>` with empty alt, or `<i className="icon">`.
3. For each icon-only interactive: confirm aria-label or accessible name.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Find buttons + links. Check accessible name (text content, aria-label, aria-labelledby).

### Forbidden claims

- "ARIA labels may be missing." Quote elements + their accessible names.
- "Icon buttons probably aren't labeled." Show specific elements.

### Detection

Interactive elements with no text content.

### What to Search For

- `<button>` with only icon children
- `<a href>` with only icon children
- `<img>` inside a link with empty alt and no surrounding text
- Custom controls with `role="button"` etc.

### Actually Hurts SEO

(Indirect: accessibility/UX value (WCAG 4.1.2, Lighthouse a11y). SEO benefit is indirect; the retired Google Mobile Usability report no longer scores these signals.)

- **Icon-only button without aria-label**.
  Evidence required: element + missing aria-label.
- **Image link without alt text** (alt is the link text).
  Evidence required: img inside a + missing/empty alt.
- **Form input without label** (`<input>` with no `<label for>` and no aria-label).
  Evidence required: input element + lookup for matching label.

### NOT a Problem

- Buttons with text content. Acceptable.
- Decorative icons inside text-bearing buttons (`<button><Icon aria-hidden /> Save</button>`). Correct.
- Icons with adjacent visible text labels. Acceptable.

### Context Check

1. Is the element interactive? Decorative icons don't need labels.
2. Is there a visible text label adjacent? May suffice without aria-label.
3. Is the icon a recognized convention (X for close, hamburger for menu)? Accessible name should still be set explicitly.

### Reference

WAI-ARIA Authoring Practices: https://www.w3.org/WAI/ARIA/apg/

WCAG 4.1.2 Name, Role, Value: https://www.w3.org/WAI/WCAG21/Understanding/name-role-value.html

**Severity tagging:**
- Icon-only button without label → High.
- Image link without alt → High.
- Form input without label → Critical.

**Fix voice:** `aarron-walter` (primary) | `don-norman` (backup).

Read `souls/aarron-walter.json` before writing the Fix. Aarron's "designing for emotion" includes designing for the people whose emotion you can't see, screen reader users, keyboard users, anyone whose interface isn't visual.

Worked fix example:

> An icon-only button is mute to a screen reader without a label. Give it a name.
>
> ```tsx
> // Bad: screen reader hears "button"
> <button onClick={close}><CloseIcon /></button>
>
> // Good: screen reader hears "Close dialog"
> <button onClick={close} aria-label="Close dialog">
>   <CloseIcon aria-hidden="true" />
> </button>
> ```
>
> The icon gets `aria-hidden="true"` so it's not announced separately. The button's `aria-label` becomes the accessible name. Same visual; the experience for assistive tech goes from confusing to clear.
