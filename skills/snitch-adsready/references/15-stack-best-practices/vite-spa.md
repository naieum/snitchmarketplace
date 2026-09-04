# Vite SPA — ads-tracking checks

A SPA is not a readiness verdict. Inspect the actual landing page and event path; do not
recommend a framework migration solely because rendering is client-side.

## Pixel and consent behavior

- Confirm which platforms the user actually uses. Do not install unrelated tags.
- Inspect initial load, consent denied/granted/revoked, and client-side navigation.
- A missing signature in initial HTML may be a tag-manager or consent-delayed install.
  Browser/network evidence is needed to settle runtime firing; unavailable evidence is Skip.
- Select one page-view strategy per platform. Check automatic history tracking, tag-manager
  triggers, and existing listeners before adding manual router events. Verify exactly one
  intended event per navigation, including initial load, redirects, and back/forward.
- Do not send sensitive query parameters or form contents as page/event properties.
- Keep server credentials out of the client bundle.

## Conversion path

A pure client app needs an appropriate server endpoint for server-side conversions. First
inspect existing backend or platform integrations; CAPI is not mandatory for every advertiser.
Check event identity/deduplication, consent handling, destination account, and the actual
conversion trigger rather than treating a loaded library as proof of attribution.

## Performance and rendered content

Measure LCP, INP, and CLS when field data is available. Label lab results separately; CrUX
observes real-user experience, not merely the static shell. No field data means unknown,
not failure. Initial HTML, rendered DOM, and a particular crawler's processing are different
evidence modes.

Inspect actual content and metadata before declaring them absent. Consider image delivery,
script cost, route splitting, and selective prerendering where the measured bottleneck
supports them. SSR or SSG may help a specific problem but guarantees neither fast pages nor
valid metadata. Do not invent expected Lighthouse scores or relax targets for a framework.

## Verification

Repeat the relevant consent/navigation/conversion checks after an authorized change. Record
what actually ran and which environments and states remain untested. A parser signature or
higher composite score alone does not verify a tracking fix.
