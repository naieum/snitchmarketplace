# Google Play policy and rejection hotspots

When to read this: auditing an Android app against Play Developer Program Policies, or triaging a Play rejection/removal notice.

**Facts verified: 2026-09-01.** Dates, fees, quotas, and thresholds below were checked against the cited official pages on this date. They move; re-verify anything volatile at the linked URL before relying on it.

Canonical source: https://play.google/developer-content-policy/ (the Policy Center). Play Help answer-page IDs churn with every policy refresh, so cite the Policy Center root and category names, not answer URLs.

## Policy taxonomy

| Category | Covers |
|---|---|
| Restricted Content | child endangerment, inappropriate content, age-restricted features, financial services (loan APR caps), real-money gambling, illegal activities, UGC, health, blockchain, AI-generated content |
| Impersonation and IP | unauthorized trademarks, branding, copyrighted assets — "modified" copies still violate |
| Privacy, Deception, Device Abuse | user data, permissions, device/network abuse, deceptive behavior, misrepresentation, target API level |
| SDK Requirements | you are liable for every bundled SDK's behavior |
| Monetization and Ads | payments, subscriptions, ads, Families ads SDK certification |
| Store Listing and Promotion | metadata rules, promotion, ratings/reviews/installs integrity, content ratings, news |
| Spam, Functionality, UX | webview spam, clones, made-for-ads apps, minimum functionality |
| Malware and Mobile Unwanted Software | ad fraud, social engineering, hostile downloaders |
| Families | everything child-directed |
| Enforcement | strikes, appeals, Play Console requirements |

## Rejection hotspots

### 1. Data safety / permission mismatches (the most common cause)

Trigger: the Data safety form does not match what the app (or any bundled SDK) actually transmits, or a restricted permission lacks its Play Console declaration form. Google cross-references your declarations against observed APK and network behavior.

Check: list every SDK in the dependency graph and every `uses-permission` entry; compare against the Data safety form and the declaration-form table in references/07-play-data-safety.md.
Fix: declare everything SDKs collect, remove permissions you cannot justify, complete every declaration form before release.
Static check: `uses-permission` entries in AndroidManifest.xml against the restricted-permission table; ads/analytics artifacts in build.gradle.

### 2. Broken or invalid privacy policy link

Trigger: the store-listing privacy policy URL is dead, geofenced, a broken PDF, or does not name the app/entity and describe collection, use, sharing, retention, deletion, and contact info. Required for every app, even ones that collect nothing.
Check: fetch the URL; confirm it resolves publicly and covers the required points; confirm the app also links it in-app.
Fix: host a plain, public HTML policy; link it in Play Console (App content) and inside the app.

### 3. Metadata policy violations

Trigger, in title / icon / developer name: emoji or emoticons, repeated special characters, ALL CAPS (unless the brand is capitalized), ranking or performance claims ("#1", "best", "top"), price and promo terms ("free", "sale", "no ads"), calls to action ("download now"). In descriptions: keyword stuffing, unattributed testimonials.
Limits: title ≤30 characters, short description ≤80, full description ≤4000.
Check: read the drafted listing text against the banned-token list.
Fix: plain descriptive title, move promotional language out of the title entirely.

### 4. Spam and minimum functionality

Trigger: crash on launch, broken core features, or an app below the quality bar (stable, responsive, engaging — enforced since 2024-08-31). Webview wrappers whose primary purpose is driving traffic to a site are "webview spam". Repetitive clones and made-for-ads apps fall here too.
Check: does the app do anything a mobile site cannot? Does it launch clean on a real device?
Fix: add native capability (offline, notifications, device APIs) or do not submit a wrapper.
Static check: single-Activity + WebView + `loadUrl` of a remote site with no native features is the wrapper signature (see references/09-static-checks.md).

### 5. Payments policy

Trigger: selling digital goods or services consumed in the app outside Google Play Billing where it is still required (regional carve-outs exist — see references/08-play-account-release.md), or using Play Billing for physical goods (also a violation).
Check: classify every purchasable as digital-in-app vs physical/external, then map to the allowed billing path for the target countries.

### 6. Impersonation and IP

Trigger: another party's name, icon style, characters, or media in the app or listing without written authorization. Google removes first and asks later.
Fix: keep license documentation ready; strip unlicensed assets before submission.

### 7. User-generated content

Trigger: UGC features without in-app reporting, blocking of abusive users, and active moderation.
Static check: presence of report/block flows near any user-content surface.

### 8. AI-generated content

Trigger: apps generating AI content without an in-app way to report offensive output.
Fix: add a report control inside the generation surface, not buried in settings.

### 9. Device and network abuse

Trigger: downloading or executing code not shipped in the reviewed artifact (dynamic DEX or native loading from external sources), or self-updating outside Play's update mechanism (hostile-downloader class). Android 16 additionally requires dynamically loaded files to be read-only.
Static check: `DexClassLoader`/`System.load` fed from downloaded paths; APK-download-and-install flows (see references/09-static-checks.md).

## Enforcement reality

Violations escalate: rejection → removal → suspension (a strike) → account termination, which extends to associated accounts (shared payment or identity signals). Details and the Strike Removal path are in references/08-play-account-release.md.
