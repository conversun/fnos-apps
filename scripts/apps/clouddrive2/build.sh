#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/meta.env"

VERSION="${VERSION:-}"
[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

mkdir -p "${WORK_DIR}/docker"
cp "${SCRIPT_DIR}/../../../apps/clouddrive2/fnos/docker/docker-compose.yaml" "${WORK_DIR}/docker/"
sed -i.bak "s/\${VERSION}/${VERSION}/g" "${WORK_DIR}/docker/docker-compose.yaml"
rm -f "${WORK_DIR}/docker/docker-compose.yaml.bak"

cp -a "${SCRIPT_DIR}/../../../apps/clouddrive2/fnos/ui" "${WORK_DIR}/ui"

cd "$WORK_DIR"
tar czf "${SCRIPT_DIR}/../../../app.tgz" docker/ ui/

echo "Built app.tgz for ${RELEASE_TITLE} ${VERSION}"
