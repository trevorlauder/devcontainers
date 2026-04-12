#!/bin/bash
set -euo pipefail

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "${_REMOTE_USER:-root}" = "root" ]; then
  echo "❌ This Feature requires a non-root remoteUser."

  exit 1
fi

REMOTE_USER_HOME="${_REMOTE_USER_HOME:-/home/${_REMOTE_USER}}"

mkdir -p "/home/${_REMOTE_USER}/.local/share/uv"
chown "${_REMOTE_USER}:${_REMOTE_USER}" "${REMOTE_USER_HOME}/.local/share/uv"

install -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" -m 0644 "${FEATURE_DIR}/mise.toml" "${REMOTE_USER_HOME}/.config/mise/conf.d/979-python.toml"
