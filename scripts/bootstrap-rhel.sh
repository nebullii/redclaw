#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

DESTDIR="${DESTDIR:-/}"
SYSTEMD_DIR="${SYSTEMD_DIR:-${DESTDIR%/}/etc/systemd/system}"
ETC_DIR="${ETC_DIR:-${DESTDIR%/}/etc/redclaw}"
VAR_LIB_DIR="${VAR_LIB_DIR:-${DESTDIR%/}/var/lib/redclaw}"
VAR_LOG_DIR="${VAR_LOG_DIR:-${DESTDIR%/}/var/log/redclaw}"
OPT_DIR="${OPT_DIR:-${DESTDIR%/}/opt/redclaw}"
BIN_DIR="${BIN_DIR:-${OPT_DIR}/bin}"
USER_NAME="${REDCLAW_USER:-redclaw}"
GROUP_NAME="${REDCLAW_GROUP:-redclaw}"
MODE="${1:-install}"

usage() {
  cat <<'EOF'
Usage:
  bootstrap-rhel.sh [install|plan]

Environment overrides:
  DESTDIR        Stage files under an alternate root.
  SYSTEMD_DIR    Override the systemd unit destination.
  ETC_DIR        Override the config destination.
  VAR_LIB_DIR    Override the state/workspace destination.
  VAR_LOG_DIR    Override the log destination.
  OPT_DIR        Override the product install root.
  BIN_DIR        Override the runtime symlink destination.
  REDCLAW_USER   Service account name. Default: redclaw
  REDCLAW_GROUP  Service group name. Default: redclaw
EOF
}

ensure_dir() {
  install -d -m "$2" "$1"
}

copy_if_missing() {
  local src="$1"
  local dst="$2"
  if [[ -e "$dst" ]]; then
    echo "keep    $dst"
  else
    install -m 0644 "$src" "$dst"
    echo "install $dst"
  fi
}

copy_force() {
  local src="$1"
  local dst="$2"
  install -m 0644 "$src" "$dst"
  echo "install $dst"
}

copy_tree() {
  local src_dir="$1"
  local dst_dir="$2"
  ensure_dir "$dst_dir" 0755
  while IFS= read -r -d '' file; do
    local rel="${file#${src_dir}/}"
    local target="${dst_dir}/${rel}"
    ensure_dir "$(dirname "$target")" 0755
    install -m 0644 "$file" "$target"
    echo "install $target"
  done < <(find "$src_dir" -type f -print0)
}

