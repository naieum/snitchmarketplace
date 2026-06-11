# lib/api.sh — AWS CLI helpers.
# Every other lib/*.sh that calls AWS uses these. Reads AWS_PROFILE / AWS_REGION /
# default-chain credentials. Refuses to operate with long-lived AKIA* access keys
# when an SSO profile is available, or with no credentials at all.

AWSSEC_LAST_STDERR=""
AWSSEC_LAST_STATUS=""
AWSSEC_CALL_LOG="${STATE_DIR:-/tmp}/api-calls.log"
AWSSEC_DEFAULT_REGION_FALLBACK="${AWSSEC_DEFAULT_REGION_FALLBACK:-us-east-1}"

# Refuse long-lived AKIA keys when SSO is configured. Always refuse when no creds.
api_check_auth_env() {
  if [[ "${AWS_ACCESS_KEY_ID:-}" == AKIA* ]]; then
    if [[ -f "$HOME/.aws/config" ]] && grep -E -q '^[[:space:]]*sso_(start_url|session)' "$HOME/.aws/config" 2>/dev/null; then
      log_fail "auth" "long-lived-key" "AWS_ACCESS_KEY_ID starts with AKIA (long-lived static key) and an SSO profile is available in ~/.aws/config. Refusing to use the long-lived key. Run: unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY; AWS_PROFILE=<sso-profile> aws sso login" "https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html"
      return 2
    fi
    log_warn "auth" "long-lived-key" "AWS_ACCESS_KEY_ID starts with AKIA (long-lived static key). Consider switching to IAM Identity Center / SSO." "https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html"
  fi

  if ! command -v aws >/dev/null 2>&1; then
    log_fail "auth" "no-cli" "aws CLI not installed. Install: 'brew install awscli' (macOS) or follow https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html" "https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    return 2
  fi

  # Try sts get-caller-identity to verify creds resolve.
  local caller
  caller="$(aws sts get-caller-identity --output json 2>/dev/null)"
  if [[ -z "$caller" ]]; then
    log_fail "auth" "no-creds" "No AWS credentials resolved from environment / profile / instance role. Run: aws configure sso  OR  export AWS_PROFILE=<existing-profile>" "https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-authentication.html"
    return 2
  fi
  return 0
}

# aws_run <args...>  — runs aws CLI, captures stderr in AWSSEC_LAST_STDERR.
# Returns the CLI's exit code. The output is always echoed on stdout.
aws_run() {
  local stderr_tmp; stderr_tmp="$(mktemp)"
  local rc=0
  local out
  out="$(aws "$@" 2>"$stderr_tmp")" || rc=$?
  AWSSEC_LAST_STDERR="$(cat "$stderr_tmp" 2>/dev/null)"
  AWSSEC_LAST_STATUS="$rc"
  rm -f "$stderr_tmp"
  printf '%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "aws $*" "rc=$rc" >> "$AWSSEC_CALL_LOG" 2>/dev/null || true
  printf '%s' "$out"
  return $rc
}

# aws_run_json <args...> — same as aws_run but pinned to --output json.
# Always emits parseable JSON on stdout (`{}` if the call returned nothing).
aws_run_json() {
  local out
  out="$(aws_run --output json "$@")"
  local rc=$?
  if [[ -z "$out" ]]; then
    printf '{}'
  else
    printf '%s' "$out"
  fi
  return $rc
}

# aws_pick_account — resolves and caches the current account id.
aws_pick_account() {
  if [[ -n "${AWSSEC_ACCOUNT_ID:-}" ]]; then
    printf '%s' "$AWSSEC_ACCOUNT_ID"
    return 0
  fi
  local cache="${STATE_DIR}/account-id.txt"
  if [[ -s "$cache" ]]; then
    cat "$cache"
    return 0
  fi
  local body acct
  body="$(aws_run_json sts get-caller-identity)" || return 3
  acct="$(jq -r '.Account // empty' <<<"$body" 2>/dev/null)"
  if [[ -z "$acct" ]]; then
    log_fail "auth" "account" "Could not resolve account id from sts get-caller-identity"
    return 3
  fi
  printf '%s' "$acct" > "$cache"
  printf '%s' "$acct"
}

# aws_pick_region — resolves the active region (env > AWSSEC_REGION > AWS_REGION > AWS_DEFAULT_REGION > profile > us-east-1).
aws_pick_region() {
  local r=""
  if [[ -n "${AWSSEC_REGION:-}" ]]; then r="$AWSSEC_REGION"
  elif [[ -n "${AWS_REGION:-}" ]];     then r="$AWS_REGION"
  elif [[ -n "${AWS_DEFAULT_REGION:-}" ]]; then r="$AWS_DEFAULT_REGION"
  else
    r="$(aws configure get region 2>/dev/null || true)"
  fi
  if [[ -z "$r" ]]; then
    r="$AWSSEC_DEFAULT_REGION_FALLBACK"
  fi
  printf '%s' "$r"
}

# aws_caller_identity — emits the parsed sts get-caller-identity JSON.
aws_caller_identity() {
  aws_run_json sts get-caller-identity
}

# doctor_run: foundation check; called from `doctor`.
doctor_run() {
  local rc=0
  if ! command -v aws >/dev/null 2>&1; then
    log_fail "doctor" "aws-cli" "aws CLI v2 is required. Install: brew install awscli (macOS) or https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    rc=2
  else
    local v; v="$(aws --version 2>&1 | head -n1)"
    log_ok "doctor" "aws-cli" "$v"
  fi
  if ! command -v jq >/dev/null 2>&1; then
    log_fail "doctor" "jq" "jq is required. Install via: brew install jq  (macOS) or apt-get install jq  (Linux)."
    rc=2
  else
    log_ok "doctor" "jq" "jq present."
  fi

  api_check_auth_env || rc=$?

  if command -v aws >/dev/null 2>&1; then
    local caller
    caller="$(aws sts get-caller-identity --output json 2>/dev/null)"
    if [[ -n "$caller" ]]; then
      local acct arn ut
      acct="$(jq -r '.Account // "?"' <<<"$caller")"
      arn="$(jq -r '.Arn // "?"' <<<"$caller")"
      ut="$(jq -r '.UserId // "?"' <<<"$caller")"
      log_ok "doctor" "sts" "account=${acct} arn=${arn} userid=${ut}"
    fi
    local region; region="$(aws_pick_region)"
    log_ok "doctor" "region" "active region: ${region}"
    local profile; profile="${AWS_PROFILE:-${AWS_DEFAULT_PROFILE:-default}}"
    log_ok "doctor" "profile" "active profile: ${profile}"
  fi

  if [[ -n "${AWSSEC_MCP_PRESENT:-}" ]]; then
    log_ok "doctor" "mcp" "AWS MCP detected — agent will prefer it for typed inventory reads."
  else
    log_warn "doctor" "mcp" "No AWS MCP detected. The skill works fine via the aws CLI; install an AWS MCP for typed inventory reads if available." "https://github.com/aws/aws-mcp-server"
  fi

  return $rc
}
