# lib/_state_helpers.sh — shared helpers for state_*.sh.
# Sourced by per-area state libs as needed. No side effects on its own.

# _state_header_check
# Verifies CLOUDFLARE_API_TOKEN equivalent — i.e. AWS creds resolve.
# On failure emits JSON-on-stderr and returns non-zero.
_state_header_check() {
  if ! command -v aws >/dev/null 2>&1; then
    printf '{"error":"aws CLI not installed","code":"E_AUTH","remediation":"brew install awscli or https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"}\n' >&2
    return 2
  fi
  local caller
  caller="$(aws sts get-caller-identity --output json 2>/dev/null)"
  if [[ -z "$caller" ]]; then
    printf '{"error":"no AWS credentials resolved","code":"E_AUTH","remediation":"export AWS_PROFILE=<sso-profile> and run aws sso login"}\n' >&2
    return 2
  fi
  return 0
}

# _state_emit_error <stderr_msg> <code> <remediation>
_state_emit_error() {
  local msg="$1" code="$2" remediation="${3:-}"
  jq -n --arg m "$msg" --arg c "$code" --arg r "$remediation" \
    '{error:$m, code:$c, remediation:$r}' >&2
}
