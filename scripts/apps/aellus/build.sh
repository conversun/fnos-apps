#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"
# Upstream asset arch names: aellus-linux-x86_64 / aellus-linux-arm64.
case "${TARBALL_ARCH:-${DEB_ARCH:-amd64}}" in
  amd64) UPSTREAM_ARCH="x86_64" ;;
  arm64) UPSTREAM_ARCH="arm64" ;;
  *) echo "Unsupported arch" >&2; exit 1 ;;
esac

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Aellus ${VERSION} for ${UPSTREAM_ARCH}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# Bare static Go ELF binary, no archive wrapper.
curl -fL -o "$WORK_DIR/aellus" \
  "https://github.com/YGQ8988/Aellus/releases/download/${VERSION}/aellus-linux-${UPSTREAM_ARCH}"
chmod +x "$WORK_DIR/aellus"

mkdir -p "$WORK_DIR/app_root/bin" "$WORK_DIR/app_root/ui"

cp "$WORK_DIR/aellus" "$WORK_DIR/app_root/aellus"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/../../apps/aellus/fnos/bin/aellus-server" "$WORK_DIR/app_root/bin/aellus-server"
chmod +x "$WORK_DIR/app_root/bin/aellus-server"
cp -a "${SCRIPT_DIR}/../../apps/aellus/fnos/ui/"* "$WORK_DIR/app_root/ui/" 2>/dev/null || true

cd "$WORK_DIR/app_root"
tar -czf "${SCRIPT_DIR}/../../app.tgz" .
echo "Built app.tgz for Aellus ${VERSION} (${UPSTREAM_ARCH})"
