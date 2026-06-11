# Tool contracts — JSON schemas

Each `snitch-railway.sh` read tool emits exactly one JSON document on stdout with a stable header. Errors go to stderr as JSON with non-zero exit. Mutating tools (`fix`, `panic`) emit `OK / WARN / FAIL` badges instead of JSON.

## Common header

```json
{
  "schema": "rwsec.<name>",
  "schema_version": 1,
  "generated_at": "<ISO8601>",
  "tool": "<subcommand>"
}
```

## Error shape (stderr)

```json
{
  "error": "<short description>",
  "code": "E_AUTH | E_API | E_USAGE | E_TEMPLATE | E_UNKNOWN_STACK | E_PROJECT | E_ENV",
  "status": <http_code>,
  "remediation": "<concrete next step>",
  "stack": "<stack-key>",
  "path": "<file-path>"
}
```

## `rwsec.detect`

```json
{
  "schema": "rwsec.detect", "schema_version": 1, "generated_at": "...", "tool": "detect",
  "cwd": "/abs/path",
  "project_kind": "railway | docker | nixpacks | procfile | node | php | ruby | python | dotnet | jvm | go | rust | elixir | unknown",
  "stacks": ["nextjs", "rails", ...],
  "railway_configs": ["railway.json", ...],
  "nixpacks_config": true|false,
  "procfile": true|false,
  "dockerfile": true|false,
  "railway_env_refs": ["RAILWAY_*_RUNTIME","variable-references","cross-service-references"],
  "databases": ["mysql","postgres","mongodb","redis","sqlite"],
  "object_storage": ["s3","gcs","azure-blob"],
  "native_deps": ["sharp","bcrypt","puppeteer",...],
  "websockets": true|false,
  "ai_providers": ["openai","anthropic",...],
  "vector_dbs": ["pinecone","weaviate","qdrant","chroma"],
  "headless_browser": true|false,
  "package_managers": ["npm","yarn","pnpm","bun","composer","bundler","python","go-modules","cargo","hex"],
  "current_host_provider": "vercel"|"netlify"|"fly"|"railway"|"render"|"gae"|"heroku-style"|null,
  "hostnames": ["yourdomain.com"]
}
```

## State tool slices

| Tool | Slices | Digest contents |
|---|---|---|
| `state workspace` | `digest` (default), `members`, `billing`, `full` | me + teams summary |
| `state project` | `digest`, `environments`, `full` | project meta, environments_summary, services_summary, public_warning if `isPublic` |
| `state services` | `digest`, `full` | total, with_healthcheck, without_healthcheck, builders, with_replicas_gt_1, with_sleep_enabled, sources |
| `state env` | `digest`, `vars`, `full` | counts + classification + warnings + duplicates (no values). `vars` = names + classifications. `full` = raw values (sensitive). |
| `state volumes` | `digest`, `full` | total, total_size_mb, mount_paths, without_backup_warning |
| `state databases` | `digest`, `full` | total, by_kind, eol[], deprecated[], supported[], backup_warning |
| `state tokens` | `digest`, `full` | total, names, per_environment, oldest_created_at. Account tokens best-effort (Railway gates token detail). |
| `state domains` | `digest`, `full` | custom_domain_count, railway_subdomain_count, custom_domain_unverified[], all_custom_domains[] |
| `state tcp-proxies` | `digest`, `full` | services_with_tcp_exposure[], total_proxies. Flag every TCP proxy as a finding — bypasses HTTPS termination. |
| `state logs` | `digest`, `full` | plan, log_retention_estimate, detected_drain_env_vars[], drain_configured |
| `state cost` | `digest`, `full` | plan, sleep_summary, replica_summary, free_tier_exhaustion_warning |

## `rwsec.state-env.*` — env-var classification fields

```json
{
  "total_vars": n,
  "by_classification": { "reference": n, "secret-shaped": n, "normal": n, "empty": n },
  "plaintext_secret_warnings": [{service,name}],
  "reserved_RAILWAY_overrides": [{service,name}],
  "duplicates_across_services": [{name, services, value_classes}],
  "shared_summary": { NAME: classification }
}
```

## `rwsec.state-databases.*` — per-DB entry

```json
{ "service_id", "service_name", "image", "kind", "version", "eol_status": "supported|deprecated|eol|unknown" }
```

## `rwsec.fit-matrix` / `rwsec.fit-matrix-entry`

```json
{ "schema":"rwsec.fit-matrix", ..., "matrix": { "<stack>": {...} } }
{ "schema":"rwsec.fit-matrix-entry", ..., "stack":"...",
  "entry": { "verdict":"strong|partial|not-recommended",
             "recommended_path":"...",
             "caveats":[],
             "dependencies_to_flag":[] } }
```

## `rwsec.stack-docs` / `rwsec.stack-docs-entry`

```json
{ "schema":"rwsec.stack-docs-entry", ..., "stack":"...",
  "entry": { "framework_docs":[], "railway_docs":[], "security_advisories":[] } }
```

## `rwsec.score`

One entry per host with grades from SSL Labs / Mozilla Observatory / hstspreload / securityheaders.

## Mutating tools

`fix <area>` and `panic <action>` emit `OK / WARN / FAIL` badges to stdout, plus per-call records to `.state/api-calls.log`. Per-action JSON record to `.state/panic-<ts>.json` (panic) or update `.state/findings.tsv` (fix). Idempotent: re-running is safe. Token revocation is the only non-reversible action.
