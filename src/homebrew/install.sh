#!/bin/bash
set -euo pipefail

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

USERNAME="${_REMOTE_USER:-"$(awk -v val=1000 -F: '$3==val{print $1}' /etc/passwd)"}"
if [ -z "${USERNAME}" ] || [ "${USERNAME}" = "root" ]; then
  USERNAME="devcontainer"
fi

USER_HOME="/home/${USERNAME}"

export BREW_VERSION="5.1.5"
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"

apt-get update
apt-get install -y --no-install-recommends build-essential procps curl file git
rm -rf /var/lib/apt/lists/*

mkdir -p "${HOMEBREW_PREFIX}/Homebrew" "${HOMEBREW_PREFIX}/bin"
chown -R ${USERNAME}:${USERNAME} "${HOMEBREW_PREFIX}"
su "${USERNAME}" -c "${SCRIPT_DIR}/setup.sh"

install -m 0440 ${FEATURE_DIR}/sudoers /etc/sudoers.d/feature-homebrew-${USERNAME}
sed -i "s/%USERNAME%/${USERNAME}/g" /etc/sudoers.d/feature-homebrew-${USERNAME}
chmod 0440 /etc/sudoers.d/feature-homebrew-${USERNAME}

install -m 0755 ${FEATURE_DIR}/post-start.sh /usr/local/bin/feature-homebrew-post-start.sh
sed -i "s/%PACKAGES%/${PACKAGES}/g" /usr/local/bin/feature-homebrew-post-start.sh

install -m 0755 ${FEATURE_DIR}/post-start-root.sh /usr/local/sbin/feature-homebrew-post-start-root.sh
sed -i "s/%USERNAME%/${USERNAME}/g" /usr/local/sbin/feature-homebrew-post-start-root.sh
