# Setup — pixel install

Walkthrough that the agent reads when running `setup pixel-install <platform>`. Agent presents these to the user, gets confirmation, chains matching `fix` calls.

## Pre-checks

1. **Run `bash ads-ready.sh detect`.** Confirm host stack (Next, Astro, SvelteKit, Vite SPA, WordPress, Shopify, Webflow, vanilla HTML).
2. **Run `bash ads-ready.sh state site <url> pixels`.** If platform pixel signature already present, skip to verification.
3. **Confirm user has access to platform's ads dashboard.** Without an account, you cannot create the pixel.

## Steps

### 1. Create the pixel in the platform dashboard (manual)

| Platform | Dashboard | Object name |
|---|---|---|
| Google | https://ads.google.com → Tools → Conversions; or https://analytics.google.com → Admin → Data Streams | Conversion ID + label, OR GA4 Measurement ID |
| Meta | https://business.facebook.com/events_manager2 | Pixel ID (15-16 digits) |
| Microsoft | https://ads.microsoft.com → Tools → Conversion Tracking → UET tag | UET tag ID |
| LinkedIn | https://www.linkedin.com/campaignmanager → Account Assets → Insight Tag | Partner ID |
| TikTok | https://ads.tiktok.com → Tools → Events → Web | Pixel code |
| X | https://ads.x.com → Tools → Events Manager → Pixel | Pixel ID |
| Pinterest | https://ads.pinterest.com → Conversions | Tag ID |
| Reddit | https://ads.reddit.com → Events Manager → Pixel | Pixel ID |
| Snapchat | https://ads.snapchat.com → Events Manager → Pixel | Pixel ID |
| Apple | https://searchads.apple.com / Info.plist for SKAdNetwork postback | NSAdvertisingAttributionReportEndpoint |

Copy the pixel ID.

### 2. Set the pixel ID env var (manual)

```bash
export ADSSEC_GOOGLE_AW_ID='AW-XXXXXXX'
export ADSSEC_GA4_MEASUREMENT_ID='G-XXXXXXX'
export ADSSEC_META_PIXEL_ID='1234567890123456'
export ADSSEC_TIKTOK_PIXEL_CODE='C1234567890ABCDEF'
# ...per platform
```

Or pass directly to `fix`. Exact env-var names live in `templates/pixel-snippets/<platform>.html`.

### 3. Apply the pixel snippet (auto)

```bash
bash ads-ready.sh fix pixel-install <platform>
```

The apply step:
- Refuses first when the project shows no consent banner / CMP signal — a 🔴 FAIL pointing at
  `fix consent-mode` and `recommend cmp`. Land consent before the pixel.
- Reads `templates/pixel-snippets/<platform>.html`.
- Detects host stack.
- Emits `=== FILE/DIFF/CONTENT ===` block targeting:
  - Next App Router → `app/layout.tsx`
  - Next Pages Router → `pages/_document.tsx`
  - Astro → `src/layouts/Layout.astro`
  - SvelteKit → `src/app.html`
  - Nuxt → `nuxt.config.ts` (or `app.vue`)
  - WordPress → `wp-content/themes/<theme>/functions.php` via `wp_head`
  - Shopify → use platform's native channel app instead (or Custom Pixel via Web Pixel API)
  - Vite SPA / vanilla HTML → `index.html`
- Idempotent: no-op if signature already present.

Agent applies via `Edit` / `Write` after user confirms.

### 4. Deploy the change (manual)

User runs their normal deploy command. Skill does not deploy.

### 5. Verify the pixel fires (manual)

| Platform | Tool |
|---|---|
| Google | Tag Assistant Companion: https://tagassistant.google.com |
| Meta | Meta Pixel Helper (Chrome ext) |
| Microsoft | UET Tag Helper |
| LinkedIn | LinkedIn Insight Tag Helper |
| TikTok | TikTok Pixel Helper |
| X | DevTools → Network → search `analytics.twitter.com` |
| Pinterest | Pinterest Tag Helper |
| Reddit | DevTools → Network → `redditstatic.com/ads` |
| Snapchat | Snap Pixel Helper |

Open tool, load deployed page, confirm pixel fires once with expected ID.

### 6. Re-run state site (auto)

```bash
bash ads-ready.sh state site <url> pixels
```

The `pixels` slice should now report `.pixels.<platform>.detected = true`, with the ids it found in `.pixels.<platform>.ids`. If it is still false:
- Did the user actually deploy?
- Snippet in the source HTML (`view-source:`)?
- CSP blocking the platform's domain?
- See `13-incident-response.md`.

## When to skip

- Shopify with a Marketing channel app — use the app (idempotent, survives theme updates).
- WordPress with Site Kit by Google or PixelYourSite — plugin manages snippet; don't double-install.
- `state site` already shows the pixel — verification only.

## See also

- `02-pixel-foundations.md` — init order.
- `04-consent-and-cmp.md` — consent must be wired BEFORE pixels for EU/UK.
- `references/platforms/<name>.md` — platform-specific setup.
