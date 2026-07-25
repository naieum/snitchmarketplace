## CATEGORY 49: XXE & XML Attacks
> Type: posture · Groups: — · CWE: CWE-611

### Detection
- XML parser imports and usage without external entity restrictions
- YAML deserialization with unsafe loaders
- DTD processing enabled in XML parsers
- XSLT processing with user-supplied input
- SOAP/XML-RPC endpoints accepting XML payloads

### What to Search For

**Node.js/TypeScript:**
- `xml2js` on untrusted input. Note `doctype` is a **Builder** (serialisation) option, not a Parser option, and already defaults falsy — requiring it as a parse-time mitigation is meaningless and would fire on every call. Judge on whether the input is untrusted and whether entity-expansion limits were set at all
- `libxmljs` with `{ noent: true }` (enables entity expansion)
- `fast-xml-parser` with entity processing on untrusted input. `processEntities` **defaults to `true`**, so hunting for an explicit flag passes every default-configured usage — the finding is the absence of `processEntities: false`, not its presence. `allowBooleanAttributes` concerns valueless attributes and is unrelated to entities; do not use it as a signal
- `xmldom` / `@xmldom/xmldom` parsing untrusted XML without disabling external entities
- **js-yaml: resolve the installed major before dispositioning — the safe and unsafe code are identical and only the version differs.**
  - **v4+ (2021 onwards): `load()` is safe by default and `safeLoad` was removed.** Calling it throws: *"Function yaml.safeLoad is removed in js-yaml 4. Use yaml.load instead, which is now safe by default."* Do not prescribe `safeLoad` — it is advice that cannot be followed. `SAFE_SCHEMA` was also removed; `{ schema: SAFE_SCHEMA }` resolves to `undefined`, falls through to the default schema, and **silently does nothing** — a hardening step that leaves a green test suite and no change in behavior. The v4 schemas are `FAILSAFE_SCHEMA`, `JSON_SCHEMA`, `CORE_SCHEMA`, `DEFAULT_SCHEMA`
  - **v3 and earlier: bare `load()` constructs arbitrary types and is the finding.** The v3 unsafe marker is `DEFAULT_FULL_SCHEMA`, which does not exist in v4
  Read `package.json` / the lockfile. With no version in scope, cap confidence at Medium and say which file you could not read.
- SOAP libraries processing external WSDL without validation
- `saxes` or `sax` parsers without entity handling restrictions

**Python:**
- `lxml.etree.parse()` or `lxml.etree.fromstring()` with `resolve_entities=True` (lxml ≥ 5.0 defaults `resolve_entities` to `'internal'`, so an explicit `True` is a deliberate opt-out of the safe default — not a default worth hedging about)
- `xml.etree.ElementTree.parse()` without `defusedxml` -- standard library has limited protections
- `xml.dom.minidom.parseString()` with untrusted input
- `xml.sax` parser without disabling external entities via `feature_external_ges`
- `yaml.load()` without `Loader=yaml.SafeLoader` or `yaml.safe_load()`
- Missing `defusedxml` library (drop-in replacement that blocks XXE by default)
- `xml.dom.pulldom` processing untrusted XML

**Java:**
- `DocumentBuilderFactory` without `setFeature("http://apache.org/xml/features/disallow-doctype-decl", true)`
- `SAXParserFactory` without disabling external entities
- `XMLInputFactory` without `XMLInputFactory.IS_SUPPORTING_EXTERNAL_ENTITIES` set to `false`
- `TransformerFactory` processing user-supplied XSLT without restricting external access
- `XMLReader` without `setFeature` to disable external general and parameter entities
- `SchemaFactory` loading untrusted XSD schemas
- `Unmarshaller` (JAXB) processing untrusted XML without securing the underlying parser

**Go:**
- `encoding/xml` Decoder -- Go's standard library does not expand external entities by default, but custom entity handling may introduce risk
- Third-party XML libraries (`etree`, `xmlquery`) with entity expansion enabled
- YAML parsing with `gopkg.in/yaml.v2` `yaml.Unmarshal` on untrusted input into `interface{}` (can deserialize arbitrary types)

