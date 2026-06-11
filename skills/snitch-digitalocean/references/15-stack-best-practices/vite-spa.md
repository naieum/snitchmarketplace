# Vite SPA on DigitalOcean

Verdict: `fit-matrix vite-spa`. Docs: `stack-docs vite-spa`.

## Landing

Spaces + CDN. `npm run build` → `dist/` → upload → CDN endpoint.

## Hardening

- Bucket private; bucket-policy `Allow s3:GetObject` to the CDN. Never `public-read` ACL.
- CDN: custom subdomain + cert.
- CSP: serve via Cloudflare in front, or via a thin Worker / App Platform proxy that adds headers.
- Cache busting: content hashes in filenames (Vite default for assets; configure for `index.html` if needed).
- `import.meta.env.VITE_*` ships to the client — never put secrets here.

## Common findings

| Status | Finding |
|---|---|
| 🔴 FAIL | `VITE_*` containing tokens |
| 🟡 WARN | Bucket-level `public-read` ACL (use bucket-policy + CDN) |
| 🟡 WARN | No CSP headers |
