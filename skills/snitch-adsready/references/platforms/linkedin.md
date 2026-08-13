# LinkedIn Marketing

| Field | Value |
|---|---|
| Web tag | LinkedIn Insight Tag — `_linkedin_partner_id` + `lintrk` |
| Identifiers | Partner ID (numeric), Sponsored Account URN (`urn:li:sponsoredAccount:<id>`) |
| Server-side | **LinkedIn Conversions API** — `api.linkedin.com/rest/conversionEvents` |
| Account model | Org → ad account → campaign group → campaign → creative |
| Marketing API | `api.linkedin.com/rest` (`LinkedIn-Version: 202411`, `X-Restli-Protocol-Version: 2.0.0`) |
| Auth | OAuth2; scopes `r_ads`, `r_ads_reporting`, `rw_ads`, `r_organization_social` |
| Consent | NOT a Consent Mode v2 partner — gate Insight Tag via CMP |

Universal: pixel + CAPI dedup in `02-pixel-foundations.md`; consent in `04-consent-and-cmp.md`.

## Setup

1. Create / claim a Company Page on LinkedIn.
2. Open Campaign Manager → create an Ad Account.
3. Apply for **Marketing Developer Platform** access: <https://learn.microsoft.com/en-us/linkedin/marketing/getting-access>. Approval can take days.
4. Create app at <https://www.linkedin.com/developers/apps>; verify for Company Page.
5. Generate OAuth2 access token (3-legged or long-lived member token).
6. Install Insight Tag (`templates/pixel-snippets/linkedin.html`) — gated behind CMP since Insight Tag does NOT honor consent flags.
7. Configure Conversions in Campaign Manager → Analyze → Conversion tracking.
8. (Optional) Set up CAPI for server-side / CRM-event conversions.

## Conversion taxonomy

Standard types: `ADD_TO_CART`, `DOWNLOAD`, `INSTALL`, `KEY_PAGE_VIEW`, `LEAD`, `PURCHASE`, `SIGN_UP`, `OTHER`, `BOOK_APPOINTMENT`, `REQUEST_QUOTE`, `SEARCH`, `SUBSCRIBE`, `START_CHECKOUT`, `VIEW_VIDEO`.

Post-click + view-through windows: `1`, `7`, `30`, or `90` days.

## CAPI

- Endpoint: `POST https://api.linkedin.com/rest/conversionEvents`
- Required headers: `Authorization: Bearer <token>`, `LinkedIn-Version: 202411`, `X-Restli-Protocol-Version: 2.0.0`, `Content-Type: application/json`.
- Body: `{ "conversion": "urn:lla:llaPartnerConversion:<id>", "conversionHappenedAt": <epoch_ms>, "conversionValue": { "currencyCode": "USD", "amount": "99" }, "user": { "userIds": [{ "idType": "SHA256_EMAIL", "idValue": "<hash>" }, { "idType": "LINKEDIN_FIRST_PARTY_ADS_TRACKING_UUID", "idValue": "<li_fat_id>" }] } }`
- `idType`: `SHA256_EMAIL`, `SHA256_PHONE`, `LINKEDIN_FIRST_PARTY_ADS_TRACKING_UUID` (li_fat_id), `ACXIOM_ID`, `ORACLE_MOAT_ID`.
- **Match rate**: combine email + phone + li_fat_id. Aim ≥40%.

## Consent integration

Insight Tag has no runtime consent API. Two options:

1. **Recommended**: gate `<script src="https://snap.licdn.com/li.lms-analytics/insight.min.js">` load behind CMP `marketing` category. Don't load until consent granted.
2. **Acceptable**: load tag and rely on regional opt-out (LinkedIn doesn't surface a per-user signal).

For CAPI, only send events when user has consented.

## Audiences + targeting

B2B-specific dimensions unique to LinkedIn (and Microsoft via integration): company name, size, industry, job function, seniority, title, member skills, groups, fields of study.

- **Matched Audiences**: hashed email upload (`urn:li:dmpSegment:...`).
- **Lookalike**: derived from matched audience or website audience.
- **ABM**: upload company lists for direct ABM targeting.
- **Lead Gen Forms**: built-in form-fill ads — `LeadFormResponseService` returns leads via API.

## Notable extras

- **Lead Gen Form fields**: API returns prefilled values directly — highest-quality lead source LinkedIn offers.
- **CRM integration**: HubSpot, Salesforce, Marketo, Eloqua have native LinkedIn CAPI connectors — prefer those over custom CAPI if user already runs one.

## Cited URLs

- Marketing API: <https://learn.microsoft.com/en-us/linkedin/marketing/>
- Marketing Developer Platform access: <https://learn.microsoft.com/en-us/linkedin/marketing/getting-access>
- Conversions API: <https://learn.microsoft.com/en-us/linkedin/marketing/conversions/conversions-api>
- Insight Tag: <https://www.linkedin.com/help/lms/answer/a427660>
- Conversion types: <https://learn.microsoft.com/en-us/linkedin/marketing/conversions/conversion-tracking>
- DMP Segments: <https://learn.microsoft.com/en-us/linkedin/marketing/integrations/ads/account-structure/create-and-manage-audiences/dmp-segments>
- ads.txt: not required (closed marketplace)
