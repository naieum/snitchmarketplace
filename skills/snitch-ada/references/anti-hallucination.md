# Anti-Hallucination Rules

The evidence contract for snitch-ada. Load this file at audit start and apply it through every
category and the final pass before the report saves. Violating any rule invalidates the audit.

This skill makes claims about conformance and about the law. Both are checkable by someone with more
authority than the audit has. So every claim here is traceable, hedged where it moves, and marked
Skip where it was not run.

## Rule 1: No finding without evidence

- Call Read or Grep (source mode) or Fetch (crawl mode) before claiming any finding.
- Quote the exact element: the markup, the CSS rule, the catalog entry, the handler.
- Cite `file_path:line_number` (source) or `URL` + CSS-selector path (crawl).
- If the source, rendered HTML or response does not show it, it is not a finding.
- A negative claim (missing, absent, none found) carries three parts: the search that ran with its
  pattern visible, the result count, and the scope it covered. `Verified via grep -nE "<pattern>"
  over src/**/*.tsx returning 0 matches across 38 route files.` A negative claim with no scope is
  not evidence; it is a guess with a citation shape.

## Rule 2: Every finding names its rule

A finding carries an observation **and** a rule. The rule is one of:

- a WCAG 2.2 success criterion row from the category's own rule table (criterion-typed categories);
- a named law, regulation or standard (compliance-typed);
- a named pattern from the category's rule table (i18n-readiness-typed).

A check with no row in a rule table is a **Skip**, never a finding under a borrowed criterion. If an
observation looks real but no row in the selected category covers it, place it by who owns it, per
SKILL.md's SCOPE RULE: a **live category of this skill** takes `Skip — <observation>; owned by Cat
NN, not run` in the skipped-checks list; a **sibling skill** takes a hand-off naming that skill; and
only an observation **no category and no sibling owns** is reported as an uncategorized observation
saying which category would need a **new row**. A live owner is a routing question, not a gap in the
map — do not report it as one. Never invent a criterion number, and never stretch a criterion to
cover something it does not say.

Every WCAG 2.2 Level A and AA criterion is owned by exactly one category. `wcag-criterion-map.md`
is the mapping. If a criterion appears in no rule table, that is a defect in the map, reported as
such — not a licence to file the finding somewhere convenient.

## Rule 3: Never write a verdict

**Forbidden, in every output: "compliant", "conformant", "non-compliant", "WCAG 2.2 AA certified",
"accessible", "meets the ADA", "passes the EAA", "ADA-compliant".** Conformance is a legal
determination that follows a complete audit including the manual passes this bundle cannot perform.
A partial static scan cannot produce it.

Write what you proved:

| Do not write | Write instead |
|---|---|
| "The site is not WCAG 2.2 AA compliant." | "Fails SC 1.4.3 at 6 elements and SC 3.3.2 at 4 inputs; 18 criteria could not be checked statically and are listed as Skip." |
| "This page is accessible." | "The 9 criteria checked in this category produced no findings; the evidence for each is listed. 46 criteria were outside this category." |
| "You are exposed to ADA litigation." | "Level A failures at 1.1.1, 2.1.1 and 3.3.2 are the criteria most often cited in web accessibility demand letters; the sector and market answers from STEP 0.5 are recorded above." |
| "Adding an accessibility statement makes you compliant." | "A statement and a feedback channel are obligations under the regimes listed in legal-landscape.md; neither is a substitute for conformance." |

The same rule applies to i18n: never write "fully localized" or "translation complete". Write "42
keys are absent from `locales/fr.json` and 7 carry placeholder mismatches".

## Rule 4: Volatile facts get hedges

Every legal date, compliance deadline, population threshold, standard version and enforcement date
comes from `legal-landscape.md`, and every one of them carries that file's
`Facts verified: <date> against <URL>` line into the report. A fact that reference could not verify
is written with `(unverified — confirm at <URL>)` and never asserted flat.

Rules that move are rewritten, extended and litigated. A date stated without its verification line
is a fabrication risk with a citation attached, which is worse than no citation.

Never predict a litigation outcome, a settlement amount, a regulator's decision, or whether a
specific entity is in scope of a specific regime. State the regime, the observed pattern, and the
inputs from STEP 0.5. The reader's counsel draws the line.

## Rule 5: Three outcomes only

Every check produces exactly one of:

- **Finding**, with full evidence in the Finding Format.
- **Pass**, with at least one quoted line proving the check ran. `Pass — every one of the 14 `<img>`
  elements in the page set carries a non-empty `alt` or `alt=""` with `aria-hidden="true"`; verified
  via grep across `src/components/**`.` A bare "Pass" is invalid.
- **Skip**, with the reason and what would unblock it. `Skip — SC 1.2.4 Captions (Live): no live
  media found in the page set; would run if a live stream or webinar embed existed.`

**Finding nothing is two different outcomes, and the difference is whether the subject exists.** A check whose subject is present in the page set and whose failing shape is absent is a **Pass**, carrying the search and the count: `Pass — 14 `<img>` elements found, all 14 carry a text alternative`. A check whose subject does not exist in the page set at all is a **Skip**, worded `Skip — not applicable: no <subject> in the page set`, plus what was searched to establish that. No motion handlers, no video, no forms, no catalogs: none of those is a Pass. A Pass says a rule held on something; a Skip says there was nothing for it to hold on. Recording an absent subject as a Pass is how a report comes to claim coverage it never had.

"Partially audited", "spot-checked but unsure", "couldn't fully verify" are not outcomes. If the
audit ran out of scope or budget, mark the category **Skip** with reason `abbreviated for scope;
re-run this category for full coverage`.

## Rule 6: Runtime checks Skip, they never infer

Many WCAG criteria cannot be settled from static source. The rule tables mark those rows
runtime-only. When no runner and no human tester is available, emit:

```
Skip — <check> requires a human or runner; not run
```

verbatim, with the criterion number and what would unblock it. Examples of the wording in use:

- `Skip — keyboard walk requires a human or runner; not run. Unblock: Tab through the page set with a visible focus ring and record order, traps and modal focus.`
- `Skip — screen-reader announcement order requires a human or runner; not run. Unblock: walk the page set with a screen reader and record what is announced.`
- `Skip — 2.4.11 Focus Not Obscured requires a human or runner; not run. Unblock: focus each control with the sticky header and any chat widget present, at the page set's widths.`

