# Secrets — Azure Key Vault

## Hardening

| Setting | Target |
|---|---|
| `enableSoftDelete` | `true` |
| `enablePurgeProtection` | `true` (IRREVERSIBLE — confirm with user) |
| `enableRbacAuthorization` | `true` (RBAC, not legacy access policies) |
| `networkAcls.defaultAction` | `Deny` |
| `publicNetworkAccess` | `Disabled` + private endpoint |

## SKU

| Tier | Capability |
|---|---|
| Standard | software-protected keys |
| Premium | HSM-backed (FIPS 140-2 Level 2). `[locked: keyvault-premium]` |

## RBAC roles

| Role | Use |
|---|---|
| Key Vault Reader | list metadata |
| Key Vault Secrets User | read secret values |
| Key Vault Secrets Officer | manage secrets |
| Key Vault Crypto User | wrap/unwrap, sign/verify |
| Key Vault Certificates Officer | manage certs |

Don't use `Key Vault Administrator` for SPs.

## Rotation

- Auto-rotation policies on keys (`keyvault.rotation_policy`).
- Secrets: app-driven (no built-in auto-rotation except for storage account keys).
- Cert auto-renew: `az keyvault certificate set-attributes` policy.

## App references

- `@Microsoft.KeyVault(SecretUri=https://<vault>.vault.azure.net/secrets/<name>/)`
- Or: `@Microsoft.KeyVault(VaultName=<vault>;SecretName=<name>)`
- App MI needs `Key Vault Secrets User` on the vault.

## Common findings

| Finding | Severity | Fix |
|---|---|---|
| Soft delete off | FAIL | `fix keyvault` |
| Purge protection off | WARN | Confirm (irreversible), then enable |
| Legacy access policy mode | WARN | Migrate to RBAC (reissue principal access) |
| Network default = Allow | WARN | Confirm IP allowlist, then Deny |
| No private endpoint on prod | WARN | Add PE + `publicNetworkAccess=Disabled` |
| Expired keys/certs | WARN | List + rotate |

## Docs

- Security: https://learn.microsoft.com/en-us/azure/key-vault/general/security-features
- Soft delete: https://learn.microsoft.com/en-us/azure/key-vault/general/soft-delete-overview
- RBAC: https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide
- Rotation: https://learn.microsoft.com/en-us/azure/key-vault/keys/how-to-configure-key-rotation
