#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/meta.env"

VERSION="${VERSION:-latest}"
WORK_DIR=$(mktemp -d)
trap "rm -rf $WORK_DIR" EXIT

mkdir -p "${WORK_DIR}/docker"
cp "${SCRIPT_DIR}/../../../apps/astrbot/fnos/docker/docker-compose.yaml" "${WORK_DIR}/docker/"
IMAGE_TAG="v${VERSION}"
[ "$VERSION" = "latest" ] && IMAGE_TAG="latest"
if sed --version >/dev/null 2>&1; then
    sed -i "s/v\${VERSION}/${IMAGE_TAG}/g" "${WORK_DIR}/docker/docker-compose.yaml"
else
    sed -i '' "s/v\${VERSION}/${IMAGE_TAG}/g" "${WORK_DIR}/docker/docker-compose.yaml"
fi

cp -a "${SCRIPT_DIR}/../../../apps/astrbot/fnos/ui" "${WORK_DIR}/ui"

cd "${WORK_DIR}"
tar czf "${SCRIPT_DIR}/../../../app.tgz" docker/ ui/

echo "Built app.tgz for astrbot ${VERSION}"
