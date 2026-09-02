# Apple Ads (Search Ads + Maps Ads) and Apple Business

Two ad surfaces now, not one: the App Store (the classic Search Ads product below) and
**Apple Maps ads** — live in the US and Canada since August 2026. See the Apple
Business + Maps section before the App Store material when the advertiser is a local /
physical-location business.

## Apple Business + Maps Ads (local businesses)

- **Apple Business** (2026-04-14) unified Business Connect, Business Manager, and Business
  Essentials into one platform — <https://business.apple.com>. Claiming the
  Maps place card there is the **prerequisite for Maps ads** and feeds Maps, Siri, Wallet,
  Messages, and Spotlight.
- **Maps ads** appear atop Maps search results and the Suggested Places surface. Targeting:
  keywords, location, dayparts. Small advertisers create campaigns inside Apple Business;
  larger ones use the Apple Ads platform. Whether the Maps surface is exposed through the
  Apple Ads Campaign Management API is not confirmed here — check the API reference below
  before promising programmatic reporting.
- **Privacy model = no pixel, again.** Ads aren't associated with the user's Apple Account
  and no behavioral data leaves the device — so like ChatGPT ads, readiness is presence
  quality, not tag installation: a claimed and deeply-filled place card (hours, photos,
  actions/Showcases, category), accurate name/address/phone consistent with the site, and
  click-out landing pages measured with your own analytics + the reporting API. The place
  card and the site's local-search markup are a listings surface — **call the Skill tool with
  "snitch-marketing"** for that half.
- **Applebot** governs Apple's web crawl (Siri, Spotlight, and Maps web enrichment);
  **Applebot-Extended** is only the Apple AI-training opt-out — blocking it does not hurt
  Maps/Siri presence, blocking Applebot does. The `state site <url> robots` slice reports
  both under `crawler_access`.
- What the audit can check today: robots verdicts for both Applebot agents, LocalBusiness
  schema + NAP on the site, landing-page lead capture. What it can't: place-card claim
  state (verify in Apple Business directly; no public read API for claim status yet).

# Apple Search Ads (App Store)

| Field | Value |
|---|---|
| Web tag | **None** — Apple Search Ads has no JavaScript pixel |
| Identifiers | Org ID, App Store app id, Apple Developer Team ID |
| Server-side / app-side | **SKAdNetwork** (iOS 14.5+) and **AdAttributionKit** (iOS 17.4+) — postbacks to your server |
| Account model | Org → app → campaign → ad group → keyword |
| Marketing API | Apple Search Ads Campaign Management API v5 — `api.searchads.apple.com/api/v5` |
| Auth | OAuth2 client_credentials with **ES256-signed JWT** as `client_secret`; bearer issued by `appleid.apple.com/auth/oauth2/token` |
| Consent | iOS App Tracking Transparency (ATT); SKAdNetwork postbacks aggregate by design — don't require ATT consent |

The iOS attribution mechanics (ATT, SKAdNetwork v3/v4, AdAttributionKit, postback wiring) are the "## iOS attribution" section below.

## Setup

1. Apply / log into Apple Search Ads Advanced at <https://searchads.apple.com>. (Basic = managed; Advanced = self-serve with API access.)
2. Apple Developer portal → Account & Settings → API → API Users. Save .p8 key (one-time download), Key ID, Team ID.
3. Configure SKAdNetwork in iOS app:
   - `SKAdNetworkItems` in `Info.plist` (one entry per ad network).
   - `NSAdvertisingAttributionReportEndpoint` to receive postbacks.
