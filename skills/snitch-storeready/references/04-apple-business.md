# Apple business rules, regional compliance, and the release process

When to read this: auditing monetization (IAP/subscriptions/external purchases), export compliance, EU obligations, or planning TestFlight and the release itself.

## 3.1.1 In-App Purchase — the core rule

Digital goods and services consumed in the app must use IAP. Physical goods and services (3.1.3(e)) must NOT use IAP — take Apple Pay or cards. Specific tripwires:

- A restore-purchases mechanism is mandatory for non-consumables and subscriptions. Static check: StoreKit purchase code (`SKPaymentQueue`, StoreKit 2 `Product.purchase`) without a restore path — see references/09-static-checks.md.
- No unlocking via license keys, QR codes, or cryptocurrency.
- Purchased credits cannot expire.
- Loot boxes must disclose odds before purchase.
- Free trials for non-subscription apps: a Tier-0 non-consumable named "XX-day Trial".

## 3.1.2 Subscriptions

Ongoing value, minimum 7-day period, functional across the user's devices. Price and term must be clearly disclosed before purchase, with renewal terms per the 4.9 disclosure style. Upgrades/downgrades must be seamless. Bait-and-switch subscription flows get removed, not just rejected.

## 3.1.3 Exceptions

Reader apps (magazines, news, books, audio, music, video) may let users access previously-purchased content without IAP, with the External Link Account entitlement for account-management links. Multiplatform apps may unlock content bought elsewhere as long as IAP is also offered where required. Person-to-person services, enterprise plans, and free companion apps have their own carve-outs — read the live 3.1.3 text before relying on one.

## External purchase links — regional state (volatile, hedge everything)

- **US storefront**: since May 2025 (court contempt order), apps may include buttons, links, and calls to action to outside purchase methods with no entitlement and, per the order, no commission on those external purchases. The order is under appeal; current as of 2026-08 — verify at https://developer.apple.com/app-store/review/guidelines/#business before advising a client to remove IAP.
- **EU (DMA)**: alternative app marketplaces, Web Distribution, alternative browser engines (2.5.6 entitlement, also Japan), and alternative payments are available. The June 2025 terms use a single communication-and-promotion entitlement with tiered fees (initial acquisition fee, Store Services Tier 1/Tier 2, Core Technology Commission); the Core Technology Fee to Core Technology Commission transition was announced for January 2026 but was not finalized as of mid-2026. Treat every EU fee number as volatile — verify at https://developer.apple.com/support/dma-and-apps-in-the-eu/.
- **Everywhere else**: external purchase links remain prohibited outside entitlement programs (reader apps; music streaming in specific regions).
- Standard commission elsewhere: 30%, or 15% for the Small Business Program and year-two subscriptions (current as of 2026-08 — verify in App Store Connect).

## Export compliance / encryption

Every build answers the encryption question. Set `ITSAppUsesNonExemptEncryption` in Info.plist: `false` when you only use exempt encryption (HTTPS, OS-provided crypto) — this skips the per-build question at upload; `true` requires compliance docs and then `ITSEncryptionExportComplianceCode`. France additionally requires an ANSSI declaration for encryption apps on the French storefront. Source: https://developer.apple.com/help/app-store-connect/reference/export-compliance-documentation-for-encryption/. Static check: `ITSAppUsesNonExemptEncryption` present in Info.plist — see references/09-static-checks.md.

## EU Digital Services Act — trader declaration

Mandatory since February 17, 2025: every developer declares trader or non-trader status in App Store Connect. Traders must provide a verified address, phone, and email, published on the EU product page. No declaration means removal from all 27 EU storefronts and blocked submissions. Source: https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/.

Also keep content-rights documentation (trademarks, streaming rights, third-party content licenses) available — App Review can request it (5.2.1).

## TestFlight vs App Review

- Internal testers (≤100 App Store Connect users): no review.
- External testers (≤10,000): Beta App Review — a lighter subset (app launches, no crashes, privacy strings present, no core-policy violations). First build of each version is reviewed (roughly 4–48 hours); later builds of the same version usually clear in minutes unless entitlements or metadata changed.
- Passing Beta App Review is not evidence the app will pass store review. Builds expire after 90 days; IAP runs against the sandbox.

## Review timing, rejection response, release mechanics

- 90% of submissions are reviewed within 24 hours (Apple's published figure; current as of 2026-08 — verify at https://developer.apple.com/distribute/app-review/). Plan two to three review cycles for a first submission.
- Expedited review: request at https://developer.apple.com/contact/app-store/?topic=expedite for a critical bug fix (include reproduction steps) or a dated event. Use sparingly.
- Rejection response: reply in App Store Connect messages (humans answer); resubmit with fixes plus an explanation in Review Notes. If you believe a guideline was misapplied, file an appeal (one per rejected submission) at https://developer.apple.com/contact/app-store/?topic=appeal. Thirty-minute consultations with App Review are bookable.
- Phased release: automatic-update rollout over 7 days — 1%, 2%, 5%, 10%, 20%, 50%, 100%. Pausable up to 30 days with unlimited pauses; users updating manually always get the new version. Source: https://developer.apple.com/help/app-store-connect/update-your-app/release-a-version-update-in-phases.

For the pre-submission walkthrough of the items App Store Connect gates (trader status, privacy labels, age rating, demo account), use references/10-store-checklists.md.
