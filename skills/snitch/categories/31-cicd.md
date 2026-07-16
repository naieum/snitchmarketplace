## CATEGORY 31: CI/CD Pipeline Security
> Type: posture · Groups: infra-supply-chain · CWE: CWE-200

### Detection
- GitHub Actions: `.github/workflows/*.yml`
- GitLab CI: `.gitlab-ci.yml`
- Other CI: `Jenkinsfile`, `.circleci/config.yml`, `azure-pipelines.yml`

### What to Search For
- Secrets hardcoded in workflow files (not using `${{ secrets.* }}`)
- `pull_request_target` trigger with checkout of PR code (script injection vector)
- Workflow `permissions` not scoped (defaults to write-all)
- Expression injection in `run:` steps (e.g., `${{ github.event.issue.title }}` in shell)
- Third-party actions pinned to branch tags instead of commit SHA
- Self-hosted runners without isolation

### Actually Vulnerable
- API key or token as plain string in workflow YAML (not `${{ secrets.KEY }}`)
- Workflow with `pull_request_target` that checks out PR branch and runs PR code
- No `permissions:` key in workflow (inherits overly broad defaults)
- `run: echo ${{ github.event.comment.body }}` (arbitrary code injection via comment)
- `uses: actions/checkout@main` instead of `uses: actions/checkout@SHA`
- Self-hosted runner used for public repository workflows

### NOT Vulnerable
- Secrets referenced via `${{ secrets.* }}` syntax
- `pull_request` trigger (safe, runs in context of PR fork)
- Explicit `permissions:` with minimal scopes (e.g., `contents: read`)
- GitHub context values used in `with:` inputs (not shell `run:`)
- Actions pinned to full SHA (`uses: actions/checkout@abc123...`)
- Self-hosted runners for private repos with proper isolation

### Context Check
1. Is this a public or private repository?
2. Does the workflow use `pull_request_target` with code checkout?
3. Are GitHub context values used in shell `run:` commands or action `with:` inputs?
4. Are third-party actions pinned to commit SHAs?

### Evidence Chain
A finding's Evidence block must show:
- The workflow/config snippet file:line showing the misconfiguration (plaintext secret, trigger, missing `permissions:`, unpinned action, expression in `run:`)
- The trigger context that makes it attacker-reachable (e.g., `pull_request_target` on a public repo, issue/comment-driven event)
- For injection findings: the attacker-controllable value's path (`${{ github.event.* }}`) into a shell `run:` step or into checked-out-and-executed PR code
- What protection is absent: no `permissions:` scoping, branch/tag pin instead of commit SHA, secret not referenced via `${{ secrets.* }}`
- Repository visibility (public vs. private) where it changes impact

### Confidence Scoring
- **High**: unambiguous config — plaintext secret in workflow YAML; `pull_request_target` + PR-branch checkout + execution; `github.event.*` interpolated into a shell `run:` on an attacker-controllable event
- **Medium**: pattern present but exploitability is partial — missing `permissions:` key (impact depends on org/repo defaults), branch-pinned action from a reputable publisher, or a private repo reducing exposure
- **Low**: repo visibility, runner isolation, or org-level policy cannot be determined from the code alone — tag `needs human verification`

### Files to Check
- `.github/workflows/*.yml`
- `.gitlab-ci.yml`, `Jenkinsfile`
- `.circleci/config.yml`
- CI/CD configuration in `package.json` scripts
