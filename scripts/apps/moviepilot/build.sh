#!/bin/bash
set -euo pipefail

VERSION="${1:-${VERSION:-}}"

[ -z "${VERSION}" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building MoviePilot ${VERSION} (uses fnOS system python312)"

SRC_URL="https://github.com/jxxghp/MoviePilot/archive/v${VERSION}.tar.gz"
curl -L -o moviepilot-src.tar.gz "$SRC_URL"
tar xzf moviepilot-src.tar.gz

dst=app_root
mkdir -p "$dst/bin" "$dst/config" "$dst/ui/images"

cp -r MoviePilot-${VERSION}/* "$dst/"

cp apps/moviepilot/fnos/bin/moviepilot-server "$dst/bin/moviepilot-server"
chmod +x "$dst/bin/moviepilot-server"

cp -a apps/moviepilot/fnos/ui/* "$dst/ui/" 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
