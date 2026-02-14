#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
DEB_ARCH="${DEB_ARCH:-amd64}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

# Map Debian arch to Kavita download arch
case "$DEB_ARCH" in
  amd64) KAVITA_ARCH="x64" ;;
  arm64) KAVITA_ARCH="arm64" ;;
  *) echo "Unsupported architecture: $DEB_ARCH" >&2; exit 1 ;;
esac

echo "==> Building Kavita ${VERSION} for ${KAVITA_ARCH}"

DOWNLOAD_URL="https://github.com/Kareadita/Kavita/releases/download/v${VERSION}/kavita-linux-${KAVITA_ARCH}.tar.gz"
curl -L -o kavita.tar.gz "$DOWNLOAD_URL"

mkdir -p extracted
tar -xzf kavita.tar.gz -C extracted

mkdir -p app_root/bin app_root/ui

# Kavita extracts to a Kavita/ directory with self-contained .NET runtime
KAVITA_BIN=$(find extracted -name "Kavita" -type f | head -1)
[ -z "$KAVITA_BIN" ] && { echo "Kavita binary not found in archive" >&2; exit 1; }
KAVITA_DIR=$(dirname "$KAVITA_BIN")

cp -a "$KAVITA_DIR"/* app_root/
chmod +x app_root/Kavita

cp apps/kavita/fnos/bin/kavita-server app_root/bin/kavita-server
chmod +x app_root/bin/kavita-server
cp -a apps/kavita/fnos/ui/* app_root/ui/ 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
