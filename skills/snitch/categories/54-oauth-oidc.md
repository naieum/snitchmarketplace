## CATEGORY 54: OAuth/OIDC Deep Security
> Type: posture · Groups: — · CWE: CWE-287

> **Owns:** the OAuth/OIDC protocol surface — PKCE, `state`, `nonce`, grant type, the registered
> `redirect_uri` and how the server matches it, refresh-token rotation, scopes, and client-secret
> placement. **Does not own:** where the resulting session token is stored, or a generic
> post-login `res.redirect(userInput)` — both are Category 4. The JWT verification algorithm is
> Category 63; provider-specific config is Category 14.

### Detection
- OAuth 2.0 or OpenID Connect implementation in the application
- Authorization code flow, implicit flow, or client credentials flow usage
- OAuth libraries: NextAuth/Auth.js, Passport.js, Spring Security OAuth, Django OAuth Toolkit, Go oauth2 package
- Token storage patterns in frontend code
- Redirect URI handling and validation

### What to Search For

**Authorization Code Flow Without PKCE:**
- OAuth authorization requests missing `code_challenge` and `code_challenge_method` parameters
- NextAuth/Auth.js configuration without PKCE enabled for custom providers
- Passport.js OAuth2 strategy without `pkce: true` or `S256` code challenge
- Spring Security OAuth2 client without PKCE configuration
- Django OAuth Toolkit authorization endpoint without PKCE enforcement
- Go `golang.org/x/oauth2` usage without PKCE extension

**Missing State Parameter:**
- Authorization URL constructed without `state` parameter
- OAuth callback handler that does not validate the `state` parameter against session
- State parameter generated but never verified on callback

**Nonce Validation (OIDC):**
- ID token received without verifying `nonce` claim matches the one sent in the authorization request
- OIDC flow without sending `nonce` parameter in the authentication request
- ID token `nonce` claim not checked, allowing token replay

**Implicit Flow Usage:**
- `response_type=token` in authorization requests (implicit flow -- should be flagged)
- `response_type=id_token token` without code flow fallback
- SPA using implicit flow instead of authorization code flow with PKCE

**Token Storage** — owned by Category 4. If tokens land in `localStorage`, a global, a URL fragment,
or a cookie missing `HttpOnly` / `Secure` / `SameSite`, note the detection and report it there.

**Redirect URI Validation (the registered `redirect_uri`, not a generic redirect):**
- Redirect URI not strictly matched (e.g., prefix matching allows `https://example.com.evil.com`)
- Wildcard redirect URIs: `redirect_uri=https://*.example.com`
- Callback accepting an arbitrary `redirect_uri` value not in the registered set
- `redirect_uri` validated on the client side but not on the authorization server
- Path traversal in redirect URI: `redirect_uri=https://example.com/../evil`
- Redirect URI with different port or path accepted (e.g., `https://example.com:8080`)

**Refresh Token Issues:**
- Refresh token rotation not enforced (same refresh token can be reused indefinitely)
- No refresh token expiration or absolute lifetime
- Refresh tokens not revoked on password change or logout
- Refresh token reuse detection not implemented (compromised token not detected)

**Scope Issues:**
- Requesting more OAuth scopes than necessary (scope inflation)
- Not validating scopes on the resource server (trusting the token without checking scope claims)
- Admin scopes requested by default for all users

**Client Secret Exposure:**
- OAuth `client_secret` included in frontend JavaScript code
- Client secret in mobile application source code (reverse-engineerable)
- Client secret committed to public repository
- Client secret in client-side OAuth configuration

### Actually Vulnerable

**JavaScript/TypeScript (NextAuth, Passport.js):**
- NextAuth custom provider without PKCE: `providers: [{ id: 'custom', ...options }]` missing `checks: ['pkce']`
- Passport OAuth2 callback not validating `state`: `passport.authenticate('oauth2')` without state check
- OAuth callback accepting any `redirect_uri` parameter without validation against the registered allowlist
- Client secret in Next.js client-side code: `process.env.NEXT_PUBLIC_OAUTH_SECRET`

**Python (Django OAuth Toolkit, Authlib):**
- Django OAuth Toolkit with `PKCE_REQUIRED = False` for public clients
- OAuth callback view not verifying `state` parameter from session
- Implicit grant type enabled: `GRANT_TYPES = ['implicit']` in Django OAuth Toolkit settings
- Flask-OAuthlib redirect URI validation using `startswith()` instead of exact match

**Java (Spring Security OAuth2):**
- Spring Security OAuth2 client registration without PKCE: missing `client-authentication-method: none` with code challenge
- `redirect-uri: "{baseUrl}/**"` with wildcard matching
- ID token `nonce` claim not verified in custom OIDC authentication handler
- Client secret in `application.properties` deployed with frontend assets

