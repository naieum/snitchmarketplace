## CATEGORY 15: Accessibility of linked documents (PDF, Office)

A site's accessibility does not stop at its HTML. When the menu, the form, the schedule, the policy or the statement is a PDF, the document *is* the content, and a person who cannot read it cannot use the service. This category audits the documents the audited surface links to — PDF, DOCX, XLSX, PPTX, and the common worst case, a scan of a paper page saved as a PDF with no text in it at all.

The honest limit is drawn early. From a link inventory and a text-extraction pass this category can prove three things: whether the document has a text layer at all, whether it declares itself tagged, and whether an HTML equivalent exists beside the link. Everything inside the document that needs a rendered read — reading order, alternative text on its figures, its form-field labels, its table headers — is runtime or tool-dependent, and Skips with the unblock rather than being guessed at from the outside.

**Boundary.** This category judges the linked document as **content that must be usable**. Whether the PDF is indexable, crawlable, or the right format for search is the sibling's judge — call the Skill tool with "snitch-marketing". Whether dropping a person into a download interrupts the task they were doing is the other sibling's — call the Skill tool with "snitch-ux". Inside this skill: a document's own criterion failures are reported here against 1.1.1 and 1.3.1 as the rule table sets out, not re-filed in Cat 01 or Cat 03; Cat 13 reads the exposure a process-critical document carries; Cat 02 owns captions on linked media, which is a different artifact.

### Pre-flight

Runs whenever the audited surface links to a document. Build the link inventory first: if it is empty, Skip with `Skip — no linked documents found in the representative page set`.

Runs at higher priority when the sector answer from discovery is public sector, education, healthcare, banking or transport, because those are the sectors where the form, the schedule and the statement are most often only a PDF.

The exception check happens before the audit, not after: a document inside a Title II exception is scoped out by naming the exception, and is never counted as a failure and never silently dropped.

### Rule table

One row per obligation. A finding names its row.

| Obligation | Who it binds | What must hold | Static signal | Facts verified | Severity |
|---|---|---|---|---|---|
| (1) A process-critical document is usable | ADA Title II entities; Section 508 vendors and agencies; EAA in-scope services | A document that is the **only** way to get information or complete a process — a form, a statement, a menu, a schedule, a policy, an application — is readable and operable, or an equivalent route exists | Link inventory plus the page context: is the document the only route, or does an HTML page carry the same content | 2026-09-03 · ada.gov, access-board.gov | High |
| (2) The document has a text layer | as above | The file is not an image of a page. A scanned PDF with no text layer is unreadable to a screen reader at any level | Text extraction returns no text, or returns only whitespace, for a file whose page count is non-zero | 2026-09-03 · access-board.gov | High (process-critical) / Medium (informational) |
| (3) The document declares itself tagged | as above | A PDF carries structure tags, so headings, lists, tables and reading order exist for assistive technology | The `Tagged:` field from a PDF information tool reads `no` | 2026-09-03 · access-board.gov | High (process-critical) / Medium (informational) |
| (4) PDF/UA as the technical bar | ADA Title II, Section 508 and EAA surfaces, as the recognised document standard | Where a PDF is the deliverable, PDF/UA (ISO 14289) is the standard it is produced against | The document's metadata declares a PDF/UA identifier, or it does not | ISO 14289 title and edition **(unverified — iso.org returned 403 on 2026-09-03; confirm at https://www.iso.org/standard/64599.html)** | Medium |
| (5) An HTML equivalent exists | ADA Title II entities; Section 508 (federal policy prioritises HTML) | The same content is reachable as a web page, or the document itself meets the bar | A sibling link to an HTML route with the same content, in the same list item or paragraph as the document link | 2026-09-03 · section508.gov | Medium |
| (6) The link says what it is | WCAG 2.2 SC 1.1.1 and 1.3.1 as applied to the linking page | The link text names the format, and gives the size where the download is large | The `href` ends in a document extension and the link text contains no format word | 2026-09-03 · w3.org | Low |
| (7) Section 508 non-web document criteria | Federal agencies and their vendors | Electronic content conforms to WCAG 2.0 Level A and AA (provision E205.4); **non-web documents are not required to conform to 2.4.1, 2.4.5, 3.2.3 and 3.2.4** | The surface is a document rather than a web page | 2026-09-03 · access-board.gov | n/a — scoping rule |
| (8) Title II document exceptions | ADA Title II entities | Archived web content, preexisting conventional electronic documents, third-party content posted with no contractual arrangement, individualized password-protected documents, and preexisting social media posts are excepted | The document's publication date against the entity's compliance date, and whether it is in a designated archive area, unchanged since archiving, and for reference, research or recordkeeping only | 2026-09-03 · ada.gov | Low (record the exception) |
| (9) Inside-the-document structure | as (1) | Reading order, alternative text on figures, form-field labels, table headers and language of the document | **Not statically evidenceable from a link inventory** | n/a | Skip — inside-document structure requires a human or runner; not run |

