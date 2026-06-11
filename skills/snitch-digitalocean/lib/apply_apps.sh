# lib/apply_apps.sh — App Platform hardening.
# Idempotent: warns on plain envs that look like secrets, missing health
# checks, no HTTPS redirect (App Platform serves HTTPS by default but the
# user's app must not 301 to http).
#
# Exports: apply_apps [args]

apply_apps() {
  local body; body="$(do_get /apps?per_page=200)" || {
    log_fail "apps" "list" "Could not list apps. $(do_last_error)"
    return 3
  }
  local total; total="$(jq -r '.apps // [] | length' <<<"$body")"
  if [[ "${total:-0}" -eq 0 ]]; then
    log_ok "apps" "list" "No App Platform apps."
    return 0
  fi

  local app_ids; app_ids="$(jq -r '.apps[]? | .id' <<<"$body")"
  while IFS= read -r aid; do
    [[ -z "$aid" ]] && continue
    _apply_apps_one "$aid" "$body"
  done <<<"$app_ids"
}

_apply_apps_one() {
  local aid="$1" body="$2"
  local a; a="$(jq -c --arg id "$aid" '.apps[] | select(.id == $id)' <<<"$body")"
  local name; name="$(jq -r '.spec.name' <<<"$a")"

  # Plain envs that look like secrets
  local plain_secrety
  plain_secrety="$(jq -r '
    [ (.spec.envs // [])[]
      | select((.type // "GENERAL") == "GENERAL")
      | select((.key // "") | test("(?i)(SECRET|TOKEN|PASSWORD|API_KEY|PRIVATE_KEY|CREDENTIAL)"))
      | .key
    ] | join(", ")
  ' <<<"$a")"
  if [[ -n "$plain_secrety" ]]; then
    log_fail "apps" "plain-secrets/${name}" "App-level plain envs look secret-shaped: ${plain_secrety}. Change type to SECRET in app.yaml or via doctl apps update." "https://docs.digitalocean.com/products/app-platform/how-to/use-environment-variables/"
  else
    log_ok "apps" "plain-secrets/${name}" "No app-level plain envs match secret-shaped names."
  fi

  # Per-service: health checks
  local missing_hc
  missing_hc="$(jq -r '[(.spec.services // [])[] | select(.health_check == null) | .name] | join(", ")' <<<"$a")"
  if [[ -n "$missing_hc" ]]; then
    log_warn "apps" "health-check/${name}" "Services without health_check: ${missing_hc}. Add health_check.http_path to app.yaml." "https://docs.digitalocean.com/products/app-platform/concepts/app-spec/"
  else
    log_ok "apps" "health-check/${name}" "All services have health checks."
  fi

  # Per-service: secret-shaped plain envs at service level
  local svc_plain
  svc_plain="$(jq -r '
    [ (.spec.services // [])[] as $s
      | ($s.envs // [])[]
      | select((.type // "GENERAL") == "GENERAL")
      | select((.key // "") | test("(?i)(SECRET|TOKEN|PASSWORD|API_KEY|PRIVATE_KEY|CREDENTIAL)"))
      | "\($s.name).\(.key)"
    ] | join(", ")
  ' <<<"$a")"
  if [[ -n "$svc_plain" ]]; then
    log_fail "apps" "service-plain-secrets/${name}" "Service-level plain envs look secret-shaped: ${svc_plain}. Change type to SECRET."
  fi

  # HTTPS — App Platform terminates TLS at the edge automatically; the only failure mode is the user app sending Location: http://...
  log_info "App Platform terminates TLS at the edge for ${name}; verify your app emits Location: https:// when redirecting."
}
