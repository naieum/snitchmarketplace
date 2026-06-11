# API-only monorepo on Vercel — best practices

For repos shipping only an API surface (no front-end). Works as long as you stay within function limits.

## Layout

```
apps/
  api/
    api/                    # Vercel functions tree
      v1/
        users.ts
        users/[id].ts
        items.ts
    package.json
    vercel.json
packages/
  shared/                   # shared types + utils
package.json
turbo.json | nx.json | pnpm-workspace.yaml
```

Link `apps/api` as the project root in `.vercel/project.json` or via `vercel link --cwd apps/api`.

## vercel.json

```json
{
  "rewrites": [
    { "source": "/v1/(.*)", "destination": "/api/v1/$1" }
  ],
  "headers": [
    { "source": "/v1/(.*)", "headers": [
      { "key": "Cache-Control", "value": "no-store" },
      { "key": "Vary",          "value": "Origin" }
    ]}
  ],
  "functions": {
    "api/v1/heavy.ts": { "memory": 1024, "maxDuration": 60 }
  }
}
```

## Cross-package imports

Vercel's monorepo auto-detection (Turborepo, pnpm, Nx) bundles shared packages. Verify with `vercel build --debug` that internal deps land in the function bundle.

## Function count limits

Each `api/**/route.ts` (Next) or `api/*.ts` (no-framework) = one function.

| Plan | Functions per project |
|---|---|
| Hobby | 12 |
| Pro | 100 |
| Enterprise | per contract |

Group related routes via dynamic segments (`api/v1/[resource]/[id].ts`) instead of one file per CRUD method.

## Auth

For B2B APIs:

- Issue scoped tokens to consumers; verify via JWT with a verify-key.
- Rate-limit per token (key on token id, not IP).
- Sign request bodies with HMAC for webhooks → verify in the handler.

## CORS

Echo origin only when whitelisted (see `references/05-headers-via-vercel-json.md`). Never `Access-Control-Allow-Origin: *` on authenticated endpoints.

## Observability

- Log JSON to stdout — Vercel collects + log drains forward to your SIEM.
- Include `request_id` (from `x-vercel-id` or `x-request-id`) in every log line for correlation.

## References

- https://vercel.com/docs/limits
- https://vercel.com/docs/monorepos
