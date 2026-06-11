# Functions: serverless and edge

Two function runtimes:

| Runtime | Stdlib | Cold start | Limits | Use for |
|---|---|---|---|---|
| Node.js (serverless) | Full Node | 100-500ms | 10s/60s/15m by plan, 1024-3008MB | Heavy logic, native modules, long timeouts |
| Edge | Web APIs subset | <50ms | 30s, ~128MB, no native modules | Auth, rate limit, geo, lightweight HTTP |

## Choose the runtime explicitly

- Next.js: per-route `export const runtime = 'edge'` or `'nodejs'`.
- `vercel.json`: `functions` block with `runtime: "edge"` or `runtime: "nodejs20.x"`.

## Region

`serverlessFunctionRegion` on the project (default `iad1` = us-east-1). Per-deployment via `vercel.json`:

```json
{
  "functions": {
    "app/api/**/route.ts": {
      "regions": ["iad1", "fra1"]
    }
  }
}
```

Pick a region close to your DB; cross-region DB roundtrips dominate latency.

## Memory and timeout

```json
{
  "functions": {
    "app/api/heavy/route.ts": {
      "memory": 3008,
      "maxDuration": 60
    }
  }
}
```

| Plan | Max maxDuration | Max memory |
|---|---|---|
| Hobby | 10s | 1024MB |
| Pro | 60s | 3008MB |
| Enterprise | 900s (15min) | 3008MB |

If you need >15 min, you're using the wrong platform — move to Fly Machines or AWS.

## Bundle size

Serverless bundles cap at ~50MB unzipped. `sharp`, `playwright`, `puppeteer` chew this up.

| Workaround | Use |
|---|---|
| `@sparticuz/chromium` | Slim Chromium for Lambda/Vercel |
| Dedicated worker host | Vercel function calls the worker |
| Vercel Image Optimization | Replace bundled `sharp` |

## Auth at the function

Always validate inputs and verify auth tokens. Even private APIs leak via discovery. Use:

- Edge middleware → reject unauth before function fires.
- Function-level: `verifyJWT(req)`, then process.

## CORS at the function

Don't set CORS in `vercel.json` for varying origins. Set in the function so you can echo the request `Origin` only when whitelisted (see `references/05-headers-via-vercel-json.md`).

## Cron functions

Vercel Cron requires Pro+. `vercel.json`:

```json
{
  "crons": [
    { "path": "/api/cron/cleanup", "schedule": "0 4 * * *" }
  ]
}
```

**Authenticate cron handlers.** Vercel signs requests with `x-vercel-signature`; verify the signature. An unauthenticated cron handler is a public mutation endpoint.

```ts
import { verifyVercelCronSignature } from "@/lib/vercel";

export async function GET(req: Request) {
  if (!verifyVercelCronSignature(req)) {
    return new Response("Forbidden", { status: 403 });
  }
  // ...
}
```

Or use `CRON_SECRET`: handler checks `req.headers.get('authorization') === \`Bearer ${process.env.CRON_SECRET}\``.

## Fluid Compute

Vercel Fluid Compute lets functions stay warm + concurrently serve more requests per instance. Reduces cold starts, drops cost on bursty traffic. Opt-in per project in Settings → Functions.

## Function URL exposure

Every deployed function is reachable at its URL even if not linked from your UI. Don't ship `/api/admin-debug` and rely on obscurity.

## References

- https://vercel.com/docs/functions
- https://vercel.com/docs/functions/runtimes
- https://vercel.com/docs/functions/edge-functions
- https://vercel.com/docs/cron-jobs
- https://vercel.com/docs/functions/fluid-compute
