# 11 — Google APIs cheatsheet

Concrete `curl` examples for the Google APIs the skill reads or writes. Lazy-load when wiring `state crux`, `state gsc`, `analytics ga4`, or Google Ads Marketing API.

## PageSpeed Insights API (CrUX + Lighthouse)

No auth required; `PSI_API_KEY` raises quota.

```bash
curl -sS "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=https%3A%2F%2Fexample.com&strategy=MOBILE&category=PERFORMANCE&category=ACCESSIBILITY&category=BEST_PRACTICES&category=SEO&key=${PSI_API_KEY}" | jq '.'
```

Response fields:
- `loadingExperience.metrics.LARGEST_CONTENTFUL_PAINT_MS.percentile` — LCP (field, ms)
- `loadingExperience.metrics.INTERACTION_TO_NEXT_PAINT.percentile` — INP (field, ms)
- `loadingExperience.metrics.CUMULATIVE_LAYOUT_SHIFT_SCORE.percentile` — CLS × 100
- `lighthouseResult.categories.performance.score` — Lighthouse perf (0-1)

Empty `loadingExperience` = URL has < 5,000 unique visitors / 28 days; use Lighthouse synthetic only.

## Search Console API

OAuth scope: `https://www.googleapis.com/auth/webmasters.readonly`.

```bash
# List verified properties
curl -sS -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  "https://www.googleapis.com/webmasters/v3/sites" | jq '.'

# Search analytics (top queries last 28 days)
curl -sS -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"startDate":"2026-04-01","endDate":"2026-04-28","dimensions":["query"],"rowLimit":50}' \
  "https://www.googleapis.com/webmasters/v3/sites/https%3A%2F%2Fexample.com%2F/searchAnalytics/query" | jq '.'
```

Site URL must be URL-encoded twice in some endpoints; check for `error.message: "Site not found"`.

## GA4 Data API

OAuth scope: `https://www.googleapis.com/auth/analytics.readonly`.

```bash
curl -sS -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "dateRanges": [{"startDate":"30daysAgo","endDate":"today"}],
    "metrics": [{"name":"sessions"},{"name":"conversions"}],
    "dimensions": [{"name":"sessionSource"},{"name":"sessionMedium"}]
  }' \
  "https://analyticsdata.googleapis.com/v1beta/properties/${PROPERTY_ID}:runReport" | jq '.'
```

`${PROPERTY_ID}` is the GA4 property ID (numeric, NOT the G-XXX measurement ID).

## GA4 Measurement Protocol (server-side events)

No OAuth — uses an API secret minted in GA4 Admin → Data Streams → Measurement Protocol API secrets.

```bash
curl -sS -X POST \
  -H "Content-Type: application/json" \
  --data-binary '{
    "client_id": "1234.5678",
    "events": [{ "name": "purchase", "params": { "transaction_id": "TX-1", "value": 49.99, "currency": "USD" } }]
  }' \
  "https://www.google-analytics.com/mp/collect?measurement_id=${MEASUREMENT_ID}&api_secret=${API_SECRET}"
```

Returns 204 on success. Validate with `/debug/mp/collect` first — same payload, returns parse warnings.

## Google Ads API

OAuth + developer token + login customer ID. Full API is gRPC; REST is supported but verbose.

```bash
# List accessible customers
curl -sS \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "developer-token: ${DEV_TOKEN}" \
  -H "Content-Type: application/json" \
  "https://googleads.googleapis.com/v25/customers:listAccessibleCustomers" | jq '.'

# Search query
curl -sS -X POST \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "developer-token: ${DEV_TOKEN}" \
  -H "login-customer-id: ${LOGIN_CUSTOMER_ID}" \
  -H "Content-Type: application/json" \
  -d '{"query": "SELECT campaign.id, campaign.name, campaign.status FROM campaign WHERE campaign.status != REMOVED LIMIT 50"}' \
  "https://googleads.googleapis.com/v25/customers/${CUSTOMER_ID}/googleAds:search" | jq '.'
```

## Google OAuth refresh

```bash
curl -sS -X POST https://oauth2.googleapis.com/token \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=${GOOGLE_OAUTH_CLIENT_ID}" \
  -d "client_secret=${GOOGLE_OAUTH_CLIENT_SECRET}" \
  -d "refresh_token=${GOOGLE_OAUTH_REFRESH_TOKEN}" \
  -d "grant_type=refresh_token" | jq -r '.access_token'
```

Cache the access token until ~5 minutes before its `expires_in` (default 3600s).

## Tag Manager API

```bash
curl -sS -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  "https://www.googleapis.com/tagmanager/v2/accounts/${ACCOUNT_ID}/containers/${CONTAINER_ID}/workspaces/${WORKSPACE_ID}/tags" | jq '.'
```

Diff workspace tag against published live one when "tag in container but not firing."

## See also

- `01-auth-and-tokens.md` — env-var conventions.
- `references/platforms/google.md` — deeper Google walk-through.
- API Explorer: https://developers.google.com/apis-explorer
