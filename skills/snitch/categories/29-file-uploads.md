## CATEGORY 29: File Upload Security
> Type: sink-pattern · Groups: infra-supply-chain · CWE: CWE-434

**Data flow tracing required (SKILL.md Rule 7).** Trace the user-supplied filename and file content to where they are used: a filename concatenated into a write path (traversal) or uploaded content served same-origin (stored XSS / polyglot) is the sink. UUID/hash-replaced names, validated/allow-listed types, and private storage are Passes. Trace both the path and the served Content-Type. Un-traceable sources downgrade to Low confidence + `needs human verification`.

### Detection
- File upload libraries: `multer`, `formidable`, `busboy`, `@uploadthing/*`
- File handling: `multipart/form-data`, file write operations
- Storage patterns: local file storage, S3 uploads, cloud storage

---

### Order of operations decides almost everything here

Before judging any individual check, establish **when the bytes reach persistent storage relative to
when they are validated.** A pipeline that writes first and validates second has decorative
validation, no matter how good the check is.

| Shape | What it means |
|---|---|
| `multer.memoryStorage()` / a stream held in memory, validated, then written | **Validate-then-store.** The correct order. Rejected files never exist on disk |
| `multer.diskStorage({ destination: … })` into a directory that is served | **Store-then-validate.** The raw attacker bytes are on disk and reachable at their URL *before the handler runs*. Every later check is post-hoc, and unless something explicitly deletes or quarantines the original, the file stays there |
| written to a temp dir outside the web root, validated, then moved | Acceptable — the exposure window is bounded and the file is never reachable |

**Report store-then-validate into a served directory as its own finding**, separate from whatever the
validation does or does not check. It is the structural bug and it makes the rest cosmetic.

### Does the parser already strip separators? It depends on the parser

Before reporting traversal from an uploaded filename, check which multipart parser produced it. They
do **not** behave the same, and a rule that generalises from one to the others is wrong in one
direction or the other. Verified by reading the installed sources:

