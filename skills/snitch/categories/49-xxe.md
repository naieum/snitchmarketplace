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
- `xml2js` used without `{ doctype: undefined }` or entity expansion limits
- `libxmljs` with `{ noent: true }` (enables entity expansion)
- `fast-xml-parser` with `{ processEntities: true }` or `{ allowBooleanAttributes: true }` combined with entity processing
- `xmldom` / `@xmldom/xmldom` parsing untrusted XML without disabling external entities
- `js-yaml.load()` instead of `js-yaml.safeLoad()` or `js-yaml.load(input, { schema: SAFE_SCHEMA })`
- SOAP libraries processing external WSDL without validation
- `saxes` or `sax` parsers without entity handling restrictions

**Python:**
- `lxml.etree.parse()` or `lxml.etree.fromstring()` with `resolve_entities=True` (default in some versions)
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
- `simplexml_load_string()` or `simplexml_load_file()` without `LIBXML_NOENT` disabled
- `DOMDocument::loadXML()` without disabling entity loading via `libxml_disable_entity_loader(true)` (deprecated in PHP 8.0+)
- `XMLReader` without `setParserProperty(XMLReader::SUBST_ENTITIES, false)`

**Ruby:**
- `Nokogiri::XML()` with `{ noent: true }` or `NOENT` parse option (enables entity substitution)
- `REXML::Document.new()` processing untrusted XML (limited XXE protection in older versions)
- `LibXML::XML::Parser` without disabling external entities

### Actually Vulnerable
- Java `DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(userInput)` without any `setFeature` calls
- Python `lxml.etree.parse(user_file)` without disabling `resolve_entities`
- Node.js `libxmljs.parseXml(userInput, { noent: true })` -- explicitly enables entity expansion
- Python `yaml.load(user_input)` without specifying `Loader=SafeLoader`
- PHP `simplexml_load_string($userXml)` without libxml protections
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
- `**/xml*.ts`, `**/xml*.js`, `**/xml*.py`, `**/xml*.java`, `**/xml*.go`
- `**/parser*`, `**/deserializ*`, `**/unmarshal*`
- `**/soap*`, `**/wsdl*`, `**/xslt*`
- `**/config*.xml`, `**/web.xml`
- `requirements.txt`, `pom.xml`, `package.json` (check for XML/YAML parser libraries)
- `**/*.yaml`, `**/*.yml` processing code
