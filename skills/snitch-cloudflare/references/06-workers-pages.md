# 06 — Workers and Pages

## Secrets vs vars

| Item | Behavior |
|---|---|
| `vars` (`wrangler.toml`) | plaintext config; visible in dashboard + source. Never put a secret here |
| secrets | encrypted via `wrangler secret put NAME`; readable as `env.NAME` at runtime; not readable back |
| `.dev.vars` | local-only for `wrangler dev`. Must be in `.gitignore` |
| `.env` | some adapters (Next on Pages) read at build. Workers don't read `process.env` at runtime |

Skill flags high-entropy values in `[vars]`.

```sh
wrangler secret put DATABASE_URL
wrangler secret put DATABASE_URL --env production
wrangler pages secret put DATABASE_URL --project-name=<project>
```

Sources: https://developers.cloudflare.com/workers/configuration/environment-variables/ , https://developers.cloudflare.com/workers/configuration/secrets/

## `compatibility_date` / `nodejs_compat`

- Missing `compatibility_date` = FAIL.
- Older than 6 months = WARN.
- `nodejs_compat` enabled with no Node-only API imported = WARN.

Source: https://developers.cloudflare.com/workers/configuration/compatibility-dates/

## Custom domains vs `workers.dev`

Production must run on a custom domain via `[[routes]]`. Disable `workers.dev`:

```toml
workers_dev = false

[[routes]]
pattern = "api.example.com/*"
zone_name = "example.com"
```

Or `POST /accounts/{id}/workers/scripts/{name}/subdomain` `{"enabled": false}`.

Skill flags production workers (heuristic: routes set + non-dev name) with `workers.dev` enabled.

Sources: https://developers.cloudflare.com/workers/configuration/routing/ , https://developers.cloudflare.com/workers/configuration/routing/workers-dev/

## Logs / tail / sampling

- `wrangler tail my-worker --format=pretty` — real-time, free.
- Workers Logs (GA): free 200k events/day, 3-day; Paid 20M/day, 7-day. `head_sampling_rate` (1.0 low traffic, 0.1 high) in `[observability.logs]`.
- Logpush (Enterprise): push to S3/Splunk/Datadog/etc.

Sources: https://developers.cloudflare.com/workers/observability/logs/real-time-logs/ , https://developers.cloudflare.com/workers/observability/logs/workers-logs/

## Pages `_headers` / `_redirects`

- `_headers`: header set per route block (security set in 05). https://developers.cloudflare.com/pages/configuration/headers/
- `_redirects`: first-match-wins; statuses 200 (rewrite), 301/302/307/308. Splat captures via `:splat`. https://developers.cloudflare.com/pages/configuration/redirects/

## Pages Functions

Workers runtime under `functions/`. Free 100k req/day shared with Workers. Local: `wrangler pages dev`. Secrets: `wrangler pages secret put`.

Source: https://developers.cloudflare.com/pages/functions/

## Access on preview deployments

Preview URLs (`<branch>.<project>.pages.dev`) are public + indexable by default. Skill flags any project with backend / DB binding / `*-staging` / `*-internal` name without preview-Access protection as WARN. Free for ≤ 50 users.

Pages → Settings → Access policy → "Preview deployments". Or create an Access app for `*.<project>.pages.dev`.

Sources: https://developers.cloudflare.com/pages/configuration/preview-deployments/ , https://developers.cloudflare.com/cloudflare-one/applications/configure-apps/self-hosted-public-app/

## `wrangler-lint` checks

- `compatibility_date` present and < 6 months stale.
- `nodejs_compat` only when needed.
- `workers_dev = false` for production.
- No high-entropy strings in `[vars]`.
- `[[routes]]` set for production zones.
- `keep_vars = false` (default).
- `usage_model` removed (deprecated 2024+).
- Bindings consistently named (`KV`, `DB`, `BUCKET`, `AI`, `RATE_LIMITER`).
- DBs/storage in `[[d1_databases]]`/`[[kv_namespaces]]`/`[[r2_buckets]]`/`[[hyperdrive]]` — never connection strings in `[vars]`.

Source: https://developers.cloudflare.com/workers/wrangler/configuration/

## `.gitignore` (skill ensures)

```
.env
.env.*
!.env.example
.dev.vars
.dev.vars.*
.wrangler/
.cloudflare/
node_modules/
.next/
.svelte-kit/
.astro/
dist/
build/
```

## API endpoints

See `11-api-cheatsheet.md`. Key: `/accounts/{id}/workers/scripts`, `/accounts/{id}/workers/scripts/{name}/subdomain` (POST `{enabled: false}`).
