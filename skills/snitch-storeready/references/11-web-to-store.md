# Web app → store path — feasibility mode

When to read this: Step 0 found a web project with **no native target**. Do not audit a web app against store rules — every manifest and plist check would be a meaningless N/A. This mode answers the question the user is actually asking: *can this ship to the stores, by which path, at what cost* — then hands back to the full audit once a native project exists.

**Facts verified: 2026-09-01.** Dates, fees, quotas, and thresholds below were checked against the cited official pages on this date. They move; re-verify anything volatile at the linked URL before relying on it.

The output is a recommendation with evidence, not an audit. Effort figures are estimates and say so; the no-approval-promises rule applies here too.

## Web-stack detection (record with file:line evidence)

| Signal | What it tells you |
|---|---|
| `package.json` with `react` / `vue` / `svelte` / `@angular/core` + `vite` / `webpack` | SPA framework — name it; SPAs are the easiest wrap targets |
| `next` / `nuxt` / `sveltekit` / `remix` with server routes or SSR config | Server-rendered app — a shell cannot bundle it as-is; needs static export, or the shell points at the hosted app (weakens the offline story) |
| `manifest.webmanifest` / `manifest.json` with `start_url` + icons | PWA manifest present — TWA prerequisite half-met |
| `navigator.serviceWorker.register`, `workbox`, `vite-plugin-pwa`, `next-pwa` | Service worker — offline capability exists; TWA prerequisite and an Apple 4.2 talking point |
| `@stripe/stripe-js`, `stripe`, checkout/payment links, `paypal` | Web payments — if these sell **digital** goods, the in-app version must move to Apple IAP / Play Billing (3.1.1 / Play Payments policy). Often the largest hidden migration cost; flag it now, not at submission |
| `supabase`, `firebase/auth`, `next-auth`, `auth0`, `signInWithOAuth`, provider names (`google`, `facebook`, `apple`) | Accounts exist — in-app deletion (5.1.1(v)) and Play's web deletion URL become mandatory; any social login triggers the 4.8 equivalent-login requirement (Sign in with Apple or an equivalent service — see references/01-apple-review-guidelines.md §4.8), including built-but-disabled providers the client may enable later — report that as a conditional finding with its trigger, not a question |
| Web push (`PushManager`, `firebase/messaging` web SDK) | Push must be re-wired through APNs/FCM in the native shell — web push does not carry over on iOS wrappers |

## Path matrix

| Path | What it is | App Store | Play | Effort (estimate) | Fits when |
|---|---|---|---|---|---|
| **Capacitor** | Native shell + plugin bridge around the existing web build | ✅ with 4.2 caveat below | ✅ with webview-spam caveat | Days–weeks | Existing SPA where a shell and necessary integrations fit the actual product; plugins alone do not establish sufficient utility |
| **TWA (Bubblewrap)** | Play publishes the live PWA in a browser container | ❌ no Apple equivalent — a bare URL wrapper is 4.2 bait | ✅ | Days | Android-first and the PWA is already good: HTTPS, valid manifest, service worker, and `assetlinks.json` digital-asset-links verification on the domain |
| **React Native / Expo** | Native UI rewrite reusing business logic and APIs | ✅ | ✅ | Weeks–months | Measured UX/performance constraints or deep native integration justify a rewrite |
| **Full native (Swift/Kotlin)** | Ground-up rewrite per platform | ✅ | ✅ | Months | Rarely the answer for an existing web product; recommend only with a concrete reason |

Default for an existing SPA targeting both stores: **Capacitor** — lowest effort that still reaches the App Store — stated with the 4.2 caveat, never as a guarantee.

## What the real audit will check once a native target exists (preview honestly)

- **Apple minimum functionality / Play policy:** inspect utility beyond a repackaged website
  for Apple. Separately check website-owner permission, affiliate purpose, and actual utility
  for Play. A WebView call alone proves none of these failures; adding a native plugin alone
  proves no remedy (references/09-static-checks.md, references/05-play-policy.md).
- **Offline is not optional:** reviewers test with degraded connectivity; a blank webview offline reads as an incomplete app (2.1). Bundle the web assets in the shell rather than loading only a live URL, and ship a real offline state.
- **Payments:** digital goods or subscriptions unlocked in-app must use Apple IAP and Play Billing; web checkout stays legal on the website only. If Stripe-for-digital-goods was detected above, this is the headline item in the recommendation.
- **Accounts cascade:** account creation → in-app deletion + Play web deletion URL; social login → the 4.8 equivalent-login requirement (Sign in with Apple or an equivalent service — see references/01-apple-review-guidelines.md §4.8), and if Sign in with Apple is the one shipped, token revocation on delete (§5.1.1).
- **Store admin:** Apple Developer Program US $99/yr; Play US $25 one-time plus the new-personal-account closed-testing gate before production access (figures in references/08-play-account-release.md; verify in the consoles).

## Report format for this mode

Write to the standard report path (references/30-recipes.md). Verdict line pattern: "Not auditable yet: web project with no native target — store-path recommendation below." Then three tables — detected stack (with evidence), path comparison scoped to *this* project, and next steps — plus one recommendation paragraph naming a path and why. Close by offering the full audit once the native project exists.
