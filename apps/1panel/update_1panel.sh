#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="1panel"
APP_DISPLAY_NAME="1Panel"
APP_VERSION_VAR="ONEPANEL_VERSION"
APP_VERSION="${ONEPANEL_VERSION:-latest}"
APP_DEPS=(curl tar)
APP_FPK_PREFIX="1panel"
APP_HELP_VERSION_EXAMPLE="2.1.7"

app_set_arch_vars() {
    case "$ARCH" in
        x86) ZIP_ARCH="amd64" ;;
        arm) ZIP_ARCH="arm64" ;;
    esac
    info "Tar arch: $ZIP_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 2.1.7       # 指定版本，x86 架构
  $0 2.1.7                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        local cdn_version
        cdn_version=$(curl -sL "https://resource.1panel.pro/v2/stable/latest" 2>/dev/null)
        APP_VERSION=$(echo "$cdn_version" | sed 's/^v//')
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 2.1.7"
    info "目标版本: $APP_VERSION"
}

app_download() {
    local download_url="https://resource.1panel.pro/v2/stable/v${APP_VERSION}/release/1panel-v${APP_VERSION}-linux-${ZIP_ARCH}.tar.gz"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/1panel.tar.gz" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/1panel.tar.gz" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 1panel..."
    cd "$WORK_DIR"
    tar -xzf 1panel.tar.gz

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui"

    local panel_bin
    panel_bin=$(find . -name "1panel" -type f | head -1)
    [ -z "$panel_bin" ] && error "在 tar.gz 中找不到 1panel 二进制文件"

    cp "$panel_bin" "$dst/1panel"
    chmod +x "$dst/1panel"

    cp "$PKG_DIR/bin/1panel-server" "$dst/bin/1panel-server"
    chmod +x "$dst/bin/1panel-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
