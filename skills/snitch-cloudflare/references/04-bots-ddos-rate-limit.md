# 04 — Bots, DDoS, Rate Limiting

## Bots: BFM / SBFM / Bot Management

| Plan | Tool | Behavior |
|---|---|---|
| Free | Bot Fight Mode | single toggle; challenges definitely-automated |
| Pro/Biz | Super Bot Fight Mode | per-category: definitely → block, likely → managed_challenge, verified → allow, JS Detections on, static-resource off |
| Enterprise | Bot Management | ML score `cf.bot_management.score` 1–99 + analytics |

Configure SBFM via `PATCH /zones/{id}/bot_management`:

```json
{ "fight_mode": true,
  "sbfm_definitely_automated": "block",
  "sbfm_likely_automated": "managed_challenge",
  "sbfm_verified_bots": "allow",
  "sbfm_static_resource_protection": false }
```

Skill flags hosts that legit need scraping (RSS readers, monitors); recommends IP allowlist with `skip` action.

Sources: https://developers.cloudflare.com/bots/get-started/bot-fight-mode/ , https://developers.cloudflare.com/bots/get-started/super-bot-fight-mode/ , https://developers.cloudflare.com/bots/plans/bm-subscription/

## L3/L4 DDoS

Free, automatic, always on. Skill confirms active + recommends notifications: `dos_attack_l4`, `dos_attack_l7`, `bot_attack`, `traffic_anomalies_alert` (`POST /accounts/{id}/alerting/v3/policies`).

Magic Transit (Enterprise) extends to BGP-announced prefixes.

Source: https://developers.cloudflare.com/ddos-protection/about/

## L7 DDoS managed ruleset

Phase `http_ddos_l7`. Free: locked sensitivity + `challenge`. Pro+: tunable. Ent: custom.

`PUT /zones/{id}/rulesets/phases/http_ddos_l7/entrypoint`.

Source: https://developers.cloudflare.com/ddos-protection/managed-rulesets/http/

## Rate Limiting Rules

Phase `http_ratelimit`. Free 1, Pro 10, Biz 100, Ent 1000+.

```json
{
  "expression": "(http.request.uri.path eq \"/api/login\") and (http.request.method eq \"POST\")",
  "action": "managed_challenge",
  "ratelimit": {
    "characteristics": ["ip.src"],
    "period": 60, "requests_per_period": 10,
    "mitigation_timeout": 600
  }
}
```

Characteristics: Free `ip.src` + `cf.colo.id`. Pro+ adds headers + cookies. Biz+ adds session-based.

Source: https://developers.cloudflare.com/waf/rate-limiting-rules/

## Workers Rate Limiting binding

Per-user / per-tenant / per-resource. Eventually consistent across colos (use DOs for atomic).

```toml
[[unsafe.bindings]]
name = "RATE_LIMITER"
type = "ratelimit"
namespace_id = "1001"
simple = { limit = 100, period = 60 }
```

```ts
const { success } = await env.RATE_LIMITER.limit({ key: userId });
if (!success) return new Response("Too many", { status: 429 });
```

Source: https://developers.cloudflare.com/workers/runtime-apis/bindings/rate-limit/

Decision (`24-decision-trees.md`): WAF RL Rule = edge-only, no code, good for `/login`. Workers binding = per-user-id, integrates with auth.

## Turnstile

Free CAPTCHA replacement. Modes: managed (invisible most of the time), non-interactive (always invisible), invisible (JS-driven).

Server verify:

```
POST https://challenges.cloudflare.com/turnstile/v0/siteverify
secret=${TURNSTILE_SECRET}&response=${CLIENT_TOKEN}
```

Skill recommends on every public-facing form (signup, login, contact, comment), lead-gen forms, high-volume forms paired with RL.

Source: https://developers.cloudflare.com/turnstile/

## Skill targets

- Bot Fight Mode `on` (free); SBFM tuned (Pro+); Bot Management as upgrade path (Ent).
- 1 RL rule on auth (free); more on paid; Workers binding at 10k+.
- DDoS notifications subscribed.
- Turnstile recommended on every public form.
