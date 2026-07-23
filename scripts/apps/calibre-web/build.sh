#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$(cd "${SCRIPT_DIR}/../../../apps/calibre-web/fnos" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
VERSION="${VERSION:-${1:-latest}}"
WORK_DIR="$(mktemp -d)"

trap 'rm -rf "${WORK_DIR}"' EXIT

mkdir -p "${WORK_DIR}/docker"
sed "s/\${VERSION}/${VERSION}/g" "${APP_DIR}/docker/docker-compose.yaml" > "${WORK_DIR}/docker/docker-compose.yaml"
cp -a "${APP_DIR}/ui" "${WORK_DIR}/ui"

tar -czf "${REPO_ROOT}/app.tgz" -C "${WORK_DIR}" docker ui
