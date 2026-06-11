# Tool contracts — JSON schemas

Each `snitch-aws.sh` read tool emits exactly **one** JSON document on stdout. Errors go to stderr as JSON `{error, code, ...}` with non-zero exit. Mutating tools (`fix`, `panic`) emit `OK / WARN / FAIL` badges to stdout instead of JSON.

## Common header

```json
{
  "schema": "awssec.<name>",
  "schema_version": 1,
  "generated_at": "<ISO8601>",
  "tool": "<subcommand>",
  ...
}
```

## Error shape (stderr)

```json
{
  "error": "<short description>",
  "code": "E_AUTH | E_API | E_USAGE | E_TEMPLATE | E_UNKNOWN_STACK | E_REGION",
  "remediation": "<concrete next step>",
  "stack": "<stack-key>",
  "path": "<file-path>"
}
```

## `awssec.detect`

```json
{
  "schema": "awssec.detect", "schema_version": 1, "generated_at": "...", "tool": "detect",
  "cwd": "/abs/path",
  "project_kind": "node | php | ruby | python | dotnet | jvm | go | rust | unknown",
  "stacks": ["nextjs", "laravel", ...],
  "iac": ["terraform", "terraform-aws-provider", "cdk", "sam", "cloudformation", "serverless-framework", "pulumi", "pulumi-aws", "copilot"],
  "aws_profiles": ["default", "prod-admin", ...],
  "aws_sso_available": true,
  "ecr_pushes": true,
  "databases": ["mysql", "postgres", "mongodb", "redis", "sqlite", "mssql", "oracle", "dynamodb"],
  "object_storage": ["s3", "gcs", "azure-blob"],
  "native_deps": ["sharp", "canvas", "bcrypt", "puppeteer", "playwright", "ffmpeg"],
  "background_workers": ["queue-lib", "sidekiq", "celery"],
  "websockets": true,
  "ai_providers": ["openai", "anthropic", "aws-bedrock", ...],
  "vector_dbs": ["pinecone", "weaviate", "qdrant", "chroma"],
  "embedding_calls": true,
  "headless_browser": true,
  "package_managers": ["npm", "pnpm", ...],
  "current_host_provider": "vercel | netlify | aws | aws-amplify | aws-apprunner | aws-elasticbeanstalk | aws-serverless-framework | cloudflare | null",
  "hostnames": ["api.example.com"]
}
```

Offline. Never makes API calls.

## `awssec.state-<area>.<slice>`

Every state tool emits the common header plus area-specific fields. `digest` is the default with derived signals; area slices and `full` emit raw lists.

| Area | Slices |
|---|---|
| account | digest, password-policy, summary, full |
| iam | digest, users, roles, policies, analyzer, full |
| s3 | digest, buckets, full |
| ec2 | digest, instances, volumes, full |
| vpc | digest, sgs, flow-logs, full |
| rds | digest, instances, clusters, full |
| dynamodb | digest, tables, full |
| lambda | digest, functions, urls, full |
| cloudfront | digest, distributions, full |
| route53 | digest, zones, full |
| acm | digest, certificates, full |
| cognito | digest, pools, full |
| secrets | digest, secrets, parameters, full |
| cloudtrail | digest, trails, full |
| cloudwatch | digest, log-groups, alarms, full |
| wafv2 | digest, acls, full |
| shield | digest, full |
| config | digest, full |
| inspector | digest, full |
| macie | digest, full |
| guardduty | digest, full |
| securityhub | digest, full |
| backup | digest, full |
| kms | digest, keys, full |
| organizations | digest, accounts, scps, full |
| eks | digest, clusters, full |
| ecs | digest, clusters, services, full |
| eventbridge | digest, full |
| sqs-sns | digest, sqs, sns, full |
| cost | digest, full |

Each digest emits a `*_summary` object containing counts + derived signals (e.g., `with_full_pab`, `imdsv2_required`, `customer_keys_without_rotation`). Slices emit raw arrays.

## `awssec.analytics`

```json
{
  "schema": "awssec.analytics", "schema_version": 1, "generated_at": "...", "tool": "analytics",
  "account_id": "...", "region": "...",
  "window": { "window_label": "30d", "start": "...", "end": "..." },
  "total_blended": 1234.56,
  "top_services": [{"service": "...", "total": 0}],
  "regions_enabled": ["us-east-1", ...],
  "anomaly_monitors_count": 0
}
```

## `awssec.events`

```json
{
  "schema": "awssec.events", "schema_version": 1, "generated_at": "...", "tool": "events",
  "account_id": "...", "region": "...",
  "window": { "window_label": "24h", "start": "...", "end": "..." },
  "events": [
    { "EventTime": "...", "EventName": "CreateAccessKey", "Username": "...", "EventSource": "iam.amazonaws.com", "AwsRegion": "us-east-1", "Resources": [...] }
  ]
}
```

## `awssec.fit-matrix` / `awssec.fit-matrix-entry`

```json
{ "schema": "awssec.fit-matrix", ..., "tool": "fit-matrix", "matrix": { "<stack>": { ... } } }
{ "schema": "awssec.fit-matrix-entry", ..., "tool": "fit-matrix", "stack": "...",
  "entry": { "verdict": "strong | partial | proxy-only | not-recommended",
             "recommended_path": "...",
             "caveats": ["..."],
             "dependencies_to_flag": ["..."] } }
```

Errors: `E_TEMPLATE`, `E_UNKNOWN_STACK`.

## `awssec.stack-docs` / `awssec.stack-docs-entry`

```json
{ "schema": "awssec.stack-docs", ..., "tool": "stack-docs", "registry": { "<stack>": { ... } } }
{ "schema": "awssec.stack-docs-entry", ..., "tool": "stack-docs", "stack": "...",
  "entry": { "framework_docs": [...], "aws_docs": [...], "security_advisories": [...] } }
```

## `score` (markdown stdout, not JSON)

Markdown grading table per host: `ssllabs`, `observatory`, `hsts-preload`, `secheaders`. Sub-checks may emit `?` if a third-party API is unreachable.

## Mutating tools

`fix <area>` and `panic <action>` emit `OK / WARN / FAIL` badges to stdout, plus per-CLI-call records to `.state/api-calls.log`. They write per-action JSON records to `.state/panic-<ts>.json` (panic) or update `.state/findings.tsv` (fix). Idempotent — re-running is safe.
