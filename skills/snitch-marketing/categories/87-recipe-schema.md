## CATEGORY 87: Recipe schema

Recipe schema unlocks Google's recipe rich result, the "by ingredient" filter, voice-search recipe responses, and the recipe carousel. It's the highest-leverage schema for any food, cooking, or beverage site. Get the required fields right and a single post can earn the rich result; get them wrong and Google quietly drops you from the recipe SERP.

### Pre-flight: relevance check

Skip this category with reason `not applicable` unless the site has at least one page that publishes a complete recipe (ingredient list + numbered instructions + yield). Cooking-themed blog posts that don't include a structured recipe should not get Recipe schema and aren't relevant here.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify recipe-type pages by URL pattern (`/recipe/`, `/recipes/`, `/cook/`) AND/OR by content shape (ingredient list + ordered instructions). Quote each candidate URL.
2. `Grep` for `"@type": "Recipe"` inside JSON-LD blocks. Quote each.
3. For each Recipe schema: parse the JSON. Check required fields per Google's rich-result spec: `name`, `image`, `recipeIngredient`, `recipeInstructions`. Recommended: `author`, `datePublished`, `description`, `prepTime`, `cookTime`, `totalTime`, `recipeYield`, `nutrition`, `aggregateRating`, `video`.
4. Cross-check structured `recipeIngredient` count vs visible ingredient count on the page. Divergence is a Rule-1 violation against the reader's contract.

**Crawl mode, required tool calls:**

1. `Fetch` the URL. Find JSON-LD blocks. Parse.
2. Quote the entire `Recipe` object.
3. Check required + recommended fields. Quote any missing.
4. Validate against Google's Rich Results Test (https://search.google.com/test/rich-results) shape; quote which warnings it would produce.

### Forbidden claims

- "Recipe schema is probably missing." Confirm the page IS a recipe AND parse for the schema.
- "The structured ingredients may differ from the visible ingredients." Quote both lists; show the diff.
- "Yield may be wrong." Quote `recipeYield` from schema and from visible page; show.

### Detection

Looking for `"@type": "Recipe"` blocks on pages that publish complete recipes (ingredients + instructions + yield).

### What to Search For

- `"@type": "Recipe"`
- Required fields: `name`, `image`, `recipeIngredient` (array of strings), `recipeInstructions` (array of `HowToStep` objects)
- Recommended fields: `author`, `datePublished`, `description`, `prepTime`, `cookTime`, `totalTime`, `recipeYield`, `recipeCategory`, `recipeCuisine`, `nutrition`, `aggregateRating`, `video`
- Time fields use ISO 8601 duration format (`PT30M`, `PT1H15M`)

### Actually Hurts the Marketing Surface

- **Recipe-shaped page with no Recipe schema**.
  Evidence required: URL pattern + visible ingredient list + visible instructions + missing JSON-LD.
- **Recipe schema missing required fields** (`name`, `image`, `recipeIngredient`, `recipeInstructions`).
  Evidence required: parsed schema with field absent.
- **Structured `recipeIngredient` count diverges from visible ingredient count** (page lists 12 ingredients; schema lists 9).
  Evidence required: both lists quoted with counts.
- **`recipeInstructions` as a single string instead of `HowToStep` array** (Google prefers structured steps for the rich result).
  Evidence required: parsed `recipeInstructions` value.
- **Time fields not in ISO 8601 duration** (`"30 minutes"` instead of `"PT30M"`).
  Evidence required: quoted time value.
