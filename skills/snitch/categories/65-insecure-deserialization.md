## CATEGORY 65: Insecure Deserialization
> Type: sink-pattern · Groups: web · CWE: CWE-502

Category 49 covers XXE specifically. This category covers the broader family: binary/object deserialization of attacker-controlled data in Python, Java, Ruby, PHP, .NET, and Node.js.

**Data flow tracing required (SKILL.md Rule 7).** For every `pickle.loads()`, `yaml.load()`, `ObjectInputStream.readObject()`, `Marshal.load`, `unserialize()`, `BinaryFormatter`, `node-serialize.unserialize()` call this category surfaces, trace the input back to its source. Data loaded from trusted local files written by the same application is generally a Pass (record the file source). Data flowing from `req.*` / `params.*` / message-broker payload / file uploads / cache-store reads of untrusted keys is a finding. Caches and brokers are easy to forget: a value put there by trusted code may be re-read after an attacker swapped it.

### Detection
- **Python:** `pickle`, `cPickle`, `dill`, `shelve`, `PyYAML` (unsafe loader), `jsonpickle`
- **Java:** `ObjectInputStream`, `XMLDecoder`, Jackson polymorphic deserialization (`enableDefaultTyping`, `@JsonTypeInfo`), Kryo without registration, Hessian/Burlap, SnakeYAML (unsafe constructor), Apache Commons Collections on classpath
- **Ruby:** `Marshal.load`, `YAML.load` (pre-Psych safe-load defaults), `Oj.load` with default options
- **PHP:** `unserialize`, `phar://` stream wrapper attacks
- **.NET:** `BinaryFormatter`, `SoapFormatter`, `NetDataContractSerializer`, `ObjectStateFormatter`, `JavaScriptSerializer` with type names, Json.NET with `TypeNameHandling` != `None`
- **Node.js:** `node-serialize`, `serialize-to-js`, custom `eval`-based deserialization

### What to Search For
- Deserialization call whose input traces back to: HTTP body, query parameter, cookie, uploaded file, message-queue payload from an untrusted queue, database column that was originally user input, cache value in a shared cache
- YAML loaders used without an explicit safe loader option
- Jackson / Json.NET configured to emit and consume class-name type tags
- Presence of known gadget-chain libraries (Apache Commons Collections, Spring, Groovy) on the classpath alongside Java deserialization

### Actually Vulnerable
- Python deserialization of session data, cache entries, or uploaded files
- Java unsafe deserialization on any untrusted input (even internal queues if those queues accept external messages)
- `YAML.load` (not `safe_load`) on config received from any external source
- `.NET` binary formatter on any payload touching a trust boundary (Microsoft has deprecated this family — flag presence alone on modern .NET)

### NOT Vulnerable
- Deserialization of data that never crossed a trust boundary (internal, signed, and integrity-checked)
- Safe formats used safely: `json.loads`, `yaml.safe_load`, Jackson with polymorphic typing disabled, Json.NET with `TypeNameHandling.None`
- HMAC or signature verification before deserialization, with a secret not exposed to the attacker

### Context Check
1. Does the deserialized payload cross a trust boundary?
2. Is there an integrity check (signature, HMAC) verified BEFORE the deserialize call?
3. For Java/.NET, is type-allowlisting configured, or can the attacker pick the class?
4. For YAML, is the loader explicitly the safe variant?
5. For cached data, could an attacker write to the cache (e.g., Redis exposed, cache key collision)?

### Evidence Chain
- The deserialization sink call (`pickle.loads`, `ObjectInputStream.readObject`, `unserialize`, unsafe `yaml.load`, etc.) quoted at file:line
- The traced variable path from source to the deserialize call, hop by hop with file:line (e.g., `req.body.payload → job.data → Marshal.load(job.data)`)
- Source classification stated explicitly: HTTP body / query param / cookie / uploaded file / queue payload / shared-cache read / trusted local file
- Sanitizers and integrity checks looked for and shown absent or bypassable: HMAC/signature verification before the deserialize call, safe-loader option, type allowlist
- For Java/.NET: whether attacker-selectable class instantiation is possible (no allowlist, `TypeNameHandling` enabled) and any gadget-chain libraries present on the classpath

### Confidence Scoring
- **High**: complete trace from an untrusted source (HTTP input, uploaded file, shared-cache read, externally reachable queue) to an unsafe deserializer with no signature check or safe-loader option anywhere in the path
- **Medium**: unsafe deserializer confirmed but the input source is only partially traceable (e.g., a queue or database column whose writers could not all be enumerated), or an integrity check exists but its key handling is unclear
- **Low**: unsafe API present but the input appears to be a locally written trusted file, or the trace dead-ends before reaching a trust boundary — tag `needs human verification`

### Files to Check
- `**/session*.ts,py,java,rb`, `**/cache*.ts,py,java,rb`
- Message-queue consumers, cron jobs processing persisted jobs
- File upload handlers that parse binary formats
- RPC / legacy SOAP / remoting endpoints

### Reference
- CWE-502: Deserialization of Untrusted Data
- OWASP Top 10:2025 — A08 Software or Data Integrity Failures
- CVSS 4.0: typically Critical (AV:N, AC:L, RCE)
