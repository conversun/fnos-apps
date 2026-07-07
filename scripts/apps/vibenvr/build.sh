#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/meta.env"

VERSION="${VERSION:-${1:-latest}}"
TARGET_ARCH="${TARBALL_ARCH:-${DEB_ARCH:-${ARCH:-amd64}}}"
case "$TARGET_ARCH" in
  amd64|x86|x86_64) ;;
  arm|arm64|aarch64)
    echo "VibeNVR upstream Docker images are linux/amd64 only; arm64 builds are intentionally disabled." >&2
    exit 1
    ;;
  *)
    echo "Unsupported architecture for VibeNVR: ${TARGET_ARCH}. Only amd64/x86 is supported." >&2
    exit 1
    ;;
esac

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

mkdir -p "${WORK_DIR}/docker"
cp "${SCRIPT_DIR}/../../../apps/vibenvr/fnos/docker/docker-compose.yaml" "${WORK_DIR}/docker/"
sed -i.bak "s/\${VERSION}/${VERSION}/g" "${WORK_DIR}/docker/docker-compose.yaml"
rm -f "${WORK_DIR}/docker/docker-compose.yaml.bak"

cp -a "${SCRIPT_DIR}/../../../apps/vibenvr/fnos/ui" "${WORK_DIR}/ui"

cd "${WORK_DIR}"
tar czf "${SCRIPT_DIR}/../../../app.tgz" docker/ ui/

echo "Built x86-only app.tgz for vibenvr ${VERSION}"
