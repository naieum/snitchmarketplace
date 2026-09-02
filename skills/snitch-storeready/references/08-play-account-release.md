# Google Play account, listing, billing, and release management

When to read this: planning the path from a finished build to production on Play — account gates, listing assets, billing rules, testing tracks, and enforcement risk.

**Facts verified: 2026-09-01.** Dates, fees, quotas, and thresholds below were checked against the cited official pages on this date. They move; re-verify anything volatile at the linked URL before relying on it.

## New-account gates

- **Closed-testing requirement**: personal developer accounts created after 2023-11-13 must run a closed test with at least 12 testers opted in continuously for at least 14 days before applying for production access. A tester who opts out and rejoins restarts that tester's clock. Then a three-part production-access application (closed-test details, app info, readiness) — review typically within 7 days. Organization accounts are exempt. Bot or emulator testers violate policy; Google evaluates engagement quality. Verify current figures at https://support.google.com/googleplay/android-developer/answer/14151465.
- **Developer verification**: personal accounts verify government ID, address, phone, email. Organizations need a D-U-N-S number, registration documents, and an authorized rep's ID. Public display: legal name and email for everyone; developers with paid apps or purchases show a verified legal address and phone on every listing. Government apps must be Organization accounts.
- One-time $25 registration fee for new accounts.

## Store listing text and assets

| Field / asset | Spec |
|---|---|
| Title | ≤30 chars; metadata policy applies (references/05-play-policy.md) |
| Short description | ≤80 chars |
| Full description | ≤4000 chars |
| Icon | 512×512, 32-bit PNG with alpha, ≤1 MB; Play applies its own masking |
| Feature graphic | 1024×500 JPEG/24-bit PNG; required to publish |
| Screenshots | 2–8 per device class (phone, 7" tablet, 10" tablet, Chromebook, Wear, TV); ≤8 MB each, sides 320–3840 px, aspect ≤2:1; for promotion eligibility: ≥4 phone screenshots at ≥1080 px, 16:9 or 9:16 |
| Video | public or unlisted YouTube URL only; not age-restricted; embeddable |

Screenshots must show the real in-app experience; misleading imagery is a metadata violation. Store listing experiments (up to 5 concurrent, 3 variants + control) and up to 50 custom store listings exist once you are live.

## Billing

- Baseline: digital goods and services consumed in the app go through Google Play Billing. Physical goods, physical services, and peer-to-peer payments must NOT use Play Billing.
- **US storefront**: following the Epic v. Google litigation, Google published new US policies on 2025-12-09 letting developers link out to external purchase or download sites, use non-Play billing in-app, and communicate external pricing. The parties reached a further settlement in March 2026 and asked the court to enter a revised injunction, so treat the exact terms as still moving. Verify current terms at https://support.google.com/googleplay/android-developer/answer/15582165.
- **User-choice billing** operates in 35+ countries with a fee reduction on alternative-billing transactions; you take on payment processing, PCI-DSS, refunds, and monthly reporting.
- Settlement-driven fee restructures are pending court approval — treat every specific commission percentage as volatile and verify current terms in Play Console.

## Subscriptions

Disclose price, billing period, trial/intro terms, and the post-trial price before purchase. Provide an easy in-app path to manage and cancel; cancellation must not require contacting support. No misleading SKU names (an SKU named "Free Trial" that auto-charges is a violation).

## Testing tracks and rollout

1. **Internal testing** — up to 100 testers, near-instant availability, exempt from managed publishing.
2. **Closed testing** — email lists or Google Groups; where the 12-tester gate runs.
3. **Open testing** — anyone can join; listed on Play.
4. **Production** — every release is reviewed.

Release practices:

- **Staged rollout**: production updates roll to a percentage (a common ladder is 1 → 5 → 10 → 20 → 50 → 100). Halt on bad Vitals (thresholds in references/06-play-technical.md); resume by continuing percentages or shipping a fixed release.
- **Managed publishing**: review completes first, you pick the go-live moment. Use it for coordinated launches.
- **Release notes**: per-locale `<xx-XX>` tags, 500 chars per language.
- **Pre-registration** campaigns can run up to 90 days before launch.
- **In-app updates API** (flexible or immediate flow) is the sanctioned way to push users forward — never self-update via downloaded APKs (references/05-play-policy.md).
- Country availability is set per track; keep it consistent with your listing languages.

## Review timing

No SLA. Established accounts commonly see 1–3 days; plan for at least 7. Sensitive categories (finance, health, kids, VPN, dating, AI chat) and December run longer. New personal accounts stack the production-access review on top. Timings commonly reported and volatile — verify current SLAs in Play Console.

## Strikes and termination

Violations escalate from rejection to removal to suspension; suspensions are strikes. Repeated or serious violations terminate the account, and termination extends to associated accounts (shared payment or identity signals). To stay clear:

- keep declared behavior identical to actual behavior; re-answer App content declarations before every release;
- never buy installs or reviews;
- keep contact and support info current, and respond to policy emails within the stated window (usually 30 days);
- an eligible strike can be waived once via the Strike Removal program (Play Academy course plus assessment);
- never create a second account after termination — evasion makes it permanent.

Appeals run through the Policy Status page in Play Console.
