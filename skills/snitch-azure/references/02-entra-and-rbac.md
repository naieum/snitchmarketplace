# Microsoft Entra ID + Azure RBAC

## Identity (Entra)

| Object | Use |
|---|---|
| Users / Groups | Humans + named groups. Prefer group-based RBAC. |
| App registrations | Multi/single-tenant identity. Generates `appId`. |
| Service principals | Runtime identity for an app reg or MI. RBAC targets SPs. |
| Managed Identity | SP with Azure-managed lifecycle. System- or user-assigned. |

## Authorization (RBAC)

- Scope: `mgmt group` ⊃ `subscription` ⊃ `RG` ⊃ `resource`. Inherits down.
- Built-in: prefer `Reader` / `Contributor` / specific service roles. Avoid `Owner`/`Contributor` for app identities.
- Custom roles: only when no built-in fits. Review every 6 months.
- Deny assignments: read-only, applied by managed apps. Cannot create via RBAC API.

## PIM (Entra ID P2)

JIT elevation. Eligible vs Active. Approval + MFA + time-bound. Quarterly review. `snitch-azure` flags as `[locked: entra-p2+]`.

## Conditional Access targets

- Block legacy auth.
- Require MFA for all admins (Global, Privileged Role, Security, etc.).
- Compliant device or hybrid-join for privileged roles.
- Block sign-in from named locations on policy violation.

## Audit signals

- 2+ Owners (avoid 1, avoid 5+).
- Zero `Microsoft.Authorization/*/write` on guests.
- Custom roles audited (no `*/*` Actions on subscription scope).
- SPs scoped to specific resources, not subscription.
- `state rbac` digest = assignment counts; `state entra` digest = app regs + CA presence.

## Common findings

| Finding | Severity | Fix |
|---|---|---|
| SP with Owner on subscription | FAIL | Drop to Contributor or specific scope |
| User with Owner not in PIM | WARN | Migrate to eligible-only via PIM |
| App reg with localhost redirect in prod | FAIL | Remove dev URIs |
| Multi-tenant app registration | WARN | Confirm intent |
| No CA policy enabled | FAIL | Apply `templates/entra-conditional-access.starter.json` |
| Legacy auth not blocked | FAIL | CA: block legacy auth |
| Inactive users (>90d) | WARN | Disable in Entra |

## Docs

- Entra ID: https://learn.microsoft.com/en-us/entra/identity/users/directory-secure-default-settings
- RBAC: https://learn.microsoft.com/en-us/azure/role-based-access-control/best-practices
- PIM: https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure
- Conditional Access: https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview
