## CATEGORY 12: Language of page and of parts

Two criteria, one attribute, and a much larger consequence than the size of the fix suggests. A screen reader picks its pronunciation rules from the declared language. Without `lang`, it guesses — usually from the user's own system setting — and reads French copy with English phonemes, which is not an accent but noise. With the wrong `lang`, it does the same thing confidently. Braille contraction, hyphenation, the browser's translation offer, and text-to-speech in every assistive tool all read the same attribute.

This category is the bridge between accessibility and internationalization, and it is deliberately placed at the seam. 3.1.1 and 3.1.2 are WCAG criteria and are judged here as criteria. The same attribute, on a site that ships more than one locale, is also the first thing that breaks when locale routing is wrong — which is why the i18n categories in this skill start from what this one finds.

**Boundary.** This category judges `lang` against 3.1.1 and 3.1.2: can the human language of the page, and of each foreign-language passage inside it, be programmatically determined. The **same attribute judged as a search and machine-readability signal** belongs to the sibling — call the Skill tool with "snitch-marketing", whose Category 52 owns it there. `hreflang` annotations and locale canonicals, which tell search engines about the alternates rather than telling assistive technology about this page, are also that sibling's, in its Categories 50 and 51. Whether a person can reach and stay in their own language is Category 20 of this skill, and the quality of the translated prose on a rendered page is again marketing's. Cross-file; never merge these into one claim.

### Pre-flight

Run on every surface. The check costs one read of the document element and one pass over the body copy, and 3.1.1 is one of the most-cited failures in automated scan output.

Skip 3.1.2 with reason `no foreign-language passages found in the audited content` when the body copy is single-language throughout, and say what was read to establish that. Never Skip 3.1.1: a page either declares a language or it does not.

Where the workspace declares `BLUEPRINT.md` intent, read it first. A recorded `Decision` such as "English-only at launch" does **not** exempt 3.1.1 — a single-language site still has to declare its one language — but it does make the multi-locale checks below Skip with that reason rather than emit findings.

### Rule table

One row per success criterion. A finding names its row. A language check with no row here is a Skip, never a finding under a borrowed SC.

| SC | Level | What must hold | Static signal (source / DOM) | Runtime-only? | Severity |
|---|---|---|---|---|---|
| 3.1.1 Language of Page | A | The default human language of each page can be programmatically determined | `<html>` with no `lang`; `lang` holding a non-BCP 47 value (`lang="english"`, `lang="en_US"` with an underscore, `lang=""`, `lang="x-default"`); a hardcoded `lang` on a site that serves more than one locale; a `lang` value that contradicts the page's actual content language; `xml:lang` alone in an HTML5 document | No | High |
| 3.1.2 Language of Parts | AA | The human language of each passage or phrase in the content can be programmatically determined, except proper names, technical terms, words of indeterminate language, and words that have become part of the vernacular of the surrounding text | a block quote, testimonial, product description, legal notice, address or navigation label in a language other than the page's, carrying no `lang` on its own element; a language-switcher option list whose items name languages in their own language with no per-item `lang`; inline transliterations and glossed foreign phrases with no markup | No | Medium |

**The exceptions to 3.1.2, stated as the criterion states them.** No `lang` is required for proper names, technical terms, words of indeterminate language, or words and phrases that have become part of the vernacular of the immediately surrounding text. A product called *Bonjour*, the word *croissant* in an English sentence, and *schadenfreude* in ordinary English prose all need nothing. A full French paragraph, a Spanish testimonial, or an Arabic address block does.

**`xml:lang` alone is not sufficient in HTML5.** HTML parsers read `lang`. Where a document is served as `text/html`, `xml:lang` without `lang` leaves the language undeclared for the assistive technology that matters. In XHTML served as XML, both are required. Say which serialization you are looking at before writing the finding.

**Valid values are BCP 47 language tags.** A primary subtag, optionally a script subtag, optionally a region subtag, joined by hyphens: `en`, `en-GB`, `pt-BR`, `zh-Hans`, `sr-Cyrl-RS`. Not underscores, not full language names, not locale identifiers copied out of a backend. `x-default` is an `hreflang` value for a search-engine annotation and is not a valid value for this attribute.

### Evidence required

A finding needs an observation and a criterion. The observation is a quoted element at `file:line` (source mode) or URL plus selector with the rendered HTML (crawl mode), or a runner rule id with its node.

**Source mode, cheapest first:**

1. `Grep` for `<html` across every layout, template and static page. Quote each opening tag verbatim, including the absence of `lang` (3.1.1).
2. For each `lang` value found, validate the shape: a primary subtag of two or three letters, hyphen-separated subtags, no underscores, no full language words (3.1.1).
3. Determine whether the site serves more than one locale: `Glob` for locale route segments (`app/[locale]`, `pages/[lang]`, `src/routes/$locale`), locale directories, or a message-catalog folder with more than one file. If it does, check whether the `lang` value is derived from the route or hardcoded (3.1.1).
4. Sample the body copy for each locale route and compare the content language against the declared `lang`. A Spanish route serving `lang="en"` is a wrong-value finding, not a missing-value one (3.1.1).
5. `Grep` the content and message catalogs for passages in another language: block quotes, testimonials, legal boilerplate, addresses, taglines, and any string whose catalog key marks it as untranslated. For each, check the wrapping element for `lang` (3.1.2).
6. `Read` the language switcher and check whether each option carries `lang` for the language it names. "Deutsch" inside an English page is a foreign-language phrase (3.1.2). The switcher's own behaviour is Category 20's judge — cross-reference rather than restating it.
7. `Grep` for `xml:lang` and record whether a matching `lang` sits beside it, and what the document's serialization is (3.1.1).

