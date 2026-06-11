# Tool contracts — JSON schemas every read tool returns

Each `snitch-flyio.sh` read tool emits one JSON document on stdout with a stable header. Errors go to stderr as JSON `{error, code, ...}` with non-zero exit. Mutating tools (`fix`, `panic`) emit `OK / WARN / FAIL` badges instead of JSON.

## Common header

```json
{
  "schema": "flysec.<name>",
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
  "code": "E_AUTH | E_API | E_USAGE | E_TEMPLATE | E_UNKNOWN_STACK | E_TOOL | E_APP | E_ORG",
  "status": <http_code>,            // optional, when E_API
  "remediation": "<concrete next step>",
  "stack": "<stack-key>",          // optional, for E_UNKNOWN_STACK
  "path": "<file-path>"            // optional, for E_TEMPLATE
}
```

On partial success: stdout has partial JSON, stderr has the per-call error, exit is non-zero.

## `flysec.detect`

```json
{
  "schema": "flysec.detect", "schema_version": 1, "generated_at": "...", "tool": "detect",
  "cwd": "/abs/path",
  "project_kind": "fly | docker | node | python | ruby | elixir | go | rust | dotnet | jvm | unknown",
  "stacks": ["phoenix-elixir", "rails", ...],
  "fly_configs": ["fly.toml", "apps/api/fly.toml", ...],
  "databases": ["mysql", "postgres", "mongodb", "redis", "sqlite"],
  "object_storage": ["s3", "tigris", "gcs", "azure-blob"],
  "native_deps": ["sharp", "canvas", "bcrypt", "ffmpeg"],
  "background_workers": ["sidekiq", "celery", "queue-lib"],
  "websockets": true | false,
  "ai_providers": ["openai", "anthropic", ...],
  "vector_dbs": ["pinecone", "weaviate", "qdrant", "chroma"],
  "embedding_calls": true | false,
  "headless_browser": true | false,
  "package_managers": ["npm", "yarn", "pnpm", "bun", "mix", "bundler", ...],
  "current_host_provider": "fly" | "vercel" | "netlify" | "railway" | "render" | "cloudflare" | null,
  "hostnames": ["example.com", "api.example.com"]
}
```

Offline. Never makes API calls.

## `flysec.state-*` (digest is default; slice on request)

`state <subscope> [slice]` — slice ∈ `digest` (default) | section-specific | `full`. Always digest first; fetch a slice only when the digest signals investigation.

### `state account [slice]`
Slices: `digest` | `members` | `tokens` | `audit` | `full`.

Digest (`flysec.state-account.digest`):
```json
{
  "schema": "flysec.state-account.digest", ..., "slice": "digest",
  "org": { "slug", "name", "type", "plan_tier" },
  "members_summary": { "total", "owners", "non_owners" },
  "tokens_summary":  { "total", "deploy", "admin", "expiring_30d", "no_expiry", "unused_90d" },
  "billing_summary": { "current_month_estimate", "alerts_configured" },
  "hint": "for full data: state account [members|tokens|audit|full]"
}
```

### `state apps [slice]`
Slices: `digest` | `services` | `secrets-meta` | `regions` | `full`.

Digest (`flysec.state-apps.digest`):
```json
{
  "schema": "flysec.state-apps.digest", ..., "slice": "digest",
  "apps": [
    { "name", "status", "deployed", "primary_region", "regions": [...],
      "force_https", "internal_only_services": n, "public_services": n,
      "machines": n, "volumes": n, "secrets_count": n }
  ],
  "summary": { "total", "with_force_https", "without_force_https",
               "with_public_tcp", "with_internal_only" }
}
```

### `state machines [slice]`
Slices: `digest` | `images` | `health-checks` | `full`.

Digest:
```json
{
  "schema": "flysec.state-machines.digest", ..., "slice": "digest",
  "machines": [
    { "id", "app", "region", "state", "image_ref", "image_age_days",
      "cpu_kind", "cpu_count", "mem_mb", "restart_policy",
      "health_checks": n, "auto_destroy" }
  ],
  "summary": { "total", "stale_image_30d", "no_health_checks", "gpu" }
}
```

### `state volumes [slice]`
Slices: `digest` | `snapshots` | `full`.

Digest:
```json
{
  "schema": "flysec.state-volumes.digest", ..., "slice": "digest",
  "volumes": [
    { "id", "app", "name", "region", "size_gb", "encrypted",
      "snapshot_retention_days", "attached_machine" }
  ],
  "summary": { "total", "unencrypted", "no_snapshots", "no_retention" }
}
```

### `state postgres [slice]`
Slices: `digest` | `clusters` | `users` | `full`.

