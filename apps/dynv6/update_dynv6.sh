#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../../scripts/apps/dynv6/meta.env
source "$REPO_ROOT/scripts/apps/dynv6/meta.env"

ARCH=""
VERSION="${DYNV6_VERSION:-}"
while [ "$#" -gt 0 ]; do
    case "$1" in
        --arch)
            [ "$#" -ge 2 ] || { echo "--arch 需要 x86 或 arm" >&2; exit 1; }
            ARCH="$2"
            shift 2
            ;;
        -h|--help)
            echo "用法: $0 [--arch x86|arm] [版本号]"
            echo "下载并校验官方 FPK，保存到当前目录；不重打包。"
            exit 0
            ;;
        -*)
            echo "未知参数: $1" >&2
            exit 1
            ;;
        *)
            VERSION="$1"
            shift
            ;;
    esac
done

if [ -z "$ARCH" ]; then
    case "$(uname -m)" in
        x86_64|amd64) ARCH=x86 ;;
        aarch64|arm64) ARCH=arm ;;
        *) echo "不支持的架构，请指定 --arch x86 或 arm" >&2; exit 1 ;;
    esac
fi
case "$ARCH" in
    x86) ASSET_TEMPLATE="$OFFICIAL_FPK_ASSET_x86" ;;
    arm) ASSET_TEMPLATE="$OFFICIAL_FPK_ASSET_arm" ;;
    *) echo "不支持的架构: $ARCH" >&2; exit 1 ;;
esac

if [ -z "$VERSION" ] || [ "$VERSION" = latest ]; then
    VERSION="$(bash "$REPO_ROOT/scripts/apps/dynv6/get-latest-version.sh")"
    VERSION="${VERSION#VERSION=}"
fi
VERSION="${VERSION#v}"
ASSET="${ASSET_TEMPLATE//\$\{VERSION\}/$VERSION}"
BASE_URL="https://github.com/$OFFICIAL_FPK_REPO/releases/download/$OFFICIAL_FPK_TAG_PREFIX$VERSION"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

curl -fL --retry 5 --retry-delay 5 --retry-all-errors --connect-timeout 30 \
    -o "$WORK_DIR/$ASSET" "$BASE_URL/$ASSET"
curl -fL --retry 5 --retry-delay 5 --retry-all-errors --connect-timeout 30 \
    -o "$WORK_DIR/SHA256SUMS.txt" "$BASE_URL/SHA256SUMS.txt"
EXPECTED="$(awk -v asset="$ASSET" '$2 == asset {print $1}' "$WORK_DIR/SHA256SUMS.txt")"
[ -n "$EXPECTED" ] || { echo "官方校验文件未包含 $ASSET" >&2; exit 1; }
if command -v sha256sum >/dev/null 2>&1; then
    ACTUAL="$(sha256sum "$WORK_DIR/$ASSET" | awk '{print $1}')"
else
    ACTUAL="$(shasum -a 256 "$WORK_DIR/$ASSET" | awk '{print $1}')"
fi
[ "$ACTUAL" = "$EXPECTED" ] || { echo "官方 FPK SHA256 校验失败" >&2; exit 1; }
tar -tzf "$WORK_DIR/$ASSET" >/dev/null
cp "$WORK_DIR/$ASSET" "./$ASSET"
echo "已下载官方 FPK（SHA256 校验通过，未修改）: $ASSET"
