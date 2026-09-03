# Scan Selection

Everything between "the user asked for an accessibility audit" and "the categories are locked in".
SKILL.md carries the summary; this file is authoritative for the menu, the preset resolution rule,
the confirm gate, the alias table and the token estimate. **Read it before showing the menu.**

Category numbers, slugs, groups and status all resolve against `categories/_index.md`, which is the
manifest of record. This file stores no ID lists. If a preset here and the manifest ever disagree,
the manifest wins and this file is the defect.

---

## The menu (STEP 1)

Display when the user asked for an audit without naming a scope:

```
Accessibility, legal exposure & i18n readiness audit for [project or domain]

What would you like to audit?

[1] Quick — the cheap static checks demand letters cite most. Group: quick
[2] WCAG 2.2 AA — full criterion sweep, every A and AA criterion accounted for. Group: wcag-aa
[3] Legal exposure — ADA / Section 508 / EAA / AODA / PSBAR posture, statement, overlays, documents. Group: legal
[4] i18n readiness — strings, plurals, formatting, bidi, routing, catalogs, input assumptions. Group: i18n
[5] Forms — labels, errors, ARIA wiring, autocomplete, input and data assumptions. Group: forms
[6] Media and documents — captions, transcripts, audio control, linked PDFs and Office files. Group: media
[7] Full — every active category
[8] Custom — name categories by number, slug or alias

[0] Exit

Enter your choice (0-8):
```

Show the resolved category count and token estimate for each option beside it, computed at display
time from the manifest with the rule below. Never hardcode those numbers into this file — a manifest
row changing status must change the menu automatically.

## Menu behavior

- **[0]** display `Audit cancelled. No changes made.` and exit.
- **[1] to [6]** resolve the named group per the rule below and go to the confirm gate.
- **[7]** every active row. Show the token estimate and require an explicit confirmation of the
  budget before launching.
- **[8]** ask for the selection, parse it with the alias table below, and go to the confirm gate.
- **Invalid input** display `Invalid choice. Enter 0-8.` and re-display the menu.
- **Arguments already given** skip the menu, parse them, and go straight to the confirm gate.

### When the menu must fire, and when it may be bypassed

- **Bypass allowed — the scope is explicit.** "run the quick audit", "full WCAG sweep", "check our
  EAA exposure", "audit the forms", "i18n readiness only", "just contrast and alt text", "run
  categories 4 and 10". The user named a preset or a category list. Proceed without the menu, but
  still show the confirm gate.
- **Menu required — the scope is ambiguous.** "run it", "audit this", "is this accessible", "check
  a11y", "what would fail", "we got a letter". The user wants something audited but has not picked a
  scope. Show the menu and wait.

When in doubt, show the menu. Tokens spent on the wrong scope cost far more than the menu does.

---

## Preset resolution

A preset resolves to **every active row in `categories/_index.md` whose Groups cell contains that
preset's slug**. Read the manifest at scan time and resolve by attribute. Never store, cache or
hardcode an ID list, here or anywhere else.

```
selected = [row.id for row in manifest
            if row.status == "active"
            and preset_slug in row.groups]
```

The six group slugs are `quick`, `wcag-aa`, `legal`, `i18n`, `forms`, `media`. `full` is a
distinct case: every active row, regardless of Groups.

Consequences that matter:

- A category added to the manifest with `quick` in its Groups cell joins the Quick audit with no
  edit here.
- A category whose Status changes to `merged→NN`, `moved→snitch-<skill>` or `deleted` leaves every
  preset automatically, and its number stays reserved.
- A preset that resolves to zero active rows is reported as such and the menu says so, rather than
  silently running nothing.

A preset is a starting point, not a lock. After resolution the user can add or remove categories at
the confirm gate.

---

## The confirm gate

Always fires, for every path into the audit including an explicit request and a bypass. Display:

```
Resolved selection: <preset name or "Custom">

  Cat 01  text-alternatives              criterion       WCAG 2.2 1.1.1, 1.4.5
  Cat 03  structure-and-relationships    criterion       WCAG 2.2 1.3.1, 1.3.2, ...
  ...

  Categories: N of M active
  Criterion coverage: this selection can produce findings against K of the 55 WCAG 2.2 A/AA
    criteria. The other 55-K will appear in the report's coverage block as Skip with a reason.
  Mode: source | crawl | both
  Page set: <the 5-10 pages from STEP 0.5>
  Locales in scope: <from the STEP 0.5 i18n inventory>
  Runtime checks: <runner available | no runner; runtime-only rows will Skip>
  Estimated cost: ~<low>-<high>K tokens

Proceed? [yes / add <cats> / remove <cats> / change scope / cancel]
```

Rules for the gate:

- **The criterion-coverage line is required** whenever the selection includes a criterion-typed
  category. It is the thing that stops a partial sweep reading like a full one. A selection that
  covers 14 of 55 criteria must say so before it runs, not only afterwards.
