# Static checks — the grep-able audit surface

When to read this: you are running the code-side audit (STEP 2). Every check here is verifiable with Read/Grep/Glob against the project, plus at most one HTTP GET per check. For store-console items you cannot verify from code, use references/10-store-checklists.md.

**Facts verified: 2026-09-01.** Dates, fees, quotas, and thresholds below were checked against the cited official pages on this date. They move; re-verify anything volatile at the linked URL before relying on it.

Every finding needs evidence: the exact file:line and snippet. Map each violation to the store rule named in its row. Severity calibration: Critical = evidenced applicable upload blocker or explicit policy violation with critical submission impact; High = frequent rejection cause or policy strike risk; Medium = review friction or quality flag; Low = polish.

## Evidence boundary

Grep signals nominate checks; they do not establish the shipped configuration. Trace the
selected release variant, merged manifests, effective Info.plist, generated config/plugins,
and relevant API use. A debug-only overlay is not a release defect. A dependency name does
not prove sensitive behavior or a missing declaration. Where generated artifacts or runtime
behavior are unavailable, record the unverified part as Skip, not absence. Do not run builds,
prebuild generators, or dependency installation without authorization. Supplied artifact
excerpts carry supplied provenance; they are not a build this audit performed.

## Platform detection (run first)

| Signal | Platform | Where the audit surface lives |
|---|---|---|
| `*.xcodeproj` / `*.xcworkspace`, `Podfile`, `Info.plist` | iOS native | `<App>/Info.plist`, `*.entitlements`, `PrivacyInfo.xcprivacy`, asset catalogs |
| `settings.gradle(.kts)` + `app/build.gradle(.kts)` | Android native | `app/src/main/AndroidManifest.xml`, `app/build.gradle(.kts)`, `res/xml/` |
| `pubspec.yaml` with a `flutter:` block | Flutter | `ios/Runner/Info.plist`, `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle` |
| `package.json` depending on `react-native`, with `ios/` + `android/` | React Native | `ios/<AppName>/Info.plist`, `android/app/src/main/AndroidManifest.xml` |
| `app.json` / `app.config.(js\|ts)` with an `expo` key | Expo | config file itself (see cross-platform notes); native dirs only if prebuilt |
| `capacitor.config.(ts\|json)`, `@capacitor/core` | Capacitor | same native paths as RN |
| `build.gradle.kts` with `kotlin("multiplatform")`, `iosApp/` | Kotlin Multiplatform | `iosApp/**/Info.plist` + Android module manifest |

A project with only one platform present: mark every check for the other store ⚪ N/A with the reason ("no Android target in repo"), not silently skipped.

## iOS static checks

### Usage-description strings (Info.plist)

Missing key while the app links the gated API = hard crash on access = Guideline 2.1 rejection (and ITMS-90683 at upload for several). Present-but-vague string ("This app needs camera") = 5.1.1(ii) rejection — the string must say *why*, specifically. Check: for each API signal grepped in source/Pods, the matching key exists and its string names a concrete user-facing purpose.

