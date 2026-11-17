#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

ARCH=""
VERSION="${FNVISTA_VERSION:-latest}"
OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT/dist}"
while [ "$#" -gt 0 ]; do
    case "$1" in
        --arch) ARCH="${2:?--arch 需要 x86 或 arm}"; shift 2 ;;
        --arch=*) ARCH="${1#*=}"; shift ;;
        -h|--help)
            echo "用法: $0 [--arch x86|arm] [版本号|latest]"
            echo "构建保留原始 app.tgz 的生命周期适配包到 OUTPUT_DIR（默认 dist/）。"
            exit 0
            ;;
        -*) echo "未知选项: $1" >&2; exit 1 ;;
        *) VERSION="$1"; shift ;;
    esac
done
if [ -z "$ARCH" ]; then
    case "$(uname -m)" in
        x86_64|amd64) ARCH=x86 ;;
        arm64|aarch64) ARCH=arm ;;
        *) echo "无法检测架构，请指定 --arch x86 或 arm" >&2; exit 1 ;;
    esac
fi
case "$ARCH" in
    x86|arm) ;;
    *) echo "不支持的架构: $ARCH" >&2; exit 1 ;;
esac
if [ "$VERSION" = latest ]; then
    VERSION="$(bash "$REPO_ROOT/scripts/apps/fnvista/get-latest-version.sh")"
else
    VERSION="$(bash "$REPO_ROOT/scripts/apps/fnvista/get-latest-version.sh" "$VERSION")"
fi
VERSION="${VERSION#VERSION=}"
export ARCH VERSION OUTPUT_DIR
exec bash "$REPO_ROOT/scripts/apps/fnvista/build.sh"