- **`recipeYield` missing when per-serving `nutrition` is present** (Google requires `recipeYield` so per-serving nutrition can be interpreted; without nutrition it's only Recommended, see "What to Search For").
  Evidence required: parsed schema showing `nutrition` present + `recipeYield` absent.
- **`image` below Google's minimum of 50,000 total pixels** (advisory). Google's actual rule is a minimum of 50,000 pixels (width × height); high-resolution images and supplying multiple aspect ratios (16x9, 4x3, 1x1) are recommended. The rich result is NOT suppressed below 1200x675, that figure is not a Google rule.
  Evidence required: image URL + dimensions (flag only when width × height < 50,000).
- **`aggregateRating` faked or scraped from a third-party site without attribution** (Google penalizes invented ratings).
  Evidence required: schema rating value + missing on-page review evidence.

### NOT a Problem

- Cooking blog post that's a personal essay about a meal, not a recipe, Recipe schema doesn't apply.
- `nutrition` field absent (recommended, not required).
- `video` field absent (recommended for video-heavy sites; not required).
- A recipe collection / index page using `ItemList` instead of `Recipe`, correct.

### Context Check

1. Is the page actually a recipe (ingredients + instructions + yield)? If not, Recipe schema is the wrong type.
2. Does the structured data match the visible recipe? The contract with the reader and the contract with Google must agree.
3. Are time fields in ISO 8601 duration? `PT30M` not `30 minutes`.
4. Does the hero image clear Google's 50,000-pixel minimum (width × height)? High-res and multiple aspect ratios (16x9, 4x3, 1x1) are recommended. There is no 1200x675 floor and the rich result is not suppressed below it.
5. If `aggregateRating` is present, is there a visible review surface on the page that justifies it?

### Reference

Google's Recipe documentation: https://developers.google.com/search/docs/appearance/structured-data/recipe

Schema.org Recipe: https://schema.org/Recipe

ISO 8601 duration: https://en.wikipedia.org/wiki/ISO_8601#Durations

**Severity tagging:**
- Recipe-shaped page with no Recipe schema → High.
- Required fields missing → High.
- Structured ingredients diverge from visible ingredients → Critical (lies to the reader, lies to Google).
- Time fields not ISO 8601 → Medium.
- `recipeYield` missing AND per-serving `nutrition` present → High; `recipeYield` missing with no nutrition → Low (Recommended only).
- `image` below Google's 50,000-pixel minimum → Medium; image present but under the (non-existent) "1200x675 floor" → not a finding (advisory: recommend high-res + multiple aspect ratios).
- Faked / unattributed `aggregateRating` → Critical (manual-action risk).

**Fix voice:** `julia-child` (primary) | `jen-simmons` (backup).

Read `souls/julia-child.json` before writing the Fix.

Worked fix example:

> A Recipe schema is the contract you make with the search engine, the same way the recipe is the contract you make with the cook. Both must be honest, complete, and kind.
>
> Start with the four required fields, `name`, `image`, `recipeIngredient`, `recipeInstructions`, and make every one of them match what your reader sees on the page. If your visible ingredient list has 12 entries, your structured `recipeIngredient` array has 12 entries. If you tell the cook the dish takes 45 minutes, your `totalTime` reads `PT45M`, not `"about 45 minutes"`.
>
> ```tsx
> const recipeSchema = {
>   '@context': 'https://schema.org',
>   '@type': 'Recipe',
>   name: recipe.title,
>   image: [recipe.heroImage],
>   author: { '@type': 'Person', name: recipe.author.name },
>   datePublished: recipe.publishedAt,
>   description: recipe.description,
>   prepTime: recipe.prepTime,    // 'PT15M'
>   cookTime: recipe.cookTime,    // 'PT30M'
>   totalTime: recipe.totalTime,  // 'PT45M'
>   recipeYield: recipe.yield,    // '4 servings'
>   recipeIngredient: recipe.ingredients.map(i => i.formatted),
>   recipeInstructions: recipe.steps.map((step, i) => ({
>     '@type': 'HowToStep',
>     position: i + 1,
>     text: step.text,
>     image: step.image,
>   })),
> };
> ```
>
> Then, the recipe itself: equipment list at the top, ingredients with quantities and prep notes ("butter, 4 tablespoons, cold and cubed"), numbered steps with verbs and visual cues, and a notes section for what to do if it goes wrong. Get the recipe right first; the schema follows from the recipe.
