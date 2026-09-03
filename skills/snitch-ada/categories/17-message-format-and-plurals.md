## CATEGORY 17: Plural, gender, select and sentence assembly

Externalizing a string makes it translatable. It does not make it *translatable correctly*. A message built by gluing a number to a noun, or by choosing between two English word forms with a ternary, carries English grammar in the code, where no catalog can reach it. A translator handed the two fragments has no way to produce a correct sentence in a language that needs six plural forms, or that puts the number after the noun, or that inflects the noun for gender.

This category audits **whether the message format can ever render correctly** in another language. Its anchor is Unicode CLDR, which defines six plural categories — `zero`, `one`, `two`, `few`, `many`, `other` — where English uses two. A ternary on `count === 1` is not a simplification of that. It is a message that cannot be repaired by translation, only by rewriting the code that builds it.

**Boundary.** This category judges the **message format in the code**: can the sentence be assembled correctly in a language with different grammar. Whether a raw `{count}` token leaked onto a rendered page, and whether the translated copy reads well, is the sibling's judge — call the Skill tool with "snitch-marketing". Inside this skill: Cat 16 judges whether the string is externalized at all — a hardcoded sentence is that category's finding, and only becomes this one once the string is in a catalog; Cat 21 judges placeholder **parity across catalogs**, meaning whether every locale's version of a key carries the same placeholders; Cat 18 judges the formatting of the values themselves; Cat 22 owns case and script handling, which row (9) below cross-references.

### Pre-flight

The same three states as Cat 16, decided before any Grep:

1. **Multi-locale.** More than one locale is served, or an i18n library is configured. Run at full severity.
2. **Single-locale, declared.** No i18n library, and `BLUEPRINT.md` records a `Decision` such as "English-only at launch". **Skip** with `Skip — single-locale by declared intent, per BLUEPRINT.md:<line>`, quoting the line.
3. **Single-locale, undeclared.** Run as **readiness**, cap every finding at **Low**, and say so before listing one.

One additional gate: this category needs either catalogs or translate-call sites to read. With neither — no i18n library and no catalog files — every row collapses into Cat 16's finding that nothing is externalized. Skip with `Skip — no catalogs or translate-call sites; string externalization is the prior finding (Cat 16)`.

### Rule table

One row per pattern. A finding names its row.

| Pattern | What must hold | Static signal | Severity |
|---|---|---|---|
| (1) Number glued to a noun | The count and its noun are one message the catalog owns, with the plural form selected by the message format | A count variable concatenated with a prose literal: `count + ' items'`, `` `${count} items` ``, `%d items` split across a format call and a literal | High (conversion path) / Medium |
| (2) English plural logic in code | Plural selection happens in the message format, against the reader's locale, not in a conditional | A ternary or `if` choosing between two word forms on `=== 1`, `> 1`, `!== 1`; a helper named for pluralizing; a trailing `'s'` appended conditionally | High (conversion path) / Medium |
| (3) Gender or select by conditional | Grammatical gender and other selections are expressed as a select in the message, not chosen in code | A conditional picking between message variants on a gender, role, type or status value | Medium |
| (4) Sentence assembly from fragments | A sentence is one catalog entry, so a translator can reorder it | Two or more catalog lookups or literals joined to build one sentence; a message split across an array and joined | High (conversion path) / Medium |
| (5) Positional placeholders | Placeholders are named, so a translator can move them | `%s`, `%d`, `%1$s`, `{0}`, `{1}` in catalog values, especially two or more in one message | Medium |
| (6) Ordinals built by suffix logic | Ordinals come from the locale's ordinal rules, not from a suffix table | A function mapping a number to `st` / `nd` / `rd` / `th`; a literal `'th'` appended to a number | Medium |
| (7) Date or time composed into a sentence | The formatted value is a named placeholder inside one catalog message | A formatted date or time concatenated with prose, or interpolated into a literal rather than into a catalog message | Medium — cross-ref Cat 18 for the formatting itself |
| (8) Case applied in code | Display casing comes from styling or from the catalog value, not from a runtime transform on translated text | `toUpperCase()`, `toLowerCase()`, a `capitalize` helper, or `charAt(0).toUpperCase()` applied to a translate call's result | Medium — cross-ref Cat 22 |
| (9) Keys that encode source grammar | Keys name position and purpose, not English word forms | A key ending in a plural marker, a key pair differing only by singular and plural, a key naming the English words | Low |
| (10) One key in two grammatical positions | A key has one grammatical role | The same key used as a button verb and as a status noun, or as a heading and as an inline word | Medium |
| (11) ICU plural or select used correctly | — | A catalog value of the shape `{count, plural, one {# item} other {# items}}`, or `{gender, select, ...}`, with the locale's own categories present in each locale's catalog | **Pass shape** — record it with the value quoted |

