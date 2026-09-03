## CATEGORY 14: Accessibility statement, feedback channel and overlay widgets

Two obligations and one risk pattern. The obligations are what several regimes ask a site to publish about its own accessibility: a **statement** that names the standard, the scope and the known gaps, and a **feedback channel** a person can use to report a barrier and expect an answer. The risk pattern is the **accessibility overlay widget** — a third-party script that injects a floating toolbar and offers to make the site accessible from the outside.

The statement is the cheapest honest thing a site can publish and the easiest thing to get wrong. A statement that overclaims is worse than no statement, because it converts a technical failure into a contradicted claim. A feedback channel that goes nowhere is the same defect in a different place. Both are audited here against what they say and whether they work, never against how the audit wishes they read.

**Boundary.** This category judges the statement and the feedback channel as **published obligations**: do they exist, do they say what the regime asks, does the channel reach a human. Whether the statement is findable at the moment a user needs it, on their decision path, is the sibling's judge — call the Skill tool with "snitch-ux". Whether the statement works as a trust signal that moves conversion is the other sibling's — call the Skill tool with "snitch-marketing". Inside this skill: Cat 13 records only whether a statement and a channel exist and reads that into the exposure; the grading of both is here. A statement page's own criterion failures (unlabeled feedback form, contrast, heading order) are findings in 01–12 against their criteria, not here.

### Pre-flight

Runs whenever any regime in Cat 13's rule table binds the surface, and whenever a statement or an overlay is found regardless of regime — an overlay is auditable on any site, and a published statement is auditable the moment it makes a claim.

Skip with `Skip — no bound regime, no statement found and no overlay detected` only when all three are true. A private, credential-gated internal tool with no public surface Skips with that reason.

Do not interview the user for the statement's contents. Read what is published; absence is a finding with the sweep quoted, never a question.

### Rule table

One row per obligation or pattern. A finding names its row.

