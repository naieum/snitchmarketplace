# Finding identity + fingerprint

A finding needs a stable identity so the same issue can be recognized across re-audits, diffed
between runs, and tracked through remediation — even after the page moves. Line numbers and finding
counts cannot do this: a finding on line 47 becomes a "new" finding the moment someone adds an
import above it, and a report that says `Previous: 21 | This audit: 19 | Resolved: 2` is arithmetic,
not reconciliation — two findings could have been fixed while two new ones appeared.

This is what makes the **second audit** worth running. First audit: 40 findings, overwhelming, mostly
ignored. Second audit should open with "3 new since Tuesday, 2 you accepted are still here, 6
resolved." Without stable identity every re-audit is a first audit, and every false positive the
customer already dismissed comes back.

## When surfaced

Every finding carries an identity block. Loaded whenever findings are reconciled across runs: the
STEP 3 scan comparison, post-scan Option 4 triage, and any delta or regression report. Pairs with
`references/seo-drift.md`, which tracks *element*-level change (a canonical that silently flipped);
this file tracks *finding*-level change.

## The three parts

1. **`ruleId`** — the stable issue *family*, dotted: `<class>.<specific>`. Derived from the category,
   never the page. e.g. `title.duplicate-across-pages`, `canonical.self-referencing-missing`,
   `schema.product-missing-offers`, `meta-description.truncated`, `internal-links.orphan-page`,
   `cwv.render-blocking-css`. Two findings of the same kind share a `ruleId` wherever they occur.

2. **`anchor`** — a *semantic* location that survives edits. Which form depends on audit mode, and
   this is the one real difference from the security skill:
   - **Source mode:** `path::symbol` — the smallest stable named construct, e.g.
     `app/blog/[slug]/page.tsx::generateMetadata`, `src/components/SEO.tsx::SEO`. **No line numbers.**
   - **Crawl mode:** `route::selector` — the URL *pattern* plus the element, e.g.
     `/blog/:slug::head>title`, `/products/:id::link[rel=canonical]`, `/::h1`.
     **Use the route pattern, not the concrete URL.** `/blog/my-post-2024` and `/blog/other-post`
     rendering from one template are the same finding at one anchor with separate `instance`s — not
     400 findings. Collapsing them by pattern is what makes a templated-site audit readable.
   - Concrete URLs and line numbers still appear in the *evidence* (Rule 1 needs them). They are
     just not part of identity.

3. **`instance`** — disambiguates independently-fixable siblings sharing `ruleId` + `anchor`: the
   concrete URL for a crawl finding, or the duplicate-bucket key for a duplicate-title finding.
   Omit when there is only one.

## Fingerprint

`fingerprint = hash(targetId + ruleId + anchor + instance)`, where `targetId` is the project or
domain. It is a **reconciliation signal, not proof of equivalence**: equal fingerprints across runs
mean "very likely the same finding" → carry triage state forward. They do not prove the page is
unchanged. Re-read the evidence before auto-suppressing anything.

## How identity is used

- **Scan comparison (STEP 3)** — match by fingerprint, not by count, to label each finding
  `new` / `unchanged` / `resolved`. Resolved means a prior fingerprint with no match this run —
  verify the issue is actually gone rather than merely moved, by re-deriving the anchor.
- **Triage carry-forward** — `.snitch-marketing-triage.json` keys on fingerprint. An `accepted` or
  `false_positive` finding stays suppressed across audits unless its anchor or evidence changes.
  Without this, the customer re-dismisses the same finding every audit and stops reading the report.
- **Templated sites** — one anchor plus N instances, so a 400-page site with one bad template
  produces one finding with 400 instances, not 400 findings.

## Forbidden claims

- An `anchor` containing a line number, or a concrete URL where a route pattern exists — neither is
  stable.
- Computing `Resolved:` / `New:` from finding **counts**. Counts are not identity; equal counts across
  two runs can hide a complete turnover of findings.
- Treating equal fingerprints as proof two findings are identical without re-checking the evidence.
- Collapsing independently-fixable siblings to shrink the count — give each an `instance`.
