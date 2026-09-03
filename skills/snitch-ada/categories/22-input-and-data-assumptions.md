## CATEGORY 22: Names, addresses, phone, Unicode handling, collation and case

Every form is a theory about people. A form with a required last name of at least two characters
is a theory that everyone has two names. A five-digit postal-code check is a theory that everyone
lives in one country. A `^[A-Za-z ]+$` on a name field is a theory that nobody the product serves
writes their own name in their own script. These theories are almost always wrong, and the person
who finds out is the one being told their real name is invalid.

This category judges the data model and the validation behind the fields, not their visual design.
The evidence is the regex, the schema column, the comparison, or the length check at `file:line`,
or the rendered input and its attributes at URL + selector. Unicode already answers most of it:
UAX #15 defines the normalization forms that make canonically equivalent strings compare equal,
UAX #29 defines the extended grapheme cluster that a person means by "one character", and
ECMA-402's `Intl.Collator` compares by a locale's own rules rather than by code-point order.

**Boundary.** Validation as an attack surface is **not** judged here. Injection, sanitization,
authentication logic and the security consequences of accepting a wide input range belong to a
different judge: call the Skill tool with "snitch-security". Nothing in this category asks for a
looser check as a security trade-off; it asks for a check that is correct about people. Whether
the form is pleasant, how many fields it asks for, and where a person abandons it is a third
judge: call the Skill tool with "snitch-ux". Label association, error identification and
programmatic input purpose are WCAG criteria and belong to Categories 03, 10 and 11 of this skill.

### Pre-flight

Run on any surface with a form that collects a name, an address, a phone number, or free text a
person will search or sort. That includes single-locale sites, because names, scripts and
migration do not respect a site's language plan.

- More than one locale served, or a form that accepts submissions from outside one country: run in
  full.
- Single-locale, single-country product with a recorded `Decision` naming that scope: run at
  **readiness severity**, capped at **Low**, except the Unicode-handling rows (charset,
  normalization, grapheme-cluster length, case mapping, collation), which keep their full severity
  because they break for people already inside that market.
- No forms and no user-supplied text anywhere: **Skip** with `no user input collected`.
- Neither declared-intent file present is a **Skip** with that reason for the locale-scoped rows;
  the Unicode-handling rows still run.

### Rule table

