#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../scripts/apps/faststrm/meta.env
source "$REPO_ROOT/scripts/apps/faststrm/meta.env"

ARCH=""
VERSION="${FASTSTRM_VERSION:-latest}"
OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT/dist}"
while [ "$#" -gt 0 ]; do
    case "$1" in
        --arch)
            ARCH="${2:?--arch 需要 x86 或 arm}"
            shift 2
            ;;
        --arch=*) ARCH="${1#*=}"; shift ;;
        -h|--help)
            echo "用法: $0 [--arch x86|arm] [版本号|latest]"
            echo "下载原始官方 FPK 到 OUTPUT_DIR（默认 dist/），不重打包。"
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
    x86) ASSET_TEMPLATE="$OFFICIAL_FPK_ASSET_x86" ;;
    arm) ASSET_TEMPLATE="$OFFICIAL_FPK_ASSET_arm" ;;
    *) echo "不支持的架构: $ARCH" >&2; exit 1 ;;
esac

if [ "$VERSION" = latest ]; then
    VERSION="$(bash "$REPO_ROOT/scripts/apps/faststrm/get-latest-version.sh")"
    VERSION="${VERSION#VERSION=}"
else
    VERSION="${VERSION#v}"
fi
ASSET="${ASSET_TEMPLATE//\$\{VERSION\}/$VERSION}"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
curl -fL --retry 5 --retry-delay 5 --retry-all-errors --connect-timeout 30 \
    -o "$WORK_DIR/official.fpk" \
    "https://github.com/${OFFICIAL_FPK_REPO}/releases/download/${OFFICIAL_FPK_TAG_PREFIX}${VERSION}/${ASSET}"
tar tzf "$WORK_DIR/official.fpk" >/dev/null
mkdir -p "$OUTPUT_DIR"
FPK_FINAL="$OUTPUT_DIR/${FILE_PREFIX}_${VERSION}_${ARCH}.fpk"
mv "$WORK_DIR/official.fpk" "$FPK_FINAL"
echo "官方 FPK 已保存（未经修改）: $FPK_FINAL"
