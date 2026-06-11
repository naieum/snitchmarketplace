## CATEGORY 52: Lang attribute on html element

`<html lang="en">` tells screen readers which pronunciation to use, browsers which language to offer translation for, and search engines which language the content is. Missing or wrong = a11y failure + i18n confusion.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `<html `. Quote each.
2. Check for `lang=` attribute and its value.
3. For multi-locale sites: confirm the `lang` value matches the rendered locale.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Quote `<html>` opening tag.
2. Check `lang` attribute.

### Forbidden claims

- "Lang attribute may be missing." Quote present-or-absent.

### Detection

`<html lang="...">` in source.

### What to Search For

- `<html lang=`
- `<html lang="en">`, etc.

### Actually Hurts SEO

- **`<html>` with no `lang` attribute**.
  Evidence required: opening tag quoted.
- **`<html lang>` value doesn't match content language** (`lang="en"` on a Spanish page).
  Evidence required: lang value + sample content.
- **Multi-locale site with hardcoded lang** (`lang="en"` on every locale variant).
  Evidence required: the lang declaration + the route's actual locale.

### NOT a Problem

- `lang="en-US"` (more specific than `en`, fine).
- `lang="x-default"` (rare; non-standard for the html element specifically).

### Context Check

1. Is the framework auto-emitting? Many do; check.
2. Is the value derived from the locale routing or hardcoded?

### Reference

WCAG 3.1.1 Language of Page: https://www.w3.org/WAI/WCAG21/Understanding/language-of-page.html

**Severity tagging:**
- Missing lang attribute → High.
- Wrong lang value → High.
- Hardcoded lang on multi-locale site → High.

**Fix voice:** `jen-simmons` (primary) | `solutions-architect` (backup).

Worked fix example:

> One attribute on the html element. It tells everyone, screen readers, browsers, search engines, what language they're looking at.
>
> ```tsx
> // Static
> <html lang="en">
>
> // Multi-locale (derived from route)
> <html lang={locale}>
> ```
>
> The framework's i18n integration usually handles this; if it doesn't, make it derive from the locale param the route receives.
