## CATEGORY 16: User-facing strings live in message catalogs, not code

The first question of internationalization readiness is not "is the translation good". It is "can this sentence be translated at all". A string typed directly into a component, a template or a handler is invisible to every translation workflow that exists: it is not in the catalog, no translator will ever see it, and no locale can override it. The page can be fully localized around it and it will still render in the source language forever.

This category audits **whether user-facing text is externalized** — pulled out of the code and into message catalogs the build reads by locale. It says nothing about whether the resulting translation is any good. Two patterns get extra weight: the accessibility-name attributes (`alt`, `aria-label`, `title`, `placeholder`), because a hardcoded one costs twice — the string cannot be translated *and* the accessible name is wrong for every reader not in the source language — and anything on the conversion path, because that is where an untranslatable sentence costs the most.

**Boundary.** This category judges the **source code**: can the string be translated. Whether the rendered translated page reads well, whether tokens leaked onto it, whether a value was never translated at all — that is the sibling's judge — call the Skill tool with "snitch-marketing". Whether the wording is the right wording for the moment is the other sibling's — call the Skill tool with "snitch-ux". Inside this skill: Cat 01 and Cat 11 judge whether an accessible name **exists** against SC 1.1.1 and 4.1.2; this category judges whether it can be **translated**. Cat 17 judges the grammar of an assembled message, Cat 18 the locale formatting of dates and numbers, Cat 21 the catalog files themselves.

### Pre-flight

Three states, decided before any Grep:

1. **Multi-locale.** More than one locale is served, or an i18n library is configured. Run the category at full severity.
2. **Single-locale, declared.** No i18n library, and `BLUEPRINT.md` records a `Decision` such as "English-only at launch" in *Constraints* or *Audience & wedge*. **Skip** with `Skip — single-locale by declared intent, per BLUEPRINT.md:<line>`. Quote the line. This category does not scold a project for a decision it recorded; that is what the declared-intent rules are for.
3. **Single-locale, undeclared.** No i18n library and no `Decision` either way. Run the category as **readiness**, cap every finding at **Low**, and say so in the first line of the section: these are not defects today, they are the work that a second locale would require, priced now while it is cheap.

The discovery block in SKILL.md already recorded which locales are served, the source locale, and the library or catalog format. Do not re-ask.

### Rule table

One row per pattern. A finding names its row.

| Pattern | What must hold | Static signal | Severity |
|---|---|---|---|
| (1) Text nodes in components | Rendered text comes from the translate call, not from a literal | A JSX text node, a Vue or Svelte template text node, or a server-side template literal containing two or more words of prose | High (conversion path) / Medium |
| (2) Accessibility-name attributes | `alt`, `aria-label`, `aria-description`, `title`, `placeholder` values come from the catalog | Any of those attributes assigned a literal string in a component or template | High |
| (3) Page and document titles | `<title>`, `document.title`, and framework head/metadata builders take a translated value | A literal assigned to `document.title`, or a hardcoded `<title>` in a layout, head component or metadata export | Medium |
| (4) Error, validation and empty-state copy | Messages a user reads on failure come from the catalog | A literal string thrown, returned, or assigned in a validation schema, a form handler, a catch block's user-facing branch, or an empty-state component | High (conversion path) / Medium |
| (5) Concatenated literals | The literal half of a concatenation is externalized | A string literal joined to a variable with `+` or in a template literal, where the literal is prose | Medium — cross-ref Cat 17 when the defect is the grammar rather than the literal |
| (6) Text baked into a graphic | Words are real text, not pixels or hardcoded vector text | An `<img>` whose visible content is words; an inline `<svg>` containing `<text>` with prose; `fillText` / `strokeText` on a canvas with a literal | Medium — cross-ref Cat 01 for SC 1.4.5 |
| (7) Enum, status and category labels | The label shown for a code value is looked up in the catalog | An object or map from a code value to a display string, rendered directly; an enum member name rendered with a formatter | Medium |
| (8) Email, SMS and notification templates | Copy sent to a person is templated per locale | Literal prose inside a mail, notification or push payload builder | Medium |
| (9) Locale-less number and date formatting | Values are formatted for the reader's locale | `toLocaleString()`, `toLocaleDateString()` or `toLocaleTimeString()` called with no locale argument | Low here — the finding belongs to Cat 18; cross-ref, do not double-count |
| (10) A translate call with a literal fallback | The fallback does not become the permanent English | `t('key', 'Some English text')` or an equivalent default-value argument used as the only copy for a key absent from every catalog | Medium — cross-ref Cat 21 for the missing key |

### Evidence required

