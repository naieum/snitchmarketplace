## CATEGORY 08: Timing, moving content and flashes

Three criteria about content that moves on its own or runs out on its own. A checkout that logs you out after fifteen minutes with no warning throws away the form of anyone who reads slowly, types with a switch, or was interrupted. A carousel that advances every four seconds steals the sentence out from under someone still reading it. A strobing hero can trigger a seizure.

All three are Level A. Two of them (2.2.1, 2.2.2) leave clean static signals in configuration and component code. The third (2.3.1) cannot be measured from source at all and must be Skipped with a reason rather than guessed at.

**Boundary.** This category asks whether the timing or the motion meets its criterion. Whether an auto-advancing hero costs the visitor the message, or a session timeout drops them out of a funnel, is the sibling's judge — call the Skill tool with "snitch-ux". A `<meta http-equiv="refresh">` also carries an SEO and crawl half, judged against search rather than against 2.2.1: that belongs to the sibling's Cat 08 — call the Skill tool with "snitch-marketing". Cross-file the criterion here and the search signal there; never merge them into one claim.

### Pre-flight

Run wherever the surface has a session, an authenticated area, a timed form, a carousel, a ticker, an auto-updating feed, an autoplaying video or a looping animation. That is most marketing sites and nearly every application.

Skip with reason `not applicable` only when the surface has no time limit, no auto-updating region and no animation of any kind. Static text pages qualify.

Note the audit's own limit up front: flash and strobe rates cannot be computed from source, so 2.3.1 will be a Skip in every static-only pass unless an analyser or a human viewed the content.

### Rule table

One row per success criterion. A finding names its row. A timing or motion check with no row here is a Skip, never a finding under a borrowed SC.

| SC | Level | What must hold | Static signal (source / DOM) | Runtime-only? | Severity |
|---|---|---|---|---|---|
| 2.2.1 Timing Adjustable | A | For each content-set time limit, the user can turn it off, adjust it over at least ten times the default, or is warned before expiry and given at least 20 seconds and at least ten chances to extend | session or idle-timeout values in auth config, middleware and cookie `maxAge`; `setTimeout` that logs out, redirects or clears a form; countdown timers on carts, quizzes, checkouts and OTP screens, with no warning dialog and no extend control in the same component | No | High |
| 2.2.2 Pause, Stop, Hide | A | Moving, blinking or scrolling content that starts automatically, lasts more than five seconds and sits beside other content has a pause / stop / hide mechanism; auto-updating information has the same, or a frequency control | carousel or slider config with `autoplay`, `autoPlay`, `interval`, `delay`, `loop` and no pause control; `<marquee>`; CSS `animation` with `infinite`; animated GIF or `<video autoplay loop>` longer than five seconds; polling `setInterval` feeds, live tickers, notification counters; `<meta http-equiv="refresh">` | No | High |
| 2.3.1 Three Flashes or Below Threshold | A | Nothing flashes more than three times in any one-second period, or the flash is below the general flash and red flash thresholds | not computable from source. Quote any animation that toggles brightness, opacity or a saturated-red fill rapidly, or any video or GIF described as strobing, and route it to a runtime check | **Yes** | Critical if confirmed by measurement; otherwise Skip |

**The exceptions, as the criteria state them.** 2.2.1 does not apply when the time limit is a required part of a real-time event such as an auction or a live score feed and no alternative is possible; when the limit is essential and extending it would invalidate the activity; or when the limit is longer than 20 hours. 2.2.2 does not apply when the movement or the auto-updating is part of an activity where it is essential.

**`prefers-reduced-motion` is an advisory, never an A or AA failure.** Honouring the user's reduced-motion preference is strongly recommended and cheap. The criterion behind it, 2.3.3 Animation from Interactions, is **Level AAA** and outside this audit's AA bar. Report a missing `prefers-reduced-motion` block as `reduced motion (advisory)` with the animation rule quoted, and never attach 2.2.2 or 2.3.1 to it. Parallax, scroll-jacking and large transition animations get the same treatment.

### Evidence required

A finding needs an observation and a criterion. The observation is a quoted declaration or handler at `file:line` (source mode), or URL plus selector with the rendered HTML (crawl mode), or a runner rule id with its node.

**Source mode, cheapest first:**

1. `Grep` the auth and server config for timeout values: `sessionTimeout`, `idleTimeout`, `maxAge`, `expiresIn`, `SESSION_LIFETIME`, `session.cookie`, `jwt` expiry, `absoluteDuration`. Record the value and whether any warning component references it (2.2.1).
2. `Grep` for `setTimeout` and `setInterval` whose callback signs out, redirects, refreshes or resets a form. `Read` the surrounding component for a warning and an extend control (2.2.1).
3. `Grep` carousel, slider and ticker configuration: `autoplay`, `autoPlay`, `interval:`, `delay:`, `loop:`, `swiper`, `slick`, `embla`, `keen`. `Read` each for a pause, stop or hide control the user can reach (2.2.2).
4. `Grep` CSS for `animation` with `infinite`, and for `<marquee>`. Record the duration and whether the animated block sits beside other content (2.2.2).
5. `Grep` markup for `<video` with `autoplay`, `<img` sourcing a `.gif`, and `<meta http-equiv="refresh"`. Record the duration or interval (2.2.2).
6. `Grep` for polling and live regions that update on a timer: `useInterval`, `refetchInterval`, `EventSource`, `socket.on`, and record whether the user can pause or throttle the stream (2.2.2).
7. Record every animation that toggles brightness, opacity or a saturated-red fill faster than roughly three cycles per second, and route it to the runtime list. Do not compute a flash rate from a CSS duration (2.3.1).

