## CATEGORY 11: Cloud Security
> Type: posture · Groups: modern-stack · CWE: CWE-16

### Detection
- Cloud SDKs: `aws-sdk`, `@aws-sdk/*`, `@google-cloud/*`, `@azure/*`
- Infrastructure-as-code: Terraform (`.tf`), CloudFormation, Pulumi files
- Cloud environment variables: `AWS_ACCESS_KEY_ID`, `GOOGLE_APPLICATION_CREDENTIALS`

### What to Search For
- Cloud credentials in code
- Overly permissive IAM policies
- Open security groups
- Service account keys in repo

### Actually Vulnerable
- IAM with wildcard action AND resource
- Security groups open to 0.0.0.0/0 on sensitive ports
- Hardcoded cloud credentials
- Service account JSON committed

### NOT Vulnerable
- Constrained IAM policies
- Web ports open to public
- Secret manager references

### Context Check
1. Is the IAM policy scoped to specific resources or using wildcards?
2. Is the security group for a web server (80/443) or sensitive service?
3. Are credentials in code or loaded from a secret manager?

### Evidence Chain
- Quote the misconfiguration file:line (IAM statement with wildcard action/resource, security-group ingress block, or the credential literal)
- For IAM: show both the `Action` and `Resource` values proving the wildcard scope
- For security groups: quote the CIDR (`0.0.0.0/0`) and the port/protocol, and state why the port is sensitive (SSH, RDP, database) rather than public web traffic
- For credentials: quote the hardcoded key or committed service-account JSON path and confirm it is not a placeholder or example value
- Link the config to deployed impact: the resource it grants access to or the service it exposes

### Confidence Scoring
- **High**: Unambiguous config evidence — IAM policy with `"Action": "*"` AND `"Resource": "*"`, a security group opening a sensitive port (22, 3389, 5432, 3306) to 0.0.0.0/0, a real cloud access key in source, or a committed service-account JSON.
- **Medium**: Pattern present but context partial — wildcard on action or resource but not both, an open port whose service role is unclear, or a credential-looking string that may be a placeholder.
- **Low**: Cloud SDK or IaC usage detected but the effective policy/exposure can't be determined from the files (variables resolved at deploy time, modules not in repo) — tag `needs human verification`.

### Files to Check
- `**/*.tf`, `**/cloudformation*.yml`, `**/pulumi*.ts`
- `**/iam*.json`, `**/policy*.json`
- `.env*`, `**/credentials*`, `**/serviceaccount*`
