## CATEGORY 93: Person / Author schema

`Person` schema is the structured signal for individual humans on a site, author bylines, founder bios, expert contributors, instructor profiles. It feeds the knowledge panel for personal brands, attaches authorship to articles (cross-reference Cat 32), drives E-E-A-T (Experience, Expertise, Authoritativeness, Trustworthiness) signals that Google ranks heavily on YMYL queries, and helps AI assistants cite individual humans when answering category questions (cross-reference Cat 82).

`Person` schema is the structured-data half of the Expertise + Trust layers in `references/eeat-assessment.md`; missing or unverifiable authorship is an E-E-A-T finding, not just a missing-schema finding.

### Pre-flight: relevance check

Skip this category with reason `not applicable` ONLY if the site has no named humans associated with it (no author bylines, no founder bio, no team page, no testimonials). Most sites have at least one Person to model.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify pages with named humans: `/about`, `/team`, `/authors/`, `/blog/[post]` (author byline), `/instructor/`, founder pages.
2. `Grep` for `"@type": "Person"` inside JSON-LD blocks. Quote each.
3. Parse the JSON. Check required: `name`. Strongly recommended: `url`, `image`, `jobTitle`, `worksFor` (Organization), `sameAs` (LinkedIn, X, GitHub, Wikipedia, ORCID, for entity disambiguation).
4. Cross-reference `Person` schema with author bylines on Article schema (Cat 32), if articles link an `author` Person object, that Person should also have its own canonical Person schema on a profile page.

**Crawl mode, required tool calls:**

1. `Fetch` the about / team / author profile page. Find JSON-LD blocks.
2. Quote the entire `Person` object.
3. Check required + recommended fields. Quote any missing.

### Forbidden claims

- "Person schema is probably missing on the author byline." Confirm the byline names a real person AND check the page for Person schema.
- "Author may not match the post." Quote both the byline and the schema.

### Detection

Looking for `"@type": "Person"` blocks on pages that profile or attribute content to specific humans.

### What to Search For

- `"@type": "Person"`
- Required: `name`
- Strongly recommended: `url` (canonical profile page), `image` (headshot), `jobTitle`, `worksFor` (Organization), `sameAs` (LinkedIn, X/Twitter, GitHub, Wikipedia, ORCID, personal website)
- Optional but useful for E-E-A-T: `alumniOf` (educational institution), `award`, `knowsAbout` (topics they're authoritative on), `description` (bio)
- For author bylines on Articles: the author should be a `Person` reference (`@id` pointing at their canonical profile page), not a duplicate inline definition

### Actually Hurts the Marketing Surface

- **Author byline on a blog post is a string, not a Person object** (E-E-A-T signal weakens; AI extractors can't credit a real human).
  Evidence required: parsed `author` value on Article schema.
- **`Person` schema on a team page lacks `sameAs`** (no entity disambiguation; Google can't connect the person to their LinkedIn / Wikipedia / etc.).
  Evidence required: parsed schema.
- **Person referenced by multiple Articles has no canonical profile page** (E-E-A-T best practice: each author has a profile page that's the canonical Person entity).
  Evidence required: bylines link to no profile / link to a duplicate Person schema.
- **`jobTitle` / `worksFor` mismatch** (the schema says one role; the page says another).
  Evidence required: both quoted.
- **Stale `image` URL (404 or wrong person)**, embarrassing in the knowledge panel.
  Evidence required: schema `image` URL + fetch result.
- **Fake / pseudonymous author with no `sameAs`** (Google's quality guidelines treat pseudonymous experts skeptically; for YMYL topics, real-name authorship matters).
  Evidence required: byline + missing identity disambiguation signals.

### NOT a Problem

- A site with no named individuals (purely brand-voiced content from an Organization, not a Person), acceptable; use Organization schema instead.
- A `Person` schema without `award` or `alumniOf`, these are optional polish, not requirements.
- Multiple Persons on a team page in an `ItemList`, correct.

### Context Check

1. Is the site's content authored by named individuals or only by the brand? If individuals, every byline should resolve to a Person.
2. Does each author have a canonical profile page that holds the authoritative Person schema?
3. Does `sameAs` include the author's primary public identity (LinkedIn for B2B, X/GitHub for tech, ORCID for academic)?
4. For YMYL topics (health, finance, legal), is the author's expertise visible (credentials, publications, affiliation)? E-E-A-T strongly weighted here.

### Reference

Schema.org Person: https://schema.org/Person

Google's E-E-A-T guidance: https://developers.google.com/search/docs/fundamentals/creating-helpful-content

Author bylines + structured data: https://developers.google.com/search/docs/appearance/structured-data/article#author

**Severity tagging:**
- Author byline as string instead of Person object → High.
- `Person` schema without `sameAs` → Medium.
- Author with no canonical profile page → Medium.
- `jobTitle` / `worksFor` mismatch → Medium.
- Stale `image` URL → Low.
- Pseudonymous author for YMYL content with no identity disambiguation → High.

**Fix voice:** `frank-chimero` (primary) | `mike-monteiro` (backup).

Read `souls/frank-chimero.json` before writing the Fix.

Worked fix example:

> The byline at the top of a post is a promise: a real person stands behind these words and is reachable for follow-up. Person schema makes that promise machine-readable, Google connects the human to their other public identities, AI extractors credit the human when answering a question, and readers can verify whose POV they're reading.
>
> Build one canonical profile page per author. Each post's byline points at it.
>
> ```tsx
> // /authors/eric-waters route
> const authorSchema = {
>   '@context': 'https://schema.org',
>   '@type': 'Person',
>   '@id': 'https://snitchplugin.com/authors/eric-waters#person',
>   name: 'Eric Waters',
>   url: 'https://snitchplugin.com/authors/eric-waters',
>   image: 'https://snitchplugin.com/authors/eric-waters/avatar.png',
>   jobTitle: 'Security Engineer',
>   worksFor: { '@type': 'Organization', name: 'Snitch', url: 'https://snitchplugin.com' },
>   sameAs: [
>     'https://www.linkedin.com/in/eric-waters-snitch',
>     'https://github.com/eric-waters-snitch',
>   ],
>   knowsAbout: ['application security', 'CVE response', 'AI-generated code review'],
>   description: 'Security Engineer at Snitch focused on CVE response and review tooling for AI-generated code.',
> };
>
> // each Article references the author by @id
> const articleAuthor = { '@id': 'https://snitchplugin.com/authors/eric-waters#person' };
> ```
>
> The `@id` reference keeps the canonical Person definition in one place; every Article that names Eric points at the same entity. When his role changes, the schema updates in one file. Trust signal compounds, surface stays consistent.
