# 25 — Vertical: SaaS

## Standard event suite

| Funnel stage | Event |
|---|---|
| Landing page view | `page_view` / `PageView` |
| View pricing | `view_item` |
| Sign up / start trial | `sign_up` / `CompleteRegistration` / `Lead` |
| Activate (custom milestone) | custom (e.g., `activated`, `core_action_completed`) |
| Trial → paid | `subscribe` / `Subscribe` / `Purchase` |
| Plan upgrade | `subscribe` (re-fired) or custom `upgrade` |
| Churn / cancellation | custom `cancel` |

Standard names enable platform smart-bidding optimization. Custom events bid on volume only.

## Time-shifted conversions

SaaS conversions often happen weeks after click. Standard pixel attribution windows (1-30 days) miss them:

1. **Server-side conversion uploads.** Wait for trial → paid, then fire CAPI with original `gclid` / `fbclid` / `event_id` stored at signup.
2. **Enhanced Conversions for Google Ads.** Pass hashed PII; Google joins to its identity graph.
3. **Long lookback windows.** LinkedIn supports 90-day click windows; useful for B2B.

## Schema.org for SaaS

`SoftwareApplication`, `Organization`, `WebSite`, `FAQPage`, `Service`, `BreadcrumbList` and
the rest are a search surface: **call the Skill tool with "snitch-marketing"**. Nothing in a
SaaS schema stack feeds an ad platform — `Product`/`Offer` markup only matters where a shopping
or catalog feed reads it (`07-structured-data.md`), so a SaaS site Skips this area with that
reason.

## Pricing pages

Drive 30-50% of SaaS conversions. Optimize:

- Direct CTAs above the fold.
- Comparison table in clean HTML — readable by a crawler without hydration.
- Customer logos, testimonials, case-studies.

Run `state lighthouse <pricing-url>` separately — pricing pages often score worse than the homepage due to comparison tables.

## B2B vs B2C

- **B2B**: LinkedIn foundational; Insight Tag + B2B Lead Gen Forms. Leads from form submissions, not purchases. Optimize on Lead, not Purchase.
- **B2C**: Meta, TikTok, Google Ads. Higher volume, lower contract value, CAPI dedup matters more.

## CAPI for SaaS

Trial-to-paid conversion is server-side, AFTER paying:

1. At signup, capture `gclid`, `fbclid`, `ttclid`, `li_fat_id` from URL.
2. Store with user record.
3. On trial → paid (Stripe webhook, custom billing event), fetch click IDs and POST to each platform's CAPI with original click ID.
4. Pass hashed email for Enhanced Conversions / Custom Audience matching.

The `templates/capi-stubs/<platform>/<lang>.template` files include click-ID fields.

## Common SaaS failures

| Symptom | Cause |
|---|---|
| "Conversions" only counts trial sign-ups, not paid | Pixel fires on `/thanks`; trial-to-paid invisible to ad platforms |
| Long sales cycles miss attribution | Need server-side upload of paid conversions with original click ID |
| LinkedIn Lead Gen Forms not in CRM | LinkedIn-side Zapier / native CRM integration not set up |
| Microsoft offline conversions show 0 | UET fired but no offline upload for closed deals |
| Trial signups inflated by bot traffic | No reCAPTCHA / Turnstile + no IP filtering in GA4 |

## Bottom line

For SaaS, prioritize:

1. CAPI / server-side conversions over client-only pixels.
2. Long lookback + offline conversion uploads for B2B.
3. Standard event names for optimization.
4. Hashed email / phone in every CAPI payload (match rate +10-30%).
5. Landing-page and pricing-page clarity — with no pixel on the AI surfaces, the page is the whole conversion story.
