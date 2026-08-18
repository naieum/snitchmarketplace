# Archetype: Mobile App

Anything installed through an app store — native or cross-platform, whatever the app does.
The archetype's defining constraint: a platform reviews the build before any buyer sees it,
so store policy is not a submission-week checklist — it is architecture. Adapted from
snitch-storeready, flipped from submission audit to day-one decisions: every storeready
finding that is expensive to fix late (privacy plumbing, permission design, account
deletion, billing route) is a blueprint decision made before the code that would violate it
exists.

## Decisions this archetype forces (from the interview)

- **Stores and accounts, day one.** Which store(s), and does a developer account exist?
  Enrollment takes days-to-weeks and gates everything (signing, test distribution,
  listing). It enters the build order at slot 1, in parallel with code.
- **The permission budget.** List every sensitive permission the core flow *truly* needs;
  everything else is out. Each permission is a review question, a privacy-label line, and
  a user drop-off point. The blueprint records the budget and the just-in-time rationale
  for each entry (permission requested at the moment of use, with the reason visible —
  never a launch-screen battery of prompts). "Might need it later" = not in the budget.
- **Value before login.** What can the first session do with no account? Stores penalize
  forced registration ahead of value, and so do users. If accounts are unavoidable, the
  blueprint says exactly why, offers the platform's native sign-in where rules require it,
  and — non-negotiable, both stores — plans **in-app account deletion** the same week
  account *creation* is built. Deletion bolted on later touches every data store the app
  ever grew.
- **Monetization route.** Paid / in-app purchase / subscription / free decides the billing
  rails: digital goods go through store billing (with the store's cut priced in from the
  start), physical goods and external services follow different rules per store. Choosing
  the route after billing code exists is a rewrite; the blueprint decides it first.
  Subscriptions add day-one obligations: restore purchases, visible terms, and
  cancellation that is as easy as signup (ethics gate — and also store policy).
- **Data inventory before code.** Every category of data the app will collect, why, and
  whether it leaves the device — this IS the privacy label / data-safety declaration, and
  both stores cross-check declarations against observed behavior (including what
  third-party SDKs do). Writing the inventory first means the declaration is a printout,
  not an archaeology project. Every SDK added later must re-clear this inventory.

## Conversion action

**Install → first-session activation.** The install is the store's number; the blueprint
names the in-app activation event (the user reaching first value) and instruments it from
the first build. Store-listing conversion (view → install) is measured in the store
console; the blueprint records who owns watching it.

## Surface inventory and build order

1. **Core flow to first value** — the app's 60-second proof, same discipline as the SaaS
   archetype: value visible before setup, permissions just-in-time, login only where the
   blueprint justified it.
2. **Store listing as a surface, specced like a page** — name and subtitle carrying the
   wedge in the characters the store allows, screenshots that show the real product doing
   the real thing (fabricated screens are both a claim-inventory violation and a rejection
   ground), description written for the buyer's decision. Listing assets enter the build
   order with an owner — they are launch-blocking artifacts, not a final-day scramble.
3. **Onboarding** — each screen earns its place; every skippable screen is skippable.
4. **Settings / account surface** — privacy policy link, data controls, account deletion,
   subscription management deep-link where applicable.
5. **The marketing/support site** (secondary archetype: usually a one-page content/SaaS
   hybrid) — stores require a support URL and a privacy policy URL that actually resolve;
   the privacy policy must match the data inventory verbatim.
6. **DEFERRED by default:** push notifications (trigger: a message worth sending — and
   permission asked only then, after value), ratings prompts (trigger: a moment of
   demonstrated success; never on first launch), referral mechanics, widgets/extensions.

## Day-one wiring (beyond build-defaults.md)

- Crash reporting and the activation event from build one; the analytics SDK must itself
  clear the data inventory.
- Versioning and phased-release posture recorded (staged rollout as default guard).
- Test distribution channel (the store's beta track) set up early — review surprises
  surface in beta review, weeks before launch review.
- Deep links / universal links decided early if the marketing site will ever route into
  the app; retrofitting link domains touches both site and app.

## Handoffs

snitch-storeready before every submission — it owns the full policy depth (review
guidelines, privacy manifests, data-safety forms, SDK-API floors, per-store metadata
rules); this file only front-loads the decisions that are expensive to reverse.
snitch-ux for onboarding depth; ads-ready if paid installs are planned (attribution and
consent on mobile have store-specific rules it owns).
