# lib/apply_databases.sh — DB version EOL audit + backup recommendation.
# Read-only with mutation recommendations: emits CLI/SQL commands the user runs.
# Exports: apply_databases [project-id]

apply_databases() {
  local project_id="${1:-}"
  if [[ -z "$project_id" ]]; then
    project_id="$(api_pick_project 2>/dev/null)" || {
      log_fail "databases" "pick" "could not resolve project id"
      return 3
    }
  fi
  log_section "databases hardening for project=${project_id}"

  . "$LIB_DIR/state_databases.sh"
  local digest
  digest="$(run_state_databases "$project_id" digest 2>/dev/null)"
  if [[ -z "$digest" ]] || ! jq -e '.databases_summary' >/dev/null 2>&1 <<<"$digest"; then
    log_fail "databases" "read" "could not read databases digest"
    return 3
  fi

  local total eol_count deprecated_count
  total="$(jq '.databases_summary.total // 0' <<<"$digest")"
  eol_count="$(jq '.databases_summary.eol // [] | length' <<<"$digest")"
  deprecated_count="$(jq '.databases_summary.deprecated // [] | length' <<<"$digest")"

  log_info "found ${total} database service(s)"

  if [[ "$eol_count" == "0" && "$deprecated_count" == "0" ]]; then
    log_ok "databases" "version" "no EOL or deprecated DB versions detected."
  else
    if [[ "$eol_count" -gt 0 ]]; then
      log_fail "databases" "eol" "${eol_count} database(s) on EOL versions — security patches no longer issued."
      jq -r '.databases_summary.eol // [] | .[] | "  - \(.kind) \(.version) on service \(.service_name) → upgrade urgently"' <<<"$digest" >&2
    fi
    if [[ "$deprecated_count" -gt 0 ]]; then
      log_warn "databases" "deprecated" "${deprecated_count} database(s) on deprecated versions — patch window closing."
      jq -r '.databases_summary.deprecated // [] | .[] | "  - \(.kind) \(.version) on service \(.service_name) → plan upgrade"' <<<"$digest" >&2
    fi
  fi

  # Backup recommendation (always WARN — Railway has no managed snapshot product).
  if [[ "$total" -gt 0 ]]; then
    log_warn "databases" "backup" "Railway does not provide a managed snapshot product. Recommend logical dumps to R2/S3 on a schedule (cron service or GitHub Actions)." "https://docs.railway.com/reference/volumes"
    log_subsection "recommended backup workflow"
    printf '\n=== FILE: .github/workflows/db-backup.yml ===\n=== DIFF ===\n(new file)\n=== CONTENT ===\n'
    cat <<'EOF'
name: railway-db-backup
on:
  schedule:
    - cron: "0 6 * * *"  # daily 06:00 UTC
  workflow_dispatch:
jobs:
  dump:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install postgres client
        run: sudo apt-get update && sudo apt-get install -y postgresql-client awscli
      - name: Dump and ship to S3
        env:
          DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
          AWS_ACCESS_KEY_ID: ${{ secrets.S3_ACCESS_KEY }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.S3_SECRET_KEY }}
          AWS_DEFAULT_REGION: us-east-1
        run: |
          ts=$(date -u +%Y%m%dT%H%M%SZ)
          pg_dump --format=custom --no-owner "$DATABASE_URL" \
            | gzip > backup-$ts.dump.gz
          aws s3 cp backup-$ts.dump.gz s3://my-db-backups/railway/
EOF
    printf '\n=== END ===\n'
  fi
}
