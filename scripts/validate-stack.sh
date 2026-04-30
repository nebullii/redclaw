#!/usr/bin/env bash
set -euo pipefail

MODEL_BASE_URL="${REDCLAW_MODEL_BASE_URL:-http://127.0.0.1:8000}"
ZEROCLAW_BASE_URL="${REDCLAW_ZEROCLAW_BASE_URL:-http://127.0.0.1:42617}"
PROMETHEUS_BASE_URL="${REDCLAW_PROMETHEUS_BASE_URL:-http://127.0.0.1:9090}"
LOKI_BASE_URL="${REDCLAW_LOKI_BASE_URL:-http://127.0.0.1:3100}"

CURL_BIN="${CURL_BIN:-curl}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required command: $1" >&2
    exit 1
  fi
}

request() {
  local url="$1"
  local output
  output="$("${CURL_BIN}" -fsS "$url")"
  printf '%s' "$output"
}

expect_contains() {
  local label="$1"
  local body="$2"
  local needle="$3"
  if grep -Fq "$needle" <<<"$body"; then
    echo "ok   ${label}"
  else
    echo "fail ${label}: expected to find '${needle}'" >&2
    exit 1
  fi
}

check_health() {
  local label="$1"
  local url="$2"
  "${CURL_BIN}" -fsS -o /dev/null "$url"
  echo "ok   ${label}"
}

check_optional_health() {
  local label="$1"
  local url="$2"
  if "${CURL_BIN}" -fsS -o /dev/null "$url"; then
    echo "ok   ${label}"
  else
    echo "skip ${label}"
  fi
}

require_cmd "${CURL_BIN}"

echo "RedClaw stack validation"
echo "model:      ${MODEL_BASE_URL}"
echo "zeroclaw:   ${ZEROCLAW_BASE_URL}"
echo "prometheus: ${PROMETHEUS_BASE_URL}"
echo "loki:       ${LOKI_BASE_URL}"
echo

check_health "model health" "${MODEL_BASE_URL}/health"
model_metrics="$(request "${MODEL_BASE_URL}/metrics")"
expect_contains "model metrics" "${model_metrics}" "vllm:"

check_health "zeroclaw health" "${ZEROCLAW_BASE_URL}/health"
zeroclaw_metrics="$(request "${ZEROCLAW_BASE_URL}/metrics")"
expect_contains "zeroclaw metrics" "${zeroclaw_metrics}" "zeroclaw_"

check_optional_health "prometheus ready" "${PROMETHEUS_BASE_URL}/-/ready"
check_optional_health "loki ready" "${LOKI_BASE_URL}/ready"

echo
echo "validation passed"
