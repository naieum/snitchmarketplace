## CATEGORY 23: GDPR
> Type: compliance · Groups: compliance · CWE: CWE-359

### Detection
- Personal data handling: `personal_data`, `pii`, `data_subject`
- Consent management: `consent`, `opt_in`, `gdpr`
- Data subject rights: `right_to_delete`, `right_to_access`, `data_export`
- EU user detection: locale, region, or country checks for EU

### What to Search For
- Data collection without consent verification
- Missing data deletion endpoints
- Missing data export/portability endpoints
- Excessive data collection
- No data retention policies
- Third-party data sharing without consent
- Analytics/tracking without consent checks

### Actually Vulnerable

#### Critical
- **Consent-dependent** processing with no consent check (Art 6(1)(a)). This is narrow on purpose:
  Art 6 offers six lawful bases, and contract (6(1)(b)) and legitimate interest (6(1)(f)) cover
  ordinary account signup, order fulfilment, and security logging. A registration form with no
  `consent` keyword near it is **not** a finding. The finding is processing that has no lawful basis
  other than consent — marketing email enrolment, non-essential cookies and tracking pixels, ad
  personalisation, profiling, sharing to a third party for their own purposes, or special-category
  data (Art 9) — reaching the wire with no consent gate on the path. Name which processing, at
  file:line, and say why contract and legitimate interest do not cover it
- No data deletion capability for personal data (Art 17 - Right to Erasure). Search broadly for ANY of these patterns:
  - Route/endpoint names: `delete`, `remove`, `erase`, `purge`, `destroy`, `forget`, `wipe`, `clear`
  - Function names: `deleteUser`, `removeAccount`, `eraseUser`, `forgetMe`, `purgeData`, `destroyAccount`, `closeAccount`, `deactivateAccount`
  - Combined with: `user`, `account`, `profile`, `data`, `personal`, `member`, `customer`
  - API paths: `/delete`, `/remove`, `/erase`, `/account/close`, `/me/delete`, `/privacy/delete`
  - If ANY deletion mechanism exists (regardless of naming), it satisfies Art 17
- No data export/portability capability (Art 20 - Right to Data Portability). Search broadly for ANY of these patterns:
  - Route/endpoint names: `export`, `download`, `portability`, `extract`, `dump`, `backup`, `archive`
  - Function names: `exportData`, `downloadData`, `getUserData`, `getMyData`, `extractData`, `generateReport`, `downloadProfile`
  - Combined with: `user`, `account`, `profile`, `data`, `personal`, `member`, `customer`
  - API paths: `/export`, `/download`, `/me/data`, `/privacy/export`, `/account/data`
  - File generation: `csv`, `json`, `pdf`, `zip` exports of user data
  - If ANY export mechanism exists (regardless of naming), it satisfies Art 20
- EU user data sent to non-EU endpoints without transfer safeguards (Art 44-49)

#### High
- Collecting unnecessary fields (SSN, DOB when not business-required) (Art 5)
- Personal data without `ttl`, `expiresAt`, or cleanup jobs (Art 5)
- PII sent to external APIs without consent verification (Art 44)
- Analytics or tracking initialized without consent banner check (Art 7)

#### Medium
- No `anonymize`, `pseudonymize`, or `hash` functions for analytics data (Art 25)
- Cookie consent not verified before setting non-essential cookies

### NOT Vulnerable
- Account signup, order processing, or security logging with no consent gate — contract and
  legitimate interest are lawful bases; absence of the word "consent" is not a finding
- Consent verification before data collection
- Any working data deletion mechanism, regardless of naming convention
- Any working data export/download mechanism, regardless of naming convention
- Anonymized or pseudonymized data for analytics
- Proper data retention with automated cleanup
- Consent management platform integration
- Third-party services with DPAs in place

### Context Check
1. Does the application actually handle EU user data?
2. Is consent managed at a different layer (consent management platform)?
3. Are there data processing agreements with third parties?
4. Is this personal data or anonymous/aggregated data?

### Evidence Chain
- The collection/processing snippet at file:line (personal data collected, tracked, or transferred)
- For missing-capability findings (Art 17/20): the broad search actually performed — the deletion/export patterns listed above that were searched, with the negative result stated
- The specific GDPR article violated (Art 5, 6, 7, 17, 20, 25, 33, 44-49) named in the finding
- The consent/safeguard checked and found absent (no consent gate before collection or analytics init, no CMP integration, no transfer safeguard)
- Impact link: which personal data of EU users is affected and where it flows

### Confidence Scoring
- High: personal data collection/transfer confirmed at file:line with the safeguard verifiably absent — for Art 17/20, only after the broad multi-pattern search found no mechanism under any naming
- Medium: the pattern is present but consent may be handled by an external consent management platform, or DPAs/transfer safeguards may exist outside the code
- Low: cannot confirm the application handles EU user data, or cannot distinguish personal from anonymized/aggregated data → tag `needs human verification`

### Files to Check
- User registration and data collection endpoints
- Privacy/settings pages
- Account management pages (settings, profile, close account)
- Analytics initialization code
- Data export/deletion handlers (search broadly: `delete`, `remove`, `export`, `download`, `extract`, etc.)
- Cookie consent components
- Third-party integrations sending user data
- Admin panels with user management features
