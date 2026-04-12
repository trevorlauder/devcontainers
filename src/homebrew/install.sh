#!/bin/bash
set -euo pipefail

USERNAME="${_REMOTE_USER:-"$(awk -v val=1000 -F: '$3==val{print $1}' /etc/passwd)"}"
if [ -z "${USERNAME}" ] || [ "${USERNAME}" = "root" ]; then
  USERNAME="devcontainer"
fi

USER_HOME="/home/${USERNAME}"

export BREW_VERSION="5.1.5"
export HOMEBREW_PREFIX="${USER_HOME}/.linuxbrew"

apt-get update
apt-get install -y --no-install-recommends build-essential procps curl file git
rm -rf /var/lib/apt/lists/*

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
setpriv --reuid="${USERNAME}" --regid="${USERNAME}" --init-groups -- "${SCRIPT_DIR}/setup.sh"

mkdir -p /home/linuxbrew
ln -s "${HOMEBREW_PREFIX}" /home/linuxbrew/.linuxbrew

if [ -n "${PACKAGES}" ]; then
  setpriv --reuid="${USERNAME}" --regid="${USERNAME}" --init-groups -- brew install ${PACKAGES}
fi