**Find the setup before searching for violations.** A sweep that does not know what a correct call looks like reports every string in the codebase.

**Source mode:**

1. **Detect the i18n library and its translate call.** Read `package.json`, `composer.json`, `Gemfile`, `pyproject.toml`, `pom.xml` or the equivalent for an internationalization dependency, and read the app's initialisation for its configuration. Record **the translate call the detected library uses** — the common shapes are `t(`, `$t(`, `i18n.t(`, `formatMessage(`, `useTranslations(`, `gettext(`, `__(`, `trans(`, `<FormattedMessage`, `<Trans`. This name is the anchor for every later step. If no library is found, record that and go to the pre-flight's state 2 or 3.
2. **Locate the catalogs.** `Glob` for `locales/**`, `messages/**`, `i18n/**`, `translations/**`, `*.po`, `*.pot`, `*.arb`, `*.strings`, `*.resx`, `*.properties`. Record which locales exist. This is Cat 21's input too; read it once and share it.
3. **Sweep the components for row (1).** `Grep` templates and components for text nodes between tags. Keep hits with two or more words of prose; the exclusions below drop the rest. Cite `file:line` with the full element.
4. **Sweep the attributes for row (2).** `Grep` for `alt=`, `aria-label=`, `aria-description=`, `title=`, `placeholder=` followed by a quoted literal rather than a call or a binding. This sweep is short, high-yield and is the one to run first when time is limited.
5. **Sweep the head for row (3).** `Grep` for `document.title`, `<title>`, and the framework's metadata export or head component.
6. **Sweep the failure paths for row (4).** `Grep` validation schemas, form handlers and error components for quoted prose. Distinguish user-facing from developer-facing by where it renders: a message passed to a UI component is row (4); a message written to a log or thrown for a developer is not.
7. **Sweep for rows (5) to (8)**: string concatenation with prose literals; `<svg>` blocks containing `<text>`; `fillText`; maps from code values to display strings; mail and notification builders.
8. **Sweep for rows (9) and (10)**: `toLocale*String(` with an empty argument list; the translate call with a second string argument.
9. **Set aside the static assets that ship as-is.** A file served unmodified out of a public or static directory — `public/**`, `static/**`, a pre-rendered or exported `.html` page — never passes through the translate call, the build or the component tree the steps above sweep. List each one and **Skip** it with `Skip — static asset served as-is; its strings never reach the translate call`, naming the file. The strings in it are real, and they are the sibling's judge on the rendered page: call the Skill tool with "snitch-marketing". Do not score them as row (1) to (10) findings here, and do not drop them silently.
10. **Score by surface.** For each hit, decide whether it sits on the conversion path from the representative page set. That decision, not the pattern, is what separates High from Medium.

**Crawl mode:** this category is a source-mode category. In crawl mode it Skips with `Skip — string externalization is judged in source; no implementation available in crawl mode`. What crawl mode *can* see — a source-language string sitting on a translated page — is the sibling's finding, not this one.

**Exclusions — do not report any of these:**

- Code comments and documentation strings.
- Test files, fixtures, mocks, seeds and stories.
- `console.*`, logger calls, and messages thrown for a developer rather than rendered for a user.
- `data-testid`, `data-cy`, `id`, `className`, `name` and other machine-facing attribute values.
- Brand names, product names, proper nouns and trademarks — those stay in one form across locales on purpose.
- Single non-linguistic tokens: `OK` used as an HTTP-ish status value, `id`, `px`, a unit, a currency code, an emoji, a punctuation glyph, a number.
- Strings that are already arguments to the detected translate call.
- Locale catalog files themselves. They are Cat 21's surface.

Two-pass rule: after collecting hits, re-read each in its surrounding function before reporting it. A literal three lines above a translate call that overwrites it is a false positive, and the second pass is where that gets caught.

### Forbidden claims

- **"The site is not internationalized."** Report the strings that cannot be translated, with citations, and the count. A summary claim is not a finding.
- **"This string is untranslated."** Not what this category checks. Untranslated means a catalog value that was never localized, which is the sibling's judge and Cat 21's catalog check. Here the claim is `this string is not externalized — it has no catalog key`.
- **"The German version will be broken."** No prediction about a locale that does not exist yet. Say what is hardcoded.
- **"Every hardcoded string is a bug."** On a single-locale project with no declared intent, these are readiness findings at Low, and the report says so before it lists one.
- **"The translation quality is poor."** This category never judges quality. That is the sibling's.
- **"This needs a translation library."** Recommending a category of tooling is fine; naming a paid product or a vendor is not. Describe the shape and let the team choose.
- **A count with no list.** "47 hardcoded strings" is a finding only when the 47 citations exist; otherwise report the ones you have and say the sweep's scope.

