## CATEGORY 09: Bypass blocks, titles, link purpose, multiple ways, predictable behavior, consistent help

Nine criteria about getting around a site and not being surprised while doing it. A keyboard user who has to tab through forty header links on every page never reaches the content. A tab list read aloud as "link, link, link" tells a screen-reader user nothing. A `<select>` that navigates the moment the arrow key changes its value traps anyone who browses options with the keyboard. A help link that sits in the header on one template and at the bottom of another costs a person with a cognitive disability the one thing they were looking for.

Six are Level A, three are Level AA, and one (3.2.6 Consistent Help) is new in WCAG 2.2. Most leave a clean static signal. Three of them are cross-page comparisons, which means the finding needs at least two templates quoted side by side.

**Boundary.** This category asks whether navigation and predictability meet their criteria. Vague link text is judged here against 2.4.4 Link Purpose (In Context): can the purpose be determined from the link text plus its programmatically determined context. The same "Read more" judged against **conversion** — does the label name the outcome the visitor gets — is the sibling's half: call the Skill tool with "snitch-marketing". Whether the visitor knows what to do next on this page, as a decision-path question, is a third judge: call the Skill tool with "snitch-ux". The `<title>` splits the same way: 2.4.2 lives here, and the search and click-through signal is marketing's Category 09 — call the Skill tool with "snitch-marketing" for that half.

### Pre-flight

Run on any multi-page surface. Six of the nine criteria are single-page checks and always apply; 2.4.5, 3.2.3, 3.2.4 and 3.2.6 need at least two pages from a set to be checkable at all.

Skip 2.4.5, 3.2.3, 3.2.4 and 3.2.6 with reason `single page audited; cross-page comparison not possible` when only one page was read. Skip the whole category with reason `not applicable` only when there is no navigation, no links and no controls, which in practice never happens.

List the test scope first: 5-10 representative pages covering at least two different templates. Cross-page findings quote both.

### Rule table

One row per success criterion. A finding names its row. A navigation check with no row here is a Skip, never a finding under a borrowed SC.

| SC | Level | What must hold | Static signal (source / DOM) | Runtime-only? | Severity |
|---|---|---|---|---|---|
| 2.4.1 Bypass Blocks | A | A mechanism exists to bypass blocks of content repeated across pages | **no skip link AND no landmark structure**; a skip link that is not the first focusable element; a skip link whose `href` target does not exist or is not focusable | No | Medium |
| 2.4.2 Page Titled | A | Every page has a title that describes its topic or purpose | missing or empty `<title>`; one templated title repeated verbatim across routes; a framework default title shipped to production | No | High |
| 2.4.4 Link Purpose (In Context) | A | Each link's purpose is determinable from its text alone, or from its text plus its programmatically determined context | repeated "click here" / "read more" / "learn more" / "details" / bare URL links with no `aria-label`, no `aria-describedby`, and no enclosing sentence, list item, paragraph, table cell or list-item ancestor that supplies the purpose | No | Medium |
| 2.4.5 Multiple Ways | AA | More than one way exists to locate a page within a set, except where the page is a step in a process | multi-page site with no sitemap page, no site search and no site-wide navigation covering the route set | No | Medium |
| 3.2.1 On Focus | A | Receiving focus does not initiate a change of context | `onFocus` handlers that submit a form, navigate, open a window or a modal, or replace the page | No | High |
| 3.2.2 On Input | A | Changing a setting does not automatically change context unless the user was told first | `onChange` on a `<select>`, radio or checkbox that navigates or submits, with no submit button and no advance warning in the label or helper text | No | High |
| 3.2.3 Consistent Navigation | AA | Navigation repeated across pages occurs in the same relative order each time, unless the user changed it | one template ordering primary nav then utility nav, another reversing them; a nav item present on one template and dropped on another | Partly — rendered order needs confirmation | Medium |
| 3.2.4 Consistent Identification | AA | Components with the same function across a set are identified consistently | the same icon or function labelled "Search" on one page and "Find" on another; a cart icon named "Basket" in one template and "Cart" in the next; the same action with two different icons | No | Medium |
| 3.2.6 Consistent Help (new in 2.2) | A | Help mechanisms repeated across pages occur in the same order relative to other page content | a contact link, phone number, chat launcher, help or FAQ link present on some templates, moved on others, or dropped entirely | Partly — rendered order needs confirmation | Medium |

**The "in context" rule for 2.4.4, stated exactly.** Programmatically determined link context is what assistive technology can reach from the link: the enclosing sentence, paragraph, list item, table cell or table header, plus an `aria-label`, `aria-labelledby` or `aria-describedby` on the link itself. A "Read more" link at the end of a paragraph that names the article **passes**, because the paragraph is context. The same link in a bare grid of identical "Read more" cells, where the heading is not an ancestor and is not referenced, **fails**. Quote the ancestor you checked, not just the link.

