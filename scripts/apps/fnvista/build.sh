#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck source=./meta.env
source "$SCRIPT_DIR/meta.env"

ARCH="${ARCH:-${1:-}}"
case "$ARCH" in x86|arm) ;; *) echo "需要 ARCH=x86 或 arm" >&2; exit 1 ;; esac
VERSION="$(bash "$SCRIPT_DIR/get-latest-version.sh" "${VERSION:-$UPSTREAM_VERSION}")"
VERSION="${VERSION#VERSION=}"
OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT/dist}"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fnvista-build.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT
mkdir -p "$WORK_DIR/package" "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
if [ -n "${FNVISTA_UPSTREAM_FPK:-}" ]; then
    cp "$FNVISTA_UPSTREAM_FPK" "$WORK_DIR/upstream.fpk"
else
    curl -fL --retry 5 --retry-delay 5 --retry-all-errors --connect-timeout 30 \
        -o "$WORK_DIR/upstream.fpk" \
        "https://github.com/mclhm8182/FnVista/releases/download/v${UPSTREAM_VERSION}/FnVista-${UPSTREAM_VERSION}.fpk"
fi
ACTUAL_SHA="$(shasum -a 256 "$WORK_DIR/upstream.fpk" | awk '{print $1}')"
[ "$ACTUAL_SHA" = "$UPSTREAM_FPK_SHA256" ] || { echo "上游 FPK SHA256 不符" >&2; exit 1; }
tar xzf "$WORK_DIR/upstream.fpk" -C "$WORK_DIR/package"
tar tzf "$WORK_DIR/package/app.tgz" >/dev/null
mv "$WORK_DIR/package/cmd/uninstall_callback" "$WORK_DIR/package/cmd/uninstall_upstream"
mv "$WORK_DIR/package/cmd/main" "$WORK_DIR/package/cmd/main_upstream"
cp "$REPO_ROOT/apps/fnvista/fnos/cmd/main" "$WORK_DIR/package/cmd/"
cp "$REPO_ROOT/apps/fnvista/fnos/cmd/uninstall_callback" "$WORK_DIR/package/cmd/"
cp "$REPO_ROOT/apps/fnvista/fnos/cmd/uninstall-quiesce" "$WORK_DIR/package/cmd/"
chmod 755 "$WORK_DIR/package/cmd/main" "$WORK_DIR/package/cmd/uninstall_callback" "$WORK_DIR/package/cmd/uninstall-quiesce"
sed -i.bak "s/^version[[:space:]]*=.*/version                    = $VERSION/" "$WORK_DIR/package/manifest"
rm "$WORK_DIR/package/manifest.bak"
cp "$REPO_ROOT/apps/fnvista/LICENSE" "$WORK_DIR/package/LICENSE"
FPK_FINAL="$OUTPUT_DIR/${FILE_PREFIX}_${VERSION}_${ARCH}.fpk"
(cd "$WORK_DIR/package" && COPYFILE_DISABLE=1 tar czf "$FPK_FINAL" -- *)
echo "已构建飞牛视野（上游 ${UPSTREAM_VERSION}，本地 ${PACKAGING_REVISION}）: $FPK_FINAL"
