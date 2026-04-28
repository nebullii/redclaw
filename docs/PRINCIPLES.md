# Principles

## Product Before Platform

`redclaw` should feel like a usable personal assistant before it grows into a broader agent platform.

## Core Knowledge Before Broad Retrieval

Stable assistant knowledge belongs in seeded files such as `MEMORY.md`.

Larger document collections can come later through retrieval.

## Local First

The default experience should work with a local model and local user data.

## Observability Is Built In

Metrics and logs are part of the product shape from the start, not later add-ons.

## Security Is Separate From Observability

`Prometheus` and `Loki` help operators see behavior.

They do not replace host security controls like `SELinux` and process isolation.

## Integrations Come After Trust

Email, calendar, and other tools are useful, but only after the assistant’s core behavior is reliable and bounded.
