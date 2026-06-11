# lib/ai_security.sh — AI-surface security audit (Workers AI, AI Gateway, Vectorize).
# Exposes:
#   ai_security_run     — read-only; flags missing rate limits, missing logs, unauthed Vectorize.
#   ai_security_fix     — recommends mitigations; never silently applies rate limits.
# Side effects:
#   - Reads cwd files (wrangler.*, source). Never mutates user code.

# _ai_sec_has_wrangler_block <regex> -> rc 0 if found in any wrangler.toml/jsonc/json in cwd.
_ai_sec_has_wrangler_block() {
  local rx="$1"
  local f
  for f in wrangler.toml wrangler.jsonc wrangler.json; do
    [[ -f "$f" ]] || continue
    grep -qE "$rx" "$f" && return 0
  done
  return 1
}

# _ai_sec_grep_source <pattern> -> rc 0 if found anywhere in src/ + repo (heuristic).
_ai_sec_grep_source() {
  local pat="$1"
  if grep -rqsE --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.mjs' --include='*.cjs' --include='*.py' --include='*.go' --include='*.rb' "$pat" . 2>/dev/null; then
    return 0
  fi
  return 1
}

# _ai_sec_check_workers_ai
_ai_sec_check_workers_ai() {
  if _ai_sec_has_wrangler_block '^\[ai\]|"ai"[[:space:]]*:|binding[[:space:]]*=[[:space:]]*"AI"'; then
    log_ok "ai-security" "workers-ai" "Workers AI binding detected in wrangler.*."
    log_warn "ai-security" "workers-ai-rate-limit" "Workers AI endpoints exposed via Workers should sit behind a rate limit (account-level Rate Limiting Rule or Workers Rate Limiting binding) to bound spend." "https://developers.cloudflare.com/waf/rate-limiting-rules/"
    log_warn "ai-security" "workers-ai-prompt-injection" "Treat user input as untrusted. Sanitize / template prompts; reject system-prompt overrides; never echo secrets back from the model context." "https://developers.cloudflare.com/workers-ai/"
    return 0
  fi
  log_info "no Workers AI binding in wrangler.*."
}

# _ai_sec_check_ai_gateway
_ai_sec_check_ai_gateway() {
  if _ai_sec_grep_source 'gateway\.ai\.cloudflare\.com'; then
    log_ok "ai-security" "ai-gateway" "AI Gateway URL pattern detected in source."
    log_warn "ai-security" "ai-gateway-logs" "Verify AI Gateway logs are enabled at https://dash.cloudflare.com/?to=/:account/ai/. Logs power cost / abuse / quality monitoring; off by default for some setups." "https://developers.cloudflare.com/ai-gateway/observability/logging/"
    log_warn "ai-security" "ai-gateway-auth" "If your Worker proxies provider keys, gate the AI Gateway endpoint with a Worker-side auth (signed request, JWT, or per-route token). Never expose the gateway URL with provider creds bare to browsers." "https://developers.cloudflare.com/ai-gateway/configuration/authentication/"
    return 0
  fi
  log_info "no AI Gateway usage detected (gateway.ai.cloudflare.com)."
}

# _ai_sec_check_vectorize
_ai_sec_check_vectorize() {
  if _ai_sec_has_wrangler_block '\[\[vectorize\]\]|"vectorize"[[:space:]]*:'; then
    log_ok "ai-security" "vectorize" "Vectorize binding detected in wrangler.*."
    log_warn "ai-security" "vectorize-auth" "Vectorize is bound directly to the Worker, so the Worker IS the auth boundary. Confirm every code path that hits VECTORIZE_INDEX.query / .insert is reachable only by authenticated callers." "https://developers.cloudflare.com/vectorize/"
    return 0
  fi
  log_info "no Vectorize binding in wrangler.*."
}

ai_security_run() {
  log_section "AI security"
  _ai_sec_check_workers_ai
  _ai_sec_check_ai_gateway
  _ai_sec_check_vectorize
}

ai_security_fix() {
  log_section "AI security fix (recommendations)"
  log_info "This 'fix' does not silently mutate AI surfaces — it prints recommended actions only."

  if _ai_sec_has_wrangler_block '^\[ai\]|"ai"[[:space:]]*:|binding[[:space:]]*=[[:space:]]*"AI"' \
    || _ai_sec_grep_source 'gateway\.ai\.cloudflare\.com'; then
    log_subsection "rate limit recommendation"
    cat <<'EOF'
Recommended Rate Limiting Rule (free tier on every plan via WAF Rate Limiting Rules):
  - When incoming requests match: (http.request.uri.path matches "^/api/(ai|chat|embed|completions)")
  - Rate: 30 requests / 60 seconds per IP (tune to your traffic)
  - Action: Block (or Managed Challenge)
  - Description tag: cloudflare-secure:ai-rate-limit
The skill does NOT auto-apply this rule because mis-tuned rate limits can lock out real users.
Apply it via the dashboard (Security -> WAF -> Rate Limiting Rules) or via:
  bash snitch-cloudflare.sh fix rate-limit  (if a generic rate-limit fixer is shipped)
EOF
  fi

  if _ai_sec_grep_source 'gateway\.ai\.cloudflare\.com'; then
    log_subsection "AI Gateway logging recommendation"
    cat <<'EOF'
Enable AI Gateway logs:
  Dashboard -> AI -> AI Gateway -> <your gateway> -> Settings -> "Log Requests" = ON.
Recommended retention: keep at least 14 days. Logs are how you'll catch:
  - prompt-injection attempts
  - runaway agents looping
  - unexpected per-user cost spikes
EOF
  fi

  if _ai_sec_has_wrangler_block '\[\[vectorize\]\]|"vectorize"[[:space:]]*:'; then
    log_subsection "Vectorize auth review"
    cat <<'EOF'
Vectorize is bound directly to the Worker. There is no separate "API key" surface.
Action: in source, confirm every Vectorize call is inside a code path that has already authenticated the caller.
A common bug pattern: a /search endpoint that calls VECTORIZE_INDEX.query() without auth, leaking embedded
training-data fragments to anonymous users. Read your routes/handlers to verify.
EOF
  fi
}