**Facts verified: 2026-09-03.** Title II's five exceptions, including archived web content and preexisting conventional electronic documents ("word processing, presentation, PDF, or spreadsheet files available before the compliance date", with limitations for documents used in an active service), verified at https://www.ada.gov/resources/2024-03-08-web-rule/. Provision **E205.4** — "Electronic content shall conform to Level A and Level AA Success Criteria and Conformance Requirements in WCAG 2.0" — and the non-web-document exception for 2.4.1, 2.4.5, 3.2.3 and 3.2.4 verified at https://www.access-board.gov/ict/. Federal preference for HTML verified at https://www.section508.gov/create/pdfs/: "PDFs are still used across government, but they are often not the most accessible or mobile-friendly option. Federal policy requires agencies to prioritize HTML and use PDFs only when necessary." The PDF/UA standard's ISO title and current edition could **not** be verified — https://www.iso.org/standard/64599.html returned HTTP 403 — so write it as `PDF/UA (ISO 14289) (unverified — confirm at https://www.iso.org/standard/64599.html)`.

### Evidence required

Cheapest first. Steps 1 to 3 need no tool beyond Grep; steps 4 and 5 need a text-extraction tool and Skip without one.

**Source mode:**

1. **Build the link inventory.** `Grep` templates, content files, MDX, JSON content and CMS exports for `href` values ending `.pdf`, `.doc`, `.docx`, `.xls`, `.xlsx`, `.ppt`, `.pptx`, `.rtf`, `.csv`. Record each link with its `file:line`, its link text, and the page it sits on. This inventory is the category's spine — every later step reads from it.
2. **Classify each document.** Process-critical (the only route to information or to completing a process: forms, applications, statements, menus, schedules, policies, notices) or informational (a report, a brochure, a slide deck that repeats what a page already says). Classification comes from the page context around the link, quoted — never from the filename alone.
3. **Look for the HTML equivalent.** In the same list item, paragraph or table row as each document link, is there a sibling link to an HTML route carrying the same content? Quote the markup either way. This is the single highest-value check in the category and it costs one read.
4. **Test for a text layer** — *if a PDF text-extraction tool is available* (`pdftotext` is the common one). Extract each PDF's text and check whether anything non-whitespace comes back. No text plus a non-zero page count is row (2). Without such a tool: `Skip — text-layer test requires a PDF text-extraction tool; not run`, and say that installing one would unblock it.
5. **Read the tag flag** — *if a PDF information tool is available* (`pdfinfo` is the common one). Its `Tagged:` field is the tag signal: `Tagged: no` is row (3). Read the page count from the same output for step 4's non-zero check. Without the tool: `Skip — tag flag requires a PDF information tool; not run`.
6. **Read the link text** against row (6): does it name the format, and the size where the file is large?
7. **Apply the exceptions before scoring.** For a Title II entity, check each document against the five exceptions using the entity's compliance date from Cat 13's table. An excepted document is recorded with the exception named, at Low, and is not counted as a failure.

**Crawl mode:**

1. Fetch each page in the representative set and collect the same link inventory from the rendered HTML, recording URL + selector instead of `file:line`.
2. Fetch each document URL's headers where possible for content type and size; do not download large files to inspect them.
3. Apply steps 2, 3, 6 and 7 exactly as above against the fetched markup.
4. Steps 4 and 5 need the file locally and a tool. Without both: Skip with the reason.

Caveat for every extraction-derived check: a text layer proves text exists, not that it is in the right reading order, and `Tagged: yes` proves tags were written, not that they are correct. Say so in the finding. A tagged PDF with a wrong reading order is a real failure this category cannot see, and row (9) is the Skip that keeps that gap visible.

### Forbidden claims

