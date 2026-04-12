#!/bin/bash
set -euo pipefail

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"

USERNAME="${_REMOTE_USER:-"$(awk -v val=1000 -F: '$3==val{print $1}' /etc/passwd)"}"
if [ -z "${USERNAME}" ] || [ "${USERNAME}" = "root" ]; then
  USERNAME="devcontainer"
fi

USER_HOME="/home/${USERNAME}"

mkdir -p "${USER_HOME}/.local/share/uv"
chown "${USERNAME}:${USERNAME}" "${USER_HOME}/.local/share/uv"

install -o "${USERNAME}" -g "${USERNAME}" -m 0644 "${FEATURE_DIR}/mise.toml" "${USER_HOME}/.config/mise/conf.d/979-python.toml"
