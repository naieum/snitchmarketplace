## CATEGORY 71: Infrastructure-as-Code Misconfiguration

Static policy checks on Terraform, CloudFormation, Kubernetes manifests, and Dockerfiles. The cloud / orchestrator IS the attack surface for many AI-generated apps; misconfigured infra ships the blast radius. This category catches the high-leverage configuration mistakes before they reach a runtime that an attacker can exploit. Snitch CLI and GitHub Action perform these checks deterministically; this category exists in the methodology so the Plugin (no toolchain) can prompt the AI to do a heuristic version of the same review.

### Detection
- **Terraform**: `*.tf` files. Resource blocks (`resource "type" "name" { ... }`), variable definitions, IAM policy documents (often as heredocs).
- **CloudFormation**: `*.yaml` / `*.yml` / `*.json` with `AWSTemplateFormatVersion` or a `Resources` block whose entries have `Type: "AWS::*"`.
- **Kubernetes**: `*.yaml` / `*.yml` with `apiVersion:` + `kind:` at top level (multi-doc files separated by `---` are normal).
- **Dockerfile**: `Dockerfile`, `Dockerfile.<variant>`, `*.dockerfile`. Multi-stage builds use multiple `FROM` directives.

### What to Search For

**AWS / Terraform:**
- S3 buckets with `acl = "public-read"` or `"public-read-write"`, or `aws_s3_bucket_public_access_block` with all four blocks disabled.
- IAM policy documents with `Action = "*"` and `Resource = "*"` and `Effect = "Allow"` together.
- `aws_db_instance` (RDS) with `storage_encrypted = false` or unset.
- `aws_security_group` ingress with `cidr_blocks = ["0.0.0.0/0"]` on sensitive ports: 22 (SSH), 3389 (RDP), 3306 (MySQL), 5432 (Postgres), 6379 (Redis), 27017 (Mongo), 9200 (Elasticsearch).
- Hardcoded credentials in TF source: `AKIA...` (AWS keys), `sk_live_...` (Stripe live), `BEGIN PRIVATE KEY` blocks, `xoxp-` / `xoxb-` (Slack tokens).

**CloudFormation:**
- Same S3 / IAM patterns as Terraform but in CFN syntax (`AccessControl: PublicRead`, `PublicAccessBlockConfiguration` with permissive flags, `AWS::IAM::Policy` PolicyDocument with wildcards).

**Kubernetes:**
- Pods / Deployments running as root: missing `securityContext.runAsNonRoot: true` AND no explicit `securityContext.runAsUser` set to a non-zero UID.
- Containers with `securityContext.privileged: true` (almost always wrong outside specific kernel-debug pods).
- Pods with `hostNetwork: true`, `hostPID: true`, or `hostIPC: true` — break the container isolation boundary.
- Containers without both `resources.limits.cpu` and `resources.limits.memory` set — one bad pod can DoS the node.
- Container image tags that are `:latest` or unset — non-reproducible deployments, can't pin known-good versions.

**Dockerfile:**
- Final stage with no `USER` directive — defaults to root, and root-in-container is one `cap_add` away from root-on-host.
- `RUN curl ... | sh` or `wget ... | sh` patterns — the build now trusts whatever that URL serves on every rebuild.
- `FROM image:latest` or `FROM image` without a tag — the same Dockerfile builds different images on different days.

### Actually Vulnerable
- A public S3 bucket with sensitive data flagged at PR review time, before it ships and gets indexed.
- An IAM role with `Action = "*"` granted to a Lambda that processes user input — code injection in that Lambda becomes account-wide compromise.
- A K8s Pod with `privileged: true` running on a multi-tenant cluster — escape to the node and you have all tenants.
- A Dockerfile that pipes a remote installer into sh, hosted on a domain that later gets bought by an attacker — every CI rebuild becomes an attack vector (the Bitwarden / Checkmarx supply-chain incidents in April 2026 generalized this exact pattern).
- An RDS instance without storage encryption containing PII — fails most compliance frameworks immediately.

### NOT Vulnerable
- Public S3 buckets that are deliberately public (static site assets, public datasets) — these usually have `# snitch-allow: public-bucket` markers in the TF, or live under predictable bucket names like `*-public-assets-*`.
- IAM wildcards scoped to your own account ARNs (`Resource = "arn:aws:s3:::myaccount-internal-*"`) — wildcard within a tight scope, usually fine.
- K8s Pods running as root for legitimate reasons (system DaemonSets, privileged debugging Pods) — usually have `securityContext.capabilities.drop` to limit blast radius.
- Multi-stage Dockerfile build stages running as root before the final stage drops privilege — only the final stage matters for runtime.

### Context Check
1. Is this infra production, staging, or dev? A wide-open Postgres on `0.0.0.0/0` is critical in prod, acceptable in a sandbox VPC.
2. Is the resource scoped to a private VPC / cluster? Public-facing IaC needs tighter rules than internal-only.
3. Does the org have a documented exception? `# snitch-allow: <rule-id>` inline comments suppress flagged rules.
4. Is the misconfig in a generated file (CDK output, Helm template render)? Generated IaC should be flagged at the source (the CDK / Helm template), not the output. Snitch may need to skip these directories.

### Reference
The Snitch CLI and GitHub Action perform this scan automatically. 15 high-signal rules ship in v1: AWS S3 / IAM / RDS / SG / secret-in-TF for Terraform + CloudFormation; runAsRoot / privileged / host-network / no-resource-limits / latest-tag for Kubernetes; runAsRoot / curl-pipe-sh / latest-base for Dockerfile. Output groups findings by framework with the rule ID + suggested fix per resource. Plugin users running this category in chat-skill mode should ask the AI to walk every `*.tf` / CFN template / K8s manifest / Dockerfile and check the same patterns; precision is lower than the deterministic CLI/Action path because the AI may miss subtle YAML structure or HCL interpolations.