Never assert live behavior nobody observed. "Screen-reader inaccessible", inferred from source, is a
Rule 1 violation dressed as a finding.

**Automated-runner output is triaged, never pasted.** axe-core, Pa11y and Lighthouse carry a real
false-positive rate and each violation still needs the criterion and the offending node. Read each
violation, confirm it against the source or DOM, then file it as a finding with the runner rule id
as corroborating evidence. Pasting a runner's JSON into the report is not an audit.

## Rule 7: Severity is single-valued

One tier per finding. If a finding could be either of two adjacent tiers, escalate to the higher
one. If it could be two non-adjacent tiers depending on which sub-case applies, split it into two
findings, each with its own tier and evidence. If you cannot pick a tier from the evidence alone,
the evidence is not tight enough yet.

## Rule 8: The redaction gate

Always on. No setting turns it off. Before the report saves, every one of these is stripped:

- **Personal data** in fixtures, seed data or rendered content: emails, phone numbers, names,
  addresses that look real become `<redacted>`. Obviously synthetic data (`jane@example.com`,
  `555-0100`) stays, because it is evidence about the fixture, not about a person.
- **Tracking and account identifiers**: analytics, tag-manager, pixel and workspace IDs become X's
  of the same shape.
- **Live secrets**: API keys, tokens and signing material found while reading source are replaced
  with X's and flagged for a security review rather than quoted.

Describe the location and the pattern instead of the value: `line 42: analytics measurement ID
hardcoded in a component prop rather than an environment variable`.

Locale catalogs are a common source of real personal data in example strings. Read them with this
rule active.

## Rule 9: Never auto-fix

- Never edit, patch or modify a file during the audit or while generating the report.
- Never apply a fix — even an obvious missing `alt` — before the complete report is displayed.
- Offer fixes only in the post-scan menu, and apply one only on explicit selection and
  confirmation.
- **Any fix touching a color value or a brand token takes per-finding confirmation even in batch.**
  A contrast fix rewrites the brand's palette. Show the before value, the after value and both
  ratios, and wait.
- If the user says "audit and fix everything", complete the full audit and report first, then show
  the menu. Auditing and fixing are always two phases.

## Rule 10: No sycophancy

The report's authority is its evidence. Forbidden across findings, passes, chat updates and menu
copy: "best-in-class", "textbook", "strong foundation", "great job", "solid", "impressive", and
every evaluative adjective describing the reader's choices. Pass evidence states what is configured
and where; the reader judges quality. Fix prose opens with the action, not a framing sentence.

Findings and passes get equal depth. A "what is working" list is facts about what is configured, not
adjectives about how well.

---

## False-positive prevention

### Framework and library auto-handling

Read the surrounding context before reporting: the layout, the route head builder, the component
library, the framework config. A pattern that looks broken in one file is often handled elsewhere.
Common mitigations that suppress a finding when confirmed:

- A framework that emits the document `lang` from the active route or locale config, so the
  per-page template carries no `lang` attribute and is still correct. Confirm by reading the
  root document or layout, not by assuming.
- A component library whose `Button`, `IconButton` or `Dialog` already applies the accessible name,
  the role, the focus trap and the Escape handler. Read the component's implementation or its
  declared props before filing 4.1.2 or 2.1.2 against every call site.
- A design-system token layer where the color in the component is a variable and the resolved value
  lives in the theme. Resolve it before computing a ratio.
- A framework router that moves focus on navigation, or a layout that renders the skip link once.
- An i18n library that lints for missing catalog keys at build time, or fails the build on them.

When a mitigation is confirmed, suppress the finding and record it in the passes with the evidence
of the mitigation. When it is plausible but unconfirmed, downgrade confidence to Medium and say what
would confirm it.

### Two-pass verification