| Info.plist key | Gates | Grep for API signal |
|---|---|---|
| `NSCameraUsageDescription` | Camera capture | `AVCaptureDevice`, `UIImagePickerController` (camera source) |
| `NSMicrophoneUsageDescription` | Microphone | `AVAudioRecorder`, `AVAudioSession.*record` |
| `NSPhotoLibraryUsageDescription` | Photo library read | `PHPhotoLibrary`, `PHPickerViewController` needs no key — flag over-asking |
| `NSPhotoLibraryAddUsageDescription` | Photo library write-only | `UIImageWriteToSavedPhotosAlbum`, `PHAssetChangeRequest` |
| `NSLocationWhenInUseUsageDescription` | Foreground location | `CLLocationManager`, `requestWhenInUseAuthorization` |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | Background location | `requestAlwaysAuthorization` (legacy `NSLocationAlwaysUsageDescription` alone is deprecated) |
| `NSLocationTemporaryUsageDescriptionDictionary` | One-time precise location | `CLServiceSession`, temporary full-accuracy requests |
| `NSContactsUsageDescription` | Contacts | `CNContactStore` |
| `NSCalendarsFullAccessUsageDescription` / `NSCalendarsWriteOnlyAccessUsageDescription` | Calendar (iOS 17+ split) | `EKEventStore` — legacy `NSCalendarsUsageDescription` **auto-denies** on iOS 17+ |
| `NSRemindersFullAccessUsageDescription` | Reminders (iOS 17+) | `EKEventStore` reminders entity — legacy `NSRemindersUsageDescription` auto-denies |
| `NSHealthShareUsageDescription` / `NSHealthUpdateUsageDescription` | HealthKit read / write | `HKHealthStore` |
| `NSHealthClinicalHealthRecordsShareUsageDescription` | Clinical records | `HKClinicalType` |
| `NSMotionUsageDescription` | Motion & fitness | `CMMotionActivityManager`, `CMPedometer` |
| `NSFallDetectionUsageDescription` | Fall detection | `CMFallDetectionManager` |
| `NSBluetoothAlwaysUsageDescription` | Bluetooth (iOS 13+) | `CBCentralManager`, `CBPeripheralManager` (legacy `NSBluetoothPeripheralUsageDescription` insufficient alone) |
| `NSLocalNetworkUsageDescription` (+ `NSBonjourServices`) | Local network | `NWBrowser`, Bonjour, mDNS, raw sockets to LAN |
| `NFCReaderUsageDescription` | NFC | `NFCNDEFReaderSession` |
| `NSNearbyInteractionUsageDescription` | UWB nearby interaction | `NISession` |
| `NSUserTrackingUsageDescription` | ATT / IDFA | `ATTrackingManager`, `ASIdentifierManager`, any ads/attribution SDK |
| `NSFaceIDUsageDescription` | Face ID | `LAContext` with biometrics |
| `NSSpeechRecognitionUsageDescription` | Speech recognition | `SFSpeechRecognizer` |
| `NSSiriUsageDescription` | SiriKit | `INIntent`, Intents extension |
| `NSAppleMusicUsageDescription` | Media library | `MPMediaLibrary`, `SKCloudServiceController` |
| `NSHomeKitUsageDescription` | HomeKit | `HMHomeManager` |
| `NSIdentityUsageDescription` | Wallet IDs | `PKIdentityRequest` |
| `NSSensorKitUsageDescription` | SensorKit (research) | `SRSensorReader` |
| `NSGKFriendListUsageDescription` | Game Center friends | `GKLocalPlayer.loadFriends` |
| `NSVideoSubscriberAccountUsageDescription` | TV provider | `VSAccountManager` |

Severity: missing key with API present = **Critical**. Vague/boilerplate string = **High**. Key present with no API signal anywhere = **Medium** (over-declaration invites review questions).

### Other Info.plist and build checks

| Check | Violation looks like | Store rule | Severity |
|---|---|---|---|
| `ITSAppUsesNonExemptEncryption` present | Key absent — every upload gets the export-compliance question; wrong answer risks a compliance hold. `false` is correct for HTTPS/OS-crypto only; non-exempt crypto needs `ITSEncryptionExportComplianceCode` (France additionally requires an ANSSI déclaration) | Export compliance | Medium |
| `NSAppTransportSecurity` | `NSAllowsArbitraryLoads=true` — needs written justification in review notes; scoped `NSExceptionDomains` preferred. Also flag `NSAllowsArbitraryLoadsInWebContent`/`ForMedia` used as blanket escapes | ATS / 5.1.1 data security | High |
| `UIBackgroundModes` each entry maps to a real feature | `audio` without playback code, `voip` without CallKit/PushKit, `location` without always-auth flow, `remote-notification` without push handling | 2.5.4 | High |
| `UIRequiredDeviceCapabilities` | Entries restricting devices beyond genuine need (e.g. `arm64` fine; `telephony` in an app that merely deep-links to dial) | 2.4.1 / 3.2.2(v) | Medium |
| Launch screen | No `UILaunchScreen` dict and no launch storyboard | 2.1 | Medium |
| App icon | `AppIcon` asset catalog missing the 1024×1024 marketing icon, PNG with alpha channel, or template/placeholder art | 2.1 / 2.3.8 | High |
| Embedded bitcode | `otool -l <framework binary> \| grep __LLVM` hits on any embedded framework — upload fails | Submission gate | Critical |
| Minimum SDK | Built with < Xcode 26 / iOS 26 SDK (`DTXcode`, `DTSDKName` in a built Info.plist, or CI config pinning an old Xcode) — current floor since 2026-04-28; verify at https://developer.apple.com/news/upcoming-requirements/ | Submission gate | Critical |

