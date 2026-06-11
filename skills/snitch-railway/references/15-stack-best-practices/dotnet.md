# .NET / ASP.NET on Railway

Nixpacks supports .NET. For control, use a Dockerfile.

## Dockerfile

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app .
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "YourApp.dll"]
```

## railway.json

```json
{
  "build": { "builder": "DOCKERFILE" },
  "deploy": {
    "startCommand": "dotnet YourApp.dll",
    "healthcheckPath": "/health",
    "numReplicas": 2
  }
}
```

## Hardening (`Program.cs`)

```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddHsts(opts => {
  opts.MaxAge = TimeSpan.FromDays(365);
  opts.IncludeSubDomains = true;
  opts.Preload = true;
});
builder.Services.Configure<ForwardedHeadersOptions>(opts => {
  opts.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
});

var app = builder.Build();
app.UseForwardedHeaders();
app.UseHsts();
app.UseHttpsRedirection();
app.MapHealthChecks("/health");
app.Run();
```

## Notes

- `ASPNETCORE_URLS=http://0.0.0.0:$PORT` — env-var path is preferred over hardcoding.
- Tight cold-start: use `aspnet` base (smaller than `sdk`).

## Docs

- https://learn.microsoft.com/en-us/aspnet/core/security/
