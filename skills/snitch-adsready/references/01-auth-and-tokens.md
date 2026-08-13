# 01 — Auth + tokens (cross-platform)

Lazy-load when wiring the first server-side / Marketing API integration. For per-platform field names, see `references/platforms/<name>.md`.

## Auth shapes by platform

| Platform | Auth flavor | Env vars | Refresh story |
|---|---|---|---|
| Google Ads | OAuth 2 + developer token | `GOOGLE_ADS_DEVELOPER_TOKEN`, `GOOGLE_ADS_CLIENT_ID`, `GOOGLE_ADS_CLIENT_SECRET`, `GOOGLE_ADS_REFRESH_TOKEN`, `GOOGLE_ADS_LOGIN_CUSTOMER_ID` | refresh_token never expires unless revoked; access_token 1h |
| GA4 / GTM | OAuth 2 service account or refresh token; MP uses API secret | `GA4_AUTH` (JSON), `GA4_API_SECRET` for MP | service-account preferred for server-side; rotate yearly |
| Search Console | OAuth 2 service account or refresh token | `GOOGLE_GSC_AUTH` | same as GA4 |
| Meta | Long-lived system-user token + appsecret_proof | `META_ACCESS_TOKEN`, `META_AD_ACCOUNT_ID`, `META_APP_SECRET` | system-user tokens 60 days unless rotated; appsecret_proof prevents tamper |
| Microsoft Ads | OAuth 2 + developer token | `MICROSOFT_ADS_DEVELOPER_TOKEN`, `MICROSOFT_ADS_CLIENT_ID`, `MICROSOFT_ADS_REFRESH_TOKEN`, `MICROSOFT_ADS_CUSTOMER_ID`, `MICROSOFT_ADS_ACCOUNT_ID` | refresh tokens roll on use; store new value after each refresh |
| LinkedIn Ads | OAuth 2 (3-legged or client-credentials) | `LINKEDIN_ADS_ACCESS_TOKEN`, `LINKEDIN_ADS_ACCOUNT_ID` | tokens 60 days; `LinkedIn-Version` header required (e.g. `202410`) |
| TikTok Ads | OAuth 2 (advertiser auth) | `TIKTOK_ADS_ACCESS_TOKEN`, `TIKTOK_ADS_ADVERTISER_ID` | long-lived, scoped to advertiser |
| X Ads | OAuth 1.0a + OAuth 2 user context | `X_ADS_CONSUMER_KEY`, `X_ADS_CONSUMER_SECRET`, `X_ADS_ACCESS_TOKEN`, `X_ADS_ACCESS_TOKEN_SECRET` | OAuth 1.0a tokens don't expire; rotate manually |
| Pinterest | OAuth 2 | `PINTEREST_ADS_ACCESS_TOKEN`, `PINTEREST_ADS_ADVERTISER_ID` | access_token 30d; refresh_token 1y |
| Reddit Ads | OAuth 2 | `REDDIT_ADS_ACCESS_TOKEN`, `REDDIT_ADS_ACCOUNT_ID` | access_token 1h; refresh required |
| Snapchat Ads | OAuth 2 | `SNAPCHAT_ADS_ACCESS_TOKEN`, `SNAPCHAT_ADS_AD_ACCOUNT_ID` | access_token 30 min — refresh on every cluster |
| Apple Search Ads | JWT (ES256) → token exchange | `APPLE_SEARCH_ADS_PRIVATE_KEY`, `APPLE_SEARCH_ADS_TEAM_ID`, `APPLE_SEARCH_ADS_KEY_ID`, `APPLE_SEARCH_ADS_CLIENT_ID`, `APPLE_SEARCH_ADS_ORG_ID` | JWT up to 180 days; exchanged token ~1h |

## Universal rules

1. **No global API keys.** Every platform's auth must be scoped per advertiser/account. Skill rejects bare `API_KEY=` envs.
2. **Refresh tokens belong in secret stores.** Never in source, never in `.env.local` checked to git.
3. **Hash PII before sending.** SHA-256 lowercase trimmed strings for email + phone in CAPI calls. The `capi-stubs/` templates do this; never pass raw PII.
4. **Dedup IDs travel with both client + server events.** Same `event_id` (Meta, TikTok, Pinterest, Snap, X), `transaction_id` (GA4), `gclid` (Google Ads), `eventId` (LinkedIn), `conversion_id` (Reddit).
5. **Token rotation is human work.** Document the schedule, assign owners.

## Do I need API access for an audit?

**No.** Site-side audits (`state site`, `state crux`, `state lighthouse`, `score`) work without any platform auth — they fetch the public URL and parse pixel signatures. Marketing API access only unlocks `state platform <name>`.

## See also

- `references/_doc-sources.json` — canonical doc URLs the skill refreshes via `refresh-docs`.
- `references/platforms/<name>.md` — per-platform deep-dive.
