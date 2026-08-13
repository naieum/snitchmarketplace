# Recommendations — CAPI helper libraries

Per-platform CAPI helper libs by language. Catalog data in `templates/recommendations.json` `capi-helpers` key.

## Universal pattern

The skill's `templates/capi-stubs/<platform>/<lang>.template` files use **direct fetch** + **crypto** for most platforms. SDKs are optional — they add typed responses but more dependency weight.

For Meta and Google, official SDKs are usually worth using. For LinkedIn, TikTok, Pinterest, Reddit, Snapchat, X, Apple — direct REST is cleanest.

## Per-platform / per-language

### Google (Ads + GA4 + Tag Manager)

| Lang | Library | Install | Use |
|---|---|---|---|
| Node | `google-ads-api` | `npm i google-ads-api` | Google Ads Enhanced Conversions, offline imports, audiences |
| Node | `@google-analytics/data` | `npm i @google-analytics/data` | GA4 Data API reporting (NOT for sending events; use Measurement Protocol) |
| Python | `google-ads` | `pip install google-ads` | Google Ads Enhanced Conversions, offline imports |
| Python | `google-analytics-data` | `pip install google-analytics-data` | GA4 Data API reporting |

For GA4 Measurement Protocol (server-side events), stubs use plain fetch — no SDK needed.

### Meta

| Lang | Library | Install | Use |
|---|---|---|---|
| Node | `facebook-nodejs-business-sdk` | `npm i facebook-nodejs-business-sdk` | Marketing API + CAPI ServerEvent |
| Python | `facebook_business` | `pip install facebook_business` | Same |

For lightweight CAPI calls, direct fetch + appsecret_proof (HMAC-SHA256) is simpler. The skill's stubs use direct fetch.

### Microsoft (Bing) Ads

| Lang | Library | Install | Use |
|---|---|---|---|
| Node | `bing-ads-node-sdk` (community) | `npm i bing-ads-node-sdk` | SOAP API for offline conversions |
| Python | `bingads` | `pip install bingads` | Microsoft official; SOAP-based |

For most users, offline conversions are uploaded via CSV in the UI — no SDK needed.

### LinkedIn Ads

| Lang | Library | Install | Use |
|---|---|---|---|
| Node | direct fetch | (built-in) | LinkedIn CAPI is REST; no Node SDK published |
| Python | `linkedin-api-python-client` | `pip install linkedin-api-client` | Coverage focused on UGC/Profile, not Ads |

Call `/rest/conversionEvents` directly. The skill's stub does this.

### TikTok Ads

| Lang | Library | Install | Use |
|---|---|---|---|
| Node | direct fetch | (built-in) | TikTok Events API S2S |
| Python | direct requests | `pip install requests` | Same |

No first-party SDK. Direct REST is canonical.

### X (Twitter) Ads

| Lang | Library | Install | Use |
|---|---|---|---|
| Node | `twitter-api-v2` | `npm i twitter-api-v2` | OAuth 1.0a + OAuth 2; Ads coverage partial |
| Python | `tweepy` | `pip install tweepy` | Mature; Ads coverage limited |

For Ads CAPI you'll likely call directly with OAuth 1.0a — neither library has full Ads coverage. The stub uses `requests-oauthlib` (Python) or hand-rolled OAuth 1.0a (Node).

### Pinterest / Reddit / Snapchat

| Lang | Library | Install |
|---|---|---|
| Node | direct fetch | (built-in) |
| Python | direct requests | `pip install requests` |

### Apple Search Ads

| Lang | Library | Install | Use |
|---|---|---|---|
| Node | `jose` (JWT) | `npm i jose` | Modern JWS/JWT lib; edge-runtime compatible |
| Python | `pyjwt` + `cryptography` | `pip install pyjwt cryptography` | Standard JWT lib + ES256 backend |

Apple's auth is JWT-then-token-exchange. JWT lib handles signing; you write the rest of the OAuth flow.

## Decision matrix

| Need | Pick |
|---|---|
| Comprehensive Marketing API + CAPI | SDK (Meta, Google) |
| Just CAPI (no campaign management) | Direct fetch — fewer deps |
| Edge-runtime deployment | Direct fetch + Web Crypto (no `node:crypto`) |
| Production at scale | Whichever you can vet for retry / circuit-breaker behavior |

## Not supported well

- **PHP SDKs**: historically lagging; skill skips PHP stubs.
- **Ruby SDKs**: community-only for most platforms.
- **Go SDKs**: partial; community-maintained.

PHP / Ruby / Go: port patterns from Node or Python templates. They're all just HTTP + HMAC-SHA256.

## See also

- `templates/capi-stubs/<platform>/<lang>.template` — drop-in starters.
- `references/setup/capi-stub.md` — install walkthrough.
- `references/platforms/<name>.md` — per-platform CAPI deep-dive.
