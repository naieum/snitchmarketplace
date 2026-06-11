# Privacy and Data Residency

## Data residency

- Pin every storage / DB / compute resource to a specific region. `az resource list --query '[].location'` shows the spread.
- Microsoft EU Data Boundary (EUDB) — data + telemetry stay in EU regions for EU customers (GA 2024 for major services). https://learn.microsoft.com/en-us/privacy/eudb/eudb-trust-center
- Sentinel and Azure Monitor: ingestion can cross regions if not pinned. Choose a workspace in the right region.

## GDPR / DSR

- Microsoft provides DSR tooling in M365 / Entra admin centers for tenant-level data.
- App-level data in your DBs: build export / delete flows yourself.

## Encryption

- At rest by default (platform-managed keys).
- CMK (Key Vault) for regulated data — required for some HIPAA / FedRAMP scopes.
- Double encryption (`requireInfrastructureEncryption=true`) — two independent layers.
- TLS 1.2 minimum in transit; 1.3 where supported.

## Logging / PII

- App Insights + Log Analytics `customDimensions` makes accidental PII logging trivial. Pre-filter before send.
- Sentinel ingest is not sanitized — apply parsers to redact at ingestion.

## Cookie consent / Front Door

EU/UK app behind Front Door:

- No first-party cookie consent. Use a vendor (OneTrust, Cookiebot) or implement at app layer.
- Front Door analytics is aggregate, not user-tracking.

## Docs

- Data residency: https://learn.microsoft.com/en-us/azure/availability-zones/cross-region-replication-azure
- EUDB: https://learn.microsoft.com/en-us/privacy/eudb/eudb-trust-center
- GDPR: https://learn.microsoft.com/en-us/compliance/regulatory/gdpr
- CMK: https://learn.microsoft.com/en-us/azure/security/fundamentals/encryption-overview#customer-managed-keys