**Crawl mode:**

1. `Fetch` each page in the test scope. Quote the carousel, ticker or player markup and its selector.
2. Quote any `<meta http-equiv="refresh">` from the served head with its interval.
3. Session limits are usually invisible to a fetch. Say so, and Skip 2.2.1 with that reason unless the timeout is stated in the page or in a served config.

**Cascade caveat, applies to every CSS-derived check.** A fetch or a source read returns declarations, not the resolved cascade. An `animation` may be overridden, paused by a parent, or already wrapped in a reduced-motion query further down the sheet. Quote the declaration, say the resolved behaviour was not observed, and mark Confidence Medium.

**Runtime checks (need a human or a runner; the bundle ships neither):**

1. Sit on an authenticated page past the configured timeout and record whether a warning appears and whether extending works.
2. Watch each auto-advancing region for more than five seconds and try to pause it with the keyboard and with a pointer.
3. Run the content through a photosensitive-flash analyser, or have a person view it, to settle 2.3.1.
4. Confirm that an auto-updating region does not also move focus or reset the reading position.

If none is available: `Skip — flash-rate measurement requires a human or runner; not run`, `Skip — session-timeout behaviour requires a human or runner; not run`, and report only the static findings. Never assert a flash rate nobody measured.

### Forbidden claims

- "The carousel probably fails WCAG." Quote the autoplay configuration and the absent pause control, or Skip.
- "This animation may trigger seizures." Nothing in a static pass can establish that. Quote the animation, state that the flash rate was not measured, and Skip 2.3.1 with the analyser or human review named as the unblock.
- "Session timeouts are too short." Quote the configured value and the missing warning. The criterion is about warning and extension, not about the length of the limit.
- "Users cannot pause the ticker." Quote the component and the absence of a control, or say the control was not found in the source you read.
- "Missing `prefers-reduced-motion` fails 2.3.1." It does not. It is advisory, and the related criterion (2.3.3) is Level AAA.
- Never write "compliant", "conformant" or "non-compliant" as a verdict. Write "fails SC 2.2.2 at these elements" and let the reader draw the line.

### Detection

Source or rendered-DOM audit of session and timeout configuration, carousel and ticker components, CSS animation rules, media elements and polling code across the representative page set, plus runner or human confirmation for anything that moves.

### What to Search For

- Session, idle and cookie lifetimes in auth config, middleware, and any framework session helper
- `setTimeout` / `setInterval` callbacks that sign out, redirect, refresh or clear state
- Countdown timers on carts, checkouts, quizzes, booking holds and one-time-code screens
- Carousel, slider and ticker options: `autoplay`, `interval`, `delay`, `loop`, and whether a pause control renders
- `<marquee>`, CSS `animation: … infinite`, long looping GIFs, `<video autoplay loop>`
- `<meta http-equiv="refresh">` with any interval
- Polling and streaming updates: `refetchInterval`, `EventSource`, socket subscriptions, live counters and notification badges
- Animations that toggle brightness, opacity or saturated red rapidly (route to runtime, do not judge statically)
- `@media (prefers-reduced-motion: reduce)` blocks, and their absence (advisory only)

### Actually Fails

- **Session or idle timeout with no warning and no extend path** (2.2.1). Evidence: the configured value plus the absence of any component that warns before it fires. A checkout or a long form makes this High.
- **Countdown that expires and discards work, with no way to turn it off or extend** (2.2.1). Evidence: the timer component and the effect on expiry.
- **Auto-advancing carousel, ticker or slideshow beside other content with no pause, stop or hide control** (2.2.2). Evidence: the autoplay configuration and the component's full control surface.
- **`<marquee>` or an infinite CSS animation on content that runs longer than five seconds beside other content, with no control** (2.2.2). Evidence: the element or the CSS rule with its duration.
- **Autoplaying looping video or a long animated GIF with no pause control** (2.2.2). Evidence: the media element and its attributes.
- **Auto-updating feed, counter or live region with no pause and no frequency control** (2.2.2). Evidence: the polling interval and the component.
- **`<meta http-equiv="refresh">` that reloads the page on a timer** (2.2.2). Evidence: the tag with its interval. Cross-file the search half rather than restating it.
- **Flashing content confirmed above the threshold by an analyser or a human** (2.3.1). Evidence: the measurement or the observer's report, never a source inference.

### NOT a Failure