**PHP:**
- **PHP is safe by default and has been since libxml 2.9 (2012). The finding is an opt-in, never the bare call.** php.net: "As of libxml 2.9.0 entity substitution is disabled by default." Flag these, in any of the forms they take:
  - `LIBXML_NOENT` in the options argument of `simplexml_load_string` / `simplexml_load_file` / `DOMDocument::loadXML` / `loadHTML`. The constant's name is misleading — it reads as "no entities" and *enables* substitution
  - `LIBXML_DTDLOAD` or `LIBXML_DTDVALID` — loading the external subset re-enables fetching external entities
  - the **property form**, set on the object rather than passed as an argument: `$doc->substituteEntities = true` or `$doc->resolveExternals = true`. A rule that only inspects the options parameter misses this entirely, and it is how the opt-in most often appears on `DOMDocument`
  - `libxml_set_external_entity_loader()` with a permissive callback — it overrides everything above
  - a bare integer where a constant is expected: a bitmask literal defeats a name-based grep
  Hardening to credit as a Pass: `LIBXML_NONET` (blocks the network channel) and `LIBXML_NO_XXE` (PHP 8.4+ / libxml 2.13+).
- `DOMDocument::loadXML()` is **not** a finding for omitting `libxml_disable_entity_loader(true)`. That function is deprecated as of PHP 8.0 and unnecessary post-libxml-2.9; php.net directs you to `libxml_set_external_entity_loader()` instead. Recommending it is stale advice, and requiring its presence flags every correct modern parse (deprecated in PHP 8.0+)
- `XMLReader` without `setParserProperty(XMLReader::SUBST_ENTITIES, false)`

**Ruby:**
- `Nokogiri::XML()` with `{ noent: true }` or `NOENT` parse option (enables entity substitution)
- `REXML::Document.new()` processing untrusted XML (limited XXE protection in older versions)
- `LibXML::XML::Parser` without disabling external entities

### Actually Vulnerable
- Java `DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(userInput)` without any `setFeature` calls
- Python `lxml.etree.parse(user_file)` without disabling `resolve_entities`
- Node.js `libxmljs.parseXml(userInput, { noent: true })` -- explicitly enables entity expansion
- Python `yaml.load(user_input, Loader=yaml.UnsafeLoader)` or `Loader=yaml.FullLoader` — name the loader, since that is how this appears in real code. A **bare** `yaml.load(x)` is not a finding on PyYAML ≥ 6.0: `Loader` is a required positional argument and the call raises `TypeError` rather than executing. That rule describes PyYAML < 5.1 (2019) without specifying `Loader=SafeLoader`
- PHP `simplexml_load_string($userXml, null, LIBXML_NOENT)`, or a `DOMDocument` with `substituteEntities` / `resolveExternals` set to `true` — the **opt-in is the finding**. A bare `simplexml_load_string($userXml)` with no options is a Pass on any libxml ≥ 2.9
- Java `SAXParserFactory.newInstance().newSAXParser().parse(userInput, handler)` without disabling DTDs
- Ruby `Nokogiri::XML(user_xml, nil, nil, Nokogiri::XML::ParseOptions::NOENT)`
- XSLT processing user-supplied stylesheets: `TransformerFactory.newInstance().newTransformer(new StreamSource(userXslt))`
- SOAP endpoint accepting raw XML POST body and parsing without entity restrictions
- Go third-party XML library with custom entity resolver processing untrusted input

