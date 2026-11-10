#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="jellyfin"
APP_DISPLAY_NAME="Jellyfin"
APP_VERSION_VAR="JELLYFIN_VERSION"
APP_VERSION="${JELLYFIN_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="jellyfin"
APP_HELP_VERSION_EXAMPLE="10.11.6"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TARBALL_ARCH="amd64"; PORTABLE_SUFFIX="linux64" ;;
        arm) TARBALL_ARCH="arm64"; PORTABLE_SUFFIX="linuxarm64" ;;
    esac
    info "Tarball arch: $TARBALL_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 10.11.6     # 指定版本，x86 架构
  $0 10.11.6                 # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION=$(curl -sL "https://api.github.com/repos/jellyfin/jellyfin/releases/latest" | \
          jq -r '.tag_name' | sed 's/^v//')
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 10.11.6"
    info "目标版本: $APP_VERSION"
}

app_download() {
    local tarball_url="https://repo.jellyfin.org/files/server/linux/latest-stable/${TARBALL_ARCH}/jellyfin_${APP_VERSION}-${TARBALL_ARCH}.tar.gz"
    # shellcheck source=scripts/apps/jellyfin/ffmpeg.sh
    source "$REPO_ROOT/scripts/apps/jellyfin/ffmpeg.sh"

    info "下载 ($ARCH): $tarball_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/jellyfin.tar.gz" "$tarball_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/jellyfin.tar.gz" | cut -f1)"

    info "下载 jellyfin-ffmpeg portable: $FFMPEG_FILE"
    curl -L -f -o "$WORK_DIR/jellyfin-ffmpeg-portable" "$FFMPEG_URL" || error "ffmpeg 下载失败"
    info "ffmpeg 下载完成: $(du -h "$WORK_DIR/jellyfin-ffmpeg-portable" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 tarball..."
    cd "$WORK_DIR"
    tar -xzf jellyfin.tar.gz
    [ -d "jellyfin" ] || error "tarball 结构异常"

    info "解压 jellyfin-ffmpeg portable..."
    mkdir -p ffmpeg_extract
    tar -xf jellyfin-ffmpeg-portable -C ffmpeg_extract

    local ffmpeg_bin
    ffmpeg_bin=$(find ffmpeg_extract -name ffmpeg -type f -print -quit)
    [ -z "$ffmpeg_bin" ] && error "portable 包中未找到 ffmpeg 二进制文件"
    local ffmpeg_src
    ffmpeg_src=$(dirname "$ffmpeg_bin")

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/config" "$dst/ui/images" "$dst/jellyfin-ffmpeg"

    cp -a jellyfin/* "$dst/"

    cp -a "$ffmpeg_src"/* "$dst/jellyfin-ffmpeg/"
    [ -x "$dst/jellyfin-ffmpeg/ffmpeg" ] || chmod +x "$dst/jellyfin-ffmpeg/ffmpeg"
    [ -x "$dst/jellyfin-ffmpeg/ffprobe" ] || chmod +x "$dst/jellyfin-ffmpeg/ffprobe" 2>/dev/null || true
    info "ffmpeg 目录: $(du -sh "$dst/jellyfin-ffmpeg" | cut -f1)"

    cp "$PKG_DIR/bin/jellyfin-server" "$dst/bin/jellyfin-server" 2>/dev/null || true
    chmod +x "$dst/bin/jellyfin-server" 2>/dev/null || true
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