**Crawl mode:**

1. `Fetch` each URL in the test scope and quote the served `<html>` opening tag verbatim.
2. For a multi-locale site, fetch at least two locale URLs and quote both tags. A single hardcoded value across both is the finding.
3. Read a sample of the served body copy per URL and compare it against the declared value.
4. Quote any foreign-language block from the served DOM with its selector, showing the absence of `lang` on it.

**Caveat for framework-emitted values.** Many frameworks emit `lang` from a config value or a locale provider rather than from literal markup. A grep for `<html` may find a template with `lang={locale}` and tell you nothing about what `locale` resolves to. Trace the value to its source, or verify it in crawl mode, before writing a wrong-value finding. Mark Confidence Medium when only the template was read.

**Runtime checks (need a human or a runner; the bundle ships neither):**

1. Listen to a screen reader read the page and confirm the pronunciation matches the declared language.
2. Confirm the browser's translation offer matches the content.
3. Confirm foreign-language passages switch voice at the right boundary.

If none is available: `Skip — screen-reader pronunciation check requires a human or runner; not run`, and report only the static findings.

### Forbidden claims

- "The lang attribute may be missing." Quote the opening tag, present or absent. This is the cheapest possible check and there is no excuse for hedging it.
- "The language is probably wrong." Quote the declared value and a sample of the content that contradicts it. Both sides, or no finding.
- "Foreign phrases are not marked up." Quote the passage, quote its element, and state which of 3.1.2's four exceptions you ruled out.
- "The lang attribute hurts SEO." That is the sibling's judge and a different claim — call the Skill tool with "snitch-marketing". Here the claim is about programmatic determination for assistive technology.
- "Adding hreflang fixes this." It does not. `hreflang` annotates alternates for search engines; `lang` declares this document's language. Different attributes, different consumers.
- "The site is not internationalized." Not a criterion. Report the attribute defect, and let the i18n-readiness categories judge the rest.
- Never write "compliant", "conformant" or "non-compliant" as a verdict. Write "fails SC 3.1.1 on these routes" and let the reader draw the line.

### Detection

Source or rendered-DOM audit of the document element on every page in the test scope, plus a content pass over body copy, catalogs and the language switcher for passages whose language differs from the declared default.

### What to Search For

- `<html` opening tags in every layout, template, static page and error page
- `lang` values that are full language names, underscore-joined, empty, or `x-default`
- A single hardcoded `lang` on a site with locale routes or more than one message catalog
- `lang={locale}` style bindings, and what the bound value actually resolves to
- `xml:lang` with no accompanying `lang`
- Block quotes, testimonials, legal notices, addresses and taglines in a second language
- Language-switcher option lists naming languages in their own language
- Message-catalog entries left in the source language inside a translated file
- Untranslated navigation labels and button text inside an otherwise translated page

### Actually Fails

- **`<html>` with no `lang` attribute** (3.1.1). Evidence: the opening tag quoted from the route or the served response.
- **`lang` holding an invalid value** (3.1.1). Evidence: the attribute quoted, with the BCP 47 shape it fails. `lang="english"` and `lang="en_US"` are both invalid; `x-default` belongs to an `hreflang` annotation, not here.
- **Hardcoded `lang` on a multi-locale site** (3.1.1). Evidence: the declaration plus at least two locale routes serving different content languages under the same value.
- **`lang` value contradicting the page's content** (3.1.1). Evidence: the declared value and a quoted sample of the content in another language.
- **`xml:lang` alone in an HTML5 document** (3.1.1). Evidence: the tag, and the content type the document is served as.
- **Foreign-language passage with no `lang` on its element** (3.1.2). Evidence: the passage, its wrapping element, and a note that it is a passage rather than a proper name or a naturalized loanword.
- **Language-switcher options with no per-item `lang`** (3.1.2). Evidence: the option list. Each item names a language in that language, so each item is a foreign-language phrase.

### NOT a Failure

- `lang="en-US"`, `lang="pt-BR"`, `lang="zh-Hans"`. More specific than the primary subtag, and valid.
- A `lang` value emitted by the framework's locale provider rather than written literally, where it resolves correctly per route. Quote the resolution as a Pass with evidence.
- Proper names in another language: a brand, a person, a place, a product name.
- Technical terms and words of indeterminate language.
- Loanwords that have become part of the surrounding language's vernacular. The criterion names this exception explicitly.
- A single-language site with one correct `lang` and no `hreflang` at all. Alternate annotation is a search concern, not a criterion.
- `xml:lang` **alongside** a matching `lang` in an HTML5 document. Redundant, not wrong.
- A `lang` on a region that differs from the page default because the region genuinely is in that language. That is the criterion working.
- A code sample, a command or an identifier left untranslated inside translated prose.

