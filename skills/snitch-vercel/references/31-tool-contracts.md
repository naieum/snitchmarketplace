# Tool contracts — JSON schemas every read tool returns

Each read tool emits one JSON document on stdout with a stable header. Errors go to stderr as JSON `{error, code, ...}` with non-zero exit. `fix` and `panic` emit `OK / WARN / FAIL` badges instead of JSON.

## Common header

```json
{
  "schema": "vrcsec.<name>",
  "schema_version": 1,
  "generated_at": "<ISO8601>",
  "tool": "<subcommand>",
  ... tool-specific fields ...
}
```

## Error shape (stderr)

```json
{
  "error": "<short description>",
  "code": "E_AUTH | E_API | E_USAGE | E_TEMPLATE | E_UNKNOWN_STACK | E_TEAM | E_PROJECT",
  "status": <http_code>,
  "remediation": "<concrete next step>"
}
```

## `vrcsec.detect`

```json
{
  "schema": "vrcsec.detect", "schema_version": 1, "generated_at": "...", "tool": "detect",
  "cwd": "/abs/path",
  "project_kind": "vercel-nextjs | vercel | node | php | ruby | python | dotnet | jvm | go | rust | unknown",
  "stacks": ["nextjs", "astro", ...],
  "vercel_markers": ["vercel.json", ".vercel/", "middleware.ts", "@vercel/edge", "@vercel/kv", ...],
  "databases": ["mysql", "postgres", "mongodb", "redis", "sqlite", "mssql"],
  "object_storage": ["s3", "gcs", "azure-blob", "vercel-blob"],
  "native_deps": ["sharp", "canvas", "bcrypt", "puppeteer", "playwright", "ffmpeg"],
  "background_workers": ["queue-lib", "sidekiq", "celery"],
  "websockets": true | false,
  "ai_providers": ["openai", "anthropic", "vercel-ai-sdk", ...],
  "vector_dbs": ["pinecone", "weaviate", ...],
  "headless_browser": true | false,
  "package_managers": ["npm", "pnpm", "bun", ...],
  "current_host_provider": "vercel" | "netlify" | "fly" | "railway" | "render" | "cloudflare" | "heroku-style" | null,
  "hostnames": ["example.com", "api.example.com"],
  "next_public_envs": ["NEXT_PUBLIC_API_URL", "NEXT_PUBLIC_FOO"]
}
```

Offline. Never makes API calls.

## `vrcsec.state-account.*`

`state account [slice]` — `digest` (default) | `members` | `tokens` | `audit` | `full`.

Digest:

```json
{
  "schema": "vrcsec.state-account.digest", ..., "slice": "digest",
  "user": { "id", "username", "email", "plan", "createdAt" },
  "teams_summary": { "total", "plans", "teams": [...] },
  "tokens_summary": { "total", "no_expiry", "expired", "names": [...] },
  "audit_log_recent_count": n,
  "hint": "..."
}
```

## `vrcsec.state-team.*`

`state team [team-id] [slice]` — `digest` | `members` | `full`.

```json
{
  "schema": "vrcsec.state-team.digest", ..., "team_id": "...",
  "team": { "id", "slug", "name", "plan", "saml" },
  "members_summary": { "total", "owners", "with_2fa", "without_2fa" }
}
```

## `vrcsec.state-project.*`

`state project [project-id] [slice]` — `digest` | `full`.

```json
{
  "schema": "vrcsec.state-project.digest", ..., "project_id": "...",
  "project": { "id", "name", "framework", "nodeVersion", "serverlessFunctionRegion", "ssoProtection", "passwordProtection", "trustedIps", ... },
  "protection_summary": { "sso", "password", "trusted_ips_present" }
}
```

## `vrcsec.state-env.*`

`state env [project-id] [slice]` — `digest` | `production` | `preview` | `development` | `full`.

Digest:

```json
{
  "schema": "vrcsec.state-env.digest", ..., "project_id": "...",
  "counts": { "production": n, "preview": n, "development": n, "total": n },
  "sensitive_summary": {
    "sensitive_total": n,
    "plaintext_total": n,
    "plaintext_with_secret_name": ["DATABASE_URL", "..."],
    "next_public_secret_shape": ["NEXT_PUBLIC_TOKEN"]
  },
  "next_public_envs_in_cwd": ["NEXT_PUBLIC_FOO"],
  "envs_meta": [...]
}
```

