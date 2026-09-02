## CATEGORY 56: WebSocket Security
> Type: posture · Groups: — · CWE: CWE-1385

> **Owns the WebSocket connection boundary**, authentication on the upgrade included. Category 4
> defers here for anything reached through `wss.on('connection', ...)` or a Socket.io handshake.

### Detection
- WebSocket server imports: `ws`, `socket.io`, `@socket.io/redis-adapter`, `uWebSockets.js`, `actioncable`, `channels` (Django), `gorilla/websocket` (Go), `spring-websocket` (Java)
- WebSocket upgrade handling in HTTP servers (Express, Fastify, Koa, net/http)
- Client-side WebSocket connections: `new WebSocket(...)`, `io(...)`, `io.connect(...)`
- WebSocket route definitions and event handlers

### What to Search For

**Missing Origin Validation:**
- WebSocket upgrade handlers without `Origin` or `Sec-WebSocket-Origin` header checking
- Socket.io configuration with no `cors` or `allowedOrigins` restriction
- Django Channels without `ALLOWED_HOSTS` or custom origin validation in consumers
- Go `gorilla/websocket` upgrader with `CheckOrigin` returning `true` unconditionally
- Spring `registerStompEndpoints` with `.setAllowedOrigins("*")`

**No Authentication on WebSocket Connections:**
- WebSocket upgrade without verifying session, token, or cookie
- Socket.io server without authentication middleware in `io.use(...)` or `io.of(...).use(...)`
- Django Channels consumers without `self.scope["user"]` authentication checks
- Go WebSocket handlers with no token/session validation before `upgrader.Upgrade()`
- Spring WebSocket without `HandshakeInterceptor` for auth
- Rails ActionCable without `identified_by` or connection rejection logic

**Missing Message Validation/Sanitization:**
- `ws.on('message', ...)` handlers that parse and use message data without schema validation
- Socket.io event handlers without input validation on received data
- Django Channels `receive()` methods that trust incoming JSON without validation
- Go handlers reading from `conn.ReadMessage()` without checking message type or size
- Spring `@MessageMapping` handlers without `@Validated` or manual validation

**No Rate Limiting on WebSocket Messages:**
- WebSocket message handlers with no throttle, debounce, or rate limiting logic
- Socket.io events processed without per-client rate limits
- No `maxPayload` or message size limits configured on WebSocket server
- Missing connection-level or message-level rate limiting middleware

**No Connection Timeout:**
- WebSocket servers without `pingInterval`/`pingTimeout` (Socket.io) or heartbeat configuration
- `ws` servers without `clientTracking` and periodic liveness checks
- No idle connection cleanup or maximum connection duration limits
- Django Channels without `CHANNEL_LAYERS` timeout configuration
- Go WebSocket without `SetReadDeadline`/`SetWriteDeadline`

**Broadcasting Sensitive Data:**
- `io.emit(...)` or `wss.clients.forEach(...)` broadcasting data to all connected clients without filtering
- Sensitive fields (tokens, emails, internal IDs, payment info) included in broadcast payloads
- No per-user or per-room message filtering before broadcast
- Admin-level data broadcasted to non-admin clients

**Missing TLS:**
- WebSocket connections using `ws://` instead of `wss://` in production configuration
- Server configuration binding WebSocket to non-TLS listener
- Client connections to `ws://` URLs (not `wss://`)
- No TLS termination proxy in front of WebSocket server

### Actually Vulnerable
- WebSocket server with `CheckOrigin: func(r *http.Request) bool { return true }` -- allows cross-site WebSocket hijacking
- Socket.io server with no `io.use(...)` auth middleware -- any client can connect and receive events
- `ws.on('message', (data) => { db.query(JSON.parse(data).sql) })` -- unvalidated message used in database query
- `io.emit('update', { users: allUsersWithPasswords })` -- broadcasting sensitive data to all clients
- ActionCable with `def connect; end` (empty) -- no authentication, all connections accepted
- Django Channels consumer with `async def receive(self, text_data): await self.channel_layer.group_send(...)` forwarding raw user input to group
- WebSocket client connecting to `ws://api.example.com/feed` in production code -- no TLS
- Go WebSocket with no `SetReadDeadline` -- client can hold connection open indefinitely, exhausting server resources

### NOT Vulnerable
- Socket.io with `cors: { origin: ["https://example.com"] }` and `io.use(authMiddleware)`
- `gorilla/websocket` with `CheckOrigin` validating against allowed origins list
- WebSocket handler that validates JWT/session before upgrade and validates each message with a schema
- Broadcasting only to specific rooms/channels with appropriate access control
- WebSocket behind TLS-terminating reverse proxy (nginx, Cloudflare) with `wss://` client URLs
- Django Channels with `TokenAuthMiddleware` and input validation in `receive()`
- Internal-only WebSocket services not exposed to external networks
- WebSocket connections behind an authenticated API gateway or proxy

### Context Check
1. Is the WebSocket endpoint exposed to external clients or only used internally?
2. Is there authentication enforced at the connection (handshake) level?
3. Are incoming messages validated against a schema before processing?
4. Is there per-client rate limiting or message size limits?
5. Are heartbeats/pings configured for connection liveness detection?
6. Does the broadcast logic filter data based on the recipient's authorization level?
7. Is TLS terminated at the WebSocket server or at a proxy in front of it?

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed the WebSocket endpoint is exposed to external clients (not internal-only)
2. [ ] Checked for origin validation on the WebSocket upgrade handler
3. [ ] Verified authentication is enforced at connection (handshake) level (session, token, or cookie)
4. [ ] Checked if incoming messages are validated against a schema before processing
5. [ ] Verified broadcast logic filters data based on recipient authorization level
6. [ ] Confirmed WebSocket connections use `wss://` (TLS) in production configuration
7. [ ] Checked for rate limiting or message size limits on the WebSocket server

### Confidence Scoring
- **HIGH**: WebSocket server has no origin validation (or `CheckOrigin` returns `true` unconditionally), no authentication on connection upgrade, and no message validation. Or sensitive data (passwords, tokens) included in broadcast payloads.
- **MEDIUM**: Authentication exists at connection level but incoming messages are not validated against a schema. Or origin validation is partial (allows broad wildcard origins). Or no rate limiting on messages.
- **LOW**: WebSocket endpoint is internal-only (not exposed to external clients). Or the WebSocket is behind an authenticated API gateway or reverse proxy that handles auth and origin checking.
- **SKIP**: Socket.io with strict CORS origin allowlist, authentication middleware in `io.use()`, message schema validation, and per-client rate limiting. Or internal-only WebSocket service not exposed to external networks.

### Files to Check
- `**/ws/**`, `**/websocket/**`, `**/socket/**`, `**/realtime/**`
- `**/gateway*.ts`, `**/gateway*.py`, `**/hub*.cs`
- Socket.io configuration files, ActionCable connection/channel files
- `**/consumers.py` (Django Channels), `**/routing.py`
- `**/channels/**`, `**/cable/**` (Rails ActionCable)
- WebSocket upgrade handlers in HTTP server configuration
- Nginx/reverse proxy configuration for WebSocket proxying
