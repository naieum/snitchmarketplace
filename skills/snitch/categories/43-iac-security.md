## CATEGORY 43: Infrastructure as Code Security
> Type: posture · Groups: — · CWE: CWE-16

Static policy checks on Terraform, CloudFormation, Kubernetes manifests, and Dockerfiles. The cloud / orchestrator IS the attack surface for many AI-generated apps; misconfigured infra ships the blast radius. This category catches high-leverage configuration mistakes before they reach an exploitable runtime.

### Detection
- **Terraform**: `*.tf`, `*.tfvars`. Resource blocks (`resource "type" "name" { ... }`), variable definitions, IAM policy documents (often as heredocs)
- **CloudFormation**: `*.yaml` / `*.yml` / `*.json` with `AWSTemplateFormatVersion` or a `Resources` block whose entries have `Type: "AWS::*"`
- **Kubernetes**: `*.yaml` / `*.yml` with `apiVersion:` + `kind:` at top level (multi-doc files separated by `---` are normal)
- **Dockerfile**: `Dockerfile`, `Dockerfile.<variant>`, `*.dockerfile` — the IaC-level checks live here; deeper container runtime security is Category 42
- Pulumi, Ansible, or other IaC tool configurations

### What to Search For

**Terraform:**
- Public S3 buckets (`acl = "public-read"` / `"public-read-write"`, or `aws_s3_bucket_public_access_block` with all four blocks disabled)
- Overly permissive security groups: ingress `cidr_blocks = ["0.0.0.0/0"]` on sensitive ports — 22 (SSH), 3389 (RDP), 3306 (MySQL), 5432 (Postgres), 6379 (Redis), 27017 (Mongo), 9200 (Elasticsearch)
- Missing encryption at rest (`encrypted = false`, `storage_encrypted = false`, or encryption not specified) on RDS, ElastiCache, EBS
- Hardcoded credentials in `.tf` / `.tfvars` (`AKIA...`, `sk_live_...`, `BEGIN PRIVATE KEY`, `xoxp-`/`xoxb-`)
- Wildcard IAM policies (`"Action": "*"` + `"Resource": "*"` + `Effect = "Allow"` together)
- Missing logging/monitoring on resources (no CloudTrail, no VPC flow logs)
- Default VPC usage instead of custom VPCs
- Missing state file encryption or remote state without locking

**CloudFormation:**
- Same S3 / IAM patterns in CFN syntax (`AccessControl: PublicRead`, permissive `PublicAccessBlockConfiguration`, `AWS::IAM::Policy` PolicyDocument with wildcards)
- Security groups with `0.0.0.0/0` ingress on sensitive ports
- Unencrypted resources (missing `KmsKeyId`, `StorageEncrypted`)
- Missing `DeletionPolicy` on stateful resources (RDS, DynamoDB, S3)

**Kubernetes:**
- Containers running as root (missing `runAsNonRoot: true` AND no non-zero `runAsUser`)
- Privileged containers (`privileged: true` — almost always wrong outside kernel-debug pods)
- `hostNetwork: true`, `hostPID: true`, or `hostIPC: true` — break the container isolation boundary
- HostPath mounts to sensitive directories (`/etc`, `/var/run/docker.sock`)
- Missing `resources.limits` for CPU and memory — one bad pod can DoS the node
- Image tags that are `:latest` or unset — non-reproducible deployments
- Missing network policies; default service account usage
- Secrets in plain YAML (`kind: Secret` with base64 values committed — not sealed-secrets or external-secrets)

**Dockerfile:**
- Final stage with no `USER` directive — defaults to root; root-in-container is one `cap_add` away from root-on-host
- `RUN curl ... | sh` / `wget ... | sh` — the build trusts whatever that URL serves on every rebuild
- `FROM image:latest` or untagged `FROM` — same Dockerfile builds different images on different days

### Actually Vulnerable
- `acl = "public-read"` on an S3 bucket containing application data
- Security group allowing `0.0.0.0/0` ingress on port 22, 3389, 3306, 5432, 6379, 27017, or 9200
- IAM policy with `"Action": "*"` and `"Resource": "*"` — full admin; critical when attached to a role for code that processes user input (injection there becomes account-wide compromise)
- `encrypted = false` / missing storage encryption on RDS, EBS, or ElastiCache — an unencrypted RDS with PII fails most compliance frameworks immediately
- Hardcoded AWS keys or database passwords in `.tf` files
- Kubernetes pod running as root with `privileged: true` and no resource limits — on a multi-tenant cluster, node escape reaches all tenants
- HostPath mount to `/var/run/docker.sock` — container can control the Docker daemon
- Secrets defined as plain `kind: Secret` with base64-encoded values in committed YAML
- Dockerfile piping a remote installer into `sh` — if the domain is later bought by an attacker, every CI rebuild becomes an attack vector