- **`add` and `remove`** re-resolve and re-display the gate. There is no limit on rounds.
- **`change scope`** returns to STEP 0.5's page set and locale inventory.
- **`cancel`** exits with `Audit cancelled. No changes made.`
- Proceed only on an affirmative. Silence is not confirmation.

---

## Token estimate

```
estimate_low  = 5K + (1.5K * number_of_categories)
estimate_high = 5K + (1.5K * number_of_categories * 1.6)
```

5K is the fixed overhead: the anti-hallucination rules, smart detection, discovery, the scan
selection itself and the report scaffold. 1.5K per category is the category file plus its search and
read work in source mode.

Multipliers, applied to the high end and stated in the gate when they apply:

- **Crawl mode** adds ~2-4K per fetched page in the page set, because each page's HTML is read.
- **A large surface** (more than ~200 routes, or more than ~5 locales) pushes every category to the
  high end.
- **`references/legal-landscape.md`** adds ~4K once, when any compliance-typed category is selected.
- **`references/wcag-criterion-map.md`** adds ~3K once, when any criterion-typed category is
  selected or whenever the report's coverage block is written.

Round the displayed estimate to the nearest thousand and always show it as a range. An estimate is a
budget warning, not a promise.

---

## Alias table (Custom selection, `[8]`)

Parse a custom selection in this order: exact category ID, exact slug, then alias. Matching is
case-insensitive and ignores surrounding punctuation. A phrase that matches nothing is reported back
to the user with the closest three candidates rather than guessed at.

| The user says | Category |
|---|---|
| `alt text`, `alt`, `image alternatives`, `images of text`, `non-text content` | 01 |
| `captions`, `transcripts`, `subtitles`, `video`, `audio`, `autoplay audio` | 02 |
| `headings`, `landmarks`, `semantics`, `structure`, `tables`, `autocomplete`, `input purpose`, `orientation` | 03 |
| `contrast`, `color`, `colour`, `color contrast`, `color only`, `non-text contrast` | 04 |
| `reflow`, `zoom`, `resize`, `text spacing`, `tooltips`, `hover content`, `320px` | 05 |
| `keyboard`, `focus`, `focus order`, `focus visible`, `keyboard trap`, `tab order`, `shortcuts` | 06 |
| `target size`, `touch targets`, `tap targets`, `24x24`, `pointer`, `gestures`, `drag`, `label in name`, `motion actuation` | 07 |
| `timing`, `timeout`, `session timeout`, `carousel`, `autoplay`, `animation`, `flashing`, `marquee` | 08 |
| `navigation`, `skip link`, `bypass blocks`, `page title`, `link purpose`, `link text`, `multiple ways`, `consistent help`, `consistent navigation` | 09 |
| `forms`, `labels`, `errors`, `error messages`, `validation`, `redundant entry`, `captcha`, `accessible authentication` | 10 |
| `aria`, `screen reader`, `accessible name`, `name role value`, `roles`, `live regions`, `status messages`, `toasts` | 11 |
| `lang`, `language attribute`, `language of page`, `language of parts` | 12 |
| `ada`, `title ii`, `title iii`, `508`, `section 508`, `vpat`, `acr`, `eaa`, `european accessibility act`, `aoda`, `psbar`, `legal`, `exposure`, `demand letter` | 13 |
| `accessibility statement`, `statement`, `overlay`, `overlays`, `accessibility widget`, `feedback channel` | 14 |
| `pdf`, `documents`, `downloads`, `office`, `docx`, `pptx`, `xlsx`, `pdf/ua` | 15 |
| `hardcoded strings`, `string externalization`, `untranslated strings`, `strings in code`, `extraction` | 16 |
| `plurals`, `icu`, `messageformat`, `gender`, `select`, `concatenation`, `sentence assembly`, `cldr` | 17 |
| `dates`, `times`, `numbers`, `currency`, `units`, `time zones`, `intl`, `formatting`, `locale formatting` | 18 |
| `rtl`, `bidi`, `right to left`, `logical properties`, `text expansion`, `arabic`, `hebrew`, `cjk`, `typography` | 19 |
| `language switcher`, `locale routing`, `locale negotiation`, `accept-language`, `locale persistence`, `bcp 47` | 20 |
| `missing translations`, `catalog`, `catalogs`, `translation files`, `placeholder parity`, `stale keys`, `po files` | 21 |
| `unicode`, `collation`, `sorting`, `name fields`, `address fields`, `phone fields`, `normalization`, `grapheme` | 22 |

Group aliases resolve to the preset, not to a category: `quick`, `wcag`, `wcag aa`, `aa`, `legal`,
`i18n`, `l10n`, `internationalization`, `localization`, `forms`, `media`, `full`, `everything`.

Two phrases belong to a sibling skill and are handed off rather than resolved here:

- `hreflang`, `locale canonical`, `alt text for SEO`, `translated content quality` → call the Skill
  tool with "snitch-marketing".
- `is this confusing`, `can a user finish this`, `usability` → call the Skill tool with "snitch-ux".
