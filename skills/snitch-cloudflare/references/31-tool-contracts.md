# Tool contracts — JSON schemas every read tool returns

Each `snitch-cloudflare.sh` read tool emits one JSON document on stdout with a stable header. Errors go to stderr as JSON `{error, code, ...}` with non-zero exit. Mutating tools (`fix`, `panic`) emit `OK / WARN / FAIL` badges instead of JSON.

## Common header

```json
{
  "schema": "cfsec.<name>",
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
  "code": "E_AUTH | E_API | E_USAGE | E_TEMPLATE | E_UNKNOWN_STACK | E_ZONE | E_ACCOUNT",
  "status": <http_code>,
  "remediation": "<concrete next step>",
  "stack": "<stack-key>",
  "path": "<file-path>"
}
```

On partial success: stdout has partial JSON, stderr has the per-call error, exit non-zero.

## `cfsec.detect`

```json
{
  "schema": "cfsec.detect", "schema_version": 1, "generated_at": "...", "tool": "detect",
  "cwd": "/abs/path",
  "project_kind": "workers | pages | node | php | ruby | python | dotnet | jvm | go | rust | unknown",
  "stacks": ["nextjs", "laravel", ...],
  "wrangler_configs": ["wrangler.toml", "wrangler.auth.jsonc", ...],
  "databases": ["mysql", "postgres", "mongodb", "redis", "sqlite", "mssql", "oracle"],
  "object_storage": ["s3", "gcs", "azure-blob"],
  "native_deps": ["sharp", "canvas", "bcrypt", "puppeteer", "playwright", "ffmpeg"],
  "background_workers": ["queue-lib", "sidekiq", "celery"],
  "websockets": true | false,
  "ai_providers": ["openai", "anthropic", "google-gemini", "cohere", "replicate", ...],
  "vector_dbs": ["pinecone", "weaviate", "qdrant", "chroma", "upstash-vector"],
  "embedding_calls": true | false,
  "headless_browser": true | false,
  "package_managers": ["npm", "yarn", "pnpm", "bun", "composer", "bundler", ...],
  "current_host_provider": "vercel | netlify | fly | railway | render | gae | heroku-style | cloudflare | null",
  "hostnames": ["example.com", "api.example.com"]
}
```

Offline. Never makes API calls.

## `cfsec.state-zone.*`

`state zone [zone-id] [slice]` — slice ∈ `digest` (default) | `dns` | `rulesets` | `firewall` | `full`. Always digest first.

Digest (`cfsec.state-zone.digest`):

```json
{
  "schema": "cfsec.state-zone.digest", ..., "slice": "digest", "zone_id": "...",
  "zone": { "id", "name", "status", "plan_tier", "account_id", "account_name", "name_servers", "paused" },
  "settings": {
    "ssl": "off|flexible|full|strict|strict_origin",
    "min_tls_version": "1.0|1.1|1.2|1.3",
    "tls_1_3": "on|off", "always_use_https": "on|off",
    "automatic_https_rewrites": "on|off", "opportunistic_encryption": "on|off",
    "security_header": { "strict_transport_security": { "enabled", "max_age", "include_subdomains", "preload", "nosniff" } },
    "http3": "on|off", "0rtt": "on|off", "tls_client_auth": "on|off",
    "bot_fight_mode": "on|off", "browser_check": "on|off",
    "email_obfuscation": "on|off", "security_level": "...", "...": "..."
  },
  "dnssec": { "status", "key_tag", "algorithm", "ds" },
  "ssl_verification": [ ... ],
  "dns_summary": { "total", "proxied", "dns_only", "types": {"A":n,"AAAA":n,...},
                   "sample": [{type,name,content,proxied}] },
  "rulesets_summary": [ {name, kind, phase, version, description} ],
  "firewall_summary": { "total", "by_mode": {block:n,...}, "by_target": {ip:n,...} },
  "hint": "for full data, run: state zone <zone-id> [dns|rulesets|firewall|full]"
}
```

Slices:
- `cfsec.state-zone.dns`: `{..., dns_records: [{type,name,content,proxied,ttl,comment}]}`
- `cfsec.state-zone.rulesets`: `{..., rulesets: [...full ruleset payloads...]}`
- `cfsec.state-zone.firewall`: `{..., firewall_access_rules: [...]}`
- `cfsec.state-zone.full`: every section combined (heaviest — exports only)

## `cfsec.state-account.*`

`state account [account-id] [slice]` — slice ∈ `digest` (default) | `members` | `tokens` | `audit` | `full`.

Digest (`cfsec.state-account.digest`):

