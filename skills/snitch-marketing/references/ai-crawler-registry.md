# AI crawler registry

The current set of AI crawler user-agents a 2026 site should account for in `robots.txt` (Cat 1)
and in the discoverability layer of AI-search citation (Cat 82), which also audits llms.txt. Where
`robots.txt` checks historically meant Googlebot/Bingbot, the AI-citation surface depends on a
separate, faster-moving fleet — and the directives that govern them are not interchangeable.

## When surfaced

Loaded when Cat 1 (robots.txt) parses user-agent groups, when Cat 82 layer 1 (discoverability)
checks AI-crawler access, or when Cat 82's Layer 1 checks whether the advisory file is even
reachable by the crawlers it targets.

## The registry

| User-agent | Owner | Purpose | Governing token |
|---|---|---|---|
| `GPTBot` | OpenAI | Training-data crawl | `User-agent: GPTBot` |
| `OAI-SearchBot` | OpenAI | ChatGPT Search index | `User-agent: OAI-SearchBot` |
| `ChatGPT-User` | OpenAI | Live user-triggered fetch (browsing) | `User-agent: ChatGPT-User` |
| `ClaudeBot` | Anthropic | Training-data crawl | `User-agent: ClaudeBot` |
| `Claude-User` | Anthropic | Live user-triggered fetch (Claude answering a question) | `User-agent: Claude-User` |
| `Claude-SearchBot` | Anthropic | Search index for Claude's search results | `User-agent: Claude-SearchBot` |
| `anthropic-ai` / `Claude-Web` | Anthropic | Legacy tokens still seen in older `robots.txt` files | `User-agent: anthropic-ai` |
| `PerplexityBot` | Perplexity | Index crawl | `User-agent: PerplexityBot` |
| `Perplexity-User` | Perplexity | Live user-triggered fetch | `User-agent: Perplexity-User` |
| `Google-Extended` | Google | Gemini / Vertex training opt-out token (does NOT affect Search indexing) | `User-agent: Google-Extended` |
| `CCBot` | Common Crawl | Open corpus feeding many models | `User-agent: CCBot` |
| `Bytespider` | ByteDance | Training-data crawl | `User-agent: Bytespider` |
| `Amazonbot` | Amazon | Alexa / model crawl | `User-agent: Amazonbot` |
| `Applebot-Extended` | Apple | Apple Intelligence training opt-out token | `User-agent: Applebot-Extended` |
| `Meta-ExternalAgent` / `FacebookBot` | Meta | AI / model crawl | `User-agent: Meta-ExternalAgent` |
| `Diffbot` | Diffbot | Knowledge-graph extraction | `User-agent: Diffbot` |
| `cohere-ai` | Cohere | Model crawl | `User-agent: cohere-ai` |

The set evolves; treat this as the 2026 baseline and quote the live `robots.txt` rather than
asserting from memory.

## Block ≠ harmless

Blocking is not a single decision. The consequences differ by crawler role:

- **Blocking a training bot** (`GPTBot`, `ClaudeBot`, `CCBot`, `Google-Extended`,
  `Applebot-Extended`) keeps content out of future model corpora but does NOT stop live-retrieval
  citation.
- **Blocking a live-retrieval / search bot** (`OAI-SearchBot`, `ChatGPT-User`, `PerplexityBot`,
  `Perplexity-User`, `Claude-User`, `Claude-SearchBot`) directly removes the site from the assistant's
  ability to fetch and cite it in an answer right now. Each vendor's tokens are independent:
  blocking a training bot does not block that vendor's retrieval or search bot, and vice versa.
- `Google-Extended` and `Applebot-Extended` are opt-out tokens for AI training only; they do not
  govern classic Search indexing. A site can allow Search while opting out of training.

When auditing, name which role is blocked and the specific citation consequence — not just "AI
crawlers are blocked."

## Block ≠ chosen: the provenance check

Most AI-crawler blocking is inherited, not decided. An industry study of 140M websites found
~5.9% block GPTBot (the scale figure is the study's; each site's block is a hard fact from its
own `robots.txt`) — largely via template `robots.txt` files, stale configurations, and managed
platforms. Notably, Cloudflare's "instruct AI bot traffic with robots.txt" feature is **enabled by
default** and auto-rewrites `robots.txt` to signal AI-training opt-out; Cloudflare-fronted sites
may be blocking AI crawlers without any human having decided to.

Before treating a block as "intentional opt-out" (Cat 82's NOT-a-Problem carve-out), verify
provenance: is the site on Cloudflare or another platform known to inject these rules? Was the
directive present before the platform migration? Ask the user whether the block was deliberate. A
default-on platform block is a finding; a documented human choice is strategy.

## Behavioral diagnostic: observed bot activity

Beyond the permission check, *observed* bot behavior in server logs (or any bot-analytics layer)
is a diagnostic — AI bots visit pages far more often than humans, and the traffic patterns
answer questions robots.txt can't:

1. Segment bot hits by the training-vs-retrieval split above.
2. Rank pages by **live-retrieval-bot** hit frequency (`ChatGPT-User`, `OAI-SearchBot`,
   `Perplexity-User`, etc.) — pages repeatedly fetched by retrieval bots are likely being used
   as answer sources right now; that ranked list is a citation-candidate list.
3. Diff against the sitemap's priority pages — priority pages retrieval bots **never** visit
   have a discoverability problem (internal linking / site structure), a Cat 82 Layer 1 finding.

This is log evidence, so it needs logs: skip the diagnostic (with reason) when neither server
logs nor a bot-analytics source is available; never infer bot behavior.

## Forbidden claims

- "AI crawlers are probably blocked." Fetch/quote the `robots.txt` and name the exact user-agent
  group and directive.
- "Blocking GPTBot removes the site from ChatGPT answers." Distinguish the training bot from
  `OAI-SearchBot` / `ChatGPT-User`; quote which one the rule targets.
- "The site chose to opt out of AI crawling." Run the provenance check first; platform-injected
  defaults are not a choice.

---

*Crawler set compiled from a handful of open-source AI-search rule sets plus the operators'
current published crawler docs, which are the authority. Internal reference only; not surfaced
in reports.*