## `vrcsec.state-domains`

```json
{
  "schema": "vrcsec.state-domains", ..., "project_id": "...",
  "summary": { "total", "verified", "with_redirects" },
  "domains": [{ "name", "redirect", "verified", "verification": [...] }],
  "configs": [{ "name", "config": { /* /v6/domains/<n>/config */ } }]
}
```

## `vrcsec.state-deployments`

```json
{
  "schema": "vrcsec.state-deployments", ..., "project_id": "...",
  "window": "24h | 7d | 30d",
  "summary": { "total", "production", "preview", "ready", "error", "canceled" },
  "deployments": [{ "uid", "url", "target", "state", "creator", "created" }]
}
```

## `vrcsec.state-protection`

```json
{
  "schema": "vrcsec.state-protection", ..., "project_id": "...",
  "sso_protection": { "deploymentType": "preview" | "all" } | null,
  "password_protection": { "deploymentType": "...", ... } | null,
  "trusted_ips": { ... } | null,
  "deployment_expiration": { ... } | null,
  "git_fork_protection": true | false | null,
  "summary": { "any_protection_enabled": bool, "production_only_protections": [...] }
}
```

## `vrcsec.state-functions`

```json
{
  "schema": "vrcsec.state-functions", ..., "project_id": "...",
  "project_defaults": { "serverless_function_region", "node_version" },
  "vercel_json_functions": { "<glob>": { "memory", "maxDuration", "runtime" } },
  "latest_production_functions": [{ "name", "runtime", "memory", "maxDuration", "regions" }],
  "summary": { "config_function_count", "deployed_function_count", "edge_runtime_count", "nodejs_runtime_count" }
}
```

## `vrcsec.state-middleware`

```json
{
  "schema": "vrcsec.state-middleware", ..., "project_id": "...",
  "present": true | false,
  "path": "middleware.ts" | null,
  "signals": {
    "rate_limit_detected": bool,
    "bot_block_detected": bool,
    "geo_routing_detected": bool,
    "auth_at_edge_detected": bool
  },
  "matcher_excerpt": "matcher: [...]"
}
```

## `vrcsec.state-storage`

```json
{
  "schema": "vrcsec.state-storage", ..., "project_id": "...",
  "stores": [{ "id", "type", "name", "primaryRegion", "readRegions" }],
  "project_bindings": [{ "key": "KV_URL", "target": [...], "type": "..." }],
  "summary": { "stores_total", "kv", "postgres", "blob", "binding_keys": [...] }
}
```

## `vrcsec.state-edge-config`

```json
{
  "schema": "vrcsec.state-edge-config", ..., "project_id": "...",
  "edge_configs": [{ "id", "slug", "sizeInBytes", "itemCount" }],
  "tokens": [{ "edgeConfigId", "tokens": [{ "id", "label", "createdAt" }] }],
  "summary": { "total", "total_items", "total_tokens" }
}
```

## `vrcsec.state-log-drains`

```json
{
  "schema": "vrcsec.state-log-drains", ..., "team_id": "...",
  "drains": [{ "id", "name", "url", "deliveryFormat", "sources", "environment" }],
  "summary": { "total", "environments": [...] }
}
```

Below Pro: `{ ..., "locked": "pro", "plan": "hobby", "drains": [] }`.

## `vrcsec.state-analytics`

```json
{
  "schema": "vrcsec.state-analytics", ..., "project_id": "...",
  "web_analytics": { "enabled": bool, "id": "..." },
  "speed_insights": { "enabled": bool, "id": "..." },
  "cwd_packages": { "@vercel/analytics": bool, "@vercel/speed-insights": bool }
}
```

## `vrcsec.state-cost`

```json
{
  "schema": "vrcsec.state-cost", ..., "team_id": "...",
  "window": "24h | 7d | 30d",
  "usage": { /* raw object from /v1/teams/<id>/usage */ },
  "hint": "..."
}
```

## `vrcsec.fit-matrix*` / `vrcsec.stack-docs*`

Same shape as cloudflare-secure equivalents with `vrcsec.` schema prefix.

## Mutating tools

`fix <area>` and `panic <action>` emit badges; record per-API-call to `.state/api-calls.log`; per-action JSON to `.state/panic-<ts>-<action>.json` (panic) or update `.state/findings.tsv` (fix).