```json
{
  "schema": "cfsec.state-account.digest", ..., "slice": "digest", "account_id": "...",
  "account": { "id", "name", "type" },
  "members_summary": { "total", "with_2fa", "without_2fa", "without_2fa_emails": [...] },
  "tokens_summary":  { "total", "active", "no_expiry", "expiring_30d", "with_ip_restriction", "names": [...] },
  "notification_summary": { "total", "enabled", "alert_types": [...] },
  "audit_log_recent_count": n,
  "audit_log_action_types_recent": [...],
  "hint": "for full data, run: state account <account-id> [members|tokens|audit|full]"
}
```

Slices:
- `cfsec.state-account.members`: full `members[]` with email, 2FA flag, role names.
- `cfsec.state-account.tokens`: full `tokens[]` (no `value` ever; `has_ip_restriction` boolean).
- `cfsec.state-account.audit`: full `audit_log_recent[]`.
- `cfsec.state-account.full`: every section combined.

## `cfsec.state-tunnels` / `cfsec.state-access` / `cfsec.state-pageshield`

- Tunnels: `{ ..., "tunnels": [...] }`. Credential fields stripped.
- Access: `{ ..., "apps": [...], "service_tokens": [...] }`. `client_secret` stripped.
- Page Shield: `{ ..., "enabled", "scripts": [...], "locked": "pro" | null }`. Below Pro: `locked: "pro"` and `enabled: null`.

## `cfsec.analytics-zone`

```json
{
  "schema": "cfsec.analytics-zone", ..., "tool": "analytics-zone",
  "zone_id": "...", "window": "1h | 24h | 7d",
  "totals": { "requests", "threats", "cached_requests", "cache_hit_rate" },
  "top_countries": [ { "name", "code", "requests" } ],
  "top_asns":      [ { "asn", "name", "requests" } ],
  "top_paths":     [ { "path", "requests" } ],
  "colo_distribution": [ { "colo", "requests" } ]
}
```

If GraphQL Analytics unavailable on the user's plan: stdout has the header with empty arrays + zero totals + `"error": "graphql-unavailable"`; stderr describes why.

## `cfsec.events-zone`

```json
{
  "schema": "cfsec.events-zone", ..., "tool": "events-zone",
  "zone_id": "...", "window": "1h | 24h | 7d",
  "events": [
    { "datetime", "action", "source", "ruleId", "clientIP", "clientCountryName",
      "clientASN", "userAgent", "clientRequestPath", "clientRequestHTTPHost",
      "clientRequestHTTPMethodName", "rayName" }
  ]
}
```

## `cfsec.fit-matrix` / `cfsec.fit-matrix-entry`

```json
{ "schema": "cfsec.fit-matrix", ..., "tool": "fit-matrix", "matrix": { "<stack>": { ... } } }
{ "schema": "cfsec.fit-matrix-entry", ..., "tool": "fit-matrix", "stack": "...",
  "entry": { "verdict": "strong | partial | proxy-only | not-recommended",
             "recommended_path": "...", "caveats": [...], "dependencies_to_flag": [...] } }
```

Errors: `E_TEMPLATE` if `templates/migration-fit-matrix.json` missing. `E_UNKNOWN_STACK` if stack key not in matrix.

## `cfsec.stack-docs` / `cfsec.stack-docs-entry`

```json
{ "schema": "cfsec.stack-docs", ..., "tool": "stack-docs", "registry": { "<stack>": { ... } } }
{ "schema": "cfsec.stack-docs-entry", ..., "tool": "stack-docs", "stack": "...",
  "entry": { "framework_docs": [...], "cloudflare_docs": [...], "security_advisories": [...] } }
```

`WebFetch` `entry.framework_docs` and `entry.cloudflare_docs` for fresh ground truth.

## `cfsec.score`

```json
{ "schema": "cfsec.score", ..., "results": {
    "<host>": { "ssllabs": { "grade": "A+", "endpoints": [...] },
                "mdn_observatory": { "grade": "A+", "score": 100, "tests_failed": 0 },
                "security_headers_local": { "grade": "A", "present": 6, "of": 6 },
                "hsts_preload": { "status": "preloaded | unknown", "header_eligible": true } } } }
```

Sub-checks may emit `null` if a third-party API is unreachable; retry.

## Audit lenses (`audit <lens>`)

Cross-cutting security lenses. Read-only JSON. The **locked convention** (one
field, four states) lets `audit all` and the agent render gated surfaces as
neutral ⚪️ N/A rows without dropping them:

