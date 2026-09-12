#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
case "${TARBALL_ARCH:-${DEB_ARCH:-amd64}}" in
  amd64) UPSTREAM_ARCH="amd64" ;;
  arm64) UPSTREAM_ARCH="arm64v8" ;;
  *) echo "Unsupported arch" >&2; exit 1 ;;
esac

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building RustDesk Server ${VERSION} for ${UPSTREAM_ARCH}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

curl -fL -o "$WORK_DIR/rustdesk.zip" \
  "https://github.com/rustdesk/rustdesk-server/releases/download/${VERSION}/rustdesk-server-linux-${UPSTREAM_ARCH}.zip"
unzip -qo "$WORK_DIR/rustdesk.zip" -d "$WORK_DIR/extracted"

# The zip nests binaries under an arch dir (amd64/, arm64v8/, aarch64/...).
HBBR_BIN=$(find "$WORK_DIR/extracted" -name hbbr -type f | head -1)
HBBS_BIN=$(find "$WORK_DIR/extracted" -name hbbs -type f | head -1)
[ -z "$HBBR_BIN" ] || [ -z "$HBBS_BIN" ] && { echo "hbbs/hbbr not found in archive" >&2; exit 1; }

mkdir -p "$WORK_DIR/app_root/bin" "$WORK_DIR/app_root/ui"
cp "$HBBS_BIN" "$WORK_DIR/app_root/hbbs"
cp "$HBBR_BIN" "$WORK_DIR/app_root/hbbr"
chmod +x "$WORK_DIR/app_root/hbbs" "$WORK_DIR/app_root/hbbr"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/../../../apps/rustdesk-server/fnos/bin/hbbs-wrapper" "$WORK_DIR/app_root/bin/hbbs-wrapper"
cp "${SCRIPT_DIR}/../../../apps/rustdesk-server/fnos/bin/hbbr-wrapper" "$WORK_DIR/app_root/bin/hbbr-wrapper"
chmod +x "$WORK_DIR/app_root/bin/"*wrapper
cp -a "${SCRIPT_DIR}/../../../apps/rustdesk-server/fnos/ui/"* "$WORK_DIR/app_root/ui/" 2>/dev/null || true

cd "$WORK_DIR/app_root"
tar -czf "${SCRIPT_DIR}/../../../app.tgz" .
echo "Built app.tgz for RustDesk Server ${VERSION}"
