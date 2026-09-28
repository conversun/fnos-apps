#!/bin/bash
set -euo pipefail

# Official-fpk passthrough: meta.env declares OFFICIAL_FPK_REPO, so CI
# downloads the upstream's own fnOS package directly and never runs this
# script. There is no fallback: this app exists only as passthrough.
echo "[ERROR] pushme-server is an official-fpk passthrough app; local builds are not supported." >&2
exit 1
