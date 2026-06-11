## CATEGORY 90: JobPosting schema

JobPosting schema unlocks Google's Jobs SERP integration (the dedicated jobs panel; the "find jobs" filter; ZipRecruiter / LinkedIn / Indeed federation). It's the highest-leverage schema for any company hiring at scale or any career site. Required fields done correctly mean Google indexes the role into Google for Jobs; missing fields mean the role is invisible to the most-used search surface for jobseekers in 2026.

### Pre-flight: relevance check

Skip this category with reason `not applicable` unless the site has at least one page describing a specific open role (title + employer + location + description). An "About / careers" page that only describes culture without listing roles is not a schema candidate.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify job-posting pages by URL pattern (`/careers/`, `/jobs/`, `/job/`, `/positions/`) AND content shape (job title + employer + responsibilities + apply CTA).
2. `Grep` for `"@type": "JobPosting"` inside JSON-LD blocks. Quote each.
3. For each JobPosting schema: parse the JSON. Check required fields per Google's spec: `title`, `description`, `datePosted`, `hiringOrganization`, `jobLocation` (or `jobLocationType: "TELECOMMUTE"` for remote).
4. Check strongly recommended: `validThrough`, `employmentType`, `baseSalary`. When `baseSalary` is present, verify it is well-formed (`MonetaryAmount` with `currency` and a `value` `QuantitativeValue` carrying `minValue`/`maxValue` + `unitText`) AND that it matches the salary visible on the page.

**Crawl mode, required tool calls:**

1. `Fetch` the URL. Find JSON-LD blocks. Parse.
2. Quote the entire `JobPosting` object.
3. Check required + recommended fields. Quote any missing.

### Forbidden claims

- "JobPosting schema is probably missing." Confirm the page IS a job posting AND parse.
- "Salary may not match." Quote both the schema and visible salary.

### Detection

Looking for `"@type": "JobPosting"` blocks on pages describing specific open roles.

### What to Search For

- `"@type": "JobPosting"`
- Required: `title`, `description` (HTML allowed), `datePosted`, `hiringOrganization` (Organization with `name`, `sameAs`, `logo`), `jobLocation` (Place with `address`) OR `jobLocationType: "TELECOMMUTE"` + `applicantLocationRequirements`
- Strongly recommended: `validThrough` (when the posting expires), `employmentType` (`FULL_TIME` / `PART_TIME` / `CONTRACTOR` / `TEMPORARY` / `INTERN`), `baseSalary` (with `value` and `unitText`)
- For remote roles: `jobLocationType: "TELECOMMUTE"` + `applicantLocationRequirements: { '@type': 'Country', name: 'USA' }`
- For hybrid: include both `jobLocation` and the remote indicators

### Actually Hurts the Marketing Surface

- **Job-posting page with no JobPosting schema**.
  Evidence required: URL + visible role description + missing JSON-LD.
- **`hiringOrganization` as plain string** (Google requires structured Organization).
  Evidence required: parsed value.
- **`jobLocation` missing** AND no `jobLocationType: "TELECOMMUTE"` (Google cannot place the role in geographic search).
  Evidence required: parsed schema with both absent.
