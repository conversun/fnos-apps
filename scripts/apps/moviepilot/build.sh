#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/meta.env"

VERSION="${VERSION:-latest}"
WORK_DIR=$(mktemp -d)
trap "rm -rf $WORK_DIR" EXIT

mkdir -p "${WORK_DIR}/docker"
cp "${SCRIPT_DIR}/../../../apps/moviepilot/fnos/docker/docker-compose.yaml" "${WORK_DIR}/docker/"
sed -i "s/\${VERSION}/${VERSION}/g" "${WORK_DIR}/docker/docker-compose.yaml"

cp -a "${SCRIPT_DIR}/../../../apps/moviepilot/fnos/ui" "${WORK_DIR}/ui"

cd "${WORK_DIR}"
tar czf "${SCRIPT_DIR}/../../../app.tgz" docker/ ui/

echo "Built app.tgz for moviepilot ${VERSION}"
