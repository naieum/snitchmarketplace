# 17 — Workers AI Security

Hardening AI features the user already built. (For "should we add Cloudflare AI?", see `17a-ai-offerings.md`.)

## Three threat surfaces

1. Prompt injection — attacker text manipulates LLM into emitting attacker-controlled output / bypassing safety / exfiltrating context.
2. Unbounded cost — attack or bug burns budget.
3. Data exposure — secrets in prompts, prompts logged to providers, vector indexes accessible without scoping.

## Rate limit LLM endpoints

Defense in depth: edge WAF + Workers binding + spend-based.

- Edge (WAF Rate Limiting Rule) — cheap; per-IP throttle on `/api/chat`. 60s, 30 req, `managed_challenge`, mitigation_timeout 600.
- Per-user (Workers RL binding) — better for logged-in:

  ```ts
  const { success } = await env.AI_LIMITER.limit({ key: `ai:${userId}` });
  if (!success) return new Response("Too many", { status: 429 });
  ```

- Spend-based — token-billed models, cost on estimated tokens:

  ```ts
  await env.AI_LIMITER.limit({ key: `ai-tok:${userId}`, cost: estimateTokens(req.body) });
  ```

Source: https://developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/

## AI Gateway logging

| Mode | When |
|---|---|
| `full` | debug only — req+resp body |
| `metadata-only` | production with PII/PHI |
| `off` | strictest |

For HIPAA / GDPR / PCI: metadata-only or off. CF DPA governs logged data.

Skill flags: AI Gateway `collect_logs: true` + prompts likely contain PII = WARN.

Source: https://developers.cloudflare.com/ai-gateway/configuration/

## Vectorize access scoping

Indexes bound to Workers; no public REST. Auth lives in the Worker fronting the index.

Mistakes:
- Open `/api/search` POST → anyone runs full vector search.
- No tenant scoping on multi-tenant indexes → cross-tenant exposure.
- Embedding "index keys" in source — there are none; the binding is the authn.

Multi-tenant pattern (skill greps for `.query(` without `filter` → WARN):

```ts
const matches = await env.VECTORIZE.query(embedding, {
  topK: 10, filter: { tenantId: { $eq: tenantId } }
});
```

Source: https://developers.cloudflare.com/vectorize/best-practices/

## Prompt-injection mitigations

1. Input filter — pre-LLM classifier (`@cf/meta/llama-guard-3-8b`).
2. Output filter — same model post-LLM; detect leaked system prompt / PII / attacker URLs.
3. Structural separation — fence user input in `<USER>...</USER>`.
4. Tool/function allowlist — every callable function validates args (parameterized queries — never LLM-emitted SQL), tight scope, logged invocations.
5. No secrets in system prompts — they're extractable.
6. Suspicious-pattern RL — detect injection → drop request → increment per-user counter → suspend AI access after N attempts.

Source: https://developers.cloudflare.com/learning-paths/secure-prompts/

## Secret-leak surfaces

- `env.AI` binding needs no secret — flag any worker using `env.AI` plus a `var OPENAI_API_KEY`.
- Provider key literals (`sk-...`, `sk-ant-...`, Gemini patterns) in source → FAIL. Move to `wrangler secret put`.
- AI Gateway full logs containing `Authorization:` / `Bearer ` patterns → leak.

## Workers AI: binding vs HTTP

- Binding (`env.AI.run(...)`) — no API key, lower latency. Use for Workers.
- HTTP (`POST gateway.ai.cloudflare.com/v1/.../workers-ai/...`) — for non-Worker callers; needs an account API token.

Source: https://developers.cloudflare.com/workers-ai/get-started/workers-binding/

## Skill targets

| Check | Level |
|---|---|
| Rate limit on every LLM-calling route | WARN if missing |
| AI Gateway in front of every external LLM call | WARN if not |
| AI Gateway log mode if prompts likely PII | WARN if `full` |
| Vectorize multi-tenant `filter` present | FAIL if missing in multi-tenant |
| No provider API key literals in source | FAIL if found |
| Prompt-injection guard | INFO recommendation |
