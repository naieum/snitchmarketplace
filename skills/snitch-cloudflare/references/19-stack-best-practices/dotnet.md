# ASP.NET on Cloudflare

Verdict: `proxy-only` (.NET doesn't run on Workers; Containers beta eventual). Pattern: ASP.NET on host (Azure App Service / IIS / Linux+Kestrel / ECS) + CF in front + Tunnel; admin / Swagger / Hangfire behind Access.

`stack-docs dotnet`.

## Cloudflare-specific

Trust forwarded headers. Without this, `Request.Scheme = http`, `Request.IsHttps = false`, `RemoteIpAddress` is local proxy. `UseForwardedHeaders()` MUST run before `UseAuthentication()` / `UseHsts()` / `UseHttpsRedirection()`.

```csharp
builder.Services.Configure<ForwardedHeadersOptions>(o => {
  o.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
  o.KnownNetworks.Clear(); o.KnownProxies.Clear();
  foreach (var cidr in CloudflareCidrs) o.KnownNetworks.Add(IPNetwork.Parse(cidr));
});
```

## Secrets

- `appsettings*.json` checked in → only non-secret values. Skill greps for high-entropy → FAIL.
- Secrets via env vars / Azure Key Vault / `dotnet user-secrets` (dev only).
- Symmetric JWT signing key in `appsettings.json` → FAIL.

## Headers / endpoints

- CF Transform Rules at edge cover the security set; in-app use `NetEscapades.AspNetCore.SecurityHeaders`. Don't double-set HSTS (CF wins).
- Swagger UI at `/swagger` — disable in prod or behind Access.
- Hangfire at `/hangfire` — `DashboardOptions.Authorization` filter or behind Access.
- `/health` via `app.MapHealthChecks("/health")` — anonymous probe-friendly.

## .NET Framework (legacy IIS)

- `web.config` `<httpCookies httpOnlyCookies="true" requireSSL="true" />`.
- `<system.webServer><httpProtocol><customHeaders>` for security headers.
- Remove `X-Powered-By: ASP.NET` and `X-AspNet-Version`.
- Disable directory browsing.
- `trace.axd` / `elmah.axd` disabled in prod or behind Access.
- View State encryption + MAC validation.

## Skill targets

- `UseForwardedHeaders` configured + CF CIDRs known: FAIL if missing + CF in front.
- Swagger UI not exposed in prod (or behind Access): FAIL if exposed.
- Origin reachable only from CF: FAIL otherwise.
- No secrets in `appsettings.json`: FAIL if found.
- HSTS / CSP via CF Transform or in-app: WARN if neither.