### Detection

Source-mode Grep sweep of components, templates, head builders, failure paths, graphics and message builders for user-facing literals, anchored on the translate call the detected i18n library uses, with the exclusion list applied and a second read of each hit in context.

### What to Search For

- The i18n dependency in the manifest, and its initialisation, so the translate call's name is known before anything else
- Catalog files and the locales that exist
- JSX, Vue, Svelte and server-template text nodes with two or more words of prose
- `alt=`, `aria-label=`, `aria-description=`, `title=`, `placeholder=` assigned quoted literals
- `document.title =`, `<title>`, framework metadata exports and head components
- Validation schema messages, form handler error strings, `catch` branches that render to the user, empty-state and zero-result components
- Prose literals concatenated with `+` or interpolated in a template literal
- `<svg>` blocks containing `<text>`; `fillText(` and `strokeText(` with literals; `<img>` whose visible content is words
- Maps and objects from a code value to a display label; enum members rendered directly
- Mail, SMS, push and notification payload builders
- `toLocaleString()`, `toLocaleDateString()`, `toLocaleTimeString()` with no arguments
- The translate call with a literal second argument used as the permanent copy
- Confirmation dialogs, toasts, tooltips and loading text — the small strings that ship last and get externalized never

### Actually Fails

- **A conversion-path string hardcoded in a component.** The checkout button, the pricing label, the sign-up heading, the submit control. Evidence: `file:line` and the element, plus the fact that the same file uses the translate call elsewhere, which proves the pattern was available and not used.
- **A hardcoded accessible name.** `alt="Shopping cart"`, `aria-label="Close"`, `placeholder="Enter your email"`. Evidence: the attribute at `file:line`. State the double cost in the Risk: the string cannot be translated, and every reader not in the source language gets an accessible name in a language they may not read.
- **A hardcoded page title.** Evidence: the `document.title` assignment or the metadata export at `file:line`.
- **Validation and error copy in code.** Evidence: the schema or handler line, plus where it renders. These are the strings a person reads at the exact moment something has gone wrong, which is the worst moment to be handed a language they do not speak.
- **Words baked into an image or an SVG `<text>` element.** Evidence: the `<img>` or the `<svg>` at `file:line`. Cross-file the SC 1.4.5 half to Cat 01 rather than scoring it twice.
- **A status or enum label map rendered directly.** Evidence: the map at `file:line` and the render site. One map is usually a dozen strings, which makes it a cheap, high-count fix.
- **Email and notification copy in the builder.** Evidence: the builder at `file:line`. These reach the user outside the app, where a locale switcher cannot help them.
- **A translate call whose literal fallback is the only copy that exists.** Evidence: the call at `file:line` and the catalog sweep showing the key is absent from every locale. The call looks externalized and is not.

### NOT a Failure

- A project whose `BLUEPRINT.md` records a single-language `Decision`. Skip with the quoted line. Not a finding, not a Low finding, not a note. A Skip.
- Brand names, product names, proper nouns and trademarks left as literals.
- Developer-facing strings: log lines, thrown errors for a developer, assertion messages, internal admin tooling copy where the audience is the team.
- Machine-facing attribute values — `data-testid`, `id`, `className`, `name`, `type`, and route segments.
- Single non-linguistic tokens: units, currency codes, `%`, an emoji, an ISO code, a number.
- Strings in test files, fixtures, mocks and stories.
- A literal that is immediately passed to the detected translate call, or is a translate key rather than copy.
- Content authored in a CMS rather than in code, where the CMS carries its own locale fields. The externalization already happened; whether the locale fields are filled is Cat 21's and the sibling's question.
- A literal that a locale-aware wrapper overwrites before render. This is what the second pass exists to catch.
- A literal inside a static asset that ships as-is — a `public/*.html` page, a static export. It never reaches the translate call, so there is no externalization defect to report here. Skip it by name and hand the rendered page to the sibling.

### Context Check

1. Which pre-flight state applies — multi-locale, single-locale-declared, or single-locale-undeclared? The answer sets the whole section's severity ceiling.
2. Was the translate call identified before the sweep ran? An unanchored sweep produces noise, not findings.
3. Is each hit on the conversion path? That is the only thing separating High from Medium in rows (1) and (4).
4. Is the string user-facing or developer-facing? Where it renders decides, not how it reads.
5. Is it an accessibility-name attribute? Then it is High regardless of path, and the Risk names both costs.
6. Was each hit re-read in its surrounding function? A literal three lines from an overwriting translate call is a false positive.
7. Does a hit belong to Cat 17 instead — is the defect the grammar of an assembled sentence rather than the literal itself? Cross-ref, do not double-count.
8. Would externalizing this contradict a recorded `Decision`? Then the finding is capped at Medium and its Fix is "revisit the decision or accept the trade-off".

