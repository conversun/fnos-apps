#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Certimate ${VERSION} for ${ZIP_ARCH}"

# Map architecture names
case "$ZIP_ARCH" in
  amd64|x86_64)
    CERTIMATE_ARCH="amd64"
    ;;
  arm64|aarch64)
    CERTIMATE_ARCH="arm64"
    ;;
  *)
    echo "Unsupported architecture: $ZIP_ARCH" >&2
    exit 1
    ;;
esac

DOWNLOAD_URL="https://github.com/certimate-go/certimate/releases/download/v${VERSION}/certimate_v${VERSION}_linux_${CERTIMATE_ARCH}.zip"
curl -L -o certimate.zip "$DOWNLOAD_URL"

unzip -o certimate.zip

mkdir -p app_root/bin app_root/ui
CERTIMATE_BIN=$(find . -name "certimate" -type f | head -1)
[ -z "$CERTIMATE_BIN" ] && { echo "certimate binary not found in zip" >&2; exit 1; }

cp "$CERTIMATE_BIN" app_root/certimate
chmod +x app_root/certimate

cp apps/certimate/fnos/bin/certimate-server app_root/bin/certimate-server
chmod +x app_root/bin/certimate-server
cp -a apps/certimate/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
