## CATEGORY 21: Catalog completeness, placeholder parity, stale and invalid entries

A message catalog is a contract between the developer and the translator. The developer promises
that every string a reader sees lives here, and the translator promises that every key comes back
in the target language with its placeholders intact. Catalogs rot quietly on both sides. Keys are
added to the source and never sent out. Keys are deleted from the source and left behind in eight
targets. A translator renames `{count}` to `{anzahl}` because it looked like a word, and the
sentence breaks at runtime for every reader of that locale. A file is saved with a byte-order mark
and the loader returns nothing.

This category judges the catalog files themselves. It runs in source mode only, and its evidence
is a diff between the source catalog and each target catalog at `file:line`, produced by the
bundled script and quoted in the finding. The script does the counting; the judgment about which
gaps matter is yours.

**Boundary.** This category judges the files a developer ships. The rendered page a reader sees
belongs to a sibling: call the Skill tool with "snitch-marketing", whose Cat 133 judges the
content quality of a translated page in crawl mode, including whether the prose reads naturally.
The split is exact. A missing key here is a file defect with a line number; the same gap there is
an English fragment visible on a German page. Neither category asserts translation quality: this
one because it reads bytes, that one because it says so explicitly and routes fluency to a native
reviewer. HTML inside a catalog value is a translator-safety note here; whether it is an injection
risk is a different judge, so for that, call the Skill tool with "snitch-security".

### Pre-flight

**Crawl mode: Skip**, with the reason `catalogs are not served; the rendered-page half belongs to
the marketing sibling's Cat 133`. Catalog files are build inputs, not routes. Do not fetch a
`/locales/en.json` path and treat a 404 as a finding.

In source mode:

- Locate the catalogs first. If none exist and the surface serves more than one locale, that
  absence is Category 16's finding (strings are not externalized), not this one. **Skip** with
  that reason and name the category.
- One locale with a recorded single-language `Decision`: **Skip**, citing the line.
- One catalog and no target catalogs: **Skip** with `no target catalogs to diff against`.
- Neither declared-intent file present is a **Skip** with that reason.
- Establish which catalog is the source from the discovery i18n inventory, never by guessing.
  Diffing against the wrong source inverts every finding.

Formats, decided by **file extension, before the script runs**: the bundled script parses `.json`
fully, and `.po` / `.pot` / `.yml` / `.yaml` best-effort. Every other extension
(`.properties`, `.strings`, `.xliff`, `.arb`, a database-backed catalog) is out of scope. Sort the
catalog list by extension first, and for each file that is not one of those five, **Skip** with the
verbatim reason `catalog format not supported by the bundled diff; verify with the project's own
tooling`, then report only what a direct Read can prove about it.

The script enforces the same line: an unsupported extension is refused, not guessed at, and printed
as `unsupported format: <path> (supported: json, po, pot, yml, yaml)` against that file. Quote that
line as the evidence for the Skip. The script's `--format json|po|yaml` flag can force a parser past
the check; **do not use it to diff a format this category Skips.** An ARB or `.strings` export is
JSON-shaped with its own key convention, so forcing it produces a page of missing keys that describe
the convention gap and not the catalog.

### Rule table

