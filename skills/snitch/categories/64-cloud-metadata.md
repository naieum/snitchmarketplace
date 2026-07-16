## CATEGORY 64: Cloud Metadata Endpoint Exploitation
> Type: sink-pattern · Groups: web, modern-stack · CWE: CWE-918

This is the cloud-specific SSRF variant where the attacker pivots a server-side request to a cloud provider's instance-metadata endpoint to exfiltrate IAM credentials or secrets. Category 5 (SSRF) covers the generic shape; this category checks that metadata endpoints in particular are protected.

**Data flow tracing required (SKILL.md Rule 7).** This is an SSRF sink — trace every outbound-request destination reachable from user input back to its source (as in Category 5). A URL or host built from `req.*` reaching a fetch without a resolved-IP denylist (re-checked on each redirect) is a finding; hardcoded URLs, hardened SSRF clients, and metadata blocked at the network layer or by IMDSv2 are Passes. Escalate severity when the workload carries a stealable instance-profile / service-account token — credential theft chains to lateral movement. Un-traceable sources downgrade to Low confidence + `needs human verification`.

### Detection
- Workloads running on AWS EC2, ECS, Lambda, EKS; Azure VM/AKS; GCP Compute/GKE
- HTTP client code reachable from any user-influenced URL (`fetch`, `axios`, `requests`, `httpx`, `urllib`, `http.Client`)
- URL allowlist/denylist implementations for outbound requests
- Webhook delivery, URL preview/unfurl, image proxy, PDF/SSR rendering, file-from-URL import

### What to Search For
- Outbound HTTP code reachable from user input that does not block the link-local metadata IP (`169.254.169.254`) or the GCP metadata host (`metadata.google.internal`)
- DNS resolution performed before fetch without re-checking the resolved address against a denylist (DNS rebinding risk)
- SSRF "protection" implemented by substring match on the URL rather than parsing + resolving
- AWS instances without IMDSv2 session-token enforcement (IMDSv1 responses allowed)
- Code running in a container/pod without a network policy blocking metadata IPs
- Explicit `Metadata-Flavor: Google` or `Metadata: true` header being forwarded from user input

### Actually Vulnerable
- URL-fetch endpoint that returns body to user with no host/IP denylist
- Image/PDF renderer that follows redirects to `169.254.169.254` / `metadata.google.internal` / `fd00:ec2::254`
- AWS workload with IMDSv1 enabled and an SSRF sink anywhere in the request path
- Kubernetes pod with no NetworkPolicy preventing egress to the node metadata IP

### NOT Vulnerable
- Outbound fetch uses a hardened client (e.g., `ssrf-agent`, `safe-fetch`, explicit `lookup` function that rejects link-local / private ranges) and re-checks on redirect
- IMDSv2 required at the instance level (`HttpTokens=required`)
- Egress NetworkPolicy / firewall rule blocks metadata IPs from the workload
- No user-influenced outbound requests in the codebase

### Context Check
1. Can a user influence the destination of any outbound HTTP request?
2. Is the denylist applied to the **resolved IP**, not just the hostname?
3. Are redirects followed, and is the denylist re-applied on each hop?
4. Is IMDSv2 enforced (AWS) or is the metadata endpoint blocked at the network layer?
5. Does the code run in a context with an attached service-account / instance-profile token worth stealing?

### Evidence Chain
- The outbound HTTP sink (`fetch` / `axios` / `requests` / `httpx` / `http.Client`) at file:line that is reachable from user input
- The traced path from the URL / host source (`req.*`) to that sink
- The absence of a resolved-IP denylist blocking `169.254.169.254` / `metadata.google.internal` / `fd00:ec2::254`, re-checked on every redirect hop
- Source classification: user-influenced destination (finding) vs. hardcoded URL or hardened SSRF client (Pass)
- The workload's exposure: IMDSv2 enforcement / egress NetworkPolicy status, and whether a stealable instance-profile / service-account token is attached (escalates severity)

### Confidence Scoring
- **High**: complete trace of a user-controlled destination into an outbound fetch with no resolved-IP denylist, on a workload where a metadata-reachable token is stealable (IMDSv1 allowed / no egress policy).
- **Medium**: the sink is reachable but a partial guard is present (hostname substring check, denylist not re-checked on redirect), or the source is only partially traced, or IMDSv2 / network status is unknown.
- **Low**: destination un-traceable or the metadata-protection status cannot be verified — tag `needs human verification`.

### Files to Check
- `**/webhook*.ts`, `**/fetch*.ts`, `**/proxy*.ts`, `**/unfurl*.ts`, `**/preview*.ts`
- Image / PDF / screenshot / SSR renderer code
- Outbound HTTP utility wrappers
- Terraform/CloudFormation for `metadata_options` / `HttpTokens` settings (AWS)
- `NetworkPolicy` YAML in Kubernetes manifests

### Reference
- CWE-918: Server-Side Request Forgery (cloud metadata is the canonical high-impact SSRF target)
- OWASP Top 10:2025 — A10 Server-Side Request Forgery
- CVSS 4.0: typically Critical on cloud workloads (AV:N, AC:L, credential theft → lateral movement)
