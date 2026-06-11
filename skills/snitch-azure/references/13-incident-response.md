# Incident Response

## When the user says "we're under attack"

`bash snitch-azure.sh events subscription 1h` — recent writes/deletes/role-assignments.

| Pattern | Risk |
|---|---|
| `Microsoft.Authorization/roleAssignments/write` | privilege escalation |
| `Microsoft.KeyVault/vaults/.../secrets/write` | data exfil prep |
| `Microsoft.Storage/storageAccounts/listKeys/action` | key abuse |
| Mass `delete` operations | destruction |

`bash snitch-azure.sh analytics subscription 24h` — top callers; an unfamiliar SP at the top is the smoking gun.

## Containment

After confirming with user:

1. `bash snitch-azure.sh panic lockdown <rg>` — `CanNotDelete` lock on affected RG.
2. `bash snitch-azure.sh panic nsg-deny-all <nsg>` — top-priority deny on a public-facing NSG.
3. `bash snitch-azure.sh panic keyvault-rotate <vault>` — list keys/secrets to rotate manually.
4. Disable suspect identities: `az ad user update --id <upn> --account-enabled false`.
5. Revoke SP credentials: `az ad sp credential delete`.
6. Apply CA "block sign-ins from country X" for the duration.

## Forensic capture

Before destroying anything:

1. Snapshot affected disks: `az snapshot create`.
2. `bash snitch-azure.sh export` — JSON snapshot of subscription.
3. Save Log Analytics queries that show the timeline.
4. Capture Activity Log + Sentinel incidents (export to Storage).

## Restore

`bash snitch-azure.sh panic restore` — undoes recorded panic actions (locks, NSG denies). Identity changes, secret rotations are NOT auto-reversed.

## Postmortem

Build the timeline from Activity Log + Sentinel. Reference:

- https://learn.microsoft.com/en-us/azure/security/fundamentals/incident-response-overview
- https://learn.microsoft.com/en-us/security/operations/incident-response-overview

## Hard rules

- Don't rotate secrets in prod without the app owner present.
- Don't delete the affected resource group — lock it for forensics.
- Don't panic-block large customer geographies without confirming.
