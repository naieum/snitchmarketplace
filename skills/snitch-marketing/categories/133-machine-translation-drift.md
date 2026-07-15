## CATEGORY 133: Machine-translation quality drift (localized content quality)

Localization is a promise to a reader in another language: this page was made for you.
Raw machine translation shipped with no human review breaks that promise quietly. Output
drifts in quality over time and across locales: awkward or wrong phrasing, pages that are
only half translated (source-language strings left sitting in a non-source locale), merge
tokens like `{name}`, `%s`, or `{{count}}` left raw on the page, dates and currencies in
the wrong convention for the region, mojibake where the encoding broke, and copy that is
grammatically fine but culturally off. Google's quality guidance treats low-quality
auto-translated content as a content-quality problem, and it erodes trust with the exact
users the localization was meant to serve. This category audits the content quality of
translated and localized pages, not whether the locales are wired up correctly.

One honest limit up front: an automated audit cannot reliably judge fluency in a language
it does not read. So this category draws a hard line. It flags objective, detectable
problems with confidence (untranslated fallback strings, broken interpolation tokens, wrong
locale formats, encoding errors, coverage gaps) because those are verifiable from the bytes
on the page. For anything that needs a native ear (does this read naturally, is the tone
right, is the idiom correct), it asserts no verdict and recommends a native human reviewer
instead. Confidence tracks what can be proven.

Scope note: this audits the content quality of translated pages. It is distinct from Cat 50
(hreflang correctness, the targeting and annotation syntax), Cat 51 (locale canonicals), and
Cat 52 (the `lang` attribute). Those three confirm the locales are wired up and pointed at
the right URLs. This one checks whether the translated content itself is any good. A site
can have flawless hreflang and still ship broken machine translation to every reader who
follows it.

### Pre-flight: relevance check

Skip with reason `not applicable` for a single-locale site (there is no localized content
to audit) and for source-locale-only content that has never claimed to be localized.
Required for any site that serves the same content in more than one language: locale-prefixed
routes (`/de/`, `/fr/`, `/es/`), a framework i18n setup, message catalogs (`locales/*.json`,
`messages.*.json`), or a CMS with locale fields. Borderline (one or two locales, recently
added): run it, scoped to the locales that actually exist. If you cannot determine the source
locale, say so and Skip rather than guess which strings are "untranslated."

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Read `.snitch-marketing-context.md`: which locales does the brand actually ship, what is
   the source locale, and is translation human-reviewed or raw machine output? Ground the
   audit in what the brand claims, not in assumption.
2. Locate the locale content. Find i18n message catalogs and locale content files
   (`locales/<code>/*.json`, `messages.<code>.json`, `/de/` and `/fr/` content directories).
   List which locales actually exist.
3. Sample and compare against the source locale. For a handful of keys, pull the
   source-locale value and the target-locale value side by side. Flag:
   - **Untranslated fallback:** the target value is byte-identical to the source-language
     text (an English string sitting in a `/de/` value).
   - **Coverage gaps:** keys present in the source catalog, missing or empty in the target
     catalog (the UI falls back to source language at runtime).
   - **Raw interpolation tokens:** `{name}`, `%s`, `%1$s`, `{{count}}`, `<0>...</0>`, or ICU
     plural/select blocks flattened or left literal.
   - **Format mismatches:** USD or `$` on a `/de/` page, `MM/DD/YYYY` on a European locale,
     decimal/thousands separators in the wrong convention, address order or units baked into
     the string.
   - **Encoding errors:** mojibake (`Ã©` for `é`, `â€™` for an apostrophe) or replacement
     characters (`�`).
   Quote the exact string, its key, and its file path for every finding.

**Crawl mode, required tool calls:**

1. Fetch the locale URLs (follow hreflang or the locale switcher). For each, inspect the
   rendered copy for the same detectable issues: source-language strings on a non-source
   locale page, raw `{...}` or `%s` tokens visible to the reader, wrong currency or date
   format, mojibake.
2. Compare a few rendered strings against the source-locale version of the same page. Quote
   the string and both URLs.
3. Do not score fluency from the crawl. If the only thing you can say is "this might read
   awkwardly," record it as a recommendation to have a native speaker review, not as a
   finding. If a mode cannot run (no locale files found in source; locale URLs unreachable in
   crawl), Skip that mode with the reason stated.

### Forbidden claims

- "The German copy reads awkwardly / is low quality." You cannot reliably evaluate fluency in
  a language you do not read. Only flag objective issues (untranslated strings, broken tokens,
  wrong formats, encoding errors) with quoted evidence; for fluency, recommend a native
  reviewer.
- "This whole locale is machine-translated." Unless the context file says so or a visible tell
  proves it (raw tokens, many target values identical to source), do not assert the production
  method.
- "The numbers and dates are wrong." Quote the exact string and the locale URL/file, and name
  the convention it violates (for example `$1,000.00` on a `/de/` page where the locale uses
  `1.000,00 €`).
- Never paraphrase the offending string. Quote it verbatim with its locale URL or file path.
  The evidence is the exact bytes.

### Detection

Side-by-side source-vs-target comparison of sampled strings, plus objective-issue detection
(untranslated fallbacks, raw interpolation tokens, format-convention mismatches, encoding
errors, coverage gaps), grounded in the context file's declared locales and source language.
Fluency is out of scope for a verdict and is routed to a native reviewer.

### What to Search For

- Source-language text sitting in a non-source-locale value or page (`"Sign up"` as the `/de/`
  string)
- Raw merge tokens in rendered copy or catalog values: `{name}`, `{{count}}`, `%s`, `%1$s`,
  `<0>...</0>`
- Currency/number/date/unit formats that don't match the locale (USD on `/de/`, `MM/DD/YYYY`
  on `/fr/`, miles on a metric locale)
