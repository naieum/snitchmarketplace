# Astro on Azure

Verdict + caveats: `fit-matrix astro`. Docs: `stack-docs astro`.

## Landing options

| Target | Use |
|---|---|
| Static Web Apps | Static-only Astro. Free tier. |
| App Service Linux | SSR with `@astrojs/node` adapter. |
| Container Apps | SSR with arbitrary Node modules. |

## Must-do

- Static-only: deploy `dist/` to SWA via GitHub Actions OIDC (`azure/static-web-apps-deploy`).
- SSR: `siteConfig.linuxFxVersion: "NODE|20-lts"`.
- API routes: review for unintended Node modules; SWA Functions has API restrictions.
- Image opt (sharp) needs Linux App Service or Container Apps; Windows plans break sharp.

## Skill targets

App Service HTTPS-only / TLS / FTPS / SCM basic — same as Next.js via `fix appservice`. SWA: ensure `staticwebapp.config.json` defines `globalHeaders` for CSP / X-Frame-Options.

## CSP via Static Web Apps

```json
{
  "globalHeaders": {
    "Content-Security-Policy": "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:;",
    "Strict-Transport-Security": "max-age=31536000; includeSubDomains",
    "X-Content-Type-Options": "nosniff",
    "Referrer-Policy": "strict-origin-when-cross-origin"
  }
}
```
