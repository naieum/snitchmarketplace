# Apple App Store Review Guidelines — rejection taxonomy

When to read this: auditing an iOS/iPadOS/macOS/visionOS app for review-guideline compliance, or triaging an Apple rejection notice by guideline number.

**Facts verified: 2026-09-01.** Dates, fees, quotas, and thresholds below were checked against the cited official pages on this date. They move; re-verify anything volatile at the linked URL before relying on it.

Canonical source: https://developer.apple.com/app-store/review/guidelines/ (updated several times a year; major revisions landed Nov 2025 and June 2026 — verify the live text before citing a clause verbatim).

## The five sections

| Section | Covers | Highest-traffic clauses |
|---|---|---|
| 1. Safety | Objectionable content, UGC, kids, physical harm, developer info | 1.2 UGC moderation, 1.3 Kids Category, 1.5 support contact |
| 2. Performance | Completeness, beta, metadata accuracy, hardware, software requirements | 2.1, 2.3.x, 2.5.x |
| 3. Business | IAP, subscriptions, other purchase methods, crypto, acceptable models | 3.1.1, 3.1.2, 3.1.3 |
| 4. Design | Copycats, minimum functionality, spam, extensions, login services | 4.2, 4.3, 4.8 |
| 5. Legal | Privacy, IP, gambling, VPN/MDM | 5.1.1, 5.1.2, 5.2.1 |

