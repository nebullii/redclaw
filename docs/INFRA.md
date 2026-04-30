# Infrastructure

## Purpose

This document defines the first deployable system shape for `redclaw`.

The goal is not to describe every future deployment option. The goal is to define the minimum service graph and filesystem layout needed to turn the current working assistant core into an operable package.

## Deployment Target

Current phases:

- development: macOS with `Ollama`
- target packaging path: `RHEL` with `vLLM`

This document focuses on the target packaged shape, because that is where service boundaries, observability, and host controls start to matter.

## Service Graph

`redclaw` is a multi-service local system.

Core services:

1. `redclaw-model.service`
   - hosts the local model over HTTP
   - current target implementation: `vLLM`
2. `redclaw-zeroclaw.service`
   - runs the assistant runtime
   - owns the user-facing assistant process
   - talks to the local model service
   - reads the configured workspace

Operational services:

3. `prometheus.service`
   - scrapes metrics from the model service, `zeroclaw`, and host exporters
4. `loki.service`
   - stores and queries logs from `zeroclaw`, the model runtime, and host-level log forwarders

Optional supporting service:

5. `node-exporter.service`
   - exposes host metrics to `Prometheus`

### Graph

```text
user
  -> redclaw-zeroclaw.service
  -> redclaw-model.service
  -> workspace data

redclaw-prometheus.service
  -> zeroclaw metrics endpoint
  -> local-model metrics endpoint
  -> node exporter

redclaw-loki.service
  -> zeroclaw logs
  -> local-model logs
  -> host/system logs
```

## Startup Order

Required ordering:

1. `redclaw-model.service` starts first
2. `redclaw-zeroclaw.service` starts after the model service is reachable
3. `redclaw-prometheus.service` and `redclaw-loki.service` can start independently after the network is available

Service dependency assumptions:

- `redclaw-zeroclaw.service` should `Require=` and `After=` the model service
- `Prometheus` does not block the assistant
- `Loki` does not block the assistant

This keeps observability important but non-critical to assistant availability.

## Responsibilities By Service

### `redclaw-model.service`

Owns:

- local model loading
- inference HTTP endpoint
- model resource usage
- model-specific metrics

Does not own:

- user-facing assistant logic
- workspace policy
- knowledge orchestration

### `redclaw-zeroclaw.service`

Owns:

- provider routing to the local model
- workspace-grounded tool usage
- runtime policy and tool access
- assistant sessions
- local memory backend

Does not own:

- model hosting
- metrics storage
- log storage

### `redclaw-prometheus.service`

Owns:

- scrape scheduling
- metrics retention
- alert rule evaluation later

Does not own:

- logs
- tracing
- policy enforcement

### `redclaw-loki.service`

Owns:

- log ingestion
- indexed log query
- short-to-medium-term runtime troubleshooting

Does not own:

- metrics
- audit policy
- host MAC enforcement

## Network Layout

Initial local-only network plan:

- `redclaw-model.service`
  - bind: `127.0.0.1:8000`
- `redclaw-zeroclaw.service`
  - bind only what is needed for the chosen user interface
  - current repo gateway placeholder: `127.0.0.1:42617`
- `redclaw-prometheus.service`
  - local-only unless explicitly exposed
- `redclaw-loki.service`
  - local-only unless explicitly exposed

Principle:

- bind internal services to loopback first
- only expose externally if the product explicitly needs it

## Filesystem Layout

Recommended packaged layout:

- `/opt/redclaw/`
  - application install root
  - packaged binaries or supporting assets
- `/etc/redclaw/`
  - main configuration
  - model service environment overrides
  - zeroclaw service environment overrides
  - Prometheus and Loki configs if packaged together
- `/var/lib/redclaw/`
  - workspace
  - runtime state
  - memory backend data
  - durable application data
- `/var/log/redclaw/`
  - optional explicit log path if not relying solely on `journald`

Suggested internal structure:

```text
/etc/redclaw/
  config.toml
  redclaw-model.env
  redclaw-zeroclaw.env
  redclaw-prometheus.env
  redclaw-loki.env
  prometheus.yml
  loki-config.yml

/var/lib/redclaw/
  workspace/
  state/
  memory/

/opt/redclaw/
  bin/
  services/
```

## Current Config Mapping

Current repo-local equivalents:

- `configs/config.toml`
  -> current macOS/Ollama dev profile
- `configs/zeroclaw-vllm.toml`
  -> future `/etc/redclaw/config.toml`
- `prometheus/prometheus.yml`
  -> future `/etc/redclaw/prometheus.yml`
- `loki/loki-config.yml`
  -> future `/etc/redclaw/loki-config.yml`
- `configs/redclaw-model.env.example`
  -> future `/etc/redclaw/redclaw-model.env`
- `configs/redclaw-zeroclaw.env.example`
  -> future `/etc/redclaw/redclaw-zeroclaw.env`
- `configs/redclaw-prometheus.env.example`
  -> future `/etc/redclaw/redclaw-prometheus.env`
- `configs/redclaw-loki.env.example`
  -> future `/etc/redclaw/redclaw-loki.env`
- `configs/workspace/`
  -> future `/var/lib/redclaw/workspace/`

## Unit Layout

Planned `systemd` units:

- `redclaw-model.service`
- `redclaw-zeroclaw.service`
- `redclaw-prometheus.service`
- `redclaw-loki.service`

The repo currently carries packaged service templates:

