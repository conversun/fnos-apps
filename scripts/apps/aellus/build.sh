#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-}"

# Upstream asset names have changed across releases:
#   1.0.0:  aellus-linux-x86_64 / aellus-linux-arm64   (lowercase, no version)
#   1.0.1:  Aellus-1.0.1-linux-x86_64 / -linux-arm64
#   1.0.2+: Aellus-<v>-linux-x64 / Aellus-<v>-linux-arm64  (x86_64 renamed to x64)
# Try the newest naming first; older shapes are kept so pinned rebuilds of
# old versions still work.
case "${TARBALL_ARCH:-${DEB_ARCH:-amd64}}" in
  amd64) UPSTREAM_ARCHS=("x64" "x86_64") ;;
  arm64) UPSTREAM_ARCHS=("arm64") ;;
  *) echo "Unsupported arch" >&2; exit 1 ;;
esac

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Aellus ${VERSION} for ${TARBALL_ARCH:-${DEB_ARCH:-amd64}}"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

# Bare static Go ELF binary, no archive wrapper.
downloaded=""
for arch_name in "${UPSTREAM_ARCHS[@]}"; do
  for prefix in "Aellus-${VERSION}-" "aellus-"; do
    url="https://github.com/YGQ8988/Aellus/releases/download/${VERSION}/${prefix}linux-${arch_name}"
    if curl -fL -o "$WORK_DIR/aellus" "$url"; then
      downloaded="$url"
      break 2
    fi
  done
done
[ -n "$downloaded" ] || { echo "No linux binary asset found for Aellus ${VERSION}" >&2; exit 1; }
echo "Downloaded: $downloaded"
chmod +x "$WORK_DIR/aellus"

mkdir -p "$WORK_DIR/app_root/bin" "$WORK_DIR/app_root/ui"

cp "$WORK_DIR/aellus" "$WORK_DIR/app_root/aellus"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "${SCRIPT_DIR}/../../../apps/aellus/fnos/bin/aellus-server" "$WORK_DIR/app_root/bin/aellus-server"
chmod +x "$WORK_DIR/app_root/bin/aellus-server"
cp -a "${SCRIPT_DIR}/../../../apps/aellus/fnos/ui/"* "$WORK_DIR/app_root/ui/" 2>/dev/null || true

cd "$WORK_DIR/app_root"
tar -czf "${SCRIPT_DIR}/../../../app.tgz" .
echo "Built app.tgz for Aellus ${VERSION} (${downloaded##*/})"
