#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="openlist"
APP_DISPLAY_NAME="OpenList"
APP_VERSION_VAR="OPENLIST_VERSION"
APP_VERSION="${OPENLIST_VERSION:-latest}"
APP_DEPS=(curl tar)
APP_FPK_PREFIX="openlist"
APP_HELP_VERSION_EXAMPLE="4.1.10"

app_set_arch_vars() {
    case "$ARCH" in
        x86) TAR_ARCH="amd64" ;;
        arm) TAR_ARCH="arm64" ;;
    esac
    info "Tar arch: $TAR_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 4.1.10      # 指定版本，x86 架构
  $0 4.1.10                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    tag=$(curl -sL "https://api.github.com/repos/OpenListTeam/OpenList/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 4.1.10"

    info "目标版本: $APP_VERSION"
}

app_download() {
    local download_url="https://github.com/OpenListTeam/OpenList/releases/download/v${APP_VERSION}/openlist-linux-${TAR_ARCH}.tar.gz"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/openlist.tar.gz" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/openlist.tar.gz" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 openlist..."
    cd "$WORK_DIR"
    tar -xzf openlist.tar.gz

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/ui"

    # OpenList extracts to current directory
    local openlist_bin
    openlist_bin=$(find . -maxdepth 2 -name "openlist" -type f | head -1)
    [ -z "$openlist_bin" ] && error "在 tar.gz 中找不到 openlist 二进制文件"

    cp "$openlist_bin" "$dst/openlist"
    chmod +x "$dst/openlist"

    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