**2.4.1 has two independent satisfiers.** Either a skip link or a landmark structure meets the criterion. Say so in every finding: the failure shape is "no skip link **and** no landmarks", never "no skip link". A page with `<header>`, `<nav>`, `<main>` and `<footer>` and no skip link is a Pass under 2.4.1.

**2.4.5's exception** is a page that is the result of, or a step in, a process. A checkout step, a wizard page and a payment confirmation are out of scope; the product page that led into them is not.

### Evidence required

A finding needs an observation and a criterion. The observation is a quoted element at `file:line` (source mode) or URL plus selector with the rendered HTML (crawl mode), or a runner rule id with its node. Cross-page criteria need two quoted surfaces.

**Source mode, cheapest first:**

1. `Read` the root layout and each template for landmarks (`<main`, `<nav`, `<header`, `<footer`, `<aside`, or their ARIA roles) and for a skip link. Where a skip link exists, resolve its `href` to a real element and check that the element is focusable or carries `tabindex="-1"` (2.4.1).
2. `Glob` the route tree and `Read` each route plus its parent layouts for the resolved `<title>`. Title cascade is real: a child's title cannot be judged without the parent template. Group routes by exact resolved string (2.4.2).
3. `Grep` link text for the generic set: `click here`, `read more`, `learn more`, `more`, `details`, `here`, `link`. For each hit, `Read` the enclosing block and record whether the sentence, list item, table cell, `aria-label` or `aria-describedby` supplies the purpose (2.4.4).
4. Inventory the ways to reach a page: a sitemap route, a site search component, and the site-wide nav's coverage of the route set (2.4.5).
5. `Grep` for `onFocus`, `onfocus`, `addEventListener\(['"]focus` and read each handler for a navigation, submit, `window.open` or modal call (3.2.1).
6. `Grep` for `onChange` / `onchange` on `<select>`, radio and checkbox elements, and read each for `location.href`, `router.push`, `form.submit()` or a route change. Record whether a submit button exists and whether the label warns (3.2.2).
7. Compare the nav block across at least two templates: the order of nav regions and the set of items in each (3.2.3).
8. Build a table of repeated functions and the label each template gives them: search, cart, account, menu, close, help (3.2.4).
9. Locate the help mechanism on each template — contact details, contact form, chat launcher, self-help or FAQ link, automated assistant — and record its position relative to the surrounding page content (3.2.6).

**Crawl mode:**

1. `Fetch` each page in the test scope. Quote the `<title>` verbatim per URL and bucket by exact string (2.4.2).
2. Quote the first focusable element of the served markup and the landmark inventory (2.4.1).
3. Quote the nav block and the help mechanism from at least two URLs and compare their serialized order (3.2.3, 3.2.6).
4. Quote each generic link with its selector and its enclosing block (2.4.4).

**Caveat for the cross-page criteria.** Serialized source order is a good proxy for "the same order relative to other page content", but CSS ordering (`order`, `grid-area`, absolute positioning) can move a rendered block away from its source position. Say which you compared, and mark Confidence Medium when only the source order was read.

**Caveat for client-set titles.** A single-page shell that sets `document.title` after hydration will not show its real title in a plain fetch. Note the limit rather than reporting a missing title, and Skip with `client-set title not verifiable without a JS-rendering fetch` when that is the situation.

**Runtime checks (need a human or a runner; the bundle ships neither):**

1. Tab from the top of each page and confirm the bypass mechanism is reachable first and actually moves focus.
2. Confirm no focus event changes context, by tabbing through every control.
3. Change every `<select>` with the keyboard and record whether context changed.
4. Compare the rendered position of the nav and the help mechanism across templates.

If none is available: `Skip — keyboard bypass walk requires a human or runner; not run`, `Skip — rendered navigation order requires a human or runner; not run`, and report only the static findings.

### Forbidden claims

- "The site is hard to navigate." That is not a criterion. Name the row and the element, or Skip.
- "There is no skip link." True but insufficient. The criterion is satisfied by landmarks too — report "no skip link and no landmark structure", with both sweeps quoted.
- "Link text is vague." Quote the link, quote the ancestor you checked for context, and say which context was absent. A vague link with context passes 2.4.4.
- "The page has no title." Quote the resolved title, or quote the absence after reading the parent layouts.
- "Navigation is inconsistent." Quote both templates and both orders.
- "Help is missing." 3.2.6 is about a help mechanism that **moves**, not about one that was never offered. A site with no help mechanism anywhere does not fail 3.2.6.
- Never write "compliant", "conformant" or "non-compliant" as a verdict. Write "fails SC 3.2.2 at this control" and let the reader draw the line.

### Detection

Source or rendered-DOM audit of layouts, route metadata, link text and its ancestors, navigation blocks, form controls and help entry points, across at least two templates from the representative page set.

### What to Search For

- Skip links, and their `href` targets; landmark elements and landmark roles; the first focusable element of each layout
- Resolved `<title>` per route, including parent-layout templates, and framework defaults left in place
- Generic link text: `click here`, `read more`, `learn more`, `details`, `here`, bare URLs, and the ancestor block around each
- A sitemap route, a site search component, and the nav's coverage of the route set
- `onFocus` handlers that navigate, submit, or open a window or a modal
- `onChange` on `<select>` / radio / checkbox that navigates or submits, and whether a submit button exists
- The nav block's region order in each template, and its item set
- Repeated functions and their labels across templates: search, cart, account, menu, close, help
- Contact links, phone numbers, chat launchers, help and FAQ entry points, and where each sits in each template

### Actually Fails

- **No skip link and no landmark structure** (2.4.1). Evidence: the layout source with both sweeps quoted, showing neither satisfier present.
- **Skip link that is not the first focusable element, or that points at a target which does not exist or cannot take focus** (2.4.1). Evidence: the link, the target lookup, and the elements ahead of it in the tab order.
- **Missing, empty, or repeated `<title>`** (2.4.2). Evidence: the resolved title per URL, with at least three routes quoted for a duplicate bucket.
- **Generic link with no programmatic context** (2.4.4). Evidence: the link element, the absent `aria-label` / `aria-describedby`, and the enclosing block showing no purpose in it.
- **Multi-page site with only one way to reach its pages** (2.4.5). Evidence: the route inventory plus the absence of a sitemap, a search and a nav covering the set.
- **Focus alone changes context** (3.2.1). Evidence: the `onFocus` handler and the navigation or submit it performs.
- **A `<select>` that navigates on change with no submit button and no warning** (3.2.2). Evidence: the control, the handler, and the absent submit path.
- **Navigation ordered differently across templates** (3.2.3). Evidence: both templates quoted, both orders shown.
- **The same function labelled differently across templates** (3.2.4). Evidence: both labels quoted with their pages, and the shared function named.
- **Help mechanism present on some templates and moved or dropped on others** (3.2.6). Evidence: the two templates and the two positions.

### NOT a Failure

- A page with full landmark structure and no skip link. Landmarks satisfy 2.4.1 on their own.
- A skip link that is visually hidden until focused. Hidden-until-focus is the standard pattern, not a defect.
- `tabindex="-1"` on a skip-link target. That is how the target is made focusable.
- Brand-as-suffix titles (`Pricing | Acme`) that differ per route. Distinct is what 2.4.2 asks for.
- A `Page not found` title on a 404 route. It describes the topic accurately.
- "Read more" at the end of a paragraph that names the article, or inside a list item whose text supplies the purpose. Context is part of the criterion.
- A link whose `aria-label` extends the visible text with the destination ("Read more about quarterly results"). Note that the accessible name must still contain the visible words — that is 2.5.3 and a different category.
- A single-page site, or a set of pages that are all steps in one process, with no sitemap or search. 2.4.5's own exception covers process steps.
- A `<select>` paired with a visible submit button, or one whose label says "changing this reloads the results".
- A modal opened by a **click**, not by focus. 3.2.1 is about focus alone.
- Nav items that differ because the section genuinely differs (a docs sidebar under a docs route), as long as the repeated nav keeps its relative order.
- Two different labels for two genuinely different functions.
- A site with no help mechanism at all. That may be worth saying elsewhere, but it is not a 3.2.6 failure.

### Context Check

1. Does the framework auto-emit the title, and does a parent layout's template fill it? Read the parent before flagging a child.
2. Is the route indexable and user-facing, or an internal debug page? Non-public routes still need titles for the people who use them, but weigh severity accordingly.
3. Is the link's context an ancestor the assistive technology can actually reach, or a heading that merely sits nearby in the layout? Only the former counts.
4. Is the page a step in a process? Then 2.4.5 does not apply to it.
5. Does the nav block reorder only because of a media query at a narrow width? Responsive reordering that keeps the same relative sequence is not a 3.2.3 failure; a genuinely different sequence is.
6. Is the help mechanism rendered by a third-party widget that injects itself at a different point per page? That is still the site's failure to fix.
7. Was the comparison made on source order or rendered order? Say which.
8. Is the same vague link also being judged as a conversion label? Cross-file it — call the Skill tool with "snitch-marketing" — rather than double-counting it here.
9. Is the question whether the visitor knows what to do next, rather than whether the link's purpose is programmatically determinable? Hand that half over — call the Skill tool with "snitch-ux".

### Severity

