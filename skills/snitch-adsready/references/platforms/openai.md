# OpenAI / ChatGPT Ads

| Field | Value |
|---|---|
| Web tag | **None** — targeting is contextual (real-time query ↔ retrieved content), not behavioral |
| Ad surface | Sponsored cards below ChatGPT responses + sponsored results in ChatGPT search |
| Buying | OpenAI Ads Manager (self-serve since May 2026); CPC + CPM; ~$25/day minimum budget |
| Eligibility | Ads show to Free and Go tiers; Plus/Team/Enterprise stay ad-free (as of mid-2026) |
| Crawlers | `OAI-SearchBot` (search index — the one that matters), `ChatGPT-User` (live fetches), `GPTBot` (training only) |
| Measurement | Click-outs land with UTM/click parameters; measure on your own analytics + landing pages |

Launched as a US pilot February 2026, self-serve globally from May 2026. Agency/adtech
integrations: Adobe, Criteo, Kargo, Pacvue, StackAdapt.

## Why "readiness" looks different here

There is no pixel to install and no CAPI to stub. Ad matching is a contextual retrieval
engine running against what OpenAI has indexed — so the site's *crawlability and
machine-readability* is the tracking-equivalent surface:

1. **`OAI-SearchBot` must not be blocked.** The `state site <url> robots` slice reports
   per-agent verdicts under `crawler_access`. Blocking `GPTBot` is a training opt-out and
   does NOT remove search visibility; blocking `OAI-SearchBot` does. Teams frequently block
   both in one gesture without knowing they're different decisions — surface it, let the
   user decide deliberately.
2. **llms.txt** (see `17-llms-txt-and-ai-search.md`) and clean structured data
   (`07-structured-data.md`) improve how the retrieval layer represents the brand.
3. **Landing pages carry the whole conversion story.** With contextual (not behavioral)
   matching, the query→ad match is only as good as the page content; and since there's no
   view-through signal, UTM discipline + your own analytics are the entire measurement
   stack. `state site <url> lead-capture` covers the form/call side.
4. **Consent posture still applies to the click-out**: the landing session is ordinary web
   traffic under GDPR / US state laws; nothing about the ad's origin exempts it.

## What the audit can and can't check

- CAN: robots verdicts for the three OpenAI agents, llms.txt presence, structured-data
  coverage, landing-page lead capture, UTM handling.
- CANNOT (no public state API as of mid-2026): campaign/account state inside OpenAI Ads
  Manager. There is no `state platform openai` — recommend the dashboard directly at
  the OpenAI Ads Manager.

## Cited URLs

- OpenAI crawler documentation: <https://platform.openai.com/docs/bots>
- llms.txt spec: <https://llmstxt.org/>
