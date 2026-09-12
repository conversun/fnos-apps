#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
case "${TARBALL_ARCH:-${DEB_ARCH:-amd64}}" in
  amd64) UPSTREAM_ARCH="amd64" ;;
  arm64) UPSTREAM_ARCH="arm64" ;;
  *) echo "Unsupported arch" >&2; exit 1 ;;
esac

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building FRP Server ${VERSION} for ${UPSTREAM_ARCH}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

curl -fL -o "$WORK_DIR/frp.tar.gz" \
  "https://github.com/fatedier/frp/releases/download/v${VERSION}/frp_${VERSION}_linux_${UPSTREAM_ARCH}.tar.gz"
tar -xzf "$WORK_DIR/frp.tar.gz" -C "$WORK_DIR" --strip-components=1 "frp_${VERSION}_linux_${UPSTREAM_ARCH}/frps"

mkdir -p "$WORK_DIR/app_root/bin" "$WORK_DIR/app_root/ui"
mv "$WORK_DIR/frps" "$WORK_DIR/app_root/frps"
chmod +x "$WORK_DIR/app_root/frps"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/../../../apps/frps/fnos/bin/frps-server" "$WORK_DIR/app_root/bin/frps-server"
chmod +x "$WORK_DIR/app_root/bin/frps-server"
cp -a "${SCRIPT_DIR}/../../../apps/frps/fnos/ui/"* "$WORK_DIR/app_root/ui/" 2>/dev/null || true

cd "$WORK_DIR/app_root"
tar -czf "${SCRIPT_DIR}/../../../app.tgz" .
echo "Built app.tgz for FRP Server ${VERSION}"
