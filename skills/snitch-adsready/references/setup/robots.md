# Setup: robots (ad crawlers + AI crawlers)

Ad platforms verify landing pages with dedicated crawlers. A `Disallow` that catches one
fails ad review, breaks dynamic ads, or degrades Quality Score / landing-page experience.

## Crawlers that must not be blocked (for active platforms)

| Platform | User-agents |
|---|---|
| Google Ads | `AdsBot-Google`, `AdsBot-Google-Mobile` (note: AdsBot ignores `User-agent: *` disallows — only a rule naming AdsBot blocks it), `Googlebot` for organic |
| Microsoft / Bing | `bingbot`, `AdIdxBot` |
| Meta | `facebookexternalhit`, `meta-externalagent` |
| LinkedIn | `LinkedInBot` |
| TikTok | `Bytespider` |
| Pinterest | `Pinterestbot` |

## AI crawlers (deliberate policy, not an accident)

AI-search surfaces — including ChatGPT (ads launched 2026, contextual retrieval against
indexed pages) — read the site through their own crawlers:

- `OAI-SearchBot` — ChatGPT search index (this is the one that affects ChatGPT visibility
  and, since ads are matched contextually to retrieved results, ad-adjacent presence)
- `GPTBot` — OpenAI model training
- `ChatGPT-User` — live user-initiated fetches
- `PerplexityBot`, `ClaudeBot`, `Google-Extended` — other AI surfaces / training opt-outs

Blocking `OAI-SearchBot` removes the site from ChatGPT answers; blocking `GPTBot` only
opts out of training. Many teams block both without realizing they are different
decisions. The audit reports each agent's status; the policy call is the user's.

## Fix behavior

`fix robots` proposes a permissive starter when robots.txt is missing, or a targeted
`Allow` override when a `Disallow` catches a canonical ad crawler. It never loosens
rules beyond the affected user-agents and never touches AI-crawler rules without an
explicit user decision.
