## CATEGORY 134: Agent operability (accessibility-tree / machine-actionability)

A page is no longer used only by people. Browsing, shopping, booking, and research
agents act on web pages on a user's behalf, and to do that they must *operate* the page, not
just read it. Operating means perceiving the primary action and completing it: clicking the
real control that submits a signup, adds to cart, books a slot, or runs a search. The channel
an agent reads is the accessibility tree the browser builds from the markup, not the styled
render. A page can look finished to a human and be opaque to a machine when its controls are
`div`/`span` click handlers instead of real elements, when its inputs have no programmatic
name, and when it has no landmark structure to orient by. This category audits one question:
could an automated agent perceive and complete this page's primary action?

Scope note: this is distinct from Cat 101 (AI-agent commerce signals), which asks whether
*product data* is extractable and structured for agents. Cat 134 asks whether the page is
*operable*, whether a machine can take the action, regardless of how well the product is
described. It also overlaps heavily with the human-accessibility categories: Cat 17 (semantic
HTML) and Cat 103 (accessible names and keyboard operability, SC 4.1.2 / 2.1.1). Strong
human a11y and agent operability rise and fall together, and a page that passes those three
usually passes this one. The lens here is narrower and action-first: "can a machine agent
complete the job," framed around the page's primary action. Cross-ref those categories rather
than re-deriving their checks.

### Pre-flight: relevance check

Skip with reason `not applicable` for a purely informational page with no primary action a
machine would operate (no signup, add-to-cart, booking, search, or contact submit). Required
for any page that has a primary conversion action. If the page hydrates its controls
client-side and you are in a non-JS-rendering crawl, do not run the absence checks; follow the
crawl-mode caveat under Evidence required.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Read `.snitch-marketing-context.md` for the page's primary action (the brand's main
   conversion: signup, add-to-cart, book, search, contact). Ground the audit on the real
   primary action, not an assumed one.
2. Locate the control that triggers the primary action and confirm it is a real `<a href>` or
   `<button>`. Quote it with file:line. A `div`/`span` with an `onClick` and no `role`,
   `tabindex`, or keyboard handler is the finding.
3. Inventory the inputs in the primary flow. For each, confirm a programmatic name: a wrapping
   or `for`-associated `<label>`, `aria-label`, `aria-labelledby`, or a `name`. Quote any
   control with none (a placeholder is not an accessible name).
4. Check for landmark regions: `<main>`, `<nav>`, `<header>`. Record absence.
5. Check whether any key step depends on a hover-only menu or a drag-only / pointer-only
   interaction with no click- or keyboard-operable alternative.

**Crawl mode, required tool calls:**

1. Fetch the page. If it renders server-side, inspect the served HTML for the primary control,
   input names, and landmarks as above. Quote URL + selector + the rendered HTML of the
   element.
2. Where a rendered accessibility tree is available (a JS-rendering crawler or browser
   automation), capture the tree and compare it against the raw HTML. This is the dual channel:
   the comparison catches client-side controls that are invisible to a non-JS crawl and
   confirms what a machine actually perceives.
3. Crawl-mode caveat: if the crawler does not execute JS and the page hydrates its controls
   client-side, the post-hydration DOM is invisible. A `curl` of the page returns shell HTML
   and the primary control may simply not be present yet. Do not report it as absent. **Skip
   with reason** `primary controls are client-rendered; a non-JS crawl cannot see the
   post-hydration accessibility tree, re-run in source mode or with a JS-rendering crawler`.

### Forbidden claims

- "An agent can't use this page." Too generic. Name the specific primary action and the
  specific element that blocks it, with quoted evidence (file:line in source; URL + selector +
  rendered HTML in crawl).
- "The button isn't a real button." Quote the element and show it is a `div`/`span` with an
  `onClick` and no role or keyboard handler, not simply a styled `<button>`.
- "There's no `<main>` / landmark." In a non-JS crawl the landmark may be injected on
  hydration. Confirm against a rendered DOM or Skip-with-reason; do not report post-hydration
  structure as absent.
- "The input has no label." Check `aria-label`, `aria-labelledby`, and a wrapping `<label>`,
  not only a `for`/`id` pair, before claiming no accessible name.

### Detection

Primary-action operability check: trace the page's primary action to its triggering control
and confirm the control is a real semantic element with an accessible name, sitting inside
landmark structure, reachable without pointer-only interaction. Where a rendered accessibility
tree is available, compare it against the raw HTML to catch client-side controls invisible to
non-JS crawl. Quote the blocking element with evidence. This shares mechanics with human a11y
(Cat 17/48/104); cross-ref rather than re-derive.

### What to Search For

- Interactive elements built as non-semantic `div`/`span` with `onClick` and no `role`,
  `tabindex`, or keyboard handler
- A primary CTA that is not a real `<a href>` or `<button>`
- Inputs or controls with no accessible name (no `<label>`, `aria-label`, `aria-labelledby`,
  or `name`)
- Forms whose submit control or fields are not programmatically associated with the form
- Missing landmark regions (`<main>`, `<nav>`, `<header>`) on a page with a primary action
- A key action reachable only via a hover-only menu or a drag-only / pointer-only interaction
- SPA controls present in the rendered DOM but absent from the non-JS crawl HTML (compare tree
  against raw HTML)

### Actually Hurts the Marketing Surface

- **The primary conversion action is a non-semantic control.** The checkout / signup / book
  trigger is a `div` with an `onClick`, no role, no keyboard handler, so an agent cannot
  perceive or operate it. This is the core failure of the category.
  Evidence required: the quoted element (file:line in source; URL + selector + rendered HTML in
  crawl) + the named primary action it blocks.