- A time limit longer than 20 hours. The criterion's own exception covers it.
- A real-time limit with no possible alternative: an auction close, a live scoreboard, a broadcast countdown.
- A carousel that pauses on hover **and** on focus **and** offers a visible pause control, or one that only advances when the user asks.
- Motion that runs for five seconds or less and then stops.
- An animation already wrapped in `@media (prefers-reduced-motion: reduce)` with a no-motion branch.
- An auto-updating region the user opted into and can stop, or one that updates a value without moving anything beside it.
- A session limit that warns, gives at least 20 seconds to respond with a simple action, and allows at least ten extensions. That is the criterion met, not a workaround.
- A missing `prefers-reduced-motion` block on its own. Advisory, and the related criterion is Level AAA.
- Loading spinners and progress indicators tied to a real in-flight operation.

### Context Check

1. Is the time limit set by the content, or by something outside it (a bank's own session, an operating-system lock)? Only content-set limits are in scope.
2. Does a warning component exist somewhere but never mount on the audited route? Read the route, not just the component.
3. Is the moving content presented in parallel with other content, or is it the whole page? The criterion's wording turns on that.
4. Does the carousel actually autoplay in production, or is autoplay disabled by a feature flag or a config override?
5. Was the flash rate measured, or inferred? If inferred, it is a Skip.
6. Does the fix touch a session-security setting? Shortening or lengthening a session has a security consequence — surface the change and get explicit confirmation before applying it.
7. Is the question whether the motion costs the visitor the message rather than whether it meets the criterion? Hand that half over — call the Skill tool with "snitch-ux".

### Severity

- **Critical** — flashing content measured above the general flash or red flash threshold (2.3.1). Only ever assigned on a measurement, never on a static read.
- **High** — session or countdown limit that discards work with no warning and no extension (2.2.1); auto-advancing content or an auto-updating region with no pause, stop or hide control (2.2.2).
- **Medium** — a `<meta http-equiv="refresh">` reload; an infinite decorative animation beside content with no control; a timer that warns but gives less than 20 seconds or fewer than ten extensions.
- **Low** — missing `prefers-reduced-motion` handling, reported as `reduced motion (advisory)` and never as a criterion failure.

### Fix guidance

Three fixes. Two are configuration, one is a control the component never rendered.

**1. Warn before the session ends, and let the user stay** (2.2.1). The limit can keep its length. What it cannot do is arrive silently.

```tsx
// Fails 2.2.1: the redirect fires with no warning and no way to extend
useEffect(() => {
  const t = setTimeout(() => router.push("/logout"), IDLE_MS);
  return () => clearTimeout(t);
}, []);

// Passes: warn early, give a simple action, allow repeated extensions
useEffect(() => {
  const warn = setTimeout(() => setShowWarning(true), IDLE_MS - 60_000);
  const end  = setTimeout(() => router.push("/logout"), IDLE_MS);
  return () => { clearTimeout(warn); clearTimeout(end); };
}, [extensionCount]);

// The dialog: at least 20 seconds to respond, at least ten extensions allowed
<div role="alertdialog" aria-labelledby="idle-title">
  <h2 id="idle-title">Still there?</h2>
  <p>You will be signed out in 60 seconds.</p>
  <button onClick={extendSession}>Keep me signed in</button>
</div>
```

**2. Give moving content an off switch** (2.2.2). One button, reachable by keyboard, that stops the movement and stays stopped.

```tsx
// Fails 2.2.2: advances every four seconds, no control
<Carousel autoplay interval={4000} loop />

// Passes: the same carousel, plus a control that pauses it for good
<Carousel autoplay={!paused} interval={4000} loop />
<button onClick={() => setPaused(p => !p)} aria-pressed={paused}>
  {paused ? "Play slideshow" : "Pause slideshow"}
</button>
```

The same shape works for a live feed: a pause toggle, or a frequency control, next to the region it governs.

**3. Respect the reduced-motion preference** (advisory). This is not the AA bar. It is one media query and it makes the product usable for people whose vestibular systems the animation was fighting.

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

Flash rate stays open until somebody measures it. Run the content through a photosensitive-flash analyser or have a person watch it, then close 2.3.1 with the result rather than with an assumption.

### Reference

WCAG 2.2 specification: https://www.w3.org/TR/WCAG22/

2.2.1 Timing Adjustable: https://www.w3.org/WAI/WCAG22/Understanding/timing-adjustable.html · 2.2.2 Pause, Stop, Hide: https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide.html · 2.3.1 Three Flashes or Below Threshold: https://www.w3.org/WAI/WCAG22/Understanding/three-flashes-or-below-threshold.html

2.3.3 Animation from Interactions (Level AAA — the criterion behind the reduced-motion advisory): https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html

General flash and red flash thresholds, defined: https://www.w3.org/TR/WCAG22/#dfn-general-flash-and-red-flash-thresholds

`prefers-reduced-motion`: https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion · `<meta http-equiv="refresh">`: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/meta

axe-core rule descriptions, for the runner rule ids quoted alongside an element: https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md
