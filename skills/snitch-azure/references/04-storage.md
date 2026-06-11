# Storage Accounts

## Targets

| Setting | Target | Why |
|---|---|---|
| `enableHttpsTrafficOnly` | `true` | HTTP rejected |
| `minimumTlsVersion` | `TLS1_2` (or 1.3) | Reject weak ciphers |
| `allowBlobPublicAccess` | `false` | No anonymous container access |
| `allowSharedKeyAccess` | `false` (when feasible) | Force AAD; some legacy SDKs break |
| `networkRuleSet.defaultAction` | `Deny` | Allowlist VNets / IPs |
| `encryption.keySource` | `Microsoft.Keyvault` (CMK) | Customer-managed for regulated |
| `requireInfrastructureEncryption` | `true` | Two layers at rest |

## Soft delete (enable all three)

| Layer | Recovers |
|---|---|
| Blob soft delete | deleted blobs (1-365d retention) |
| Container soft delete | deleted containers |
| Versioning | overwrites |

## Immutable storage

Time-based or legal-hold policies. Locked policies cannot be removed. Surface as `[paid: container-tier]`.

## SAS

- Prefer **user delegation SAS** (AAD-signed) over **account SAS** (shared-key-signed). With `allowSharedKeyAccess=false`, account SAS is impossible.
- IP-restrict + HTTPS-only.
- ≤ 1 hour for sensitive data.

## Lifecycle

Hot → Cool (30d) → Archive (90d). Lifecycle rules don't apply to versions automatically — opt in.

## Common findings

| Finding | Severity | Fix |
|---|---|---|
| HTTPS not enforced | FAIL | `fix storage` (`--https-only true`) |
| Min TLS < 1.2 | FAIL | `fix storage` (`--min-tls-version TLS1_2`) |
| Public blob access enabled | FAIL | `fix storage` |
| Shared-key auth enabled | WARN | Confirm, then disable (legacy SDKs may break) |
| Default network = Allow | WARN | Switch to Deny + allowlist; `fix` warns |
| No CMK | WARN | Out of scope for `fix`; emits guidance |
| Soft delete off | WARN | `fix storage` enables 14d blob soft-delete |

## Docs

- Secure transfer: https://learn.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer
- Network security: https://learn.microsoft.com/en-us/azure/storage/common/storage-network-security
- Soft delete: https://learn.microsoft.com/en-us/azure/storage/blobs/soft-delete-blob-overview
- Immutable: https://learn.microsoft.com/en-us/azure/storage/blobs/immutable-storage-overview
