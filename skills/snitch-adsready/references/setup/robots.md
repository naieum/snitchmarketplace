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

## The ChatGPT-ads retrieval agent

`OAI-SearchBot` builds the index ChatGPT answers from, and ChatGPT ads are matched
contextually against what that index retrieved — so a rule blocking it removes the site
from the ad surface as well as the answers. `ChatGPT-User` handles live in-conversation
fetches; `GPTBot` is a training opt-out with no effect on either. Teams block all three in
one gesture without knowing they are different decisions. The audit reports each status;
the policy call is the user's. `references/17-ai-crawler-access.md` has the detail.

Access policy for the other AI crawlers — `PerplexityBot`, `ClaudeBot`, `Google-Extended`
and the rest — is a search-and-visibility decision, not an ads one: **call the Skill tool
with "snitch-marketing"**.

## Fix behavior

`fix robots` proposes a permissive starter when robots.txt is missing, or a targeted
`Allow` override when a `Disallow` catches a canonical ad crawler. It never loosens
rules beyond the affected user-agents and never touches AI-crawler rules without an
explicit user decision.
