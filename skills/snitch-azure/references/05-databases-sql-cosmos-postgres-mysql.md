# Databases on Azure

## Azure SQL

| Target | Setting |
|---|---|
| `minimalTlsVersion` | `1.2` (or 1.3) |
| AAD-only | set AAD admin → `azureAdOnlyAuthentication=true` |
| TDE | every DB (Microsoft-managed default; CMK via KV for regulated) |
| Defender for SQL | paid; VA + ATP. Recommended for prod |
| Auditing | LA workspace + Storage |
| `publicNetworkAccess` | `Disabled` + private endpoint |
| Firewall rules | no `0.0.0.0` / `0.0.0.0-255.255.255.255` |

## Cosmos DB

| Target | Setting |
|---|---|
| `disableLocalAuth` | `true` |
| `minimalTlsVersion` | `Tls12` (or Tls13) |
| `publicNetworkAccess` | `Disabled` + private endpoint |
| CMK | `keyVaultKeyUri` |
| IP firewall + VNet ACLs | enabled |
| Continuous backup | with PITR |

## PostgreSQL Flexible

| Target | Setting |
|---|---|
| `network.publicNetworkAccess` | `Disabled` (VNet-integrated) |
| `authConfig.activeDirectoryAuth` | `Enabled` |
| `dataEncryption.type` | `AzureKeyVault` |
| `backup.geoRedundantBackup` | `Enabled` for prod |
| `highAvailability.mode` | `ZoneRedundant` for prod |
| `require_secure_transport` | `ON` |

## MySQL Flexible

Same shape as Postgres Flexible. `require_secure_transport = ON`. AAD via Microsoft Entra integration.

## Cross-cutting

- Connection strings → Key Vault. Apps reference via `@Microsoft.KeyVault(SecretUri=...)`.
- App MI gets `Key Vault Secrets User` + direct DB role.
- No DB password in `local.settings.json` / `appsettings.json` in git.

## Common findings

| Finding | Severity | Fix |
|---|---|---|
| Public network access = Enabled | FAIL | Move to PE, then disable public |
| TLS < 1.2 | FAIL | `fix sql` / `fix cosmos` |
| No AAD admin (SQL) | FAIL | `az sql server ad-admin create` |
| Local auth enabled (Cosmos) | WARN | After AAD wired: `--disable-local-auth true` |
| No CMK | WARN | Out of scope for `fix` |
| Defender for SQL = Free | WARN | Recommend Standard for prod |

## Docs

- SQL: https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview
- Cosmos: https://learn.microsoft.com/en-us/azure/cosmos-db/security-baseline
- Postgres Flexible: https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-security
- MySQL Flexible: https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-security
