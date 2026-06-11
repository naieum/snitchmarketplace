## CATEGORY 55: Microservices & Service Mesh Security

### Detection
- Multi-service architectures with inter-service communication
- Service mesh configurations (Istio, Linkerd, Envoy, Consul Connect)
- Kubernetes deployments with multiple services
- gRPC service definitions and configurations
- Internal API endpoints without authentication

### What to Search For

**Service-to-Service Authentication:**
- Internal HTTP/gRPC calls without mTLS or any authentication
- Services calling other services over plaintext HTTP inside the cluster
- Missing service identity verification (no client certificates, no JWT service tokens)
- Shared static API keys used across all services instead of per-service credentials
- Services trusting requests based solely on network location (e.g., "it's internal, no auth needed")
- Hardcoded service URLs without TLS: `http://user-service:8080/api/users`

**Kubernetes Network Policies:**
- Missing `NetworkPolicy` resources (default Kubernetes allows all pod-to-pod traffic)
- Overly permissive policies: `spec.ingress[].from: []` or `spec.egress[].to: []` (allow all)
- No default-deny policy in namespace
- Services in the same namespace with no network segmentation
- Pods with `hostNetwork: true` (bypasses network policies)

**Istio/Linkerd/Envoy Configuration:**
- Istio `PeerAuthentication` with `mtls.mode: DISABLE` or `PERMISSIVE` in production
- Missing Istio `AuthorizationPolicy` (all traffic allowed by default)
- Istio `AuthorizationPolicy` with `action: ALLOW` and empty `rules` (allows everything)
- Linkerd without `linkerd.io/inject: enabled` annotation on deployments
- Envoy configuration with `transport_socket` missing TLS context
- Istio `DestinationRule` without `trafficPolicy.tls.mode: ISTIO_MUTUAL`
- Service mesh bypass: pods communicating directly instead of through the sidecar proxy

**gRPC Security:**
- gRPC server without TLS: `grpc.NewServer()` in Go or `Server()` in Python without credentials
- gRPC channel without TLS: `grpc.insecure_channel()` in Python, `grpc.Dial(addr, grpc.WithInsecure())` in Go
- Missing gRPC interceptors for authentication/authorization
- gRPC reflection enabled in production (`grpc.EnableServerReflection`)
- No deadline/timeout on gRPC calls (resource exhaustion risk)

**Shared Secrets & Credentials:**
- Same database credentials shared across multiple services
- Single API key used for all service-to-service communication
- Shared JWT signing key across services (compromise of one compromises all)
- Service account tokens shared between services instead of per-service accounts

**Circuit Breaker & Resilience:**
- External API calls without circuit breaker pattern
- No timeout on outbound HTTP/gRPC calls (can hang indefinitely)
- Missing retry limits (unbounded retries can cascade failures)
- No bulkhead pattern isolating external dependencies

**Service Discovery & Access Control:**
- Service registry (Consul, Eureka, etcd) accessible without authentication
- DNS-based service discovery without access control
- Service registry allowing any service to register (spoofing risk)

**Language-Specific Patterns:**

*Node.js/TypeScript:*
- `axios.get('http://internal-service/api/...')` without auth headers
- Missing `@grpc/grpc-js` TLS configuration: `grpc.credentials.createInsecure()`
- No circuit breaker library (e.g., `opossum`) on external calls

*Python:*
- `requests.get('http://internal-service/api/...')` without auth
- `grpc.insecure_channel('service:50051')` in production code
- Missing `pybreaker` or `circuitbreaker` on external service calls

*Go:*
- `http.Get("http://internal-service/api/...")` without auth headers or mTLS
- `grpc.Dial(addr, grpc.WithInsecure())` or `grpc.WithTransportCredentials(insecure.NewCredentials())`
- No context timeout on outbound requests: missing `context.WithTimeout()`

*Java (Spring):*
- `RestTemplate` or `WebClient` calling internal services over HTTP without auth
- Missing `@LoadBalanced` with service discovery (direct URL instead of service name)
- gRPC `ManagedChannelBuilder.forAddress(...).usePlaintext()` in production
- No Resilience4j or Hystrix circuit breaker on external service calls

*Ruby:*
- `Net::HTTP.get(URI('http://internal-service/api/...'))` without auth
- Missing circuit breaker gem (`stoplight`, `circuit_breaker`) on external calls

