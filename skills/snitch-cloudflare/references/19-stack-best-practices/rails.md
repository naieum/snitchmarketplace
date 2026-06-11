# Rails on Cloudflare

Verdict: `proxy-only` (Ruby doesn't run on Workers; ActionCable WebSockets don't migrate; Containers beta is the eventual play). Path: Rails on its host + CF in front.

`fit-matrix rails`. `stack-docs rails`.

## Cloudflare-specific

- `config.action_dispatch.trusted_proxies = [..., *cloudflare_v4_cidrs, *cloudflare_v6_cidrs]` — without it, `force_ssl = true` causes redirect loops. FAIL if empty.
- `RAILS_MASTER_KEY` lives as Worker secret (Containers) or env var on origin — never committed. `master.key` in `.gitignore`. FAIL if `master.key` tracked.
- `config.force_ssl = true` in `config/environments/production.rb`. FAIL otherwise.
- Origin reachable only from CF (Tunnel preferred). FAIL if 443/80 public.
- Rate-limit `/users/sign_in` at edge OR `rack-attack` on origin.
- `/up` (Rails 7+) anonymous-friendly, no detail leakage.

## Session / cookies

```ruby
Rails.application.config.session_store :cookie_store,
  key: '_my_app_session', secure: Rails.env.production?, httponly: true, same_site: :lax
```

`secure: true` non-negotiable in prod. FAIL otherwise.

## CSP initializer

Rails 5.2+ ships `config/initializers/content_security_policy.rb`. Set `content_security_policy_nonce_generator` and `content_security_policy_nonce_directives`; tag `<%= javascript_include_tag "app", nonce: true %>`. WARN if missing.

## Logging

`filter_parameters` covers `:password`, `:password_confirmation`, `:credit_card`, `:ssn`, `:token`, `:api_key`. Without it, `Rails.logger.info(params)` leaks credentials.

## Active Storage

Direct upload to R2 via S3-compatible config; never proxy through Rails. URLs via `signed_id` (expiring), not bucket-public.

## Foot-guns

- Old Ruby/Rails: Rails 7+, Ruby 3.1 minimum (3.3 recommended).
- `render inline:` with user input → RCE.
- String-concat SQL: `User.where("email = '#{params[:email]}'")` → FAIL.

## Skill targets

- `force_ssl = true`: FAIL otherwise.
- `trusted_proxies` includes CF CIDRs: FAIL when CF in front.
- Session cookie `secure` + `httponly`: FAIL otherwise.
- `master.key` in `.gitignore`: FAIL if tracked.
- CSP initializer present: WARN if missing.
- `filter_parameters` covers passwords/tokens: WARN if missing.
- Rate limit on auth (rack-attack or CF): WARN if neither.
- No string-concat SQL: FAIL if detected.
- Origin reachable only from CF: FAIL otherwise.
