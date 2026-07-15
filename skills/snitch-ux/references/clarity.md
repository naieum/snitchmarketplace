# Clarity & Comprehension

Where the rest of this skill is about
**persuasion** (making people *want* to act), this file is about **clarity** — making the
interface so obvious that acting takes no thought. Persuasion is wasted on a page nobody
can parse. Do this part first.

The one-line premise: **"Don't make me think."** Every question mark you leave in the
user's head — *Is that a link? What does this label mean? Where am I? Can I click that?* —
spends a little of their attention and a little of their patience. Your job is to remove
the question marks.

---

## Contents
- The three laws
- How people actually use interfaces
- Billboard Design 101 — five moves for a scannable page
- Navigation & the home page
- The reservoir of goodwill — do right by the user
- Accessibility — the low-hanging fruit

## The three laws

**First Law — Don't make me think.** A page should be **self-evident**: an average user
"gets it" — what it is and how to use it — without effort. If the thing is genuinely
novel or complex and can't be self-evident, settle for **self-explanatory** (a little
thought, but only a little). The tie-breaker for any design decision: does this add a
question mark, or remove one?

**Second Law — Mindless choices beat few choices.** The number of clicks barely matters as
long as each one is a mindless, unambiguous choice. The "3-click rule" is a myth; what tires
people is *ambiguous* clicks, not clicks. Rule of thumb: **three mindless clicks cost less
than one that makes you stop and think.** So don't collapse a clear 4-step path into a clever
2-step one that forces a hard decision. Keep the **scent of information** strong — each step
should visibly confirm "yes, you're heading the right way."

**Third Law — Omit needless words.** Cut the words on the page in half, then cut what's left
in half again. (Detailed in `copywriting.md`.) Fewer words → less noise, the useful content
stands out, the page looks less daunting.

---

## How people actually use interfaces

Design for the real user, not the imagined one. Three facts of life:

- **They scan, they don't read.** Users glance for words that match their task or their
  interests (and trigger words: *free, you, new, [their name]*). They act like they're
  reading "a billboard going by at 60 mph." → *If your users act like you're designing
  billboards, design great billboards.*
- **They satisfice — they pick the first reasonable option**, not the best one.
  Optimizing is hard; guessing is fast and the penalty for a wrong guess is usually one
  Back click. So the **first plausible** link/label/button wins the click — make sure the
  first plausible one is the right one, and label it for what people are looking for.
- **They muddle through.** People use things without understanding how they work, and
  stick with whatever they found that works — they rarely look for the better way. Don't
  assume anyone read the instructions or built a mental model. Nobody reads the manual.

**The Back button is the lifeboat.** It's one of the most-used controls there is. Never
break it, trap the user, or open things that strand them somewhere Back can't return from.

---

## Billboard Design 101 — five moves for a scannable page

1. **Clear visual hierarchy.** Three cues, working together: **prominence** (more important
   = bigger, bolder, more contrast, more whitespace, higher on the page); **grouping**
   (things related in meaning look related — shared style, a bounded area); **nesting**
   (a heading visually contains what it labels). A good hierarchy pre-processes the page
   for the user. (This reinforces the "Direct attention" principles elsewhere in the skill.)
2. **Use conventions.** A convention is a solved problem — the hamburger, the cart icon, a
   logo top-left that links home, blue underlined links. Conventions only *become*
   conventions because they work; the reader needs no explanation. Break one only when your
   replacement is either (a) so clear it's self-evidently as good, or (b) adds enough value
   to be worth a small learning curve. **Innovate when you truly have a better idea and
   everyone says "wow"; otherwise, use the convention.** Novelty for its own sake is a tax
   on the user.
3. **Break the page into clearly defined areas.** A user should be able to glance and know
   at once which region is navigation, which is the main content, which is the promo/ads.
   People decide what to look at in a fraction of a second and ignore the rest entirely.
4. **Make it obvious what's clickable.** Users should never spend a millisecond wondering
   whether something is a link/button. Buttons must look like buttons; links must look like
   links. Ambiguous affordances (styled text that may or may not click, an icon with no cue)
   burn the user's limited goodwill.
5. **Minimize noise.** Two kinds: **busy-ness** (everything shouting at once) and
   **background noise** (a thousand tiny bits of visual clutter that wear you down).
   Default stance: **treat every element as visual noise until it earns its place.**

---

## Navigation & the home page

The web has no physical sense of scale, direction, or location — navigation is what supplies
"there's a *there* here," and done well it *is* all the instructions the user needs.
Site-level navigation (persistent nav, page names, "you are here," breadcrumbs, tabs),
**the parachute test**, and the home page's job of conveying the big picture live in their own
file: **`site-navigation.md`**. (For the mobile bottom-tab bar, see `mobile-navigation.md`.)

The one-line version for the clarity pass: on any deep page, a user should instantly know
*what site this is, what page they're on, what the sections are, and where they are* — run
the **parachute test** to check.

---

## The reservoir of goodwill — do right by the user

Every visitor arrives with a **reservoir of goodwill.** Each friction, each broken promise,
each "why are they making me do this" lowers the level; a single bad move (a huge required
form, a hidden fee revealed late) can empty it in one shot. You can also *refill* it. The
second half of usability, past "is it clear?", is **"does this treat the user well?"** — is
the design considerate, honest, and on the user's side?

**Depletes goodwill:** hiding what people came for (prices, shipping cost, support phone
number); punishing sloppy input you could just parse (credit-card spaces, phone dashes);
asking for information you don't need; fake sincerity ("your call is important to us");
sizzle that delays people in a hurry (splash screens, forced intros); an amateurish look.

**Refills goodwill:** make the top tasks obvious and dead-easy; tell people what they want
to know up front (shipping, fees, outages) — candor buys forgiveness; save them steps
(a tracking link in the receipt); answer the real questions (a true FAQ, not
"questions-we-wish-you'd-ask"); provide creature comforts (printer-friendly pages, easy
error recovery); **and when in doubt, apologize** — at least let people know you know
you're inconveniencing them.

This is the honest core of the skill's Guardrails: the persuasion techniques win the tap;
goodwill decides whether the user comes back. Don't spend the reservoir to close one
conversion.

---

## Accessibility — the low-hanging fruit

You can't honestly call an interface usable if a whole class of people can't use it —
accessibility is part of usability, not a separate checklist. And the single most effective
accessibility improvement is the same thing that helps everyone: **make it clearer, and test
it.** People using screen readers "scan with their ears" — they jump by
the first few words of a link or line — so front-load the meaningful words. Concrete wins:

- **Alt text on every image** (empty `alt=""` for purely decorative ones).
- **Associate form fields with their labels** (`<label for>`), so screen readers announce them.
- **A "Skip to main content" link** at the top of the page.
- **Everything usable by keyboard**, not just mouse.
- **Let text resize** without breaking layout; check a large-type pass.
- **Sufficient contrast; never encode meaning in color alone.**
- **Source order = reading order** — the DOM sequence should match how you'd read it aloud.