- **"The PDF is compliant / conformant / non-compliant / accessible."** A text layer and a tag flag are two signals, not a document audit. Write `no text layer: text extraction returned nothing across 4 pages` and stop.
- **"The PDF's reading order is wrong."** Not observable from extraction. Skip row (9) with its wording.
- **"The figures in the PDF have no alternative text."** Same. Skip.
- **"The form fields in the PDF are unlabeled."** Same. Skip.
- **"This PDF is exempt."** The exceptions have conditions — a designated archive area, unchanged since archiving, reference or recordkeeping only, a date before the entity's compliance date. Quote the condition that is satisfied, or do not claim the exception.
- **"Replace every PDF with HTML."** The finding is about a specific document on a specific path. A blanket format policy is not a finding, and the fix section says why HTML is preferred without turning it into a rule the audit enforces.
- **A date, threshold or standard version with no verification line**, including the PDF/UA identifier, which is unverified.
- **"The document is untagged"** where the tag flag was never read. Absent the tool, the outcome is a Skip.

### Detection

Link inventory from source or rendered HTML, classification from the surrounding page context, an HTML-equivalent check in the same block as each link, and — where a text-extraction and information tool is available — a text-layer test and a tag-flag read per PDF. Inside-document structure is out of reach and Skips.

### What to Search For

- `href` values ending `.pdf`, `.doc`, `.docx`, `.xls`, `.xlsx`, `.ppt`, `.pptx`, `.rtf`, `.csv`
- The page context around each link: is this the application form, the menu, the schedule, the policy, the notice — or a brochure
- A sibling HTML link in the same list item, paragraph or table row
- Link text with no format word: "Download", "Click here", "2026 schedule", "More information"
- Link text with no size where the file is large
- Documents behind a login, on an account page, or in a checkout confirmation — those are process-critical almost by definition
- Documents in a route named `archive`, `archives`, `historical`, or dated before the entity's compliance date
- Files whose names suggest a scan: `scan`, `scanned`, `img`, a bare date, a bare number
- Generated documents — invoices, statements, tickets, receipts — produced by the application itself, which is source-fixable in a way an uploaded file is not
- The document-generation code path: any library call that writes a PDF, and whether it sets a document title, a language and structure tags

### Actually Fails

- **A process-critical document with no text layer and no HTML equivalent.** Evidence: the link with its `file:line` or URL, the page context proving it is the only route, and the extraction result across N pages. The highest-severity finding in this category.
- **A process-critical document that declares itself untagged, with no HTML equivalent.** Evidence: the link, the context, and the `Tagged: no` reading.
- **An informational document with no text layer.** Evidence: the same, at Medium, because a route around it exists.
- **A document link with no HTML equivalent where the content is plainly page-shaped** — a policy, a notice, a schedule. Evidence: the link markup and the absence of a sibling HTML route.
- **A generated document produced by this codebase with no structure.** Evidence: the generation call at `file:line` showing no title, no language and no tagging option set. This one is worth more than the others because it is fixable in source and it fixes every future document at once.
- **Link text that does not say it is a document.** Evidence: the quoted link text and its `href`. Low, but it is the cheapest fix on the list.
- **A document behind an authenticated route that is the only way to complete a process.** Evidence: the route and the link. Note that the Title II individualized password-protected document exception is narrow — it covers documents about a specific person, property or account, not every file behind a login.

### NOT a Failure

- A document that duplicates content already on an HTML page, where the page is linked beside it. Quote both links and record a Pass.
- A document inside a Title II exception whose conditions are quoted: an archived file in a designated archive area, unchanged since archiving, for reference, research or recordkeeping; a preexisting conventional electronic document dated before the entity's compliance date and not used in an active service; third-party content posted with no contractual arrangement; an individualized password-protected document about a specific person, property or account; a preexisting social media post.
- A PDF used because the document must be printed and signed, where an accessible alternative route to the same process exists and is linked.
- A document whose text layer extracts cleanly and whose tag flag reads `Tagged: yes`. That is a Pass with evidence — record the extraction and the flag, and record the row (9) Skip beside it so the reader knows what was not checked.
- A source file offered alongside a PDF — the DOCX or the CSV beside the report — which often reads better than the PDF does.
- 2.4.1, 2.4.5, 3.2.3 and 3.2.4 raised against a non-web document under Section 508. The Revised Standards excuse them.
- A large download with no size in the link text, where the size is shown adjacent in the same row. The information is present; the placement is a Cat 09 question, not a failure here.

### Context Check