- Mojibake and replacement characters (`Ã`, `â€`, `�`) in locale content
- Keys present in the source catalog but missing or empty in a target catalog (runtime
  fallback to source language)
- Target values byte-identical to source values across many keys (a sign the locale was never
  actually translated, only copied)
- ICU plural/select blocks rendered literally instead of resolved

### Actually Hurts the Marketing Surface

- **A large indexed locale surface with untranslated strings visible to readers and Google.**
  The page promises a localized experience and delivers source-language fragments; trust drops
  on the first screen, and Google sees thin, mixed-language content.
  Evidence required: the quoted source-language string + its locale URL/file, and the sample
  size or count of affected pages.
- **Broken interpolation tokens on the page.** A raw `{name}` or `%s` tells the reader the
  page is unfinished and breaks the sentence's meaning, not just its polish.
  Evidence required: the quoted string with the raw token + its locale URL/file.
- **Wrong locale formats on a conversion page.** Currency, date, or number conventions that
  don't match the region on pricing, checkout, or sign-up copy create doubt at the exact
  moment of the decision.
  Evidence required: the quoted value + the locale URL + the convention it violates.
- **Coverage gaps that fall back to source language at runtime.** Keys missing from the target
  catalog mean the reader silently gets English in the middle of a German page.
  Evidence required: the keys present in source and missing/empty in target, with file paths.
- **Encoding errors in locale content.** Mojibake makes the copy look broken regardless of how
  good the underlying translation is.
  Evidence required: the quoted garbled string + its locale URL/file.

### NOT a Problem

- Professionally human-translated or human-reviewed content. Fluency is the translator's job;
  don't second-guess a native review you can't perform.
- Intentionally untranslated brand terms, product names, or proper nouns. A brand name staying
  in its original form across locales is correct, not a gap.
- A single-locale site (Skip; pre-flight not applicable).
- Source-locale-only content that has never claimed to be localized. Not every page needs a
  translation.
- A few keys deliberately left in the source language because that is the accepted term in the
  target market (loanwords, established technical terms). Confirm intent before flagging.

### Context Check

1. Which locales does the brand actually ship, and which is the source language? (From the
   context file, not assumed.)
2. Is the translation human-reviewed or raw machine output? The fix differs: review the
   machine output, or leave good human work alone.
3. Are the issues objective and detectable (untranslated strings, raw tokens, wrong formats,
   encoding), or are you reaching for a fluency verdict you can't support?
4. Is an untranslated term a gap, or an intentional brand / proper-noun / loanword that should
   stay as-is?
5. How large and how indexed is the affected surface? A few internal strings differ from a
   public, indexed locale shipped to thousands of readers.
6. Do the locale formats (currency, date, number, unit) match the region, especially on
   conversion pages?

### Reference

Google Search guidance on auto-generated and low-quality translated content (treated under
spam/scaled-content and quality guidance). CLDR locale formatting conventions (Unicode Common
Locale Data Repository) for currency, date, number, and unit formats:
https://cldr.unicode.org/

Cross-ref Cat 50 (hreflang correctness), Cat 51 (locale canonicals), Cat 52 (`lang`
attribute). Those check the locales are wired up; this checks the content is good.

**Severity tagging:**
- Large auto-translated, indexed surface with untranslated strings or broken interpolation
  tokens visible to users and Google → High.
- Wrong locale formats (currency/date/number) on conversion pages → Medium.
- Coverage gaps that fall back to source language at runtime → Medium.
- Encoding errors in locale content → Medium.
- Scattered minor issues on low-traffic or non-indexed locales → Low.
- A suspected fluency problem you can't verify → not a finding; recommend a native reviewer
  (note, not a severity).

**Fix voice:** `frank-chimero` (primary) | `mike-monteiro` (backup).

Read `souls/frank-chimero.json` before writing the Fix.

Worked fix example:

> Start with a question: what is this page's relationship to the person reading it? A
> translated page is a promise that someone made this for them, in their language. Right now
> the `/de/` pages keep that promise halfway. There's English sitting in the middle of German
> sentences, and `{firstName}` is showing up raw where a name should be. The reader sees the
> seams. They were told the page was made for them, and it quietly says otherwise.
>
> I can tell you what is objectively broken, and only that. I don't read German well enough to
> judge whether the prose is graceful, so I won't pretend to. What I can show you, with the
> line quoted, is the part that is provably unfinished:
>
> 1. **The untranslated strings.** `locales/de/pricing.json` still holds the English value for
>    `cta.start`. The reader follows a German page and lands on an English button. Pull every
>    key whose target value equals its source value; those were never translated, only copied.
> 2. **The raw tokens.** `{{count}} items` is rendering as `{{count}} items`. The merge never
>    happened. That breaks the sentence, not just the polish. Find every `{...}` and `%s` left
>    standing in a locale value and resolve it.
> 3. **The formats.** Prices read as `$1,000.00` on a page whose readers write `1.000,00 €`.
>    That isn't a translation question, it's a convention one, and CLDR already knows the right
>    shape for every locale. Let the locale decide the format instead of hard-coding the
>    source one.
>
> Fix those first, because they're certain. Then do the thing the tooling can't: have a native
> speaker read the pages end to end. Not to catch what I caught, but to catch what I can't see,
> the phrasing that is correct and still sounds like a stranger wrote it. That read was always
> going to need a person. The tooling gets you to "complete." A human gets you to "made for
> you."
>
> Verify: re-pull the locale catalogs and confirm no target value equals its source value, no
> `{...}` or `%s` survives in rendered copy, and currency, date, and number formats match the
> region. Then ship the native review as its own pass, and treat it as content work, not a
> checkbox.
