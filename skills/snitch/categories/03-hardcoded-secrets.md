## CATEGORY 3: Hardcoded Secrets
> Type: posture · Groups: secrets-auth, quick-core · CWE: CWE-798

### Detection
- Any project with source code (universally applicable)
- `.env` files, config files, source files with string literals
- CI/CD configuration files

### What to Search For
- API keys assigned as string literals
- Passwords in code
- AWS access keys (AKIA prefix)
- Stripe keys (sk_live_, sk_test_)
- Private keys in source files

### Actually Vulnerable
- Real API keys assigned to variables
- Real passwords hardcoded in source
- AWS access keys embedded in code
- Private keys stored in source files

### NOT Vulnerable
- Environment variable references (process.env.X)
- Template placeholders
- Example values in comments
- Test/development placeholder values
- .env.example with dummy values
- Security scanner pattern definitions
- Real secrets in .env.local or .env.development that are gitignored (flag as Medium, not Critical — not committed to source)

### Context Check
1. Is this a real secret or a placeholder?
2. Is it in a test/example file?
3. Is it documentation or actual code?
4. Is the secret in a file listed in .gitignore (lower severity — not committed to git) vs. committed to source control (higher severity — already in history)?

### Evidence Chain
- The secret assignment quoted at file:line with the value redacted (show prefix/format only, e.g. `sk_live_…`, `AKIA…`)
- Why it is judged real, not a placeholder (recognized provider prefix, realistic entropy/length, no `example`/`changeme`/`xxx` markers)
- The secret's type classification (AWS key, Stripe key, private key, password, etc.) matching a rotation playbook row
- Git exposure status: whether the file is committed to source control vs listed in `.gitignore` — this drives the severity link
- Where the file sits (production config, CI/CD workflow, test fixture, docs) as the impact context

### Confidence Scoring
- **High** — value matches a known provider format (AKIA…, sk_live_…, `-----BEGIN … PRIVATE KEY-----`) in a committed source or CI/CD file with no placeholder markers
- **Medium** — high-entropy literal assigned to a secret-named variable but no recognizable provider prefix, or a real-looking secret in a gitignored env file
- **Low** — secret-named variable with a value that could plausibly be a placeholder or test fixture, and file context doesn't settle it → tag `needs human verification`

### Files to Check
- `.env*`, `**/*.config.*`, `**/config/**`
- `docker-compose*.yml`, `Dockerfile*`
- CI/CD files: `.github/workflows/*`, `.gitlab-ci.yml`

### Secret Rotation Playbooks

When a hardcoded secret is detected, match the type and provide specific rotation steps in the finding's Fix field:

| Secret Type | Rotation Steps |
|------------|---------------|
| AWS Access Key | Create new key: `aws iam create-access-key --user-name X` → deactivate old key → update environment variables |
| Stripe Secret Key | Dashboard → Developers → API Keys → Roll Key → update environment variables |
| GitHub PAT | Settings → Developer Settings → Personal Access Tokens → Regenerate → update CI secrets |
| Supabase Service Key | Dashboard → Settings → API → Generate new key → update environment variables |
| Database Connection String | Create new database user/password → update connection string → revoke old credentials |
| JWT Secret | Generate new secret → deploy with dual-accept period → remove old secret |
| SendGrid/Resend API Key | Dashboard → API Keys → Create new → delete old → update environment variables |
| OpenAI/Anthropic API Key | Dashboard → API Keys → Create new → revoke old → update environment variables |
| SSH Private Key | Generate new key: `ssh-keygen -t ed25519` → add public key to authorized_keys → remove old key |
| Generic/Unknown | Move to environment variable or secret manager (Vault, AWS SSM, 1Password CLI) |

**Usage in findings:** When reporting a hardcoded secret, include the matching rotation playbook in the **Fix** field. Example:
```
## Finding: Hardcoded Stripe Secret Key
- **Fix:** Move to environment variable. **Rotation:** Dashboard → Developers → API Keys → Roll Key → update env vars. The old key is compromised — rolling it invalidates the exposed value.
```
