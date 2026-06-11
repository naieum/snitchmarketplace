# Security headers via vercel.json

Vercel has no `_headers` file. All custom headers go through `vercel.json`'s `headers` block, or via framework middleware/route handlers.

## Recommended baseline

`templates/headers-vercel-json.starter.json` is paste-ready. The baseline:

| Header | Value | Why |
|---|---|---|
| Strict-Transport-Security | `max-age=63072000; includeSubDomains; preload` | Force HTTPS for 2 years |
| X-Content-Type-Options | `nosniff` | Stop MIME sniffing |
| X-Frame-Options | `DENY` | No iframing (legacy; CSP frame-ancestors covers modern browsers) |
| Referrer-Policy | `strict-origin-when-cross-origin` | No full URL leak on cross-origin nav |
| Permissions-Policy | `geolocation=(), microphone=(), camera=()` | Disable APIs you don't use |
| Cross-Origin-Opener-Policy | `same-origin` | Process-per-origin isolation |
| Cross-Origin-Resource-Policy | `same-site` | Cross-Origin-Read-Blocking |
| Content-Security-Policy | (see below) | Tight default + per-stack overlays |

## CSP

Default:

```
default-src 'self';
img-src 'self' data: https:;
style-src 'self' 'unsafe-inline';
script-src 'self' 'unsafe-inline';
object-src 'none';
base-uri 'self';
frame-ancestors 'none';
```

Real apps need overlays. See `templates/csp-stack-overlays.json` for additions:

| Overlay | Adds |
|---|---|
| Stripe Elements | `script-src https://js.stripe.com`, etc. |
| Vercel Analytics / Speed Insights | `script-src https://va.vercel-scripts.com`, `connect-src https://vitals.vercel-insights.com` |
| Vercel Live (Comments) | preview-only, `frame-src https://vercel.live` |
| Cloudflare Turnstile | `script-src https://challenges.cloudflare.com` |

Tighten over time:
1. Start with `unsafe-inline` for styles/scripts (Next.js + most React frameworks need it for hydration).
2. Move to per-route nonces (Next.js `Content-Security-Policy` middleware) once inline scripts are audited.
3. Add `report-uri` or `report-to`.

## Per-path overrides

`source` is a path glob:

```json
{
  "source": "/api/(.*)",
  "headers": [
    { "key": "Cache-Control", "value": "no-store" }
  ]
}
```

Multiple blocks merge; later blocks overwrite same-named headers.

## CORS

For public APIs, set CORS at the function level (not in `vercel.json`) so you can vary by origin:

```ts
export async function GET(req: Request) {
  const origin = req.headers.get("origin") ?? "";
  const allowed = ["https://example.com"].includes(origin) ? origin : "";
  return new Response(JSON.stringify({}), {
    headers: {
      "Access-Control-Allow-Origin": allowed,
      "Vary": "Origin",
      "Content-Type": "application/json"
    }
  });
}
```

## Caveats

- `vercel.json` is read at build time. Header updates require a redeploy (`vercel --prod`).
- Headers stack with framework-emitted headers; framework wins on conflicts (e.g., Next.js sets `X-Powered-By`). Override explicitly.
- Edge middleware can set headers at runtime, layered on top of `vercel.json`.

## References

- https://vercel.com/docs/projects/project-configuration#headers
- https://content-security-policy.com
- https://www.permissionspolicy.com
