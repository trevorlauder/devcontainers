#!/bin/bash
set -euo pipefail

REMOTE_USER="${_REMOTE_USER:-devcontainer}"

if [ "${REMOTE_USER}" = "root" ]; then
  echo "❌ This Feature requires a non-root remoteUser."

  exit 1
fi

export BREW_VERSION="5.1.5"
export HOMEBREW_PREFIX="${_REMOTE_USER_HOME:-/home}/${REMOTE_USER}/.linuxbrew"

apt-get update
apt-get install -y --no-install-recommends build-essential procps curl file git
rm -rf /var/lib/apt/lists/*

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
su "${REMOTE_USER}" -c "${SCRIPT_DIR}/setup.sh"

mkdir -p /home/linuxbrew
ln -s "${HOMEBREW_PREFIX}" /home/linuxbrew/.linuxbrew

if [ -n "${PACKAGES}" ]; then
  su "${REMOTE_USER}" -c "brew install ${PACKAGES}"
fi
