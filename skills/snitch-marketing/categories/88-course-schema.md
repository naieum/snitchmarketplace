## CATEGORY 88: Course schema

Course schema feeds the surviving Course List carousel (the `ItemList` of `Course` grid Google shows for course-discovery queries) and AI-search / LLM consumption (AI Overviews, ChatGPT, Perplexity reading structured course data). Google REMOVED the per-course rich result (the standalone "course card with provider + duration") on 2025-09-09, so a single course detail page no longer earns its own SERP card from this schema. The schema is still worth shipping: it qualifies catalog pages for the Course List carousel and makes course data machine-readable for AI surfaces. It applies to online courses, bootcamps, university programs, structured learning paths, and certificate-bearing tutorials. Most education-focused sites publish a course catalog page and detail pages, both deserve schema, with different shapes (`ItemList` of `Course` for catalog, full `Course` for detail).

### Pre-flight: relevance check

Skip this category with reason `not applicable` unless the site offers structured learning with named courses, defined providers, and (typically) enrollment. A blog tagged "tutorial" is not a course. A multi-lesson Udemy-style series with a named instructor and price IS a course.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify course-type pages by URL pattern (`/courses/`, `/learn/`, `/program/`, `/certificate/`) AND content shape (named instructor, defined curriculum, enrollment CTA).
2. `Grep` for `"@type": "Course"` inside JSON-LD blocks. Quote each.
3. For each Course schema: parse the JSON. Check required fields: `name`, `description`, `provider` (must be `Organization` with `name` + `sameAs`).
4. Check recommended fields: `hasCourseInstance` (with `courseMode`, `instructor`, `startDate`, `endDate`, `location`, `offers`), `coursePrerequisites`, `educationalCredentialAwarded`.

**Crawl mode, required tool calls:**

1. `Fetch` the URL. Find JSON-LD blocks. Parse.
2. Quote the entire `Course` object.
3. Check required + recommended fields. Quote any missing.

### Forbidden claims

- "Course schema is probably missing." Confirm the page IS a course AND parse for the schema.
- "Provider may not match." Quote the provider object and the visible institution name.

### Detection

Looking for `"@type": "Course"` blocks on pages offering structured learning.

### What to Search For

- `"@type": "Course"`
- Required fields: `name`, `description`, `provider` (Organization with `name` + `sameAs`)
- Recommended: `hasCourseInstance` (CourseInstance with `courseMode`, `instructor`, `startDate`, `endDate`, `location`, `offers`), `coursePrerequisites`, `educationalCredentialAwarded`, `aggregateRating`, `review`
- For self-paced courses: `courseMode: "online"` + omit `startDate`/`endDate`
- For cohort-based: include `startDate`/`endDate`/`courseSchedule`

### Actually Hurts the Marketing Surface

- **Course-type page with no Course schema**. The per-course card was removed (2025-09-09), so missing schema on a single detail page no longer "loses a course card"; the cost is reduced AI-search legibility and (for catalog pages) ineligibility for the Course List carousel. Severity is correspondingly modest, not High.
  Evidence required: URL + visible course content + missing JSON-LD.
- **`provider` field as plain string instead of structured `Organization`** (Google requires structured provider for Course List eligibility; AI surfaces also parse it).
  Evidence required: parsed `provider` value.
- **`provider.sameAs` missing** (recommended for entity disambiguation).
  Evidence required: parsed `provider`.
- **Catalog / index page uses `Course` instead of `ItemList` of `Course`** (the Course List carousel is built from an `ItemList`; a single Course block on an index page can't qualify for it).
  Evidence required: page is an index + single Course block present.
- **`hasCourseInstance` missing for cohort-based courses** (recommended detail for AI consumption and completeness; note the per-course SERP card no longer renders this, so this is informational, not a card-breaking miss).
  Evidence required: parsed schema + visible cohort start date on page.
- **Faked / unattributed `aggregateRating`** (manual-action risk, same as other schema types).
  Evidence required: schema rating value + missing on-page review evidence.

### NOT a Problem

- Free course without `offers`, acceptable (Google understands free courses).
- A multi-lesson blog series without enrollment / instructor / credential, not a course; do not flag.
- `educationalCredentialAwarded` absent on courses that don't grant a credential, correct.
- Multiple `hasCourseInstance` entries (e.g., quarterly cohorts), correct, each instance is its own offering.

### Context Check

1. Is the page actually a course (named provider + structured curriculum + enrollment)?
2. Is the catalog page using `ItemList` (correct) vs `Course` (incorrect for an index)?
3. Is the provider a proper `Organization` with `sameAs` URLs (Wikipedia / LinkedIn / official)?
4. Are cohort dates accurate? Stale start dates feed wrong data to the Course List carousel and to AI surfaces.

### Reference

Google's Course List documentation (the per-course rich result was removed 2025-09-09; the Course List carousel survives): https://developers.google.com/search/docs/appearance/structured-data/course-info

Schema.org Course: https://schema.org/Course

Schema.org CourseInstance: https://schema.org/CourseInstance

**Severity tagging:**
- Course-type page with no Course schema → Low (per-course card removed 2025-09-09; cost is reduced AI legibility, not a lost SERP card).
- Catalog page using `Course` instead of `ItemList` → Medium (blocks Course List carousel eligibility).
- `provider` as string → Medium (Course List eligibility + AI parsing).
- `hasCourseInstance` missing for cohort-based → Low (informational; no longer renders a card).
- Faked `aggregateRating` → Critical.

**Fix voice:** `frank-chimero` (primary) | `jen-simmons` (backup).

Read `souls/frank-chimero.json` before writing the Fix.

Worked fix example:

> A course is a promise to a learner, here is what you'll learn, here is who is teaching it, here is how to enroll. The Course schema makes that promise machine-readable.
>
> ```tsx
> const courseSchema = {
>   '@context': 'https://schema.org',
>   '@type': 'Course',
>   name: course.title,
>   description: course.summary,
>   provider: {
>     '@type': 'Organization',
>     name: 'Snitch Academy',
>     sameAs: 'https://snitchplugin.com',
>   },
>   hasCourseInstance: course.cohorts.map(cohort => ({
>     '@type': 'CourseInstance',
>     courseMode: cohort.mode,           // 'online' | 'onsite' | 'blended'
>     instructor: { '@type': 'Person', name: cohort.instructor.name },
>     startDate: cohort.startDate,
>     endDate: cohort.endDate,
>     location: cohort.location,
>     offers: { '@type': 'Offer', price: cohort.price, priceCurrency: 'USD' },
>   })),
>   coursePrerequisites: course.prerequisites,
>   educationalCredentialAwarded: course.credential,
> };
> ```
>
> A catalog page is a different shape, `ItemList` of `Course` references, not one big `Course` block. Match the structure to what the page actually does, and Google will surface the right rich result.
