#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Sun-Panel ${VERSION} for ${ZIP_ARCH}"

# Map architecture names
case "$ZIP_ARCH" in
  amd64|x86_64)
    UPSTREAM_ARCH="amd64"
    ;;
  arm64|aarch64)
    UPSTREAM_ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ZIP_ARCH" >&2
    exit 1
    ;;
esac

DOWNLOAD_URL="https://github.com/hslr-s/sun-panel/releases/download/v${VERSION}/sun-panel_v${VERSION}_linux_${UPSTREAM_ARCH}.tar.gz"
curl -L -o sun-panel.tar.gz "$DOWNLOAD_URL"

tar -xzf sun-panel.tar.gz

mkdir -p app_root
SUNPANEL_DIR=$(find . -maxdepth 1 -type d -name "sun-panel_v${VERSION}_linux_${UPSTREAM_ARCH}" | head -1)
[ -z "$SUNPANEL_DIR" ] && { echo "sun-panel directory not found in archive" >&2; exit 1; }

# Copy binary and web assets
cp "$SUNPANEL_DIR/sun-panel" app_root/sun-panel
chmod +x app_root/sun-panel
cp -r "$SUNPANEL_DIR/web" app_root/web

# Copy launcher script and UI config
mkdir -p app_root/bin app_root/ui
cp apps/sun-panel/fnos/bin/sun-panel-server app_root/bin/sun-panel-server
chmod +x app_root/bin/sun-panel-server
cp -a apps/sun-panel/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
