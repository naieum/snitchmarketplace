## CATEGORY 36: HowTo schema

`HowTo` schema marks step-by-step tutorial content. Google REMOVED the HowTo rich result entirely in September 2023, it no longer surfaces in SERP at all. The schema retains only minor value for general content understanding and AI-search consumption, so "no HowTo schema" is a low-priority / informational finding, not a missed rich-result opportunity.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify HowTo pages: URLs with `/how-to/`, `/tutorial/`, `/guide/`, OR pages with numbered step headings (`Step 1:`, `Step 2:`).
2. `Grep` for `"@type": "HowTo"`, `"@type": "HowToStep"`. Quote.
3. For each HowTo page: confirm schema + check steps match visible content.

**Crawl mode, required tool calls:**

1. `Fetch` URL. Parse JSON-LD for HowTo. Quote.
2. Compare schema steps to visible step headings.

### Forbidden claims

- "HowTo schema may be missing." Confirm page + schema absence.
- "Steps may not match." Quote both.

### Detection

Looking for `"@type": "HowTo"` with `step` array.

### What to Search For

- `"@type": "HowTo"`
- `"@type": "HowToStep"`
- `step`, `tool`, `supply`, `totalTime`
- Numbered headings: `Step 1`, `Step 2`, `1. Do this`, etc.

### Actually Hurts SEO

- **HowTo-shaped content with no HowTo schema** (low priority, the rich result was removed Sept 2023; only marginal content-understanding / AI-search value remains).
  Evidence required: numbered steps in content + no schema.
- **HowTo schema with steps not matching visible content**.
  Evidence required: schema steps + visible step headings.
- **HowTo schema steps without `text` or `name`**.
  Evidence required: parsed step entries with empty fields.

### NOT a Problem

- Sites with no how-to content. Skip.
- Long-form articles that include some how-to flavored sections but aren't primarily how-to. Acceptable to skip schema.

### Context Check

1. Is the page primarily a how-to / tutorial (not just an article that mentions steps)?
2. Are the steps in order? Numbered explicitly?
3. Do the steps include action language ("Run", "Click", "Set", "Add")?

### Reference

Google's HowTo removal announcement (Sept 2023 — the rich result no longer surfaces): https://developers.google.com/search/blog/2023/08/howto-faq-changes

Schema.org HowTo: https://schema.org/HowTo

Cross-reference `references/schema-deprecations.md` for the full registry of retired rich-result types — never recommend HowTo (or any deprecated type) "for a rich result"; frame it as still-valid structured data with no SERP feature.

**Severity tagging:**
- HowTo page with no schema → Low / informational (rich result removed Sept 2023).
- Schema steps not matching visible → Medium (the schema misrepresents the page; downgraded from High since no rich result is at stake).
- Empty step text → Low (malformed schema, but no rich result depends on it).

**Fix voice:** `aaron-draplin` (primary) | `mike-monteiro` (backup).

Read `souls/aaron-draplin.json` before writing the Fix. DDC's plain-language voice for step-by-step instructions: do this, then do this, then do this. No fluff.

Worked fix example:

> A how-to is a list of clear steps. The schema mirrors the steps. Both should sound like instructions a friend gave you, not corporate process documentation.
>
> ```tsx
> const steps = [
>   { name: "Install the CLI", text: "Run npm install -g @snitchplugin/cli." },
>   { name: "Run your first scan", text: "From your repo root, run snitch scan." },
>   { name: "Read the report", text: "Open SECURITY_AUDIT_REPORT.md in your editor." },
> ];
>
> <script type="application/ld+json" dangerouslySetInnerHTML={{
>   __html: JSON.stringify({
>     '@context': 'https://schema.org',
>     '@type': 'HowTo',
>     name: 'How to run your first Snitch audit',
>     totalTime: 'PT2M',
>     step: steps.map((s, i) => ({
>       '@type': 'HowToStep',
>       position: i + 1,
>       name: s.name,
>       text: s.text,
>     })),
>   }),
> }} />
> ```
>
> The visible steps and the schema steps come from the same data. Each step is one action, in plain language. Done.
