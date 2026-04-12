#!/bin/bash
set -euo pipefail

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "${_REMOTE_USER:-root}" = "root" ]; then
  REMOTE_USER="devcontainer"
else
  REMOTE_USER="${_REMOTE_USER}"
fi

REMOTE_USER_HOME=${_REMOTE_USER_HOME:-/home/${REMOTE_USER}}

install -o ${REMOTE_USER} -g ${REMOTE_USER} -m 0644 ${FEATURE_DIR}/mise.toml ${REMOTE_USER_HOME}/.config/mise/conf.d/989-aws.toml

if [ "${USEGRANTED}" = "true" ]; then
    mkdir -p ${REMOTE_USER_HOME}/.granted
    chown ${REMOTE_USER}:${REMOTE_USER} ${REMOTE_USER_HOME}/.granted
    install -o ${REMOTE_USER} -g ${REMOTE_USER} -m 0644 ${FEATURE_DIR}/mise.granted.toml ${REMOTE_USER_HOME}/.config/mise/conf.d/988-aws-granted.toml
fi
