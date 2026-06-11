# Fly secrets checklist

Use this list to verify every sensitive value lives in `fly secrets`, never in `fly.toml [env]` or git.

## Set with `fly secrets set NAME=... -a <app>`

A single `fly secrets set` writes a release; the app restarts with the new env. Stage multiple changes with `--stage` and deploy once with `fly deploy`.

## Inventory checklist

For each app, run `fly secrets list -a <app>` and confirm every name below has a value if applicable.

### Always secrets (never plaintext in fly.toml [env])

- [ ] `DATABASE_URL` (Postgres / MySQL / Mongo connection string)
- [ ] `REDIS_URL` / `REDIS_PASSWORD`
- [ ] `SECRET_KEY_BASE` (Rails) / `SECRET_KEY` (Django/Flask)
- [ ] `RAILS_MASTER_KEY` / `Rails credentials.yml.enc` decryption key
- [ ] `PHX_HOST` is fine in [env]; `SECRET_KEY_BASE` is a secret
- [ ] `JWT_SECRET` / `SESSION_SECRET` / cookie signing keys
- [ ] `STRIPE_SECRET_KEY`, `STRIPE_WEBHOOK_SECRET`
- [ ] `OPENAI_API_KEY` / `ANTHROPIC_API_KEY` / any AI provider key
- [ ] `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (or `TIGRIS_*`)
- [ ] `SMTP_PASSWORD` / `SENDGRID_API_KEY` / `RESEND_API_KEY`
- [ ] OAuth client secrets (`GITHUB_CLIENT_SECRET`, `GOOGLE_CLIENT_SECRET`, ...)
- [ ] Webhook signing secrets (Stripe, GitHub, Linear, Slack, ...)

### Always [env], never secrets

- [ ] `NODE_ENV` / `RAILS_ENV` / `ENV`
- [ ] `LOG_LEVEL` / `RUST_LOG` / `DEBUG` (set to `false`)
- [ ] `PORT` (must match `[http_service].internal_port`)
- [ ] `PRIMARY_REGION` (Fly sets this automatically too)

### Special cases

- [ ] **Public-by-design API keys** (Stripe `pk_*`, Mapbox public tokens) can sit in `[env]`. Verify the key is documented as public.
- [ ] **Per-environment secrets**: use a separate Fly app per environment (e.g. `myapp-prod`, `myapp-staging`). Don't multiplex with conditionals in code.

## Rotation

- [ ] Database password: `fly pg revoke -a <pg-app> --user <user>` (legacy) or rotate via Managed Postgres dashboard.
- [ ] OAuth/API keys: rotate at the provider, then `fly secrets set` the new value.
- [ ] After rotation, run `fly secrets list -a <app>` and verify the `digest` changed.

## Detection

The skill (`bash snitch-flyio.sh state secrets <app>`) returns:

- `secrets.names` — all secret names (no values).
- `secrets_summary.local_env_keys` — keys present in fly.toml [env] in cwd.
- `secrets_summary.env_keys_overlapping_secrets` — keys present in BOTH places. **This is the leak.** Delete from fly.toml [env]; the secret stays.

## After every audit

- [ ] No high-entropy values in fly.toml [env].
- [ ] No secrets committed to git (check `.gitignore` covers `.env`, `.env.local`).
- [ ] Each app's `fly secrets list` matches the expected inventory above.
