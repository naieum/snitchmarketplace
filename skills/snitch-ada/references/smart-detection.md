# Smart Detection

Run this at the start of every audit, before the discovery questions. It settles three things:

1. Mode (source, crawl, or both).
2. The stack, and therefore where templates, CSS, components and head builders live, and which
   accessibility behavior the framework already emits.
3. The i18n setup, and therefore where the message catalogs live and what shape they are in.

Everything here is a detection signal, never a finding on its own.

---

## Mode detection

| Signal in the working directory | Mode |
|---|---|
| `package.json` plus a framework config (`next.config.*`, `astro.config.*`, `nuxt.config.*`, `svelte.config.*`, `remix.config.*`, `vite.config.*`, `angular.json`, `gatsby-config.*`) | Source |
| `wp-config.php`, or `wp-content/themes/` | Source (PHP templates) |
| `Gemfile` with a Rails or static-site generator, plus `app/views/` or `_config.yml` | Source |
| `manage.py` plus `templates/` | Source (Django templates) |
| `*.csproj` plus `Views/` or `Pages/` | Source (Razor) |
| `pubspec.yaml`, or `*.xcodeproj`, or `AndroidManifest.xml` | Source (native app; the criterion tables still apply, the DOM-specific signals do not) |
| Theme files with `.liquid` or `.hbs` templates | Source |
| `index.html` at the root with no framework config | Source (static HTML) |
| The user pasted a URL and there is no working directory | Crawl |
| Both of the above | Both: prefer source for anything source-fixable, crawl to confirm what is served |
| Neither | Ask: "Where is the surface? Point me at a directory or paste a URL." |

## Closed and hosted builders: crawl only

Hosted site builders expose no editable source. Detect them from the served HTML, usually a
`<meta name="generator">` value or a platform-specific asset host. There is no repository to point
at, so **never recommend source mode to a user on one of these**.

Skip reason, use verbatim when a non-JS crawl cannot see the post-hydration DOM on a hosted builder:

```
crawl mode without JS rendering can't see post-hydration DOM; source mode is unavailable on this hosted platform - re-run with a JS-rendering crawler (Playwright / headless Chrome) for the post-hydration DOM.
```

Two accessibility consequences worth stating in the report rather than filing as findings:

- On a hosted builder the user can often fix content-level failures (alt text, heading levels, link
  text, form labels) through the editor, but cannot fix template-level ones (focus management, the
  skip link, ARIA on the platform's own widgets). Say which side of that line each finding falls on.
- The platform's own chrome - cookie banner, chat widget, sticky header - is frequently what fails
  2.4.11 and 2.5.8. Attribute it to the platform component, not to the user's content.

---

## What the framework already does

Read the framework's own emission before filing a finding against a template that looks bare. These
are the mitigations that most often make a "missing" claim wrong. Confirm each by reading the
config or the root layout; never assume it from the framework name alone.

| Behavior | Where to confirm it |
|---|---|
| The document `lang` attribute emitted from the route or locale config rather than written per page | the root layout or document component, the i18n config, the server render entry |
| A skip link rendered once in a shared layout | the root layout, the shared header component |
| Focus moved to the main region on client-side navigation | the router config, a route-change effect, the framework's own announcer component |
| A route announcer that speaks the new page title on navigation | the framework's built-in announcer, usually mounted in the root layout |
| `<title>` resolved by a metadata API rather than a literal `<title>` tag in the page | the route's metadata export or head builder |
| Accessible names, roles, focus traps and Escape handlers supplied by a component library | the component's implementation or its published props; read `Button`, `IconButton`, `Dialog`, `Modal`, `Menu`, `Tabs` |
| Color values resolved from a theme or token layer | the theme file, the CSS custom-property definitions, the design-token source |
| Missing catalog keys failing the build | the i18n plugin config, the lint config, the CI workflow |

Where to look for the auditable surface, by stack shape:

- **File-routed JS frameworks** - routes under a `pages/`, `app/`, `src/routes/` or `src/pages/`
  directory; shared chrome in a root layout or `_app`-style file; head and metadata in a per-route
  export or a `<head>` component.
- **Component-library UIs** - the reusable controls under `components/`, `ui/` or `packages/ui/`.
  One unlabeled icon button in a shared component is one finding with N call sites, not N findings.
- **Server-rendered template stacks** (PHP, Ruby, Python, .NET) - templates under `views/`,
  `templates/`, `Views/` or a theme directory; partials and layouts carry the landmarks and the
  skip link.
- **CSS** - a global stylesheet, a utility-class config, CSS modules beside components, or a
  CSS-in-JS layer. Find where `outline` and `:focus-visible` are set, and where colors are defined,
  before reading any component.
- **Native app targets** - the accessibility criteria still apply, but the evidence is platform
  accessibility attributes on views rather than DOM markup. Say so in the mode line.

---

## i18n setup detection

Detect the catalog location and format first; every i18n category's evidence depends on it. Check
`package.json` dependencies, the lockfile, the framework config, and then the directory shapes.

| Shape found | What it means for the audit |
|---|---|
| A `locales/`, `lang/`, `i18n/`, `messages/` or `translations/` directory with one file per locale tag | The catalogs. Feed them to `catalog-diff.py` with the source locale as `--source`. |
| JSON files with nested objects keyed by message id | Flatten to dotted keys. Placeholder syntax is usually `{name}` or ICU. |
| JSON or JS files whose values carry `{count, plural, one {...} other {...}}` | ICU MessageFormat. Cat 17 checks plural category coverage against CLDR, not just `one`/`other`. |
| `.po` and `.pot` files, with `msgid` / `msgstr` pairs | gettext. Plurals live in `msgid_plural` and `msgstr[n]`; the header's `Plural-Forms` line states the locale's rule. |
| YAML locale trees, usually one file per locale with the locale tag as the root key | Flat-parse to dotted keys. Common in Ruby and Python stacks. |
| `.arb`, `.strings`, `.stringsdict`, `.xliff` or `strings.xml` | Platform-native catalogs for mobile targets. Same completeness and placeholder rules apply. |
| TypeScript or JavaScript message maps exported as a typed object | Type-checked catalogs. Missing keys may already fail the build; confirm before filing Cat 21 findings. |
| A framework-native i18n folder with per-locale route segments | Routing is locale-aware; Cat 20's evidence is the route config, not a query parameter. |

Package names worth grepping for in `package.json`, a lockfile, or an import, because the literal
string is what identifies the setup: `i18next`, `react-i18next`, `next-intl`, `next-i18next`,
`react-intl`, `@formatjs/intl`, `vue-i18n`, `@nuxtjs/i18n`, `svelte-i18n`, `@angular/localize`,
`@lingui/core`, `@inlang/paraglide-js`, `node-polyglot`, `globalize`, `intl-messageformat`,
`gettext`, `babel` (the Python one), `rails-i18n`, `django.utils.translation`.

**No i18n library found** is not a finding by itself. It is the fact that scopes the i18n
categories: with one locale and no catalog, Cat 16 (are strings externalized), Cat 18 (is formatting
locale-aware), Cat 19 (would the layout survive another script), and Cat 22 (do the input fields
assume one culture's data) all still run and still find real defects. Cat 17, 20 and 21 Skip with
the reason "one locale served; no catalog to compare".

**A recorded Decision outranks all of it.** If `BLUEPRINT.md` records a `Decision` such as
"English-only at launch", the i18n categories Skip citing that line, per STEP 0.5.

---

## Client-hydrated rendering: the auto-skip trigger list

A plain Fetch of a client-hydrated app returns the shell. Reporting a missing element from the shell
is a fabrication. Detect these from the initial HTML with no JavaScript executed:

- An empty mount element - `<div id="root">`, `<div id="app">`, or similar - with no body content
  beneath it and a module script tag after it.
- A hydration data payload in a script tag, whatever the framework names it.
- Framework-specific static asset path prefixes in the `<link>` and `<script>` tags.
- Framework-specific data attributes on the root element or on the mount element.
- A `<noscript>` block that says the app requires JavaScript.

**Trigger:** the signals are present **and** the content the category checks is absent from the
initial HTML. Then the category auto-skips with the verbatim text in `anti-hallucination.md`.

**Exception:** the app server-renders the relevant markup into the served HTML. Then every category
proceeds normally with full evidence. Check before skipping - a server-rendered route on a
client-hydrated framework is the common case, not the rare one.

The full trigger conditions per category, the two verbatim skip texts, and the report note are in
`anti-hallucination.md` under "SPA hydration auto-skip". This file only carries the detection.
