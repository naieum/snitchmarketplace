# Google Play technical requirements

When to read this: verifying an Android project's build configuration, packaging, and runtime quality against Play's hard technical gates.

**Facts verified: 2026-09-01.** Dates, fees, quotas, and thresholds below were checked against the cited official pages on this date. They move; re-verify anything volatile at the linked URL before relying on it.

## Target API level

Deadlines run on a yearly cadence: every August 31, new apps and updates must target the previous year's Android release. Current cycle (verify at https://support.google.com/googleplay/android-developer/answer/11926878):

| App class | Requirement |
|---|---|
| New apps and updates, since 2026-08-31 | target Android 16 (API 36); extension to 2026-11-01 available via the Play Console Policy Status page |
| Wear OS / Android Automotive, since 2026-08-31 | API 35 |
| Android TV / Android XR, since 2026-08-31 | API 34 |
| Existing apps (not updated) | must target at least API 35 or they stop surfacing to new users on devices running newer Android; existing installs keep working |

A release targeting a lower API than the floor is rejected at upload.
Static check: `targetSdk` (and lagging `compileSdk`) in build.gradle / build.gradle.kts.

## Packaging

- **Android App Bundle**: new apps must publish as .aab (since 2021-08). AAB requires enrollment in **Play App Signing** — Google holds the app signing key, you keep an upload key. A lost upload key can be reset in Play Console; a leaked keystore in the repo is a finding regardless.
- **64-bit**: any release with native code serving Android 9+ must ship `arm64-v8a` (and `x86_64` where x86 is shipped) alongside any 32-bit libs. Source: https://developer.android.com/google/play/requirements/64-bit.
  Static check: every `lib/armeabi-v7a/*.so` has an `arm64-v8a` counterpart; `abiFilters`/`ndk` block in build.gradle.
- **Size**: compressed download ≤200 MB for AABs (100 MB for legacy APK apps). Beyond that, use Play Asset Delivery (install-time, fast-follow, on-demand packs) or Play Feature Delivery. OBB expansion files are legacy. Source: https://support.google.com/googleplay/android-developer/answer/9859372.

## Android Vitals bad-behavior thresholds

Exceeding these reduces discoverability; exceeding the per-device thresholds can additionally put a warning on your store listing on affected devices. Verify current figures at https://developer.android.com/topic/performance/vitals:

| Metric | Overall threshold | Per-device-model threshold |
|---|---|---|
| User-perceived crash rate | 1.09% of DAU | 8% |
| User-perceived ANR rate | 0.47% of DAU | 8% |

Also tracked: excessive wakeups, stuck wake locks, cold start over 5 s, excessive background battery drain. Vitals problems do not block review, but they throttle growth after launch and matter when Play evaluates a staged rollout (references/08-play-account-release.md).

## Pre-launch report

Publishing to any testing track triggers a free automatic run on real Android 9+ devices (Firebase Test Lab crawler). It reports:

- stability (crashes) and performance (startup time, frame rate)
- accessibility issues
- security flags: known-vulnerable SDK versions, cleartext traffic, JavaScript-interface issues
- display/screenshot problems per device
- private (non-SDK) API usage

Supply test credentials or an Espresso script in Play Console so the crawler gets past login. Treat pre-launch report failures as review blockers: the same signals feed human review. Source: https://support.google.com/googleplay/android-developer/answer/9842757.

## Upload blockers worth knowing

- `android:debuggable="true"` in a release artifact is refused at upload.
  Static check: `android:debuggable` in AndroidManifest.xml and `debuggable` in release build type.
- Non-monotonic `versionCode`, or versionCode collisions across ABI splits.
  Static check: `versionCode` scheme in build.gradle.
- Missing R8/ProGuard is not a blocker but inflates size and ships symbol names; reflection-heavy SDKs without keep rules crash in release and feed the Vitals crash rate.
  Static check: `minifyEnabled` and presence of proguard-rules.pro.

Deep grep-level detail for all of these lives in references/09-static-checks.md.