### NOT Vulnerable
- XML parsing with external entities explicitly disabled via parser features or flags
- Using `defusedxml` in Python (blocks XXE by default)
- Java `DocumentBuilderFactory` with `disallow-doctype-decl` feature set to `true`
- `yaml.safe_load()` or `yaml.load(input, Loader=yaml.SafeLoader)` in Python
- `js-yaml.load(input, { schema: JSON_SCHEMA })` or `js-yaml.load(input, { schema: FAILSAFE_SCHEMA })`
- Hardcoded XML strings with no user input (no injection vector)
- JSON APIs that do not accept XML content type
- Go `encoding/xml` standard library (does not expand external entities by default)
- Nokogiri in Ruby with default settings (entities not expanded by default)
- XML schemas validated before parsing untrusted content

### Context Check
1. Does the XML parser receive user-supplied or external input?
2. Are external entities and DTD processing explicitly disabled?
3. Is `defusedxml` used in Python projects, or are standard library parsers hardened?
4. Does the YAML parser use a safe loader?
5. Is XSLT processing performed with user-supplied stylesheets?
6. Is the application a SOAP service or does it accept XML content types?

**Library-shaped code:** an exported parser with a typed parameter and no caller in scope cannot
satisfy "confirm the parser receives untrusted input" — there is nothing to trace to. That is not a
reason to withhold the finding. The misconfiguration is provable from the call itself: report it,
state that reachability is unverified, and lower the *likelihood* rather than dropping the finding.
A parser that opts into entity substitution is misconfigured regardless of who calls it.

**Tag the right CWE.** This category covers two mechanisms: XML external entities (**CWE-611**) and
unsafe deserialization of YAML and similar formats (**CWE-502**). The manifest anchor is CWE-611;
override it to CWE-502 for a YAML/loader finding, which involves no XML and no entities. Labelling a
Python object-construction RCE as "XML External Entity" is wrong in the report, the SARIF and the ticket.

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Confirmed the XML/YAML parser receives user-supplied or external input (not hardcoded/internal data)
2. [ ] Verified external entity expansion or DTD processing is enabled (not disabled by parser configuration)
3. [ ] Checked if safe alternatives are used (`defusedxml` in Python, `yaml.safe_load()`, `FAILSAFE_SCHEMA`)
4. [ ] For Java, confirmed no `setFeature("http://apache.org/xml/features/disallow-doctype-decl", true)` call
5. [ ] Verified the application accepts XML content type (not JSON-only)
6. [ ] For XSLT, confirmed user-supplied stylesheets are processed (not internal-only templates)

### Confidence Scoring
- **HIGH**: XML parser processes user-supplied input with external entity expansion enabled (e.g., Java `DocumentBuilderFactory` without `disallow-doctype-decl`, Python `lxml.etree.parse()` with `resolve_entities=True`, Node.js `libxmljs` with `noent: true`). Or `yaml.load()` used without `SafeLoader`.
- **MEDIUM**: XML parser is used on external input but entity expansion settings are ambiguous (default settings that vary by library version). Or YAML parsing uses unsafe loader but the input source is partially trusted.
- **LOW**: XML parser is used but only on hardcoded or internally-generated XML (no user input vector). Or the parser's default settings are safe but the code does not explicitly disable entities.
- **SKIP**: Application does not parse XML or YAML from external sources. JSON-only APIs. Or `defusedxml` is used in Python. Or Go `encoding/xml` standard library is used (safe by default).

### Files to Check

Parsers are usually named for the **domain** they serve, not for XML or YAML — `import`, `feed`,
`config`, `loader`, `sync`, `webhook`. Treat the globs below as a starting set, never as scope: the
Detection greps are the reliable path. Include `**/*.php` and `**/*.rb` — a scan driven by the
extensions below alone can enumerate zero files in a codebase that parses XML on every request.
- `**/xml*.ts`, `**/xml*.js`, `**/xml*.py`, `**/xml*.java`, `**/xml*.go`
- `**/parser*`, `**/deserializ*`, `**/unmarshal*`
- `**/soap*`, `**/wsdl*`, `**/xslt*`
- `**/config*.xml`, `**/web.xml`
- `requirements.txt`, `pom.xml`, `package.json` (check for XML/YAML parser libraries)
- `**/*.yaml`, `**/*.yml` processing code
