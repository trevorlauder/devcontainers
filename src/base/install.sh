#!/bin/bash
set -euo pipefail

USERNAME="vscode"
FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"
HOME_DIR="/home/${USERNAME}"
SHELL="/usr/bin/zsh"

ARCH="$(dpkg --print-architecture)"

apt-get update -y
apt-get install -y --no-install-recommends ca-certificates

install -dm 755 /etc/apt/keyrings
install -m 0644 "${FEATURE_DIR}/mise-gpg-key.pub" /etc/apt/keyrings/mise-archive-keyring.asc
install -m 0644 "${FEATURE_DIR}/mise.list" /etc/apt/sources.list.d/mise.list

apt-get update -y
apt-get install -y --no-install-recommends \
    mise \
    cosign \
    curl \
    less \
    procps \
    sudo \
    dnsutils \
    gnupg2 \
    openssh-client \
    zsh \
    jq \
    iptables \
    aggregate \
    ipset \
    iproute2 \
    git \
    vim

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

userdel -r app 2>/dev/null || true
groupdel app 2>/dev/null || true

if ! id "${USERNAME}" &>/dev/null; then
    groupadd --gid 1000 "${USERNAME}"
    useradd --uid 1000 --gid 1000 --shell "${SHELL}" --create-home "${USERNAME}"
fi

install -m 0440 "${FEATURE_DIR}/sudoers" /etc/sudoers.d/${USERNAME}

git clone --depth 1 https://github.com/tarjoilija/zgen.git "${HOME_DIR}/.zgen"
rm -rf "${HOME_DIR}/.zgen/.git"

mkdir -p \
    /workspace \
    /commandhistory \
    "${HOME_DIR}/.claude" \
    "${HOME_DIR}/.config/mise" \
    "${HOME_DIR}/.local/share/mise" \
    "${HOME_DIR}/.rustup" \
    "${HOME_DIR}/.cargo"

chown -R "${USERNAME}:${USERNAME}" \
    /workspace \
    /commandhistory \
    "${HOME_DIR}"

echo "export TZ=${TIMEZONE}" > /etc/profile.d/devcontainer-base.sh

install -m 0755 ${FEATURE_DIR}/init-container.sh /usr/local/bin/
install -m 0744 ${FEATURE_DIR}/init-firewall.sh /usr/local/sbin/
install -m 0644 ${FEATURE_DIR}/firewall-fqdns.txt /usr/local/etc/
