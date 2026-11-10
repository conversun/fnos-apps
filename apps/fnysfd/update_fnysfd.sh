#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ARCH="${ARCH:-$(uname -m)}"
VERSION="${FNYSFD_VERSION:-latest}"
while [ "$#" -gt 0 ]; do
    case "$1" in
        --arch) ARCH="${2:?--arch 需要指定 x86}"; shift 2 ;;
        --arch=*) ARCH="${1#*=}"; shift ;;
        -h|--help)
            echo "用法：$0 [--arch x86] [版本号|latest]（不支持 ARM）"
            exit 0 ;;
        -*) echo "未知选项：$1" >&2; exit 1 ;;
        *) VERSION="$1"; shift ;;
    esac
done
case "$ARCH" in
    x86|amd64|x86_64) ;;
    *) echo "飞牛影视反代原生包仅支持 x86，不支持 ${ARCH}。" >&2; exit 1 ;;
esac

RESOLVED="$(bash "$REPO_ROOT/scripts/apps/fnysfd/get-latest-version.sh" "$VERSION")"
VERSION="${RESOLVED#VERSION=}"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/fnysfd-update.XXXXXX")"
trap 'rm -rf "$WORK_DIR"' EXIT
OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT/dist}"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"
(
    cd "$WORK_DIR"
    VERSION="$VERSION" ARCH=x86 bash "$REPO_ROOT/scripts/apps/fnysfd/build.sh"
    bash "$REPO_ROOT/scripts/build-fpk.sh" "$SCRIPT_DIR" "$WORK_DIR/app.tgz" "$VERSION" x86
)
mv "$WORK_DIR/fnysfd_${VERSION}_x86.fpk" "$OUTPUT_DIR/"
echo "已生成：${OUTPUT_DIR}/fnysfd_${VERSION}_x86.fpk"
