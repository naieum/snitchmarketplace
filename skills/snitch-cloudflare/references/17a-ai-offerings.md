# 17a — Cloudflare AI Offerings

Snapshot 2026-05. Pricing changes monthly — cite live pages.

## Workers AI

Open-weight inference on Cloudflare's GPU fleet. Bind via `env.AI.run("@cf/...")` from Workers, or HTTP via AI Gateway.

Honest framing: covers most use cases at lower cost than frontier models. Doesn't match GPT-4-class / Claude Opus on hard reasoning, long-context, or vision-heavy tasks. Use frontier via AI Gateway for those, Workers AI for cheap tractable problems.

Catalog: https://developers.cloudflare.com/workers-ai/models/

Common picks: `@cf/meta/llama-3.3-70b-instruct-fp8-fast` (chat), `@cf/meta/llama-3.1-8b-instruct` (cheap), `@cf/qwen/qwen2.5-coder-32b-instruct` (code), `@cf/baai/bge-{small,base,large,m3}` (embeddings 384/768/1024/1024-multilingual), `@cf/openai/whisper-large-v3-turbo` (STT), `@cf/black-forest-labs/flux-1-schnell` (image gen), `@cf/meta/llama-guard-3-8b` (safety).

Pricing: Neurons. Free 10k Neurons/day. Paid (Workers Paid required) ~$0.011 / 1k. https://developers.cloudflare.com/workers-ai/platform/pricing/

Comparison highlights (benchmark on your data):
- BGE-base ~10x cheaper than OpenAI `text-embedding-3-small` for English at comparable quality.
- Whisper Workers AI competitive with OpenAI Whisper API at lower cost.
- Llama 3.3 70B fine for cheap tier; for hard reasoning prefer Anthropic / OpenAI.
- Image: Flux schnell + SDXL fast/cheap; for marketing-grade prefer Midjourney / FAL.

## AI Gateway

Proxy URL: `https://gateway.ai.cloudflare.com/v1/{ACCOUNT_ID}/{GATEWAY}/{provider}` — drop-in replace OpenAI base URL.

Providers: openai, anthropic, azure-openai, aws-bedrock, google-vertex-ai, google-ai-studio, cohere, perplexity, replicate, huggingface, mistral, groq, deepseek, workers-ai.

Features: caching (semantic + exact), per-route rate limits, retries + provider fallback, logs/analytics, AI WAF (beta), Universal Endpoint (multi-provider fallback chain), BYOK.

Pricing: free 100k logged req/mo. Caching + rate-limiting free. https://developers.cloudflare.com/ai-gateway/reference/pricing/

Source: https://developers.cloudflare.com/ai-gateway/

## Vectorize

Managed vector DB. `env.VECTORIZE` binding.

- Dimensions fixed at index creation (384/768/1024/1536 typical) — mismatch = full re-index.
- Metric: `cosine | euclidean | dot-product`.
- Up to 5M vectors / index. Per-vector JSON metadata, filterable. Namespaces for per-tenant separation.
- Dense-only — for hybrid (BM25 + dense) add an external sparse store.

Pricing: billed in dimensions not vectors. 1536-dim costs 4x a 384-dim index. https://developers.cloudflare.com/vectorize/platform/pricing/

Source: https://developers.cloudflare.com/vectorize/

## AutoRAG

Managed RAG: R2 → chunk + embed → Vectorize → AI Gateway + Workers AI generation. Use for simple PDFs-in-R2 RAG. Avoid for complex pipelines (custom rerankers, hybrid retrieval, conversation-aware retrieval, function-calling agents). Bills on the underlying components.

Source: https://developers.cloudflare.com/autorag/

## Browser Rendering

Managed headless Chrome. PDF gen, screenshots, scraping (within ToS), agent automation.

Modes: REST (`POST /accounts/{id}/browser-rendering/{action}`) or Workers binding (`env.MYBROWSER`, Puppeteer-compatible). Workers Paid required. Per-minute pricing — https://developers.cloudflare.com/browser-rendering/platform/pricing/

Cheaper than self-managed Chrome at low volume; sandboxed. Not an anti-bot evasion tool.

Source: https://developers.cloudflare.com/browser-rendering/

## Skill recommendations

| Detected | Recommend | Caveat |
|---|---|---|
| Direct OpenAI/Anthropic/Gemini SDK | AI Gateway base URL | Free; drop-in |
| OpenAI embeddings | Workers AI BGE | Benchmark first |
| Whisper / Deepgram / AssemblyAI | Workers AI Whisper | Quality competitive |
| Pinecone / Weaviate / Qdrant Cloud | Vectorize | Dimension mismatch warning |
| Hand-rolled chunker → embed → vector | AutoRAG | Only if simple |
| Puppeteer / Playwright at runtime | Browser Rendering | Per-minute pricing |
| Workers + AI HTTP API | Switch to `env.AI` binding | Lower latency, no key |
| Frontier model (Opus, GPT-4o) | Keep upstream + AI Gateway | Don't migrate to Workers AI |

Recommendations are diff-only; never auto-applied.
