#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./meta.env
source "$SCRIPT_DIR/meta.env"

TAG="${1:-$UPSTREAM_VERSION}"
VERSION="${UPSTREAM_VERSION}-${PACKAGING_REVISION}"
case "${TAG#v}" in
    "$UPSTREAM_VERSION"|"$VERSION") ;;
    *) echo "未经适配验证的飞牛视野版本: $TAG" >&2; exit 1 ;;
esac

echo "VERSION=$VERSION"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
