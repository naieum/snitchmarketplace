# Compute on Azure

## Virtual Machines

| Setting | Target |
|---|---|
| Encryption at host | on |
| Just-In-Time access | Defender for VMs; no static SSH/RDP rules |
| Update Manager | patch compliance |
| Boot diagnostics | Storage account or managed-storage |
| Trusted Launch | Secure Boot + vTPM (Gen2 only) |
| Public IPs on prod | none; use Bastion or VPN/ExpressRoute |

## App Service

| Setting | Target |
|---|---|
| `httpsOnly` | `true` |
| `siteConfig.minTlsVersion` | `1.2` |
| `siteConfig.ftpsState` | `Disabled` |
| SCM basic auth | `Microsoft.Web/sites/basicPublishingCredentialsPolicies/scm` `allow=false` |
| Identity | system-assigned MI + `Key Vault Secrets User` |
| AAD | Easy Auth (Authentication V2) |
| IP restrictions | enabled on prod |
| Slots | blue/green; secrets distinct per slot |

## Functions

Same hardening as App Service. Plus:

- Authorization-level: `function` (default) → `anonymous` only behind APIM/Front Door with auth.
- `AzureWebJobsStorage__accountName` (MI) instead of connection string.
- Premium plan for VNet integration; Consumption can't have private endpoints to Storage.

## AKS

| Setting | Target |
|---|---|
| AAD-integrated | `aadProfile.managed=true` |
| Azure RBAC for K8s | `enableAzureRBAC=true` |
| Private cluster | `enablePrivateCluster=true` OR `authorizedIpRanges` allowlist |
| Network Policy | `networkProfile.networkPolicy=calico|azure` |
| Defender for Containers | `securityProfile.defender` |
| Container Insights | `addonProfiles.omsagent.enabled=true` |
| KV Secrets Provider CSI | enabled |
| Workload Identity | federated |
| Image registry | ACR with Defender vulnerability scanning |

## Container Apps

- MI per app for ACR pulls + outbound auth.
- Internal-only ingress when behind APIM / Front Door.
- Min replicas > 0 for prod; min = 0 only for batch (cold start).
- Dapr: scope ACL for service-to-service.

## Common findings

| Finding | Severity | Fix |
|---|---|---|
| App Service HTTPS-only off | FAIL | `fix appservice` |
| App Service min TLS < 1.2 | FAIL | `fix appservice` |
| App Service FTPS allowed | WARN | `fix appservice` |
| App Service SCM basic auth allowed | FAIL | `fix appservice` (REST) |
| App Service no MI | WARN | `az webapp identity assign` |
| Function app no identity | WARN | `az functionapp identity assign` |
| AKS public API server, no IP allowlist | FAIL | Private cluster or authorized IPs |
| AKS no AAD integration | FAIL | Recreate with AAD-managed (immutable) |
| AKS no Network Policy | WARN | Recreate (set at create time) |
| VM with public IP, no Bastion | WARN | Move behind Bastion |

## Docs

- App Service TLS: https://learn.microsoft.com/en-us/azure/app-service/overview-tls
- App Service basic-auth: https://learn.microsoft.com/en-us/azure/app-service/configure-basic-auth-disable
- AKS security: https://learn.microsoft.com/en-us/azure/aks/concepts-security
- Functions: https://learn.microsoft.com/en-us/azure/azure-functions/security-concepts
- Container Apps: https://learn.microsoft.com/en-us/azure/container-apps/managed-identity
