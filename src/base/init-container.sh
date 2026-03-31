#!/bin/bash
set -euo pipefail

rm -Rf ~/.gnupg

mise trust
eval "$(mise activate bash)"

mise install --yes

sudo /usr/local/sbin/init-firewall.sh
