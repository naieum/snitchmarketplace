# Environment variables and secrets

## Three environments

| Env | Applied to | Pulled by |
|---|---|---|
| `production` | production deployments | — |
| `preview` | every non-production branch | — |
| `development` | local `vercel dev` | `vercel env pull` |

Scope a var to one, two, or all three.

## Three sensitivity types

| Type | Storage | Visibility | UI |
|---|---|---|---|
| `plain` (default) | Plaintext | All team members | Editable inline |
| `encrypted` | At rest | Maintainers/owners only | Editable inline |
| `sensitive` | At rest, write-once | Never visible after creation | Re-create to change |

Use `sensitive` for any value with secret semantics: API keys, DB connection strings, OAuth secrets, signing keys. The skill flags plaintext values with secret-shaped names as `WARN` and emits CLI commands to migrate them.

## Secret references (`@`-syntax)

Older projects use `@my-secret`. Legacy — use Sensitive type instead. Don't introduce new `@` references.

## `NEXT_PUBLIC_*` ships to the browser

Next.js inlines any `NEXT_PUBLIC_*` env var into the browser bundle. Never put credentials there. The skill flags names matching:

```
(?i)(secret|token|api[_-]?key|password|passwd|private_key|dsn|connection|database_url)
```

If you have `NEXT_PUBLIC_API_TOKEN`, it's in `view-source:` of every page. Fix:

1. Rename to `API_TOKEN` (drop `NEXT_PUBLIC_`).
2. Move all reads to server-side code (route handlers, server components, server actions).
3. Re-add as Sensitive type.

## `.env*` files

| File | Purpose | Commit? |
|---|---|---|
| `.env` | Universal default | No |
| `.env.local` | Local dev overrides | No (gitignore) |
| `.env.development` | Loaded by Next.js in dev | Maybe (no secrets) |
| `.env.production` | Loaded by Next.js in prod build | Maybe (no secrets) |
| `.env.preview` | Vercel-specific, pulled by `vercel env pull` | No |

The skill refuses to ship secret values to stdout. For migration, it emits `vercel env add NAME --sensitive` invocations; the user types the value into the CLI prompt.

## Common workflow

```bash
vercel env pull .env.local                            # for vercel dev
vercel env add DATABASE_URL production --sensitive    # add sensitive
vercel env add DATABASE_URL preview --sensitive
vercel env rm OLD_TOKEN production                    # remove leak
```

## References

- https://vercel.com/docs/projects/environment-variables
- https://vercel.com/docs/projects/environment-variables/sensitive-environment-variables
- https://nextjs.org/docs/app/building-your-application/configuring/environment-variables
