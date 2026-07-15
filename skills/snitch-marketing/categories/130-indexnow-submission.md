## CATEGORY 130: IndexNow / indexing-submission readiness

A sitemap is a standing inventory: it lists what exists. It does not tell a search engine
that something just changed. IndexNow is the change-notification layer. One ping, sent when a
URL is added, updated, or removed, is shared across the engines that participate (Bing,
Yandex, Seznam, Naver), so those engines learn about the change immediately instead of waiting
for the next organic recrawl. To use it, a site hosts a key file at its root (`/{key}.txt`)
and runs an automated submission step that fires on publish. This category audits whether a
site is set up to push those notifications at all, and whether it is using the right channel
for its content and its audience.

The honest constraint that shapes this whole category: Google does not consume IndexNow.
Google has said so publicly. IndexNow does not speed up Google indexing or change Google
ranking. For Google, the discovery path is a clean XML sitemap with honest `lastmod` values
plus internal links from pages that already get crawled. The Google Indexing API is a separate
mechanism limited to officially eligible content types (`JobPosting` and `BroadcastEvent`
livestreams); for anything else it is not an eligible channel. A team that wires IndexNow
expecting it to help Google has solved a problem it does not have and left the Google one
unsolved. Correcting that expectation is part of the audit.

Scope note: distinct from Cat 2 (sitemap.xml presence and structure) and Cat 1 (robots.txt).
Sitemaps and IndexNow are complementary, not redundant: the sitemap is the standing inventory,
IndexNow is the change notification. This category is the "are you actively pushing change
notifications, on the right channel" check. It audits readiness only. It does not itself submit
anything, and running it requires no external submission tool.

### Pre-flight: relevance check

