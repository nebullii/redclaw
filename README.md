# redclaw

`redclaw` is a local-first personal knowledge assistant package built around:

- `zeroclaw` for agent runtime
- `vLLM` for the target RHEL model-serving path
- `Prometheus` for metrics
- `Loki` for logs
- `RHEL` for the host platform

The first target is simple: a personal knowledge assistant for non-technical users that runs locally, answers questions over their files, and stays observable.

Development starts on macOS with `Ollama` because it is a better fit for this machine than first-pass `vLLM`. The package target remains `RHEL + vLLM`.

## Scope

Version 1 focuses on:

- local document-based question answering
- summaries and short briefings
- local-only model inference
- strict workspace boundaries
- minimal service packaging on RHEL

Version 1 does not include:

- browser automation
- shell execution
- multi-agent orchestration
- external chat channels
- cloud model fallback

## Repo layout

- `configs/` runtime configuration templates
- `docs/` product and architecture notes
- `loki/` local log aggregation config
- `prometheus/` scrape config
- `samples/knowledge/` sample knowledge base files
- `scripts/` bootstrap and developer helpers
- `services/` `systemd` unit files
- `vendor/zeroclaw/` dedicated runtime checkout for `redclaw`
- `vendor/zeroclaw.PINNED.md` pin record for the vendored runtime

## First milestone

The first milestone is one working vertical slice:

1. start the local model runtime
2. start `zeroclaw`
3. load sample knowledge files
4. ask questions through the assistant
5. observe logs and metrics locally

## Runtime isolation

`redclaw` should not depend on your contributor `zeroclaw` install.

Use one of these:

- build the vendored checkout at `vendor/zeroclaw`
- point `REDCLAW_ZEROCLAW_BIN` at a dedicated `zeroclaw` binary

The development scripts prefer `REDCLAW_ZEROCLAW_BIN`. If unset, they expect the vendored checkout to provide a built binary at:

- `vendor/zeroclaw/target/release/zeroclaw`
- or `vendor/zeroclaw/target/debug/zeroclaw`

## Planned stack

- Host OS: `RHEL 9` developer subscription
- Model runtime:
  - dev: `Ollama`
  - target: `vLLM`
- Assistant runtime: `zeroclaw`
- Metrics: `Prometheus`
- Logs: `Loki`
- Security: `SELinux` + `systemd` hardening

## Next steps

1. bring up the local macOS model path
2. validate `zeroclaw` against the local endpoint
3. tighten the assistant tool policy
4. wire Prometheus and Loki
5. add an install path for RHEL
