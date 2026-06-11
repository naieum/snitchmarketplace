# Vite SPA on Vercel — best practices

Pure static SPA. No server. Vercel serves `dist/` from its CDN.

## Configuration

```js
// vite.config.ts
export default defineConfig({
  build: {
    outDir: 'dist',
    sourcemap: 'hidden',                 // no source-map URL in served files
    minify: 'esbuild',
  },
});
```

## SPA fallback

Vercel auto-detects the SPA pattern and rewrites unknown routes to `/index.html`. Explicit:

```json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

## Headers

Static SPA still gets HSTS / CSP / X-Frame from `vercel.json`:

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "Strict-Transport-Security", "value": "max-age=63072000; includeSubDomains; preload" },
        { "key": "X-Content-Type-Options",    "value": "nosniff" },
        { "key": "X-Frame-Options",           "value": "DENY" },
        { "key": "Referrer-Policy",           "value": "strict-origin-when-cross-origin" }
      ]
    },
    {
      "source": "/assets/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    }
  ]
}
```

## Auth in a pure SPA

You can't keep a secret in a SPA. Auth flows go via:

- A backend API (separate Vercel project or external host) holding tokens.
- OAuth Authorization Code with PKCE — no client secret.
- Redirect-back flows that set HTTP-only cookies on the SPA's domain.

## Common mistakes

- `VITE_API_KEY` in `.env` ships to the browser. `VITE_*` is bundled.
- Inline `<script>` without a CSP nonce → XSS surface.
- Missing long-cache header on `/assets/*`.

## References

- https://vercel.com/docs/frameworks/vite
- https://vitejs.dev/guide/static-deploy.html