### Actually Vulnerable
- Microservice calling another service over plaintext HTTP with no authentication: any pod in the cluster can impersonate the caller
- Kubernetes namespace with no `NetworkPolicy` -- all pods can communicate with all other pods across all namespaces
- Istio `PeerAuthentication` set to `PERMISSIVE` in production -- mTLS is optional, allowing plaintext connections
- gRPC server started without TLS in production: `grpc.NewServer()` with no `grpc.Creds()`
- Same `JWT_SECRET` used across all microservices -- compromising one service's secret allows forging tokens for all services
- Consul service registry accessible without ACL tokens -- any client can register or deregister services
- External API calls without timeout or circuit breaker -- one slow dependency can cascade failures across all services
- Kubernetes pod with `hostNetwork: true` -- bypasses network policies and can access host network interfaces
- Istio `AuthorizationPolicy` with empty rules and `action: ALLOW` -- allows all traffic
- gRPC reflection enabled in production -- allows enumeration of all service methods and message types

### NOT Vulnerable
- Services within the same trust boundary with network-level isolation (VPC, security groups) and mutual authentication
- Development and local environments (Docker Compose for local dev)
- Istio with `STRICT` mTLS mode and `AuthorizationPolicy` restricting traffic to specific source principals
- Kubernetes namespace with default-deny `NetworkPolicy` and explicit allow rules for required communication
- gRPC with TLS and per-RPC authentication interceptors
- Per-service credentials managed by a secrets manager with automatic rotation
- Circuit breakers configured with fallback responses and reasonable timeout values
- Service mesh with sidecar injection enforced and direct pod-to-pod communication blocked
- Service registry with ACLs restricting which services can register and discover
- AWS VPC security groups restricting traffic between service instances

### Context Check
1. Is service-to-service communication authenticated (mTLS, service tokens, or per-service API keys)?
2. Are Kubernetes `NetworkPolicy` resources defined with a default-deny posture?
3. Is the service mesh configured with strict mTLS (not permissive)?
4. Are gRPC connections using TLS in production?
5. Are credentials unique per service, or shared across multiple services?
6. Are external dependencies wrapped with circuit breakers and timeouts?
7. Is the service registry protected with access control?
8. Is this a development/local environment where these controls are not expected?

### Files to Check
- `**/k8s/**`, `**/kubernetes/**`, `**/deploy/**`, `**/manifests/**`
- `**/networkpolicy*.yaml`, `**/networkpolicy*.yml`
- `**/istio/**`, `**/linkerd/**`, `**/envoy/**`
- `**/peerauthentication*.yaml`, `**/authorizationpolicy*.yaml`, `**/destinationrule*.yaml`
- `**/*.proto` (gRPC service definitions)
- `**/grpc*`, `**/rpc*`, `**/client*`
- `**/docker-compose*.yml` (multi-service local setup)
- `**/consul*`, `**/eureka*`, `**/etcd*`
- `**/circuit*`, `**/resilience*`, `**/retry*`

### Confidence Scoring
- **HIGH**: Microservices communicate over plaintext HTTP with no authentication. Kubernetes namespace has no `NetworkPolicy`. Istio mTLS set to `PERMISSIVE`. gRPC server started without TLS in production. Same JWT secret shared across all services.
- **MEDIUM**: Service-to-service auth exists but uses a shared static API key instead of per-service credentials. Or network policies exist but are overly permissive. Or circuit breakers are missing on some external calls.
- **LOW**: Inter-service communication lacks explicit auth in code but runs within a VPC with security groups providing network-level isolation. Or this is a docker-compose local development setup.
- **SKIP**: Services use mTLS via Istio STRICT mode with AuthorizationPolicy. Kubernetes has default-deny NetworkPolicy. Per-service credentials from secrets manager. Circuit breakers on all external calls. Or application is monolithic (not microservices).

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed service-to-service calls use plaintext HTTP (not HTTPS or mTLS)
2. [ ] Verified no authentication headers, tokens, or client certificates on inter-service requests
3. [ ] Checked Kubernetes manifests for `NetworkPolicy` resources with default-deny posture
4. [ ] For Istio, verified `PeerAuthentication` mode is not `STRICT` and `AuthorizationPolicy` is missing or permissive
5. [ ] Confirmed gRPC connections use TLS credentials (not `insecure` or `WithInsecure`)
6. [ ] Verified credentials are per-service (not a single shared key across all services)
7. [ ] Checked if this is a production environment (not local docker-compose development)