### Privacy manifest (PrivacyInfo.xcprivacy)

| Check | Violation looks like | Store rule | Severity |
|---|---|---|---|
| Manifest present in app target | No `PrivacyInfo.xcprivacy` anywhere while the app uses required-reason APIs or third-party SDKs | ITMS-91053 upload rejection | Critical |
| Required-reason APIs covered | API signal in source without a matching `NSPrivacyAccessedAPITypes` entry + valid reason code. Greps: `UserDefaults(` / `NSUserDefaults` → `NSPrivacyAccessedAPICategoryUserDefaults` (CA92.1 typical); `systemUptime` / `mach_absolute_time` → SystemBootTime (35F9.1); `volumeAvailableCapacity` / `statfs` → DiskSpace (E174.1 / 85F4.1); `activeInputModes` → ActiveKeyboards; `creationDate` / `modificationDate` / `stat(` / `fstat(` / `getattrlist` → FileTimestamp (C617.1 / DDA9.1) | ITMS-91053 / 91055 | Critical |
| Tracking declared | `NSPrivacyTracking=true` requires `NSPrivacyTrackingDomains`; ATT SDK present with `NSPrivacyTracking=false` is a label mismatch | 5.1.2 | High |
| SDK manifests + signatures | Dependencies on Apple's commonly-used-SDK list (Firebase*, FBSDK*, Alamofire, GoogleSignIn, SDWebImage, Lottie, RxSwift, Flutter plugins such as image_picker_ios / shared_preferences_ios / geolocator_apple, and ~80 more — list: https://developer.apple.com/support/third-party-SDK-requirements/) pinned to versions predating their privacy manifest | Upload rejection when adding/updating the SDK | High |

### Behavior ↔ implementation pairings

| If you detect… | …verify this exists | Store rule | Severity |
|---|---|---|---|
| Third-party/social login (`GIDSignIn`, `FBSDKLoginKit`, `TwitterKit`, OAuth flows to google/facebook) | `com.apple.developer.applesignin` entitlement + `ASAuthorizationAppleIDProvider` usage (or another name/email-limiting, email-hiding login service) | 4.8 | High |
| StoreKit purchases (`SKPaymentQueue`, `Product.purchase`, RevenueCat et al.) | A restore path: `restoreCompletedTransactions` / `AppStore.sync` / SDK restore call reachable from UI | 3.1.1 | High |
| Account creation (sign-up screens, `createUser`, `signUp`) | An in-app account **deletion** (not deactivation) path — grep "delete account", account-deletion routes/handlers | 5.1.1(v) | High |
| Sign in with Apple (`ASAuthorizationAppleIDProvider`, SIWA plugins) **and** an account-deletion path both present | A server-side Apple token-revocation call in the deletion flow — grep `appleid.apple.com/auth/revoke`, `revokeToken`, `auth/revoke` across backend/functions code. Both features with no revocation call = documented rejection | 5.1.1(v) | High |
| ATT prompt (`requestTrackingAuthorization`) | `NSUserTrackingUsageDescription` present; no consent-gating of features, no incentives, no fingerprinting SDKs as a fallback | 5.1.1(iv), 5.1.2(i) | High |
| Push registration | `aps-environment` entitlement; app remains usable if the user declines notifications | 4.5.4 | Medium |
| Associated domains / universal links | Each `applinks:` domain serves `https://<domain>/.well-known/apple-app-site-association` (one GET per domain) | Quality / 2.1 | Medium |

