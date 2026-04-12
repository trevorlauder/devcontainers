#!/bin/bash
set -euo pipefail

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"

USERNAME="${_REMOTE_USER:-"$(awk -v val=1000 -F: '$3==val{print $1}' /etc/passwd)"}"
if [ -z "${USERNAME}" ] || [ "${USERNAME}" = "root" ]; then
  USERNAME="devcontainer"
fi

USER_HOME="/home/${USERNAME}"

install -o ${USERNAME} -g ${USERNAME} -m 0644 ${FEATURE_DIR}/mise.toml ${USER_HOME}/.config/mise/conf.d/989-aws.toml

if [ "${USEGRANTED}" = "true" ]; then
    mkdir -p ${USER_HOME}/.granted
    chown ${USERNAME}:${USERNAME} ${USER_HOME}/.granted
    install -o ${USERNAME} -g ${USERNAME} -m 0644 ${FEATURE_DIR}/mise.granted.toml ${USER_HOME}/.config/mise/conf.d/988-aws-granted.toml
fi
