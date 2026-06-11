## CATEGORY 52: Secrets Rotation & Lifecycle

### Detection
- API keys and secrets with no expiration mechanism
- Static secrets that persist unchanged in configuration or environment
- Missing key versioning strategy for cryptographic keys or API tokens
- Long-lived credentials with no rotation policy
- Secrets stored directly in code or config files without referencing a secrets manager

### What to Search For

**AWS:**
- IAM access keys without rotation policy (no `max_key_age` or rotation Lambda)
- `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` hardcoded or static in environment
- IAM users with access keys instead of IAM roles (for EC2, Lambda, ECS)
- Missing `aws iam get-credential-report` or no credential age monitoring
- Long-lived STS tokens (default 1 hour is fine; custom durations over 12 hours are risky)

**Database Credentials:**
- Database connection strings with static passwords in `.env`, `config.yml`, or application code
- No rotation mechanism for database passwords (no RDS IAM auth, no Vault dynamic credentials)
- Same database password used across environments (dev, staging, production)
- MongoDB connection URIs with embedded passwords that never change

**JWT & Signing Keys:**
- JWT signing key as a static string in environment variables with no rotation plan
- HMAC signing secret that is the same value across all environments
- RSA/EC private keys for JWT signing stored in filesystem with no key versioning
- Missing `kid` (key ID) header in JWTs (prevents key rotation without breaking existing tokens)
- Signing keys without a JWKS endpoint for key discovery and rotation

**API Keys & Tokens:**
- Stripe secret keys (`sk_live_*`) with no rotation plan
- GitHub personal access tokens with no expiration set
- OAuth client secrets that have never been rotated
- Third-party API keys (SendGrid, Twilio, OpenAI) with no documented rotation schedule
- Firebase/GCP service account keys downloaded and stored indefinitely

**General Patterns (All Languages):**
- Secrets loaded from environment variables with no reference to a secrets manager
- No secret versioning: single key without a migration path to a new key
- Missing grace period for old keys during rotation (cut-over breaks in-flight requests)
- Encryption keys with no re-encryption strategy when keys are rotated
- Same secret value appearing in git history across many commits over extended periods

### Actually Vulnerable
- AWS IAM access keys older than 90 days with no rotation policy or monitoring
- Database password hardcoded in `docker-compose.yml` or `.env` that has been the same value since initial setup
- JWT signing secret stored as `JWT_SECRET=mysupersecretkey` in `.env` with no rotation mechanism
- Stripe `sk_live_` key in environment with no documentation or automation for rotation
- GitHub personal access token with `no expiration` selected, stored in CI/CD environment
- GCP service account JSON key file committed to repository or stored on server filesystem indefinitely
- Single signing key with no `kid` header -- rotating the key invalidates all existing tokens
- OpenAI API key shared across all environments with no rotation schedule
- Encryption at-rest key with no re-encryption strategy -- rotating the key makes existing data unreadable

### NOT Vulnerable
- Secrets fetched at runtime from AWS Secrets Manager, HashiCorp Vault, or GCP Secret Manager with automatic rotation enabled
- IAM roles used instead of access keys (credentials rotate automatically)
- Database authentication via IAM (RDS IAM auth, Cloud SQL IAM auth) -- credentials are short-lived
- JWT signing with JWKS endpoint and `kid` header -- supports seamless key rotation
- API keys with built-in expiration (e.g., GitHub fine-grained tokens with expiration date)
- Secrets managed by Kubernetes Secrets with external-secrets-operator syncing from a vault
- Development or test API keys (e.g., Stripe `sk_test_*`) -- rotation not security-critical
- Encryption keys managed by KMS (AWS KMS, GCP Cloud KMS) with automatic key rotation enabled
- Short-lived tokens (STS, OAuth access tokens) that expire within hours
- Secrets managed by HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager, or Azure Key Vault (rotation handled externally -- not visible in application code)
- Short-lived tokens with automatic renewal (JWT with <1hr expiry, AWS STS temporary credentials, GCP metadata server tokens)
- Secrets rotated via CI/CD pipeline (rotation script exists in `.github/workflows/`, `Jenkinsfile`, or similar CI configuration)
- Development and local-only secrets (not used in production environments)
- Public keys (do not need rotation -- only the corresponding private keys require rotation)

### Context Check
1. Is there a documented secrets rotation policy or schedule?
2. Are secrets sourced from a secrets manager with automatic rotation, or from static environment variables?
3. Do API keys and tokens have expiration dates set?
4. Is there key versioning (e.g., `kid` in JWT, key version in KMS) to support rotation?
5. Are IAM roles used instead of long-lived access keys where possible?
6. Is there a grace period or dual-key strategy during rotation to avoid downtime?
7. Is this a development/test key where rotation is less critical?

### Files to Check
- `.env`, `.env.production`, `*.env`, `docker-compose*.yml`
- `**/config.*`, `**/settings.*`, `**/secrets.*`
- `**/.aws/credentials`, `**/service-account*.json`
- CI/CD configs: `.github/workflows/*.yml`, `.gitlab-ci.yml`, `Jenkinsfile`
- Infrastructure-as-code: `**/terraform/**/*.tf`, `**/pulumi/**`, `**/cdk/**`
- `**/jwt*`, `**/auth*`, `**/token*`

### Confidence Scoring
- **HIGH**: Production secret (AWS access key, database password, JWT signing key, Stripe live key) with no rotation mechanism, no secrets manager integration, and no key versioning. Secret has been static across git history.
- **MEDIUM**: Secrets are loaded from environment variables (not hardcoded) but there is no evidence of a secrets manager or rotation automation. Or JWT signing lacks `kid` header for rotation support.
- **LOW**: Secrets appear static but may be managed by an external system (Vault, AWS Secrets Manager) that is configured outside the application code. Or the secret is a development/test key where rotation is less critical.
- **SKIP**: Secrets managed by Vault, AWS Secrets Manager, GCP Secret Manager, or Azure Key Vault with automatic rotation. IAM roles used instead of access keys. Short-lived tokens with automatic renewal. Development-only secrets.

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed the secret is used in production (not a development/test key)
2. [ ] Verified no secrets manager integration (Vault, AWS Secrets Manager, GCP Secret Manager, Azure Key Vault)
3. [ ] Checked if IAM roles are used instead of long-lived access keys where applicable
4. [ ] For JWT signing keys, checked for `kid` header support and JWKS endpoint
5. [ ] Verified API keys and tokens do not have built-in expiration dates
6. [ ] Confirmed there is no rotation automation in CI/CD pipelines or IaC
7. [ ] Checked for key versioning or dual-key strategy that would support rotation