| Pattern | What must hold | Static signal | Severity |
|---|---|---|---|
| Keys present in the source catalog and missing from a target | Every source key exists in every target catalog, or the locale is documented as partial | `missing` rows in the diff output, per target | High |
| Keys present in a target and absent from the source (orphans) | Target catalogs carry no keys the source has dropped | `extra` rows in the diff output | Low |
| One target value byte-identical to the source value | A target value equal to its source is untranslated, unless it is a number, a URL, a brand name or a token of two characters or fewer | An `identical` row in the diff output for that key, after those exclusions | High (the key renders on the conversion path, or supplies an accessibility name) / Medium (anywhere else) |
| A target catalog mostly identical to the source | A locale that ships is translated, not copied; the locale exists in fact and not only in the file tree | The `identical` count against that target's total key count, after the exclusions, quoted as a ratio | High |
| Placeholder parity broken | Every placeholder in the source appears, by the same name, in every target: `{name}`, `{{name}}`, `%s`, `%1$s`, `%(name)s`, `${name}`, and ICU arguments | `placeholder-mismatch` rows naming the source and target token sets | High |
| ICU plural or select categories missing for the target language | A target whose language needs categories beyond `one` and `other` declares them: CLDR gives Polish and Russian `one`, `few`, `many`, `other`, and Arabic `zero`, `one`, `two`, `few`, `many`, `other`; `other` is mandatory everywhere | An ICU `plural` block in a target with fewer categories than the language uses | High |
| Empty values | No key resolves to an empty string; an empty value renders as nothing at all | `empty` rows in the diff output | High |
| Invalid JSON, YAML or `.po` | Every catalog parses; a parse failure means the whole locale falls back silently | The parser error with the file and position | High |
| Duplicate keys within one catalog | Each key appears once; a duplicate silently wins or loses depending on the parser | Two occurrences of the same key path in one file | Medium |
| Catalog not UTF-8, or carrying a byte-order mark the loader rejects | Every catalog is UTF-8 without a BOM unless the loader documents otherwise | A non-UTF-8 encoding, or the bytes `EF BB BF` at the head of a JSON file | High |
| HTML markup inside catalog values | Structure lives in the code and the catalog holds text with placeholders, so a translator is never asked to hand-edit tags | `<` followed by a tag name inside a value | Medium |
| A hardcoded fallback string in code that diverges from its catalog entry | A default written beside the lookup matches the source catalog, or there is no default | A lookup call with a second string argument, compared against the catalog value | Medium |
| Unused keys (present in the source, referenced nowhere in code) | The catalog tracks the code; dead keys are removed on a schedule | A source key with no reference found by a grep of the key path | Low (advisory) |
| Every locale bundled into every page | The bundle carries the requested locale, not all of them | A build config or import that pulls the whole catalog directory | Low (advisory) |

### Evidence required

**Source mode, cheapest first:**

1. `Glob` the catalog locations and list every file with its locale: `locales/**`, `messages/**`,
   `i18n/**`, `lang/**`, `translations/**`, `*.po`, `*.pot`, `*.arb`. Record the source catalog.
2. **Check every extension against the supported five before running anything.** `.json`, `.po`,
   `.pot`, `.yml` and `.yaml` go into the diff; every other file Skips with the Pre-flight wording
   and is left out of the command. Passing one in anyway does not corrupt the run — the script
   refuses it by name — but the Skip is decided here, not read off the output.
3. Run the bundled diff on the supported catalogs and quote its output as the evidence for the
   completeness rows.

   ```
   python3 "${CLAUDE_SKILL_DIR}/scripts/catalog-diff.py" --source locales/en.json locales/de.json locales/ar.json
   ```

   It prints, per target: missing keys, extra keys, values identical to the source, placeholder
   mismatches with both token sets, and empty or invalid entries. Quote the block for the target
   the finding is about, and cite the catalog at `file:line` beside it. Never paste the whole run
   into a report; a script's output is evidence for a finding, not a finding.
4. Without `python3`, say so in the finding (`catalog diff not computed — python3 unavailable`)
   and fall back to reading the source catalog and one target and comparing the key sets by hand,
   scoped to the sections you read and stated as such.
5. `Grep` the catalogs for markup and for placeholder tokens: `<`, `{{`, `%s`, `%(`, `${`,
   `plural,`, `select,`.
6. `head -c 3` each catalog, or read its first bytes, to check for a byte-order mark, and confirm
   the encoding is UTF-8.
7. `Grep` the lookup call sites for a second string argument (a hardcoded fallback) and compare
   each against the source catalog value.
8. For the unused-key advisory, take a sample of source keys and grep the codebase for each key
   path. Report a count from the sample, and say it is a sample.

**Caveat:** a key can be built at runtime (`t('errors.' + code)`), so a grep that finds no
reference does not prove the key is dead. Say so in the unused-key advisory and keep the
confidence low. The same caveat applies in reverse: a key missing from a target may be supplied by
a documented fallback chain, so read the loader's fallback configuration before calling a gap a
runtime failure.

### Forbidden claims

- "The German translation is poor" or "this reads awkwardly." This category reads bytes. Fluency
  is not judged here or anywhere in this skill; route it to the marketing sibling's Cat 133 and to
  a native reviewer.
