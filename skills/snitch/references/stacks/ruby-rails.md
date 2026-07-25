# Stack hardening: Ruby / Rails

Loaded when stack detection identifies Rails (`rails` in `Gemfile`, `config/application.rb`,
`app/controllers/`, `config/routes.rb`). Rails is "secure by default" on more axes than almost any
other framework — parameterized ORM, auto-escaping templates, CSRF protection, strong parameters,
signed/encrypted cookies — and nearly all of those defaults are **switched on by a single line in
`config/application.rb`**. That makes Rails the stack where the same code is safe or unsafe
depending on a file you have not opened, so read the config first.

## Read this before grading any controller

`config.load_defaults <version>` in `config/application.rb` selects a whole generation of framework
defaults. It is the single highest-value line in a Rails audit, and several categories give
opposite answers on either side of it.

| Threshold | What it turns on | Affects |
|---|---|---|
| **5.2+** | `action_controller.default_protect_from_forgery = true` — CSRF protection registered on every `ActionController::Base` subclass with no explicit line in any controller | 47 |
| **5.2+** | Encrypted credentials (`config/credentials.yml.enc` + `master.key`) become the idiom | 03 |
| **6.1+** | `action_view.form_with_generates_remote_forms = false` (no CSRF consequence — helpers inject the token either way); stricter cookie serialization | 39 |
| **7.0+** | `active_record.encryption` available; `cookies_serializer = :json` | 12, 65 |

Overrides beat the generation default and live in more than one place — check
`config/initializers/*.rb` and `config/environments/*.rb` as well as `application.rb`.
`config.action_controller.default_protect_from_forgery = false` under a 7.0 default is a real,
easily-missed unprotected state.

**Callbacks are inherited.** `protect_from_forgery`, `before_action :authenticate_user!`, and every
other callback declared in `ApplicationController` applies to every subclass. From Rails 4.0 to 5.1
the generators emitted `protect_from_forgery` in `ApplicationController` *and nowhere else*, so a
controller with no such line is usually protected. **Walk the ancestor chain to
`ActionController::Base` before reporting anything as missing** — grading a controller on its own
text is the most common false-positive generator in this stack.

## Where the sinks are (trace these — Rule 7)

| Pattern | Risk | Cat |
|---|---|---|
| Interpolation **inside the SQL fragment** — `where("ref = '#{x}'")`, `find_by_sql`, `exec_query` | SQL injection | 01 |
| `Arel.sql(params[:sort])` passed to `.order` / `.pluck` — the sanitizer's escape hatch | SQL injection | 01 |
| `.order(params[:sort])`, `.pluck(params[:col])` bare — see the auto-protection below before rating | info disclosure (Medium) | 01 / 12 |
| `raw`, `html_safe`, `sanitize` with a permissive allow-list, `<%== %>` | XSS | 02 |
| `system`, backticks, `%x()`, `Open3` with input | command injection | 10 |
| `Marshal.load`, `YAML.load` (pre-Psych-4), `Oj` in compat mode | insecure deserialization | 65 |
| `redirect_to params[:url]` without allow-list | open redirect | 05 |
| `Net::HTTP` / `HTTParty` / `Faraday` to a user-supplied URL | SSRF / cloud metadata | 05 / 64 |
| `Nokogiri::XML` with a config block enabling `noent` on untrusted XML | XXE | 49 |
| `Model.find(params[:id])` / `where(id: params[:id])` with no `current_user` or tenant scope | IDOR — the most common Rails authz bug | 28 |
| `.permit!` anywhere on a params object, or `update(params[:user])` without `permit` | mass assignment | 28 |
| `skip_before_action :verify_authenticity_token` | CSRF | 47 |
| `config.force_ssl = false` in production; `/rails/info` reachable | transport / debug endpoint | 32 / 51 |

## Framework auto-protections (do NOT flag these)

- **Active Record parameterizes.** `where(email: x)`, `where("email = ?", x)`, and `where("email = :e", e: x)`
  are safe. Do not flag a hash condition as SQLi (01).
  **Which argument the `#{}` sits in decides it — not whether `#{}` appears on the line:**

  | | |
  |---|---|
  | **Pass** | `where("name ILIKE ?", "%#{term}%")` — the fragment is a literal; the interpolation builds argument 2, which `?` binds |
  | **Finding** | `where("customer_ref = '#{params[:ref]}'")` — the interpolation is inside the fragment itself |

  Ruby resolves `#{}` before `where` is ever called, so an interpolated *bind value* is just a
  String by the time it is bound. The wildcard idiom `"%#{term}%"` is near-universal for LIKE and
  looks more like string-building than the genuinely unsafe case does — read the argument position,
  not the punctuation.
