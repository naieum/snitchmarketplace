# Validate, Don't Debate — Usability Testing on the Cheap

Everything else in this skill is a strong
prior — a bet about how people behave. The way you find out whether *this* screen actually
works for *these* users is to watch someone use it. Testing is the tie-breaker that ends
arguments and the only thing that reliably surfaces the problems you've stopped noticing.

## Why bother — the myth of the average user

Web teams burn huge time on **religious debates**: "Do users like dropdowns?" "Is a
carousel good?" These are unwinnable because everyone assumes *users are like me* — and
there is **no average user**. The question isn't "do people like X in general," it's
"does *this* X, with *these* labels, in *this* context, work for the people likely to use
*this* screen?" — and the only way to answer that is to build a rough version and watch.
Testing moves the team from *right vs. wrong* (opinion) to *works vs. doesn't* (observation),
and it's very hard to keep believing "everyone thinks like me" after you've watched three
people not.

## The method — testing on 10 cents a day

- **Three users, not eight.** The first three users hit almost all the significant
  problems. More rounds beat more users per round — test 3, fix, test 3 again. (Round two's
  users get *past* the bugs you just fixed and surface the next layer.)
- **One morning a month.** Make it small and routine, not a big event: 3–4 users in a
  morning, debrief over lunch the same day. No lab, no one-way mirror, no "big honking
  report." A room, a computer, two chairs, and a screen recorder is enough.
- **Recruit loosely and grade on a curve.** It matters far less *who* you test than that
  you test. "We're all beginners under the skin" — scratch an expert and you'll find
  someone muddling through at a higher level, and experts are never insulted by clarity.
  (Exceptions: if the whole audience is one narrow group, or the task needs real domain
  knowledge, recruit for that at least once.)
- **Start now, start early.** A crude test early beats a polished test late — it's cheap to
  change a sketch, expensive to change a shipped site. You can even test *competitors'*
  sites before you've built anything ("a free working prototype").

## Two things to test

- **"Get it" testing.** Show the page and ask what it is, what you'd do here, what you'd
  click first. Reveals whether the big picture / value proposition / labels land. (See the
  home-page and parachute-test material in `navigation.md`.)
- **Key-task testing.** Give a realistic task and watch them do it — let them finish, get
  stuck, or stop teaching you anything new. Let the user pick a task they actually care
  about ("find a book *you'd* buy") over a contrived one.

**How to facilitate:** "We're testing the site, not you — you can't do anything wrong."
Ask them to **think out loud.** Then mostly shut up and watch; don't rescue them, don't
lead. Their tone of voice tells you where the friction is.

## Turning observations into fixes — triage

You'll always find more problems than you can fix, so triage instead of trying to fix
everything:

- **Fix the serious, common ones first.** They're hard to miss — the same wall, hit by
  most users.
- **Grab head-slappers and cheap hits.** Obvious problem + obvious fix, or near-zero effort
  for high visibility — "found money."
- **Ignore "kayak" problems** — a user wobbles off course but rights themselves and gets
  back on track in a second. No harm, no foul; usually an unresolvable ambiguity.
- **Resist adding things.** The fix is often to *remove* what's obscuring the meaning, not
  to add another label/button/explanation.
- **Discount feature requests.** "I wish it had X" usually just tells you what they like,
  not what the design needs.
- **Discount "I like it" — attractive designs test better than they work.** People rate a
  polished screen as *more usable* than a plain one with identical behavior, and forgive
  its failures longer — so a beautiful prototype's glowing session can hide the same wall
  an ugly one would have exposed. Weigh what they *did* (completed, stalled, backtracked,
  how long) over what they *said*, and when a polished screen tests suspiciously clean,
  re-watch the recording for wrong turns the participant talked past. The same bias runs
  in the reviewer: a screen that looks professionally made gets its flows read less
  skeptically — which is exactly backwards.
- **Don't break what works.** When you make one thing more prominent, something else gets
  de-emphasized — check you didn't trade one problem for another.

## Measure honestly — did it actually work?

**The honest-measurement question lives here, not in the ethics gate:** if you'll judge this
surface by a metric, does that metric only improve when the *user* is better off — not a vanity
number a dark pattern could lift while goodwill drains? It is a real question and worth raising
with the team, but it asks about the team's metric choice rather than about anything on the
surface, so it cannot be evidenced the way a gate check must be (`ethics-gate.md`). Raise it as
a recommendation, never as a gate failure.

Watching people tells you *why* something fails; numbers tell you *whether* a change helped.
But a number can lie, and the techniques in this skill are very good at moving numbers in
ways that quietly cost you. Keep measurement honest:

- **A metric moving up is not proof of a better experience.** Urgency, dark defaults, and
  buried exits can lift a click-through while draining the reservoir of goodwill. The tap you
  won and the trust you lost show up in different reports, at different times.
- **Watch the second-order number, not just the first.** Signups vs. *retained, activated*
  users; add-to-cart vs. *kept, not-refunded* orders; time-on-app vs. *did they get what they
  came for*. A win on the near metric with a loss on the far one is a loss.
- **Beware the vanity metric.** If a number can go up while users are worse off, it's the
  wrong number to optimize. Pick the metric that only improves when the user genuinely got
  more value.
- **Short-term lift, long-term drag.** Manipulative wins tend to decay: complaints, churn,
  refunds, uninstalls, and support load rise later. Give a change time before you call it a
  win, and look at the costs, not only the conversions.
- **One change at a time, or you learn nothing.** If you ship five moves at once, you can't
  tell which helped, which hurt, or which cancelled out.
- **Qualitative + quantitative together.** The number says *something changed*; watching
  three people says *what and why*. Neither alone is enough to act with confidence.

The through-test matches the skill's guardrail: **would this still look like a win if you
measured the user's outcome instead of yours?**

## When to reach for this

Any time a design decision has turned into an argument, or you're about to ship something
novel/risky, or you catch yourself asserting what "users will" do — that's the cue to stop
debating and go watch three people. In an agent/PR context the practical version is:
build the rough thing, run the **parachute test** and the review checklist on it yourself,
and frame recommendations as "here's what to put in front of 3 users to confirm," not
"this is definitely right."