| Pattern | What must hold | Static signal | Severity |
|---|---|---|---|
| Separate first and last name, both required | A single required full-name field, or a second field that is optional; one legal name is a real shape | Two required name inputs, or a schema with two non-nullable name columns | High |
| Latin-only regex on a name | Name validation accepts letters in any script, marks, spaces, apostrophes and hyphens; the safest rule is a length bound and nothing else | `^[A-Za-z\s]+$`, `[a-zA-Z]`, `\w+` applied to a name field | High |
| Minimum length above one on a name, or an assumed name order | Any single character is a valid name, and the display order is a property of the locale, not of the columns | `minLength="2"` on a name input; a display template hardcoding `first last` | Medium |
| Title or honorific list drawn from one culture | Honorifics are optional and free text, or the list is culture-scoped and includes an opt-out | A fixed `<select>` of `Mr / Mrs / Ms` with no free entry and no blank | Low |
| US-shaped address form shown to every locale | The address form changes shape with the country: field set, order, labels and which fields are required all follow the selected country | A required state `<select>`, a `city, state, zip` line, or a fixed field order with no country branch | High |
| Postal-code validation that rejects valid codes | Postal-code rules are per country, and countries without postal codes leave the field absent, not empty-and-required | `^\d{5}(-\d{4})?$` applied to every country; a required postal code with no country branch | High |
| Phone validation assuming one national format or a fixed length | Phone entry offers a country selection, stores the number in a country-qualified form, and validates per country | A regex like `^\(\d{3}\) \d{3}-\d{4}$`; a fixed `maxLength` on a phone field; a missing `type="tel"` | High |
| No `<meta charset="utf-8">`, or a non-UTF-8 column or connection | The document, the database columns and the connection are all UTF-8 end to end | A missing or non-UTF-8 `<meta charset>`; a `latin1` / `utf8` (three-byte) charset or collation in a schema or connection string | High |
| String comparison, dedupe or login without normalization | Strings compared for equality are normalized to the same form first, because canonically equivalent text has more than one byte sequence (UAX #15) | An equality check or a unique index on user text with no `normalize(` anywhere near it | High |
| Length limits counted in bytes or UTF-16 code units | A user-facing length limit counts extended grapheme clusters (UAX #29); truncation never splits a cluster or a surrogate pair | `.length` used as a character count on user text; `substring(0, n)` on a display string; a `VARCHAR(n)` bound presented to the user as a character count | Medium |
| `\w`, `[a-z]` or `[A-Za-z]` character classes applied to user text | Character classes over user text either use Unicode property escapes or are replaced by a bound | `\w`, `[a-z]`, `[A-Za-z]` in a validation or search regex over a name, address or search term | High |
| `toUpperCase()` / `toLowerCase()` used for case-insensitive comparison | Case-insensitive comparison uses a locale-aware collator or a case-folding comparison; the Turkish dotted and dotless i do not survive the default mappings | `.toLowerCase() ===`, `.toUpperCase() ===` on user text such as an email, a username or a search term | High |
| Sorting with `Array.sort()` or `localeCompare()` with no locale | Sorting user-visible lists uses `Intl.Collator` with the reader's locale, because collation order differs by language | `.sort()` on a string array of names or labels; `localeCompare(` with no locale argument | Medium |
| Search expected to be accent-insensitive with no collator sensitivity | Accent-insensitive matching comes from a collator's `sensitivity` setting or a normalized index, not from a hand-written character map | A search comparison over accented text with no `Intl.Collator` and no normalization step | Medium |
| Date-of-birth or age validation with calendar assumptions | Date entry accepts the locale's field order and does not assume a Gregorian-only calendar; see Category 18 for the formatting half | A date input parsed with a hardcoded field order; an age computed by subtracting years | Medium |
| Emoji or RTL characters in a username or display name unhandled | Display names of unknown direction are isolated on render (see Category 19), and stored without silent stripping | A strip or replace over non-ASCII characters in a display-name path | Medium |
| `parseFloat` on localized numeric input | Numeric input typed in the reader's convention is parsed against that convention, or the field is a numeric input that supplies a machine value | `parseFloat(` or `Number(` over a text input's value on a form that serves more than one number convention | Medium |

### Evidence required

**Source mode, cheapest first:**

1. `Grep` the validation regexes: `^[A-Za-z`, `[a-zA-Z]`, `\w`, `\d{5}`, `pattern=`, `minLength`,
   `maxLength`, `matches(`. Read each hit with the field it guards and quote both.
2. Read every name, address and phone form in full. Record which fields are required, whether the
   address form branches on country, and whether the phone field offers a country selection and
   carries `type="tel"`.
3. `Grep` the schema and migrations for the identity and address columns, their nullability,
   length bounds and charset or collation: `VARCHAR`, `CHARACTER SET`, `COLLATE`, `latin1`,
   `utf8mb3`, `utf8mb4`, `NOT NULL` on a name or postal-code column. Then `Grep` the document head
   for `<meta charset` and the connection string or config for a charset parameter.
4. `Grep` the comparison and sorting sites: `toLowerCase()`, `toUpperCase()`, `localeCompare(`,
   `.sort()`, `normalize(`, `Intl.Collator`. Read each hit and record what is being compared. The
   presence of `normalize(` and `Intl.Collator` is the pass evidence.
5. `Grep` the length and truncation sites (`.length`, `substring(`, `slice(`, `truncate(`) over
   user text and compare each against the limit the interface shows; then `Grep` `parseFloat(`
   and `Number(` over form values, and any strip or replace over a display name.

**Crawl mode, cheapest first:**

1. Fetch a page carrying each form and quote the inputs with their selectors: `type`, `required`,
   `pattern`, `minlength`, `maxlength`, `inputmode`, `autocomplete`.
2. Quote the `<meta charset>` from the head, and any `Content-Type` charset in the response header.
3. Change the country selection where the markup allows it and quote whether the address fields
   change. Where the form is rendered by script and the fetch returns only the shell, record
   `Skip — country-dependent form shape requires a rendering runner; not run`.
4. Server-side validation is not observable from a fetch. Quote the client-side rule and say so.

**Caveat:** a client-side `pattern` is a hint, and the authoritative rule is on the server. When
you can read only one side, say which side you read and scope the finding to it. When the two
disagree, quote both, because a permissive client with a Latin-only server still rejects the name.

### Forbidden claims

- "This form rejects international names." Quote the regex or the length rule and the field it
  guards. A named rule is evidence; a predicted rejection is not.
- "Names will break." Say which input, which rule, and which shape of name it excludes.
- Never "compliant", "conformant" or "non-compliant" as a verdict.
- "This validation is a security hole" or "loosening this is safe." Neither claim is this
  category's to make. Name the sibling that judges validation as an attack surface and stop.
- "The database will corrupt this." Quote the column or connection charset, or Skip with a reason.
- "The sort order is wrong for German." Quote the comparison call, say it uses code-point or
  default-locale order, and name what a locale-aware collator would do differently.
- Any WCAG success criterion number. Labels, error identification and input purpose are Categories
  03, 10 and 11; this category names data assumptions.

### Detection

Static read of every identity, address and phone field with its validation rule, plus a schema and
connection charset read, and a grep sweep of comparison, sorting, length and parsing call sites.
Crawl mode reads the served input attributes and the document charset. Anything depending on
server-side behavior or a re-rendered form Skips with its reason.

### What to Search For

- Name rules: `^[A-Za-z`, `[a-zA-Z]+`, `\w+`, `minLength`, `pattern=` on a name input; address
  rules: `\d{5}`, `zip`, `postal`, `state`, a required state `<select>`, a fixed field order
- Phone rules: `\(\d{3}\)`, `^\+?1`, `maxLength` on a phone field, a missing `type="tel"`
- Encoding: `<meta charset`, `latin1`, `utf8mb3`, `CHARACTER SET`, `COLLATE`, a connection string
  with a `charset` parameter
- Comparison and sort: `toLowerCase() ===`, `toUpperCase() ===`, `localeCompare(`, `.sort()`
- The pass shapes: `normalize('NFC')`, `normalize('NFKC')`, `Intl.Collator`, `Intl.Segmenter`,
  `\p{L}`, `\p{Letter}` with the `u` flag
- Length and truncation: `.length`, `substring(`, `slice(`, `truncate(` over user text
- `parseFloat(`, `Number(` over a text input value; strip or replace over a display name

### Actually Fails

- **A Latin-only regex on a name field.** A person is told their own name is invalid, the most
  personal rejection a form can deliver. Evidence: the regex at `file:line` and the field it
  guards.
- **A five-digit postal-code rule applied to every country.** Every reader outside that country is
  blocked at the last step of a purchase. Evidence: the rule at `file:line` and the absence of a
  country branch.
- **A phone field with a national-format regex and no country selection.** Evidence: the regex or
  the fixed `maxLength`, plus the markup showing no country control.
- **A non-UTF-8 column or connection.** Names and addresses are mangled on the way into storage,
  and the damage is not reversible. Evidence: the schema or connection charset quoted.
- **Case-insensitive comparison via `toLowerCase()` on user text.** Turkish maps the dotted and
  dotless i differently from the default mappings, so two users can collide or fail to match.
  Evidence: the comparison at `file:line` and what it compares.
- **A user-facing character limit counted in code units.** A name with combining marks or an emoji
  is cut mid-cluster and the stored value is broken. Evidence: the `.length` or `substring` call
  and the limit the interface states.
- **Equality or uniqueness over unnormalized user text.** Two visually identical strings compare
  unequal, so a duplicate account is created or a login fails. Evidence: the comparison or the
  unique index, and the grep for `normalize(` returning nothing.

### NOT a Failure

- A single required full-name field with an optional second field. That is the pass shape.
- A country-branched address form where the US shape is one branch among several. Quote the branch
  before flagging it.
- A postal-code rule scoped inside a country branch, matching that country's real format, and a
  phone field with a country selector, or one that stores a country-qualified number and validates
  loosely on entry.
- `\w` or `[a-z]` on a machine-generated value (a slug, an identifier, a coupon code, a hex
  token), and `toLowerCase()` used to build one rather than to compare.
- `.length` used as a byte or storage bound in a place the user never sees, where the interface
  states a different, cluster-based limit.
- A single-country product with a recorded `Decision` naming that scope, for the address and phone
  rows. The Unicode-handling rows still run.
- A locale-scoped honorific list with a blank option and a free-text alternative, and a
  `type="number"` input for a genuinely numeric quantity, which needs no localized parse.

### Context Check

1. Does the form accept submissions from outside one country? Its own routing, its shipping
   options and its payment methods answer this before you flag an address rule.
2. Is the rule client-side, server-side, or both? Say which one you read.
3. Is the text machine-generated or user-supplied? Character classes over machine values are fine.
4. Is `toLowerCase()` comparing, or transforming? Only comparison is the finding.
5. Does the storage layer normalize on write? A database or search index that normalizes may make
   an application-level gap harmless; read it before asserting a collision. And is the stated
   character limit the one the code enforces? The finding is that mismatch.
6. Is there a recorded `Decision` scoping the market? If so the locale-scoped findings run as
   readiness and cap at **Low**, with the Fix "revisit the decision or accept the trade-off", and
   the Unicode-handling rows do not cap. That readiness cap is separate from the declared-intent
   tension rule: where a best-practice fix would contradict a recorded `Decision` on some other
   axis — a stored data shape, a fixed input format — the finding stays a Finding and caps at
   **Medium**, citing `BLUEPRINT.md:line` beside the surface evidence.

### Severity

One tier per failure shape. `Critical` is not used in this category; it is reserved for Level A
accessibility failures that block a task.

- **High** — Latin-only name rules, both name fields required, a US-shaped address form or postal
  rule applied to every country, national-format phone validation with no country selection, a
  non-UTF-8 document, column or connection, unnormalized comparison or uniqueness, `\w` and
  `[a-z]` over user text, and case-mapped comparison.
- **Medium** — name minimum lengths and assumed name order, code-unit length limits and
  truncation, collation without a locale, accent-insensitive expectations with no collator,
  calendar assumptions in date entry, unhandled display-name characters, `parseFloat` on localized
  input. Also the cap under the declared-intent tension rule, where a best-practice fix would
  contradict a recorded `Decision` on an axis other than market scope; the market-scope case is
  the readiness cap on the Low tier below, not this one.
- **Low** — culture-bound honorific lists, and every locale-scoped finding on a single-country
  product with a recorded scope `Decision`, reported as readiness.

### Fix guidance

Stop describing people and start bounding input. Almost every rule in this category gets shorter
when it stops trying to predict what a valid person looks like.

```js
// Before: four theories about people, one line each.
if (!/^[A-Za-z ]{2,}$/.test(lastName))      return 'Enter a valid last name';
if (!/^\d{5}(-\d{4})?$/.test(zip))          return 'Enter a valid ZIP code';
if (a.email.toLowerCase() === b.email.toLowerCase()) return 'Account exists';
const preview = displayName.substring(0, 20);
```

```js
// After: a bound, a country-scoped rule, a normalized comparison, a cluster-safe cut.
if (fullName.trim().length === 0 || fullName.length > 200) return 'Enter your name';
if (!postalRuleFor(country).test(postalCode))              return postalHintFor(country);

const fold = s => s.normalize('NFC').trim();               // UAX #15 canonical composition
const same = new Intl.Collator(locale, { sensitivity: 'accent' })
  .compare(fold(a.email), fold(b.email)) === 0;            // no case mapping in the comparison

const segmenter = new Intl.Segmenter(locale, { granularity: 'grapheme' });
const preview = [...segmenter.segment(displayName)].slice(0, 20)
  .map(s => s.segment).join('');                           // UAX #29 clusters, never split
```

```sql
-- The storage layer has to agree. Four-byte UTF-8 end to end, on the column and the connection.
ALTER TABLE users
  MODIFY full_name VARCHAR(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL;
```

Four rules carry the rest. **A name field is bounded, not described**: a length bound and a
non-empty check, one required field, and no character class. **The address form is a function of
the country**: the selected country picks the field set, the order, the labels and the postal rule,
and a country without postal codes does not show the field. **Comparison is normalized before it is
compared**, and case-insensitivity comes from a collator's sensitivity rather than from a case
mapping, because the Turkish dotted and dotless i do not survive the default mappings. **Anything
the user counts is counted in grapheme clusters**, and truncation cuts on cluster boundaries.

Store phone numbers in a country-qualified form with the country beside them, and keep entry
validation loose. Do not tighten a validation rule as part of this fix, and do not delete a stored
value a stricter rule would now reject. Report both and let the user decide.

### Reference

- Unicode Standard Annex #15, Unicode Normalization Forms (NFC, NFD, NFKC, NFKD), and why
  normalization is what makes canonically equivalent strings compare equal:
  https://www.unicode.org/reports/tr15/
- Unicode Standard Annex #29, Unicode Text Segmentation, which defines the extended grapheme
  cluster as the unit a user perceives as a character, including emoji sequences and combining
  marks: https://www.unicode.org/reports/tr29/
- `Intl.Collator`, including the `sensitivity` option for accent- and case-insensitive comparison,
  and why collation order differs by language:
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/Collator
- `String.prototype.toLocaleUpperCase`, which documents the Turkish case-mapping difference that
  makes the default mappings unsafe for comparison:
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/toLocaleUpperCase
- ECMA-402, the specification behind `Intl.Collator` and `Intl.Segmenter`: https://tc39.es/ecma402/

Facts verified 2026-09-03 against unicode.org, developer.mozilla.org and tc39.es.
