#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

VERSION="${VERSION:-}"
TARBALL_ARCH="${TARBALL_ARCH:-${DEB_ARCH:-amd64}}"
NODE_VERSION="${NODE_VERSION:-22.11.0}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building Feigram ${VERSION} for ${TARBALL_ARCH}"

case "$TARBALL_ARCH" in
  amd64) NODE_ARCH="x64" ;;
  arm64) NODE_ARCH="arm64" ;;
  *) echo "Unsupported TARBALL_ARCH=${TARBALL_ARCH}" >&2; exit 1 ;;
esac

SOURCE_TAG="Feigram${VERSION}"
SOURCE_URL="https://github.com/g-star1024/Feigram-Public/archive/refs/tags/${SOURCE_TAG}.tar.gz"
NODE_ARCHIVE="node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz"
NODE_URL="https://nodejs.org/dist/v${NODE_VERSION}/${NODE_ARCHIVE}"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

curl -fL -o "${WORK_DIR}/source.tar.gz" "$SOURCE_URL"
mkdir -p "${WORK_DIR}/source"
tar -xzf "${WORK_DIR}/source.tar.gz" -C "${WORK_DIR}/source" --strip-components=1

curl -fL -o "${WORK_DIR}/${NODE_ARCHIVE}" "$NODE_URL"
mkdir -p "${WORK_DIR}/node"
tar -xJf "${WORK_DIR}/${NODE_ARCHIVE}" -C "${WORK_DIR}/node" --strip-components=1

npm --prefix "${WORK_DIR}/source/client" ci
npm --prefix "${WORK_DIR}/source/client" run build
rm -rf "${WORK_DIR}/source/server/public"
cp -R "${WORK_DIR}/source/client/dist" "${WORK_DIR}/source/server/public"
npm --prefix "${WORK_DIR}/source/server" ci --omit=dev

mkdir -p "${WORK_DIR}/app_root/bin" "${WORK_DIR}/app_root/ui" "${WORK_DIR}/app_root/server"
cp "${WORK_DIR}/node/bin/node" "${WORK_DIR}/app_root/bin/node"
chmod +x "${WORK_DIR}/app_root/bin/node"

cp "${REPO_ROOT}/apps/feigram/fnos/bin/feigram-server" "${WORK_DIR}/app_root/bin/feigram-server"
chmod +x "${WORK_DIR}/app_root/bin/feigram-server"
cp -a "${REPO_ROOT}/apps/feigram/fnos/ui"/* "${WORK_DIR}/app_root/ui/" 2>/dev/null || true

cp "${WORK_DIR}/source/server/package.json" "${WORK_DIR}/source/server/package-lock.json" "${WORK_DIR}/app_root/server/"
cp -R "${WORK_DIR}/source/server/src" "${WORK_DIR}/source/server/public" "${WORK_DIR}/source/server/node_modules" "${WORK_DIR}/app_root/server/"

tar -czf "${REPO_ROOT}/app.tgz" -C "${WORK_DIR}/app_root" .
echo "Built app.tgz for Feigram ${VERSION} (${TARBALL_ARCH})"