4. Implement `SKAdNetwork.updatePostbackConversionValue(_:)` (iOS 14.5–) or AdAttributionKit (iOS 17.4+).
5. Stand up postback receiver (HTTPS) — Apple POSTs JSON with `version`, `ad-network-id`, `transaction-id`, `campaign-id`, `app-id`, `attribution-signature`, `redownload`, `did-win`, optional `conversion-value`, `source-app-id`, `source-domain`. Verify signature against Apple's public key set.
6. (Optional) Use Apple Ads Attribution API in-app for detail-token + non-aggregate attribution for ATT-granted users.
7. Implement ATT prompt (`ATTrackingManager.requestTrackingAuthorization(...)`).
8. Declare the SDK's tracking domains and API usage in the app's privacy manifest. That declaration is a store-submission requirement, not an ads-readiness one — for it, call the Skill tool with "snitch-storeready".

## Conversion taxonomy (app-side)

No "events" in the web-pixel sense. Instead:

- **SKAdNetwork conversion value (CV)**: 6-bit value (0-63) you map to a meaningful conversion event in your app. Mapping is yours — Apple doesn't specify.
- **Coarse / fine** (iOS 16.1+): `ConversionValue.coarse` (low/medium/high) layered on fine CV.
- **Postback windows** (iOS 15.4+): up to 3 postbacks at 0-2d, 3-7d, 8-35d.

## Server-side

No real-time CAPI. Postbacks arrive asynchronously (24-48h after window close) and are AGGREGATE — no IDFA, no 1:1 attribution unless user granted ATT and app reads `AAAttribution.attributionToken`.

Server tasks:
- Accept POST application/json from Apple's IPs.
- Verify `attribution-signature` against Apple's public key set (rotated periodically).
- Persist raw postback for audit + funnel reconstruction.
- Aggregate by `campaign-id`; push to data warehouse / BI.

## iOS attribution: ATT, SKAdNetwork, AdAttributionKit

Read this section only if the user has an iOS app. Web-only sites: mark Apple ⚪ Skip and move on.

### App Tracking Transparency (ATT)

iOS 14.5+ requires explicit user permission for cross-app tracking. The OS prompts; if declined, the app cannot access IDFA and most cross-app attribution breaks.

```swift
import AppTrackingTransparency

ATTrackingManager.requestTrackingAuthorization { status in
  // .authorized | .denied | .restricted | .notDetermined
}
```

**You can only request ONCE per install.** Decline = decline forever (until reinstall or Settings → Privacy → Tracking). A pre-prompt screen explaining WHY lifts the authorization rate materially; ship one.

### SKAdNetwork (SKAN)

Apple's privacy-preserving attribution. Network credit arrives as signed postbacks from the OS to your campaign server, carrying:

- Coarse install timestamp (24-hour window).
- Conversion value (single byte in v3; v4 adds coarse + fine across multiple windows).
- Campaign ID.
- Source app or source domain.
- Signed JWS proving Apple sent it.

No user-level data. All aggregate.

| Feature | v3 (iOS 14.5-15.4) | v4 (iOS 16.1+) |
|---|---|---|
| Conversion value | 1 byte (0-63 valid) | 4-bit fine + 2-bit coarse |
| Postback windows | one (24-48h) | three: 0-2d, 3-7d, 8-35d |
| Source identifier | source app | source app OR source domain (web-to-app) |
| Hierarchical IDs | flat campaign IDs | hierarchical |
| Privacy threshold | crowd anonymity | crowd anonymity + per-postback redactions |

The major mobile attribution platforms auto-handle v3, v4, and AdAttributionKit. Rolling your own means supporting both; the `apple/node.template` and `apple/python.template` stubs accept either.

### AdAttributionKit (iOS 17.4+)

SKAdNetwork's successor. Adds App Store-managed conversion-value tables, re-engagement / re-attribution (iOS 18+), and a developer mode for testing postbacks, and stays backward-compatible with SKAdNetwork. It covers app-to-app campaigns; web → app stays on SKAdNetwork v4 (checked 2026-09-01). Apps targeting iOS 17.4+ fire postbacks from both — de-dup server-side by `transaction-id`, which appears in each. Plan for a multi-year migration.

### Postback URL setup

In `Info.plist`:

