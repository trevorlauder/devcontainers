#!/bin/bash
set -euo pipefail

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "${ENABLEFIREWALL}" = "true" ]; then
    install -m 0644 "${FEATURE_DIR}/firewall-fqdns.txt" /usr/local/etc/firewall-extra-fqdns.d/feature-ansible-fqdns.txt
fi

install -o "${USERNAME}" -g "${USERNAME}" -m 0644 "${FEATURE_DIR}/mise.toml" "/home/${USERNAME}/.config/mise/conf.d/130-ansible.toml"
