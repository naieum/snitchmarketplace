# Auth and tokens

## Token model

Two identity surfaces:

| Surface | Source | Used by |
|---|---|---|
| User session | `vercel login` writes `~/.local/share/com.vercel.cli/auth.json` (Linux) or `~/Library/Application Support/com.vercel.cli/auth.json` (macOS) | CLI default |
| API token | https://vercel.com/account/tokens — scoped to a team, optional expiration | `VERCEL_TOKEN` env for direct REST |

The skill prefers `VERCEL_TOKEN` for direct REST; falls back to the CLI for command-style ops. With neither, the skill refuses.

## Token best practices

- Always set an expiration. `expiresAt: null` is a forever-credential. Default 90 days; rotate.
- Scope to the smallest team needed. Personal tokens see every team you belong to.
- Never commit tokens. `.env.local` (gitignored) for dev; CI secrets for CI.
- Rotate after offboarding. Revoke their tokens, not just team membership.
- The skill flags any token without expiry in `state account tokens` and emits `WARN` from `fix account`.

## CLI auth file

Holds the user-session token, not a scoped API token. Don't manipulate by hand — use `vercel login` / `vercel logout`.

## Refusal contract

The skill refuses when `vercel whoami` fails AND `VERCEL_TOKEN` is unset. It runs with either present. `doctor` reports which path was selected.

## References

- https://vercel.com/account/tokens
- https://vercel.com/docs/rest-api#authentication
- https://vercel.com/docs/cli/login
