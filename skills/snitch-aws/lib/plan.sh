# lib/plan.sh — AWS Support plan tier detection + Organizations gating.
# Tier ordering: basic < developer < business < enterprise.
# Cache: ${STATE_DIR}/plan.txt holds the detected Support tier.

# detect_plan -> echoes one of: basic, developer, business, enterprise, unknown
# Detection: aws support describe-services. If access denied → infer Basic.
detect_plan() {
  local cache="${STATE_DIR}/plan.txt"
  if [[ -s "$cache" ]]; then
    cat "$cache"
    return 0
  fi
  local out rc
  out="$(aws_run support describe-services --language en --output json 2>&1)"
  rc=$?
  local tier="unknown"
  if [[ $rc -eq 0 ]]; then
    # Successful call → at least Developer (Basic cannot call Support API).
    # We can't distinguish Developer vs Business vs Enterprise via describe-services.
    # Use describe-severity-levels to differentiate: Enterprise has 'critical'.
    local sev; sev="$(aws_run support describe-severity-levels --output json 2>/dev/null | jq -r '[.severityLevels[]?.code] | join(",")')"
    if printf '%s' "$sev" | grep -q 'critical'; then
      tier="enterprise"
    elif printf '%s' "$sev" | grep -q 'urgent'; then
      tier="business"
    else
      tier="developer"
    fi
  else
    # AccessDenied / SubscriptionRequired → Basic.
    tier="basic"
  fi
  printf '%s' "$tier" > "$cache"
  printf '%s' "$tier"
}

# detect_organization -> echoes "single" | "managed" | "management" | "unknown"
detect_organization() {
  local cache="${STATE_DIR}/org.txt"
  if [[ -s "$cache" ]]; then
    cat "$cache"
    return 0
  fi
  local body rc
  body="$(aws_run_json organizations describe-organization 2>&1)"
  rc=$?
  local kind="single"
  if [[ $rc -eq 0 ]]; then
    local mgmt acct master_id
    mgmt="$(jq -r '.Organization.MasterAccountId // empty' <<<"$body" 2>/dev/null)"
    acct="$(aws_pick_account)"
    if [[ -n "$mgmt" && "$mgmt" == "$acct" ]]; then
      kind="management"
    elif [[ -n "$mgmt" ]]; then
      kind="managed"
    fi
  fi
  printf '%s' "$kind" > "$cache"
  printf '%s' "$kind"
}

# tier_rank <tier> -> integer
tier_rank() {
  case "$1" in
    basic)      echo 0 ;;
    developer)  echo 1 ;;
    business)   echo 2 ;;
    enterprise) echo 3 ;;
    *) echo -1 ;;
  esac
}

# tier_at_least <current> <required> -> 0 if current >= required, else 1
tier_at_least() {
  local cur req cr rr
  cur="$1"; req="$2"
  cr=$(tier_rank "$cur"); rr=$(tier_rank "$req")
  [[ "$cr" -ge "$rr" ]]
}

# requires_tier <area> <key> <message> <required_tier> <docs_url>
# If current tier meets required, returns 0 (caller proceeds).
# Else logs a [N/A locked] entry and returns 1.
requires_tier() {
  local area="$1" key="$2" msg="$3" req="$4" url="${5:-}"
  local cur; cur="$(detect_plan 2>/dev/null)"
  if tier_at_least "$cur" "$req"; then
    return 0
  fi
  log_locked "$area" "$key" "$msg" "$req" "$url"
  return 1
}

# requires_org <area> <key> <message> <docs_url>
# Returns 0 if the account is part of an Organization (managed or management).
requires_org() {
  local area="$1" key="$2" msg="$3" url="${4:-}"
  local kind; kind="$(detect_organization 2>/dev/null)"
  if [[ "$kind" == "management" || "$kind" == "managed" ]]; then
    return 0
  fi
  log_locked "$area" "$key" "$msg" "org" "$url"
  return 1
}
