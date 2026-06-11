# Health checks and failover

## App Service health checks

`siteConfig.healthCheckPath` — App Service polls this; failing instances pulled from rotation. Pair with `Always On` on prod plans.

## Front Door health probes

Per backend pool. `probeProtocol`, `probeIntervalInSeconds`, `probePath`. Unhealthy origins removed automatically.

## App Gateway health probes

Per backend pool. Default probe = HTTP `/` to backend HTTPS port; usually wrong — define a custom probe with explicit path + status codes.

## Traffic Manager

DNS-based cross-region routing. Methods: priority, weighted, performance, geographic, multivalue, subnet. Health checks at endpoint level.

## Cross-region failover

For real DR:

| Layer | Setup |
|---|---|
| DNS | Front Door global routing OR Traffic Manager |
| App | deploy to two regions (paired: e.g., East US ↔ West US) |
| Data | Storage geo-redundant (RA-GRS or GZRS), DB geo-replication |
| Backup | Recovery Services Vault cross-region restore enabled |

## Common findings

| Finding | Severity | Fix |
|---|---|---|
| App Service no health check path | WARN | Define `/healthz` returning 200 |
| Front Door probe path returns 404 | FAIL | Make it return 200 |
| App Gateway default probe (HTTP /) | WARN | Define custom probe |
| Single-region production app | WARN | Add second region OR document RTO/RPO acceptance |
| RSV no cross-region restore | WARN | Enable at vault level |

## Docs

- App Service health: https://learn.microsoft.com/en-us/azure/app-service/monitor-instances-health-check
- Front Door probes: https://learn.microsoft.com/en-us/azure/frontdoor/health-probes
- App Gateway probes: https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-probe-overview
- Traffic Manager: https://learn.microsoft.com/en-us/azure/traffic-manager/traffic-manager-overview