- "This locale is machine-translated." Unless the project says so, or a tell proves it, do not
  assert the production method. Many identical values is a signal, not a proof.
- "Keys are probably missing." Run the diff, or read both files and say which sections you read.
- Never "compliant", "conformant" or "non-compliant" as a verdict.
- "This value has an XSS problem." Markup in a catalog is a translator-safety note here. Name the
  sibling that judges the injection risk and stop.
- "The catalog is broken." Say which file, which parser, and quote the error with its position.
- A count with no file. Every number in a finding here names the catalog it came from.
- Any WCAG success criterion number. This is an i18n-readiness pattern, not a criterion.

### Detection

A key-set and value diff between the source catalog and every target catalog, produced by the
bundled script, plus an encoding read, a markup grep, and a fallback-string comparison. Nothing
here needs a runner. Crawl mode does not run at all.

### What to Search For

- Catalog paths: `locales/`, `messages/`, `i18n/`, `lang/`, `translations/`, `*.po`, `*.pot`
- Placeholder tokens in values: `{name}`, `{{name}}`, `%s`, `%1$s`, `%(name)s`, `${name}`
- ICU blocks: `plural,`, `select,`, `selectordinal,`, `#`, and the category keywords `zero`,
  `one`, `two`, `few`, `many`, `other`
- Empty values: `": ""`, `msgstr ""` with a non-empty `msgid`
- A byte-order mark at the head of a JSON or YAML catalog
- Markup inside values: `<a `, `<strong`, `<br`, `&nbsp;`
- Lookup calls with a fallback: `t('key', 'Default text')`, `defaultMessage:`
- Build config that imports a whole catalog directory

### Actually Fails

- **Keys missing from a target catalog.** Every missing key is a place where the reader gets the
  source language mid-sentence, or a raw key path if there is no fallback. Evidence: the `missing`
  block from the diff for that target, the count, and three key paths quoted with the target file.
- **A placeholder renamed or dropped in a target.** `{count} items` translated with the token
  removed produces a sentence with a hole in it, and a renamed token can throw at runtime.
  Evidence: the `placeholder-mismatch` row with both token sets, plus the source and target values
  quoted.
- **A plural block missing categories the language needs.** A Russian message with only `one` and
  `other` is grammatically wrong for most of the numbers a reader will see. Evidence: the target's
  ICU block quoted, beside the categories CLDR gives that language.
- **Empty values in a shipped catalog.** The reader gets nothing where a label belonged, which is
  worse than an untranslated string because there is nothing to read at all. Evidence: the `empty`
  rows with key paths and the file.
- **A catalog that does not parse, or is not UTF-8.** The whole locale silently falls back, and
  every finding about its contents is moot until it loads. Evidence: the parser error with its
  position, or the encoding and the first bytes.
- **One target value identical to the source.** That key is untranslated, and the reader gets the
  source language in the middle of their own. Evidence: the `identical` row for that key with both
  values quoted, and the exclusions stated as applied. High where the key renders on the conversion
  path or supplies an accessibility name, Medium elsewhere — say which, and why.
- **Most target values identical to the source.** The locale exists in the file tree and not in
  fact. Evidence: the `identical` count against the total key count for that target, quoted as a
  ratio, with the numeric, URL, brand and short-token exclusions applied and stated. This is the
  per-locale shape, reported once for the catalog rather than once per key.

### NOT a Failure

- Target values identical to the source where the value **is** the same in both languages: a
  brand name, a product name, a proper noun, an established loanword, a units token, an emoji, a
  URL, a number, a token of two characters or fewer. Apply these exclusions before counting.
- A locale documented as partial, with a declared fallback chain the loader implements. Read the
  loader's configuration and record the pass with that configuration as its evidence.
- Keys missing from a target for a feature not shipped in that market, where the routing does not
  offer those pages in that locale.
- A `.pot` template with empty `msgstr` values. That is what a template is.
- Orphan keys during a migration, where the source catalog is mid-rename and both key sets exist
  on purpose. Confirm before flagging.
- Inline markup in a value where the framework's own translation component requires it and the
  tags are numbered placeholders rather than hand-written HTML.
- Deliberate duplicate key **paths** in different namespaces. The duplicate row is about the same
  path twice in one file.
