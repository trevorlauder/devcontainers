#!/bin/bash
set -euo pipefail

USERNAME="${_REMOTE_USER:-"$(awk -v val=1000 -F: '$3==val{print $1}' /etc/passwd)"}"
if [ -z "${USERNAME}" ] || [ "${USERNAME}" = "root" ]; then
  USERNAME="devcontainer"
fi

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"
SHELL="/usr/bin/zsh"
USER_HOME="/home/${USERNAME}"

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
    gh \
    gzip \
    less \
    procps \
    sudo \
    dnsutils \
    gnupg2 \
    openssh-client \
    zsh \
    git \
    vim

if [ -n "${PACKAGES:-}" ]; then
  apt-get install -y --no-install-recommends $PACKAGES
fi

apt autoremove -y

rm -rf /var/lib/apt/lists/*

ldconfig

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

if ! id "${USERNAME}" &>/dev/null; then
  groupadd --gid 2000 "${USERNAME}"
  useradd --uid 2000 --gid 2000 --shell "${SHELL}" --create-home "${USERNAME}"
fi

mkdir -p \
  "${USER_HOME}/.cache/pre-commit" \
  "${USER_HOME}/.cache/prek" \
  "${USER_HOME}/.claude" \
  "${USER_HOME}/.config/mise/conf.d" \
  "${USER_HOME}/.local/share/mise"

if [ -n "${HOMEDIRS:-}" ]; then
  case "${HOMEDIRS}" in
    *..*) echo "ERROR: rejecting unsafe homeDirs value: ${HOMEDIRS}" >&2; exit 1 ;;
  esac

  ( cd $USER_HOME && mkdir -p $HOMEDIRS)
fi

chown -R "${USERNAME}:${USERNAME}" "${USER_HOME}"

install -o "${USERNAME}" -g "${USERNAME}" -m 0644 "${FEATURE_DIR}/mise.toml" "/home/${USERNAME}/.config/mise/conf.d/999-base.toml"

ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
echo "${TIMEZONE}" > /etc/timezone

cat "${FEATURE_DIR}/zshenv" >> /etc/zsh/zshenv

mkdir -p /usr/local/bin/
install -m 0755 ${FEATURE_DIR}/init-container.sh /usr/local/bin/