### NOT Vulnerable
- S3 bucket with `acl = "private"` and a restrictive bucket policy; deliberately public buckets (static site assets, public datasets) — often marked `# snitch-allow: public-bucket` or named `*-public-assets-*`
- Security group with 80/443 ingress from `0.0.0.0/0` (public web server / load balancer)
- IAM wildcards scoped to the org's own ARNs (`Resource = "arn:aws:s3:::myaccount-internal-*"`) — wildcard within a tight scope
- Encrypted resources with KMS key references; Terraform variables sourcing `var.db_password` from Vault or SSM
- Kubernetes pods with `runAsNonRoot: true`, resource limits, read-only root filesystem; root-by-necessity system DaemonSets that drop capabilities
- Multi-stage Dockerfile stages running as root before the final stage drops privilege — only the final stage matters at runtime
- Sealed Secrets or External Secrets Operator; `.tfvars` files listed in `.gitignore`

### Context Check
1. Is this infra production, staging, or dev? A wide-open Postgres on `0.0.0.0/0` is critical in prod, acceptable in a sandbox VPC
2. Is the resource scoped to a private VPC / cluster? Public-facing IaC needs tighter rules than internal-only
3. Are credentials stored in variables with values sourced from a secret manager?
4. Is the S3 bucket intentionally public (static website hosting) or a misconfiguration?
5. Are Kubernetes pods running with the minimum required privileges?
6. Is state file encryption and locking configured for Terraform?
7. Does the org have a documented exception? `# snitch-allow: <rule-id>` inline comments suppress flagged rules
8. Is the misconfig in a generated file (CDK output, Helm template render)? Flag at the source (the CDK / Helm template), not the rendered output

### Evidence Chain
A finding's Evidence block must show:
- The offending resource block / manifest snippet quoted with file:line (the exact `acl`, `cidr_blocks`, PolicyDocument, `securityContext`, or `RUN curl | sh` line)
- The resource identity and its exposure context — what the resource is (S3 bucket, security group, pod spec) and whether it is production-facing, internet-reachable, or scoped to a private VPC/sandbox
- The absent mitigation checked for (no `aws_s3_bucket_public_access_block`, no KMS/`storage_encrypted`, no `runAsNonRoot`/resource limits, credentials not sourced from Vault/SSM)
- Confirmation that no `# snitch-allow: <rule-id>` exception or deliberate-public naming convention covers the resource
- For generated files (CDK output, rendered Helm): the source template file:line, since the fix belongs there — not in the rendered output

### Confidence Scoring
- **HIGH**: The configuration is unambiguous in the file — literal `0.0.0.0/0` ingress on a sensitive port, `"Action": "*"` + `"Resource": "*"` + `Allow` together, `privileged: true`, `acl = "public-read"` on an app-data bucket, or a hardcoded `AKIA...` key — and the environment context (prod / public-facing) is established.
- **MEDIUM**: The pattern is present but context is partial — the environment (prod vs. sandbox) is undetermined, the value comes through one level of variable indirection, or encryption is merely unspecified (provider defaults may apply) rather than explicitly disabled.
- **LOW**: The value cannot be resolved statically — HCL interpolation, `var.`/`local.` chains sourced outside the repo, subtle multi-doc YAML structure, or Helm templating that obscures the final rendered value. Tag `needs human verification`.

### Files to Check
- `*.tf`, `*.tfvars`, `terraform.tfstate` (should not be committed)
- `*.yaml`, `*.yml` (Kubernetes manifests, CloudFormation templates)
- `Dockerfile`, `Dockerfile.*`, `*.dockerfile`
- `kustomization.yaml`, `helmfile.yaml`, `values.yaml`
- `.github/workflows/*.yml` (IaC deployment steps)

### Reference
The Snitch CLI and GitHub Action perform these checks deterministically (S3 / IAM / RDS / SG / secret-in-TF for Terraform + CloudFormation; runAsRoot / privileged / host-network / no-resource-limits / latest-tag for Kubernetes; runAsRoot / curl-pipe-sh / latest-base for Dockerfile), with rule IDs and per-resource fixes. In pure-skill mode, walk every `*.tf` / CFN template / K8s manifest / Dockerfile against the same patterns; precision is lower on subtle YAML structure and HCL interpolation, so calibrate confidence accordingly.