```xml
<key>NSAdvertisingAttributionReportEndpoint</key>
<string>https://api.example.com/skan-postbacks</string>
```

Postbacks arrive as JSON POSTs. Your server:

1. Validates the JWS signature against Apple's published public key set.
2. Extracts campaign ID, conversion-value bits, source.
3. Joins to install records by source-domain or source-app.
4. Forwards to ad platforms as a verified install.

The `apple/node.template` stub provides the JWS verification + parsing scaffold.

### Apple Search Ads is a different path

Apple Search Ads has its own attribution path predating SKAdNetwork: AAAttribution. Purely first-party (Apple → Apple), no cross-app limits. ASA conversions are visible in App Store Connect Analytics and the Search Ads dashboard. For attribution beyond ASA, SKAdNetwork applies.

### Web-to-app campaigns

Web → app attribution is SKAdNetwork v4 (iOS 16.1+), not AdAttributionKit: the ad link on the web carries the attribution params, and the postback reports a **source domain** in place of a source app, so Apple credits the install to the site the click came from. The click window matches the in-app one — the install has to happen within 30 days of the click. This is how the large social platforms measure web-to-app installs without a device identifier — the web pixel sets the params, the app SDK reads them on launch. Apple's ad-attribution documentation scopes AdAttributionKit to app-to-app campaigns (plus re-engagement from iOS 18), so keep web-to-app on v4 (checked 2026-09-01).

### When the audit marks apple N/A

The skill marks `apple` Skip unless the user has an iOS app (App Store URL in `<link rel="alternate">` or deep-link metadata) or `APPLE_SEARCH_ADS_*` env vars are set. Don't manufacture iOS work for web-only sites.

## Consent integration

- **ATT (iOS 14.5+)**: SKAdNetwork postbacks don't depend on ATT — aggregate. ATT controls IDFA access and Apple Ads Attribution API per-user attribution.

## Audiences + targeting

Keyword-driven (search ads on App Store), not audience-driven:

- **Search Match** (auto-keyword expansion).
- **Custom Product Pages** (alternate listings tied to keywords).
- **Today tab / Product Pages** (iOS 14.5+) — Apple-curated outside search.
- Demographics (age band, gender) and device class (iPhone / iPad) are the primary audience filters.

## Notable extras

- **No JS pixel**: `apple.html` snippet only installs the `apple-itunes-app` Smart Banner meta tag. Skill's `state site` parser detects this as the iOS-app marker.
- **OAuth2 via ES256 JWT**: unique among the 10. `lib/platforms/apple.sh` includes inline JWT signing using `openssl` + `xxd` for DER → R||S — verify both binaries in `prereqs`.
- **AdAttributionKit (iOS 17.4+)**: SKAdNetwork's successor; supports re-engagement and JWS-signed click invocations. Plan for multi-year migration.
- **Custom Product Pages**: each variant has its own conversion-rate metric — surface in reporting separately.

## Cited URLs

- Campaign Management API: <https://developer.apple.com/documentation/apple_search_ads>
- API auth (OAuth2 + ES256 JWT): <https://developer.apple.com/documentation/apple_search_ads/implementing_oauth_for_the_apple_search_ads_api>
- SKAdNetwork: <https://developer.apple.com/documentation/storekit/skadnetwork>
- AdAttributionKit: <https://developer.apple.com/documentation/adattributionkit>
- Ad attribution scope, app-to-app + re-engagement (checked 2026-09-01): <https://developer.apple.com/app-store/ad-attribution/>
- App Tracking Transparency: <https://developer.apple.com/documentation/apptrackingtransparency>
- Smart App Banners: <https://developer.apple.com/documentation/webkit/promoting_apps_with_smart_app_banners>
- app-ads.txt: not generally required for ASA advertisers
- Apple Maps ads launch, US + Canada, August 2026 (verified 2026-09-01): <https://9to5mac.com/2026/08/25/apple-maps-launches-ads-on-iphone-heres-whats-new/>
