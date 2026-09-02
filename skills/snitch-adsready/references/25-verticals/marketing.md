# 25 — Vertical: marketing site / agency / consulting

A site whose primary goal is brand awareness, lead generation, or content distribution — not direct ecommerce, not a SaaS product. Examples: agency portfolio, consulting practice, professional services, B2B brand site.

## Standard event suite

| Funnel stage | Event |
|---|---|
| Landing page view | `page_view` |
| View case study / portfolio | `view_item` (treat like a product page) |
| Form interaction | `form_start` (custom) |
| Form submission | `generate_lead` / `Lead` (Meta) |
| Demo / consultation booking | `schedule` (custom) |
| Newsletter signup | `subscribe` |
| Resource download | `select_content` / custom `download` |
| Outbound link to social / partner | `click` (custom) |

For B2B: LinkedIn Lead Gen Forms usually convert higher than custom forms — they pre-fill from LinkedIn profile.

## Schema.org

`Organization`, `LocalBusiness`, `ProfessionalService`, `Service`, `FAQPage`, `BreadcrumbList`,
`Person`, and `Article` are evidenced against search, not against an ad platform: **call the
Skill tool with "snitch-marketing"**. This skill only emits `Product`/`Offer` as a shopping-feed
input, which a services site rarely needs — Skip with that reason.

## Conversion-tracking pattern

Marketing sites usually have ONE primary conversion (lead form) and several micro-conversions:

| Platform | Primary | Secondary |
|---|---|---|
| Google Ads | Lead | newsletter, download, demo schedule |
| Meta | Lead | InitiateCheckout (for "schedule" CTA) |
| LinkedIn | conversion event for form submit | demo bookings |
| TikTok | SubmitForm | scroll depth, video view |
| Microsoft | signupCompleted | offline conversion for sales-qualified leads |

Optimization works best with volume. If you only get 5 leads/mo, primary-event optimization fails — bid manually.

## CAPI / lead enrichment

Marketing-site CAPI fires on form submission, server-side, with hashed email + phone:

1. User fills form on landing page.
2. Server validates + stores lead.
3. Server hashes email + phone (SHA-256).
4. Server sends CAPI to Meta, TikTok, Google (Enhanced Conversions), LinkedIn.
5. Original click IDs flow through for accurate attribution.

The `templates/capi-stubs/<platform>/<lang>.template` files apply directly.

## Form-spam mitigation

Marketing-site forms are bot magnets. Failed prevention = inflated conversions + wasted budget:

1. Cloudflare Turnstile or reCAPTCHA v3.
2. Honeypot field.
3. Server-side email validation (mailgun-validate, kickbox).
4. Rate-limit per IP at edge.
5. Filter known bot ASNs in GA4.

After cleanup, conversion counts often drop 20-40% — but ROAS improves correspondingly.

## Sub-verticals

- **Local services** (plumber, electrician, dentist): budget skews Google + Bing over Meta/TikTok, and location assets in those accounts are fed by a claimed business profile. Claiming and tuning the profiles themselves is local search — **call the Skill tool with "snitch-marketing"**.
- **Agency / consultancy**: LinkedIn-heavy. Less Snap / Pinterest unless visual.
- **Real estate**: per-listing pages need `Place` + `Offer`. Heavy Google + Meta + Pinterest.
- **Legal / finance / healthcare**: ad platforms restrict these verticals — expect certification requirements, limited audience targeting, and slower ad review. Check the platform's restricted-categories policy before promising a launch date.

## Honest framing

Marketing-site advertisers often spread spend across too many platforms. For most:

1. Pick 2 platforms based on audience (Google + Meta for B2C; Google + LinkedIn for B2B).
2. Get pixel + CAPI + consent solid on those 2.
3. Add a third only when you can dedicate time + creative.

Spreading across 6 platforms = each underperforms because none has enough conversion volume to optimize against.
