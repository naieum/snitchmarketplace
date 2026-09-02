# Schema deprecation registry

Google retires rich-result support for schema types periodically. Recommending a deprecated type
as a rich-result win is a false finding — the markup is valid but produces no SERP feature. This
registry keeps the schema cats (31, 32, 94) from recommending dead rich results.

The markup itself is usually still valid structured data (it can still aid entity understanding);
what's gone is the *rich-result rendering*. Distinguish the two in any finding: "still valid as
structured data, no longer eligible for a rich result."

## When surfaced

Loaded when Cat 32 (schema type validation) runs its HowTo, FAQPage or Course row, when Cat 31 (JSON-LD presence)
evaluates rich-result eligibility, or whenever a schema-group finding would recommend adding a type
for its SERP feature.

## Retired / narrowed rich results

| Type | Status | Date |
|---|---|---|
| **HowTo** | Rich results removed entirely | Sept 2023 |
| **FAQ** | Rich results narrowed to authoritative gov/health sites only | mid-2023 |
| **SpecialAnnouncement** | Rich result retired | July 2025 |
| **Course Info** (the per-course card; the Course List carousel built from an `ItemList` of `Course` is unaffected) | Rich result retired, then dropped from Search Console, the Rich Result Test and the search-appearance filters | Announced June 2025, removed 2025-09-09 |
| **ClaimReview** | Limited rollout; not a general win | ongoing |
| **VehicleListing** | Narrow eligibility | ongoing |
| **EstimatedSalary** | Narrow eligibility | ongoing |
| **LearningVideo** | Narrow eligibility | ongoing |

Treat this as the known-deprecations baseline; Google's structured-data docs are the live source.

## How this changes findings

- **Do not** recommend HowTo schema "to win a rich result." If HowTo markup already exists, note
  it is still valid structured data but no longer renders a rich result; don't flag its absence as
  a rich-result miss.
- **FAQ schema**: only recommend it as a rich-result lever for eligible site types (government,
  health). For everyone else, recommend it for AI-extractability / entity clarity (cross-ref
  `references/citability-scoring.md`), not for a SERP FAQ accordion.
- **Course**: the per-course Course Info card is gone, so don't promise one for a single course-detail
  page. The Course List carousel is still live for a catalog page marked up as an `ItemList` of
  `Course` — that is the only Course rich result left, and `references/standards-table.md`'s Course
  row is what sets its ceiling.
- Frame every still-valid-but-no-rich-result type honestly so the customer doesn't expect a SERP
  feature that won't appear.

## Forbidden claims

- "Add HowTo schema for a rich result." Removed Sept 2023.
- "Add FAQ schema to get the FAQ accordion." Only for eligible site types; verify first.
- Recommending a retired type's SERP feature without checking this registry.

---

*Deprecation tracking consolidated from several open-source SEO rule sets and cross-checked
against Google's live structured-data documentation, which is the authority when the two
disagree. Internal reference only; not surfaced in reports.*