**Go:**
- `golang.org/x/oauth2` authorization URL without `oauth2.SetAuthURLParam("state", state)`
- Redirect URI validated with `strings.HasPrefix()` instead of exact match

**Ruby (OmniAuth, Doorkeeper):**
- OmniAuth with state checking turned **off**: `provider :oauth2, ..., provider_ignores_state: true`. The option defaults to `false` (state is validated), so its *absence* is the secure configuration and is never the finding — the finding is an explicit `true`, and the fix is to remove the option or get the provider to return `state`
- Doorkeeper with `force_ssl_in_redirect_uri false` in production
- Implicit grant enabled in Doorkeeper: `grant_flows %w[implicit]`

### NOT Vulnerable
- Authorization code flow with PKCE (`code_challenge_method=S256`) enforced
- State parameter generated, stored in session, and validated on callback
- Nonce sent in OIDC authentication request and verified in ID token
- Redirect URIs validated with exact string match against a registered allowlist
- Refresh token rotation enabled (new refresh token issued on each use, old one invalidated)
- Scopes minimized to only what the application requires
- Client secrets stored server-side only, never exposed to frontend code
- A **confidential** client that omits PKCE but validates the OIDC `nonce` claim in the ID token
  obtained from the token endpoint, and disregards every token until that check succeeds. Current
  best-current-practice recommends PKCE for confidential clients too, and names the OIDC nonce as
  the one sanctioned alternative — so nonce-with-validation is a Pass, and "it's a backend client"
  on its own is not. Record which of the two you found, quoted. (Nonce does not protect a *public*
  client: an attacker can call the token endpoint with the stolen code directly.)
- Proper client secret management in a secrets manager for confidential clients
- Implicit flow disabled; authorization code flow with PKCE used for SPAs and mobile apps
- `provider_ignores_state` absent from an OmniAuth provider block — the default is `false`, so state
  is being validated

### Context Check
1. Is PKCE used for public clients (SPAs, mobile apps, CLI tools)?
2. Is the `state` parameter generated, stored in session, and validated on callback?
3. Is the `nonce` claim verified in OIDC ID tokens?
4. For a confidential client without PKCE: is the OIDC `nonce` claim verified in the ID token, with tokens disregarded until it passes?
5. Are redirect URIs strictly validated with exact match against a registered allowlist?
6. Is refresh token rotation enabled with reuse detection?
7. Are OAuth scopes minimized to the least privilege needed?
8. Is the client secret kept server-side only (not in frontend code or mobile apps)?
9. Is implicit flow disabled in favor of authorization code flow with PKCE?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Determined if the OAuth client is public (SPA, mobile, CLI) or confidential (server-side)
2. [ ] Checked authorization request for `code_challenge` and `code_challenge_method` parameters (PKCE)
3. [ ] Verified `state` parameter is generated, stored in session, and validated on callback
4. [ ] For a confidential client without PKCE, checked whether the OIDC `nonce` is sent AND verified in the ID token
5. [ ] Verified redirect URI validation uses exact string match against a registered allowlist
6. [ ] Confirmed client secret is not exposed in frontend code or client-side configuration
7. [ ] Checked if refresh token rotation is enabled with reuse detection

### Confidence Scoring
- **HIGH**: Authorization code flow without PKCE for a public client (SPA, mobile app). Or redirect URI validation uses prefix matching instead of exact match. Or `provider_ignores_state: true`. Or client secret exposed in frontend code.
- **MEDIUM**: State parameter is generated but not validated on callback. Or refresh token rotation is not enforced. Or implicit flow is used but the application is being migrated.
- **MEDIUM (not Low)**: PKCE is absent on a confidential client **and** no verified OIDC `nonce` covers it — best current practice recommends PKCE here too, so this is a real gap, not an exemption.
- **LOW**: PKCE is absent on a confidential client but a `nonce` is sent and its verification could not be traced to a specific line — tag `needs human verification`.
- **SKIP**: Authorization code flow with PKCE, state validation, nonce verification. Redirect URIs with exact string match. Client secrets server-side only. Auth managed by a provider (Clerk, Auth0) with secure defaults.

### Files to Check
- `**/auth*`, `**/oauth*`, `**/oidc*`, `**/login*`, `**/callback*`
- `**/providers/**`, `**/strategies/**`
- `**/*next-auth*`, `**/*authOptions*`, `**/[...nextauth]*`
- `**/passport*`, `**/omniauth*`, `**/doorkeeper*`
- `**/SecurityConfig.java`, `**/application.properties`, `**/application.yml`
- `**/settings.py` (Django OAuth Toolkit config)
- `**/token*`, `**/session*`, `**/cookie*`
- Frontend code: `**/store/**`, `**/context/**`, `**/hooks/useAuth*`
