# AI crawler registry

The current set of AI crawler user-agents a 2026 site should account for in `robots.txt` (Cat 1)
and in the discoverability layer of AI-search citation (Cat 82) and llms.txt (Cat 106). Where
`robots.txt` checks historically meant Googlebot/Bingbot, the AI-citation surface depends on a
separate, faster-moving fleet — and the directives that govern them are not interchangeable.

## When surfaced

Loaded when Cat 1 (robots.txt) parses user-agent groups, when Cat 82 layer 1 (discoverability)
checks AI-crawler access, or when Cat 106 (llms.txt) checks whether the advisory file is even
reachable by the crawlers it targets.

## The registry

| User-agent | Owner | Purpose | Governing token |
|---|---|---|---|
| `GPTBot` | OpenAI | Training-data crawl | `User-agent: GPTBot` |
| `OAI-SearchBot` | OpenAI | ChatGPT Search index | `User-agent: OAI-SearchBot` |
| `ChatGPT-User` | OpenAI | Live user-triggered fetch (browsing) | `User-agent: ChatGPT-User` |
| `ClaudeBot` | Anthropic | Training-data crawl | `User-agent: ClaudeBot` |
| `Claude-Web` | Anthropic | Live user-triggered fetch | `User-agent: Claude-Web` |
| `anthropic-ai` | Anthropic | Legacy/general Anthropic crawl | `User-agent: anthropic-ai` |
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
  `Perplexity-User`, `Claude-Web`) directly removes the site from the assistant's ability to fetch
  and cite it in an answer right now.
- `Google-Extended` and `Applebot-Extended` are opt-out tokens for AI training only; they do not
  govern classic Search indexing. A site can allow Search while opting out of training.

When auditing, name which role is blocked and the specific citation consequence — not just "AI
crawlers are blocked."

## Forbidden claims

- "AI crawlers are probably blocked." Fetch/quote the `robots.txt` and name the exact user-agent
  group and directive.
- "Blocking GPTBot removes the site from ChatGPT answers." Distinguish the training bot from
  `OAI-SearchBot` / `ChatGPT-User`; quote which one the rule targets.

---

*Crawler set compiled from the MIT-licensed geo-seo-claude, claude-seo, and claude-rank projects
plus current published crawler docs. Internal reference only; not surfaced in reports.*
