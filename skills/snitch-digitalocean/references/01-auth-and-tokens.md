# Auth and tokens

DigitalOcean uses **personal access tokens** (PATs) generated at https://cloud.digitalocean.com/account/api/tokens. Every token is a PAT — there is no separate global key.

## Scopes

PATs support scopes (`droplet:read`, `database:create`, `app:update`, etc.). The skill recommends scoped tokens; replace legacy un-scoped read+write tokens.

| Mode | Scopes |
|---|---|
| Read-only audit | `account:read droplet:read database:read firewall:read domain:read kubernetes:read loadbalancer:read monitoring:read app:read registry:read function:read vpc:read cdn:read image:read` |
| Hardening (`fix`) | Add `:update`, `:create`, `:delete` for the area to mutate |

## Token resolution

The skill reads, in order:

1. `DIGITALOCEAN_ACCESS_TOKEN` env var
2. `doctl auth list` active context

Neither present → `E_AUTH`, exit.

## Rotation

- Set token expiry to 90 days. Rotate quarterly.
- Revoke old tokens immediately after switching.
- On leak: rotate Spaces access keys, kubeconfig, registry creds, and SSH keys.

## Spaces access keys

Spaces uses S3-compatible access keys, separate from API tokens. Generate at https://cloud.digitalocean.com/account/api/spaces. The skill reads `DOSEC_SPACES_KEY` and `DOSEC_SPACES_SECRET`.

## Refusals

- No auth → `E_AUTH`, exit.
- Legacy un-scoped + no-expiry → WARN heuristically (DO API does not expose token metadata to the token itself).
- Global RW + no expiry → treat as legacy; recommend rotation.