| Obligation | Who it binds | What must hold | Static signal | Facts verified | Severity |
|---|---|---|---|---|---|
| (a1) A statement exists | EU Web Accessibility Directive and UK PSBAR bodies explicitly; every other site as good practice | An accessibility statement is published at a stable URL | A route, page file or nav entry matching `accessibility` / `a11y`; in crawl mode a footer link followed to a real page | 2026-09-03 · digital-strategy.ec.europa.eu, gov.uk | High (bound regime) / Medium (unbound) |
| (a2) It is reachable | as above | Reachable from every page footer, or from a stable, linked URL that navigation reaches in one step from any page | The footer partial or layout component contains the link; every template in the representative set includes that partial | 2026-09-03 · gov.uk | Medium |
| (a3) It names the standard and level | as above | The statement names the standard and level targeted (for example WCAG 2.2 Level AA) and states its status against it — the guidance's three-way wording: fully, partially, or not | The statement text contains a standard name **and** a level **and** a status word | 2026-09-03 · gov.uk | Medium |
| (a4) It states its scope | as above | Which sites, subdomains, apps and documents the statement covers | The statement names the surfaces; a statement with no scope sentence covers nothing checkably | 2026-09-03 · gov.uk | Medium |
| (a5) It lists known limitations | EU WAD and PSBAR bodies | The parts that do not meet the standard, why, and how to get an alternative to non-accessible content | A "known issues", "non-accessible content" or equivalent section naming specific content, not a generic apology | 2026-09-03 · gov.uk, digital-strategy.ec.europa.eu | Medium (missing) / High (present but contradicted by this audit's findings) |
| (a6) It is dated | as above | A preparation or last-review date, reviewed at least annually per the UK guidance | A date string in the statement; compare to today | 2026-09-03 · gov.uk | Low (absent) / Medium (older than a year on a bound public-sector site) |
| (b1) A feedback channel works | EU WAD and PSBAR bodies explicitly; EAA service providers as part of the information duty | A reachable way to report a barrier: an email, a form or a phone number, plus a stated response commitment | A `mailto:`, a form with an action, or a `tel:` link inside the statement; a form whose fields are labelled and whose action is not empty | 2026-09-03 · digital-strategy.ec.europa.eu, gov.uk | High (no channel on a bound site) / Medium (channel present, no response commitment) |
| (b2) The enforcement path is named | UK PSBAR bodies | The statement links onward for a person unhappy with the response; Government Digital Service monitors and the Equality and Human Rights Commission enforces | The statement contains an onward link in its complaints section | 2026-09-03 · gov.uk | Medium |
| (b3) EAA service information | EAA in-scope service providers | Information needed to assess how the service meets the accessibility requirements is made available; recital 81 points at the general terms and conditions or an equivalent document | The terms page, the statement, or a linked document carries that information | 2026-09-03 · eur-lex.europa.eu (recital 81 only) — Article 13 and Annex V **(unverified — confirm at https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32019L0882)** | Medium |
| (c1) An overlay widget is present | any site | Detected by shape and reported with the script quoted; never named as a product | A `<script src>` from a third-party host that injects a fixed-position toolbar; a `data-`attribute-configured widget element; a documented CSS class prefix the injected toolbar uses | n/a — pattern, not a legal fact | Medium |
| (c2) The overlay is presented as the accessibility solution | any site | The statement, marketing copy or the widget's own label does not present the overlay as making the site meet a standard | Statement or copy that names the widget as the accessibility measure; a badge or claim beside the toolbar | n/a — pattern, not a legal fact | High |

**Facts verified: 2026-09-03.** Statement and feedback obligations verified at https://www.gov.uk/guidance/make-your-website-or-app-accessible-and-publish-an-accessibility-statement (the four elements the guidance requires: status against the standard; which parts do not meet it and why; how people can get alternatives to inaccessible content; how to contact you to report problems, with an onward link if they are unhappy with the response — reviewed at least annually) and https://digital-strategy.ec.europa.eu/en/policies/web-accessibility (a statement per website and mobile app "stating non-accessible content and alternatives as well as contacts", plus "a feedback mechanism so users can flag accessibility problems"). The UK guidance page names **WCAG 2.2 AA** and states that the Government Digital Service monitors and the Equality and Human Rights Commission enforces. The EAA service-information duty is verified only to recital 81 — "information necessary to assess conformity with accessibility requirements should be provided in general terms and conditions, or equivalent document" — with Article 13 and Annex V unverified.

Rows (c1) and (c2) are **patterns, not legal requirements**. No regime in Cat 13's table requires or forbids an overlay. They are audited because of what they do to the markup and to assistive technology, and because presenting one as the remedy is a claim like any other.

### Evidence required

**Source mode:**

1. `Grep` route, page and layout files for `accessibility`, `a11y`, `accessibility-statement` to find the statement's file. Read it in full.
2. `Grep` the footer partial or layout component for the statement link, then confirm every template in the representative page set renders that partial. A statement linked from one page only fails (a2).
3. Read the statement against (a3) through (a6): standard name, level, status word, scope sentence, a named-limitations section, a date.
4. Read the feedback path: the `mailto:`, the `tel:`, or the form. For a form, read its action, its method and its field labels — a feedback form whose own fields are unlabeled fails 3.3.2 in Cat 10 **and** fails (b1) here, because the channel does not work for the people it exists for.
5. `Grep` the statement's named limitations against this audit's findings. A limitations list that omits a Critical or High failure this audit found is (a5) at High.
6. `Grep` for the overlay shape: `<script` tags whose `src` host is not the site's own and whose surrounding attributes are `data-`configured; any script that documents a class prefix for an injected toolbar; inline initialisation objects that set toolbar position, icon or language. Quote the tag.
7. `Grep` the statement and marketing copy for the overlay being named as the accessibility measure, and for any badge, seal or certification claim beside it.

**Crawl mode:**

1. Fetch each page in the representative set and look for the statement link in the footer. Follow it; fetch the statement page.
2. Apply steps 3 through 5 above to the fetched statement text, citing URL + selector.
3. Test the channel's shape, not its inbox: an `href` that is a real `mailto:` / `tel:` / form action. Never send a message to it, and never assert that a reply would arrive.
4. Read the fetched HTML `<head>` and end of `<body>` for third-party script tags matching the overlay shape, and the DOM for a fixed-position injected toolbar container.

Cascade and hydration caveat: a footer or an overlay injected after hydration will not be in a plain fetch of a hydration-heavy page. Absence in that case is `Skip — footer and injected scripts render client-side; presence not determined`, with what would unblock it (a rendered DOM from a browser runner). Never report an absence that the fetch could not have seen.

### Forbidden claims

- **"The site is compliant / conformant / non-compliant with the statement obligations."** Report the elements present and the elements missing, each quoted. No verdict.
- **"Product X does not work" / naming any overlay vendor.** Describe the shape: a third-party script that injects a fixed-position toolbar. Quote the tag. Never name the product, the company, or a competitor to it, and never characterise a specific product's behaviour.
- **"The overlay causes failures."** Say what is observable: an overlay does not change the underlying markup, so the criterion failures in this report are unaffected by it. Do not attribute a specific runtime break to it without observing that break.
- **"This overlay will be cited against you."** No prediction. The permitted, hedged sentence is that overlay widgets have been raised in accessibility demand letters and complaints as a reported pattern, and that this skill does not verify litigation records.
- **"The feedback channel does not work."** Unless a send was attempted and failed, the claim is about the channel's shape. Write `no reachable channel found in the statement` or `the form's action attribute is empty` with the quoted markup.
- **"The statement is out of date, so the site regressed."** A stale date is a stale date. Quote it and say what the guidance asks for.
- **A date or obligation with no verification line.** Every regime fact here carries `Facts verified: <date> against <URL>` or `(unverified — confirm at <URL>)`.
- **Any claim that a statement provides legal protection.** It does not, and saying so is advice.

### Detection

Source or crawl read of the statement page, the footer link across the representative page set, the feedback path's markup, and third-party script tags matching the overlay shape. Cross-read of the statement's named limitations against this report's own findings.

### What to Search For

- Route, page or nav entries matching `accessibility`, `a11y`, `accessibility-statement`
- The footer partial or layout component, and whether every template renders it
- In the statement text: a standard name, a level, a status word, a scope sentence, a named-limitations section, a preparation or review date
- `mailto:`, `tel:` and form `action` inside the statement; the form's field labels and its response commitment
- An onward link for a person unhappy with the response (UK)
- The terms and conditions page, for EAA service information
- `<script src>` tags pointing at a third-party host near the top of `<head>` or the end of `<body>`, with sibling `data-` attributes configuring a widget
- Inline widget initialisation objects setting a toolbar's position, icon, colour or language
- A CSS class prefix used by an injected fixed-position container, and any `position: fixed` container the site's own CSS does not define
- Badges, seals or certification claims near the widget or in the footer
- Statement or marketing copy naming the widget as the site's accessibility measure

### Actually Fails

- **No statement on a site a public-sector regime binds.** Evidence: the route and footer sweep that found nothing, the templates checked, and the regime row from Cat 13.
- **A statement reachable from one page only.** Evidence: the templates that render the footer partial and the ones that do not, at `file:line`.
- **A statement that names no standard or no level.** Evidence: the quoted statement text and what is absent. A statement that says "we care about accessibility" and nothing else is this finding.
- **A statement with no scope.** Evidence: the quoted text. Without a scope sentence the reader cannot tell whether the app, the subdomain or the PDFs are covered.
- **A statement whose limitations list omits a failure this audit found at Critical or High.** Evidence: the quoted limitations section and the omitted finding with its citation. This is the overclaim case and it is High.
- **No feedback channel in the statement.** Evidence: the quoted statement with no `mailto:`, `tel:` or form action.
- **A feedback form that cannot be used by the people it is for** — empty action, unlabeled fields, or a required field with no accessible name. Evidence: the form markup; cross-file the criterion failure to Cat 10 rather than double-counting it.
- **No response commitment.** Evidence: the quoted channel with no statement of when a reply comes.
- **No enforcement onward link on a UK public sector statement.** Evidence: the quoted complaints section.
- **An undated statement, or one older than a year on a bound public-sector site.** Evidence: the quoted date or its absence.
- **An overlay widget present.** Evidence: the quoted `<script>` tag with its third-party host and the widget configuration attributes, plus the injected container if the DOM was read. Reported with the hedged sentence about what an overlay does and does not change.
- **The overlay presented as the accessibility solution.** Evidence: the quoted statement or copy naming it, alongside the criterion failures this audit found in the same markup. High, because it is a claim the findings contradict.

### NOT a Failure

- A statement that honestly reports known failures. That is the statement working. Do not turn an honest limitations list into a finding; the underlying criterion failures are already findings in 01–12.
- A statement that targets a level the site has not reached yet, and says so. Naming a target and a gap is what the guidance asks for.
- A statement on an unbound site that is thinner than the public-sector model. Report the gaps at Medium at most; the model is a public-sector obligation, not a universal one.
- A feedback channel that is a form rather than an email, or a phone number rather than either. Any reachable channel satisfies (b1).
- A third-party script that is not an overlay — analytics, consent management, chat, a font loader, a tag manager. Match the shape: injected fixed-position toolbar, widget configuration attributes, a documented class prefix. A `<script src>` from a CDN is not evidence of an overlay on its own.
- A site's **own** accessibility controls built into the product — a theme toggle, a text-size control, a reduced-motion switch the site implements itself. Those are product features, not an overlay, and they do not carry row (c1).
- An overlay on a site whose statement does not claim it fixes anything. Row (c1) at Medium stands, row (c2) does not.
- A statement page with its own criterion failures. Those are findings in 01–12 against their criteria. Cross-reference, do not re-score.

### Context Check

1. Does a regime from Cat 13 actually bind this site? The statement rows are High on a bound site and Medium on an unbound one.
2. Was the statement found, or did the sweep run against a hydration-heavy stack that a plain fetch cannot see? Skip beats a false absence.
3. Does the statement's limitations list match what this audit found? An omission at Critical or High is the finding that matters most in this category.
4. Is the feedback path's shape being reported, or is a claim being made about whether anyone answers it? Only the shape is observable.
5. Is the overlay being described by shape, with its tag quoted, or is a product being named or characterised? Never name it.
6. Is the overlay being blamed for failures that were found in the underlying markup? The markup findings stand on their own evidence.
7. Does the site claim a certification, a seal, or a level anywhere? Check it against the findings and against the Claim inventory in `BLUEPRINT.md`, and cite both lines.
8. Would the fix here contradict a recorded `Decision` in `BLUEPRINT.md`? Then it is a Finding capped at Medium whose Fix is "revisit the decision or accept the trade-off".

### Severity

One tier per finding.

- **High** — no statement on a site a public-sector regime binds; a limitations list that omits a Critical or High failure this audit found; no feedback channel on a bound site; an overlay presented as the site's accessibility measure.
- **Medium** — statement present but missing the standard, the level, the scope, or the limitations section; reachable from one page only; no response commitment; no enforcement onward link on a UK public sector statement; a date older than a year on a bound public-sector site; EAA service information absent on an in-scope service; an overlay present and not overclaimed.
- **Low** — an undated statement on an unbound site; a thin statement on an unbound site; a channel that works but is buried inside the statement's last paragraph.
- **Pass** — a statement carrying all six elements with a working channel, recorded with the quoted text that proves each element; no overlay detected, recorded with the sweep that looked for one.

Critical is not used in this category. A missing statement blocks nobody by itself; the barriers it should have described are already Critical where they are found.

### Fix guidance

Write the statement last, not first. It is a report on the product, and a report written before the work is a claim waiting to be contradicted.

**1. The statement, with the six elements it actually needs.**

```markdown
<!-- Before: the whole statement -->
# Accessibility
We are committed to accessibility and are always working to improve.
```

That names no standard, no scope, no gap, no channel and no date, so nothing in it can be checked, and the one thing it does communicate — "we handled it" — is the thing it has not shown.

```markdown
<!-- After -->
# Accessibility statement

**Scope.** This statement covers example.com, app.example.com, and the PDFs linked from
our support pages. It does not cover our status page, which a third party hosts.

**Standard.** We target WCAG 2.2 Level AA. We meet it in part. The gaps below are the
ones we know about, from an audit dated 2026-08-14.

**What does not meet it yet.**
- The invoice table on /billing has no row headers, so a screen reader reads the cells
  without their labels. Fix scheduled for Q4. If you need an invoice in another format,
  ask us and we will send one.
- Four archived PDFs under /legal/ are scans with no text layer. HTML versions are
  linked beside each one.

**Report a barrier.** Email access@example.com or call +1 555 0100. We reply within
two working days.

**Prepared** 2026-08-14. **Last reviewed** 2026-08-14. We review this at least once a year.
```

Each element is checkable, and the parts that are not fixed yet carry an alternative route rather than an apology. A UK public sector statement adds the onward link for a person unhappy with the response; an EU public sector statement carries the same shape.

**2. The feedback channel, made to work.** A channel is not a `mailto:` you never read. Route it somewhere staffed, commit to a response time you can hold, and make the form itself usable:

```html
<!-- Before: a channel the people who need it cannot use -->
<form>
  <input type="text" placeholder="Your email">
  <textarea placeholder="What went wrong?"></textarea>
  <div onclick="send()">Send</div>
</form>

<!-- After -->
<form action="/accessibility-feedback" method="post">
  <label for="af-email">Your email</label>
  <input id="af-email" type="email" name="email" autocomplete="email" required>

  <label for="af-detail">What went wrong, and where?</label>
  <textarea id="af-detail" name="detail" required></textarea>

  <button type="submit">Send</button>
</form>
```

**3. The overlay.** The plain version: an overlay runs on top of the page and does not change the markup underneath it, so every criterion failure in this report is still there after it loads. It can also interact badly with the assistive technology a person already runs, because two things are then trying to describe the same page. Overlay widgets have been raised in accessibility demand letters and complaints as a reported pattern; this skill does not verify litigation records, so take that as context, not as a finding.

What to do with it is the owner's call, and there are two honest paths. Keep it and stop claiming anything for it — remove the badge, remove the sentence in the statement that names it as the accessibility measure, and fix the markup findings on their own schedule. Or remove it and put the same budget into the shared components the findings point at, which is where one change closes thirty findings. What is not available is the third path, where the widget stands in for the work.

Never write the statement to match the overlay's claims. Write it to match the audit.

### Reference

UK guidance on publishing an accessibility statement: https://www.gov.uk/guidance/make-your-website-or-app-accessible-and-publish-an-accessibility-statement · UK public sector accessibility requirements, monitoring and enforcement: https://www.gov.uk/guidance/accessibility-requirements-for-public-sector-websites-and-apps

EU Web Accessibility Directive, statement and feedback obligations: https://digital-strategy.ec.europa.eu/en/policies/web-accessibility

European Accessibility Act, Directive (EU) 2019/882: https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32019L0882

W3C guidance on writing an accessibility statement: https://www.w3.org/WAI/planning/statements/

WCAG 2.2: https://www.w3.org/TR/WCAG22/