- A catalog that is not UTF-8 where the loader documents and handles that encoding.

### Context Check

1. Which catalog is the source? Everything in this category is relative to it, and a wrong answer
   inverts every finding.
2. Does every catalog's **extension** sit in the supported five (`.json`, `.po`, `.pot`, `.yml`,
   `.yaml`)? JSON parses fully; the rest are best-effort; any other extension Skips with the
   Pre-flight wording, before the diff runs and whatever the file's contents look like.
3. Does the loader implement a documented fallback chain? A gap with a fallback is a content
   problem for the sibling; a gap without one is a broken render.
4. Is the locale advertised to readers? A catalog for a locale the switcher does not offer is a
   work in progress, not a shipped defect.
5. Are the identical values genuinely untranslated, or are they the exclusions? Apply the
   exclusions before you count, and say you applied them.
6. Does the target language need plural categories the source does not have? That asymmetry is the
   most common way an ICU message is broken by a well-meaning translation.
7. Is there a recorded `Decision` about locale coverage? If so the finding caps at Medium with the
   Fix "revisit the decision or accept the trade-off".

### Severity

One tier per failure shape. `Critical` is not used in this category; it is reserved for Level A
accessibility failures that block a task.

- **High** — missing keys on a shipped locale, broken placeholder parity, missing plural
  categories, empty values, a catalog that does not parse, a non-UTF-8 or BOM-broken catalog, a
  target that is mostly identical to the source, and one identical value on a key that renders on
  the conversion path or supplies an accessibility name.
- **Medium** — one identical value on any other key, duplicate keys, markup inside values, a
  hardcoded fallback that diverges from the catalog. Also the cap for a finding contradicting a
  recorded `Decision`.
- **Low** — orphan keys, unused keys, all locales bundled into every page, and every finding on a
  locale that is not yet advertised to readers.

### Fix guidance

Make the catalog a checked artifact instead of a folder people remember to update.

```jsonc
// Before: locales/de.json. Three defects in four lines.
{
  "cart.title": "Warenkorb",
  "cart.items": "{anzahl} Artikel",        // source token is {count}: renamed, breaks at runtime
  "cart.empty": "",                        // renders as nothing
  "cart.checkout": "Checkout"              // identical to source, never translated
}
```

```jsonc
// After: tokens match the source exactly, no empty values, plurals declared per CLDR.
{
  "cart.title": "Warenkorb",
  "cart.items": "{count, plural, one {# Artikel} other {# Artikel}}",
  "cart.empty": "Ihr Warenkorb ist leer",
  "cart.checkout": "Zur Kasse"
}
```

```jsonc
// A target whose language needs more categories declares them. Polish: one, few, many, other.
{
  "cart.items": "{count, plural, one {# produkt} few {# produkty} many {# produktów} other {# produktu}}"
}
```

Three rules keep it that way. **The diff runs in continuous integration**, not by hand: fail the
build on a missing key, a placeholder mismatch, an empty value or a parse error, and warn on
orphans and identical values. **Placeholders are never translated**: send translators the token
names as untranslatable, and check parity mechanically on the way back. **Plural categories come
from CLDR, per language**, so a target gets the categories its language uses rather than a copy of
the source's two; `other` is mandatory in every language and is the fallback when nothing else
matches.

Do not fill a missing key with machine output as part of this fix, and do not delete an orphan key
that a runtime-built lookup may still request. Report both and let the user decide.

### Reference

- Unicode CLDR language plural rules, the source of each language's plural categories and of the
  rule that `other` is mandatory in every locale:
  https://www.unicode.org/reports/tr35/tr35-numbers.html#Language_Plural_Rules
- The CLDR plural-rules chart, for checking a specific language's categories:
  https://www.unicode.org/cldr/charts/47/supplemental/language_plural_rules.html
- Unicode CLDR project home: https://cldr.unicode.org/
- `Intl.PluralRules`, the runtime API that returns a value's CLDR plural category:
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/PluralRules

Facts verified 2026-09-03 against unicode.org and developer.mozilla.org. Verified there: CLDR
defines the six categories `zero`, `one`, `two`, `few`, `many` and `other`; `other` is mandatory;
Polish and Russian use `one`, `few`, `many`, `other`; Arabic uses all six.
