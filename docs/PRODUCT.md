# Product Definition

## What RedClaw Is

`redclaw` is a local-first personal assistant package built around:

- `zeroclaw` as the assistant runtime
- a local model runtime for inference
- a hardened host story centered on Linux and later `RHEL`
- built-in observability with metrics and logs

It is not a raw agent framework for power users. It is an opinionated assistant product shape.

## Who It Is For

The first user is:

- a non-technical or lightly technical user
- someone who wants a private assistant over their own notes and documents
- someone who benefits from local execution and does not want to depend on frontier APIs by default

The first deployment environment is a single-user assistant, not a team platform.

## What It Does First

Version 1 focuses on:

- answering questions from seeded local knowledge
- summarizing notes and documents
- helping the user navigate what they already know
- running locally with minimal trust assumptions

The first successful behavior is:

- grounded answers
- clear summaries
- honest uncertainty
- low operational friction

## What It Does Not Do In V1

Version 1 does not prioritize:

- broad autonomy
- multi-agent orchestration
- deep workflow automation
- always-on external integrations
- complex browser or shell operations

Those may come later, but they are not the product core.

## Core Principles

### Local First

- the assistant should work with a local model by default
- user knowledge should stay local whenever possible
- cloud dependency should be optional, not required

### Private By Default

- the user should know where data lives
- the assistant should prefer local state and local inference
- observability should not mean indiscriminate data leakage

### Observable By Default

- the package should expose metrics and logs
- the operator should be able to inspect behavior and failures
- observability is a built-in property, not an afterthought

### Safe By Default

- the assistant should not act broadly just because tools exist
- side effects should be constrained
- the system should clearly separate observability from security enforcement

### Grounded Over Performative

- the assistant should answer from seeded and retrieved knowledge when possible
- if it does not know, it should say so
- it should avoid generic filler when local knowledge is expected

## Product Layers

### Assistant Layer

- `zeroclaw` handles runtime behavior, tool use, and memory

### Model Layer

- local model runtime provides inference
- macOS development can use `Ollama`
- the later `RHEL` target can use `vLLM`

### Platform Layer

- `redclaw` packages the runtime, model path, and operational defaults

### Operations Layer

- `Prometheus` provides metrics
- `Loki` provides logs
- Linux security controls provide host enforcement

## Knowledge Model

`redclaw` has two knowledge classes:

### Seeded Core Knowledge

- product identity
- platform knowledge
- operating rules
- stable user or project context

This belongs in bootstrap files such as `MEMORY.md`, `AGENTS.md`, and `USER.md`.

### Retrieved Working Knowledge

- note collections
- documents
- evolving reference material
- imported local corpora

This belongs in a broader workspace corpus and retrieval path.

## Why It Matters

The product is not “an agent with many integrations.”

The product is:

- a trustworthy personal assistant
- running locally
- with clear operational visibility
- and a controlled path to broader integrations later

## Near-Term Roadmap

1. make seeded core knowledge reliable
2. validate personal knowledge assistant behavior
3. improve local retrieval over user documents
4. add carefully chosen integrations such as email or calendar
5. package the stack cleanly for `RHEL`
