#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building DDNS-GO ${VERSION} for ${ZIP_ARCH}"

# DDNS-GO uses x86_64 instead of amd64 in release asset names
case "$ZIP_ARCH" in
  amd64) ASSET_ARCH="x86_64" ;;
  arm64) ASSET_ARCH="arm64" ;;
  *) echo "Unsupported arch: $ZIP_ARCH" >&2; exit 1 ;;
esac

DOWNLOAD_URL="https://github.com/jeessy2/ddns-go/releases/download/v${VERSION}/ddns-go_${VERSION}_linux_${ASSET_ARCH}.tar.gz"
curl -L -o ddns-go.tar.gz "$DOWNLOAD_URL"

tar -xzf ddns-go.tar.gz

mkdir -p app_root/bin app_root/ui

cp ddns-go app_root/
chmod +x app_root/ddns-go

cp apps/ddns-go/fnos/bin/ddns-go-server app_root/bin/ddns-go-server
chmod +x app_root/bin/ddns-go-server
cp -a apps/ddns-go/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
