# Migration to Azure

## Verdicts (from `fit-matrix`)

| Verdict | Meaning |
|---|---|
| `strong` | Azure has a first-class managed offering. Deploy directly. |
| `partial` | Works with caveats; expect rewriting auth, sessions, storage drivers. |
| `proxy-only` | Keep origin; Front Door / App Gateway in front. |
| `not-recommended` | Azure has no good landing; consider another cloud. |

Most server-side stacks (Express, Fastify, NestJS, Laravel, Rails, Django, Flask, FastAPI, Spring Boot, .NET) get `strong` — App Service Linux + Container Apps run them directly. Static sites: Static Web Apps. DB-heavy: managed Postgres / MySQL / SQL / Cosmos.

## App Service path

1. Container image OR App Service runtime (Node 20, Python 3.11, .NET 8, Java 17, PHP 8.2, Ruby 3.x).
2. `az webapp create --plan <asp> --name <app> --runtime <stack>`.
3. App Settings via Key Vault references (NEVER plaintext).
4. MI on the app, granted RBAC for SQL / Storage / KV.
5. Custom domain + managed SSL: `az webapp config ssl bind --certificate-source ManagedCertificate`.
6. Slot blue-green: `staging` → swap to `production`.
7. Front Door / App Gateway in front for WAF + global routing.

## Container Apps path

1. Build to ACR.
2. `az containerapp create --image <acr>.azurecr.io/<repo>:<tag> --target-port 80 --ingress external`.
3. Bind MI for ACR pulls + KV secrets.
4. Internal-only ingress when behind APIM / Front Door.

## DB migration

| From | To | How |
|---|---|---|
| MySQL | Azure DB for MySQL Flexible | `mysqldump` + restore, or DMS (online) |
| PostgreSQL | Azure DB for PostgreSQL Flexible | `pg_dump` + restore, or DMS (online) |
| SQL Server | Azure SQL or SQL Managed Instance | DMS online (MI preserves more features) |
| MongoDB | Cosmos for MongoDB API OR MongoDB Atlas on Azure | Atlas safer for complex aggregations |
| Redis | Azure Cache for Redis | direct |

## Storage migration

| From | To | How |
|---|---|---|
| S3 | Azure Blob | `azcopy sync` or AWS DataSync; `@azure/storage-blob` SDK |
| GCS | Azure Blob | `azcopy copy --recursive --source <gcs-url> --destination <azure-url>` |

## DNS cutover

1. Lower TTL to 300s, 24h ahead.
2. Validate Azure target at the new hostname.
3. Update primary record (A / CNAME / ALIAS) → Azure.
4. Watch traffic + errors for 30 min.
5. Roll back by reverting record (TTL 300s = ≤5 min impact).

## Cost realism

| Cost | Estimate |
|---|---|
| Defender Standard, 50-VM prod with App Services | ~$1500/mo |
| Front Door Premium base | $330/mo + bandwidth |
| Log Analytics ingestion (chatty cluster) | up to $5K/mo (set daily cap) |
| Sentinel | $2-5/GB ingested (pre-filter) |

End every plan with: cost estimate, DNS cutover, rollback path.