**CLDR plural categories, verified 2026-09-03 against https://cldr.unicode.org/index/cldr-spec/plural-rules:** `zero`, `one` (singular), `two` (dual), `few` (paucal), `many`, and `other`, which is required as the general plural form. The page gives Welsh as a language using all six and Russian and Czech as languages using more than two. English uses two. That gap is the whole reason this category exists.

### Evidence required

**Source mode:**

1. **Anchor on the setup.** Reuse Cat 16's step 1 result: the i18n library, the name of its translate call, and the catalog locations. Do not re-detect. Record whether the library supports ICU MessageFormat, because that decides what the correct shape looks like in the fix.
2. **Read the catalogs for message shapes.** `Grep` catalog files for `plural`, `select`, `selectordinal`, `#`, and for positional placeholders `%s`, `%d`, `%1$s`, `{0}`. Record which keys already use a plural or select block — those are row (11) Passes and they prove the pattern is available in this codebase.
3. **Sweep the call sites for row (1) and (2).** `Grep` for a count variable adjacent to a prose literal, and for the plural conditionals: `=== 1 ?`, `== 1 ?`, `> 1 ?`, `!== 1 ?`, `length === 1`, `? 's' :`, `+ 's'`, and any helper whose name is about pluralizing. Read each hit in context; a `=== 1` that selects an icon rather than a word is not this finding.
4. **Sweep for row (3).** `Grep` conditionals whose branches are two translate calls or two message keys, keyed on a gender, role, type or status value.
5. **Sweep for row (4).** `Grep` for two translate calls joined by `+`, by a template literal, or by `join(' ')`; and for arrays of message fragments.
6. **Sweep for rows (6) to (8).** Ordinal suffix helpers; formatted dates concatenated with prose; `toUpperCase(` / `toLowerCase(` / `capitalize(` applied to a translate call's result.
7. **Read the keys for rows (9) and (10).** Scan the catalog's key list for singular and plural pairs and for keys naming English words. Then `Grep` each suspicious key's usages: a key used in two different grammatical positions is row (10) and is only visible from the usage list, never from the catalog alone.
8. **Set aside the static assets that ship as-is.** A file served unmodified out of a public or static directory — `public/**`, `static/**`, a pre-rendered or exported `.html` page — never passes through the translate call this category anchors on. List each one and **Skip** it with `Skip — static asset served as-is; its strings never reach the translate call`, naming the file. A raw `{count}` or `%s` token visible in such a file is a rendered-page observation and the sibling's finding: call the Skill tool with "snitch-marketing". Name it and attribute it; never fold it into a row (1) to (10) finding here and never drop it silently.
9. **Score by surface.** Conversion path or not. That is the High / Medium line for rows (1), (2) and (4).

**Crawl mode:** Skips with `Skip — message format is judged in source; no implementation available in crawl mode`. A raw token visible on a rendered page is the sibling's finding.

**Exclusions — do not report:**

- Developer-facing strings: logs, thrown developer errors, internal admin tooling.
- Test files, fixtures, mocks and stories.
- A `=== 1` conditional that selects something other than a word form — an icon, a route, a layout, a numeric branch.
- Machine-facing formats: a URL built from segments, a CSS class assembled from parts, a query string, a file path, a generated identifier.
- Number formatting with no prose attached. That belongs to Cat 18.
- A single placeholder in a message where reordering cannot arise. `{name}` alone in `Hello, {name}` is fine; two positional placeholders in one message is row (5).

Two-pass rule: re-read every hit in its surrounding function before reporting. A concatenation inside a formatter that the library later parses is not a finding, and the second read is where that is caught.

### Forbidden claims

- **"This message is grammatically wrong in German."** Not what is being judged, and not observable. The claim is `this message format cannot express the plural categories German uses`, with the code quoted.
- **"The translation is broken."** This category never judges a translation. It judges whether the format could ever carry one.
- **"Every language needs six plural forms."** CLDR defines six categories; a given language uses a subset. Say what the format cannot express, not what a language requires.
- **"The raw token shows on the page."** That is a rendered-page observation and the sibling's finding. Here the evidence is the format in the code.
- **"This will break at runtime."** No prediction. A ternary plural does not throw; it renders a sentence that is wrong for readers who cannot report it.
- **"The catalog is missing the `few` form."** Placeholder and form parity across catalogs is Cat 21's judge. Cross-ref, do not score it here.
- **"Use ICU MessageFormat"** stated as the only option, where the detected library does not support it. Recommend the shape the detected library actually offers, and name the standard as the reference model.
- **A count with no list.** Report the citations you have.

