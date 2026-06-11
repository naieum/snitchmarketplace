# .NET on Azure

Verdict + caveats: `fit-matrix dotnet`. Docs: `stack-docs dotnet`.

## Landing

- **App Service** — canonical. Linux preferred (cheaper, ARM64).
- **Functions** — first-class for serverless C#.
- **Container Apps** — Docker.
- **Service Fabric** / **AKS** — large-scale microservices (rare for greenfield).

## Must-do

- HTTPS-only, min TLS 1.2, FTPS off, SCM basic off.
- AAD via `Microsoft.Identity.Web`; `[Authorize]` on controllers.
- App Settings → Key Vault references; `Configuration["MySecret"]` resolves at runtime.
- `IConfiguration` chain: env vars > App Settings > Key Vault > appsettings.{env}.json. Plaintext appsettings.json secrets = FAIL.
- HSTS in `Program.cs`: `app.UseHsts()`.
- `app.UseHttpsRedirection()`.
- CSP via middleware or `NWebsec.AspNetCore.Middleware`.

## Skill targets

Same App Service hardening. Plus:

| Finding | Severity |
|---|---|
| `appsettings.json` containing connection-string-shaped values | FAIL (`detect` flags) |
| `ASPNETCORE_ENVIRONMENT` not `Production` in prod | WARN |