- **ERB auto-escapes.** `<%= value %>` is escaped; the escape hatches are `raw`, `html_safe`,
  `<%== %>`, and `sanitize` with a widened allow-list (02).
- **CSRF protection is on** under `load_defaults` 5.2+, or wherever `protect_from_forgery` appears
  anywhere in the ancestor chain. Absence of the call is not evidence of absence of protection (47).
  **Before passing on this basis, grep for `default_protect_from_forgery` across `application.rb`,
  `config/initializers/*.rb` and `config/environments/*.rb`.** A single
  `config.action_controller.default_protect_from_forgery = false` disables it under any
  `load_defaults`, and it is commonly two lines below the `load_defaults` you just read. Passing an
  app because the generation default is modern, without checking for the override, is the one way
  this file will make you miss a live vulnerability.
- **Strong parameters drop unpermitted keys.** `action_on_unpermitted_parameters` defaults to
  `:log` in development/test and `false` in production, so unpermitted keys are **filtered
  silently** rather than raising — do not treat the absence of a raise, or an explicit `false`, as a
  finding. Mass assignment is a finding when `permit!` is used, when the whole params hash is
  passed, or when a privilege attribute (`role`, `admin`, `user_id`) sits inside `permit` (28).
- **Session cookies are signed, and encrypted by default** since Rails 4 — a cookie's contents are
  not attacker-forgeable unless `secret_key_base` leaked (03, 39).
- `has_secure_password` uses **bcrypt**. Do not flag it as a fast-hash finding (09).
- **`order` / `reorder` / `pluck` are sanitized since 6.1.** Non-attribute arguments raise
  `ActiveRecord::UnknownAttributeReference`; only plain column references with optional
  `ASC`/`DESC`/`NULLS FIRST` pass. So `.order(params[:sort])` does **not** splice arbitrary SQL on a
  supported Rails — rate it **Medium** as an information-disclosure oracle (an attacker orders by
  columns they cannot read), not Critical SQL injection. The escape hatch is `Arel.sql(...)`, which
  asserts safety without sanitizing: `Arel.sql` wrapping request input **is** the Critical finding.
  The fix in either case is an allow-list, never a bind parameter — identifier positions cannot be
  bound.
- **Form helpers inject the CSRF token at render time.** `form_with`, `form_tag` and `button_to`
  emit `authenticity_token` themselves, so it will never appear in the `.erb` source. Do not report
  "form with no hidden CSRF token field" from reading a template (47) — that fires on every
  correctly-built Rails form.
- **CSP and security headers** may come from `config/initializers/content_security_policy.rb`;
  check there before reporting missing headers (32).

## Hardening checklist

- `secret_key_base` and credentials from `credentials.yml.enc` or ENV, never in source; confirm
  `master.key` is gitignored (03).
- `config.force_ssl = true` in production; secure/httponly/samesite cookie settings (32, 47).
- Object-level authorization on every action that loads by an id from params — Pundit/CanCan
  policies, or an ownership scope on the query. Rails has **no** default authorization (28).
  Before rating an unscoped `find(params[:id])`, **open the model**: a `default_scope` there can
  legitimately scope every query, and it is the one mechanism that makes a bare `find` safe. If the
  model is outside the scan scope, say so and drop to Medium confidence rather than assuming either
  way. Note `current_user.orders.find(...)` is safe because the association generates
  `WHERE user_id = ?` in SQL — the scope, not the `find`, is what protects it.
- Never `permit!`; enumerate permitted keys and keep privilege attributes out of them (28).
- `YAML.safe_load` on untrusted input; never `Marshal.load` (65).
- Pin and audit gems (`bundle audit`); check `Gemfile.lock`, not the `Gemfile` range (27).

## Forbidden claims

- Reporting a controller as CSRF-unprotected without reading `config.load_defaults` **and** the
  ancestor chain. Both are required; either alone gets it wrong (47, Rule 1).
- Flagging `where(id: params[:id])` or any hash/placeholder condition as SQL injection (01).
- Flagging `<%= %>` as XSS — it escapes; the sink is `raw`/`html_safe`/`<%== %>` (02).
- Calling authorization "present" because `authenticate_user!` is present. Authentication is not
  authorization, and Rails ships no default authorization at all (28).
- Reporting a missing security header without checking `config/initializers/` and
  `config/environments/production.rb` (32).

---

*Per-stack reference, evidence-first and cross-referenced to snitch's category numbers.
Internal reference.*
