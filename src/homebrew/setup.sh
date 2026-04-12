#!/bin/bash
set -euo pipefail

mkdir -p "${HOMEBREW_PREFIX}/Homebrew" "${HOMEBREW_PREFIX}/bin"

curl -fsSL "https://github.com/Homebrew/brew/archive/refs/tags/${BREW_VERSION}.tar.gz" | \
  tar -xz --strip-components=1 -C "${HOMEBREW_PREFIX}/Homebrew"

ln -s ../Homebrew/bin/brew "${HOMEBREW_PREFIX}/bin/brew"
