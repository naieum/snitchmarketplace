# DigitalOcean API token — permissions checklist

DigitalOcean offers two kinds of token: **personal access tokens** (PATs) and **OAuth tokens**. The skill expects a PAT.

## Generate

1. Open https://cloud.digitalocean.com/account/api/tokens
2. Click **Generate New Token**
3. Set:
   - **Name**: `snitch-digitalocean-skill (read+limited-write)`
   - **Expiry**: **90 days** (rotate every quarter; never "no expiry" for production tokens)
   - **Scopes**: pick the minimum needed:
     - **Read-only audit (recommended)**: `account:read`, `droplet:read`, `database:read`, `firewall:read`, `domain:read`, `kubernetes:read`, `loadbalancer:read`, `monitoring:read`, `app:read`, `registry:read`, `function:read`, `vpc:read`, `cdn:read`, `image:read`
     - **Full hardening (`fix` actions)**: add `:update`, `:create`, `:delete` for the areas you want the skill to mutate.
4. Copy the token. **You will not see it again.**
5. Export:
   ```sh
   export DIGITALOCEAN_ACCESS_TOKEN="dop_v1_..."
   ```
   Or run `doctl auth init --context dosec-secure` and paste it there.

## Refuse

The skill **refuses** to operate when:

- No token is set AND no `doctl` context is active.
- The legacy un-scoped token format is detected (full-account RW with no expiry — rare on modern accounts but possible if the user has an old token).
- The token is older than ~365 days (heuristic; surfaces a WARN if it cannot determine).

## Rotate

To rotate:

1. Generate a new token (same steps above).
2. Update `DIGITALOCEAN_ACCESS_TOKEN` everywhere it's used (shells, CI, .env, k8s secrets).
3. Revoke the old token in the dashboard.

If a token is leaked: also rotate Spaces access keys, k8s kubeconfig tokens, registry credentials, and any SSH keys that may have been exposed.

## Spaces access keys (separate from the API token)

For Spaces enumeration / hardening, generate Spaces keys at https://cloud.digitalocean.com/account/api/spaces:

```sh
export DOSEC_SPACES_KEY="..."
export DOSEC_SPACES_SECRET="..."
```

Spaces keys are S3-compatible and grant access to all Spaces in the account. Treat them like AWS access keys.
