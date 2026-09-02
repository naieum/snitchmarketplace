# OpenAI / ChatGPT Ads

| Field | Value |
|---|---|
| Web tag | **None** — targeting is contextual (real-time query ↔ retrieved content), not behavioral |
| Ad surface | Sponsored cards below ChatGPT responses + sponsored results in ChatGPT search |
| Buying | OpenAI Ads Manager, self-serve beta since 2026-05-05; CPC + CPM. The pilot's $50k minimum was dropped at that launch; confirm current minimums in the Ads Manager |
| Eligibility | Ads show to Free and Go tiers (as of 2026-09); paid tiers were announced as ad-free — verify before promising a client |
| Crawlers | `OAI-SearchBot` (search index — the one that matters), `ChatGPT-User` (live fetches), `GPTBot` (training only) |
| Measurement | Click-outs land with UTM/click parameters; measure on your own analytics + landing pages |

The self-serve beta opened to US-based advertisers on 2026-05-05; it is not global. Ad
delivery at that launch covered the US, Canada, Australia, and New Zealand. Treat every
number here as a starting point and re-check the Ads Manager — this surface is new and
moving.

## Why "readiness" looks different here

There is no pixel to install and no CAPI to stub. Ad matching is a contextual retrieval
engine running against what OpenAI has indexed — so the site's *crawlability and
machine-readability* is the tracking-equivalent surface:

1. **`OAI-SearchBot` must not be blocked.** The `state site <url> robots` slice reports
   per-agent verdicts under `crawler_access`. Blocking `GPTBot` is a training opt-out and
   does NOT remove search visibility; blocking `OAI-SearchBot` does. Teams frequently block
   both in one gesture without knowing they're different decisions — surface it, let the
   user decide deliberately.
2. **The page has to carry its own content.** Contextual matching reads what the crawler
   fetched, so an offer that appears only after client-side hydration is not in the
   retrieved text. `17-ai-crawler-access.md` covers the access side. No provider publishes
   how answers or sponsored slots are assembled — do not promise a user that a file or a
   schema type improves their standing, and send content-and-citation questions to the
   marketing audit by calling the Skill tool with "snitch-marketing".
3. **Landing pages carry the whole conversion story.** With contextual (not behavioral)
   matching, the query→ad match is only as good as the page content; and since there's no
   view-through signal, UTM discipline + your own analytics are the entire measurement
   stack. `state site <url> lead-capture` covers the form/call side.
4. **Consent posture still applies to the click-out**: the landing session is ordinary web
   traffic under GDPR / US state laws; nothing about the ad's origin exempts it.

## What the audit can and can't check

- CAN: robots verdicts for the three OpenAI agents, server-rendered landing-page content,
  lead capture, UTM handling.
- CANNOT (no public state API as of 2026-09): campaign/account state inside OpenAI Ads
  Manager. There is no `state platform openai` — recommend the dashboard directly at
  the OpenAI Ads Manager.

## Cited URLs

- OpenAI crawler documentation: <https://platform.openai.com/docs/bots>
- Self-serve Ads Manager launch, 2026-05-05 (verified 2026-09-01): <https://www.axios.com/2026/05/05/openai-self-serve-ad-platform>
