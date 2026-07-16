## CATEGORY 54: OAuth/OIDC Deep Security
> Type: posture · Groups: — · CWE: CWE-287

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

**Token Storage Issues:**
- Access tokens stored in `localStorage` -- vulnerable to XSS exfiltration
- Refresh tokens stored in `localStorage` or `sessionStorage`
- Tokens stored in cookies without `HttpOnly`, `Secure`, and `SameSite` attributes
- Tokens stored in `window.__STATE__` or global JavaScript variables
- JWT stored in URL query parameters or fragments

**Redirect URI Validation:**
- Redirect URI not strictly matched (e.g., prefix matching allows `https://example.com.evil.com`)
- Wildcard redirect URIs: `redirect_uri=https://*.example.com`
- Open redirect via OAuth: callback accepts arbitrary `redirect_uri` values
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
- Access token stored in `localStorage.setItem('token', accessToken)` in SPA
- OAuth callback accepting any `redirect_uri` parameter without validation against allowlist
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
- Token stored in cookie without `HttpOnly` flag: `http.SetCookie(w, &http.Cookie{Name: "token", Value: token})`
- Redirect URI validated with `strings.HasPrefix()` instead of exact match

**Ruby (OmniAuth, Doorkeeper):**
- OmniAuth without CSRF protection: `provider :oauth2, ... ` without `provider_ignores_state: false`
- Doorkeeper with `force_ssl_in_redirect_uri false` in production
- Implicit grant enabled in Doorkeeper: `grant_flows %w[implicit]`

### NOT Vulnerable
- Authorization code flow with PKCE (`code_challenge_method=S256`) enforced
- State parameter generated, stored in session, and validated on callback
- Nonce sent in OIDC authentication request and verified in ID token
- Tokens stored in `HttpOnly`, `Secure`, `SameSite=Lax` cookies (not accessible to JavaScript)
- Redirect URIs validated with exact string match against a registered allowlist
- Refresh token rotation enabled (new refresh token issued on each use, old one invalidated)
- Scopes minimized to only what the application requires
- Client secrets stored server-side only, never exposed to frontend code
- Backend-only OAuth flows (confidential clients) where PKCE is optional per OAuth 2.1 spec
- Proper client secret management in a secrets manager for confidential clients
- Implicit flow disabled; authorization code flow with PKCE used for SPAs and mobile apps

### Context Check
1. Is PKCE used for public clients (SPAs, mobile apps, CLI tools)?
2. Is the `state` parameter generated, stored in session, and validated on callback?
3. Is the `nonce` claim verified in OIDC ID tokens?
4. Are tokens stored securely (HttpOnly cookies, not localStorage)?
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
4. [ ] Checked token storage location (localStorage, sessionStorage, HttpOnly cookies)
5. [ ] Verified redirect URI validation uses exact string match against a registered allowlist
6. [ ] Confirmed client secret is not exposed in frontend code or client-side configuration
7. [ ] Checked if refresh token rotation is enabled with reuse detection

### Confidence Scoring
- **HIGH**: Authorization code flow without PKCE for a public client (SPA, mobile app). Or access tokens stored in `localStorage`. Or redirect URI validation uses prefix matching instead of exact match. Or client secret exposed in frontend code.
- **MEDIUM**: State parameter is generated but not validated on callback. Or refresh token rotation is not enforced. Or implicit flow is used but the application is being migrated.
- **LOW**: PKCE is not used but the client is confidential (server-side) where PKCE is optional per OAuth 2.1. Or tokens are stored in cookies that are missing one of the three attributes (`HttpOnly`, `Secure`, `SameSite`).
- **SKIP**: Authorization code flow with PKCE, state validation, nonce verification. Tokens in HttpOnly/Secure/SameSite cookies. Redirect URIs with exact string match. Client secrets server-side only. Auth managed by a provider (Clerk, Auth0) with secure defaults.

### Files to Check
- `**/auth*`, `**/oauth*`, `**/oidc*`, `**/login*`, `**/callback*`
- `**/providers/**`, `**/strategies/**`
- `**/*next-auth*`, `**/*authOptions*`, `**/[...nextauth]*`
- `**/passport*`, `**/omniauth*`, `**/doorkeeper*`
- `**/SecurityConfig.java`, `**/application.properties`, `**/application.yml`
- `**/settings.py` (Django OAuth Toolkit config)
- `**/token*`, `**/session*`, `**/cookie*`
- Frontend code: `**/store/**`, `**/context/**`, `**/hooks/useAuth*`
