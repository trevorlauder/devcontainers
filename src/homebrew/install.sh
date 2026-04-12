#!/bin/bash
set -euo pipefail

export BREW_VERSION="5.1.5"
export HOMEBREW_PREFIX="${_REMOTE_USER_HOME:-/home}/${_REMOTE_USER}/.linuxbrew"

if [ "${_REMOTE_USER:-root}" = "root" ]; then
  echo "❌ This Feature requires a non-root remoteUser."

  exit 1
fi

apt-get update
apt-get install -y --no-install-recommends build-essential procps curl file git
rm -rf /var/lib/apt/lists/*

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
su "${_REMOTE_USER}" -c "${SCRIPT_DIR}/setup.sh"

mkdir -p /home/linuxbrew
ln -s "${HOMEBREW_PREFIX}" /home/linuxbrew/.linuxbrew

if [ -n "${PACKAGES}" ]; then
  su "${_REMOTE_USER}" -c "brew install ${PACKAGES}"
fi