Skip with reason `not applicable, low-velocity surface; sitemap fully suffices and new URLs
are rare` for brochure / marketing sites that publish infrequently and rarely add routes. Note
that IndexNow is optional for them rather than missing. Skip with reason `Google-only audience;
IndexNow engines bring little traffic here` when analytics or target geography show the
audience is effectively all Google, and note the tradeoff rather than forcing the mechanism.
Required for high-velocity sites: frequent new or updated URLs (active blog / news / changelog,
large catalogs, programmatic page generation per Cat 95) combined with a real Bing / Yandex /
Seznam / Naver audience. Borderline (moderate velocity, mixed audience): run it scoped to
whether fast discovery is wired and whether the Google path is healthy on its own.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Glob` for a key file in the public root: `public/*.txt`, `static/*.txt`, `assets/*.txt`,
   root-level `*.txt`. Inspect any candidate for a long hex key string (the IndexNow key is
   typically 8 to 128 hex characters, filename matching contents). Quote what you find or
   record the absence with the directories checked.
2. `Grep` the repo for `indexnow` (case-insensitive) across CI configs, deploy scripts,
   `package.json` scripts, CMS webhook handlers, and serverless functions. A submission step
   POSTs changed URLs to the IndexNow endpoint on publish; quote it or record its absence.
3. Establish content velocity: count blog / changelog / route additions over a recent window,
   or note programmatic generation. A slow site and a fast site get different findings.
4. If no submission step exists, check whether a sitemap-ping or recrawl-request step exists
   instead, so the finding distinguishes "no fast discovery at all" from "uses a different
   mechanism."

**Crawl mode, required tool calls:**

1. `Fetch` `{origin}/robots.txt` and the declared sitemap(s); scan for any IndexNow key
   reference or `IndexNow:` line. Quote what is present.
2. If a key filename is referenced anywhere, `Fetch` `{origin}/{key}.txt` and quote the status
   and body. A referenced-but-missing or mismatched key file means submissions are silently
   rejected.
3. Infer publishing cadence from sitemap `lastmod` values and visible blog / news dates, so the
   velocity judgment rests on observed data, not assumption.

If a mode cannot run (no source access, or no crawlable origin), Skip that mode with the reason
and report from the mode that did run. Never infer a key file or a pipeline step you did not
see.

### Forbidden claims

- "IndexNow will speed up your Google indexing" or "improve Google ranking." False. Google does
  not consume IndexNow. Never write this, even as encouragement.
- "You should use the Google Indexing API." Only if the content is an officially eligible type
  (`JobPosting`, `BroadcastEvent` livestream). For everything else the Google path is sitemap
  plus internal links; do not recommend the Indexing API for ordinary pages.
- "The site has no fast-discovery mechanism." First show the `Glob` for the key file, the
  `Grep` for the submission step, and the sitemap / robots check. Absence is a finding only
  after you looked.
- "This site needs IndexNow." Not for a low-velocity or Google-only surface. State velocity and
  audience evidence before recommending it.

### Detection

Readiness mapping: key file present at root and matching, automated submission step on publish,
content velocity, and audience composition, cross-checked against the Google reality (sitemap +
internal links is the Google path; Indexing API only for eligible types).

### What to Search For

- An IndexNow key file at the site root (`/{key}.txt`) whose contents match the filename
- A submission step that fires on publish (CI job, deploy hook, CMS publish webhook) and POSTs
  added / changed / removed URLs to the IndexNow endpoint
- Content-velocity signals: active blog / news / changelog, large or growing catalogs,
  programmatic page generation (cross-ref Cat 95)
- Audience signals that the Bing / Yandex / Seznam / Naver engines matter for this site
  (analytics, target markets, language / geography)
- A healthy Google discovery path independent of all of the above: a clean sitemap with honest
  `lastmod` (Cat 2) and internal links from crawled pages
- A mistaken IndexNow-for-Google expectation in comments, docs, pipeline names, or task copy

### Actually Hurts the Marketing Surface

- **High-velocity site with no fast-discovery mechanism at all.** Frequent new or updated URLs
  rely entirely on organic recrawl, so the participating engines learn about changes late and
  new content earns visibility slower than it could.
  Evidence required: velocity count + `Glob`/`Grep` showing no key file and no submission step.
- **A team relying on or expecting IndexNow to help Google.** Effort is pointed at a channel
  Google ignores, and the real Google path may be neglected as a result.
  Evidence required: the IndexNow-for-Google expectation quoted + the state of the sitemap /
  internal-link path that should be carrying Google.
- **Key file referenced but missing or mismatched at the root.** Submissions are silently
  rejected, so the site believes it is notifying when it is not.
  Evidence required: the reference location + the `Fetch` status/body of `/{key}.txt`.
- **Submission is manual or ad hoc rather than automated on publish.** It depends on someone
  remembering, which means it lapses; the mechanism exists but does not run reliably.
  Evidence required: the manual process (or its absence in CI) + no on-publish trigger found.
- **Stale sitemap `lastmod` on an otherwise high-velocity site.** Even the standing inventory
  stops signaling change, which weakens the Google path too (cross-ref Cat 2).
  Evidence required: sitemap `lastmod` values that do not move when content changes.

### NOT a Problem

- A low-velocity brochure / marketing site where the sitemap fully suffices and new URLs are
  rare. IndexNow is optional here; note it as available, not missing.
- A Google-only audience where the IndexNow engines bring little traffic. Note the tradeoff and
  do not force the mechanism; the team's effort belongs on the Google path.
- A site that already hosts a matching key file and submits on publish. Pass with the evidence:
  the key file fetch, the submission step, and the velocity that justifies it.
- A site using the Google Indexing API only for officially eligible types (`JobPosting`,
  `BroadcastEvent` livestream). That is correct usage, not a finding.
- A site that leans on a clean sitemap plus strong internal linking for Google and skips
  IndexNow because its audience is Google. That is a deliberate, correct channel choice.

### Context Check

1. What is the content velocity? Frequent additions and edits make fast discovery valuable;
   rare changes make a sitemap sufficient.
2. Who is the audience? Do the IndexNow engines (Bing, Yandex, Seznam, Naver) carry meaningful
   share for this market, or is the audience effectively all Google?
3. Is a key file present at the root and does its content match its filename? A mismatch means
   submissions fail silently.
4. Is submission automated on publish, or does it depend on someone remembering to run it?
5. Is anyone expecting IndexNow to help Google? If so, correct it: Google does not consume
   IndexNow.
6. Is the Google path itself healthy, independent of IndexNow? Clean sitemap with honest
   `lastmod` plus internal links from crawled pages. The Indexing API applies only to eligible
   types.

### Reference

IndexNow protocol: https://www.indexnow.org/ , with engine docs from Bing
(https://www.bing.com/indexnow) and Yandex. Google's stated position that it does not use
IndexNow: https://developers.google.com/search/blog (Google has confirmed it relies on its own
crawling and sitemaps). Google Indexing API eligibility, limited to `JobPosting` and
`BroadcastEvent`: https://developers.google.com/search/apis/indexing-api/v3/quickstart .
Cross-ref Cat 2 (sitemap.xml) and Cat 1 (robots.txt).

**Severity tagging:**
- High-velocity site with a real Bing / Yandex audience and no fast-discovery mechanism at all → Medium.
- Key file referenced but missing or mismatched, so submissions silently fail → Medium.
- A team relying on or expecting IndexNow to help Google → Low (correct the expectation).
- Manual rather than automated submission on an otherwise sound setup → Low.
- Already wired and submitting on publish, key file present and matching → Pass (record the evidence).

**Fix voice:** `solutions-architect` (primary) | `analytics-engineer` (backup).

Read `souls/solutions-architect.json` before writing the Fix.

Worked fix example:

> Decide the channel before wiring anything, because the two audiences need different
> mechanisms and conflating them wastes effort. This is a business decision first: which engines
> actually send you traffic, and is your publishing cadence high enough that "discovered next
> week" costs you anything? If the answer is a slow brochure site that lives on Google, the
> simplest correct architecture is no IndexNow at all. Keep a clean sitemap and good internal
> links and stop there.
>
> If you do have real velocity and a real Bing / Yandex / Seznam / Naver audience, wire two
> channels and keep them separate:
>
> 1. **The IndexNow engines.** Host the key file at the site root (`/{key}.txt`, contents
>    matching the filename) and add one submission step that POSTs changed URLs on publish. Put
>    it in the deploy pipeline, not in a person's checklist, so it cannot be forgotten and
>    cannot drift. This is a reversible decision: there is no standing state to unwind, so if it
>    adds noise you remove the step and you are back where you started.
> 2. **Google.** Google does not read IndexNow, so do not route any effort there expecting it to
>    help. Google's path is a clean XML sitemap with honest `lastmod` plus internal links from
>    pages that already get crawled. The Indexing API is only for `JobPosting` and
>    `BroadcastEvent` livestreams; for ordinary pages it is not an eligible channel, so do not
>    build against it.
>
> Make the failure modes explicit. A key file that does not match its filename fails silently,
> so the pipeline should fetch `/{key}.txt` after deploy and assert the body before it trusts a
> submission. Verify the whole thing by publishing one test URL, confirming the submission
> request returned a success status, and confirming the Google side independently by checking
> that the sitemap `lastmod` moved. Two channels, one decision, each verified on its own terms.