### Severity

One tier per finding. Critical is not used in this category — an untranslatable string is a readiness defect, not a barrier that stops a person at a criterion.

- **High** — a conversion-path string or an accessibility-name attribute hardcoded on a multi-locale project; user-facing validation and error copy on the conversion path.
- **Medium** — any other user-facing literal on a multi-locale project: content pages, titles, enum labels, notification templates, graphics with baked-in words, a translate call whose fallback is the only copy.
- **Low** — every finding on a single-locale project with no declared intent, reported as readiness; a locale-less `toLocale*String` call, which is cross-referenced to Cat 18 rather than scored here.
- **Pass** — a surface swept with the translate call identified and no user-facing literal found outside the exclusion list. Record the sweep, the files covered and the call name; a bare "externalization looks fine" is not a Pass.
- **Skip** — single-locale by declared intent, with the `BLUEPRINT.md` line quoted; a static asset that ships as-is, with the file named; or crawl mode with no source.

### Fix guidance

Externalizing is mechanical, which is why it gets deferred and why it is worth doing in one pass rather than one string at a time. Two rules make the pass survivable: keys describe **where and what**, never the English words, and the accessibility attributes go first.

**1. The attributes, first.**

```jsx
// Before — two defects in one line
<button onClick={close} aria-label="Close dialog">
  <CloseIcon aria-hidden="true" />
</button>
<img src="/cart.svg" alt="Shopping cart" />

// After
<button onClick={close} aria-label={t('dialog.close.label')}>
  <CloseIcon aria-hidden="true" />
</button>
<img src="/cart.svg" alt={t('nav.cart.alt')} />
```

The accessible name is now a translatable value. Before this change a screen-reader user reading the site in another language heard the source language for every control on the page, which is the failure mode nobody notices because it is invisible in the source locale.

**2. The copy, with keys that survive a rewrite.**

```jsx
// Before
<h1>Start your free trial</h1>
<p>No credit card required.</p>

// After
<h1>{t('signup.hero.heading')}</h1>
<p>{t('signup.hero.subheading')}</p>
```

```json
// locales/en.json
{
  "signup.hero.heading": "Start your free trial",
  "signup.hero.subheading": "No credit card required."
}
```

The key names the position, not the sentence. `signup.hero.heading` still makes sense after marketing rewrites the headline; `signup.startYourFreeTrial` becomes a lie the first time the words change, and a key that lies is worse than a key that is ugly.

**3. The error copy, at the schema.**

```js
// Before — the message is stuck in the validator
const schema = { email: { type: 'email', message: 'Enter a valid email address' } };

// After — the validator carries a key, the renderer resolves it
const schema = { email: { type: 'email', messageKey: 'form.email.invalid' } };
// at render:
<span role="alert">{t(field.messageKey)}</span>
```

**4. The labels that hide in a map.**

```js
// Before
const STATUS = { paid: 'Paid', pending: 'Pending', failed: 'Failed' };
// After
const STATUS_KEY = { paid: 'invoice.status.paid', pending: 'invoice.status.pending', failed: 'invoice.status.failed' };
```

Then set the guard so the work does not come back: a lint rule that fails on literal JSX text and on literal `alt` / `aria-label` / `placeholder` values, with the exclusion list above encoded in its configuration. Without the guard, the next feature adds the next twenty strings, and the pass gets run again in a year.

On a single-locale project with no declared intent, none of this is urgent — it is priced now because it costs a day today and a sprint after the codebase has doubled. Say that plainly, at Low, and let the team decide.

### Reference

W3C Internationalization — techniques and checks for authoring localizable content: https://www.w3.org/International/techniques/authoring-html

W3C Internationalization Best Practices for Spec Developers, on text and message handling: https://www.w3.org/TR/international-specs/

MDN on `Intl` and locale-aware formatting, for the row (9) cross-reference: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl

WCAG 2.2 SC 1.1.1 Non-text Content: https://www.w3.org/WAI/WCAG22/Understanding/non-text-content.html · SC 1.4.5 Images of Text: https://www.w3.org/WAI/WCAG22/Understanding/images-of-text.html · SC 4.1.2 Name, Role, Value: https://www.w3.org/WAI/WCAG22/Understanding/name-role-value.html

Unicode CLDR, for what a locale actually carries: https://cldr.unicode.org/
