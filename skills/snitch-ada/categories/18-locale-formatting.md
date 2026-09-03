## CATEGORY 18: Dates, times, numbers, currency, units and time zones

Formatting is where a product either speaks the reader's language or quietly speaks its own.
`03/04/2026` is the 3rd of April to most of the world and March 4th to the United States, and
nothing on the page says which. `1,234.56` and `1.234,56` are the same amount under two
conventions that disagree about what a comma means. A price built as `"$" + amount` is a US
dollar figure wherever it lands. A timestamp printed from the server's clock is right only for
people sitting near the server.

This category judges whether the format of a date, time, number, currency amount, unit or time
zone is decided by the reader's locale or hardcoded by the developer's. The evidence is the code
that builds the string at `file:line`, or the rendered value at URL + selector. ECMA-402 (the
ECMAScript Internationalization API, the `Intl` object) and the Unicode Common Locale Data
Repository already hold the correct pattern for every locale, so the finding is almost always
that the code did the work itself instead of asking for it. An `Intl` constructor called with no
`locales` argument resolves to the runtime's default locale, which on a server is the server's.

**Boundary.** This category judges the code path that produces the value. The rendered translated
page a reader sees, including a wrong-convention price sitting in translated copy, is judged
against content quality by a sibling: call the Skill tool with "snitch-marketing" for that half.
Whether a date picker or a currency input is pleasant on the reader's decision path is a
different judge again: call the Skill tool with "snitch-ux". Money handled as a float is a
readiness note here and nothing more; for money arithmetic itself, call the Skill tool with
"snitch-security".

### Pre-flight

