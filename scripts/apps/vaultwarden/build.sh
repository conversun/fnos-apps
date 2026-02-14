#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
ZIP_ARCH="${ZIP_ARCH:-${DEB_ARCH:-amd64}}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Vaultwarden ${VERSION} for ${ZIP_ARCH}"

# Map architecture names
case "$ZIP_ARCH" in
  amd64|x86_64)
    VAULTWARDEN_ARCH="x86_64-unknown-linux-musl"
    ;;
  arm64|aarch64)
    VAULTWARDEN_ARCH="aarch64-unknown-linux-musl"
    ;;
  *)
    echo "Unsupported architecture: $ZIP_ARCH" >&2
    exit 1
    ;;
esac

DOWNLOAD_URL="https://github.com/dani-garcia/vaultwarden/releases/download/${VERSION}/vaultwarden-${VERSION}-linux-${VAULTWARDEN_ARCH}.tar.gz"
curl -L -o vaultwarden.tar.gz "$DOWNLOAD_URL"

tar -xzf vaultwarden.tar.gz

mkdir -p app_root/bin app_root/ui

# Find and copy the vaultwarden binary
VAULTWARDEN_BIN=$(find . -name "vaultwarden" -type f | head -1)
[ -z "$VAULTWARDEN_BIN" ] && { echo "vaultwarden binary not found in archive" >&2; exit 1; }

cp "$VAULTWARDEN_BIN" app_root/vaultwarden
chmod +x app_root/vaultwarden

cp apps/vaultwarden/fnos/bin/vaultwarden-server app_root/bin/vaultwarden-server
chmod +x app_root/bin/vaultwarden-server
cp -a apps/vaultwarden/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
