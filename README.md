# redclaw

`redclaw` is a local-first personal knowledge assistant package built around `zeroclaw`, a local model runtime, and an opinionated operational stack for observability and deployment.

The project goal is straightforward: make a private assistant that answers from local knowledge, runs on local infrastructure, and can later be packaged cleanly for `RHEL`.

## Status

`redclaw` is currently an early integration project.

What works today:

- local development with `Ollama`
- a dedicated vendored `zeroclaw` runtime
- grounded answers over local workspace files
- local summary and comparison flows
- strict local-only tool policy for the current MVP

What is not done yet:

- service packaging for the full stack
- `Prometheus` integration
- `Loki` integration
- hardened `RHEL` deployment path
- end-user installation flow

## Vision

`redclaw` is not trying to be a generic agent framework first.

It is trying to be:

- local-first
- private by default
- observable by default
- safe by default
- useful to non-technical users

The first use case is a personal knowledge assistant that answers from local notes and documents.

## Architecture

At a high level, `redclaw` has five layers:

1. `redclaw`
   - product wrapper
   - owns packaging, configuration, startup flow, workspace conventions, and deployment shape
2. `zeroclaw`
   - assistant runtime
   - handles prompting, tools, memory, workspace access, and provider routing
3. local model runtime
   - `Ollama` for current macOS development
   - later `vLLM` for the `RHEL` target
4. knowledge workspace
   - local notes and documents used as the source of truth
5. operations layer
   - later `Prometheus` for metrics
   - later `Loki` for logs
   - later Linux host controls such as `SELinux` and service hardening

### Request Flow

```text
user
  -> redclaw profile
  -> zeroclaw runtime
  -> local tools (file_read / glob_search / content_search) when needed
  -> local model runtime
  -> grounded response
```

### Service Graph

Current development shape:

```text
user
  -> zeroclaw
  -> Ollama
  -> local workspace
```

Target packaged shape:

```text
user
  -> zeroclaw.service
  -> local-model.service
  -> workspace data

prometheus.service
  -> scrapes zeroclaw + model runtime + host metrics

loki.service
  -> collects zeroclaw + model runtime + host logs
```

## Current Tool Policy

The current MVP is intentionally narrow.

Allowed tools:

- `file_read`
- `glob_search`
- `content_search`

Blocked or disabled by default:

- `web_search`
- `shell`
- `browser`
- `http`
- broad side-effecting tools

This keeps the assistant focused on local knowledge instead of drifting into generic agent behavior.

## MVP Scope

Version 1 focuses on:

- local document-based question answering
- summaries and briefings over local notes
- file-to-file comparison
- local-only inference
- clear workspace boundaries

Version 1 does not focus on:

- shell automation
- browser automation
- external chat channels
- broad integrations
- multi-agent orchestration

## Repository Layout

- `configs/`
  - runtime configuration templates
- `docs/`
  - product, architecture, and principles documents
- `loki/`
  - starter log aggregation config
- `prometheus/`
  - starter metrics config
- `samples/knowledge/`
  - seeded MVP knowledge files
- `scripts/`
  - developer and bootstrap helpers
- `services/`
  - service templates for the target deployment path
- `vendor/zeroclaw/`
  - dedicated vendored runtime source
- `vendor/zeroclaw.PINNED.md`
  - pin record for the vendored runtime

## Local Development

Current development is optimized for macOS with `Ollama`.

Typical flow:

1. start the local model runtime
2. start the vendored `zeroclaw` binary with the `redclaw` profile
3. load seeded knowledge files
4. ask grounded questions over the workspace

Helper script:

```bash
cd /Users/nehachaudhari/Developer/redclaw
./scripts/start-dev.sh
```

The script prints the exact command to run the dedicated `zeroclaw` binary with the current tool policy.

## Deployment Direction

The target packaged stack is:

- host OS: `RHEL`
- model runtime: `vLLM`
- assistant runtime: `zeroclaw`
- metrics: `Prometheus`
- logs: `Loki`
- host enforcement: `SELinux` + service hardening

`redclaw` is the integration layer that makes these components feel like one product instead of a collection of parts.

## Roadmap

Near term:

1. define the service graph and unit layout
2. formalize the infra slice
3. wire `Prometheus`
4. wire `Loki`
5. shape the first `RHEL` packaging flow

Later:

1. validate against real user notes and documents
2. improve retrieval quality
3. add carefully chosen integrations
4. package for a more end-user-friendly installation flow

## Documentation

- [Product Definition](docs/PRODUCT.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Infrastructure](docs/INFRA.md)
- [MVP](docs/MVP.md)
- [Principles](docs/PRINCIPLES.md)
- [GitHub Metadata](docs/GITHUB_METADATA.md)

## License

No project license has been added yet.
