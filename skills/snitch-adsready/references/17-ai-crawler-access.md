# 17 — AI crawler access (the ChatGPT-ads surface)

Read when auditing readiness for ChatGPT ads, or when a robots rule is about to decide whether
an assistant can retrieve the site at all.

**ChatGPT is an ad channel** (sponsored cards in responses and in ChatGPT search, matched
contextually against retrieved content, bought through a self-serve Ads Manager — details and
dates in `references/platforms/openai.md`). There is no pixel to install: the retrieval layer
only sees pages its crawler is allowed to fetch, so crawler access *is* the tracking-equivalent
surface here. The `state site <url> robots` slice reports per-agent verdicts under
`crawler_access`.

Everything else AI-search-shaped — llms.txt, whether an assistant cites a page, schema as a
citation play, AI Overviews, brand answer coverage — is evidenced against search and belongs to
the marketing audit: **call the Skill tool with "snitch-marketing"**.

## The three OpenAI agents, and why the difference matters

| User-agent | What it does | Blocking it costs |
|---|---|---|
| `OAI-SearchBot` | builds the ChatGPT search index | removal from ChatGPT answers, and from the retrieved set that ads are matched against |
| `ChatGPT-User` | live, user-initiated fetch during a conversation | on-demand page reads fail |
| `GPTBot` | model-training collection | nothing on the ads or answer surface — this is a training opt-out only |

Teams routinely block all three in one gesture believing they are opting out of training.
Report each agent's status separately and let the user make three decisions. Anthropic,
Perplexity, and other assistants ship their own agents on the same pattern; their access is a
site-policy question the marketing audit judges, not an ads one.

Nothing here is a recommendation to open the site to training crawlers. The audit reports what
the file says; the policy is the user's.

```
# robots.txt — allow the ad-adjacent retrieval agent, opt out of training
User-agent: OAI-SearchBot
Allow: /

User-agent: ChatGPT-User
Allow: /

User-agent: GPTBot
Disallow: /   # training opt-out only: a policy call, never a readiness finding
```

## Audit signals

- `crawler_access` verdict per OpenAI agent from `state site <url> robots`, quoted with the
  robots.txt line that produced it.
- `<meta name="robots">` on the landing pages a campaign points at — a `noindex` there removes
  the page from the retrieval set even with robots.txt wide open.
- Whether the landing pages render their offer server-side. Contextual matching reads fetched
  content; an offer that only exists after client-side hydration is not in it.
- Landing-page conversion path: with no view-through signal and no pixel, UTM discipline plus
  the site's own analytics is the entire measurement stack —
  `state site <url> lead-capture` covers the form and call side.

## What this file deliberately does not claim

No provider publishes how its answers are assembled. This skill does not tell a user that a
schema type, an llms.txt file, or a content format raises their odds of being cited or
sponsored. Access is checkable; ranking inside an assistant is not.

## See also

- `references/platforms/openai.md` — the ad product, buying, and what the audit cannot check.
- `references/setup/robots.md` — the ad-crawler rules and the `fix robots` behavior.
- OpenAI crawler documentation: https://platform.openai.com/docs/bots
