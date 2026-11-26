#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/gh-api.sh
source "$SCRIPT_DIR/../../lib/gh-api.sh"

if [ -n "${1:-}" ]; then
    VERSION="${1#v}"
else
    TAG="$(gh_latest_tag "yanghy949/suiyan-ledger")"
    VERSION="${TAG#v}"
fi

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "无法获取随言记账的正式版本号" >&2
    exit 1
fi

echo "VERSION=$VERSION"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