- **A required input in the primary flow has no accessible name.** The agent can see a form but
  cannot tell the email field from the coupon field, so it cannot fill the right one.
  Evidence required: the input element quoted + absence of label / `aria-label` /
  `aria-labelledby` / `name`.
- **The page has no landmark structure.** Only generic `div` containers, no `<main>` / `<nav>`
  / `<header>`, so an agent has no regions to orient by when finding the action.
  Evidence required: the document outline showing only generic containers, no landmark elements.
- **A key step is gated behind a hover-only or drag-only interaction.** The action a user must
  reach opens only on hover, or a control is drag-only with no operable equivalent.
  Evidence required: the interaction quoted + absence of a click- or keyboard-operable path.
- **A secondary action is non-operable.** A non-primary control (filter, secondary CTA) is a
  non-semantic or unlabeled element an agent can't reliably target.
  Evidence required: the quoted element + the secondary action it blocks.

### NOT a Problem

- A page already built on semantic HTML with labeled controls and landmark structure (Pass,
  and note the synergy: it inherits operability from Cat 17 / 48 / 104).
- A purely informational page with no primary action to operate.
- A progressive-enhancement pattern where the operable control is a real semantic element and
  the JS only enhances it (the agent gets the real fallback).
- A deliberately gated flow (auth) where the gate itself is an operable, labeled control.
- An element that is non-semantic in raw HTML but renders as a real, named control
  post-hydration, confirmed in the rendered accessibility tree. Do not flag from a non-JS crawl
  alone; Skip-with-reason instead.

### Context Check

1. What is the page's primary action, and is the control that triggers it a real `<a href>` or
   `<button>`?
2. Does every input in the primary flow have a programmatic name?
3. Does the page have landmark regions an agent can orient by?
4. Can the primary flow be completed without hover-only or pointer-only interactions?
5. Are you judging from a rendered accessibility tree, or from non-JS crawl HTML that cannot
   see post-hydration controls?
6. Is this a genuine operability gap, or is strong human a11y already in place (Cat 17/48/104)
   that an agent inherits?

### Reference

WAI-ARIA accessibility-tree model, and the first rule of ARIA (use a native element before
adding a role): https://www.w3.org/WAI/ARIA/apg/

web.dev Learn Accessibility, on building with real controls, accessible names, and landmark
regions: https://web.dev/learn/accessibility/

MDN, the accessibility tree and accessible names:
https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA

Cross-ref Cat 101 (agent-readable product data), Cat 17 (semantic HTML), Cat 103 (accessible names
and keyboard operability), Cat 82 (AI-search citation).

**Severity tagging:**
- Primary conversion action (checkout, signup, book, primary search) implemented as a
  non-semantic or unlabeled control an agent can't reliably operate → High.
- A required input in the primary flow with no accessible name → High (the agent perceives the
  form but can't target the field).
- Missing landmark structure on a page with a primary action → Medium.
- A key step gated behind a hover-only or drag-only interaction with no operable alternative →
  Medium.
- A secondary (non-primary) action that is non-operable → Medium.
- Minor unlabeled non-critical controls → Low.

**Fix voice:** `intrinsic-web-engineer` (primary) | `solutions-architect` (backup).

Read `souls/intrinsic-web-engineer.json` before writing the Fix.

Worked fix example:

> A `div` with an `onClick` is not a button. It looks like one, and for a mouse user it even
> behaves like one, but the browser builds an accessibility tree from your markup, and that
> tree is what a machine agent reads. A `<div>` arrives in the tree as a generic group: no
> role, no name, no keyboard behavior. The agent hunting for "the thing that completes
> checkout" finds nothing it can act on, because you described the control to the eyes and
> never to the machine.
>
> Use the element the platform already gives you. `<button>` is a real control. It has a role,
> it is focusable, it fires on Enter and Space, and it shows up in the tree as "button" with
> its text content as its name. You do not reconstruct those behaviors with `tabindex` and
> `onkeydown` and `role="button"`. That is twenty years of workaround thinking applied to a
> problem the platform already solved. Write the real element and you get all of it for free.
>
> ```html
> <!-- Not operable: described to the eye, invisible to the tree -->
> <div class="cta" onclick="checkout()">Complete purchase</div>
> <span class="link" onclick="goToPricing()">Pricing</span>
> <input class="field" placeholder="Email">
>
> <!-- Operable: real controls, real names, inside real landmarks -->
> <main>
>   <button type="button" onclick="checkout()">Complete purchase</button>
>   <a href="/pricing">Pricing</a>
>   <label for="email">Email</label>
>   <input id="email" name="email" type="email">
> </main>
> ```
>
> Then give every input a programmatic name. A placeholder is not a label. Wire a `<label for>`
> to the field, or use `aria-label` only where a visible label genuinely does not fit, so the
> field reads as "Email, edit text" in the tree instead of "edit text, blank." And give the
> page its landmarks: a real `<main>`, `<nav>`, `<header>`. Those are the regions an agent uses
> to orient, the same way a person scans for where the form is.
>
> Verify against the tree, not the render. Open the accessibility inspector, or run an
> automated agent through the primary action once. If the path from landing on the page to the
> action being done is all real controls with real names inside real landmarks, then a person
> on assistive tech and a machine acting for one both get through. Same markup, both audiences.
> That is the web doing the job it was built to do.
