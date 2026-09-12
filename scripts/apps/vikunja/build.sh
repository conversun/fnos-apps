#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
case "${TARBALL_ARCH:-${DEB_ARCH:-amd64}}" in
  amd64) UPSTREAM_ARCH="amd64" ;;
  arm64) UPSTREAM_ARCH="arm64" ;;
  *) echo "Unsupported arch" >&2; exit 1 ;;
esac

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Vikunja ${VERSION} for ${UPSTREAM_ARCH}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# The "-full" zip carries the binary with the web frontend embedded; releases
# also publish rebranded "veans-*" twins we deliberately do not use.
curl -fL -o "$WORK_DIR/vikunja.zip" \
  "https://github.com/go-vikunja/vikunja/releases/download/v${VERSION}/vikunja-v${VERSION}-linux-${UPSTREAM_ARCH}-full.zip"
unzip -qo "$WORK_DIR/vikunja.zip" -d "$WORK_DIR"

BIN=$(find "$WORK_DIR" -maxdepth 1 -name "vikunja-v${VERSION}-linux-${UPSTREAM_ARCH}" -type f | head -1)
[ -z "$BIN" ] && { echo "vikunja binary not found in archive" >&2; exit 1; }

mkdir -p "$WORK_DIR/app_root/bin" "$WORK_DIR/app_root/ui"
cp "$BIN" "$WORK_DIR/app_root/vikunja"
chmod +x "$WORK_DIR/app_root/vikunja"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/../../../apps/vikunja/fnos/bin/vikunja-server" "$WORK_DIR/app_root/bin/vikunja-server"
chmod +x "$WORK_DIR/app_root/bin/vikunja-server"
cp -a "${SCRIPT_DIR}/../../../apps/vikunja/fnos/ui/"* "$WORK_DIR/app_root/ui/" 2>/dev/null || true

cd "$WORK_DIR/app_root"
tar -czf "${SCRIPT_DIR}/../../../app.tgz" .
echo "Built app.tgz for Vikunja ${VERSION}"
