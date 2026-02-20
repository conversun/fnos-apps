#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Gotify ${VERSION} for ${ZIP_ARCH}"

# Gotify distributes zip archives containing the binary
DOWNLOAD_URL="https://github.com/gotify/server/releases/download/v${VERSION}/gotify-linux-${ZIP_ARCH}.zip"
curl -L -o gotify-linux-${ZIP_ARCH}.zip "$DOWNLOAD_URL"
unzip -o gotify-linux-${ZIP_ARCH}.zip -d gotify-extract
chmod +x gotify-extract/gotify-linux-${ZIP_ARCH}

mkdir -p app_root/bin app_root/ui

cp gotify-extract/gotify-linux-${ZIP_ARCH} app_root/
cp apps/gotify/fnos/bin/gotify-server app_root/bin/gotify-server
chmod +x app_root/bin/gotify-server
cp -a apps/gotify/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