`"locked": "<tier>" | "not-configured" | "mcp-absent" | null`
— a plan tier (`enterprise|business|pro`), present-but-unconfigured, the backing
MCP isn't loaded, or not gated. Precedent: `cfsec.state-pageshield` (`locked:"pro"`).
Emitted by `emit_locked_doc` (curl lenses) or the delegation pointer (MCP lenses).

### `cfsec.audit-auditlog`
```json
{ "schema":"cfsec.audit-auditlog", ..., "account_id","window","since",
  "total": n, "by_action_type": {"<type>": n},
  "by_actor": [{"email","type","count"}], "top_actor_ips": [{"ip","count"}],
  "sensitive_events": [{"when","action_type","result","actor_email","actor_type","actor_ip","interface","resource_type"}] }
```
Window 24h|7d|30d. 403 ⇒ stderr E_API (token needs Account Audit Logs Read) + zero-stub.

### `cfsec.audit-logpush`  (Enterprise → `locked:"enterprise"`)
```json
{ "schema":"cfsec.audit-logpush", ..., "account_id","zone_id","locked":null,
  "jobs": [{"id","dataset","scope","enabled","frequency","last_complete","last_error",
            "filter_present","destination_redacted","destination_has_secret"}],
  "coverage": {"datasets_shipped":[...],"security_datasets":[...],"missing_security_datasets":[...]} }
```
Destinations redacted (creds stripped). 403/404 ⇒ `{locked:"enterprise","jobs":[],"coverage":null}`.

### `cfsec.audit-dns`
```json
{ "schema":"cfsec.audit-dns", ..., "zone_id","window","since","until",
  "settings": {"foundation_dns","multi_provider","secondary_overrides","zone_mode","nameservers","ns_ttl"},
  "analytics": {"total_queries","by_response_code":[{"code","count"}],"nxdomain_rate","servfail_rate",
                "by_query_type":[{"type","count"}],"top_query_names":[{"name","count"}]} }
```
`settings.*` are bare values (a meaningful `false` is preserved). If GraphQL
unavailable: `analytics:null` + `analytics_error:"graphql-unavailable"`.

### `cfsec.audit-ai-gateway`  (no gateway → `locked:"not-configured"`)
```json
{ "schema":"cfsec.audit-ai-gateway", ..., "account_id","locked":null,
  "gateways": [{"id","collect_logs","log_management","rate_limiting_enabled","rate_limiting_limit",
                "rate_limiting_technique","authentication_enabled","caching_enabled","cache_ttl","logpush_enabled"}] }
```
Config flags only — never log bodies (PII). 403 ⇒ stderr E_API (AI Gateway Read).

### `cfsec.audit-secevents`
```json
{ "schema":"cfsec.audit-secevents", ..., "zone_id","window","since","until",
  "totals": {"events","blocked","challenged","other"},
  "by_action":[{"action","count"}], "by_source":[{"source","count"}],
  "top_rules":[{"rule_id","source","count"}], "by_country":[{"country","count"}], "by_host":[{"host","count"}] }
```
GraphQL stub-on-error like `cfsec.analytics-zone`.

### `cfsec.audit-delegated`  (MCP-backed lenses: casb/dex/builds/browser/observability)
```json
{ "schema":"cfsec.audit-delegated", ..., "lens","mode":"mcp",
  "mcp_present": true|false, "locked": null|"mcp-absent",
  "requires":"...", "recipe":"references/32-mcp-surfaces.md#<lens>",
  "reference":"references/<doc>.md", "install_hint":"..." }
```
No findings computed in bash; the agent runs the recipe in `32-mcp-surfaces.md`.

### `cfsec.audit-all`  (master report envelope)
```json
{ "schema":"cfsec.audit-all", ..., "account_id","zone_id",
  "render_order": ["edge/external","zone-dns-tls-waf","origin","workers/builds","storage",
                   "ai","zero-trust","casb","logging/observability","account"],
  "lenses":    [{"order","lens","status":"ok|locked|error","doc": {...}}],
  "delegated": [ <cfsec.audit-delegated> ],
  "compose_also": [{"section","tool","why"}],
  "note":"render per 30-recipes.md#full-stack-audit; locked/mcp-absent = neutral ⚪️ N/A" }
```
Thin orchestrator: runs the five curl lenses, attaches delegation pointers, lists
existing tools (`score`, `state zone/account`, `analytics`, MCP storage/workers)
to compose the remaining sections. Does **not** run `score` (slow) inline.

## Mutating tools

`fix <area>` and `panic <action>` emit `OK / WARN / FAIL` badges to stdout, plus per-API-call records to `.state/api-calls.log`. Per-action JSON record to `.state/panic-<ts>.json` (panic) or update `.state/findings.tsv` (fix). Idempotent.
