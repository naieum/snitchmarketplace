# Tool contracts

Each read tool emits one JSON document on stdout. Errors → stderr JSON, non-zero exit. `fix` and `panic` emit `OK / WARN / FAIL` badges instead.

## Common header

```json
{ "schema": "dosec.<name>", "schema_version": 1, "generated_at": "<ISO8601>", "tool": "<subcommand>", ... }
```

## Error shape (stderr)

```json
{ "error": "<short>", "code": "E_AUTH | E_API | E_USAGE | E_TEMPLATE | E_UNKNOWN_STACK | E_DOCTL", "status": <http_code>, "remediation": "<next step>" }
```

## `dosec.detect`

Offline. No API calls.

```json
{
  "schema": "dosec.detect", ..., "tool": "detect",
  "cwd": "/abs/path",
  "project_kind": "app-platform | docker | node | php | ruby | python | dotnet | jvm | go | rust | static | unknown",
  "stacks": ["nextjs", "laravel", ...],
  "databases": ["mysql", "postgres", "mongodb", "redis", "sqlite"],
  "object_storage": ["s3", "gcs", "azure-blob", "do-spaces"],
  "native_deps": ["sharp", "canvas", "bcrypt", "puppeteer", "playwright", "ffmpeg"],
  "background_workers": ["queue-lib", "sidekiq", "celery"],
  "websockets": true|false,
  "ai_providers": ["openai", "anthropic", ...],
  "vector_dbs": ["pinecone", ...],
  "headless_browser": true|false,
  "package_managers": ["npm", "pnpm", ...],
  "current_host_provider": "digitalocean | vercel | ... | null",
  "hostnames": ["..."],
  "do_markers": ["app-platform-spec", "terraform-digitalocean", "pulumi-digitalocean", "github-actions-doctl", "docker-do-images"]
}
```

## `dosec.state-account.*`

Slice ∈ `digest | team | tokens | audit | full`.

```json
{
  "schema": "dosec.state-account.digest", ..., "slice": "digest",
  "account": { "email", "uuid", "status", "droplet_limit", "email_verified", ... },
  "account_type": "personal | team",
  "team_summary": { "present": bool, "name", "uuid" },
  "billing_summary": { "month_to_date_balance", "account_balance", "month_to_date_usage" },
  "audit_log_recent_count": <int>,
  "hint": "..."
}
```

## `dosec.state-droplets.*`

```json
{
  "schema": "dosec.state-droplets.digest", ..., "slice": "digest",
  "droplets_summary": {
    "total", "by_region", "by_size",
    "backups_enabled_count", "monitoring_enabled_count", "ipv6_enabled_count",
    "private_networking_count", "public_ipv4_count",
    "sample": [...]
  }
}
```

## `dosec.state-databases.*`

```json
{
  "schema": "dosec.state-databases.digest", ..., "slice": "digest",
  "databases_summary": {
    "total", "by_engine", "by_region",
    "online_count", "private_network_count",
    "trusted_source_coverage": { "total", "with_firewall_rules" },
    "sample": [...]
  }
}
```

## `dosec.state-spaces.*`

Requires `DOSEC_SPACES_KEY` + `DOSEC_SPACES_SECRET`. Without them, returns a payload with a `note`.

```json
{
  "schema": "dosec.state-spaces.digest", ..., "slice": "digest",
  "spaces_summary": { "total", "by_region", "cdn_endpoint_count" },
  "sample": [{name, region, created}]
}
```

## `dosec.state-apps.*`

```json
{
  "schema": "dosec.state-apps.digest", ..., "slice": "digest",
  "apps_summary": {
    "total", "by_region", "by_tier_slug",
    "services_with_health_check", "secrets_count", "plain_envs_count", "domains_total",
    "sample": [...]
  }
}
```

## `dosec.state-loadbalancers.*`

```json
{
  "schema": "dosec.state-loadbalancers.digest", ..., "slice": "digest",
  "loadbalancers_summary": {
    "total", "by_region",
    "https_listener_count", "http_only_count", "redirect_http_to_https_count",
    "sticky_sessions_count", "health_check_configured_count",
    "sample": [...]
  }
}
```

## `dosec.state-firewalls.*`

```json
{
  "schema": "dosec.state-firewalls.digest", ..., "slice": "digest",
  "firewalls_summary": {
    "total", "droplet_attached_count", "tag_scoped_count",
    "inbound_open_world_count", "mgmt_port_open_world_count",
    "sample": [...]
  }
}
```

## `dosec.state-registry.*`

```json
{
  "schema": "dosec.state-registry.digest", ..., "slice": "digest",
  "present": bool, "name", "region", "subscription_tier",
  "repositories_summary": { "total", "total_tags", "sample": [...] }
}
```

## `dosec.state-kubernetes.*`

```json
{
  "schema": "dosec.state-kubernetes.digest", ..., "slice": "digest",
  "clusters_summary": {
    "total", "by_region", "versions",
    "auto_upgrade_count", "surge_upgrade_count", "ha_count",
    "autoscaler_node_pool_count", "sample": [...]
  },
  "latest_versions": [...]
}
```

## `dosec.state-functions.*`

```json
{ "schema": "dosec.state-functions.digest", ..., "functions_summary": { "total_namespaces", "by_region", "sample": [...] } }
```

## `dosec.state-vpcs.*`

```json
{ "schema": "dosec.state-vpcs.digest", ..., "vpcs_summary": { "total", "by_region", "default_count", "public_ip_droplet_count", "sample": [...] } }
```

## `dosec.state-dns.*`

```json
{
  "schema": "dosec.state-dns.digest", ..., "slice": "digest",
  "dns_summary": { "total_domains", "domains": [...], "records_sampled", "a_records", "caa_records", "mx_records", "txt_records" },
  "dnssec_supported": false,
  "dnssec_note": "DigitalOcean managed DNS does NOT support DNSSEC..."
}
```

## `dosec.state-monitoring.*`

```json
{ "schema": "dosec.state-monitoring.digest", ..., "alerts_summary": { "total", "enabled", "by_type", "channels_used", "sample": [...] } }
```

## `dosec.state-cost.*`

```json
{
  "schema": "dosec.state-cost.digest", ..., "slice": "digest",
  "cost_summary": {
    "month_to_date_balance", "account_balance", "month_to_date_usage",
    "recent_invoices": [...], "recent_charges": [...]
  }
}
```

## `dosec.fit-matrix` / `dosec.fit-matrix-entry`

```json
{ "schema": "dosec.fit-matrix", ..., "matrix": { "<stack>": { ... } } }
{ "schema": "dosec.fit-matrix-entry", ..., "stack": "...",
  "entry": { "verdict": "strong | partial | proxy-only | not-recommended",
             "recommended_path": "...",
             "caveats": [...],
             "dependencies_to_flag": [...] } }
```

## `dosec.stack-docs` / `dosec.stack-docs-entry`

```json
{ "schema": "dosec.stack-docs", ..., "registry": { "<stack>": { ... } } }
{ "schema": "dosec.stack-docs-entry", ..., "stack": "...",
  "entry": { "framework_docs": [...], "digitalocean_docs": [...], "security_advisories": [...] } }
```

## `dosec.export`

Combines all digests into one document for snapshotting, diffing, change-tracking.

## Mutating tools

`fix <area>` and `panic <action>` emit `OK / WARN / FAIL` badges to stdout, plus per-API-call records to `.state/api-calls.log`. Panic state lives in `.state/panic-<ts>.json`; fix updates `.state/findings.tsv`. Both idempotent.