### Detection

Source-mode read of the message catalogs and the translate-call sites, anchored on the detected library, looking for grammar decided in code rather than in the message format: plural conditionals, concatenated counts, sentence assembly, positional placeholders, ordinal suffix logic, runtime case transforms, and keys that carry source-language grammar.

### What to Search For

- In the catalogs: `plural`, `select`, `selectordinal`, `#`, `%s`, `%d`, `%1$s`, `{0}`, `{1}`
- Conditionals on `=== 1`, `== 1`, `> 1`, `!== 1`, `length === 1`, and `? 's' :`
- A trailing `+ 's'` or a conditional `'s'` appended to a noun
- Helpers whose names are about pluralizing, and imports of one
- A count variable adjacent to a prose literal in a template literal or a concatenation
- Two translate calls joined by `+`, by a template literal, or by `join`
- Arrays of message fragments assembled into a sentence
- Conditionals whose branches are two message keys, keyed on gender, role, type or status
- Ordinal suffix tables: `'st'`, `'nd'`, `'rd'`, `'th'`
- A formatted date or time interpolated into prose
- `toUpperCase(`, `toLowerCase(`, `capitalize(`, `charAt(0).toUpperCase()` applied to translated text
- Catalog keys that pair a singular and a plural, or that spell out English words
- Short, reusable keys — `common.open`, `common.close`, `common.new` — and every place they are used

### Actually Fails

- **A count concatenated with a noun on the conversion path.** The cart count, the results count, the seats-remaining line, the items-in-order line. Evidence: the expression at `file:line`. Risk: the message has one form; a reader whose language needs `few` and `many` gets a sentence that is wrong every time the number changes.
- **A ternary choosing between two English word forms.** Evidence: the conditional at `file:line`. Say plainly that the two branches are the two forms English has, and that the code cannot produce a third.
- **A sentence built from fragments.** `t('you.have') + ' ' + count + ' ' + t('new') + ' ' + kind`. Evidence: the assembly at `file:line`. Risk: word order is fixed by the code, and the translator cannot move the pieces.
- **Two positional placeholders in one message.** Evidence: the catalog value quoted with its key. Risk: a translator who needs to swap the two has no way to say which is which.
- **Gender or role selected by a conditional over two keys.** Evidence: the conditional at `file:line`, plus both keys.
- **Ordinal suffixes from a lookup table.** Evidence: the helper at `file:line`.
- **A formatted date concatenated into prose.** Evidence: the expression at `file:line`. Cross-file the formatting half to Cat 18.
- **`toUpperCase()` applied to a translated string.** Evidence: the call at `file:line`. Risk: uppercasing is not a safe transform across scripts, and some scripts have no case at all; cross-ref Cat 22.
- **A key used in two grammatical positions.** Evidence: the key and both usages at `file:line`. Risk: a language that inflects the word differently as a verb and as a noun cannot satisfy both with one entry.

### NOT a Failure

- A project whose `BLUEPRINT.md` records a single-language `Decision`. Skip with the quoted line.
- A correct ICU plural or select block: `{count, plural, one {# item} other {# items}}`. That is row (11) and it is a Pass — record it with the value and the key, because it proves the codebase already has the pattern.
- The equivalent shape in a library that does not use ICU syntax — a plural key family, a `_plural` suffix convention, a `pluralize` API the library provides. The standard is the model; the library's own correct pattern is what matters.
- A single named placeholder in a message. `Hello, {name}` cannot be reordered wrongly.
- A `=== 1` conditional that does not select a word form.
- A count with no noun attached — a badge, a bare numeric cell in a table, a chart label. There is no grammar to get wrong.
- Machine-facing string assembly: URLs, CSS classes, query strings, file paths, identifiers.
- Case applied by CSS `text-transform` rather than in code. It is a styling choice a locale stylesheet can override, and it does not mutate the string.
- Developer-facing messages, test fixtures and internal admin copy.
- A message inside a static asset that ships as-is — a `public/*.html` page, a static export. Nothing in it reaches the message format, so there is no format defect to report here. Skip it by name and hand the rendered page to the sibling.

### Context Check

