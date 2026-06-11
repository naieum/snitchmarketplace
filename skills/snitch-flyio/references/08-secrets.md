# 08 — Secrets

Fly secrets are encrypted environment variables. Set with `fly secrets set`; available at runtime as `process.env.NAME` / `os.environ['NAME']` / `ENV['NAME']`. Never appear in `fly config show`, never logged, never returned by any read API.

## Set / list / unset

```sh
fly secrets set DATABASE_URL='postgres://...' STRIPE_KEY='sk_...' -a <app>
fly secrets list -a <app>                       # name + digest only
fly secrets unset OLD_KEY -a <app>
fly secrets set --stage NEW_KEY=... -a <app>    # batch; deploy applies
fly deploy -a <app>                             # apply staged secrets
```

Setting a secret triggers an app restart. Use `--stage` to batch, then deploy once.

## Never put secrets in `[env]`

`[env]` ships in the deployable artifact and is committed to git. Use it only for:

| OK in [env] | Why |
|---|---|
| `LOG_LEVEL`, `PORT` | Non-sensitive runtime config. |
| Public API keys (Stripe `pk_*`) | Designed to be public. |

The skill flags high-entropy `[env]` values whose names match `KEY|SECRET|TOKEN|PASS|DSN`.

## Detection

`bash snitch-flyio.sh state secrets <app>`:

```json
{
  "secrets_summary": {
    "total": 12,
    "names": ["DATABASE_URL","STRIPE_KEY",...],
    "local_env_keys": [...keys in fly.toml [env]...],
    "env_keys_overlapping_secrets": [...keys in BOTH places...]
  }
}
```

Overlap is the leak — secret value wins at runtime, but `[env]` copy is in git.

`bash snitch-flyio.sh fix secrets <app>` emits:

- Per-suspect-key, `fly secrets set NAME=<NEW_VALUE>`.
- Reminder to delete the `[env]` entry.

## Rotation

| Secret type | Procedure |
|---|---|
| Database password | `fly pg revoke -a my-db --user app_user`, then `fly secrets set DATABASE_URL=...`. |
| API keys | Rotate at provider, then `fly secrets set NAME=...`. |
| Webhook signing secrets | Rotate at provider, set on Fly. Brief window where old in-flight webhooks fail. |

Verify the digest in `fly secrets list` changed.

## CI deploy

CI should NOT have scope to mutate secrets unless required. Best practice: humans manage secrets via `fly secrets set`; CI deploy token scoped to deploy only.

If CI must set per-PR preview secrets, use `--stage` to batch and deploy once.

## Templating

Fly secrets don't support reference / templating like `${{ secrets.NAME }}`. Each secret is a literal at the time of `fly secrets set`. Coordinate cross-environment values manually.

## Common mistakes

| Mistake | Cost |
|---|---|
| `DATABASE_URL` in `fly.toml [env]` "just for now" | Never gets cleaned up. |
| Setting secrets one at a time | Many app restarts. |
| Same secret across prod + staging | Staging compromise leaks prod. |
| Trusting `fly secrets list` to show value changes | Shows digest only; values are sealed. |
| Logging `process.env` in error handlers | Exposes secrets in log stream. |
