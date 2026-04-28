# Architecture

## Services

- `ollama` for macOS development
- `vllm.service`: local inference endpoint
- `zeroclaw.service`: assistant runtime
- `prometheus.service`: metrics scraper
- `loki.service`: log store

## Request flow

1. user sends a question to `zeroclaw`
2. `zeroclaw` reads from the configured workspace and memory
3. `zeroclaw` calls the local model endpoint
4. response is returned to the user
5. logs go to `journald` and Loki
6. metrics are scraped by Prometheus

## Environments

- macOS development uses `Ollama`
- RHEL packaging targets `vLLM`
- `redclaw` uses a dedicated `zeroclaw` checkout under `vendor/zeroclaw`

## Boundaries

- `vLLM` is a sibling service, not embedded in `zeroclaw`
- the workspace is the only allowed data root for the assistant
- observability is bundled with the package, not optional afterthought
