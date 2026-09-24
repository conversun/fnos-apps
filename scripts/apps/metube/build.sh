#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/meta.env"

# Version must be a real dated Docker Hub tag (e.g. 2026.09.23): the compose
# pins the image to :${VERSION} at build time (follow-up hardening to #310).
# CI exports VERSION; a local bare build resolves it via get-latest-version.sh.
if [ -z "${VERSION:-}" ]; then
  VERSION="$(bash "${SCRIPT_DIR}/get-latest-version.sh" | cut -d= -f2)"
fi
WORK_DIR=$(mktemp -d)
trap 'rm -rf $WORK_DIR' EXIT

mkdir -p "${WORK_DIR}/docker"
cp "${SCRIPT_DIR}/../../../apps/metube/fnos/docker/docker-compose.yaml" "${WORK_DIR}/docker/"
# Bake the dated tag into the shipped compose so manual (non-store) installs
# resolve a pullable image too. This exact sed form is mandated: see the
# version-substitution pitfall in AGENTS.md.
sed -i.bak "s/\${VERSION}/${VERSION}/g" "${WORK_DIR}/docker/docker-compose.yaml"
rm -f "${WORK_DIR}/docker/docker-compose.yaml.bak"

cp -a "${SCRIPT_DIR}/../../../apps/metube/fnos/ui" "${WORK_DIR}/ui"

cd "${WORK_DIR}"
tar czf "${SCRIPT_DIR}/../../../app.tgz" docker/ ui/

echo "Built app.tgz for metube ${VERSION}"
