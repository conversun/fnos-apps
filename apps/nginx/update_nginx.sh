#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"
WORK_DIR="/tmp/nginx_update_$$"
NGINX_VERSION="${NGINX_VERSION:-latest}"
ARCH="${ARCH:-}"

# fnOS is Debian bookworm-based
CODENAME="bookworm"

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
    
    if [ "$NGINX_VERSION" = "latest" ]; then
        # Parse nginx.org stable package pool for latest version
        NGINX_VERSION=$(curl -sL "https://nginx.org/packages/debian/pool/nginx/n/nginx/" 2>/dev/null | \
            grep -oE "nginx_[0-9]+\.[0-9]+\.[0-9]+-[0-9]+~${CODENAME}_amd64\.deb" | \
            sed -E 's/nginx_([0-9]+\.[0-9]+\.[0-9]+)-.*/\1/' | \
            sort -V | tail -1)
    fi
    
    [ -z "$NGINX_VERSION" ] && error "无法获取版本信息，请手动指定: $0 1.28.2"
    
    info "目标版本: $NGINX_VERSION"
}

download_deb() {
    local deb_url="https://nginx.org/packages/debian/pool/nginx/n/nginx/nginx_${NGINX_VERSION}-1~${CODENAME}_${DEB_ARCH}.deb"
    
    info "下载 ($ARCH): $deb_url"
    mkdir -p "$WORK_DIR"
    
    curl -L -f -o "$WORK_DIR/nginx.deb" "$deb_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/nginx.deb" | cut -f1)"
}

extract_deb() {
    info "解压 deb 包..."
    cd "$WORK_DIR"
    ar -x nginx.deb
    mkdir -p extracted
    
    # nginx .deb uses data.tar.zst or data.tar.xz depending on version
    if [ -f data.tar.zst ]; then
        tar --zstd -xf data.tar.zst -C extracted
    elif [ -f data.tar.xz ]; then
        tar -xf data.tar.xz -C extracted
    elif [ -f data.tar.gz ]; then
        tar -xf data.tar.gz -C extracted
    else
        error "deb 包结构异常：找不到 data.tar.*"
    fi
    
    [ -d "extracted/usr/sbin" ] || error "deb 包结构异常：找不到 /usr/sbin"
}

build_app_tgz() {
    info "构建 app.tgz..."
    
    local src="$WORK_DIR/extracted"
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/sbin" "$dst/conf" "$dst/html" "$dst/lib" "$dst/ui/images"
    
    # Copy nginx binary
    cp "$src/usr/sbin/nginx" "$dst/sbin/"
    chmod +x "$dst/sbin/nginx"
    
    # Copy configuration files (mime.types, etc.)
    cp -a "$src/etc/nginx"/* "$dst/conf/" 2>/dev/null || true
    
    # Copy default html pages
    cp -a "$src/usr/share/nginx/html"/* "$dst/html/" 2>/dev/null || true
    
    # Copy libraries if any
    [ -d "$src/usr/lib" ] && cp -a "$src/usr/lib"/* "$dst/lib/" 2>/dev/null || true
    
    # Copy launcher script and UI assets
    cp "$PKG_DIR/bin/nginx-server" "$dst/bin/" 2>/dev/null || {
        mkdir -p "$dst/bin"
        cp "$PKG_DIR/bin/nginx-server" "$dst/bin/"
    }
    chmod +x "$dst/bin/nginx-server"
    
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true
    
    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

update_manifest() {
    info "更新 manifest..."
    local checksum=$(md5 -q "$WORK_DIR/app.tgz" 2>/dev/null || md5sum "$WORK_DIR/app.tgz" | cut -d' ' -f1)
    
    sed -i.tmp "s/^version.*=.*/version         = ${NGINX_VERSION}/" "$PKG_DIR/manifest"
    sed -i.tmp "s/^checksum.*=.*/checksum        = ${checksum}/" "$PKG_DIR/manifest"
    
    if ! grep -q "^platform" "$PKG_DIR/manifest"; then
        echo "platform        = ${MANIFEST_PLATFORM}" >> "$PKG_DIR/manifest"
    else
        sed -i.tmp "s/^platform.*=.*/platform        = ${MANIFEST_PLATFORM}/" "$PKG_DIR/manifest"
    fi
    
    rm -f "$PKG_DIR/manifest.tmp"
}

build_fpk() {
    local fpk_name="nginx_${NGINX_VERSION}_${ARCH}.fpk"
    info "打包 $fpk_name..."
    
    mkdir -p "$WORK_DIR/package"
    
    cp "$WORK_DIR/app.tgz" "$WORK_DIR/package/"
    cp -a "$PKG_DIR/cmd" "$WORK_DIR/package/" 2>/dev/null || true
    cp -a "$PKG_DIR/config" "$WORK_DIR/package/" 2>/dev/null || true
    cp -a "$PKG_DIR/wizard" "$WORK_DIR/package/" 2>/dev/null || true
    cp "$PKG_DIR"/*.sc "$WORK_DIR/package/" 2>/dev/null || true
    cp "$PKG_DIR"/ICON*.PNG "$WORK_DIR/package/" 2>/dev/null || true
    cp "$PKG_DIR/manifest" "$WORK_DIR/package/"
    
    cd "$WORK_DIR/package"
    tar -czf "$SCRIPT_DIR/$fpk_name" *
    
    info "生成: $SCRIPT_DIR/$fpk_name ($(du -h "$SCRIPT_DIR/$fpk_name" | cut -f1))"
}

show_help() {
    cat << EOF
用法: $0 [选项] [版本号|latest]

选项:
  --arch ARCH       指定目标架构 (x86 或 arm)，默认自动检测
  -h, --help        显示此帮助信息

示例:
  $0                        # 最新稳定版，自动检测架构
  $0 --arch arm             # 最新版本，ARM 架构
  $0 --arch x86 1.28.2      # 指定版本，x86 架构
  $0 1.28.2                 # 指定版本，自动检测架构

环境变量:
  ARCH              目标架构 (x86 或 arm)
  NGINX_VERSION     Nginx 版本号

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
                NGINX_VERSION="$1"
                shift
                ;;
        esac
    done
}

main() {
    parse_args "$@"
    
    echo "========================================"
    echo "  Nginx fnOS Package Builder"
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
    
    if [ "$current_version" = "$NGINX_VERSION" ]; then
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
    info "完成: $current_version -> $NGINX_VERSION ($ARCH)"
}

main "$@"