1. Which pre-flight state applies? It sets the section's severity ceiling.
2. Are there catalogs or translate-call sites to read at all? Without them the prior finding is Cat 16's.
3. Does the detected library support ICU MessageFormat, or does it have its own plural API? The fix must be written for the library in the repo.
4. Is the hit on the conversion path? That is the High / Medium line.
5. Is the `=== 1` actually selecting a word form, or something else entirely?
6. Is this the same defect Cat 16 already reported? A hardcoded sentence is externalization; a catalog message with English grammar baked in is this category.
7. Is the claim about the format, or about a translation's quality? Only the format is in scope.
8. Does the codebase already use a correct plural block somewhere? Cite it in the fix — the team does not need a new dependency, they need the pattern they already have.

### Severity

One tier per finding. Critical is not used in this category.

- **High** — plural, gender or sentence-assembly logic in code on a multi-locale project's conversion path: the cart, the checkout, the pricing, the sign-up, the order summary.
- **Medium** — the same patterns off the conversion path; positional placeholders; ordinal suffix logic; a date composed into prose; a runtime case transform on translated text; one key in two grammatical positions.
- **Low** — keys that encode source-language grammar; every finding on a single-locale project with no declared intent, reported as readiness.
- **Pass** — a message using a correct plural or select block, recorded with the key and the value; a swept surface with no grammar-in-code found, recorded with the files covered and the patterns searched for.
- **Skip** — single-locale by declared intent, with the line quoted; no catalogs or call sites; a static asset that ships as-is, with the file named; crawl mode.

### Fix guidance

The move is always the same: take the grammar out of the code and put it in the message, where a translator can reach it. The message format decides the form; the code supplies the number and the values.

**1. The count.**

```jsx
// Before — English's two forms, hardcoded, in a language that may need six
<span>{count} {count === 1 ? 'item' : 'items'}</span>

// After — one message, one key, the format selects the form
<span>{t('cart.items', { count })}</span>
```

```json
// locales/en.json
{ "cart.items": "{count, plural, one {# item} other {# items}}" }

// locales/cy.json — Welsh uses all six categories
{ "cart.items": "{count, plural, zero {# eitem} one {# eitem} two {# eitem} few {# eitem} many {# eitem} other {# eitem}}" }
```

The English catalog carries the two forms English has. The Welsh catalog carries the six Welsh has. Neither is a translation of the other's structure, which is the point: the code stopped deciding.

**2. The assembled sentence.**

```jsx
// Before — word order fixed in JavaScript
<p>{t('you.have')} {count} {t('new')} {kind}</p>

// After — one message; the translator moves the parts
<p>{t('inbox.summary', { count, kind: t(`kind.${kind}`) })}</p>
```

```json
{ "inbox.summary": "{count, plural, one {You have # new {kind}} other {You have # new {kind}s}}" }
```

If the target language puts the count last, or inflects `kind` for case, the catalog entry can say so. The previous version could not, no matter who translated it.

**3. Named placeholders instead of positional ones.**

```
Before: "Moved %s to %s"
After:  "Moved {file} to {folder}"
```

A translator working with `%s %s` is guessing which is which. A translator working with `{file}` and `{folder}` can reorder them, and often must.

**4. Gender and other selects, in the message.**

```json
{ "invite.sent": "{gender, select, female {She was invited} male {He was invited} other {They were invited}}" }
```

**5. Ordinals, from the locale.**

```js
// Before — an English suffix table
const suffix = n => (n % 10 === 1 && n % 100 !== 11) ? 'st' : /* ... */ 'th';

// After — the locale's own ordinal rules
new Intl.PluralRules(locale, { type: 'ordinal' }).select(n);
// or, in the message: "{n, selectordinal, one {#st} two {#nd} few {#rd} other {#th}}"
```

**6. Casing, out of the code.** Move it to CSS `text-transform` where it is decoration, or into the catalog value where it is part of the copy. A runtime `toUpperCase()` on a translated string is a transform applied to text the code has never seen; some scripts have no case, and in a few languages the uppercase of a character is not one character. Cat 22 carries that detail.

**7. Keys.** One key, one grammatical role. `common.open` used as a button verb and as a status noun becomes `action.open` and `status.open`, which costs two catalog entries and buys every language that inflects them differently.

Where the detected library does not speak ICU syntax, use its own plural API and keep the same discipline: one message per sentence, named placeholders, no word-form selection in application code. The standard named in the Reference is the model to copy, not a dependency to install.

### Reference

Unicode CLDR plural rules and the six categories: https://cldr.unicode.org/index/cldr-spec/plural-rules · Language plural rules chart: https://www.unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html

ICU MessageFormat: https://unicode-org.github.io/icu/userguide/format_parse/messages/

`Intl.PluralRules`, including ordinal selection: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/PluralRules · ECMA-402: https://tc39.es/ecma402/

W3C Internationalization guidance on composing and building strings: https://www.w3.org/International/techniques/authoring-html
