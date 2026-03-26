#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building 1Panel ${VERSION} for ${ZIP_ARCH}"

case "$ZIP_ARCH" in
  amd64|x86_64)
    PANEL_ARCH="amd64"
    ;;
  arm64|aarch64)
    PANEL_ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ZIP_ARCH" >&2
    exit 1
    ;;
esac

DOWNLOAD_URL="https://resource.1panel.pro/v2/stable/v${VERSION}/release/1panel-v${VERSION}-linux-${PANEL_ARCH}.tar.gz"
curl -fL -o 1panel.tar.gz "$DOWNLOAD_URL"

tar -xzf 1panel.tar.gz

mkdir -p app_root/bin app_root/ui
PANEL_BIN=$(find . -name "1panel" -type f | head -1)
[ -z "$PANEL_BIN" ] && { echo "1panel binary not found in tarball" >&2; exit 1; }

cp "$PANEL_BIN" app_root/1panel
chmod +x app_root/1panel

cp apps/1panel/fnos/bin/1panel-server app_root/bin/1panel-server
chmod +x app_root/bin/1panel-server
cp -a apps/1panel/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
