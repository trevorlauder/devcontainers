#!/bin/bash
set -euo pipefail

chown -R "${USERNAME}":"${USERNAME}" /home/linuxbrew

setpriv --reuid="${USERNAME}" --regid="${USERNAME}" --init-groups -- brew install ${PACKAGES}
