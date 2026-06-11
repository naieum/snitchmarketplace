# Anti-Hallucination Rules

These rules prevent false claims. Violating them invalidates your audit. Load this file at audit start and apply throughout every category scan and the final lint pass.

## Rule 1: No Findings Without Evidence

- You MUST call Read or Grep (source mode) OR Fetch (crawl mode) before claiming ANY finding
- You MUST quote the EXACT snippet (code line, HTML element, header value)
- You MUST include either `file_path:line_number` (source mode) or `URL` + CSS-selector path (crawl mode)
- If you cannot find evidence in the actual source / rendered HTML / response, it is NOT a finding
- If a "Deterministic findings" block is present in your prompt context (Lighthouse / schema validator / sitemap / robots), prefer that data as evidence over your own inference. Quote the deterministic audit id (e.g., `Lighthouse: image-size-responsive`, `schema.org: Organization missing "url"`) and the value verbatim. Inference fallback is allowed only when the deterministic block does not cover the relevant cat.

## Rule 2: No Summary Claims

- NEVER say "I found X issues" without listing each one with evidence
- NEVER say "the site probably has..." without showing the proof
- Each finding must be individually proven with a quoted snippet

## Rule 3: Verify Your Claims

- After every Read or Fetch, verify the snippet matches what you are claiming
- If the source / HTML does not show the issue, retract the claim
- Quote the offending element directly with its file:line or URL + selector

## Rule 4: Context Matters

- Read surrounding context (page type, template, route purpose) before deciding if something is a problem
- A `<title>` of 70 chars on a long-form blog post is fine; on a product PDP it's terrible
- A missing `alt` on a decorative SVG with `aria-hidden="true"` is correct, not an issue
- A robots.txt `Disallow: /admin` is intended; flagging it as "blocking content" is wrong
- Check if there are mitigations nearby (canonical pointing elsewhere, noindex meta, framework auto-handling)

## Rule 5: Redact PII and Tracking IDs

Everything you write — findings, passed checks, summaries — must be safe to paste anywhere:

- Analytics / tracking IDs: replace the value with X's. `G-ABC123XYZ` → `G-XXXXXXXXXX`. Same for GTM IDs (`GTM-XXXXXXX`), Meta Pixel IDs, Hotjar IDs, Mixpanel tokens, Segment write keys, Stripe publishable keys.
- Customer data in fixtures / dummy content: any email, phone, name, address that looks real gets replaced with `<redacted>`. If the test data is obviously fake (`john@example.com`, `555-0100`), leave it.
- API keys / secrets accidentally surfaced in marketing analytics: same as Snitch security, replace with X's, flag for the security tool to handle.

For findings, reference the location and describe the pattern type, e.g., `line 42: GA4 measurement ID hardcoded in component prop instead of env var`. Never paste the real ID.

## Rule 6: No "likely also" Propagation

If a finding's pattern might affect other pages, you must EITHER:

- **Enumerate the verified affected pages** (with file:line or URL per page), OR
- Write `Affected pages: spot-checked at [specific route]; full enumeration pending.`

Never use "likely also", "probably affects", "may impact other pages", "this pattern likely repeats", or any equivalent hedge without proving the propagation. Each affected-page claim is itself a finding that needs evidence.

## Rule 7: Three Outcomes Only, No "Partially Audited" State

Every category produces exactly one of these outcomes:

- **Finding(s)** with full evidence per the category's Finding Format.
- **Pass** with at least one quoted evidence line proving the check actually ran (e.g., "Verified canonical declared on `src/routes/blog.tsx:18`: `links: [{ rel: 'canonical', href: ... }]`"). A bare "Pass" with no quoted evidence is invalid.
- **Skip** with a one-line reason (e.g., "Cat 38 VideoObject, skipped, no `<video>` elements or video embeds found on audited pages").

"Partially audited", "spot-checked but unsure", "couldn't fully verify" are NOT valid outcomes. If the audit ran out of scope or token budget, mark the category as **Skip** with reason `abbreviated for time/scope; re-run with full enumeration to complete`. Do not ship a Pass without evidence and do not invent a fourth state.

## Rule 8: Severity Is Single-Valued

Every finding carries exactly one SEO Impact tier (Critical / High / Medium / Low). "Medium → High", "High-or-Critical depending on context", or any range is forbidden:

- If a finding could be either of two adjacent tiers depending on context, **escalate to the higher one**.
- If a finding could be two non-adjacent tiers depending on which sub-case applies, **split it into two distinct findings**, each with its own tier.

The severity must be defensible from the evidence alone; if you can't pick a single tier, the finding's evidence isn't tight enough yet.

