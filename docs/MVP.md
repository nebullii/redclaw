# MVP

## Use case

`redclaw` starts as a personal knowledge assistant.

The user should be able to:

- drop notes and documents into a workspace
- ask what they know about a topic
- summarize a set of files
- compare related documents

Before broader retrieval is added, the assistant should answer correctly from a seeded core knowledge base.

## Product rules

- local model only
- local workspace only
- no shell tool
- no browser tool
- read-only by default
- file writing only for explicit summary output

## Core-First Principle

The first MVP does not assume the model will discover and use arbitrary local files correctly.

Instead:

- core platform and product knowledge lives in `MEMORY.md`
- workspace bootstrap files shape behavior
- larger document retrieval comes after the assistant is stable on core knowledge

## Success criteria

- one local model endpoint is reachable
- `zeroclaw` can answer questions over the workspace
- `zeroclaw` can answer core platform questions from seeded local knowledge
- metrics and logs are visible locally
- the system stays usable without cloud dependencies

## Development note

macOS development uses `Ollama` first. The deployment target can switch to `vLLM` later without changing the product shape.
