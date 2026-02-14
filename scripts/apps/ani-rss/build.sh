#!/bin/bash
set -euo pipefail

VERSION="${1:-${VERSION:-}}"

[ -z "${VERSION}" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building ani-rss ${VERSION} (uses fnOS system java-17-openjdk)"

JAR_URL="https://github.com/wushuo894/ani-rss/releases/download/v${VERSION}/ani-rss-jar-with-dependencies.jar"
curl -L -o ani-rss.jar "$JAR_URL"

dst=app_root
mkdir -p "$dst/bin" "$dst/config" "$dst/ui/images"

cp ani-rss.jar "$dst/ani-rss-jar-with-dependencies.jar"

cp apps/ani-rss/fnos/bin/ani-rss-server "$dst/bin/ani-rss-server"
chmod +x "$dst/bin/ani-rss-server"

cp -a apps/ani-rss/fnos/ui/* "$dst/ui/" 2>/dev/null || true

cd app_root
tar -czf ../app.tgz .
