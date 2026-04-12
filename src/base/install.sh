#!/bin/bash
set -euo pipefail

if [ "${_REMOTE_USER:-root}" = "root" ]; then
  REMOTE_USER="devcontainer"
else
  REMOTE_USER="${_REMOTE_USER}"
fi

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"
SHELL="/usr/bin/zsh"
REMOTE_USER_HOME="${_REMOTE_USER_HOME:-/home/${REMOTE_USER}}"

ARCH="$(dpkg --print-architecture)"

apt-get update
apt-get upgrade -y
apt-get install -y --no-install-recommends ca-certificates

install -dm 755 /etc/apt/keyrings
install -m 0644 "${FEATURE_DIR}/mise-gpg-key.pub" /etc/apt/keyrings/mise-archive-keyring.asc
install -m 0644 "${FEATURE_DIR}/mise.list" /etc/apt/sources.list.d/mise.list

apt-get update
apt-get install -y --no-install-recommends \
    mise \
    cosign \
    curl \
    less \
    procps \
    dnsutils \
    gnupg2 \
    openssh-client \
    zsh \
    git \
    vim

SUDO_FORCE_REMOVE=yes apt-get purge -y sudo
rm -rf /etc/sudoers /etc/sudoers.d

apt autoremove -y

rm -rf /var/lib/apt/lists/*

mkdir /tmp/chezmoi

(
    cd /tmp/chezmoi

    CHEZMOI_COSIGN_PUB="chezmoi_cosign.pub"
    install -m 0644 "${FEATURE_DIR}/${CHEZMOI_COSIGN_PUB}" .

    CHEZMOI_RELEASES_URL="https://github.com/twpayne/chezmoi/releases/download/v${CHEZMOIVERSION}"
    CHEZMOI_PKG="chezmoi_${CHEZMOIVERSION}_linux_${ARCH}.deb"

    CHEZMOI_CHECKSUMS="chezmoi_${CHEZMOIVERSION}_checksums.txt"
    CHEZMOI_CHECKSUMS_SIG="chezmoi_${CHEZMOIVERSION}_checksums.txt.sig"

    curl --location --remote-name-all \
        "${CHEZMOI_RELEASES_URL}/${CHEZMOI_CHECKSUMS}" \
        "${CHEZMOI_RELEASES_URL}/${CHEZMOI_CHECKSUMS_SIG}" \
        "${CHEZMOI_RELEASES_URL}/${CHEZMOI_PKG}"

    cosign verify-blob \
        --key="${CHEZMOI_COSIGN_PUB}" \
        --signature="${CHEZMOI_CHECKSUMS_SIG}" \
        "${CHEZMOI_CHECKSUMS}"

    sha256sum --check "${CHEZMOI_CHECKSUMS}" --ignore-missing

    dpkg -i "${CHEZMOI_PKG}"
)

rm -rf /tmp/chezmoi

if ! id "${REMOTE_USER}" &>/dev/null; then
  groupadd --gid 2000 "${REMOTE_USER}"
  useradd --uid 2000 --gid 2000 --shell "${SHELL}" --create-home "${REMOTE_USER}"
fi

mkdir -p \
  "${REMOTE_USER_HOME}/.cache/pre-commit" \
  "${REMOTE_USER_HOME}/.cache/prek" \
  "${REMOTE_USER_HOME}/.claude" \
  "${REMOTE_USER_HOME}/.config/mise/conf.d" \
  "${REMOTE_USER_HOME}/.local/share/mise"

if [ -n "${HOMEDIRS:-}" ]; then
  case "${HOMEDIRS}" in
    *..*) echo "ERROR: rejecting unsafe homeDirs value: ${HOMEDIRS}" >&2; exit 1 ;;
  esac

  ( cd $REMOTE_USER_HOME && mkdir -p $HOMEDIRS)
fi

chown -R "${REMOTE_USER}:${REMOTE_USER}" "${REMOTE_USER_HOME}"

install -o "${REMOTE_USER}" -g "${REMOTE_USER}" -m 0644 "${FEATURE_DIR}/mise.toml" "/home/${REMOTE_USER}/.config/mise/conf.d/999-base.toml"

ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
echo "${TIMEZONE}" > /etc/timezone

cat "${FEATURE_DIR}/zshenv" >> /etc/zsh/zshenv

install -m 0755 ${FEATURE_DIR}/init-container.sh /usr/local/bin/