print_plan() {
  cat <<EOF
RedClaw RHEL bootstrap plan

Service account:
  user:  ${USER_NAME}
  group: ${GROUP_NAME}

Destination layout:
  systemd units: ${SYSTEMD_DIR}
  config:        ${ETC_DIR}
  state:         ${VAR_LIB_DIR}
  logs:          ${VAR_LOG_DIR}
  install root:  ${OPT_DIR}
  bin links:     ${BIN_DIR}

Files staged from repo:
  configs/zeroclaw-vllm.toml           -> ${ETC_DIR}/config.toml
  configs/redclaw-model.env.example    -> ${ETC_DIR}/redclaw-model.env
  configs/redclaw-zeroclaw.env.example -> ${ETC_DIR}/redclaw-zeroclaw.env
  configs/redclaw-prometheus.env.example -> ${ETC_DIR}/redclaw-prometheus.env
  configs/redclaw-loki.env.example     -> ${ETC_DIR}/redclaw-loki.env
  prometheus/prometheus.yml            -> ${ETC_DIR}/prometheus.yml
  loki/loki-config.yml                 -> ${ETC_DIR}/loki-config.yml
  samples/knowledge/*                  -> ${VAR_LIB_DIR}/workspace/
  services/*.service                   -> ${SYSTEMD_DIR}/

Directories created:
  ${VAR_LIB_DIR}/workspace
  ${VAR_LIB_DIR}/state
  ${VAR_LIB_DIR}/memory
  ${VAR_LIB_DIR}/prometheus
  ${VAR_LIB_DIR}/loki
  ${VAR_LOG_DIR}
  ${OPT_DIR}
  ${BIN_DIR}

Manual follow-up still required:
  - create the ${USER_NAME}:${GROUP_NAME} service account on the target host
  - install runtime binaries: zeroclaw, vllm, prometheus, loki
  - optionally add node_exporter and log forwarding
  - run: systemctl daemon-reload
  - run: systemctl enable --now redclaw-model redclaw-zeroclaw
EOF
}

install_layout() {
  ensure_dir "$SYSTEMD_DIR" 0755
  ensure_dir "$ETC_DIR" 0755
  ensure_dir "$VAR_LIB_DIR" 0755
  ensure_dir "$VAR_LIB_DIR/workspace" 0755
  ensure_dir "$VAR_LIB_DIR/state" 0755
  ensure_dir "$VAR_LIB_DIR/memory" 0755
  ensure_dir "$VAR_LIB_DIR/prometheus" 0755
  ensure_dir "$VAR_LIB_DIR/loki" 0755
  ensure_dir "$VAR_LOG_DIR" 0755
  ensure_dir "$OPT_DIR" 0755
  ensure_dir "$BIN_DIR" 0755

  copy_if_missing "${REPO_ROOT}/configs/zeroclaw-vllm.toml" "${ETC_DIR}/config.toml"
  copy_if_missing "${REPO_ROOT}/configs/redclaw-model.env.example" "${ETC_DIR}/redclaw-model.env"
  copy_if_missing "${REPO_ROOT}/configs/redclaw-zeroclaw.env.example" "${ETC_DIR}/redclaw-zeroclaw.env"
  copy_if_missing "${REPO_ROOT}/configs/redclaw-prometheus.env.example" "${ETC_DIR}/redclaw-prometheus.env"
  copy_if_missing "${REPO_ROOT}/configs/redclaw-loki.env.example" "${ETC_DIR}/redclaw-loki.env"
  copy_force "${REPO_ROOT}/prometheus/prometheus.yml" "${ETC_DIR}/prometheus.yml"
  copy_force "${REPO_ROOT}/loki/loki-config.yml" "${ETC_DIR}/loki-config.yml"

  copy_force "${REPO_ROOT}/services/redclaw-model.service" "${SYSTEMD_DIR}/redclaw-model.service"
  copy_force "${REPO_ROOT}/services/redclaw-zeroclaw.service" "${SYSTEMD_DIR}/redclaw-zeroclaw.service"
  copy_force "${REPO_ROOT}/services/redclaw-prometheus.service" "${SYSTEMD_DIR}/redclaw-prometheus.service"
  copy_force "${REPO_ROOT}/services/redclaw-loki.service" "${SYSTEMD_DIR}/redclaw-loki.service"

  copy_tree "${REPO_ROOT}/samples/knowledge" "${VAR_LIB_DIR}/workspace"

  cat <<EOF

Bootstrap layout staged successfully.

Next steps on the target host:
  1. Create service account: useradd --system --home /var/lib/redclaw --shell /sbin/nologin ${USER_NAME}
  2. Install binaries into /usr/local/bin or adjust the unit ExecStart paths.
  3. Review ${ETC_DIR}/config.toml and the env files for model/provider settings.
  4. Run: chown -R ${USER_NAME}:${GROUP_NAME} ${VAR_LIB_DIR} ${VAR_LOG_DIR}
  5. Run: systemctl daemon-reload
  6. Run: systemctl enable --now redclaw-model redclaw-zeroclaw
EOF
}

case "${MODE}" in
  plan)
    print_plan
    ;;
  install)
    install_layout
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "Unknown mode: ${MODE}" >&2
    usage >&2
    exit 1
    ;;
esac
