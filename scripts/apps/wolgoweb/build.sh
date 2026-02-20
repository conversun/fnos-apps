#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building WolGoWeb ${VERSION} for ${ZIP_ARCH}"

# WolGoWeb distributes raw binaries (no archive), tag uses uppercase V
DOWNLOAD_URL="https://github.com/xiaoxinpro/WolGoWeb/releases/download/V${VERSION}/WolGoWeb_linux_${ZIP_ARCH}"
curl -L -o WolGoWeb_linux_${ZIP_ARCH} "$DOWNLOAD_URL"
chmod +x WolGoWeb_linux_${ZIP_ARCH}

mkdir -p app_root/bin app_root/ui

cp WolGoWeb_linux_${ZIP_ARCH} app_root/
cp apps/wolgoweb/fnos/bin/wolgoweb-server app_root/bin/wolgoweb-server
chmod +x app_root/bin/wolgoweb-server
cp -a apps/wolgoweb/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