Digest:
```json
{
  "schema": "flysec.state-postgres.digest", ..., "slice": "digest",
  "clusters": [
    { "app", "version", "version_eol", "primary_region", "replicas": n,
      "backups_enabled", "backup_retention_days", "attached_apps": [...] }
  ],
  "summary": { "total", "eol_versions", "no_backups", "single_region" }
}
```

### `state redis [slice]`
Slices: `digest` | `databases` | `full`. Fly Redis ≈ Upstash; `state redis` lists database metadata only.

```json
{
  "schema": "flysec.state-redis.digest", ..., "slice": "digest",
  "databases": [
    { "name", "region", "tls_only", "auth_required", "eviction" }
  ],
  "summary": { "total", "without_tls", "without_auth" }
}
```

### `state secrets [slice]`
Slices: `digest` | `names` | `full`. Names only — values never readable via API.

Digest:
```json
{
  "schema": "flysec.state-secrets.digest", ..., "slice": "digest",
  "apps": [
    { "name", "secrets": n, "names": ["DATABASE_URL", "JWT_SECRET", ...],
      "env_in_fly_toml": n, "env_keys_looking_secret": ["..."] }
  ],
  "summary": { "total_apps", "apps_with_plaintext_secret_in_env": n }
}
```

### `state services [slice]`
Slices: `digest` | `http` | `tcp` | `full`.

Digest:
```json
{
  "schema": "flysec.state-services.digest", ..., "slice": "digest",
  "services": [
    { "app", "protocol", "internal_port", "ports": [...], "force_https",
      "auto_stop", "min_machines_running", "checks": [...] }
  ],
  "summary": { "total", "public_tcp", "without_force_https", "without_checks" }
}
```

### `state network [slice]`
Slices: `digest` | `wireguard` | `ips` | `full`.

```json
{
  "schema": "flysec.state-network.digest", ..., "slice": "digest",
  "wireguard_peers": n,
  "public_ipv4": [...], "public_ipv6": [...],
  "private_apps": n,
  "ips_summary": { "static": n, "shared": n, "dedicated": n }
}
```

### `state tokens [slice]`
Slices: `digest` | `org` | `app` | `deploy` | `full`.

```json
{
  "schema": "flysec.state-tokens.digest", ..., "slice": "digest",
  "tokens": [
    { "id", "name", "scope": "org|app|deploy", "app",
      "expires_at", "ip_restriction", "last_used_at" }
  ],
  "summary": { "total", "expiring_30d", "no_expiry", "no_ip_restriction", "unused_90d" }
}
```

### `state cost [slice]`
Slices: `digest` | `apps` | `gpu` | `full`.

```json
{
  "schema": "flysec.state-cost.digest", ..., "slice": "digest",
  "current_month_estimate_usd": n,
  "by_app": [{ "app", "estimate_usd" }],
  "drivers": { "machine_hours": n, "volume_gb_months": n,
               "egress_gb": n, "gpu_minutes": n, "ip_static": n },
  "alerts_configured": true | false
}
```

## `flysec.fit-matrix` / `flysec.fit-matrix-entry`

```json
{ "schema": "flysec.fit-matrix", ..., "tool": "fit-matrix", "matrix": { "<stack>": { ... } } }
{ "schema": "flysec.fit-matrix-entry", ..., "tool": "fit-matrix", "stack": "...",
  "entry": { "verdict": "strong | partial | proxy-only | not-recommended",
             "recommended_path": "...",
             "caveats": [ "..." ],
             "dependencies_to_flag": [ "..." ] } }
```

Errors: `E_TEMPLATE` if `templates/migration-fit-matrix.json` missing. `E_UNKNOWN_STACK` if the stack key is not in the matrix.

## `flysec.stack-docs` / `flysec.stack-docs-entry`

```json
{ "schema": "flysec.stack-docs", ..., "tool": "stack-docs", "registry": { "<stack>": { ... } } }
{ "schema": "flysec.stack-docs-entry", ..., "tool": "stack-docs", "stack": "...",
  "entry": { "framework_docs": [...], "fly_docs": [...], "security_advisories": [...] } }
```

`WebFetch` `entry.framework_docs` and `entry.fly_docs` for fresh ground truth.

## `flysec.score`

```json
{ "schema": "flysec.score", ..., "results": {
    "<host>": { "ssllabs": { "grade": "A+", "endpoints": [...] },
                "mozilla_observatory": { "grade": "A+", "score": 100 },
                "securityheaders": { "grade": "A" },
                "hsts_preload": { "status": "preloaded | eligible | not-eligible" } } } }
```

Sub-checks may emit `null` if a third-party API is unreachable; the agent can retry.

## Mutating tools

`fix <area>` and `panic <action>` emit human-readable `OK / WARN / FAIL` badges to stdout, plus per-call records to `.state/api-calls.log`. They write per-action JSON records to `.state/panic-<ts>.json` (panic) or update `.state/findings.tsv` (fix). Idempotent: re-running is safe.