### Context Check

1. Does the framework auto-emit `lang`? Many do, from a config value that may or may not track the route. Trace it.
2. Is the value derived from the locale segment of the route, or from a build-time constant? Derived is the pass; constant on a multi-locale site is the finding.
3. Is the audited surface a single-locale site by recorded decision? Then the multi-locale checks Skip with that reason, and 3.1.1 still applies.
4. Is the foreign passage a real passage, or one of 3.1.2's four exceptions? Name which exception you ruled out.
5. Does the error page, the maintenance page and the email template carry `lang` too? They are pages, and they are usually the ones nobody templated.
6. Is the switcher itself in scope? Its options are judged here under 3.1.2; whether it works, persists and negotiates correctly is Category 20.
7. Is the same attribute also being judged as a search signal? Cross-file — call the Skill tool with "snitch-marketing" — rather than double-counting it here.

### Severity

- **High** — `<html>` with no `lang`; an invalid `lang` value; a `lang` value contradicting the content language; a hardcoded `lang` across locale routes; `xml:lang` alone in an HTML5 document (3.1.1).
- **Medium** — a foreign-language passage of a sentence or more with no `lang` on its element; a language-switcher option list with no per-item `lang` (3.1.2).
- **Low** — a short foreign-language phrase inside otherwise consistent prose where the surrounding sentence makes the language obvious, and no exception cleanly applies.

No Critical tier. A missing `lang` degrades every assistive reading of the page, but it does not block the task outright, which is what Critical is reserved for.

### Fix guidance

Two fixes. The first is one attribute; the second is one attribute per passage.

**1. Declare the page's language, and derive it** (3.1.1). A literal value is right for a single-locale site and wrong the moment a second locale arrives. Bind it to the route from the start.

```tsx
// Fails 3.1.1: nothing declared
<html>

// Fails 3.1.1 differently: declared once, wrong on every non-English route
<html lang="en">

// Passes: the declared language follows the locale the route resolved
export default function RootLayout({ children, params }) {
  return (
    <html lang={params.locale}>   {/* "en", "pt-BR", "zh-Hans" */}
      <body>{children}</body>
    </html>
  );
}
```

Validate the value where it enters the system, not where it is printed. A locale that reaches the template as `en_US` will render as `en_US`, and the attribute will be invalid on every page at once.

```ts
// Normalize once, at the boundary: underscores to hyphens, BCP 47 shape enforced
const lang = rawLocale.replace("_", "-");
if (!/^[a-z]{2,3}(-[A-Za-z]{4})?(-[A-Za-z]{2}|-\d{3})?$/.test(lang)) {
  throw new Error(`Invalid language tag: ${rawLocale}`);
}
```

**2. Mark the passages that change language** (3.1.2). One attribute on the element that wraps the passage. It costs nothing and it is the difference between a quoted testimonial being read and being mangled.

```html
<!-- Fails 3.1.2: read with English pronunciation rules -->
<blockquote>Le produit a transformé notre flux de travail.</blockquote>

<!-- Passes -->
<blockquote lang="fr">Le produit a transformé notre flux de travail.</blockquote>

<!-- Inline, and the exceptions that need nothing -->
<p>Our <span lang="de">Betriebsrat</span> approved the rollout.</p>
<p>She ordered a croissant.</p>  <!-- naturalized: no lang needed -->
```

The switcher deserves the same treatment, because every option in it names a language in that language.

```html
<ul>
  <li><a href="/en/" lang="en" hreflang="en">English</a></li>
  <li><a href="/de/" lang="de" hreflang="de">Deutsch</a></li>
  <li><a href="/ja/" lang="ja" hreflang="ja">日本語</a></li>
</ul>
```

Note what each attribute is doing there: `lang` tells the assistive technology how to read this text, `hreflang` tells a consumer what language the destination is in. They coincide here and they are not the same claim. Whether the switcher then persists the choice, negotiates from `Accept-Language`, and keeps the user on the page they were reading is a separate audit, in Category 20.

### Reference

WCAG 2.2 specification: https://www.w3.org/TR/WCAG22/

3.1.1 Language of Page: https://www.w3.org/WAI/WCAG22/Understanding/language-of-page.html · 3.1.2 Language of Parts: https://www.w3.org/WAI/WCAG22/Understanding/language-of-parts.html

Human language, programmatically determined, defined: https://www.w3.org/TR/WCAG22/#dfn-programmatically-determined

BCP 47 language tags: https://www.rfc-editor.org/info/bcp47 · IANA Language Subtag Registry: https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry

The `lang` global attribute: https://developer.mozilla.org/en-US/docs/Web/HTML/Global_attributes/lang · HTML language declaration guidance: https://www.w3.org/International/questions/qa-html-language-declarations

axe-core rule descriptions, for the runner rule ids quoted alongside an element: https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md
