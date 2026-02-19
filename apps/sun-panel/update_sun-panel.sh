#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="sun-panel"
APP_DISPLAY_NAME="Sun-Panel"
APP_VERSION_VAR="SUNPANEL_VERSION"
APP_VERSION="${SUNPANEL_VERSION:-latest}"
APP_DEPS=(curl tar)
APP_FPK_PREFIX="sun-panel"
APP_HELP_VERSION_EXAMPLE="1.8.1"

app_set_arch_vars() {
    case "$ARCH" in
        x86) ZIP_ARCH="amd64" ;;
        arm) ZIP_ARCH="arm64" ;;
    esac
    info "Zip arch: $ZIP_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 1.8.1       # 指定版本，x86 架构
  $0 1.8.1                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    tag=$(curl -sL "https://api.github.com/repos/hslr-s/sun-panel/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 1.8.1"

    info "目标版本: $APP_VERSION"
}

app_download() {
    local download_url="https://github.com/hslr-s/sun-panel/releases/download/v${APP_VERSION}/sun-panel_v${APP_VERSION}_linux_${ZIP_ARCH}.tar.gz"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/sun-panel.tar.gz" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/sun-panel.tar.gz" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 sun-panel..."
    cd "$WORK_DIR"
    tar -xzf sun-panel.tar.gz

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui"

    local sunpanel_dir
    sunpanel_dir=$(find . -maxdepth 1 -type d -name "sun-panel_v${APP_VERSION}_linux_${ZIP_ARCH}" | head -1)
    [ -z "$sunpanel_dir" ] && error "在归档中找不到 sun-panel 目录"

    cp "$sunpanel_dir/sun-panel" "$dst/sun-panel"
    chmod +x "$dst/sun-panel"
    cp -r "$sunpanel_dir/web" "$dst/web"

    cp "$PKG_DIR/bin/sun-panel-server" "$dst/bin/sun-panel-server"
    chmod +x "$dst/bin/sun-panel-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
