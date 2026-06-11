## CATEGORY 59: AI-content tells

Pages written by AI without editing have characteristic patterns: over-hedging, generic transitions, made-up statistics, em dashes everywhere, "delve into", "in today's fast-paced world", "it's important to note that". Google's helpful-content system is increasingly tuned to demote slop. The fix isn't "remove AI", it's "edit so the page sounds like a person who knows what they're talking about."

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. `Read` the page content fully.
2. Scan for AI tells: hedging frequency, generic transition density, made-up "studies show" without citations, em dash density (suspicious if every paragraph has one), platitudes ("in today's fast-paced world").
3. Quote 3-5 tell-bearing sentences with the pattern called out.

**Crawl mode, required tool calls:**

1. Same as source on rendered content.

### Forbidden claims

- "The content may be AI-generated." You can't prove provenance, only call out tells. Don't claim provenance.
- "The page reads as AI." Quote the specific patterns.

### Detection

Pattern scan on content text.

### What to Search For

AI tells (case-insensitive):
- "delve into", "delving into"
- "in today's fast-paced world"
- "it's important to note"
- "navigate the complexities"
- "tapestry of"
- "leverage" / "leveraging" (extremely common in AI output)
- "robust solution"
- "harness the power of"
- Heavy em dash density (>1 per paragraph)
- "Studies show that..." with no actual study cited
- Lists of "5 ways to" / "10 tips for" with platitude content

### Actually Hurts SEO

- **High density of AI-tell phrases**.
  Evidence required: quoted tells + frequency count.
- **Made-up statistics** ("85% of marketers say..." with no source).
  Evidence required: quoted stat + missing citation.
- **Generic transitions throughout** ("Furthermore", "Additionally", "It's worth noting").
  Evidence required: quoted samples.
- **Em dash overload** (more than ~1 per 200 words).
  Evidence required: count + sample paragraphs.

### NOT a Problem

- AI-assisted content that's been edited by a human until it sounds like the human (the goal, not "no AI", but "edited AI").
- Lists with substantive items (10 things with concrete details, not 10 platitudes).
- Em dashes used sparingly for genuine emphasis.

### Context Check

1. Does the page have a real author byline? AI-without-edit slop usually doesn't.
2. Are the examples concrete or vague? Vague is the AI tell; concrete suggests real expertise.
3. Are the citations real? Made-up "studies" are the strongest tell.
4. Does the page sound like the rest of the site's content? Sudden voice shift = inserted AI page.

### Reference

Google on AI-generated content: https://developers.google.com/search/blog/2023/02/google-search-and-ai-content

**Severity tagging:**
- Heavy AI tells throughout → High.
- Made-up statistics → Critical (factual misrepresentation).
- Em dash overload as the dominant punctuation → Medium.

**Fix voice:** `mike-monteiro` (primary) | `frank-chimero` (backup).

Read `souls/mike-monteiro.json` before writing the Fix. Mike's voice on cutting bullshit out of writing.

Worked fix example:

> The page reads like every other AI-generated page on the internet. Generic transitions, hedged claims, made-up percentages, an em dash in every paragraph. None of it sounds like anyone in particular wrote it.
>
> Edit it like you would edit a junior writer's first draft.
>
> 1. Cut every "in today's fast-paced world", "delve into", "navigate the complexities". Replace with what you actually meant.
> 2. Cut hedging. "It's important to note that X" becomes "X." If X isn't important, cut X entirely.
> 3. Replace made-up stats with real ones (cited) or remove the stat and make the point another way.
> 4. Get the em dash count to under one per 200 words. Use commas / periods / colons / semicolons / parens for the rest.
> 5. Read the page out loud. If you'd cringe saying it to a friend, rewrite it.
>
> The result sounds like a person who knows the topic. Google's algorithm increasingly distinguishes that voice from the slop voice. So do readers.