### Placeholder and completeness greps

| Grep | Store rule | Severity |
|---|---|---|
| `lorem ipsum`, `coming soon`, `placeholder`, `TODO` in user-facing strings/resources | 2.1 | High |
| `example.com`, `localhost`, `127.0.0.1`, `http://` endpoints in release configuration | 2.1 / ATS | High |
| "beta", "demo", "test" in app display name (`CFBundleDisplayName`) | 2.2 | High |
| References to Android/Google Play in UI strings or metadata files | 2.3.10 | Medium |

## Android static checks

### AndroidManifest.xml

| Check | Violation looks like | Store rule | Severity |
|---|---|---|---|
| `android:debuggable="true"` | Present in release manifest or forced in a release build type | Upload blocked outright | Critical |
| `android:usesCleartextTraffic="true"` or `network_security_config.xml` permitting cleartext | Cleartext allowed app-wide; contradicts an encryption-in-transit Data safety answer | Data safety / pre-launch report | High |
| `android:allowBackup="true"` without `android:fullBackupContent` / `android:dataExtractionRules` | Backup enabled with no exclusion rules for tokens/keys | Security flag in review | Medium |
| `android:exported="true"` components | Exported activity/service/receiver/provider with no `android:permission` and no reason to be public; deep-link activities accepting arbitrary URIs | Device & Network Abuse / security | High |
| Foreground services (targetSdk ≥ 34) | A service started with `startForeground()` lacking `android:foregroundServiceType`, or the type present without its `FOREGROUND_SERVICE_<TYPE>` permission; `specialUse` without `PROPERTY_SPECIAL_USE_FGS_SUBTYPE`. Every declared type also needs the Play Console FGS declaration + demo video (references/10-store-checklists.md) | FGS policy | Critical |
| Declaration-form permissions | Any of: `READ_SMS` / `SEND_SMS` / `RECEIVE_SMS` / `READ_CALL_LOG` / `WRITE_CALL_LOG` / `PROCESS_OUTGOING_CALLS`, `MANAGE_EXTERNAL_STORAGE`, `QUERY_ALL_PACKAGES`, `ACCESS_BACKGROUND_LOCATION`, `READ_MEDIA_IMAGES` / `READ_MEDIA_VIDEO` (broad gallery — photo picker required for one-time use since 2025), `BIND_ACCESSIBILITY_SERVICE` (non-accessibility use), `USE_EXACT_ALARM`, `REQUEST_INSTALL_PACKAGES`, `SYSTEM_ALERT_WINDOW`, `READ_CONTACTS` (Contacts Permissions policy announced 2026-04-15, enforcement begins 2026-10-28 for apps targeting API 37+ — contact picker preferred; see references/07-play-data-safety.md). Each present without matching core functionality = a Play Console declaration the user must be able to defend | Permissions policy | High (Critical if clearly unjustified) |
| `com.google.android.gms.permission.AD_ID` | Ads/analytics SDK in the dependency graph, targetSdk ≥ 33, permission absent (ad ID reads as zeros) — or the permission **present** in a Families-targeted app (forbidden) | Advertising ID / Families | High |
| `USE_FULL_SCREEN_INTENT` | Present in a non-alarm, non-call app | FSI declaration | Medium |
| App links | `android.intent.action.VIEW` intent-filter with `android:autoVerify="true"` whose host does not serve `https://<host>/.well-known/assetlinks.json` (one GET per host) | Quality | Medium |

### build.gradle / build.gradle.kts

