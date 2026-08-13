# Setup: verification-meta

Domain verification is a prerequisite most ad features silently depend on: Meta
conversion-domain settings and aggregated event configuration, Google Search Console
data (which feeds Ads landing-page diagnostics), Microsoft UET tag ownership, Pinterest
claimed-domain analytics.

## Meta-tag verifiers (what `fix verification-meta` emits)

| Platform | Meta name | Token source |
|---|---|---|
| Google | `google-site-verification` | Search Console → Settings → Ownership verification |
| Meta | `facebook-domain-verification` | Business Manager → Brand Safety → Domains |
| Microsoft | `msvalidate.01` | Bing Webmaster Tools → Settings → Verify ownership |
| Pinterest | `p:domain_verify` | Pinterest Settings → Claimed accounts |

Emitted tags carry a `REPLACE_WITH_TOKEN` placeholder — the user pastes the real token
before deploy, then clicks Verify in the platform dashboard.

## File-based verifiers (not meta tags — manual)

LinkedIn, TikTok, X, Reddit, and Snapchat verify by uploading a platform-generated file
to the site root. Apple uses `apple-app-site-association` (JSON at the root or
`/.well-known/`), which `fix verification-meta apple` stubs.

DNS TXT verification is an alternative on Google / Meta / Microsoft when editing the
site is harder than editing DNS.
