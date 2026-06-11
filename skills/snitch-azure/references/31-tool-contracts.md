# Tool contracts — JSON schemas

Each `snitch-azure.sh` read tool emits one JSON document on stdout with a stable header. Errors go to stderr as JSON with non-zero exit. `fix` and `panic` emit `OK / WARN / FAIL` badges (not JSON).

## Common header

```json
{
  "schema": "azsec.<name>",
  "schema_version": 1,
  "generated_at": "<ISO8601>",
  "tool": "<subcommand>",
  ...
}
```

## Error shape (stderr)

```json
{
  "error": "<short>",
  "code": "E_AUTH | E_API | E_USAGE | E_TEMPLATE | E_UNKNOWN_STACK | E_SUBSCRIPTION | E_TENANT",
  "remediation": "<concrete next step>",
  "stack": "<stack-key>",
  "path": "<file-path>"
}
```

## `azsec.detect`

Offline. No API calls. Needs `bash` + `jq`.

```json
{
  "schema": "azsec.detect", "schema_version": 1, "generated_at": "...", "tool": "detect",
  "cwd": "/abs/path",
  "project_kind": "node | php | ruby | python | dotnet | jvm | go | rust | azure-functions | azure-static-web-apps | unknown",
  "stacks": ["nextjs", "laravel", ...],
  "iac_signals": ["bicep", "arm-template", "terraform-azurerm", "pulumi-azure", "azure-devops-pipeline", "static-web-apps", "azd", ...],
  "databases": ["mysql", "postgres", "mongodb", "redis", "sqlite", "mssql", "cosmos", "azure-sql"],
  "object_storage": ["s3", "gcs", "azure-blob"],
  "native_deps": [...],
  "background_workers": [...],
  "websockets": true | false,
  "ai_providers": ["openai", "anthropic", "azure-openai", ...],
  "vector_dbs": [..., "azure-ai-search"],
  "embedding_calls": true | false,
  "headless_browser": true | false,
  "package_managers": [...],
  "current_host_provider": "vercel" | "netlify" | "azure" | null,
  "hostnames": [...]
}
```

## `state` digests

Every `state <area>` accepts a slice (`digest` default | `<resource>` | `full`). Digest emits a summary block with counts; `<resource-name>` slice emits per-resource list; `full` emits everything.

| Tool | Slice options | Digest signals |
|---|---|---|
| `state subscription [id]` | `digest` / `locks` / `budgets` / `full` | meta + locks_summary + budgets_summary + owners_summary |
| `state entra` | `digest` / `apps` / `policies` / `full` | users_summary, groups_summary, apps_summary, service_principals_summary, conditional_access_summary |
| `state rbac [scope]` | `digest` / `assignments` / `custom-roles` / `full` | by_role, by_principal_type, owners, contributors |
| `state policy` | `digest` / `assignments` / `compliance` / `full` | initiatives, compliance_state |
| `state defender` | `digest` / `pricing` / `recommendations` / `full` | pricing_summary (Standard vs Free), secure_score, recommendations |
| `state storage / keyvault / vm / appservice / ...` | `digest` / `<resource>` / `full` | per-area counts (`https_only_violations`, `public_access_count`, ...) |

## `azsec.analytics-subscription`

```json
{
  "schema": "azsec.analytics-subscription",
  "subscription_id": "...",
  "window": "1h | 24h | 7d",
  "totals": { "events", "succeeded", "failed", "write", "delete", "action" },
  "top_callers":        [ { "caller", "events" } ],
  "top_operations":     [ { "operation", "events" } ],
  "top_resource_types": [ { "resource_type", "events" } ]
}
```

## `azsec.events-subscription`

```json
{
  "schema": "azsec.events-subscription",
  "subscription_id": "...",
  "window": "1h | 24h | 7d",
  "events": [ { "eventTimestamp", "operationName", "status", "caller", "resourceId", "resourceType", "correlationId", "level" } ]
}
```

## `fit-matrix` / `stack-docs`

Same shape as Cloudflare. Errors: `E_TEMPLATE` if missing, `E_UNKNOWN_STACK` if not in matrix. Agent `WebFetch`es `entry.framework_docs` and `entry.azure_docs`.

## `score`

```json
{ "schema": "azsec.score", ..., "results": {
    "<host>": { "ssllabs": { "grade": "A+" },
                "mozilla_observatory": { "grade": "A+", "score": 100 },
                "securityheaders": { "grade": "A" },
                "hsts_preload": { "status": "preloaded | eligible | not-eligible" } } } }
```

## Mutating tools

`fix <area>` and `panic <action>` emit `OK / WARN / FAIL` badges to stdout, plus per-az-call records to `.state/api-calls.log`. Per-action JSON to `.state/panic-<ts>.json` (panic) or `.state/findings.tsv` (fix). Idempotent: re-running is safe.
