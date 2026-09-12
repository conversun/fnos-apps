#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
case "${TARBALL_ARCH:-${DEB_ARCH:-amd64}}" in
  amd64) UPSTREAM_ARCH="amd64" ;;
  arm64) UPSTREAM_ARCH="arm64" ;;
  *) echo "Unsupported arch" >&2; exit 1 ;;
esac

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Pocket ID ${VERSION} for ${UPSTREAM_ARCH}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

curl -fL -o "$WORK_DIR/pocket-id" \
  "https://github.com/pocket-id/pocket-id/releases/download/v${VERSION}/pocket-id_linux_${UPSTREAM_ARCH}"
chmod +x "$WORK_DIR/pocket-id"

mkdir -p "$WORK_DIR/app_root/bin" "$WORK_DIR/app_root/ui"
cp "$WORK_DIR/pocket-id" "$WORK_DIR/app_root/pocket-id"
chmod +x "$WORK_DIR/app_root/pocket-id"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/../../../apps/pocket-id/fnos/bin/pocket-id-server" "$WORK_DIR/app_root/bin/pocket-id-server"
chmod +x "$WORK_DIR/app_root/bin/pocket-id-server"
cp -a "${SCRIPT_DIR}/../../../apps/pocket-id/fnos/ui/"* "$WORK_DIR/app_root/ui/" 2>/dev/null || true

cd "$WORK_DIR/app_root"
tar -czf "${SCRIPT_DIR}/../../../app.tgz" .
echo "Built app.tgz for Pocket ID ${VERSION}"