Read the declared-intent files first (`BLUEPRINT.md`, only *Audience & wedge*, *Conversion
action*, *Claim inventory* and *Constraints*; `marketing/positioning.md`, only "who it's for /
not for" and "claims we never make"). Then:

- A recorded `Decision` such as "English-only at launch" or "US market only at launch" makes this
  category a **Skip** citing that line. Not a Finding. Say which line, and say the category runs
  on the first added locale.
- No such Decision and more than one locale served: run in full.
- No such Decision, **one** locale served, no recorded intent either way: run at **readiness
  severity**. Every finding caps at **Low**, worded as "this will break on the first added
  locale", with the undeclared-intent state named in the finding.
- Neither declared-intent file present is a **Skip** with that reason. Never interview the user
  for their contents.

A single-locale site that serves readers in more than one region (a global product with one
English UI, a shop that ships internationally) still runs: time zones, currency and units break
for those readers even with one language.

### Rule table

| Pattern | What must hold | Static signal | Severity |
|---|---|---|---|
| Hardcoded date format built by string concatenation (`${m}/${d}/${y}`, `MM/DD/YYYY`, `DD.MM.YYYY`) | Date order, separators and field widths come from the locale, not from code | Template literal or `+` chain joining `getMonth`, `getDate`, `getFullYear`; a format-string literal containing `MM/DD` or `DD/MM` | High |
| Month or weekday name array in code (`['Jan','Feb',…]`, `['Mon','Tue',…]`) | Names come from locale data, not a Latin-script English list | An array literal of month or day names, indexed by `getMonth()` / `getDay()` | High |
| `toLocaleDateString()` / `toLocaleTimeString()` / `toLocaleString()` / `Intl.*` called with no `locales` argument on a multi-locale surface | The reader's resolved locale tag is passed explicitly | The call site with an empty or missing first argument | High |
| `Date.prototype.toDateString()` / `toString()` / `toUTCString()` used for display | Display strings come from a locale-aware formatter; these three are fixed English formats | The method name on a value that reaches a template | High |
| Number formatting by string operations (`toFixed(2)` plus a manual thousands separator, a hardcoded `.` or `,`) | Decimal and group separators come from the locale | `toFixed(`, `replace(/\B(?=(\d{3})+(?!\d))/g, ",")`, a literal `','` or `'.'` used as a separator | High |
| Currency symbol prefixed or suffixed in code (`"$" + amount`, `` `${amount} €` ``) | The amount is formatted with a currency formatter carrying the ISO 4217 code, so symbol, position, spacing and decimal count come from the locale | A currency glyph adjacent to an interpolated amount in a template | High |
| Currency amount held as a binary float, or a formatter given a float from cents division | Amounts are held in minor units or a decimal type, and the currency's own minor-unit count decides the decimal places | `parseFloat` / `Number(` on a price, `* 0.01`, a schema column typed `float` / `double` for money | Low (readiness note) |
| Server-local timestamp rendered without conversion | The instant is stored as UTC or with an offset, and converted to the reader's or the record's zone at render | A formatter called with no `timeZone` option on a server-rendered path; `new Date()` formatted directly into markup | High |
| `new Date(string)` parsing non-ISO input | Parsing uses an explicit format with an explicit zone; only ISO 8601 date-time strings parse consistently across engines | `new Date(` with an argument that is not an ISO literal or a number | Medium |
| No user or locale time zone stored or selectable | An account, event or booking that means a wall-clock time carries the zone it means | A user or event schema with a timestamp column and no time-zone column; no zone in the profile form | Medium |
| DST assumed away (a day added as `+ 86400000`, an hour as a fixed offset, a zone stored as `UTC-5`) | Date arithmetic goes through a calendar-aware API or a zone-aware library; offsets are derived from the zone, not stored | `86400000`, `* 24 * 60 * 60 * 1000`, a stored numeric offset used as a zone | Medium |
| Units hardcoded (miles, °F, lb, in, US Letter) | The unit follows the locale's measurement system, or the reader picks it and the choice persists | A unit literal or suffix beside a value; a page-size constant of `letter` in a PDF or print path | Medium |
| First day of week, or a 12-hour clock, hardcoded | Week start and hour cycle come from locale data | A calendar component with a `startOfWeek = 0` constant; an `AM`/`PM` literal in a formatter | Medium |
| Calendar system assumed Gregorian where the audience uses another | Non-Gregorian calendars are at least reachable for the locales that use them | A date component with no calendar option on a surface serving a locale whose default calendar is not Gregorian | Low (advisory) |
| Phone number formatted or masked by code for one national convention | Phone display and input follow the number's own country, not the site's | A regex or mask literal shaped `(###) ###-####`; see Category 22 for the validation half | Medium |
| Relative time assembled from English fragments (`"3 days ago"`, `` `${n} days ago` ``) | Relative time comes from a locale-aware relative-time formatter with its own plural handling | A template joining a number with a hardcoded `ago` / `in` / `days` | High |
| Dates sorted or compared as formatted strings | Sorting and comparison run on the underlying instant, never on the display string | A comparator over values produced by a formatter; a table column sorted on rendered text | Medium |

### Evidence required

**Source mode, cheapest first:**

1. `Grep` the formatter call sites: `toLocaleDateString`, `toLocaleTimeString`, `toLocaleString`,
   `Intl.DateTimeFormat`, `Intl.NumberFormat`, `Intl.RelativeTimeFormat`. Read each hit and
   record whether a locale tag is passed first and where it comes from. A hit with a literal
   `'en-US'` on a multi-locale surface is the same finding as a hit with nothing.
2. `Grep` the hand-rolled formatters: `getMonth()`, `getDate()`, `getFullYear()`, `toFixed(`,
   `toDateString`, `toUTCString`, `86400000`, `parseFloat`, and the literals `MM/DD` and `DD/MM`
   inside a format string. Quote the line that builds the string.
3. `Grep` currency: a `$`, `€`, `£`, `¥` or `₹` glyph next to an interpolated value, plus
   `currency`, `USD`, `price`, `amount`. Read the template and quote the concatenation.
4. `Grep` units and page sizes: `miles`, `mi`, `km`, `°F`, `°C`, `lbs`, `kg`, `Letter`, `A4`.
5. `Grep` time-zone handling: `timeZone`, `tz`, `UTC`, `offset`, `Date.now()`, `new Date()`, and
   read the schema or migrations for a timestamp column with no zone column beside it.
6. Read the i18n setup the detection reference identified and record which locale tag the app
   resolves per request and whether the call sites receive it. A framework that resolves a locale
   and never passes it to a formatter is still a finding.

**Crawl mode, cheapest first:**

1. Fetch one page per served locale that renders a date, a price and a number, and quote each
   rendered value with its selector.
2. Compare each against the convention the locale uses, naming the convention and where it comes
   from. `$1,000.00` on a `/de/` page is a finding; quote the value and the locale route.
3. Check whether the same instant renders differently under a different client zone. If you
   cannot vary the client zone, record `Skip — time-zone conversion requires a runner that can
   vary the client zone; not run`.

**Rendered-value caveat, applies to every static check here:** source reads return the call, not
its output. A wrapper may inject the locale one layer up and a build step may replace the
formatter. Trace the argument to its source before asserting the value is wrong, and say in the
finding when the resolution is ambiguous.

### Forbidden claims

- "Dates may be formatted for the wrong locale." Quote the line that builds the string, or the
  rendered value and its selector, or Skip with the reason.
- "The locale is probably not passed through." Trace the argument. If the trace ends in a wrapper
  you cannot resolve, write what you traced, what you could not, and lower the confidence.
- "This site is not localization-ready", and never "compliant", "conformant" or "non-compliant"
  as a verdict. Name the pattern and the call site and let the reader draw the line.
- "This will break for users in Europe." Say which convention differs and quote both the code and
  the convention. A named convention is evidence; a named continent is not.
- "The currency is wrong." A price in the seller's currency is a pricing decision. The finding is
  that the *format* is fixed in code, not that the currency is.
- "Floats will lose money here." This category does not judge money arithmetic. Record the float
  as a readiness note and name the sibling that judges it.
- Any WCAG success criterion number attached to a finding here. This is an i18n-readiness
  pattern, not a criterion. A check with no row in the table above is a Skip.

### Detection

Static trace from every formatter call site and hand-rolled format string to the locale tag that
reaches it, plus a schema read for stored time zones and money types. Crawl mode compares the
rendered value against the locale's convention. Only time-zone conversion under a varied client
zone needs a runner; it Skips with its reason when none is available.

### What to Search For

- `toLocaleDateString`, `toLocaleTimeString`, `toLocaleString`, `Intl.DateTimeFormat(`,
  `Intl.NumberFormat(`, `Intl.RelativeTimeFormat(` with an empty or hardcoded first argument
- `toDateString`, `toUTCString`, `Date().toString()` reaching a template
- `getMonth()`, `getDate()`, `getFullYear()` inside a template literal or `+` chain, and month or
  weekday name arrays (`'Jan'`, `'January'`, `'Mon'`, `'Monday'` in an array literal)
- `toFixed(`, `replace(/\B(?=(\d{3})+(?!\d))/g`, a bare `','` or `'.'` used as a separator
- A currency glyph adjacent to an interpolation: `+ amount`, `+ price`, `` ${amount} ``
- `86400000`, `* 24 * 60 * 60 * 1000`, `UTC-`, `GMT+`, a stored numeric `offset`, `new Date(`
  with a non-ISO string argument
- `miles`, `°F`, `lbs`, `Letter` (page size), `startOfWeek`, `'AM'`, `'PM'`, and `' ago'`,
  `' days'` or `' hours'` joined to a number

### Actually Fails

- **A date built by string concatenation on a multi-locale surface.** The reader gets the
  developer's field order, and an ambiguous date is worse than an unfamiliar one because it looks
  correct. Evidence: the concatenation at `file:line`, the locales served, and the convention
  each served locale uses.
- **A formatter called with no locale on a server-rendered path.** The resolved locale is the
  server's, so every reader gets the same format regardless of who they are. Evidence: the call
  site at `file:line`, the trace showing no tag is passed, and the path proving it runs on the
  server.
- **A currency amount assembled with a hardcoded symbol.** Symbol, position, spacing and
  decimal-place count all vary by locale and by currency, and the concatenation fixes all four.
  Evidence: the template at `file:line` and the served locales.
- **A number formatted with a hardcoded group or decimal separator.** `1,234.56` reads as one
  thousand two hundred to some readers and as one point two to others. Evidence: the separator
  literal at `file:line` and the rendered sample.
- **A timestamp rendered in the server's zone with no conversion.** Meeting times, deadlines and
  delivery windows land an hour or a day off for everyone outside that zone. Evidence: the
  formatter call with no `timeZone` option plus the schema line showing no zone is stored.
- **Relative time assembled from English fragments.** The string cannot be translated without
  rewriting code, and the plural form is wrong in every language with more than two categories.
  Evidence: the assembly at `file:line`; cross-reference Category 17 for the plural half.

### NOT a Failure

- A formatter called with an explicit locale tag resolved per request, including a single-locale
  site that passes its one tag explicitly. Explicit is the pass shape, not multi-locale.
- ISO 8601 (`2026-09-03T14:00:00Z`) on machine surfaces: `<time datetime>`, API payloads,
  filenames, log lines, sort keys, `input[type=date]` values. ISO is locale-independent by design
  and is correct there.
- A framework or design-system formatter that takes the locale from context. Trace it once,
  record the pass with the trace as its evidence, and stop flagging its call sites.
- A currency deliberately fixed for the business (one seller, one settlement currency). Only the
  hardcoded *format* is the finding.
- A hardcoded unit that is the thing being measured rather than a preference: a `1080p` label, a
  `16 px` design token, a physical spec on a product page.
- Money held in minor units as an integer or in a decimal type, a duration in a fixed engineering
  format (`00:04:32`), and a UTC timestamp carrying an explicit `UTC` label on an audit surface.

### Context Check

1. Which locales are served, and which one is the source? Ground the check in the discovery
   inventory, not in the routes you happen to have seen.
2. Does the app resolve a locale per request at all? If it does not, the formatter findings are
   symptoms and the resolution gap is the finding to lead with.
3. Does the value reach a human or a machine? ISO on a machine surface is correct; ISO inside a
   sentence a reader reads is a different question.
4. Is the surface server-rendered or client-rendered? A missing locale argument on the client at
   least resolves to the reader's browser locale; on the server it resolves to the server's.
5. Does the timestamp mean an instant (a log entry) or a wall-clock time in a place (a store's
   opening hour, a scheduled call)? The second needs a stored zone; the first does not.
6. Is the unit a preference or a specification, and is there a recorded `Decision` fixing the
   format deliberately? Only preferences are findings, and a Decision caps the finding at Medium
   with the Fix "revisit the decision or accept the trade-off".

### Severity

One tier per failure shape. `Critical` is not used in this category; it is reserved for Level A
accessibility failures that block a task.

- **High** — a formatter with no locale, a hand-built date, a hardcoded currency symbol, a
  hardcoded separator, or English-fragment relative time, on a surface serving more than one
  locale or more than one region.
- **Medium** — time-zone gaps (no stored zone, DST assumed away, non-ISO parsing), hardcoded
  units, week start or hour cycle, phone formatting fixed to one convention, sorting on formatted
  strings. Also the cap for any finding contradicting a recorded `Decision`.
- **Low** — calendar-system assumptions, money held as a float, and every finding on a
  single-locale site with no declared intent (the readiness case from Pre-flight).

### Fix guidance

Stop building the string. The locale data already exists in the runtime; pass the reader's locale
into it and let it decide the shape.

```js
// Before: three conventions hardcoded in four lines.
const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
const shipDate = `${months[d.getMonth()]} ${d.getDate()}, ${d.getFullYear()}`;
const total = '$' + amount.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',');
const when = `${daysSince} days ago`;

// After: one locale tag, three formatters, zero conventions in the code.
const shipDate = new Intl.DateTimeFormat(locale, {
  dateStyle: 'medium', timeZone: viewerTimeZone,   // the reader's zone, or the record's
}).format(shipInstant);
const total = new Intl.NumberFormat(locale, {
  style: 'currency', currency: currencyCode,       // ISO 4217: 'USD', 'EUR', 'JPY'
}).format(amountMinorUnits / 100);                 // minor units in, one division at the edge
const when = new Intl.RelativeTimeFormat(locale, { numeric: 'auto' })
  .format(-daysSince, 'day');                      // plural category handled by the formatter
```

Three rules make this stick. **`locale` is a parameter, never a default:** resolve it once per
request and let a lint rule fail any `Intl` or `toLocale*` call with no first argument. **Store
instants in UTC with the zone beside them:** an IANA zone identifier (`Europe/Berlin`, not
`UTC+1`) is what makes daylight-saving arithmetic correct, and offsets are derived at render,
never stored. **Money stays in minor units:** divide once at the formatter and let the currency's
own minor-unit count set the decimal places, because Japanese yen has none and several currencies
have three.

Where the codebase already uses a locale-aware date or number library, use its equivalents rather
than mixing two systems, and pass the same resolved tag. Do not change a displayed currency, a
rounding rule, or a stored money type as part of a formatting fix. Those are product and finance
decisions; report them and let the user decide.

### Reference

- ECMA-402, the ECMAScript Internationalization API Specification (the `Intl` object, the
  `locales` argument, and the ISO 4217 currency codes `Intl.NumberFormat` takes):
  https://tc39.es/ecma402/
- Unicode Common Locale Data Repository: https://cldr.unicode.org/
- `Intl.DateTimeFormat`, including the rule that an undefined `locales` argument resolves to the
  runtime's default locale and an omitted `timeZone` resolves to the runtime's time zone:
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/DateTimeFormat/DateTimeFormat
- `Intl.NumberFormat` and `Intl.RelativeTimeFormat`:
  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat

Time zones use the IANA time zone database identifiers (`Europe/Berlin`, `America/Sao_Paulo`)
that ECMA-402 accepts in the `timeZone` option. Facts verified 2026-09-03 against tc39.es,
cldr.unicode.org and developer.mozilla.org.
