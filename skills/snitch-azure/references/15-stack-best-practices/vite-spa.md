# Vite SPA on Azure

Verdict + caveats: `fit-matrix vite-spa`. Docs: `stack-docs vite-spa`.

## Landing

- **Static Web Apps** — exact fit. Free tier covers most.
- **Storage Static Website** — cheaper for high-traffic pure-static, but no managed certs / managed routing.
- **App Service** — overkill for pure static; only if server-side templating later.

## Must-do

- Build → `dist/` → SWA via GitHub Actions OIDC (`azure/static-web-apps-deploy`).
- `staticwebapp.config.json` `globalHeaders` for security headers (HSTS, CSP, X-Frame-Options).
- `routes` in `staticwebapp.config.json` for SPA fallback to `/index.html`.
- API: separate Functions or Container App — keep client/server split clean.

## Anti-patterns

- Don't bake API keys / tokens into the bundle. SPA has no secrets.
- Don't use Storage Static Website without Front Door — no managed certs, no global CDN.