After a pattern match, read the surrounding context a second time before writing the finding: the
parent component, the layout, the theme, the config. Then re-read the quoted snippet against the
claim. If the snippet does not show what the claim says, retract.

### Auto-exclude paths (source mode)

Do not report from `node_modules/**`, `.git/**`, `dist/**`, `build/**`, `.next/**`, `.astro/**`,
`.output/**`, `coverage/**`, `__tests__/**`, `*.test.*`, `*.spec.*`, `*.stories.*`, `mocks/**`.
Report from `*.example.*` and `*.template.*` only as "verify this is not shipping to production".

Storybook stories are the common false-positive source here: a story that renders a bare unlabeled
control to demonstrate a state is not a shipped barrier.

### Confidence threshold

Assign High, Medium or Low confidence to every finding.

- **High** — the element is quoted, the rule is unambiguous, and no mitigation is plausible.
- **Medium** — the element is quoted but the resolved value depends on something not read (the
  cascade, a theme token, a runtime behavior), or the mitigation is plausible but unconfirmed.
- **Low** — the pattern matched but the context is uncertain. Low-confidence findings go in a
  "Needs review" section, never in the main findings list, and never carry a Critical tier.

### Inline ignore comments

Recognize and suppress on:

```
<!-- snitch-ada-ignore: 1.4.3 brand wordmark, decorative, not text content -->
{/* snitch-ada-ignore: 04 palette locked by contract until Q2 */}
/* snitch-ada-ignore: 2.5.8 inline link, natural text size */
```

The form is `snitch-ada-ignore: <rule> <reason>`, where `<rule>` is a criterion number, a category
ID, or a category slug, and `<reason>` is free text. **A reason is required** — an ignore with no
reason is itself reported, as a suppression with no justification. The comment suppresses matches on
the same line and the line following it. Every suppression is listed in the report's Suppressed
section with its rule and its reason, so a reader can see what was silenced and why.

### `.snitch-ada-ignore` file

At audit start, read `.snitch-ada-ignore` from the working directory if present. One entry per line;
`#` starts a comment. Entries:

```
# path glob : rule : reason
src/legacy/**            : 04    : legacy admin theme, scheduled for removal 2026-Q4
src/vendor/player.tsx:88 : 1.2.2 : third-party player, captions configured in the vendor console
https://example.com/status : 1.4.1 : status page is a third-party embed
locales/pseudo.json      : 21    : pseudo-locale fixture, not shipped
```

A path glob or `path:line` matches in source mode; a URL prefix matches in crawl mode. The rule
field is a criterion number, a category ID or a category slug, or `*` for the whole file. The reason
field is required. Report the suppressed count and list every entry that actually matched something
this run; an entry that matched nothing is reported as stale.

### SPA hydration auto-skip

On a hydration-heavy stack a plain Fetch returns the shell, not the page. Reporting a missing
element there is a Rule 1 violation by definition.

**Signals, read from the initial HTML with no JS executed:** an empty mount element (`<div id="root">`,
`<div id="app">`) with a module script and no body content; a framework hydration data script;
framework-specific static asset paths in the `<link>` and `<script>` tags; framework-specific data
attributes on the root element.

**Trigger:** SPA signals present **and** the content the category checks is absent from the initial
HTML. Categories that auto-skip under that condition: 01 (fewer than 3 `<img>` in the initial body),
03 (no heading elements in the initial body), 04 (no rendered text nodes to pair with a background),
06, 07, 09, 10, 11 (no form or interactive markup in the initial body), 19 and 20 (no rendered
locale switcher or direction attribute).

**Exception:** when the app emits the relevant content into the served HTML — a server-rendered
route, a framework that resolves metadata and markup on the server, a static build — the category
proceeds normally with full evidence. The auto-skip fires only when the initial HTML genuinely lacks
what the category checks.

**Skip reason text, use verbatim:**

```
crawl mode without JS rendering can't verify post-hydration DOM; re-run in source mode (point the audit at the repo) or with a JS-rendering crawler (Playwright / headless Chrome) for full coverage.
```

For a closed or hosted builder, where the user has no source to point at, use the hosted variant in
`smart-detection.md` instead — never tell someone to switch to source mode they do not have.

Surface a one-line note in the report's metadata block: `Stack detected: <framework>, client-hydrated.
Categories X, Y, Z auto-skipped pending a JS-rendered crawl.`

### The CSS-cascade caveat

**Fetch and source reads return declarations, not the resolved cascade.** The computed color, size,
spacing or ratio can differ from the declaration you read: a later rule, a media query, a theme
token, a container query, a user-agent default or an inline style may win.

Every CSS-derived finding — contrast (1.4.3, 1.4.11), target size (2.5.8), reflow and spacing
(1.4.10, 1.4.12), focus visibility (2.4.7) — carries this in its evidence when the cascade is
ambiguous:

```
Declared value read from <file:line>; the resolved cascade was not computed. Confirm the rendered
value in devtools before treating this as final.
```

Confidence on such a finding is capped at Medium unless the resolved value was actually observed.
A ratio is **never** asserted without both color values it was computed from, and never computed
from a variable name whose value was not resolved.
