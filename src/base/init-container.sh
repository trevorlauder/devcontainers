#!/bin/bash
set -euo pipefail

post_init_cmd=/usr/local/bin/post-init.sh

rm -Rf ~/.gnupg

mise trust
eval "$(mise activate bash)"

mise install --yes

if command -v ${post_init_cmd}; then
  ${post_init_cmd}
fi