1. Is this document the only route to the information or the process, or is there a page that carries the same content? That answer sets the severity.
2. Was the classification taken from the page context, or from the filename? Quote the context.
3. Is the entity a Title II entity, and does an exception apply with its conditions satisfied? Name the exception or drop the claim.
4. Was a text-extraction tool actually available? Without one, rows (2) and (3) Skip; they do not become "probably untagged".
5. Is the document generated by this codebase, or uploaded by a person? The generated case is a source fix that scales; the uploaded case is a content workflow.
6. How many documents are affected, and do they share a producer or a template? One producer setting is often the whole finding.
7. Is the report about to claim something about the inside of the document? Row (9) Skips; keep it that way.
8. Does an accessibility statement already list these documents as known limitations with an alternative route offered? Cross-reference Cat 14 rather than double-counting.

### Severity

One tier per finding.

- **High** — a process-critical document that is image-only or declares itself untagged, with no HTML equivalent. The form, the application, the statement, the schedule, the menu, the policy.
- **Medium** — an informational document with the same defect; a page-shaped document with no HTML equivalent; a generated-document code path that sets no title, language or tags; a PDF deliverable produced with no reference to PDF/UA where a bound regime is in scope.
- **Low** — link text that does not name the format or the size; a document inside a named exception, recorded so the reader can see it was considered.
- **Pass** — a document with a clean text extraction and a `Tagged: yes` flag, or one paired with a linked HTML equivalent, recorded with the evidence and with the row (9) Skip beside it.

Critical is not used here. A blocked process is Critical where the criterion is scored; this category reports the document that carries it.

### Fix guidance

The order is the same every time, and it is not the order people expect. Fix the route before fixing the file.

**1. Give the content a web page.** The document is a container, not the content. Where the content is page-shaped — a policy, a notice, a schedule, a menu — the fastest route to a usable version is an HTML page, which is also cheaper to maintain than a document that must be re-produced correctly every time it changes.

```html
<!-- Before: the only route to the enrolment process -->
<li><a href="/files/enrolment-2026.pdf">Download</a></li>

<!-- After: a route that works, and a document that says what it is -->
<li>
  <a href="/enrolment">Enrol online</a>
  (or <a href="/files/enrolment-2026.pdf">download the enrolment form, PDF, 480KB</a>)
</li>
```

Two things changed. The process now has a route that does not depend on the document at all, and the document link says what it is and what it costs to open. The second change takes a minute and it is the one that stops a person on a metered connection from downloading four megabytes to find out it was the wrong form.

**2. Fix the producer, not the file.** Where this codebase generates the documents, the fix is one code path and it covers every document produced after it:

```python
# Before: a PDF with no structure, no title, no language
pdf = Document()
pdf.add_paragraph(invoice_line)
pdf.save(path)

# After: title, language and tagging set at the producer
pdf = Document(tagged=True)
pdf.set_title(f"Invoice {invoice.number}")
pdf.set_language("en-GB")
pdf.add_heading(f"Invoice {invoice.number}", level=1)
pdf.add_table(rows, header_row=True)
pdf.save(path)
```

The exact API names differ by library; the four things to set do not. A title, a language, real headings instead of large bold text, and real table headers instead of a top row that only looks like one.

**3. Deal with the scans.** A scanned page with no text layer cannot be repaired by tagging it, because there is nothing to tag. Either run it through text recognition and correct the output, or — better where the original still exists — re-export from the source document. Where neither is possible and the content still matters, transcribe it to a page and link that beside the scan.

**4. Say what you did not fix.** The documents that stay imperfect belong in the accessibility statement's known-limitations list with an alternative route offered, which is Cat 14's shape. A named gap with a route around it is honest. A silent gap is the thing that gets found by the person who needed it.

One caveat to carry into every finding: a text layer and a tag flag are the two signals this audit can read from outside the file. Correct reading order, alternative text on figures, labelled form fields and real table headers are inside the document, and confirming them takes a person opening it with assistive technology or a document-checking tool. Say that in the report rather than implying the document passed.

### Reference

ADA Title II web and mobile app rule, including the archived-content and preexisting-document exceptions: https://www.ada.gov/resources/2024-03-08-web-rule/

Revised Section 508 Standards, provision E205.4 and the non-web document exception: https://www.access-board.gov/ict/ · Federal guidance on PDFs and the preference for HTML: https://www.section508.gov/create/pdfs/

WCAG 2.2 SC 1.1.1 Non-text Content: https://www.w3.org/WAI/WCAG22/Understanding/non-text-content.html · SC 1.3.1 Info and Relationships: https://www.w3.org/WAI/WCAG22/Understanding/info-and-relationships.html

W3C guidance on WCAG conformance for non-web documents and software: https://www.w3.org/TR/wcag2ict/

PDF/UA (ISO 14289) — title and current edition unverified on 2026-09-03; confirm at https://www.iso.org/standard/64599.html
