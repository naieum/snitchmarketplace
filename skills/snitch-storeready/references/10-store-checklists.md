# Store-console checklists — what code cannot prove

When to read this: the static audit (references/09-static-checks.md) is done and you are walking the user through the App Store Connect / Play Console items that only they can verify. Ask each question, record the answer as 🟢 OK / 🔴 FAIL / 🟡 WARN / ⚪ N/A, and fold the results into the same report — these items cause more first-submission rejections than code does.

**Facts verified: 2026-09-01.** Dates, fees, quotas, and thresholds below were checked against the cited official pages on this date. They move; re-verify anything volatile at the linked URL before relying on it.

Ask in order; skip N/A rows aloud ("no accounts in this app, so account-deletion items are N/A"). Where the user is unsure, treat as WARN with the verification step as the remediation. Policy details behind each item: references/01-apple-review-guidelines.md through references/08-play-account-release.md.

## App Store Connect checklist

| # | Item | Ask the user | Rejection it prevents | Done when |
|---|---|---|---|---|
| A1 | Demo account + review notes | "Does any feature sit behind login, region, or hardware? Have you supplied a working demo account and reviewer notes?" | 2.1 — the single largest rejection bucket; reviewers reject what they cannot reach | Credentials tested from a clean device the day of submission; notes cover special setup, region locks, hardware pairing videos |
| A2 | Support / privacy / marketing URLs | "Do all three URLs load real content right now?" | 2.1 broken links; 5.1.1(i) missing policy | Each URL returns a live page; the privacy policy names the app, covers collection/use/retention/deletion, and matches the nutrition labels |
| A3 | Privacy nutrition labels | "Do the App Privacy answers match what the app and every SDK actually collect — including IP address and crash/analytics data?" | 5.1 label-vs-behavior mismatch | Labels reconciled against the static audit's SDK inventory and PrivacyInfo.xcprivacy; third-party SDK collection declared even for SDK features you don't use |
| A4 | Age rating questionnaire | "Have you answered the expanded questionnaire (tiers 4+/9+/13+/16+/18+)?" | Updates are blocked if unanswered (since 2026-01-31); 2.3.6 for dishonest answers | Questionnaire complete and honest; 18+ apps have regional age-verification where mandated |
| A5 | Screenshots & previews | "Are screenshots current-spec (6.9\" iPhone, 13\" iPad required classes) and do they show the real app in use?" | 2.3.3 / 2.3.7 metadata rejections | 1–10 per class, correct dimensions, no other-platform UI, no undisclosed IAP content, no price claims |
| A6 | In-app purchases submitted | "Are all IAPs attached to this version, reviewable, and explained if not obvious?" | 2.1 incomplete IAP; 3.1.1 | Every IAP is in 'Ready to Submit' with the binary; restore purchases works |
| A7 | Export compliance | "Is the encryption question answered — `ITSAppUsesNonExemptEncryption` set, or docs on file for non-exempt crypto?" | Compliance hold at upload | Key set in Info.plist (static check confirms) or compliance code entered; France ANSSI filed if applicable |
| A8 | EU DSA trader status | "Have you declared trader or non-trader status, with verified contact details if trader?" | Removal from all 27 EU storefronts (mandatory since 2025-02) | Declaration complete; traders show verified address/phone/email on the EU product page |
| A9 | TestFlight caveat | "Are you treating Beta App Review approval as store approval?" | Surprise production rejection | User understands external-TestFlight review is a lighter subset; production review re-checks everything |
| A10 | Rollout plan | "Phased release or all-at-once? Expedite request only if genuinely critical?" | — (process hygiene) | Deliberate choice made; phased release ladder (1→2→5→10→20→50→100% over 7 days) understood as automatic-updates-only |

## Play Console checklist

| # | Item | Ask the user | Rejection it prevents | Done when |
|---|---|---|---|---|
| P1 | Data safety form | "Does every Data safety answer match actual app + SDK behavior — collection, sharing, encryption in transit, deletion?" | The #1 Play rejection/removal cause; Google cross-references observed behavior | Form reconciled against the static audit's permission/SDK inventory; SDK data-safety pages consulted for each dependency |
| P2 | Privacy policy | "Is the policy URL set in Play Console AND linked inside the app, live, non-geofenced, and does it name this app?" | User Data policy rejection (broken policy link is routine) | Both placements verified; policy covers collection/use/sharing/retention/deletion + contact info |
| P3 | Account deletion web link | "If users can create accounts: is there an in-app deletion path AND a web link (in the Data deletion section) usable without reinstalling?" | Account deletion policy | Both paths tested; deletion actually removes data, retained data disclosed |
| P4 | App content declarations | "Are all App content forms complete — foreground services (with demo video), health, ads, news (deadline 2026-05-27 for in-scope apps), government, financial features?" | Update rejection on any missing declaration | Every FGS type found in the static audit has a Console declaration + video showing user-initiated use; health declaration answered even if 'no health features' |
| P5 | Sensitive-permission declarations | "For each declaration-form permission the static audit found — is the Console form filed and defensible as core functionality?" | Permissions policy rejection/removal | Each permission has an approved (or drafted, defensible) declaration; alternatives (photo picker, contact picker, SAF) considered and ruled out in writing |
| P6 | Advertising ID declaration | "Does the ad ID declaration match reality — including SDKs that touch it? Families-targeted: confirmed no ad ID transmission?" | Advertising ID / Families enforcement | Declaration matches the AD_ID static finding; Families apps use self-certified ads SDKs only |
| P7 | Content rating (IARC) | "Questionnaire answered, including for the ads shown in-app?" | Unrated apps are removed; misrating = enforcement | Rating issued; re-submitted after any content change |
| P8 | Target audience declaration | "Which age groups did you declare? If any child group: are you meeting Families policy (certified ads SDKs, neutral age screen for mixed audiences)?" | Families policy enforcement | TAD matches the real audience; no accidental child-appeal in listing assets |
| P9 | Store listing assets | "Title ≤30 chars with no emoji/ALL CAPS/'#1'/'free'/CTAs; short description ≤80; icon 512×512; feature graphic 1024×500; 2–8 screenshots per device class (≥4 phone at 1080px+ for featuring); video is a public/unlisted YouTube URL?" | Metadata policy rejection; featuring ineligibility | All limits met; screenshots show real in-app experience |
| P10 | New-account testing gate | "Personal account created after 2023-11-13? Then: has the closed test met the tester-count / day-count gate in references/08-play-account-release.md (verify current figures in Play Console)?" | Production access denied | Gate passed or org account; production-access application answers drafted honestly |
| P11 | Developer verification | "Identity/D-U-N-S verification complete? If the app has payments: are you aware your legal address and phone become public on the listing?" | Publishing blocked; listing takedown | Verification green in Console; user accepts the disclosure |
| P12 | Release plan | "Which tracks (internal → closed → open → production), staged rollout percentages, managed publishing on?" | — (process hygiene; Vitals protection) | First production rollout staged (e.g. 1→5→10→20→50→100) with halt criteria tied to crash/ANR rates; managed publishing chosen deliberately |
| P13 | Country availability | "Do track country lists match the store-listing languages and any licensing constraints (gambling, finance, crypto)?" | Regulatory removal | Availability reviewed against licensed territories |

## After the walkthrough

Fold every answer into the main report tables (format: references/30-recipes.md). A checklist item the user cannot answer is a 🟡 WARN whose remediation is the verification step itself ("open Play Console → App content → confirm the health declaration"). Do not mark an item 🟢 OK on the user's guess — OK requires they looked.
