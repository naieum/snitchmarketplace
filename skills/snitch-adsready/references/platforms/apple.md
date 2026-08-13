# Apple Ads (Search Ads + Maps Ads) and Apple Business

Two ad surfaces now, not one: the App Store (the classic Search Ads product below) and
**Apple Maps ads** — launching summer 2026 (US + Canada, iOS 26.5). See the Apple
Business + Maps section before the App Store material when the advertiser is a local /
physical-location business.

## Apple Business + Maps Ads (local businesses)

- **Apple Business** (April 2026) unified Business Connect, Business Manager, and Business
  Essentials into one platform, 200+ countries — <https://business.apple.com>. Claiming the
  Maps place card there is the **prerequisite for Maps ads** and feeds Maps, Siri, Wallet,
  Messages, and Spotlight.
- **Maps ads** appear atop Maps search results and the Suggested Places surface. Targeting:
  keywords, location, dayparts. Managed via the Apple Ads interface or an automated flow in
  Apple Business; campaign-management and reporting **APIs** are part of the launch.
- **Privacy model = no pixel, again.** Ads aren't associated with the user's Apple Account
  and no behavioral data leaves the device — so like ChatGPT ads, readiness is presence
  quality, not tag installation: a claimed and deeply-filled place card (hours, photos,
  actions/Showcases, category), accurate NAP consistent with the site (`LocalBusiness`
  schema, see `07-structured-data.md`), and click-out landing pages measured with your own
  analytics + the reporting API.
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

Universal: SKAdNetwork / AdAttributionKit / ATT in `19-ios-skadnetwork-and-att.md`.

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
8. Update `PrivacyInfo.xcprivacy` (privacy manifest) to declare API usage and tracking domains.

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

## Consent integration

- **ATT (iOS 14.5+)**: SKAdNetwork postbacks don't depend on ATT — aggregate. ATT controls IDFA access and Apple Ads Attribution API per-user attribution.
- **Privacy manifest** (`PrivacyInfo.xcprivacy`): declare "Required Reason API" categories + tracking domains. Required for App Store submission as of May 2024.

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
- App Tracking Transparency: <https://developer.apple.com/documentation/apptrackingtransparency>
- Privacy manifest: <https://developer.apple.com/documentation/bundleresources/privacy_manifest_files>
- Smart App Banners: <https://developer.apple.com/documentation/webkit/promoting_apps_with_smart_app_banners>
- app-ads.txt: not generally required for ASA advertisers
