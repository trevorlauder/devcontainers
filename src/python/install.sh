#!/bin/bash
set -euo pipefail

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"

REMOTE_USER="${_REMOTE_USER:-devcontainer}"

if [ "${REMOTE_USER}" = "root" ]; then
  echo "❌ This Feature requires a non-root remoteUser."

  exit 1
fi

REMOTE_USER_HOME="${_REMOTE_USER_HOME:-/home/${REMOTE_USER}}"

mkdir -p "/home/${REMOTE_USER}/.local/share/uv"
chown "${REMOTE_USER}:${REMOTE_USER}" "${REMOTE_USER_HOME}/.local/share/uv"

install -o "${REMOTE_USER}" -g "${REMOTE_USER}" -m 0644 "${FEATURE_DIR}/mise.toml" "${REMOTE_USER_HOME}/.config/mise/conf.d/979-python.toml"
