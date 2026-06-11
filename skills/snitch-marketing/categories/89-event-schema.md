## CATEGORY 89: Event schema

Event schema powers Google's Events SERP feature (the dedicated event card with date, location, ticket link). It applies to concerts, conferences, webinars, workshops, virtual events, recurring meetups. Required fields done correctly: `name`, `startDate`, `location` (with `Place` for in-person OR `VirtualLocation` for online). Get them right and your event appears in the Events search panel; get them wrong and Google ignores the page.

### Pre-flight: relevance check

Skip this category with reason `not applicable` unless the site publishes at least one page representing a specific event with a specific date and location (or virtual location). An "events" landing page that lists past events without specifics is not a schema candidate; flag it under content strategy instead.

### Evidence required (do not skip)

**Source mode, required tool calls:**

1. Identify event-type pages by URL pattern (`/events/`, `/event/`, `/conference/`, `/webinar/`) AND content shape (specific date + location/url + register CTA).
2. `Grep` for `"@type": "Event"` (or subtypes: `BusinessEvent`, `EducationEvent`, `MusicEvent`, `SocialEvent`, `SportsEvent`, `TheaterEvent`, `VisualArtsEvent`).
3. For each Event schema: parse the JSON. Check required: `name`, `startDate`. Strongly recommended: `endDate`, `location` (Place OR VirtualLocation), `eventAttendanceMode`, `eventStatus`, `organizer`, `offers`, `description`, `image`.
4. Check `eventStatus` for current state: `EventScheduled`, `EventRescheduled`, `EventPostponed`, `EventCancelled`, `EventMovedOnline`. Stale `EventScheduled` on a past event is a finding.

**Crawl mode, required tool calls:**

1. `Fetch` the URL. Find JSON-LD blocks. Parse.
2. Quote the entire `Event` object.
3. Check required + recommended fields. Quote any missing.

### Forbidden claims

- "Event schema is probably missing." Confirm the page IS an event page AND parse.
- "The date may be wrong." Quote both the schema date and the visible date.

### Detection

Looking for `"@type": "Event"` blocks (or subtypes) on pages publishing specific events.

### What to Search For

- `"@type": "Event"` or subtype
- Required: `name`, `startDate` (ISO 8601 with timezone)
- Strongly recommended: `endDate`, `location` (Place with `address` for in-person; VirtualLocation with `url` for online; both for hybrid), `eventAttendanceMode` (`OfflineEventAttendanceMode` / `OnlineEventAttendanceMode` / `MixedEventAttendanceMode`), `eventStatus`, `organizer`, `offers`, `description`, `image`
- For ticketed events: `offers` with `price`, `priceCurrency`, `availability`, `validFrom`, `url`
- Recurring events: separate Event entries per occurrence, OR a single Event with a `subEvent` array

### Actually Hurts the Marketing Surface

- **Event-type page with no Event schema**.
  Evidence required: URL + visible event date + missing JSON-LD.
- **`startDate` missing or not ISO 8601 with timezone** (Google requires both).
  Evidence required: parsed `startDate` value.
- **`location` missing** (in-person events without Place; online events without VirtualLocation).
  Evidence required: parsed schema + visible location on page.
- **`eventAttendanceMode` missing** (Google ranks this prominently for the SERP card).
  Evidence required: parsed schema.
- **`eventStatus` stale on a postponed/cancelled event** (page still says `EventScheduled` after the event was moved or cancelled).
  Evidence required: visible cancellation notice + stale schema status.
- **Past event still marked `EventScheduled`** (page should be removed, redirected, or marked with archived status).
  Evidence required: `startDate` in past + status still scheduled.
- **`offers.url` missing or broken** (the SERP card's "Get tickets" link goes nowhere).
  Evidence required: parsed `offers.url` + fetch result.
- **Recurring event modeled as a single Event with a vague `startDate`** (every occurrence merges; users never see the right one).
  Evidence required: page lists multiple occurrences + single Event schema.

### NOT a Problem

- Past event archive page (no longer accepting registration) without Event schema, acceptable.
- An events index / calendar page using `ItemList` of `Event` references, correct.
- Multiple Event schemas on a page that lists multiple distinct events, correct.

### Context Check

1. Is the page a specific event (date + location/url) or a category index?
2. Does `startDate` include timezone? `2026-06-15T18:00:00-07:00` is correct; `2026-06-15` is incomplete for the SERP card.
3. Is `eventAttendanceMode` set correctly (in-person vs online vs hybrid)?
4. Is the event in the past, present, or future? Past events with future-dated schema are common bugs.
5. For online events, does `VirtualLocation.url` resolve to a real meeting link?

### Reference

Google's Event documentation: https://developers.google.com/search/docs/appearance/structured-data/event

Schema.org Event: https://schema.org/Event

eventAttendanceMode values: https://schema.org/EventAttendanceMode

**Severity tagging:**
- Event-type page with no Event schema → High.
- `startDate` missing or non-ISO-8601 → Critical.
- `location` missing → High.
- `eventAttendanceMode` missing → Medium.
- Stale `eventStatus` after cancellation/postponement → High (lies to attendees).
- Past event still `EventScheduled` → Medium.
- `offers.url` broken → High.

**Fix voice:** `solutions-architect` (primary) | `mike-monteiro` (backup).

Read `souls/solutions-architect.json` before writing the Fix.

Worked fix example:

> Event schema is a promise about a specific moment in time at a specific place. The required fields are the contract: `name`, `startDate` (with timezone), `location` (Place or VirtualLocation), `eventAttendanceMode`, `eventStatus`. Each one is a fact the user expects to be true.
>
> ```tsx
> const eventSchema = {
>   '@context': 'https://schema.org',
>   '@type': 'Event',
>   name: event.title,
>   startDate: event.startISO,        // '2026-06-15T18:00:00-07:00'
>   endDate: event.endISO,
>   eventAttendanceMode:
>     event.mode === 'online'
>       ? 'https://schema.org/OnlineEventAttendanceMode'
>       : event.mode === 'hybrid'
>       ? 'https://schema.org/MixedEventAttendanceMode'
>       : 'https://schema.org/OfflineEventAttendanceMode',
>   eventStatus: event.status,        // 'EventScheduled' | 'EventCancelled' | etc.
>   location: event.mode === 'online'
>     ? { '@type': 'VirtualLocation', url: event.streamUrl }
>     : { '@type': 'Place', name: event.venue, address: event.address },
>   organizer: { '@type': 'Organization', name: 'Snitch', url: 'https://snitchplugin.com' },
>   offers: {
>     '@type': 'Offer',
>     url: event.registrationUrl,
>     price: event.price,
>     priceCurrency: 'USD',
>     availability: 'https://schema.org/InStock',
>     validFrom: event.salesOpenISO,
>   },
>   description: event.summary,
>   image: [event.heroImage],
> };
> ```
>
> Wire `eventStatus` to a real source of truth (a CMS field, an env flag, a feature switch). When the event moves online or cancels, the schema should change automatically, not require a manual edit. The cost of a stale `EventScheduled` after cancellation is broken trust with anyone who shows up.