- **`datePosted` in the past with no `validThrough`** (Google's documentation says posts older than 90 days without `validThrough` may be deprioritized or removed from Google for Jobs).
  Evidence required: `datePosted` value + missing `validThrough`.
- **Filled / closed role still has active JobPosting schema** (the role no longer accepts applications but the schema still indicates it does).
  Evidence required: visible "filled" / "closed" indicator on page + active schema.
- **`baseSalary` in schema does not match the salary visible on the page** (a real manual-action trigger, Google flags structured data that contradicts page content).
  Evidence required: parsed `baseSalary` + quoted visible salary, with the diff highlighted.
- **`baseSalary` malformed** (missing `currency`, or a `value` without `minValue`/`maxValue` or without `unitText` like `YEAR`/`HOUR`). Malformed `baseSalary` is dropped by Google and can invalidate the salary display.
  Evidence required: parsed `baseSalary` with the missing field named.
- **`description` is a list of perks instead of role responsibilities** (Google ranks job pages by content quality; the description must describe the role).
  Evidence required: quoted description content.
- **Remote role missing `applicantLocationRequirements`** (Google can't filter by jobseeker location).
  Evidence required: schema marks `TELECOMMUTE` but lacks `applicantLocationRequirements`.

### NOT a Problem

- Generic "we're hiring" page (not a specific role) without JobPosting schema, correct (use `ItemList` if listing multiple roles).
- A careers landing page with culture content but no roles, not a JobPosting candidate.
- `validThrough` absent on a posting <30 days old, acceptable; flag at 90+ days.

### Context Check

1. Is the page a specific role with title + responsibilities + apply CTA?
2. Is `hiringOrganization.sameAs` the brand's canonical homepage / Wikidata / Crunchbase URL? Helps entity disambiguation.
3. Is the role open right now? Closed roles should remove the JobPosting schema and either redirect or mark the page as archived.
4. Is the posting older than 90 days without `validThrough`? Will be deprioritized.
5. Does `baseSalary` match the visible salary on the page?

### Reference

Google's JobPosting documentation: https://developers.google.com/search/docs/appearance/structured-data/job-posting

Schema.org JobPosting: https://schema.org/JobPosting

Google for Jobs guidelines: https://developers.google.com/search/docs/appearance/structured-data/job-posting#guidelines

**Severity tagging:**
- Job-posting page with no JobPosting schema → Critical (invisible to Google for Jobs).
- `hiringOrganization` as string → High.
- `jobLocation` missing AND no TELECOMMUTE → Critical.
- `datePosted` >90d without `validThrough` → High.
- Filled role with active schema → High (lies to applicants).
- `baseSalary` mismatch (schema vs visible page) → High (manual-action trigger for schema/content mismatch).
- Malformed `baseSalary` (missing `minValue`/`maxValue`/`unitText`/`currency`) → Medium (Google drops the salary display).
- Description without role responsibilities → Medium.

**Fix voice:** `mike-monteiro` (primary) | `solutions-architect` (backup).

Read `souls/mike-monteiro.json` before writing the Fix.

Worked fix example:

> A job posting is a contract with the candidate. If you list the title, you mean the title. If you list the salary, you mean the salary. If you list the location, you mean the location. The JobPosting schema is the version of that contract Google reads, if your schema says one thing and your page says another, you are lying to one of them, and that's not a strategy that ages well.
>
> ```tsx
> const jobSchema = {
>   '@context': 'https://schema.org',
>   '@type': 'JobPosting',
>   title: role.title,
>   description: role.responsibilitiesHTML,
>   datePosted: role.openedAt,
>   validThrough: role.expiresAt,
>   employmentType: role.type,           // 'FULL_TIME' | 'PART_TIME' | 'CONTRACTOR' | etc.
>   hiringOrganization: {
>     '@type': 'Organization',
>     name: 'Snitch',
>     sameAs: 'https://snitchplugin.com',
>     logo: 'https://snitchplugin.com/logo.png',
>   },
>   jobLocation: role.remote
>     ? undefined
>     : { '@type': 'Place', address: role.address },
>   jobLocationType: role.remote ? 'TELECOMMUTE' : undefined,
>   applicantLocationRequirements: role.remote
>     ? { '@type': 'Country', name: role.applicantCountry }
>     : undefined,
>   baseSalary: role.salary
>     ? {
>         '@type': 'MonetaryAmount',
>         currency: 'USD',
>         value: { '@type': 'QuantitativeValue',
>                  minValue: role.salary.min,
>                  maxValue: role.salary.max,
>                  unitText: 'YEAR' },
>       }
>     : undefined,
> };
> ```
>
> Then: when the role closes, the schema goes away. Not "stays up but with a banner." Goes away. Either delete the page, 410 it, or remove the JobPosting block and let the page exist as an archive. Active schema on a closed role wastes the time of every applicant who clicks through, and Google notices.
