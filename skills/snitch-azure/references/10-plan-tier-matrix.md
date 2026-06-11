# Plan / SKU / License gating

`snitch-azure` flags features needing a paid plan/SKU/license as `[locked: <tier>+]`.

| Feature | Tier | Cost | Why |
|---|---|---|---|
| Defender for VMs (host threat detection, JIT, FIM) | `defender-standard` | ~$15/VM/mo | Compliance + internet-facing VMs |
| Defender for App Services | `defender-standard` | ~$0.02/vCore-hr | Web shell + brute-force |
| Defender for Storage (anomaly + malware scan) | `defender-standard` | ~$10/account + per-GB | Exfiltration |
| Defender for SQL | `defender-standard` | ~$15/server/mo | VA + ATP for SQLi |
| Defender for Key Vault | `defender-standard` | ~$2/vault/mo | Anomalous access |
| Defender for Resource Manager | `defender-standard` | ~$4/sub/mo | Malicious mgmt ops |
| Defender for DNS | `defender-standard` | ~$0.70/M queries | DNS exfil |
| Defender for Containers | `defender-standard` | ~$7/vCore/mo | Cluster runtime + image scanning |
| PIM (JIT elevation) | `entra-p2` | ~$9/user/mo | JIT admin; SOC 2 friendly |
| Conditional Access | `entra-p1` | ~$6/user/mo | Block legacy auth, MFA, device compliance |
| Identity Protection | `entra-p2` | (P2 includes) | Risky sign-in detection |
| Microsoft Sentinel | `sentinel` | ~$2-5/GB | SIEM/SOAR |
| App Gateway WAF v2 | `appgw-waf-v2` | ~$0.25/hr + per-CU | OWASP + custom rules |
| Front Door Premium | `frontdoor-premium` | ~$330/mo + per-GB | Private endpoint origins, bot mgmt |
| Key Vault Premium (HSM) | `keyvault-premium` | ~$1/key/mo + ops | FIPS 140-2 Level 2 |
| App Service Premium V3 | `appservice-premium` | varies | Zone-redundant, larger SKUs, VNet on isolated workloads |

## How `requires_tier` works

Each `*_run` calls `requires_tier <area> <key> <message> <required_tier> <docs_url>` before a paid-only check. If matched, check proceeds. Otherwise logs `[N/A locked: <tier>+]`.

Detection caveat: reliably detects Defender plans (`az security pricing show`). Entra license, App Service SKU, Front Door tier — gating logs `[N/A locked: <tier>+]` with: "license tier could not be determined from `az` alone."

Override: `AZSEC_FORCE_PAID=1` (testing only).

## Free things to always do

- HTTPS-only on Storage / App Service.
- Min TLS 1.2 everywhere.
- RBAC on Key Vault.
- Soft delete on Key Vault and Recovery Services Vaults.
- Activity log → Log Analytics.
- Disable SCM basic auth on App Service.
- Disable shared-key auth on Storage (where compatible).
- NSG deny-by-default with explicit allow-list.
- Subscription `CanNotDelete` lock on prod.
- Required-tag policy.
