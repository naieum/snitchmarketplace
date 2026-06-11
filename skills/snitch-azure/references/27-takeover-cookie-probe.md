# Subdomain takeover + cookie / CORS probe

## Azure-specific takeover risk

Dangling resources surface as takeovers when the Azure resource is deleted but DNS remains:

| Service | Pattern | Risk |
|---|---|---|
| App Service | `*.azurewebsites.net` | Anyone re-claims the name + serves content |
| Storage account | `*.blob.core.windows.net` | Name reuse globally |
| Front Door (classic) | `*.azurefd.net` | Profile name reuse |
| Static Web Apps | `*.azurestaticapps.net` | Name reuse |
| Functions | `*.azurewebsites.net` | Same as App Service |
| Container Apps | `*.<region>.azurecontainerapps.io` | Subdomain reuse |
| Traffic Manager | `*.trafficmanager.net` | Profile reuse |
| ACR | `*.azurecr.io` | Registry name reuse |

## Detection

For each CNAME pointing at an Azure-managed pattern, resolve. If `NXDOMAIN` or `404 Resource Not Found`, candidate. The skill does NOT auto-probe; emits the candidate list for the user to verify.

## Cookie / CORS probe

Manual checks via `WebFetch`:

- `Set-Cookie` should have `Secure`, `HttpOnly`, `SameSite=Lax|Strict`.
- `Access-Control-Allow-Origin` ≠ `*` for credentialed endpoints.
- `Access-Control-Allow-Credentials: true` + `Access-Control-Allow-Origin: *` is a bug.

## Hardening

- Use Azure DNS Alias records (not CNAME) where target is an Azure resource — Alias records tear down with the resource.
- Front Door / App Gateway: validate origins explicitly; no wildcards.
- Custom domain certs rotate before expiry (managed certs handle this; verify renewal job).

## Docs

- Subdomain takeover: https://learn.microsoft.com/en-us/azure/security/fundamentals/subdomain-takeover
- DNS Alias: https://learn.microsoft.com/en-us/azure/dns/dns-alias
