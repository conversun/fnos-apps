#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"
BUILD_FPK_SCRIPT="$REPO_ROOT/scripts/build-fpk.sh"
WORK_DIR="/tmp/emby_update_$$"
EMBY_VERSION="${EMBY_VERSION:-latest}"
ARCH="${ARCH:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

detect_arch() {
    if [ -z "$ARCH" ]; then
        local machine=$(uname -m)
        case "$machine" in
            x86_64|amd64)
                ARCH=x86
                ;;
            aarch64|arm64)
                ARCH=arm
                ;;
            *)
                error "Unsupported architecture: $machine. Use --arch to specify x86 or arm."
                ;;
        esac
        info "Auto-detected architecture: $ARCH"
    fi
    
    case "$ARCH" in
        x86)
            DEB_ARCH="amd64"
            MANIFEST_PLATFORM="x86"
            ;;
        arm)
            DEB_ARCH="arm64"
            MANIFEST_PLATFORM="arm"
            ;;
        *)
            error "Invalid architecture: $ARCH. Must be x86 or arm."
            ;;
    esac
    
    info "Deb arch: $DEB_ARCH"
    info "Manifest platform: $MANIFEST_PLATFORM"
}

get_latest_version() {
    info "获取最新版本信息..."
    
    if [ "$EMBY_VERSION" = "latest" ] || [ "$EMBY_VERSION" = "beta" ]; then
        local html=$(curl -sL "https://github.com/MediaBrowser/Emby.Releases/releases" 2>/dev/null)
        
        if [ "$EMBY_VERSION" = "latest" ]; then
            EMBY_VERSION=$(echo "$html" | grep -oE '(releases/tag/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[^"]*|Latest)' | grep -B1 "^Latest$" | head -1 | sed 's|releases/tag/||')
        else
            EMBY_VERSION=$(echo "$html" | grep -oE 'releases/tag/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's|releases/tag/||')
        fi
    fi
    
    [ -z "$EMBY_VERSION" ] && error "无法获取版本信息，请手动指定: $0 4.9.3.0"
    
    EMBY_VERSION_CLEAN="${EMBY_VERSION%-beta}"
    info "目标版本: $EMBY_VERSION"
}

download_deb() {
    local deb_url="https://github.com/MediaBrowser/Emby.Releases/releases/download/${EMBY_VERSION}/emby-server-deb_${EMBY_VERSION_CLEAN}_${DEB_ARCH}.deb"
    
    info "下载 ($ARCH): $deb_url"
    mkdir -p "$WORK_DIR"
    
    curl -L -f -o "$WORK_DIR/emby-server.deb" "$deb_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/emby-server.deb" | cut -f1)"
}

extract_deb() {
    info "解压 deb 包..."
    cd "$WORK_DIR"
    ar -x emby-server.deb
    mkdir -p extracted
    tar -xf data.tar.xz -C extracted
    [ -d "extracted/opt/emby-server" ] || error "deb 包结构异常"
}

build_app_tgz() {
    info "构建 app.tgz..."
    
    local src="$WORK_DIR/extracted/opt/emby-server"
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst"
    
    cp -r "$src/bin" "$src/etc" "$src/extra" "$src/lib" "$src/licenses" "$src/share" "$src/system" "$dst/"
    mkdir -p "$dst/config" "$dst/ui/images"
    
    cp "$PKG_DIR/EmbyServer.sc" "$dst/" 2>/dev/null || true
    cp -a "$PKG_DIR/config"/* "$dst/config/" 2>/dev/null || true
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true
    cp "$PKG_DIR/bin/emby-server" "$dst/bin/emby-server" 2>/dev/null || true
    chmod +x "$dst/bin/emby-server" 2>/dev/null || true
    
    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

update_manifest() {
    info "更新 manifest..."
    local checksum=$(md5 -q "$WORK_DIR/app.tgz" 2>/dev/null || md5sum "$WORK_DIR/app.tgz" | cut -d' ' -f1)
    
    sed -i.tmp "s/^version.*=.*/version         = ${EMBY_VERSION_CLEAN}/" "$PKG_DIR/manifest"
    sed -i.tmp "s/^checksum.*=.*/checksum        = ${checksum}/" "$PKG_DIR/manifest"
    
    if ! grep -q "^platform" "$PKG_DIR/manifest"; then
        echo "platform        = ${MANIFEST_PLATFORM}" >> "$PKG_DIR/manifest"
    else
        sed -i.tmp "s/^platform.*=.*/platform        = ${MANIFEST_PLATFORM}/" "$PKG_DIR/manifest"
    fi
    
    rm -f "$PKG_DIR/manifest.tmp"
}

build_fpk() {
    local fpk_name="embyserver_${EMBY_VERSION_CLEAN}_${ARCH}.fpk"
    info "打包 $fpk_name..."

    local build_output
    local built_name
    build_output=$(cd "$SCRIPT_DIR" && "$BUILD_FPK_SCRIPT" "$SCRIPT_DIR" "$WORK_DIR/app.tgz" "$EMBY_VERSION_CLEAN" "$MANIFEST_PLATFORM") || error "打包失败"
    echo "$build_output"
    built_name=$(echo "$build_output" | tail -n 1)

    if [ "$built_name" != "$fpk_name" ] && [ -f "$SCRIPT_DIR/$built_name" ]; then
        mv -f "$SCRIPT_DIR/$built_name" "$SCRIPT_DIR/$fpk_name"
    fi

    info "生成: $SCRIPT_DIR/$fpk_name ($(du -h "$SCRIPT_DIR/$fpk_name" | cut -f1))"
}

show_help() {
    cat << EOF
用法: $0 [选项] [版本号|latest|beta]

选项:
  --arch ARCH       指定目标架构 (x86 或 arm)，默认自动检测
  -h, --help        显示此帮助信息

示例:
  $0                        # 最新稳定版，自动检测架构
  $0 --arch arm             # 最新版本，ARM 架构
  $0 --arch x86 4.9.3.0     # 指定版本，x86 架构
  $0 beta                   # 最新 beta 版本

环境变量:
  ARCH              目标架构 (x86 或 arm)
  EMBY_VERSION      Emby 版本号

支持的架构:
  x86 (x86_64)      Intel/AMD 64位处理器
  arm (aarch64)     ARM 64位处理器
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            --arch)
                ARCH="$2"
                shift 2
                ;;
            --arch=*)
                ARCH="${1#*=}"
                shift
                ;;
            -*)
                error "未知选项: $1"
                ;;
            *)
                EMBY_VERSION="$1"
                shift
                ;;
        esac
    done
}

main() {
    parse_args "$@"
    
    echo "========================================"
    echo "  Emby Server fnOS Package Builder"
    echo "========================================"
    echo
    
    for cmd in curl ar tar sed; do
        command -v $cmd &>/dev/null || error "缺少依赖: $cmd"
    done
    
    [ -f "$PKG_DIR/manifest" ] || error "找不到 fnos 目录"
    
    detect_arch
    
    local current_version=$(grep "^version" "$PKG_DIR/manifest" | awk -F'=' '{print $2}' | tr -d ' ')
    info "当前版本: $current_version"
    
    get_latest_version
    
    if [ "$current_version" = "$EMBY_VERSION_CLEAN" ]; then
        warn "已是最新版本"
        read -p "强制重新构建? [y/N] " -n 1 -r; echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
    fi
    
    download_deb
    extract_deb
    build_app_tgz
    update_manifest
    build_fpk
    
    echo
    info "完成: $current_version -> $EMBY_VERSION_CLEAN ($ARCH)"
}

main "$@"
