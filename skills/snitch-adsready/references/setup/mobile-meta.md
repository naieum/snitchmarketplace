# Setup: mobile-meta

Mobile-friendliness is a direct input to ad landing-page experience (Google Quality
Score, Meta ad review). The minimum viable set:

- `<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">`
  — without it, the page renders desktop-width on phones and fails mobile-friendly checks.
- `<meta name="theme-color" content="...">` — browser chrome color; cosmetic but cheap.
- `<meta name="apple-mobile-web-app-capable">` + status-bar style — standalone-mode polish.
- `<meta name="format-detection" content="telephone=no">` — stops iOS auto-linking every
  number-like string. **Caveat for call-first businesses:** this removes auto-generated
  call links, so every phone number the business wants called must be an explicit
  `<a href="tel:...">` — which is also the only version call-conversion tracking can see
  (see the `lead-capture` slice and `references/platforms/google.md` call-first section).

`fix mobile-meta` emits the tag block for the detected stack; the agent applies it to the
document head component after user confirmation.