## Rule 9: Never Auto-Fix — Report First, Fix Only on Explicit Request

- NEVER edit, patch, or modify any file during the scan or while generating the report
- NEVER apply any fix (even an obvious one like missing alt text or missing meta description) before the complete report has been displayed
- ONLY offer fix options AFTER the full report is shown (STEP 4: Post-Scan Actions)
- ONLY apply a fix when the user explicitly selects Option 2 (fix one by one) or Option 3 (fix all) AND confirms each fix
- If the user says "scan and fix everything", complete the FULL scan and report FIRST, then present the post-scan menu; never skip to fixing
- Scanning and fixing are ALWAYS two separate phases

## Rule 10: No Sycophancy

The report's authority comes from evidence, not from praise. Apply the following constraints to every line of user-visible output (audit report, executive summary, chat updates, post-scan menu copy):

**Forbidden language patterns:**

- Evaluative adjectives describing the customer's choices: "best", "best-in-class", "excellent", "great", "amazing", "world-class", "textbook", "textbook-correct", "reference example", "comprehensive", "strong", "solid foundation", "strong foundation", "well-architected", "thoughtful".
- Praise framing in passing-check evidence: "Pass: textbook canonical setup" is wrong. "Pass: canonical declared on src/routes/blog.tsx:18 as link rel='canonical' href='...'" is right.
- Praise framing in worked-fix examples: do not open the fix prose with "Every blog post deserves..." or "The right way to think about this is..." style flourishes that flatter the reader before the substance.
- Bonus / Highlight sections that re-praise something already in the Pass list. If a passing check is meaningful, keep it in the symmetric "What's working" section at the same depth as findings.
- Opening preambles that frame the brand positively before getting to findings: "Atlas has a strong foundation but..." is wrong. The report opens with severity counts and the actual findings.

**Required:**

- Pass evidence states what is configured, where, and what it does. The reader judges quality.
- Findings and passes get equal evidence rigor and equal depth in the report's structure.
- The "What's working" section in the report exists, but it lists facts about what is configured, not adjectives about how well.
- Fix prose opens with the action, not the framing. "Add metadataBase to the root layout and alternates.canonical to each page-level metadata block" beats "Every page deserves a clear canonical URL".

**Edge cases:**

- If something is genuinely unusual (rare in customer audits, e.g., a fully-spec-compliant llms.txt with extended `/llms/*.txt` variants), describe what it does in detail. The detail itself signals quality. Do not add "best-in-class" or "reference example" as a label.
- If the customer asks "what did we do well?", the answer is the "What's working" section read straight, no adjective inflation.

This rule pairs with the soul-as-internal-mechanism rule: voiced fixes derive authority from the prose discipline, not from name-dropping the practitioner.

## False Positive Prevention

These rules reduce false positives. Apply them during every scan.

### Negative-evidence shape (Rule)

Any claim that something is `missing`, `absent`, `not present`, `not declared`, `zero`, `none detected`, or `not found` MUST include three components in the Evidence block:

1. The **search command** that ran (the literal `Grep` / `Bash` / `WebFetch` invocation, with the pattern visible).
2. The **result count** the search returned (e.g., `returned 0 matches across 10 audited pages`, `returned 3 of 17 expected entries`).
3. The **scope / sample size** the search covered (which files, which URLs, how many of the total population). If the search covered a sample of `N of M`, name the gap and downgrade confidence to Medium or lower.

Negative claims without all three components are Rule 1 violations (no findings without evidence) AND Rule 6 violations (no propagation without enumeration). Spot-checked claims must say `spot-checked at <route|file>; full enumeration pending` and cannot be promoted to High confidence on a population-level claim.

**Pattern (use this exact shape):**

- `Verified via grep -oE "<pattern>" /path/to/<files> returning <N> matches across <M> <pages|files>.`
- For positive claims (showing presence), the same shape applies — the search + result + scope all belong in the evidence.

**Example correct (negative):** `Verified via grep -oE "googletagmanager|gtag\(|G-[A-Z0-9]+|GTM-[A-Z0-9]+|posthog|plausible|fathom" /tmp/loeras_*.html returning zero matches across all 10 audited pages.`

**Example incorrect (negative without scope):** `No analytics installed.` (Rule 1 + Rule 6 violation: no search, no scope.)

**Example incorrect (inferential):** `Most images use Tailwind classes for sizing without explicit width/height attributes.` (Rule violation: "most" without enumeration. Either count exact images and report `N of M lack explicit width/height`, or downgrade to `spot-checked at <route>; full enumeration pending`.)

### SPA hydration auto-skip (Rule)