| Parser | Field | What it strips | Traversal from that field? |
|---|---|---|---|
| **multer → busboy** (multer 1.4.5-lts.1 and 2.2.0 both depend on busboy ^1.6.0) | `file.originalname` | `basename()` slices at the last `/` **or** `\`, and returns `''` for `.` and `..`. Applied whenever `preservePath` is falsy, and multer never sets it — it passes `options.preservePath` straight through, so the default is `undefined`. Applied *after* the `filename*` (RFC 5987) parameter is chosen and decoded, so percent-encoded separators do not survive either | **No** — unless the app sets `preservePath: true` |
| **formidable** (3.5.4) | `file.originalFilename` | only **backslash**: `match.substr(match.lastIndexOf('\\') + 1)`. The unquoted-filename regex branch excludes `/`, but the **quoted** branch does not — so `filename="../../etc/x"` reaches `originalFilename` intact | **Yes.** `path.join(dir, file.originalFilename)` on formidable is a live traversal finding |
| formidable, its own write path | `file.filepath` | built from `newFilename`, which defaults to a random name | No |
| **undici / the fetch `FormData` path** — Next.js route handlers using `await req.formData()` | `file.name` | **nothing.** `formdata-parser.js` assigns the filename attribute straight into `new File([body], filename)`; there is no `basename` anywhere in the fetch path | **Yes** |
| `@fastify/busboy` (2.1.1), busboy 0.3.1 | filename | same `basename` implementation as busboy 1.6.0, same `preservePath` default | No |
| hand-rolled parsers | — | check the source | Unknown — verify |

Two details on the multer/busboy row, both stronger than "not traversal" suggests:
- **The decode order is the safe one.** Percent-decoding and charset conversion happen inside
  `parseDispositionParams` *before* `basename()` runs, so `%2F`, `%5C`, and charset-encoded
  separators are all real separator bytes by the time it scans for them. This is the obvious place
  for a bypass and it is not one.
- **multer drops the file entirely** when `basename()` returns `''` (i.e. the name was exactly `.`
  or `..`) — `if (!filename) return fileStream.resume()`.

Scope note: `basename()` does not strip `:`. On NTFS, `report.pdf:payload` names an alternate data
stream. Irrelevant on POSIX, worth a note if the target deploys to Windows.

Unicode lookalikes (U+2215 `∕`, U+FF0F `／`) are not stripped and are not separators — no OS
normalizes them to `/`. They are ordinary filename characters, not a bypass.

So the same line of application code is a Pass on multer and a finding on formidable. **Establish the
parser from the imports before deciding**, and if you cannot, report at Low confidence with
`needs human verification` rather than picking a side.

### Validating the type: what actually counts

The type must be decided by **the bytes**, not by anything the client sent. The client controls the
filename, the extension, and the `Content-Type` header equally.

**Accept these as content-based validation:**
- A magic-byte / signature check (`file-type`, `python-magic`, `mimetype`) against an allowlist
- **An image library's own header parse, checked against an allowlist** — `sharp(buf).metadata()` then
  testing `meta.format`; PIL's `Image.open(...).format` after `verify()`; `ffprobe` for media.
  `metadata()` gives "fast access to (uncached) image metadata **without decoding any compressed
  pixel data**" — it reads the container header, and `format` is the codec the library identified
  from the bytes. This is equivalent to a magic-byte check, not weaker than one
- **Re-encoding the file and storing only the output.** The strongest mitigation available: decode
  and re-encode (`.webp()`, `.jpeg()`, `.toBuffer()`), then persist the library's output rather than
  the uploaded bytes. Appended payloads, polyglot headers, embedded EXIF and trailing archives do not
  survive it. Name this as a Pass wherever you find it

**Do not accept these as type validation:**
- The extension, however it is parsed
- `file.mimetype` / the `Content-Type` header — client-supplied
- `fileFilter` alone. It only ever sees `originalname` and the client's `mimetype`, both attacker-
  controlled. **A pipeline with no `fileFilter` that validates by content in the handler is stronger
  than one with a `fileFilter`.** Do not report the absence of `fileFilter` as missing validation —
  look for the content check wherever it lives, including after the middleware
- `failOn` / `failOnError` — see below

### The sharp options, specifically

Both of these read as hardening and are routinely miscited. Verified against sharp's documentation
and source:

| Option | What it actually does | Default | Verdict |
|---|---|---|---|
| `failOn: 'warning' \| 'error' \| 'truncated' \| 'none'` | **When to abort on invalid *pixel* data.** A decode-strictness dial. It does not decide which formats are admitted — a well-formed SVG, PDF, GIF or TIFF passes at any setting | `'warning'` — already the strictest | Not type validation |
| `failOnError: true` | Deprecated alias; resolves to `failOn: 'warning'` | — | **A no-op.** It sets the value that is already the default |
| `limitInputPixels` | Rejects inputs whose width × height exceeds the limit — the pixel-bomb ceiling | `268402689` (~268 MP) | **Absence is a Pass.** `0` or `false` is the *off* sentinel and disables the check entirely |
| `unlimited: true` | Removes libvips' internal memory guards | `false` | A finding on untrusted input |

So `sharp(buf, { failOnError: true, limitInputPixels: 0 })` is **strictly worse** than
`sharp(buf)` — one option does nothing and the other switches off the only built-in
decompression-bomb defence. Never read `failOnError` as a type gate, and never read the *presence*
of `limitInputPixels` as a guard; read its value.

---

### What to Search For
- Uploads written to a served directory before any validation runs (see order of operations)
- No content-based type validation anywhere in the path — extension or `mimetype` only
- User-controlled path segments in a write or read path
- Uploads served from the application's own origin
- Missing size limits on the upload middleware
- `limitInputPixels: 0` / `unlimited: true`, or the equivalent in another imaging stack
- Archive extraction without a decompressed-size, entry-count, or entry-path check
- File type checked only by extension, or only at the last dot

### Actually Vulnerable
- Upload handler with **no content-based type check anywhere** — not merely no `fileFilter`
- `multer.diskStorage` writing into a directory that `express.static` (or equivalent) serves
- Files saved to `public/uploads/` and reachable by direct URL
- `svg` in an image allowlist, with uploads served same-origin — SVG carries `<script>` and event
  handlers, and executes in the serving origin. Stored XSS with session access
- No `limits` configuration on multer/formidable
- `limitInputPixels: 0` / `unlimited: true` / Pillow's `Image.MAX_IMAGE_PIXELS = None` /
  ImageMagick with no `-limit` or `policy.xml` — pixel-bomb decode
- Extension-only validation, and `filename.split('.').pop()` in particular
- `archive.extractAllTo(dest)` with no decompressed-size, entry-count, or nesting check
- Archive entries written without validating that the resolved path stays inside the destination
  (**zip-slip**) — and `overwrite: true`, which lets entries clobber existing files
- **Extraction into a directory that is served.** Ask where `dest` points, not only what is checked
  on the way in. Extracting into the static root places attacker-named, attacker-*typed* files at
  public URLs with no traversal and no SVG in the allowlist — it routes around the upload path's
  type check entirely, because the type gate never sees the archive's contents
- A file-serving endpoint that takes a filename from the request: `res.sendFile(path.join(dir, req.query.name))`.
  **`path.join` normalizes `../` rather than rejecting it**, so joining does not defend anything. The
  fix is `res.sendFile(name, { root: dir })`, which resolves and then rejects escapes
- Uploads served **from the application's own origin** without `X-Content-Type-Options: nosniff` and
  `Content-Disposition: attachment`. Cross-origin/CDN serving is a Pass — see NOT Vulnerable.
  **These two headers are not interchangeable.** `nosniff` stops a *sniffed* content type; it does
  nothing about a *declared* one, so an SVG served as `image/svg+xml` still renders and still
  executes. Only `Content-Disposition: attachment`, a separate origin, or sanitize-before-store
  addresses SVG

### NOT Vulnerable
- `sharp(buf).metadata()` / `Image.open()` used **as the validator**, with the resulting `format`
  checked against an allowlist before any processing call. This is the correct implementation of the
  content check this category demands — do not flag the parse that performs the validation
- Re-encoding and storing the library's output rather than the uploaded bytes
- Multer configured with **no** `fileFilter` where the content check happens in the handler
- No `limitInputPixels` in the options — the ~268 MP default applies
- Filenames replaced with generated UUIDs/hashes
- Files in private storage — S3 without public access, reached by signed URL, ideally on a
  separate host
- Files served from a different domain/CDN, not same-origin
- Size limits configured on the upload middleware
- SVG sanitized with DOMPurify or svg-sanitize **before storage**, or served with
  `Content-Disposition: attachment`
- `path.join(uploadDir, req.file.originalname)` **under multer/busboy defaults specifically** — see
  the parser table below. This is **not** traversal there. What remains is that the attacker chooses
  the entire basename *and extension* in a possibly-served directory, and can overwrite a sibling
  file: report that, with that wording, rather than as traversal

### Context Check
1. Where do the bytes land, and does that happen before or after validation?
2. Is there a content-based type check anywhere in the path — at any layer, not just the middleware?
3. Is the storage location reachable by URL, and from which origin?
4. Are size limits configured on the middleware?
5. For imaging: what are `limitInputPixels` / `unlimited` set to, if present?
6. For archives: is decompressed size, entry count, and each entry's resolved path checked?
7. Which multipart parser is in use, and does it sanitize the filename? Check the parser table and
   `preservePath` before reporting — or before suppressing — traversal from an uploaded filename.

### Evidence Chain
**Precondition, not a finding condition:** the upload handler is production code — not a test, not a
fixture, not an admin-only tool behind authentication. If it is not, the category does not apply and
nothing below is evaluated.

Each numbered item states a **vulnerable** condition: it holding is what produces a finding, and it
not holding is Pass evidence to be recorded per Rule 7. The boxes are not a "things I verified"
checklist — a ticked box means *vulnerable*.

1. [ ] No content-based type validation exists **anywhere in the path** — checked the middleware
       config *and* the handler body *and* any shared validation helper
2. [ ] The bytes reach a served location before validation, and nothing removes them afterwards
3. [ ] A user-controlled value reaches a write or read path, and the parser that produced it does
       not already strip separators (see the parser table — multer/busboy does, formidable does not)
4. [ ] No size limit is configured on the upload middleware. Reverse-proxy and CDN limits usually sit
       outside the scan's reach — note that they may exist rather than asserting they do not, and do
       not let their unknowability block the finding
5. [ ] Uploaded files are served from the application origin without `Content-Disposition: attachment`
       (and, separately, without `nosniff`)
6. [ ] An archive is extracted without size, count, or entry-path validation, **or into a directory
       that is served**
7. [ ] An imaging library's bomb guard is explicitly disabled

### CWE by finding class
The `CWE-434` in `_index.md` is this category's **default, not a per-finding mandate**. Tag each
finding with the one that fits: traversal → CWE-22; stored XSS via SVG or HTML → CWE-79;
decompression bomb, archive or pixel → CWE-409; unrestricted upload / missing type validation →
CWE-434; attacker-controlled filename without traversal → CWE-73; missing size limit → CWE-770.

### Confidence Scoring
- **HIGH**: no content-based validation anywhere in the path; store-then-validate into a served
  directory; SVG allowed and served same-origin; user-controlled segment in a read/write path that
  the parser does not sanitize; archive extracted with no limits, or into a served directory; a bomb
  guard explicitly disabled; **no size limit configured at all**
- **MEDIUM**: a size limit exists but is disproportionate; storage location's reachability could not
  be determined; uploads served from the app origin without `Content-Disposition: attachment`.
  **Extension-only validation is Medium only when a content check exists elsewhere in the path** — if
  the extension check is the *only* gate, that is "no content-based validation anywhere," which is
  High. The two tiers otherwise describe the same code and the choice becomes arbitrary
- **LOW**: the filter logic is complex and needs manual review; storage looks private but could not be
  confirmed; a version-dependent library behaviour (zip-slip patch status) could not be resolved
  because no lockfile was reachable — tag `needs human verification`
- **SKIP**: content-based type validation present and gating the processing call; re-encoded output
  stored; filenames replaced; private storage; size limits configured

### Files to Check
- `**/upload/**/*.{ts,js,py,rb,php,go}`, `**/file/**/*.{ts,js,py,rb,php,go}`
- `**/api/**/*` (routes handling multipart)
- Multer/formidable/busboy configuration files
- Storage utility files
- Static-file mounts and download endpoints — the serving side is half of this category

### Advanced File Upload Attacks

#### Decompression bombs — two different kinds
- **Archive bombs**: ZIP/GZIP/TAR extracted without checking total decompressed size, expansion
  ratio, entry count, or nesting depth. Search: `unzip`, `tar.extract`, `zlib.gunzip`, `AdmZip`,
  `decompress`, `extract-zip`
- **Pixel bombs**: a small file whose *raster* is enormous — a few kilobytes of PNG or WebP declaring
  40000×40000. The decode allocates the full raster. This is the more common upload DoS, and the
  guard is usually on by default: sharp's `limitInputPixels` (268402689), Pillow's
  `Image.MAX_IMAGE_PIXELS` (~178 MP, warns then raises), ImageMagick's `-limit` / `policy.xml`.
  **Look for these being disabled**, not for them being absent

#### Zip-slip
Archive entry names are attacker-controlled and may contain `../` or absolute paths. Extracting
without resolving each entry against the destination and rejecting escapes writes files anywhere the
process can reach. Distinct from the size question and often unpatched in older extractor versions —
resolve the version from the lockfile, and drop to Low with `needs human verification` if you cannot.

#### SVG with embedded scripts
SVG carries `<script>`, `onload=`, `onclick=`. Served from the same origin it is stored XSS with full
session access. Note that sanitizing at *render* does not help if the file is also reachable directly
at its own URL — the fix is sanitize-before-store, serve cross-origin, or force `attachment`.

#### Polyglot files
Files valid as more than one type. Extension and even magic-byte checks can pass while a browser
interprets the file differently. **Re-encoding is the reliable defence**; a signature check alone is
not, because the signature can be genuine.

#### Loader surface
A content-sniffing design necessarily hands raw attacker bytes to a parser before it knows the
format, so decoder CVEs (libvips, ImageMagick, librsvg, libwebp) are reachable even for formats the
allowlist later rejects. This is inherent to sniffing and is **not** a design finding — it is a
dependency-currency question for Cat 27. It is worth a note in the report, not a finding. Narrowing
it further means a magic-byte pre-check with a small dedicated library before the imaging call.

#### Image processing exploits (ImageTragick)
ImageMagick without a `policy.xml` restricting dangerous coders (MVG, SVG, EPHEMERAL, MSL, URL).
Unlike the sharp options above, this one *is* about absence — ImageMagick's defaults are permissive.

#### Double extension & null byte
- `file.php.jpg` passes a `.jpg` check but may execute as PHP on a misconfigured server
- Search for extension extraction from the last dot only, without checking for dangerous extensions
  anywhere in the name
- Null-byte truncation is dead in modern Node and PHP (both reject NUL in paths); do not report it
  against those stacks without a version that is actually affected

#### Content-Type mismatch / MIME sniffing
Uploads served without `X-Content-Type-Options: nosniff` may be sniffed as HTML/JavaScript. Missing
`Content-Disposition: attachment` means they render inline. Even `.txt` can be sniffed as HTML.
