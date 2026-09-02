# Before / after: what the rewrite actually does

Real model outputs from the 2026 experiment behind this skill: same prompt, baseline
system prompt versus this writing system. Scores are heuristic anti-slop violations per
100 words from `scripts/ste-lint.py` (lower is cleaner).

## README intro (flavored mode)

**Baseline** (191 words, 4.19/100w, 4 em dashes):

> Traditional caches miss constantly in LLM workloads because users rarely phrase the
> same question identically — fluxcache solves this by embedding incoming prompts and
> matching them against previously cached queries within a configurable similarity
> threshold. [...] It ships with sensible defaults so you can get semantic caching
> running in a few lines of code, while exposing the knobs — similarity thresholds, TTLs,
> namespacing, custom scoring — that real applications need as they scale. Whether you're
> building a chatbot, a RAG pipeline, or an agentic workflow, fluxcache is designed to
> slot into your existing stack with minimal friction and no vendor lock-in.

What lights up: the em dashes, "sensible defaults", "slot into your existing stack with
minimal friction and no vendor lock-in", the 30+-word opening sentence, the contraction.

**Rewrite** (169 words, 1.18/100w, 0 em dashes):

> A normal cache matches requests by exact text. A small change in wording then causes a
> cache miss. fluxcache compares the meaning of a new prompt with the prompts already in
> the cache. If two prompts are close enough in meaning, fluxcache returns the stored
> response instead of a new call to the model. This lowers the number of calls to the
> model and cuts the cost and response time of the application.

Short declaratives, condition before consequence, one name ("the cache") throughout, no
voice, and the same facts.

## Error message (strict mode, the cleanest result)

**Baseline** (123 words, 3.25/100w): contractions (`You've`), a rolling-window
explanation in one long sentence, filler (`ensures fair access for all users`).

**Rewrite** (72 words, 0.00/100w, 41% fewer words):

> The API allows a maximum of 100 requests per minute for each account. Your application
> sent more requests than this limit allows. The server rejected the extra requests to
> protect the system for all users. Check the `Retry-After` header in the response for
> the exact wait time. Wait for this time, then send your request again.

Fact → cause → action, in that order. The code span (`Retry-After`) stays untouched.

## PR description (flavored mode: density without run-ons)

Baseline (347 words, 3.46/100w) stacks parentheticals into 30–40-word sentences
("surfaced immediately to callers with no retry, forcing every call site to implement its
own ad-hoc retry logic"). The rewrite (297 words, 1.35/100w) is one action per line,
short sentences, same information. The lesson: the caps do not cost information. They
cost only the packaging.

## The pattern

Across all three: the rewrite is *shorter*, scores 3–4× cleaner, and loses no facts. When
a rewrite loses a fact, that is a rewrite failure. Restore the fact and split the
sentence instead.
