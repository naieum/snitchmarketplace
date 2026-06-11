## CATEGORY 29: File Upload Security

**Data flow tracing required (SKILL.md Rule 7).** Trace the user-supplied filename and file content to where they are used: a filename concatenated into a write path (traversal) or uploaded content served same-origin (stored XSS / polyglot) is the sink. UUID/hash-replaced names, validated/allow-listed types, and private storage are Passes. Trace both the path and the served Content-Type. Un-traceable sources downgrade to Low confidence + `needs human verification`.

### Detection
- File upload libraries: `multer`, `formidable`, `busboy`, `@uploadthing/*`
- File handling: `multipart/form-data`, file write operations
- Storage patterns: local file storage, S3 uploads, cloud storage

### What to Search For
- File uploads accepting any file type (no extension or MIME type validation)
- User-controlled filenames used directly in file paths (path traversal via `../../`)
- Uploads stored in publicly accessible directories (e.g., `public/uploads/`)
- Missing file size limits on upload endpoints
- No virus/malware scanning on uploaded files
- File type checked only by extension, not by magic bytes/file signature

### Actually Vulnerable
- Upload handler with no file type restriction (`multer()` with no `fileFilter`)
- `path.join(uploadDir, req.file.originalname)` using user-supplied filename directly
- Files saved to `public/uploads/` accessible via direct URL
- No `limits` configuration on multer/formidable (unlimited file size)
- Extension-only validation (`.jpg`) without checking actual file content

### NOT Vulnerable
- File type validation checking both extension and MIME type
- Filenames replaced with generated UUIDs/hashes
- Files stored in private storage (S3 with signed URLs, not public directory)
- File size limits configured on upload middleware
- Upload middleware with proper `fileFilter` configuration

### Context Check
1. Is the filename sanitized or replaced before storage?
2. Is there file type validation beyond just extension?
3. Are uploaded files stored in a private or public location?
4. Are file size limits configured?

### Files to Check
- `**/upload/**/*.ts`, `**/file/**/*.ts`
- `**/api/**/*.ts` (routes handling multipart)
- Multer/formidable configuration files
- Storage utility files

### Advanced File Upload Attacks

#### Zip Bomb / Decompression Bomb
- Uploaded archives (ZIP, GZIP, TAR) extracted without checking decompressed size
- No limit on extraction ratio (small file expands to fill disk)
- Search for: `unzip`, `tar.extract`, `zlib.gunzip`, `AdmZip`, `decompress`, `extract-zip` without size validation

#### SVG with Embedded Scripts
- SVG files accepted and served from the same origin
- SVG can contain `<script>`, `onload=`, `onclick=` and other event handlers
- If rendered in browser from same domain, this is stored XSS
- Search for: SVG in allowed file types, SVG served without sanitization

#### Polyglot Files
- Files valid as multiple types (e.g., a GIF that's also valid JavaScript)
- Extension validation passes but browser interprets differently
- Search for: file type checks that only validate one dimension (extension OR MIME OR magic bytes, but not all)

#### Image Processing Exploits (ImageTragick)
- Crafted images exploiting ImageMagick, Sharp, or jimp vulnerabilities
- Search for: `sharp(`, `gm(`, `imagemagick`, `convert`, `identify` processing user-uploaded images without policy restrictions
- ImageMagick without `policy.xml` restricting dangerous coders (MVG, SVG, ephemeral)

#### Double Extension & Null Byte Attacks
- `file.php.jpg` — passes `.jpg` extension check but may be executed as PHP
- `file.php%00.jpg` — null byte truncates filename in some systems
- Search for: extension extracted only from the last dot (`.split('.').pop()`) without checking for known dangerous extensions anywhere in the filename

#### Content-Type Mismatch / MIME Sniffing
- Uploaded files served without `X-Content-Type-Options: nosniff` header
- Browser MIME sniffing may interpret uploaded file as HTML/JavaScript
- Missing `Content-Disposition: attachment` on download endpoints (files render inline)
- Search for: file serving endpoints without proper response headers

#### Stored XSS via File Content
- HTML, SVG, or XML files uploaded and served from the same origin
- Even non-executable extensions (`.txt`) can be sniffed as HTML by browsers
- Search for: file serving from same domain without Content-Type enforcement

### Actually Vulnerable (Additional)
- `app.use('/uploads', express.static('uploads'))` — serves any uploaded file type with MIME sniffing
- SVG uploaded and rendered in `<img>` tag from same origin with no sanitization
- `const ext = filename.split('.').pop()` — only checks last extension, vulnerable to double extension
- `sharp(req.file.buffer).resize(...)` with no file type validation before processing
- ZIP extraction: `archive.extractAllTo(destPath)` without checking total decompressed size
- File download endpoint returns `Content-Type` from user upload without `nosniff` header

### NOT Vulnerable (Additional)
- Files served from a different domain/CDN (e.g., S3 with separate domain, not same-origin)
- SVG files sanitized with DOMPurify or svg-sanitize before storage
- `X-Content-Type-Options: nosniff` and `Content-Disposition: attachment` on all file serving endpoints
- Image processing with Sharp configured to reject non-image inputs (`sharp(buffer, { failOnError: true })`)
- ZIP extraction with decompressed size limit checked before extraction
- Double extension prevention: reject filenames containing multiple dots or known executable extensions anywhere

### Confidence Scoring
- **HIGH**: Upload handler with no fileFilter or file type restriction (accepts any file). User-supplied filename used directly in file path (path traversal). Files saved to public directory accessible via direct URL. No file size limit configured on upload middleware. SVG with embedded scripts served from same origin. ZIP/archive extraction without decompressed size limit. Image processing (Sharp/ImageMagick) on unvalidated uploads.
- **MEDIUM**: Upload handler has some validation but only checks extension (not MIME type or magic bytes). File size limit exists but is very high (> 100MB). Files stored in a directory that may or may not be publicly accessible. Files served from same origin without Content-Disposition: attachment. Extension validation only checks last dot.
- **LOW**: Upload handler exists with a file filter but the filter logic is complex and needs manual review. Storage location appears private but needs verification.
- **SKIP**: File type validation checking both extension and MIME type. Filenames replaced with UUIDs/hashes. Files stored in private storage (S3 with signed URLs). File size limits configured. Upload middleware with proper fileFilter.

### Evidence Chain
Before reporting, verify ALL of these:
1. [ ] Upload handler is in production code (not test or admin-only upload)
2. [ ] No file type validation exists (check multer fileFilter, formidable options, busboy handlers)
3. [ ] Filename is used directly without sanitization or UUID replacement
4. [ ] Uploaded files are accessible via a public URL (check storage destination)
5. [ ] File size limits are not configured at any level (middleware, reverse proxy, CDN)
6. [ ] Uploaded files are served with proper headers (X-Content-Type-Options: nosniff, Content-Disposition)
7. [ ] No archive extraction without decompressed size validation
8. [ ] No image processing on unvalidated file types
