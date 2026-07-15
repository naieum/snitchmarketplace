# Site Navigation & the Home Page

This is **site-level** navigation — the
information architecture that tells users where they are and how to move around: persistent
nav, page names, breadcrumbs, tabs, "you are here," and the home page's job of conveying the
big picture. For the **mobile bottom-tab bar** (tab count, sizes, active-state cues, thumb
zone), see `mobile-navigation.md` — that file governs the component; this one governs the
site's structure.

## Contents
- "The site is the navigation"
- Persistent (global) navigation
- Page names — the street signs of the web
- "You are here" indicators
- Breadcrumbs
- Tabs
- The parachute test — the acid test for navigation
- The home page — convey the big picture

## "The site *is* the navigation"

On the web there's no physical sense of scale, direction, or location — you teleport around
by clicking links, and your feet never touch the ground. Navigation is what supplies
"there's a *there* here." Done well, it *is* all the instructions the user needs. Its jobs:
find things, tell me where I am, tell me what's here, and quietly build confidence that the
people who made this knew what they were doing.

**The Back button is the lifeboat** — one of the most-used controls on the web. Never break
it, trap the user in a flow it can't escape, or open things it can't return from.

## Persistent (global) navigation

The elements present and consistent on (almost) every page. Consistency is the point: it
says, calmly, "the navigation is over here, it will always be here, and it will always work
the same way." Two reasonable exceptions to "every page": the **home page** (different job,
below) and **forms/checkout** (strip nav down so it doesn't distract mid-task). It should
carry:

- **Site ID / logo** — top-left, links home. The "you're in this building" marker;
  the highest thing in the page's logical hierarchy.
- **Sections** — the primary top-level areas (primary nav); also show the current section's
  sub-nav (secondary nav).
- **Utilities** — links that aren't part of the content hierarchy: Help, Account, Cart,
  Search, Contact, Sign in. Keep to ~4–5.
- **A way home** — a reset / "get out of jail free" for the lost. The logo usually doubles
  as this.
- **A way to search** — just a box, a button, and the word "Search." No cute label ("Quick
  Find"), no instructions inside the box, no scope dropdown crammed in. Offer scope on the
  *results* page if it's useful there.

**Don't neglect the lower levels.** The most common navigation failure on big sites is
giving deep pages less design attention than the top — but users spend just as much time
down there. Design the nav for *every* level before arguing about the home page's colors.

## Page names — the street signs of the web

Big, well-placed street signs let a driver devote attention elsewhere; page names do the
same. Four rules:

1. **Every page needs a name.**
2. **Put it where it frames** the page's unique content.
3. **Make it prominent** — usually the largest text on the page.
4. **Make it match the words the user clicked to get there.** A "Gifts for Him" link should
   not land on a page titled "Menswear"; the mismatch makes people wonder if they went
   wrong. This is an implicit contract — honor it.

## "You are here" indicators

Highlight the current location in the nav (bold + color + reversed button, etc.). The most
common failure is being **too subtle** — use *two* visual cues, not one. Rule of thumb: if
as a designer you think the cue is sticking out like a sore thumb, it's probably about
right; consider making it twice as prominent.

## Breadcrumbs

"Home > Section > Page" — turn-by-turn directions showing the path from home to here (as
opposed to "you are here," which shows your place in the whole map). Best-practice: put them
at the top, tiny type, `>` between levels, boldface the last (current) item, and label them
literally with the words "You are here" if space allows. They're an **accessory** for deep
hierarchies — not a navigation scheme on their own, and never a substitute for a page name.

## Tabs

One of the few UI metaphors that genuinely works: tabs are self-evident, hard to miss, and
physically suggest a stack of spaces. But only if drawn right:

- The **active tab visually connects to** the space below it and "pops" in front of the
  others (an inactive-looking active tab defeats the whole metaphor).
- **Color-code** sections if you like, but **never rely on color alone** — roughly 1 in 12
  men are color-blind, and many users never consciously register color coding. Pair it with
  position/contrast.
- Have a tab **selected when the user first arrives.**

## The parachute test — the acid test for navigation

Imagine you parachute in and land on a random deep page of the site, with no memory of how
you got there. From that page alone you should be able to answer, without hesitation:

1. **What site is this?** (Site ID)
2. **What page am I on?** (Page name)
3. **What are the major sections?** (primary nav)
4. **What are my options here?** (local nav)
5. **Where am I in the scheme of things?** ("you are here")
6. **How do I search?**

To run it: pull up (or print) any page *other than* the home page, squint or hold it at
arm's length so it blurs, and see whether those six answers still pop off the page. If they
don't, the navigation isn't done — no matter how nice the home page looks.

## The home page — convey the big picture

The home page is fought over by every stakeholder ("waterfront property"), and the first
casualty is almost always the **big picture**. A first-time visitor must answer, at a
glance: **What is this? What can I do here? What do they have? Why here and not somewhere
else? Where do I start?** Two dedicated spots do this work:

- **Tagline** — next to the Site ID, ~6–8 words, states the *value proposition* and the
  differentiator. A tagline is not a motto ("we bring good things to life" is a motto — a
  guiding principle, not a description of what the site does for me). The best tagline is
  the brand's **controlling idea** — the one specific thing it's known for; to derive it,
  see `brand-messaging.md`.
- **Welcome blurb** — a terse, above-the-fold description of the site. Use as much space as
  needed to explain a novel offering, but no more. Never paste a mission statement here;
  nobody reads them.

**Make the entry points look like entry points** and label them ("Search," "Browse by
category," "Start here") so the answer to "where do I start?" is obvious.

**Home-page nav can differ — but not too much.** More room for identity, section
descriptions, a different orientation are all fine; but keep section **names, order, and
wording identical** to the rest of the site, or users have to relearn the navigation the
moment they leave the home page.

Beware the **tragedy of the commons**: prominent home-page slots work so well that every
team wants one, and the page slowly fills with "just one more thing" until it says nothing.
Guard the big picture; it's the one thing nobody inside the org will notice is missing.