- `services/redclaw-model.service`
- `services/redclaw-zeroclaw.service`
- `services/redclaw-prometheus.service`
- `services/redclaw-loki.service`

These should be treated as the canonical RHEL-facing unit baseline.

## Bootstrap Flow

The repo now includes a staging bootstrap helper:

- `scripts/bootstrap-rhel.sh plan`
  - prints the target layout, staged files, and manual follow-up steps
- `scripts/bootstrap-rhel.sh install`
  - creates the filesystem layout
  - installs unit files under the configured systemd directory
  - installs the target `vLLM` config as `/etc/redclaw/config.toml`
  - installs env and observability config templates under `/etc/redclaw`
  - seeds `/var/lib/redclaw/workspace` from `samples/knowledge`

The script intentionally does not try to:

- install host packages with `dnf`
- create system users automatically
- choose one distribution-specific binary source for `zeroclaw`, `vLLM`, `Prometheus`, or `Loki`

That is deliberate. The current goal is to make the layout and service contracts reproducible first, then layer package installation and host-specific policy on top.

## Validated Metrics Contracts

The current infra contract is based on the actual vendored `zeroclaw` source and current `vLLM` docs:

- `redclaw-zeroclaw.service`
  - runs `zeroclaw daemon`
  - binds the gateway to `127.0.0.1:42617` by default
  - serves `GET /metrics` on the gateway
  - only emits real Prometheus metrics when `[observability] backend = "prometheus"`
- `redclaw-model.service`
  - runs `vllm serve`
  - binds to `127.0.0.1:8000` by default
  - exposes Prometheus-compatible metrics at `GET /metrics` on the OpenAI-compatible API server

Because of that:

- the target packaged config must use `configs/zeroclaw-vllm.toml`, not the macOS dev config
- the target packaged config must keep `[observability] backend = "prometheus"`
- `prometheus/prometheus.yml` can use default `/metrics` scraping for both services

## Validation Flow

The repo includes a simple endpoint validator:

- `scripts/validate-stack.sh`

Default checks:

- model health: `http://127.0.0.1:8000/health`
- model metrics: `http://127.0.0.1:8000/metrics`
- zeroclaw health: `http://127.0.0.1:42617/health`
- zeroclaw metrics: `http://127.0.0.1:42617/metrics`
- Prometheus readiness: `http://127.0.0.1:9090/-/ready` if present
- Loki readiness: `http://127.0.0.1:3100/ready` if present

Override points are environment-driven:

- `REDCLAW_MODEL_BASE_URL`
- `REDCLAW_ZEROCLAW_BASE_URL`
- `REDCLAW_PROMETHEUS_BASE_URL`
- `REDCLAW_LOKI_BASE_URL`

## RHEL Packaging Notes

This project should follow normal RHEL service packaging conventions:

- service names should be product-qualified: `redclaw-*`
- configuration should live under `/etc/redclaw/`
- mutable state should live under `/var/lib/redclaw/`
- logs should default to `journald`, with `Loki` as an aggregation plane
- internal services should bind to loopback first
- environment-specific overrides should be supplied through environment files, not by editing unit files

For systemd hardening, prefer:

- `NoNewPrivileges=true`
- `PrivateTmp=true`
- `ProtectSystem=strict`
- `ProtectHome=true`
- `ProtectKernelTunables=true`
- `ProtectKernelModules=true`
- `ProtectControlGroups=true`
- narrow `ReadWritePaths=`

## Observability Plan

### Metrics

`Prometheus` should eventually scrape:

- `zeroclaw`
- local model runtime
- host/node metrics

Current packaged assumptions:

- `redclaw-model.service`
  - target: `127.0.0.1:8000`
- `redclaw-zeroclaw.service`
  - target: `127.0.0.1:42617`
- `node-exporter.service`
  - target: `127.0.0.1:9100`

Examples of useful signals:

- request latency
- inference throughput
- error counts
- memory pressure
- queue depth
- process uptime

### Logs

`Loki` should eventually collect:

- `zeroclaw` logs
- local model runtime logs
- host or service logs forwarded from `journald`

Current packaged assumptions:

- Loki binds to `127.0.0.1:3100`
- Loki stores local data under `/var/lib/redclaw/loki`
- service logs should flow through `journald` first
- a later pass can add a dedicated shipper such as `promtail` or a journald-forwarding path

Examples of useful log classes:

- startup failures
- provider connection failures
- tool-call failures
- model loading issues
- workspace access errors

## Security Boundary

The first infra slice assumes:

- `zeroclaw` is workspace-bounded
- the model service is local-only
- shell/browser/web search remain out of the MVP profile

Later host hardening should add:

- `SELinux`
- tighter `systemd` sandboxing
- service-specific filesystem write scopes
- resource limits

Important separation:

- `Prometheus` and `Loki` observe the system
- they do not enforce the system

## V1 Infra Scope

Included in the first infra pass:

- service graph definition
- unit layout definition
- filesystem layout definition
- local-only network plan
- `Prometheus` and `Loki` placement in the architecture

Deferred:

- full installer
- full `SELinux` policy work
- multi-node deployment
- external exposure
- complex user interface packaging

## Immediate Next Steps

1. align the existing unit files with the service graph in this document
2. decide whether the packaged service names should stay generic or become `redclaw-*`
3. define the metrics endpoints that `Prometheus` should scrape
4. define the log ingestion path into `Loki`
5. tighten the `RHEL` filesystem and service ownership layout
