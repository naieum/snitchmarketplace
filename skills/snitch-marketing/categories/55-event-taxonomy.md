## CATEGORY 55: Event taxonomy

Custom events fired to GA4 / Mixpanel / Segment / etc. need a stable, documented taxonomy: consistent event names, consistent property keys, no typo'd duplicates ("button_click" + "buttonClick" + "btn_click" all firing). Bad taxonomy = unusable analytics.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `gtag(`, `analytics.track(`, `mixpanel.track(`, `posthog.capture(`, `segment.track(`. Quote each call.
2. Bucket by event name. Identify variations (snake_case vs camelCase, abbreviations, typos).
3. Check property key consistency across events.

**Crawl mode, required tool calls:**

1. Out of scope; events fire at runtime. Source-mode audit is the primary path.

### Forbidden claims

- "Events may be inconsistent." Quote variants.
- "Taxonomy is probably ad-hoc." Show the variations.

### Detection

Analytics calls in source code.

### What to Search For

- `gtag('event', '...', {...})`
- `analytics.track('...', {...})`
- `mixpanel.track('...', {...})`
- `segment.track('...', {...})`
- `posthog.capture('...', {...})`

### Actually Hurts SEO

(Indirect: better analytics enables better SEO decisions.)

- **Same event with multiple name variants** ("signup" + "sign_up" + "signUp").
  Evidence required: variants quoted from different source files.
- **Property keys inconsistent across events** ("user_id" + "userId" + "uid").
  Evidence required: property key variants.
- **Events fired with no documented taxonomy** (no tracking plan in repo).
  Evidence required: events found + missing tracking-plan doc.
- **PII in event properties** (email, phone, name as event property values).
  Evidence required: property + value pattern.

### NOT a Problem

- Consistent naming convention applied throughout.
- Documented tracking plan with event/property reference.

### Context Check

1. Does the team have a tracking plan?
2. Is naming convention enforced via TypeScript types?
3. Are tracking calls wrapped in helper functions (single source of truth for taxonomy)?

### North-star metric (required output)

Beyond the taxonomy itself, this category produces ONE leading-indicator metric that the team commits to monitoring as the single most important number. The metric falls out of the event taxonomy; without instrumented events, no metric. The audit identifies it; the team owns it.

**The pattern.** A north-star metric for a marketing surface is a percentage of users who reach the activation event within a bounded time after entry:

`% of [users who entered via {channel}] who reach [activation event] within [N hours/days] of entry`

**Selecting the right metric.** Walk the funnel from the customer's first touchpoint to the moment the product creates value:

1. Entry events (landing_view, signup, install, first content read).
2. Engagement events (scroll, click, action that signals intent).
3. **Activation event** (first time the product produces value: first_dictation_completed, first_form_submission_received, first_audit_run, first_post_published).
4. Retention events (return visit, repeat usage, subscription).
5. Revenue events (paid_signup, upgrade, renewal).

The activation event is the highest-leverage measurement target, and the percentage of new users who reach it within 24 hours (or 7 days for higher-friction products) is the single number the team monitors.

**Why activation, not signup or revenue.** Signup is too early (vanity-metric-like for SaaS with friction-free signup). Revenue is too late (a quarter of lag time before the team can react). Activation is the leading indicator that predicts retention better than any other event in the funnel.

**Output expected.** The category's report includes:

- The named activation event (e.g., `first_dictation_completed`).
- The bounding time window (24h, 7d, etc.).
- The current baseline number, if instrumented (e.g., 47%).
- The healthy threshold for the brand's category (e.g., "<60% means an onboarding problem; >80% is good").
- The decision rule for what to do at each threshold ("If <60%, fix onboarding before any marketing investment. If 60-80%, marketing investment may compound. If >80% and free→paid is below 5%, price/value perception is the gap, not activation").

This is the "single most important number" framing: the team should be able to pull up one dashboard, see one number, and know whether the product is working.

### Reference

Mixpanel guide on event taxonomy: https://mixpanel.com/blog/data-governance/

Activation metrics: Reforge Growth Series, Andrew Chen on "the magic moment."

Cat 99 (conversion funnel deep-audit), this category's north-star metric becomes Cat 99's primary tracked KPI.

**Severity tagging:**
- Same event with name variants → High.
- PII in event properties → Critical (privacy).
- No tracking plan → Medium.

**Fix voice:** `analytics-engineer` (primary) | `solutions-architect` (backup).

Worked fix example:

> Define event names as a typed enum or const. Wrap every analytics call in a helper that validates the name + property keys against the schema.
>
> ```ts
> // Tracking plan as code
> type EventName =
>   | 'plugin_installed'
>   | 'audit_started'
>   | 'audit_completed'
>   | 'subscription_created';
>
> type EventProps = {
>   plugin_installed: { plugin_version: string; client: string };
>   audit_started: { categories_count: number; mode: 'source' | 'crawl' };
>   // ...
> };
>
> function trackEvent<T extends EventName>(name: T, props: EventProps[T]) {
>   gtag('event', name, props);
> }
> ```
>
> Now you can't fire an unknown event or pass wrong properties. Taxonomy enforced by the compiler. Tracking plan lives next to the code, not in a stale Google Doc.
