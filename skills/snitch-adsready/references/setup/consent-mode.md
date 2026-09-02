# Setup — Consent Mode v2

Walkthrough for `setup consent-mode`. Goal: install the v2 default-deny snippet plus integration glue with a CMP, so pixels respect EU/UK/EEA + CCPA + state laws.

## Pre-checks

1. **Run `bash ads-ready.sh state site <url> consent`.** Reports CMP detection (Cookiebot, OneTrust) and CMv2 default state.
2. **Identify regional scope.** EU/UK/EEA + Switzerland → CMv2 mandatory. CA + state laws → opt-out + GPC respect required.
3. **Confirm no existing CMP that conflicts.** Two CMPs at once = chaos.

## Steps

### 1. Pick a CMP if none installed (external-tool)

```bash
bash ads-ready.sh recommend cmp
```

Catalog: OneTrust (enterprise), Cookiebot (mid-market), CookieYes (free tier), Klaro (open-source), Termly (small biz), Osano (mid-market).

- **Budget**: Klaro (free, self-hosted) → CookieYes free / Cookiebot ($11+) → Termly ($15+) → Osano ($199+) → OneTrust (enterprise quote).
- **Compliance scope**: full IAB TCF v2.2 + multi-jurisdiction → OneTrust / Cookiebot / Osano. Single-region GDPR → CookieYes / Klaro / Termly.
- **DevOps**: managed (auto cookie scan) → Cookiebot / OneTrust / CookieYes / Termly / Osano. Self-hosted → Klaro.

### 2. Install the chosen CMP (manual / external-tool)

- **OneTrust**: Sign up → publish DataMap → embed SDK script in `<head>`.
- **Cookiebot**: Sign up → grant scan access → paste auto-blocking script as the FIRST `<script>` in `<head>`.
- **CookieYes**: Sign up → install via WordPress plugin (if WP) or paste embed snippet.
- **Klaro**: `npm install klaro`; configure services in JS; serve klaro.js + klaro.css.
- **Termly**: Sign up → embed Termly CMP script.
- **Osano**: Sign up → embed Osano script in `<head>`.

CMP must load BEFORE any pixels.

### 3. Set Consent Mode v2 defaults to denied (manual / auto)

Default-deny snippet — first inline script in `<head>`, before the CMP:

```html
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('consent', 'default', {
    ad_storage: 'denied',
    ad_user_data: 'denied',
    ad_personalization: 'denied',
    analytics_storage: 'denied',
    wait_for_update: 500
  });
</script>
```

Locks tags into deny mode for first 500ms while CMP loads + reads prior consent. After 500ms (or after `gtag('consent','update',...)`), tags fire with actual state.

### 4. Apply integration glue (auto)

```bash
bash ads-ready.sh fix consent-mode
```

The apply step:
- Adds default-deny snippet to host file `<head>`.
- For platforms not natively wired by the CMP, adds bridge calls:
  - `fbq('consent','grant'/'revoke')` for Meta.
  - `ttq.consent('grant'/'revoke')` for TikTok.
  - `pintrk('consent','grant')` for Pinterest.
  - etc.

Most paid CMPs (Cookiebot, OneTrust, CookieYes, Termly, Osano) wire automatically. Klaro requires manual config of the `services` list.

### 5. Verify consent signals reach platforms (manual)

Click "Decline All". In DevTools → Network confirm:
- No requests to googletagmanager.com / google-analytics.com (analytics denied).
- No requests to facebook.com / connect.facebook.net (ads denied).
- No requests to other platform domains.

Click "Accept All" and confirm those requests appear.

For finer verification, use Tag Assistant (shows consent state per tag) or Meta Pixel Helper (shows consent_state field).

### 6. Re-run state site (auto)

```bash
bash ads-ready.sh state site <url> consent
```

The `consent` slice reports three fields:
- `.consent.platform` — the detected CMP vendor, or `"none"`
- `.consent.consent_mode_v2` — `true` once the v2 signals are present
- `.consent.has_data_layer` — `true` when a `dataLayer` is on the page

If `.consent.platform` is `"none"` but you installed a CMP, the vendor's signature may not be in
the skill's detector — `references/04-consent-and-cmp.md` lists what it recognizes. The tool
does not report a default state; read the `html` slice and check the `'default'` call yourself.

## Common failures

| Symptom | Cause |
|---|---|
| Tags fire BEFORE consent prompt closes | `wait_for_update` too short or default-deny script below CMP in source order |
| Banner appears every page reload | CMP cookie not being set; check CMP host domain matches site apex |
| Consent state ignored on "Accept All" | CMP not calling `gtag('consent','update',...)` — wire manually if your CMP doesn't |
| Google Ads conversions still down post-fix | EU enforcement of CMv2 lifts conversions ~30-60 days after fix; not instant |

## See also

- `04-consent-and-cmp.md` — full reference.
- `references/recommendations/cmp.md` — vendor catalog.
- Google CMv2: https://developers.google.com/tag-platform/security/guides/consent
