## CATEGORY 56: Consent-mode setup

GDPR / CCPA / regional privacy laws require explicit consent before firing analytics + ad tracking in many jurisdictions. Google Consent Mode v2 is the standard mechanism: gate tag firing on the user's stated consent. Botched consent = legal risk + invalid analytics from non-consenting users.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Grep` for `gtag('consent'`, consent banner libraries (`cookiebot`, `iubenda`, `onetrust`, `usercentrics`, `cookieconsent`).
2. Check if analytics tags fire BEFORE or AFTER consent.
3. Verify Consent Mode v2 default state (`denied` for most regions until user accepts).

**Crawl mode, required tool calls:**

1. `Fetch` URL. Look for consent banner script + analytics tag relative timing.

### Forbidden claims

- "Consent may not be wired." Quote the consent calls + analytics calls.
- "Tags may fire before consent." Show order.

### Detection

Consent banner library + Consent Mode v2 calls.

### What to Search For

- `gtag('consent', 'default', {...})`
- `gtag('consent', 'update', {...})`
- Consent libraries: `cookiebot`, `iubenda`, `onetrust`, `cookieconsent.run`
- Tags firing without prior consent gate

### Actually Hurts SEO

(Indirect: privacy non-compliance can cause legal action + lost trust. Doesn't directly impact rankings.)

- **No consent banner in regulated jurisdictions**.
  Evidence required: missing banner library + analytics tags firing.
- **Consent Mode default state set to `granted` instead of `denied`**.
  Evidence required: gtag('consent', 'default', { ... 'granted' ... })
- **Tags fire before consent decision** (no gating on `gtag('event'...)` calls).
  Evidence required: gtag calls in source not wrapped in consent check.
- **Cookie banner that's not blocking** (analytics fires regardless of user choice).
  Evidence required: banner present + tags fire on initial load.

### NOT a Problem

- US-only sites without GDPR coverage may skip Consent Mode (CCPA still applies for CA users).
- Sites using cookieless analytics (Plausible, Fathom) don't need full Consent Mode.

### Context Check

1. Does the site serve EU / UK / Brazil / California users? Compliance applies.
2. Is the team using Consent Mode v2 (current standard) or older v1 (deprecated)?
3. Is the cookie banner blocking (consent required before tags fire) or non-blocking (tags fire, banner is decorative, illegal)?

### Reference

Google Consent Mode v2: https://developers.google.com/tag-platform/security/guides/consent

**Severity tagging:**
- No consent gate in EU-serving site → Critical (legal).
- Consent Mode default `granted` → Critical.
- Tags fire before consent → Critical.

**Fix voice:** `security-engineer` (primary) | `analytics-engineer` (backup).

Read `souls/security-engineer.json` before writing the Fix. Privacy compliance is a security-shaped concern: who sees what data and when.

Worked fix example:

> Consent Mode v2 default state denied for everything until the user explicitly accepts. Then update the state. Then tags fire.
>
> ```js
> // BEFORE any tag fires (e.g., in head, before gtag.js)
> window.dataLayer = window.dataLayer || [];
> function gtag(){dataLayer.push(arguments);}
> gtag('consent', 'default', {
>   ad_storage: 'denied',
>   ad_user_data: 'denied',
>   ad_personalization: 'denied',
>   analytics_storage: 'denied',
>   wait_for_update: 500,
> });
>
> // After user accepts (in your consent banner's onAccept handler)
> gtag('consent', 'update', {
>   ad_storage: 'granted',
>   analytics_storage: 'granted',
> });
> ```
>
> The user choice is persisted; on next visit, set the consent state from the saved value before any tag fires. Legal compliance and clean analytics both depend on getting the order right.