- **High** — missing, empty or duplicated page title across routes (2.4.2); focus alone changing context (3.2.1); a setting change navigating or submitting with no warning (3.2.2).
- **Medium** — no bypass mechanism at all, or a broken skip link (2.4.1); a generic link with no programmatic context (2.4.4); only one way to locate pages (2.4.5); navigation reordered across templates (3.2.3); the same function labelled two ways (3.2.4); a help mechanism that moves between templates (3.2.6).
- **Low** — a skip link present but placed after one or two non-repeated focusable elements, where a bypass path still exists through landmarks.

No Critical tier here. Every failure shape leaves a slower path to the content rather than closing it, which is what separates this category from the keyboard and forms categories.

### Fix guidance

Four fixes, cheapest first.

**1. Give the page a bypass and a name** (2.4.1, 2.4.2). Landmarks alone satisfy 2.4.1, and they cost nothing but the right element names. Add the skip link anyway: it is the fastest path for the people who need it most.

```html
<!-- First focusable element in the document -->
<a class="skip-link" href="#main">Skip to main content</a>
<header>…</header>
<nav aria-label="Primary">…</nav>
<main id="main" tabindex="-1">…</main>
<footer>…</footer>
```

```css
.skip-link { position: absolute; inset-inline-start: -9999px; }
.skip-link:focus { inset-inline-start: 0; inset-block-start: 0; }
```

Then make the title describe the page, not the product.

```tsx
// Fails 2.4.2: every route resolves to the same string
export const metadata = { title: "Acme" };
// Passes: the route's own topic, brand at the end
export const metadata = { title: "Pricing | Acme" };
```

**2. Put the purpose in the link, or in the context that reaches it** (2.4.4). Two valid fixes. Prefer rewriting the text; use the label when the design needs the short version.

```tsx
// Fails 2.4.4: twelve identical links in a card grid, no ancestor names the target
<a href={post.url}>Read more</a>

// Passes, option A: the text carries the purpose
<a href={post.url}>Read the {post.title} write-up</a>

// Passes, option B: the visible text stays, the name extends it
<a href={post.url} aria-label={`Read more about ${post.title}`}>Read more</a>
```

**3. Never change context on focus or on input** (3.2.1, 3.2.2). Both fixes are the same move: put the change behind a deliberate action.

```tsx
// Fails 3.2.2: the page navigates as soon as the value changes
<select onChange={e => router.push(e.target.value)}>…</select>

// Passes: the select sets state, a button applies it
<label htmlFor="region">Region</label>
<select id="region" value={region} onChange={e => setRegion(e.target.value)}>…</select>
<button onClick={() => router.push(region)}>Go to region</button>
```

**4. Keep the nav, the labels and the help in one place** (3.2.3, 3.2.4, 3.2.6). This is an architecture fix, not a markup fix: render the header, the nav and the help entry point from one shared layout, and let templates fill slots rather than re-declaring the chrome.

```tsx
// One layout owns the repeated regions; templates never reorder them
<SiteHeader />        {/* search, account, cart — same labels, same order, every page */}
<PrimaryNav />
<main id="main" tabindex={-1}>{children}</main>
<SiteFooter />        {/* contact and help link, same relative position, every page */}
```

Pick one word per function and use it everywhere: "Search", not "Search" here and "Find" there. Consistency is cheaper than the alternative and it is the whole of 3.2.4.

### Reference

WCAG 2.2 specification: https://www.w3.org/TR/WCAG22/

2.4.1 Bypass Blocks: https://www.w3.org/WAI/WCAG22/Understanding/bypass-blocks.html · 2.4.2 Page Titled: https://www.w3.org/WAI/WCAG22/Understanding/page-titled.html · 2.4.4 Link Purpose (In Context): https://www.w3.org/WAI/WCAG22/Understanding/link-purpose-in-context.html · 2.4.5 Multiple Ways: https://www.w3.org/WAI/WCAG22/Understanding/multiple-ways.html

3.2.1 On Focus: https://www.w3.org/WAI/WCAG22/Understanding/on-focus.html · 3.2.2 On Input: https://www.w3.org/WAI/WCAG22/Understanding/on-input.html · 3.2.3 Consistent Navigation: https://www.w3.org/WAI/WCAG22/Understanding/consistent-navigation.html · 3.2.4 Consistent Identification: https://www.w3.org/WAI/WCAG22/Understanding/consistent-identification.html · 3.2.6 Consistent Help (Level A, new in 2.2): https://www.w3.org/WAI/WCAG22/Understanding/consistent-help.html

Programmatically determined link context, defined: https://www.w3.org/TR/WCAG22/#dfn-programmatically-determined-link-context

W3C ARIA Authoring Practices, for landmark and navigation patterns: https://www.w3.org/WAI/ARIA/apg/patterns/landmarks/

HTML sectioning elements: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/main

axe-core rule descriptions, for the runner rule ids quoted alongside an element: https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md