Commonly reported: roughly a quarter of all submissions are rejected, and more than 40% of unresolved review issues trace to Guideline 2.1 alone (verify at https://developer.apple.com/distribute/app-review/).

## Rejection hotspots

### 2.1 App Completeness — the single biggest rejection cause

Triggers: crashes or obvious bugs during review; placeholder text or images ("lorem ipsum", "coming soon", template icons); broken support or privacy-policy URLs; login-gated features with no demo account; backend not live during review; IAPs referenced but not submitted or not reviewable; "beta"/"demo"/"test" labeling (that is 2.2).

Check before submitting:
- Run the final build on a physical device on the current OS; exercise every screen.
- HTTP-fetch every URL in your App Store Connect metadata (support, privacy policy, marketing). All must return real content.
- Confirm the demo account credentials in App Review Information work against the production backend, and that any server-side feature flags are enabled for that account.
- Static check: grep the project for placeholder strings (`lorem ipsum`, `TODO`, `example.com`, `localhost`, `127.0.0.1`, `http://` endpoints in release config) — see references/09-static-checks.md.

Fix: complete the feature or cut it from the build; supply working credentials or an approved demo mode; explain any reviewer-invisible IAP or hardware dependency in the Notes field.

### 2.3 Accurate Metadata

The clauses that actually fire:
- 2.3.1 — no hidden, dormant, or undocumented features; the app must do only what the metadata says.
- 2.3.3 — screenshots must show the app in use, not splash screens, login walls, or marketing art.
- 2.3.7 — app name ≤30 characters; no prices, terms, or platform names in name or metadata.
- 2.3.8 — icons and screenshots must be suitable for a 4+ audience even if the app is rated higher.
- 2.3.10 — no references to other platforms or alternative marketplaces in metadata (screenshots showing Android UI are a classic trigger).
- 2.3.12 — What's New must accurately describe the update.

Fix: audit metadata against the running app before every submission; treat screenshots as evidence, not advertising. Details in references/03-apple-metadata-assets.md.

### 4.2 Minimum Functionality

Triggers: web wrappers with no native capability beyond a WKWebView; marketing brochures or content aggregators; apps a mobile website already fully replaces; template apps submitted by the templating service instead of the content owner (4.2.6).

Check: ask "what does this app do that Safari cannot?" If the honest answer is nothing, expect rejection. Static check: a single view controller hosting a WKWebView that loads one remote URL is the signature pattern — see references/09-static-checks.md.

Fix: add native, offline, or device-integrated functionality (push done right, widgets, camera, native navigation), or ship as a web app instead.

### 4.3 Spam — tightened June 9, 2026

4.3(b) now reads against apps "indistinguishable from what's already widely available": opportunistic variants of popular apps or saturated categories (dating, flashlight, wallpaper, timers, fortune telling, thin AI wrappers). The June 2026 revision responded to a flood of low-effort AI-generated submissions; repeat offenders risk Developer Program removal (verify at https://developer.apple.com/app-store/review/guidelines/#spam).

Check: if the app enters a crowded category, document the meaningfully different experience in the Review Notes; do not submit near-identical binaries under multiple accounts or names.

### 4.8 Login Services

Trigger: the app offers any third-party or social login (Google, Facebook, X, WeChat, ...) without also offering a login service that limits data collection to name and email, lets users hide their email, and does not collect interactions for advertising. Sign in with Apple satisfies this.

Exempt: apps using only their own account system; education/enterprise apps; government/industry eID; clients for one specific third-party service.

Static check: `GIDSignIn` / `FBSDKLoginKit` present without `ASAuthorizationAppleIDProvider` or the Sign in with Apple entitlement — see references/09-static-checks.md.

If the app also supports account deletion, Sign in with Apple brings a second obligation — token revocation on delete. See 5.1.1(v) below.

### 5.1.1 Privacy — collection and storage

- 5.1.1(i) — a working privacy policy link in App Store Connect and inside the app, covering what is collected, how it is used, third-party access, retention, and deletion.
- 5.1.1(ii) — permission purpose strings must be specific. "This app needs your location" gets rejected; "Shows pharmacies near you" passes. Every `NS*UsageDescription` you ship is read by a human.
- 5.1.1(iv) — permission requests cannot be a condition of unrelated functionality; no consent-gating or bribing.
- 5.1.1(v) — **account deletion**: any app that supports account creation must offer in-app account deletion (real deletion, not deactivation), working during review, with no forced phone call. Heavily enforced since mid-2022.
- 5.1.1(v) corollary — **Sign in with Apple token revocation**: an app that offers Sign in with Apple must revoke the user's tokens through the Sign in with Apple REST API when the account is deleted. Deleting the server-side rows without calling the revocation endpoint is a documented rejection, and it is commonly missed because the deletion flow "works" without it — https://developer.apple.com/support/offering-account-deletion-in-your-app

Static check: sign-up flow detected without a delete-account code path; Sign in with Apple plus a deletion path with no token-revocation call in the backend; vague or missing usage-description strings — see references/09-static-checks.md.

### 5.1.2(i) Sharing with third-party AI — added Nov 2025

Apps must obtain explicit user consent and disclose before sharing personal data with third-party AI services. If the app sends user content, identifiers, or profile data to an external model API, ship a consent step and disclose it in the privacy label (verify the live 5.1.2 text).

### 1.2 User-Generated Content

Any app with UGC must ship all four: a filter for objectionable material, a report mechanism with timely follow-up, the ability to block abusive users, and published contact info. 1.2.1 adds age-restriction mechanisms for creator-content platforms. Missing any one is a rejection.

### 1.3 / 5.1.4 Kids

Kids Category apps: no third-party analytics or advertising (narrow, contractually-bound exceptions), no external links or purchase prompts outside a parental gate, and a parental gate is not consent for data collection. Do not use "for kids" or "for children" in the name of an app outside the Kids Category. ATT-style tracking of children is prohibited outright.

### Other clauses worth scanning for

- 1.4 Physical harm: medical calculations must cite sources; drug-dosage apps restricted to verified entities; no DUI-checkpoint content.
- 1.5: a working support contact is mandatory.
- 5.2.1/5.2.3: third-party content and media downloading need documented authorization — keep licenses ready to show App Review.
- 5.3.4: real-money gaming needs licensing for every enabled region, geo-restriction, and a free download.
- 3.2.2(ix): personal-loan apps — max 36% APR, no full repayment demanded in 60 days or less.
- 4.5.3 (June 2026): Live Activities must not carry spam, phishing, or unsolicited messages.

## Using this file in an audit

Map each finding to a guideline number in the Evidence line. When triaging a rejection notice, jump to the matching hotspot above, then to references/10-store-checklists.md for the resubmission playbook.
