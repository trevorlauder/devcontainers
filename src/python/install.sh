#!/bin/bash
set -euo pipefail

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "${ENABLEFIREWALL}" = "true" ]; then
    install -m 0644 "${FEATURE_DIR}/firewall-fqdns.txt" /usr/local/etc/firewall-extra-fqdns.d/feature-python-fqdns.txt
fi

mkdir -p "/home/${USERNAME}/.local/share/uv"
chown "${USERNAME}:${USERNAME}" "/home/${USERNAME}/.local/share/uv"

install -o "${USERNAME}" -g "${USERNAME}" -m 0644 "${FEATURE_DIR}/mise.toml" "/home/${USERNAME}/.config/mise/conf.d/979-python.toml"
