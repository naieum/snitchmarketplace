# .NET / ASP.NET Core on Fly.io

`fly launch` recognizes .csproj. Use the official Microsoft images.

## Dockerfile (multi-stage)

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY *.csproj ./
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app .
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "MyApp.dll"]
```

## fly.toml essentials

```toml
[env]
  ASPNETCORE_ENVIRONMENT = "Production"
  ASPNETCORE_URLS = "http://+:8080"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true

  [[http_service.checks]]
    grace_period = "20s"
    interval = "30s"
    path = "/health"
```

## Trust the proxy

```csharp
builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});

var app = builder.Build();
app.UseForwardedHeaders();
app.UseHttpsRedirection();
```

## Health check

```csharp
builder.Services.AddHealthChecks().AddNpgSql(builder.Configuration.GetConnectionString("Default")!);
app.MapHealthChecks("/health");
```

## DataProtection keys

Default storage is `~/.aspnet/DataProtection-Keys` — ephemeral, per-machine. Multi-machine setups log users out randomly. Persist to a shared store:

| Approach | When |
|---|---|
| Mount a volume + `PersistKeysToFileSystem("/data/keys")` | Single-region apps. |
| `PersistKeysToStackExchangeRedis(...)` | Multi-region (Upstash-on-Fly). |

## Secrets

```sh
fly secrets set \
  ConnectionStrings__Default="Host=...;Username=...;Password=...;Database=..." \
  -a <app>
```

`__` for nesting (`ConnectionStrings__Default`).

## Common mistakes

| Mistake | Cost |
|---|---|
| Forgetting `UseForwardedHeaders` | `req.IsHttps` is wrong. |
| Default DataProtection keys | Cookie auth breaks across machines. |
| `dotnet run` in prod | Uses dev server. Use `dotnet MyApp.dll`. |
| Config in `appsettings.Production.json` | Use fly secrets. |
| Missing `Microsoft.AspNetCore.HealthChecks.NpgSql` | DB health checks don't compile. |
