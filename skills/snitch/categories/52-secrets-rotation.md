## CATEGORY 52: Secrets Rotation & Lifecycle
> Type: posture · Groups: — · CWE: CWE-324

> **Only what a source scan can actually see.** A repository does not know a key's age, whether
> anyone rotated it last quarter, or what a policy document says — so this category audits the
> *rotation machinery*, not the rotation history. Every rule below has to be answerable by reading a
> file. Two hard exclusions:
> - **`process.env` reads are not a finding.** Loading a secret from the environment is the correct
>   pattern (SKILL.md False Positive Prevention), and "env vars but no secrets manager" would fire on
>   nearly every well-built application. It is not a Medium; it is not a finding at all.
> - **Storage findings belong to Category 3.** A password in `docker-compose.yml`, a committed
>   service-account JSON, a live key in source — those are hardcoded secrets. Report them there once,
>   not again here under a rotation heading.

### Detection
- JWT/token verification code: `kid` header handling, JWKS endpoint configuration, `algorithms` pinning
- Configured token lifetimes: `expiresIn`, `maxAge`, `ttl`, STS `DurationSeconds`
- Dual-key or key-version arrangements in config (`*_KEY_CURRENT` / `*_KEY_PREVIOUS`, `keyVersion`, KMS key aliases)
- IaC rotation settings: `rotation_rules` on `aws_secretsmanager_secret`, `enable_key_rotation` on `aws_kms_key`, GCP `rotation_period`
- CI/CD rotation automation: a scheduled workflow that re-issues or re-deploys a credential

### What to Search For

**Signing keys — the rotation primitive that is fully visible in code:**
- JWTs issued with no `kid` (key ID) header: rotating the key then invalidates every outstanding token, so in practice the key never rotates
- Verifier that accepts exactly one hardcoded key with no JWKS endpoint and no key-set lookup
- No dual-key / grace-period arrangement: verification accepts only the current key, so any cut-over drops in-flight requests
- Encryption-at-rest key used with no key-version column or re-encryption path — rotating it makes existing rows unreadable, which is why nobody rotates it

**Configured lifetimes — read them, don't assume them:**
- Access or session token issued with no `expiresIn` / `maxAge` at all
- STS `DurationSeconds` set well beyond the workload's actual need (the 1-hour default is fine; a custom multi-hour duration needs a reason)
- API tokens created in code or IaC with expiration explicitly disabled

**IaC and pipeline rotation settings:**
- `aws_secretsmanager_secret` with no `rotation_rules` block for a production secret
- `aws_kms_key` with `enable_key_rotation` absent or `false`; GCP KMS key with no `rotation_period`
- Long-lived IAM *user* access keys declared in IaC where an IAM role would carry the workload — a role's credentials rotate on their own, a user's never do

### Actually Vulnerable
- Single signing key with no `kid` header and no JWKS endpoint -- rotating the key invalidates every outstanding token, so the key is effectively permanent
- Verifier hardcoded to one key with no key-set lookup and no previous-key acceptance window
- `aws_kms_key` for production data with `enable_key_rotation` absent or `false`
- `aws_secretsmanager_secret` holding a production credential with no `rotation_rules`
- IaC declaring an IAM *user* with long-lived access keys for a workload that could assume a role
- Token issuance with no expiry configured at all (`jwt.sign(payload, key)` with no `expiresIn` and no `exp` claim set by hand)
- Encryption at-rest key with no key-version column or re-encryption path -- rotating the key makes existing data unreadable

### NOT Vulnerable
- **Secrets read from `process.env`.** This is the correct pattern, not a Medium finding
- Secrets fetched at runtime from AWS Secrets Manager, HashiCorp Vault, or GCP Secret Manager with automatic rotation enabled
- IAM roles used instead of access keys (credentials rotate automatically)
- Database authentication via IAM (RDS IAM auth, Cloud SQL IAM auth) -- credentials are short-lived
- JWT signing with JWKS endpoint and `kid` header -- supports seamless key rotation
- API keys with built-in expiration (e.g., GitHub fine-grained tokens with expiration date)
- Secrets managed by Kubernetes Secrets with external-secrets-operator syncing from a vault
- Development or test API keys (e.g., Stripe `sk_test_*`) -- rotation not security-critical
- Encryption keys managed by KMS (AWS KMS, GCP Cloud KMS) with automatic key rotation enabled
- Short-lived tokens (STS, OAuth access tokens) that expire within hours
- Secrets managed by HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager, or Azure Key Vault (rotation handled externally). Where rotation is genuinely outside the repo, that is a **Skip with reason**, not a finding: say which system you could not read
- Short-lived tokens with automatic renewal (JWT with <1hr expiry, AWS STS temporary credentials, GCP metadata server tokens)
- Secrets rotated via CI/CD pipeline (rotation script exists in `.github/workflows/`, `Jenkinsfile`, or similar CI configuration)
- Development and local-only secrets (not used in production environments)
- Public keys (do not need rotation -- only the corresponding private keys require rotation)

### Context Check
1. Do issued tokens carry a `kid`, and does the verifier resolve keys through a set (JWKS, key map) rather than one constant?
2. Do issued tokens carry a configured expiry you can read at file:line?
3. Is there a key version or dual-key arrangement that lets a rotation land without breaking in-flight requests?
4. Does the IaC enable rotation where the provider offers it (`rotation_rules`, `enable_key_rotation`, `rotation_period`)?
5. Are IAM roles used instead of long-lived user access keys where the workload allows?
6. Is this a development/test key, where rotation machinery is not security-critical?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed the key or token is used in production (not a development/test key)
2. [ ] Quoted the issuance call and the state of its expiry option
3. [ ] Quoted the verification path and whether it resolves a key set or a single constant
4. [ ] For JWT signing keys, checked for `kid` header support and a JWKS endpoint
5. [ ] Checked the IaC for the provider's rotation setting and quoted it as absent, false, or set
6. [ ] Checked whether an IAM role could carry the workload instead of a long-lived user key
7. [ ] Stated explicitly what is NOT visible from source (key age, last rotation date, written policy) and recorded it as a Skip rather than inferring it

### Confidence Scoring
- **HIGH**: The rotation machinery is verifiably absent in code you read — signing key with no `kid` and no JWKS, KMS key with `enable_key_rotation = false`, or token issuance with no expiry — on a production path.
- **MEDIUM**: The setting is absent rather than explicitly disabled and the provider's default is unclear, or the key-set lookup crosses a module you could not fully read.
- **LOW**: Rotation may be configured in an external system outside the repository, or the key is a development/test key — tag `needs human verification`.
- **SKIP**: Secrets managed by Vault, AWS Secrets Manager, GCP Secret Manager, or Azure Key Vault with automatic rotation. IAM roles used instead of access keys. Short-lived tokens with automatic renewal. Development-only secrets.

### Files to Check
- `**/jwt*`, `**/auth*`, `**/token*` (issuance and verification, `kid` handling, JWKS route)
- Infrastructure-as-code: `**/terraform/**/*.tf`, `**/pulumi/**`, `**/cdk/**` (`rotation_rules`, `enable_key_rotation`, `rotation_period`, IAM user vs role)
- CI/CD configs: `.github/workflows/*.yml`, `.gitlab-ci.yml`, `Jenkinsfile` (scheduled rotation jobs)
- `**/config.*`, `**/settings.*` (configured lifetimes)

Note what is deliberately **not** on this list: `.env` files and committed credential files. Those
are Category 3's surface, and duplicating them here was how this category used to report the same
secret twice.
