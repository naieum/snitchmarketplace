# Google Play data safety, privacy, and declarations

When to read this: auditing an Android app's privacy posture — the Data safety form, restricted permissions, foreground services, ads identifiers, health, Families, and content-rating declarations.

**Facts verified: 2026-09-01.** Dates, fees, quotas, and thresholds below were checked against the cited official pages on this date. They move; re-verify anything volatile at the linked URL before relying on it.

## Data safety form

Mandatory for every app, including "no data collected". Declare per data type: collected vs shared, ephemeral processing, required vs optional, and purpose (app functionality, analytics, developer communications, advertising, fraud prevention/security, personalization, account management).

The rules that catch people:

- **Third-party SDK data counts.** Firebase, ad SDKs, crash reporters — anything they transmit off device must be declared, whether or not you use that data.
- **"Collection" means transmission.** Device-to-server transfer counts even if nothing is stored.
- **Google verifies.** Declarations are cross-referenced against observed APK and network behavior. A mismatch is the most common rejection cause and can carry a strike.
- Encryption-in-transit and deletion-request questions are part of the form; do not claim encryption while `usesCleartextTraffic` is on (references/09-static-checks.md).

Check SDK vendors' published data-safety disclosures via the Play SDK Index (https://play.google.com/sdks) rather than guessing.

## Privacy policy

Every app needs a privacy policy URL in Play Console (App content), shown on the store listing AND linked inside the app. Active, public, not geofenced, not a broken PDF; names the app or entity; covers collection, use, sharing, retention, deletion, and contact info.

## Account deletion

If the app allows account creation, you must provide both:

1. an in-app path to delete the account, and
2. a web link (entered in the Data safety form's data-deletion section, shown on the listing) where users can request account and data deletion without reinstalling the app.

Deleting the account must delete associated data; retention exceptions (legal compliance) must be disclosed.
Static check: sign-up flow present but no delete-account route or screen.

## Restricted permissions requiring Play Console declaration forms

Any of these in the manifest without its Console declaration (and a defensible core-feature justification) blocks the release. Verify in Play Console's App content section:

| Permission / API | Rule |
|---|---|
| `READ_SMS`, `SEND_SMS`, `RECEIVE_SMS`, `READ_CALL_LOG`, `WRITE_CALL_LOG`, `PROCESS_OUTGOING_CALLS` | only default SMS/Phone/Assistant handlers or narrow exceptions; declaration mandatory |
| `ACCESS_BACKGROUND_LOCATION` | declaration plus demo video; prominent in-app disclosure; clear user benefit |
| `MANAGE_EXTERNAL_STORAGE` | justify why Storage Access Framework / MediaStore is insufficient |
| `QUERY_ALL_PACKAGES` | core interoperability only (launchers, security, file managers); otherwise use the `<queries>` element |
| Accessibility services (`BIND_ACCESSIBILITY_SERVICE`) | non-accessibility uses must be declared; `isAccessibilityTool` flag; heavy scrutiny |
| `USE_EXACT_ALARM` | alarm-clock/calendar-class apps only; prefer `SCHEDULE_EXACT_ALARM` |
| `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO` | broad gallery access only if core to the app; one-time/infrequent selection must use the Android photo picker; declaration required |
| Broad contacts access | Contacts Permissions policy announced 2026-04-15; enforcement for apps targeting Android 17+ (API 37+) begins 2026-10-28 (Play Console pre-review checks from 2026-10-27) — use the contact picker unless contacts are core, or file the Play Console declaration before enforcement starts. See "facts verified" note above. |
| `REQUEST_INSTALL_PACKAGES` | package-installer class apps only |
| `SYSTEM_ALERT_WINDOW`, VPNService, body sensors | policy-scrutinized; expect justification requests |

Static check: grep the manifest's `uses-permission` set against this table (references/09-static-checks.md).

## Foreground services

Targeting API 34+, every foreground service needs all three:

1. `android:foregroundServiceType` on the `<service>` element,
2. the matching `FOREGROUND_SERVICE_<TYPE>` permission,
3. the Play Console foreground-service declaration (App content) describing the feature with a demo video of user-initiated, perceptible use.

Types: camera, connectedDevice, dataSync, health, location, mediaPlayback, mediaProjection, microphone, phoneCall, remoteMessaging, shortService, specialUse (requires the `PROPERTY_SPECIAL_USE_FGS_SUBTYPE` justification), systemExempted. Geofencing is no longer an approved FGS use case (use the Geofence API). `USE_FULL_SCREEN_INTENT` has its own declaration and defaults to alarm/call apps on API 34+.

## Advertising ID

The Console Advertising ID declaration is always required: state whether the app or any SDK uses the ad ID and why. Targeting API 33+, add `com.google.android.gms.permission.AD_ID` or the ID reads as zeros. Child-directed apps must not transmit the ad ID at all.
Static check: ads/analytics SDK in the dependency graph without the AD_ID permission (or AD_ID present in a Families-targeted app).

## Health

All apps complete the health declaration, even to say "no health features". Health Connect access has its own declaration; health data may not be used for ads, sold to brokers, or used for credit/insurance decisions, and needs a health-specific privacy policy section.

## Families and target audience

Every app files a target audience declaration. Including any child age group activates Families policy:

- ads to children only through self-certified Families ads SDK versions, non-personalized;
- no ad-ID transmission for child users;
- mixed-audience apps need a neutral age screen and must route children to the certified, non-personalized path;
- no SDKs unapproved for child-directed use in child-only apps (major analytics SDKs have child-directed modes);
- no deceptive purchase pressure.

Apps "unintentionally appealing to children" get flagged too; do not use kid-styled art for a 13+ product.

## Content rating and sector declarations

- IARC questionnaire is mandatory; unrated apps are removed. The rating must account for ads shown in the app, and must be redone when content changes. Deliberate misrating is enforced.
- News apps: self-declaration required (in-scope apps without it were removed after 2026-05-27; verify in Play Console).
- Government-process apps need Organization accounts and may need proof of authorization.
