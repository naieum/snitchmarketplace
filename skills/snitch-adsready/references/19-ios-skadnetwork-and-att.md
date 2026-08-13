# 19 — iOS SKAdNetwork, ATT, AdAttributionKit

Read only if the user has an iOS app. Web-only sites: mark Apple as ⚪ N/A and move on.

## App Tracking Transparency (ATT)

iOS 14.5+ requires explicit user permission for cross-app tracking. The OS prompts; if declined (~70% of users), the app cannot access IDFA and most cross-app attribution breaks.

```swift
import AppTrackingTransparency

ATTrackingManager.requestTrackingAuthorization { status in
  // .authorized | .denied | .restricted | .notDetermined
}
```

**You can only request ONCE per install.** Decline = decline forever (until reinstall or Settings → Privacy → Tracking).

Pre-prompt screens explaining WHY lift authorization rate from ~30% to ~50%+.

## SKAdNetwork (SKAN)

Apple's privacy-preserving attribution. Network credit via signed postbacks from OS to your campaign server, with limited data:

- Coarse install timestamp (24-hour window).
- Conversion value (single byte v3; v4 adds coarse + fine across multiple windows).
- Campaign ID (32 in v3, 100k in v4).
- Source app or source domain.
- Signed JWS verifying Apple sent it.

No user-level data. All aggregate.

## SKAdNetwork v3 vs v4

| Feature | v3 (iOS 14.5-15.4) | v4 (iOS 16.1+) |
|---|---|---|
| Conversion value | 1 byte (0-63 valid) | 4-bit fine + 2-bit coarse |
| Postback windows | one (24-48h) | three: 0-2d, 3-7d, 8-35d |
| Source identifier | source app | source app OR source domain (web-to-app) |
| Hierarchical IDs | flat 32 campaign IDs | hierarchical (1000s) |
| Privacy threshold | crowd anonymity | crowd anonymity + per-postback redactions |

Most attribution platforms (Adjust, AppsFlyer, Branch, Singular) auto-handle v3 + v4 + AdAttributionKit. DIY: support both. The `apple/node.template` and `apple/python.template` stubs accept either.

## AdAttributionKit (iOS 17.4+)

Apple's successor to SKAdNetwork. Adds:

- App Store-managed conversion-value tables.
- Re-engagement / re-attribution support.
- Web-to-app developer-mode attribution.
- Backward-compatible with SKAdNetwork (apps receive both during transition).

Apps targeting iOS 17.4+ fire postbacks from both. Server should de-dup by `transaction-id` (in both).

## Postback URL setup

In Info.plist:

```xml
<key>NSAdvertisingAttributionReportEndpoint</key>
<string>https://api.example.com/skan-postbacks</string>
```

Postbacks are POSTed as JSON. Your server:

1. Validates JWS signature against Apple's published public key.
2. Extracts campaign ID, conversion value bits, source.
3. Joins to install records by source-domain or source-app.
4. Forwards to ad platforms as a verified install.

The `apple/node.template` stub provides JWS verification + parsing scaffold.

## Apple Search Ads — different beast

Apple Search Ads has its own attribution path predating SKAdNetwork: AAAttribution. Purely first-party (Apple → Apple), no cross-app limits. ASA conversions visible in App Store Connect Analytics + Search Ads dashboard.

For attribution beyond ASA, SKAdNetwork applies.

## Web-to-app campaigns

iOS 17.4+ AdAttributionKit supports web → app attribution. Web link includes attribution params; if user installs within 30 days, Apple delivers a postback to the campaign server.

How Meta + TikTok + Snap measure web-to-app installs without UDID. Web pixel sets attribution params; app SDK reads them on launch.

## Audit signals

Skill marks `apple` as N/A unless:
- User has an iOS app (App Store URL in `<link rel="alternate">` or deep-link metadata).
- OR `APPLE_SEARCH_ADS_*` env vars are set.

Don't manufacture iOS work for web-only sites.

## See also

- `references/platforms/apple.md` — Apple Search Ads / ASA deep-dive.
- Apple SKAdNetwork: https://developer.apple.com/documentation/storekit/skadnetwork
- Apple AdAttributionKit: https://developer.apple.com/documentation/adattributionkit
