# Apple technical and privacy-infrastructure requirements

When to read this: auditing build settings, Info.plist, entitlements, PrivacyInfo.xcprivacy, ATS, or ATT wiring before an App Store submission.

## Build and SDK floor

- Apps must be built with Xcode 26 and the iOS 26 / iPadOS 26 / tvOS 26 / visionOS 26 / watchOS 26 SDK (in force since April 28, 2026). This floor moves roughly yearly each spring; current as of 2026-08 — verify at https://developer.apple.com/news/upcoming-requirements/. The deployment target may stay lower; only the build SDK is gated.
- Device slices are arm64 only. Bitcode is dead: deprecated in Xcode 14 and rejected at upload. A third-party framework precompiled with bitcode will fail the archive — strip it (`bitcode_strip`). Static check: `otool -l <binary> | grep __LLVM` on embedded frameworks.
- App thinning requires consistent architectures between the app and every embedded framework.
- Mac App Store apps must be sandboxed; submitted bundles must not carry the `com.apple.quarantine` xattr.

## Network

- IPv6-only compatibility is mandatory (guideline 2.5.5). Test on a Mac internet-sharing NAT64 network. Hardcoded IPv4 literals are the usual failure.
- App Transport Security: `NSAllowsArbitraryLoads=true` invites review scrutiny and needs a justification the reviewer accepts (for example, user-supplied or third-party servers outside your control). Prefer scoped `NSExceptionDomains` with per-domain keys (`NSExceptionAllowsInsecureHTTPLoads`, `NSExceptionMinimumTLSVersion`). Static check: `NSAppTransportSecurity` dict in Info.plist; flag global arbitrary-loads and overbroad `NSAllowsArbitraryLoadsInWebContent`/`ForMedia`.

## Background modes (2.5.4)

Every `UIBackgroundModes` entry must map to real user-facing functionality: `voip` requires actual VoIP (CallKit/PushKit), `audio` requires background playback, `location` requires always-style features. A music app declaring `audio` with no background playback is a rejection. Static check: `UIBackgroundModes` array vs. evidence of the matching frameworks in code — see references/09-static-checks.md.

## Privacy nutrition labels (App Privacy in App Store Connect)

Source: https://developer.apple.com/app-store/app-privacy-details/

- Three buckets: Data Used to Track You / Data Linked to You / Data Not Linked to You, across 14 category groups (Contact Info, Location, Identifiers, Usage Data, Diagnostics, ...).
- "Collect" means transmitted off-device and retained beyond servicing the real-time request. On-device-only processing is exempt.
- You must declare everything your third-party SDKs collect, including SDK features you do not use if the SDK repurposes the data. IP address counts (declare as location, device ID, or diagnostics).
- Labels are editable without a new build; keep them synchronized with the privacy manifest and actual behavior. Label / manifest / behavior mismatch is a standing rejection risk.

## Privacy manifests and required-reason APIs

`PrivacyInfo.xcprivacy` is required in the app target. Keys: `NSPrivacyTracking`, `NSPrivacyTrackingDomains` (mandatory when tracking is true; those domains are blocked until ATT consent), `NSPrivacyCollectedDataTypes`, `NSPrivacyAccessedAPITypes`.

Since May 1, 2024, uploads using required-reason APIs without an approved reason are rejected (ITMS-91053 missing declaration, ITMS-91055 invalid reason). Categories and the principal reason codes:

| Category | Covers | Common approved codes |
|---|---|---|
| `NSPrivacyAccessedAPICategoryFileTimestamp` | creationDate, modificationDate, stat, fstat, getattrlist | DDA9.1 (display to user), C617.1 (in-container access), 3B52.1 (user-granted files), 0A2A.1 (SDK wrapper) |
| `NSPrivacyAccessedAPICategorySystemBootTime` | systemUptime, mach_absolute_time | 35F9.1 (elapsed time in-app), 8FFB.1 (absolute timestamps), 3D61.1 (opt-in bug report) |
| `NSPrivacyAccessedAPICategoryDiskSpace` | volumeAvailableCapacity, statfs | E174.1 (check before writing), 85F4.1 (display to user), 7D9E.1 (opt-in bug report) |
| `NSPrivacyAccessedAPICategoryActiveKeyboards` | activeInputModes | 3EC4.1 (keyboard-extension app), 54BD.1 (customize UI) |
| `NSPrivacyAccessedAPICategoryUserDefaults` | UserDefaults / NSUserDefaults | CA92.1 (app's own defaults), 1C8F.1 (app group, same developer), C56D.1 (SDK wrapper), AC6B.1 (managed configuration) |

Full code list: https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api

Static check: PrivacyInfo.xcprivacy present; every declared category has a valid code; cross-grep the codebase for `UserDefaults(`, `systemUptime`, `mach_absolute_time`, `volumeAvailableCapacity`, `activeInputModes`, `stat(` and confirm each hit is covered — see references/09-static-checks.md.

## Third-party SDK manifests and signatures

Apple maintains a list of roughly 86 commonly-used SDKs that must each ship their own privacy manifest and code signature; adding one without them blocks new apps and updates at upload. Representative entries: the Firebase family, FBSDK (CoreKit/LoginKit/ShareKit), GoogleSignIn, Alamofire, AFNetworking, SDWebImage, Kingfisher, Lottie, RealmSwift, RxSwift, OneSignal, UnityFramework, Capacitor, Cordova, Flutter and its common plugins (image_picker_ios, shared_preferences_ios, path_provider, webview_flutter_wkwebview, sqflite, geolocator_apple, device_info_plus, ...).

Do not maintain your own copy of the list; check dependencies against https://developer.apple.com/support/third-party-SDK-requirements/. The practical audit move: update listed SDKs to versions that bundle a manifest, and treat an upload error naming ITMS-91053 against an SDK bundle ID as "upgrade that dependency".

## App Tracking Transparency

Source: https://developer.apple.com/app-store/user-privacy-and-data-use/

- Any tracking (linking app data with third-party data for advertising, or sharing with data brokers) and any IDFA read requires the ATT prompt first; without consent the IDFA returns zeros.
- `NSUserTrackingUsageDescription` is required alongside any `ATTrackingManager.requestTrackingAuthorization` call. Static check: the API without the plist key, or a tracking SDK without either.
- You cannot gate features on consent, incentivize it, or re-prompt manipulatively (5.1.1(iv), 5.1.2(i)).
- Fingerprinting is banned outright, including inside SDKs, and is grounds for rejection even when the user granted ATT consent.
- IDFV is acceptable for same-developer analytics only. Webviews count as native code for tracking purposes unless the app is a general-purpose browser.
- Pre-prompt explainer screens are allowed; a separate GDPR consent flow is allowed but cannot override the ATT choice.

## Certificates and receipts (context, rarely audit findings)

- APNs trust requires the USERTrust RSA CA (SHA-2) root (since early 2025).
- The SHA-1 receipt-signing certificate expired January 2025; validate receipts with the AppTransaction/Transaction APIs or SHA-256.