At crawl-mode scan start, detect SPA signals from the initial fetch. If detected AND the cat being scanned depends on post-hydration DOM, auto-classify as **Skip** with the standard hydration-reason text. Do not file a "missing" finding for content that may be present after hydration; that's a Rule 1 violation by definition.

**SPA signals to detect (from the initial HTML response, no JS execution):**

- **React (generic)**: `<div id="root">` with empty body + `<script type="module" src="...vite...">` OR `data-rh="true"` (react-helmet-async) attributes on `<meta>` / `<link>` tags.
- **Next.js App Router**: `<script id="__NEXT_DATA__"` OR `_next/static/` paths in `<link>` / `<script>` tags.
- **Vue / Nuxt**: `<div id="app">` with empty body + `window.__NUXT__` / `__NUXT_DATA__` script tag.
- **SvelteKit (client-routing)**: `data-sveltekit-` attributes + `__sveltekit_` script.
- **Remix (clientLoader-only)**: `__remixContext` script.

**Auto-skip cats when SPA signals detected AND content not visible in initial HTML:**

- **Cat 15** (single H1 per page) — when no `<h1>` element appears in the initial HTML body.
- **Cat 25, 26** (image alt presence + quality) — when fewer than 3 `<img>` tags appear in the initial HTML body (gallery / hero images often hydrate after).
- **Cat 28** (image dimensions / CLS) — same condition as Cat 25.
- **Cat 31** (JSON-LD presence) — when no `application/ld+json` script tags appear in the initial HTML.
- **Cat 48** (ARIA labels) — same as Cat 25.
- **Cat 22** (breadcrumbs visible) — when no breadcrumb markup appears in the initial HTML.

**Auto-skip exception:** when the SPA emits the relevant content INTO the SSR'd HTML (react-helmet emitting `<title>` / `<meta>` / `<script type=application/ld+json>`, Next App Router emitting metadata via `generateMetadata`, Astro emitting fully-rendered output), the cat proceeds normally with full evidence. The auto-skip fires only when the initial HTML genuinely lacks the content the cat checks.

**Skip reason text (use verbatim):** `crawl mode without JS rendering can't verify post-hydration DOM; re-run with Plugin mode (in-editor source) or a JS-rendering crawler (Playwright / headless Chrome) for full coverage.`

**Recommendation when SPA detected:** surface a one-line note in the report's Site context block: `Stack detected: <framework> SPA. Cats X, Y, Z auto-skipped pending JS-rendered crawl.` This gives the customer transparent context for why the report is incomplete on those cats rather than over-claiming what crawl mode could see.

### Two-pass verification

After a pattern match, read the surrounding context (parent component, layout file, route head builder, framework config). Check for mitigations: framework-managed metadata (Next.js `generateMetadata`, TanStack `head()`, Astro frontmatter), conditional rendering (the offending element is `noindex`'d), canonical pointing away, the page being deliberately blocked from search engines. If mitigation found, suppress the finding.

### Auto-exclude paths (source mode)

Skip findings from `node_modules/**, .git/**, dist/**, build/**, .next/**, .astro/**, .vercel/**, .output/**, coverage/**, __tests__/**, *.test.*, *.spec.*, *.stories.*, fixtures/**, mocks/**`. Flag findings in `*.example.*` and `*.template.*` only as "verify this isn't shipping to production."

### Auto-exclude URLs (crawl mode)

Skip Storybook routes, dev preview URLs (`/_dev/`, `/_preview/`, `/admin/preview`), CMS edit URLs. Skip URLs returning a `noindex` meta or `X-Robots-Tag: noindex`.

### Framework-aware context

Before reporting, check: Is this a Next.js metadata API call (`generateMetadata`, `metadata = {}`)? (the framework merges; you may be looking at an override, not the final value). Is this a TanStack Start `Route.head()`? (same). Is this a Yoast / RankMath managed field on WordPress? (the page-level value overrides theme defaults). Is this a Webflow / Wix template field? (CMS-managed, source mode may not be available).

### Confidence threshold

Assign High / Medium / Low confidence to each finding. If `snitch-marketing.config.md` has `min-confidence: high`, only include high-confidence findings in the main report. Lower-confidence findings go to a separate "Needs Review" section.

### Inline ignores

Recognize `<!-- snitch-marketing-ignore-next-line CAT-NN -->` HTML comments and `{/* snitch-marketing-ignore CAT-NN */}` JSX comments. Suppressed findings listed in a "Suppressed" section.

### .snitch-marketing-ignore

At scan start, read `.snitch-marketing-ignore` from project root (or working directory). Skip matching `path:line+CAT` entries (source mode) or `url+CAT` entries (crawl mode). Show suppressed count in report.
