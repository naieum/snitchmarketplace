# Authentication on Azure

## Preferred (in order)

1. **Workload Identity Federation (OIDC)** — CI/CD, Kubernetes, GitHub Actions. No stored secrets.
2. **Managed Identity** — system- or user-assigned. Azure-hosted compute (VM, App Service, Functions, AKS, Container Apps). Token from IMDS; no secrets.
3. **Entra service principal with certificate** — when MI/WIF unavailable. Cert-based, not client-secret.
4. **Entra service principal with client-secret** — last resort. Rotate every 90 days. Refused by `snitch-azure` when MI/WIF is available.

## Refused

`AZURE_CLIENT_SECRET` set with `AZURE_FEDERATED_TOKEN_FILE` / `MSI_ENDPOINT` / `IDENTITY_ENDPOINT` / `ACTIONS_ID_TOKEN_REQUEST_TOKEN` also present → exit `E_AUTH`.

## Local CLI

| Command | Use |
|---|---|
| `az login` | interactive (browser) |
| `az login --identity` | inside Azure VM with MI |
| `az login --service-principal -u <appId> -p <secret> --tenant <t>` | refused if MI is available; warned otherwise |
| `az login --service-principal -u <appId> -p <cert.pem> --tenant <t>` | preferred over client-secret SP |

## Token verification

`bash snitch-azure.sh doctor` runs `az account show`; surfaces tenant, subscription, signed-in principal; refuses on the client-secret + WIF combo.

## Azure DevOps PAT

Only for ADO API calls (not ARM). Skill does not interact with ADO. Store ADO PAT as a pipeline secret variable, not as `AZURE_CLIENT_SECRET`.

## Docs

- WIF: https://learn.microsoft.com/en-us/entra/workload-id/workload-identity-federation
- Managed Identity: https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/overview
- CLI auth: https://learn.microsoft.com/en-us/cli/azure/authenticate-azure-cli
