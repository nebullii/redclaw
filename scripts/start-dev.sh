#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$ROOT_DIR/configs"
WORKSPACE_DIR="$CONFIG_DIR/workspace"
SAMPLE_DIR="$ROOT_DIR/samples/knowledge"
VENDORED_ZEROCLAW_DIR="$ROOT_DIR/vendor/zeroclaw"
DEFAULT_RELEASE_BIN="$VENDORED_ZEROCLAW_DIR/target/release/zeroclaw"
DEFAULT_DEBUG_BIN="$VENDORED_ZEROCLAW_DIR/target/debug/zeroclaw"
ZEROCLAW_BIN="${REDCLAW_ZEROCLAW_BIN:-}"
ALLOWED_TOOLS=(
  "--allowed-tool" "file_read"
  "--allowed-tool" "glob_search"
  "--allowed-tool" "content_search"
)

if [[ -z "$ZEROCLAW_BIN" ]]; then
  if [[ -x "$DEFAULT_RELEASE_BIN" ]]; then
    ZEROCLAW_BIN="$DEFAULT_RELEASE_BIN"
  elif [[ -x "$DEFAULT_DEBUG_BIN" ]]; then
    ZEROCLAW_BIN="$DEFAULT_DEBUG_BIN"
  fi
fi

if [[ -z "$ZEROCLAW_BIN" ]]; then
  cat <<EOF
No dedicated zeroclaw binary found for redclaw.

Expected one of:
  $DEFAULT_RELEASE_BIN
  $DEFAULT_DEBUG_BIN

Next step:
  cd "$VENDORED_ZEROCLAW_DIR"
  cargo build

Or set:
  REDCLAW_ZEROCLAW_BIN=/path/to/dedicated/zeroclaw
EOF
  exit 1
fi

if ! command -v ollama >/dev/null 2>&1; then
  echo "ollama is not installed."
  exit 1
fi

mkdir -p "$WORKSPACE_DIR"
rm -f "$WORKSPACE_DIR/IDENTITY.md" "$WORKSPACE_DIR/SOUL.md"
cp -f "$SAMPLE_DIR"/* "$WORKSPACE_DIR"/

cat <<EOF
redclaw macOS dev flow

1. In another terminal, start Ollama if it is not already running:
   ollama serve

2. Pull the starter model if needed:
   ollama pull gemma3:12b

3. Run the dedicated zeroclaw binary against the repo-local config:
   ZEROCLAW_CONFIG_DIR="$CONFIG_DIR" ZEROCLAW_WORKSPACE="$WORKSPACE_DIR" "$ZEROCLAW_BIN" agent ${ALLOWED_TOOLS[*]}

The workspace is:
  $WORKSPACE_DIR

The dedicated zeroclaw binary is:
  $ZEROCLAW_BIN
EOF
