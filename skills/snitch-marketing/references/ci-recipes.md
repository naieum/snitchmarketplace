# CI/CD Integration Recipes

Snitch: Marketing's diff-mode is most useful when it runs automatically on every PR, surfacing SEO regressions before they ship. This reference is the concrete patterns for integrating the audit into common CI/CD platforms. Each recipe covers: trigger event, scoped run, comment posting, blocking vs advisory mode.

## Why diff-mode in CI

A full audit on every PR is wasteful (90+ minutes per run). Diff-mode runs only on the files that changed AND their declared route layouts / heads. This typically scans 5-30 files in 2-5 minutes, catching regressions like:

- Canonical accidentally removed from a route head
- Title / description regressed below recommended length
- Schema.org JSON-LD lost in a refactor
- A new page added without alt text on its hero image
- `noindex` accidentally shipped to a route

## Recipe 1: GitHub Actions (most common)

```yaml
# .github/workflows/snitch-marketing.yml
name: SEO Audit (diff mode)

on:
  pull_request:
    paths:
      - 'src/routes/**'
      - 'src/pages/**'
      - 'app/**'
      - 'content/**'
      - '**/*.tsx'
      - '**/*.mdx'

jobs:
  seo-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # needed for diff against base ref

      # The skill runs inside an AI coding CLI — there is no Snitch-hosted Action.
      # Swap the CLI and the key for whichever provider you already use.
      - name: Run Snitch Marketing diff audit
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          npm install -g @anthropic-ai/claude-code
          claude --print "Read ./skills/snitch-marketing/SKILL.md and run a diff-mode
            SEO audit against ${{ github.base_ref }}. Write SEO_AUDIT_REPORT.md."

      - name: Upload audit report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: seo-audit-report
          path: SEO_AUDIT_REPORT.md
```

### Variants

- **Block on critical only**: `fail-on: critical` — PR can't merge if any Critical finding.
- **Advisory mode**: `fail-on: never` — always succeeds; comment is informational.
- **Block on high+**: `fail-on: high` — fails if any High or Critical.

### PR comment format

The action posts (or updates) one comment per PR:

```markdown
## Snitch: Marketing — Diff Audit

Scanned 7 changed files. Detected:

**Critical (1)**
- `src/routes/blog/post.tsx:14` — Cat 3: Canonical accidentally removed in refactor

**High (2)**
- `src/routes/blog/post.tsx:18` — Cat 9: Title regressed to 14 chars (was 52)
- `src/routes/blog/post.tsx:23` — Cat 10: Meta description missing

**Medium (3)**
- `src/components/Hero.tsx:8` — Cat 25: Image alt missing
- `src/routes/changelog.tsx:11` — Cat 11: OG image not absolute URL
- `src/routes/changelog.tsx:42` — Cat 31: JSON-LD block removed

Re-run after fixing: `git push`.

[Full report](link to artifact)
```

## Recipe 2: GitLab CI

```yaml
# .gitlab-ci.yml
seo_audit:
  stage: test
  image: node:22  # any image with your AI CLI installable — there is no Snitch-hosted runner
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
      changes:
        - 'src/routes/**'
        - 'src/pages/**'
        - 'content/**'
        - '**/*.{tsx,mdx}'
  script:
    - npm install -g @anthropic-ai/claude-code
    - claude --print "Read ./skills/snitch-marketing/SKILL.md and run a diff-mode SEO audit
      against $CI_MERGE_REQUEST_TARGET_BRANCH_NAME. Write SEO_AUDIT_REPORT.md."
  artifacts:
    when: always
    paths:
      - SEO_AUDIT_REPORT.md
    expire_in: 30 days
  allow_failure: false  # set to true for advisory-only
```

GitLab equivalent of GitHub's PR comment is the MR Discussion API. The runner can POST findings as a discussion via `$CI_PROJECT_ID` + the merge-request IID.

## Recipe 3: Vercel build hook

Vercel previews are the canonical "see the change before merging" surface. Run the audit against the preview URL:

```yaml
# vercel.json (in repo root)
{
  "github": {
    "silent": false
  },
  "buildCommand": "npm run build && npm run seo:audit:preview"
}
```

```json
// package.json
{
  "scripts": {
    "seo:audit:preview": "snitch-marketing audit --url=$VERCEL_URL --mode=crawl"
  }
}
```

Vercel populates `$VERCEL_URL` for preview builds. The audit runs in crawl mode against the live preview, catches runtime-only regressions (post-hydration content, client-side schema), and uploads results.

For PR comments on Vercel previews: install the `vercel-output-format` plugin OR use the Vercel REST API to post a comment via a follow-up GitHub Actions step.

## Recipe 4: Cloudflare Pages preview deploy

```bash
# .github/workflows/cloudflare-preview-audit.yml
name: SEO Audit on CF Pages preview

on:
  deployment_status:

jobs:
  audit-preview:
    if: github.event.deployment_status.state == 'success' && github.event.deployment_status.environment == 'preview'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: |
          PREVIEW_URL="${{ github.event.deployment_status.target_url }}"
          snitch-marketing audit --url="$PREVIEW_URL" --mode=crawl --comment-on-pr
```

## Recipe 5: Pre-commit hook (git)

Pre-commit catches regressions before they're even pushed. Use `husky` + custom script:

```json
// package.json
{
  "scripts": {
    "seo:audit:precommit": "snitch-marketing audit --mode=diff --base-ref=HEAD~1 --fail-on=critical"
  },
  "husky": {
    "hooks": {
      "pre-commit": "npm run seo:audit:precommit"
    }
  }
}
```

Pre-commit is best for advisory: blocking commits on every Medium finding will be too noisy. Tune `--fail-on=critical` and let the team triage High/Medium in the PR review.

## Recipe 6: Post-deploy production audit (canary)

After production deploy, run a full audit (not diff) to catch any production-specific issues a preview-deploy didn't surface:

```yaml
# .github/workflows/post-deploy-audit.yml
name: Post-deploy SEO audit

on:
  workflow_run:
    workflows: ['Deploy production']
    types: [completed]

jobs:
  audit:
    if: github.event.workflow_run.conclusion == 'success'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: snitch-marketing audit --url=https://example.com --mode=crawl --preset=quick
      - if: failure()
        uses: actions/setup-node@v4
        # post to Slack via webhook — alert team to production regression
```

## Mode selection per CI scenario

| Scenario | Mode | Preset | Why |
|---|---|---|---|
| PR diff audit | diff (source) | derived from changed files | Fast, scoped, advisory |
| Preview deploy | crawl | quick | Catches runtime issues SSR diff misses |
| Pre-commit | diff (source) | critical-only | Blocks regressions but doesn't slow commits |
| Post-production deploy | crawl | quick or technical | Catches production-only issues |
| Quarterly full audit | source + crawl | full | Comprehensive review for stakeholder reporting |

## Token cost considerations

Diff-mode on a typical 5-30 file change runs in 2-5 minutes and is cheap to run on every PR. Full audits run 90-180 minutes and should be scheduled (weekly / monthly) rather than per-PR. Crawl-mode is bound by network latency more than token count and is reasonable per PR.

## Triage state in CI

The `.snitch-marketing-triage.json` and `.snitch-marketing-ignore` files (see `triage-workflow.md`) should be committed to the repo. CI audits read these and suppress already-triaged findings. This keeps PR comments focused on NEW findings, not re-flags of accepted ones.

## Output artifacts

CI audits should always upload `SEO_AUDIT_REPORT.md` as an artifact, even on success — historical reports are useful for trend analysis and post-mortem after a regression.

For long-term trend tracking, consider piping the report's metadata to a metrics endpoint (Datadog, custom analytics, internal dashboard) capturing finding count + severity distribution over time.

## Cross-references

- SKILL.md STEP 1 (Scan Selection Menu — Option 12 Diff Mode)
- `triage-workflow.md` — `.snitch-marketing-ignore` and `.snitch-marketing-triage.json` formats
- `category-groups.md` — preset definitions used by `--preset=quick / technical / etc.`
