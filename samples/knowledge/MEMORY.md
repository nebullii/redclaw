# RedClaw Memory

This file is the seeded core knowledge for the `redclaw` assistant.

## Product

- `redclaw` is a local-first personal knowledge assistant.
- The first deployment target is a non-technical user who wants a private assistant with local knowledge and local model inference.
- `redclaw` is not trying to start as a broad autonomous agent platform.
- The first success condition is grounded answers over local knowledge, not wide tool use.

## Stack

- `redclaw` uses `zeroclaw` as the assistant runtime.
- `redclaw` uses a local model runtime for inference.
- macOS development currently uses `Ollama`.
- the later RHEL target is `vLLM`.
- `Prometheus` is the metrics and alerting layer.
- `Loki` is the log aggregation layer.
- `RHEL` is the target host platform for the packaged version.

## Platform Knowledge

### RHEL

- `RHEL` can host local model runtimes and assistant services.
- `RHEL` is useful when the goal is predictable packaging, system services, and Linux security controls.
- the no-cost RHEL developer subscription is acceptable for prototyping and development.

### Linux Security

- `SELinux` is part of the host security story.
- `SELinux` provides confinement and policy enforcement.
- `Prometheus` is not a security boundary.
- host security and observability are separate responsibilities.

### Prometheus

- `Prometheus` is for metrics, health, alerting, and capacity visibility.
- `Prometheus` does not replace audit, policy, or executable allowlists.
- `Prometheus` is useful once multiple assistant instances need to be monitored consistently.

### Loki

- `Loki` is for log aggregation and troubleshooting.
- `Loki` complements metrics from `Prometheus`.
- `Loki` is not the same thing as Linux audit or MAC enforcement.

### Local Models

- local models are important for privacy, latency, and offline behavior.
- not every user needs a frontier cloud model for assistant-style workflows.
- local models are especially suitable for question answering over personal notes and documents.

### ZeroClaw

- `zeroclaw` already has provider abstraction, runtime controls, memory, and service support.
- `zeroclaw` can use local model providers such as `Ollama` and `vLLM`.
- `redclaw` should wrap and configure `zeroclaw`, not replace it.

## Current MVP Direction

- first use case: personal knowledge assistant
- first environment: macOS development with `Ollama`
- later deployment target: `RHEL + vLLM + Prometheus + Loki`
- current priority: make the assistant reliably answer from seeded local knowledge

## Test Data

- RedClaw test marker: copper-harbor-729
