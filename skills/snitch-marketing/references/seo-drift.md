# SEO drift — element-level baseline + compare (git-diff for SEO)

The skill already compares **finding counts** between two audits (SKILL.md STEP 3 "Scan
comparison": `Previous: X | This audit: Y | Resolved: Z | New: W`). That answers "are there
more or fewer findings." It does **not** answer "did the canonical on the pricing page
silently change last Tuesday, or did a deploy strip the Product JSON-LD off every PDP."

This reference adds that: a stateless, element-level regression check. It catches the
high-stakes SEO elements that change quietly between audits — the ones that don't throw an
error, don't fail a build, and don't show up until rankings move three weeks later.

## Why this stays a skill, not a tool

There is **no database, no daemon, no separate runtime.** The baseline is a plain artifact
the agent writes with `Write` and reads back with `Read` on the next audit. The compare is
the agent diffing two files and applying the rule table below. It uses only the skill's
native tools, and it degrades to nothing if no baseline exists (first run just writes one).
This is the same discipline as `references/field-cwv.md`: optional, gated, and the audit
still completes with it absent.

## The baseline artifact

On a run where drift tracking is enabled, after the audit completes, write a compact
snapshot to:

```
{working_directory}/snitchfindings/{target_slug}/drift-baseline.json
```

Capture one record per audited URL (or per route in source mode). Keep it small — these are
the load-bearing elements, not the full DOM:

```json
{
  "captured_at": "<ISO date — stamp from the environment, never invent one>",
  "stack_detected": "Next.js 15",
  "pages": [
    {
      "url": "https://example.com/pricing",
      "status": 200,
      "title": "Pricing — Example",
      "meta_description": "<text or null>",
      "canonical": "https://example.com/pricing",
      "robots_meta": "index,follow",
      "x_robots_tag": null,
      "h1": "Simple, honest pricing",
      "heading_outline_hash": "<hash of the h1-h6 sequence>",
      "jsonld_types": ["Organization", "Product", "Offer"],
      "og_present": true,
      "hreflang_set": ["en", "de", "fr"],
      "word_count": 820,
      "internal_link_count": 24,
      "lang_attr": "en",
      "indexable": true
    }
  ]
}
```

Add `drift-baseline.json` to the `snitchfindings/` directory that's already suggested for
`.gitignore`. Stamp `captured_at` from the real environment clock; if no clock is available,
write `"captured_at": "unknown"` rather than guessing a date.

## The compare

On a later audit, if `drift-baseline.json` exists for this target, `Read` it, re-capture the
same fields for the same URLs, and diff field-by-field. Emit a **Drift** section in the
report (or a standalone `SEO_DRIFT_REPORT.md`) listing each change with its severity from the
rule table. A field that is unchanged produces nothing. A URL that was in the baseline and is
now missing (or 404) is itself a CRITICAL drift.

Every drift line follows the same evidence discipline as a finding: name the URL, the field,
the **before → after**, and the severity. No drift claim without the before value quoted from
the baseline and the after value quoted from the current capture.

## Comparison rules (severity by what changed)

CRITICAL — these can de-index a page or kill a rich result, often silently:

1. **Indexable → non-indexable** (a `noindex` robots meta or `X-Robots-Tag: noindex` appeared). The single most damaging silent drift.
2. **Canonical changed** to a different URL, or canonical removed.
3. **Status 200 → non-200** (page now 404/410/5xx, or redirects where it didn't).
4. **A JSON-LD type disappeared** (e.g., `Product` or `FAQPage` gone → the rich result it powered is now ineligible).
5. **Page present in baseline is now missing** from the crawl/sitemap entirely.

WARNING — these move rankings or CTR but rarely de-index:

6. **Title changed** (especially a shorter or generic-er title on a ranking page).
7. **H1 removed or materially changed.**
8. **Heading outline hash changed** (the document structure was restructured).
9. **An hreflang entry was removed** from the set (a locale lost its annotation).
10. **Open Graph block removed** (social/share CTR surface lost).
11. **Word count dropped > 40%** (content was gutted — possible thin-content regression).
12. **Internal link count dropped > 50%** on a page (a nav/restructure stranded it).
13. **`lang` attribute changed or removed.**
14. **Canonical now points at a non-200 / non-self URL** (consolidating into a broken target).

INFO — worth noting, usually intentional:

15. **Meta description changed** (often a deliberate copy edit; flag, don't alarm).
16. **Title changed within a safe length and kept the primary term** (likely an intentional tweak).
17. **Word count changed < 40%, or internal links changed < 50%** (normal editing churn).

When two rules could apply, take the higher severity (the single-valued severity rule, same
as findings). If a change is plausibly intentional (rule 15/16), say so — drift detection
reports *what moved*, and lets the operator confirm whether it was meant.

## Honest limits

- **Crawl mode without JS rendering** sees only the SSR shell. A canonical or JSON-LD that's
  injected post-hydration will look "removed" when it isn't. Mirror the SKILL.md crawl-mode
  caveat: don't report a drift you can't actually observe — Skip-with-reason and recommend
  source mode or a JS-rendering crawler.
- **Field CWV drift** (LCP/INP/CLS moving) is tracked separately via the CrUX history trend in
  `references/field-cwv.md`, not here — that's a 28-day rolling field metric, not a
  point-in-time element snapshot. Cite both when a perf regression is suspected.
- A first run has no baseline; it writes one and reports "baseline captured, no prior to
  compare." That's a pass state, not a finding.

## When this surfaces

- SKILL.md STEP 3 "Scan comparison" — element-level drift extends the finding-count compare.
- The post-scan menu **Option 7 (Compare to previous audit)** — run the element-level diff,
  not just the count delta.
- A **post-deploy regression check** or **traffic-drop diagnosis** (`references/traffic-diagnosis.md`
  Stage 3a "a deploy") — drift between the last good baseline and now is the fastest way to
  find what a deploy silently changed.
- Cat 97 (content decay & refresh) — drift gives the structural-change half; Cat 97 gives the
  performance-decay half.

Cross-refs: `references/field-cwv.md` (CWV trend, the perf-drift counterpart),
`references/traffic-diagnosis.md` (Stage 3a deploy regressions), Cat 97 (content decay),
SKILL.md STEP 3 + post-scan Option 7.
