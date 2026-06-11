# lib/gha.sh — emit GitHub Actions workflows for cf-secure check on PR + terraform plan.
# Exposes:
#   gha_fix — emits two workflow files via the stdout File-writes pattern.
# Never writes inside the user's repo; the agent applies via Edit/Write.

# _gha_load_template <name> -> echoes content from templates/github-actions/<name> or empty
_gha_load_template() {
  local name="$1"
  local f="${TPL_DIR}/github-actions/${name}"
  [[ -f "$f" ]] && cat "$f"
}

# _gha_emit <relative_path> <body>
_gha_emit() {
  local path="$1" body="$2"
  printf '\n=== FILE: %s ===\n' "$path"
  printf '=== DIFF ===\n'
  printf -- '--- /dev/null\n+++ %s\n' "$path"
  printf '%s\n' "$body" | sed 's/^/+/'
  printf '=== CONTENT ===\n'
  printf '%s\n' "$body"
  printf '=== END ===\n'
}

# _gha_pr_workflow_default
_gha_pr_workflow_default() {
  cat <<'YAML_EOF'
name: cf-secure on PR

on:
  pull_request:
    branches: [main, master]
  workflow_dispatch:

jobs:
  cf-secure-check:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          sudo apt-get update -y
          sudo apt-get install -y jq curl

      - name: Fetch snitch-cloudflare skill
        run: |
          mkdir -p .cf-secure
          # Replace this with your skill source of truth:
          # - private GitHub repo: actions/checkout with ssh-key
          # - tarball pinned to a commit
          # - or vendor the skill into the repo
          if [ -d "$HOME/.claude/skills/snitch-cloudflare" ]; then
            cp -R "$HOME/.claude/skills/snitch-cloudflare" .cf-secure/snitch-cloudflare
          else
            echo "::warning::vendor or fetch the snitch-cloudflare skill before this step"
            exit 0
          fi

      - name: Run posture audit (read-only)
        id: cfsec
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          CFSEC_ZONE_ID: ${{ vars.CFSEC_ZONE_ID }}
        run: |
          set +e
          # `audit all` emits a JSON envelope (lenses[] + delegated[] + compose_also[]).
          bash .cf-secure/snitch-cloudflare/snitch-cloudflare.sh audit all > cf-audit.json 2> cf-audit.err
          rc=$?
          errors=$(jq '[.. | objects | select(has("error"))] | length' cf-audit.json 2>/dev/null || echo 0)
          echo "errors=${errors:-0}" >> "$GITHUB_OUTPUT"
          echo "rc=$rc" >> "$GITHUB_OUTPUT"
          exit 0

      - name: Comment results on PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            let body = '';
            try { body = fs.readFileSync('cf-audit.json', 'utf8'); } catch (e) {}
            let pretty = body;
            try { pretty = JSON.stringify(JSON.parse(body), null, 2); } catch (e) {}
            const trimmed = pretty.length > 60000 ? pretty.slice(0, 60000) + '\n... (truncated)' : (pretty || '(no output)');
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: '## snitch-cloudflare audit\n\n```json\n' + trimmed + '\n```'
            });

      - name: Fail on operational errors
        run: |
          if [ "${{ steps.cfsec.outputs.rc }}" != "0" ] || [ "${{ steps.cfsec.outputs.errors }}" -gt 0 ]; then
            echo "::error::snitch-cloudflare audit hit operational errors (rc=${{ steps.cfsec.outputs.rc }}, errors=${{ steps.cfsec.outputs.errors }})"
            exit 1
          fi
YAML_EOF
}

# _gha_terraform_workflow_default
_gha_terraform_workflow_default() {
  cat <<'YAML_EOF'
name: cf-terraform plan

on:
  pull_request:
    paths:
      - '**/*.tf'
      - '**/*.tfvars'
  workflow_dispatch:

jobs:
  terraform-plan:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    env:
      TF_IN_AUTOMATION: "true"
      CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: terraform init
        run: terraform init -input=false

      - name: terraform validate
        run: terraform validate -no-color

      - name: terraform plan
        id: plan
        run: |
          set +e
          terraform plan -no-color -input=false -out=tfplan 2>&1 | tee tfplan.txt
          echo "exitcode=$?" >> "$GITHUB_OUTPUT"

      - name: Comment plan on PR
        if: github.event_name == 'pull_request'
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const body = fs.readFileSync('tfplan.txt', 'utf8');
            const trimmed = body.length > 60000 ? body.slice(0, 60000) + '\n... (truncated)' : body;
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: '## terraform plan (Cloudflare)\n\n```hcl\n' + trimmed + '\n```'
            });
YAML_EOF
}

# gha_fix — emit both workflow files via stdout File-writes pattern.
gha_fix() {
  log_section "GitHub Actions workflows"

  local pr_body tf_body
  pr_body="$(_gha_load_template 'cf-secure-on-pr.yml')"
  [[ -z "$pr_body" ]] && pr_body="$(_gha_pr_workflow_default)"

  tf_body="$(_gha_load_template 'cf-terraform-plan.yml')"
  [[ -z "$tf_body" ]] && tf_body="$(_gha_terraform_workflow_default)"

  log_info "emitting .github/workflows/cf-secure-on-pr.yml (set repo secret CLOUDFLARE_API_TOKEN)"
  _gha_emit ".github/workflows/cf-secure-on-pr.yml" "$pr_body"

  log_info "emitting .github/workflows/cf-terraform-plan.yml (opt-in; agent can skip if not using Terraform)"
  _gha_emit ".github/workflows/cf-terraform-plan.yml" "$tf_body"

  log_ok "gha" "emit" "Two workflow files emitted. Apply via Edit/Write after review."
}
