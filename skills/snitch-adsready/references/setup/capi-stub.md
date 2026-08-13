# Setup — CAPI stub

Walkthrough for `setup capi-stub <platform>`. Goal: install a working server-side conversion endpoint that hashes PII, signs the request, and POSTs to the platform's CAPI.

## Pre-checks

1. **Run `bash ads-ready.sh detect`.** Confirm server-side language (Node, Python) and framework (Express / Fastify / Hono / Next API / Flask / FastAPI / Django).
2. **Confirm pixel already installed for this platform.** CAPI complements the pixel.
3. **Confirm user has CAPI credentials.** Without access token + pixel/dataset ID, stub installs but won't authenticate.

## Steps

### 1. Create CAPI access token in platform dashboard (external-tool)

| Platform | Where | Permissions |
|---|---|---|
| Google | https://console.cloud.google.com → OAuth credentials; or Enhanced Conversions in Ads UI | analytics.edit + ads.write |
| Meta | https://business.facebook.com → Business Settings → System Users → Generate Token | ads_management |
| Microsoft | https://ads.microsoft.com → Tools → Microsoft Advertising API → Developer token + OAuth refresh | offline_access + msads.manage |
| LinkedIn | https://www.linkedin.com/developers → Apps → Auth tab → 3-legged OAuth | r_ads, r_organization_social, w_organization_social, rw_ads |
| TikTok | https://business-api.tiktok.com → Apps → Generate token | ads.read + advertiser auth |
| X | https://developer.twitter.com → Projects → Apps → Keys (OAuth 1.0a) | Ads-API access (requires approval) |
| Pinterest | https://developers.pinterest.com → Apps → OAuth | ads:read + ads:write |
| Reddit | https://ads-api.reddit.com → OAuth | ads:write |
| Snapchat | https://kit.snapchat.com/portal/marketing-api → Apps → Snap Login OAuth | snapchat-marketing-api |
| Apple | Apple Developer → Apple Search Ads API → Generate API Key (.pem) + Team/Key/Client IDs | searchadsorg |

Copy access token (and any related secrets — appsecret, pixel ID, advertiser ID).

### 2. Set CAPI env vars in your deployment (manual)

Set in hosting platform's secret store — NEVER commit to git:

```bash
# Vercel:    vercel env add META_ACCESS_TOKEN
# Cloudflare: wrangler secret put META_ACCESS_TOKEN
# AWS:       Secrets Manager / SSM Parameter Store
# Render:    Dashboard → Environment → Add Secret
```

Exact env-var names live in `templates/capi-stubs/<platform>/<lang>.template`.

### 3. Render the CAPI stub (auto)

```bash
bash ads-ready.sh fix capi-stub <platform>
```

The apply step:
- Detects language (Node from `package.json`, Python from `requirements.txt` / `pyproject.toml`).
- Detects framework: Express / Fastify / Hono / Next API / Flask / FastAPI / Django.
- Reads `templates/capi-stubs/<platform>/<lang>.template`.
- Emits `=== FILE/DIFF/CONTENT ===` targeting the right path:
  - Next App Router → `app/api/capi/<platform>/route.ts`
  - Next Pages Router → `pages/api/capi/<platform>.ts`
  - Express / Fastify / Hono → `src/routes/capi-<platform>.ts`
  - Flask / FastAPI → `capi_<platform>.py`
  - Django → `capi/views_<platform>.py`
- Idempotent.

### 4. Wire the stub to your conversion trigger (manual)

The stub is a handler. Your code calls it from purchase / signup / lead webhook:

```ts
// Example: Stripe webhook in a Next API route
import { sendMetaCapiEvent } from "@/lib/meta-capi";

export async function POST(req) {
  const event = await stripeWebhookVerify(req);
  if (event.type === "checkout.session.completed") {
    await sendMetaCapiEvent({
      eventName: "Purchase",
      eventId: event.data.object.metadata.event_id,  // from your client-side fbq pixel
      url: event.data.object.metadata.referer,
      email: event.data.object.customer_details.email,
      value: event.data.object.amount_total / 100,
      currency: event.data.object.currency,
    });
  }
  return Response.json({ received: true });
}
```

Make sure `event_id` matches what the client-side pixel sent — that's how the platform deduplicates.

### 5. Deploy + send a test event (manual)

- **Meta**: Events Manager → Test Events tab → send test event from UI; confirm server-side event arrives.
- **TikTok**: Events Manager → Test Event Code (TEST123) → fire test event from stub.
- **Google**: Google Ads → Conversions → Diagnose; or GA4 → Realtime.
- Each Events Manager has a Test Events panel.

Use a `test_event_code` env var if the platform supports it (Meta, TikTok do).

### 6. Verify dedup ratio (manual)

After 24h of production traffic:

- **Meta**: Events Manager → Pixel → Diagnostics → Server + Browser dedup ratio. Healthy: 80%+ matched.
- **TikTok**: Events Manager → Web Events → dedup ratio.
- **Google**: Enhanced Conversions → Diagnostics.

Ratio < 50% = dedup ID isn't matching client + server. Audit your event_id flow.

## Common failures

| Symptom | Cause |
|---|---|
| `401 Unauthorized` on every CAPI send | Access token expired (Snap: 30 min; Reddit: 1h); add refresh logic |
| `400 Bad Request: invalid pixel ID` | Pixel ID and access token mismatched (different account) |
| Test events arrive but production doesn't | `test_event_code` left in production payload — remove |
| Dedup ratio below 50% | event_id not matching client / server |
| CAPI throws on edge runtime | `node:crypto` not available; switch to Web Crypto |

## See also

- `02-pixel-foundations.md` — pixel + CAPI dedup overview.
- `references/recommendations/capi-helpers.md` — per-platform helper libs.
- `references/platforms/<name>.md` — platform-specific CAPI.