| Check | Violation looks like | Store rule | Severity |
|---|---|---|---|
| `targetSdk` | < 36. Since 2026-08-31, new apps and updates must target Android 16 (API 36); an extension to 2026-11-01 is available via the Play Console Policy Status page. Existing apps that are not being updated are grandfathered at API 35. Verify at https://support.google.com/googleplay/android-developer/answer/11926878 | Target API policy | Critical |
| 64-bit | `abiFilters` / `ndk` block including `armeabi-v7a` without `arm64-v8a`, or `jniLibs` shipping 32-bit-only `.so` files | 64-bit requirement | Critical |
| Release optimization | Disabled minification alone is not a store-policy defect. Investigate measured size or crash failures against the applicable rule; enabling shrinking can itself require keep rules | Quality, only with an evidenced failure | Calibrate to actual impact |
| Keystore hygiene | `*.jks` / `*.keystore` committed to the repo, or signing passwords in `gradle.properties` under version control | Security (also report via snitch-security) | Critical |
| Publishing format | Config producing only APKs — new apps must ship AAB with Play App Signing | AAB requirement | High |
| `versionCode` | Not monotonic, or per-ABI schemes that can collide | Upload gate | Medium |

### Behavior red flags (source-level)

| Check | Violation looks like | Store rule | Severity |
|---|---|---|---|
| Dynamic code loading | `DexClassLoader` / `PathClassLoader` / `System.load` on files fetched from the network | Device & Network Abuse | Critical |
| Self-update | Code that downloads and prompts installation of an APK outside Play | Device & Network Abuse | Critical |
| WebView-wrapper pattern | Check website-owner authorization, affiliate purpose, and actual utility. A WebView call alone is not evidence of spam or inadequate functionality | Spam & minimum functionality | High |
| Backup/data-extraction rules | `backup_rules.xml` / `data_extraction_rules.xml` absent or not excluding auth tokens, or referenced file missing | Security | Medium |
| Account creation detected | No in-app delete-account path (and remind the user of the required web deletion link — console side) | Account deletion policy | High |
| Placeholder greps | Same list as iOS (lorem ipsum, example.com, localhost, `http://` release endpoints); plus test ad unit IDs (`ca-app-pub-3940256099942544`) in release config | Min functionality / Ads | High |

## Cross-platform notes

| Framework | Where to audit | Gotchas |
|---|---|---|
| Flutter | `ios/Runner/Info.plist`, `ios/Runner/Runner.entitlements`, `android/app/src/main/AndroidManifest.xml`, `android/app/build.gradle`; dependencies in `pubspec.yaml`/`pubspec.lock` | Many flutter plugins are on Apple's SDK-manifest list — outdated plugin versions block upload. Permission plugins (`permission_handler`) require you to add the Info.plist keys yourself; the plugin's presence is the API signal. |
| React Native | `ios/<AppName>/Info.plist`, `android/app/src/main/AndroidManifest.xml`; `package.json` for SDK signals (`react-native-fbsdk-next`, `@react-native-google-signin`, ads/attribution SDKs) | Autolinked native modules can pull declaration-form permissions into the merged manifest — check the merged output, not just the app manifest, when a permission finding seems unexplained. hermes and several RN deps carry their own privacy manifests; pin current versions. |
| Expo (managed) | `app.json` / `app.config.*`: `ios.infoPlist` (usage strings), `ios.entitlements`, `android.permissions`, `android.blockedPermissions`, plugin entries | No native dirs until prebuild — audit the config, not `ios/`/`android/`. Config plugins inject permissions silently; `android.permissions` omission does NOT strip what libraries add — use `blockedPermissions`. Privacy manifests are aggregated from SDKs at build; `expo prebuild` output is the ground truth when present. |
| Capacitor / KMP | Same native paths as RN (`iosApp/` for KMP) | Capacitor plugins add manifest entries on `npx cap sync`; audit the synced native projects. |

Cross-store constant: one codebase, two rulebooks. A `READ_CONTACTS` finding on Android usually has an `NSContactsUsageDescription` twin on iOS — check both sides before reporting either as done.
