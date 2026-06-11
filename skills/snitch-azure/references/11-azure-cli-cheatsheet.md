# Azure CLI cheatsheet

## Auth

```sh
az login                                       # interactive
az login --identity                            # MI context
az account show                                # current sub
az account set --subscription <id>             # switch
az account list --output table                 # all visible
```

## Subscription

```sh
az group list -o table
az resource list --subscription <id> -o table
az lock list -o table
az consumption budget list
az role assignment list --role Owner -o table
```

## Entra

```sh
az ad user list --query '[].{u:userPrincipalName,e:accountEnabled}' -o table
az ad group list -o table
az ad app list --all --query '[].{n:displayName,id:appId,m:signInAudience}' -o table
az ad sp list --all --query '[].{n:displayName,t:servicePrincipalType}' -o table
az rest --method GET --url 'https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies'
```

## RBAC

```sh
az role assignment list --all -o table
az role definition list --custom-role-only true -o table
az role assignment create --role <role> --assignee <upn|spn|mi-id> --scope <scope>
az role assignment delete --ids <assignment-id>
```

## Storage

```sh
az storage account list -o table
az storage account show -n <name> -g <rg> --query '{https:enableHttpsTrafficOnly,minTls:minimumTlsVersion,public:allowBlobPublicAccess,sharedKey:allowSharedKeyAccess}'
az storage account update -n <name> -g <rg> --https-only true --min-tls-version TLS1_2 --allow-blob-public-access false
az storage account blob-service-properties update --account-name <name> --resource-group <rg> --enable-delete-retention true --delete-retention-days 14
```

## Key Vault

```sh
az keyvault list -o table
az keyvault show -n <name> --query '{rbac:properties.enableRbacAuthorization,sd:properties.enableSoftDelete,pp:properties.enablePurgeProtection,acl:properties.networkAcls.defaultAction}'
az keyvault update -n <name> --enable-rbac-authorization true --default-action Deny
az keyvault secret list --vault-name <name>
az keyvault key rotate --vault-name <name> --name <key>
```

## App Service / Functions

```sh
az webapp list -o table
az webapp config show --name <app> --resource-group <rg>
az webapp update --name <app> --resource-group <rg> --https-only true
az webapp config set --name <app> --resource-group <rg> --min-tls-version 1.2 --ftps-state Disabled
az webapp identity assign --name <app> --resource-group <rg>
# SCM basic auth (no first-class CLI; REST):
az rest --method PUT \
  --url "https://management.azure.com/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Web/sites/<app>/basicPublishingCredentialsPolicies/scm?api-version=2022-09-01" \
  --body '{"properties":{"allow":false}}'
```

## SQL / Cosmos / Postgres / MySQL

```sh
az sql server list -o table
az sql server update -n <s> -g <rg> --minimal-tls-version 1.2
az sql db tde set --server <s> --database <db> -g <rg> --status Enabled
az cosmosdb list -o table
az cosmosdb update -n <n> -g <rg> --disable-local-auth true --minimal-tls-version Tls12
az postgres flexible-server update -n <n> -g <rg> --active-directory-auth Enabled
```

## NSG / firewall

```sh
az network nsg list -o table
az network nsg rule list --nsg-name <n> -g <rg> -o table
az network nsg rule create --nsg-name <n> -g <rg> --name <rule> --priority 100 \
  --source-address-prefixes 'VirtualNetwork' --destination-port-ranges 443 \
  --access Allow --protocol Tcp --direction Inbound
az network watcher flow-log list --location <region>
```

## Defender for Cloud

```sh
az security pricing list -o table
az security pricing show -n VirtualMachines
az security pricing create -n <plan> --tier Standard
az security secure-score list -o table
az security task list -o table
```

## Activity log + diagnostics

```sh
az monitor activity-log list --start-time "$(date -u -v-1d +%Y-%m-%dT%H:%M:%SZ)" --max-events 500
az monitor diagnostic-settings subscription list
az monitor diagnostic-settings subscription create -n primary --workspace <la-id> \
  --logs '[{"category":"Administrative","enabled":true},{"category":"Security","enabled":true},{"category":"ServiceHealth","enabled":true},{"category":"Alert","enabled":true},{"category":"Recommendation","enabled":true},{"category":"Policy","enabled":true},{"category":"Autoscale","enabled":true},{"category":"ResourceHealth","enabled":true}]'
```

## Policy

```sh
az policy assignment list -o table
az policy state list --top 100 --query '[?complianceState==`NonCompliant`]'
az policy assignment create --policy-set-definition <id> --display-name <name>
```

## Locks

```sh
az lock list
az lock create -n cannotdelete-prod --lock-type CanNotDelete
az lock delete -n <name>
```
