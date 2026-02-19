#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="certimate"
APP_DISPLAY_NAME="Certimate"
APP_VERSION_VAR="CERTIMATE_VERSION"
APP_VERSION="${CERTIMATE_VERSION:-latest}"
APP_DEPS=(curl tar unzip)
APP_FPK_PREFIX="certimate"
APP_HELP_VERSION_EXAMPLE="0.4.17"

app_set_arch_vars() {
    case "$ARCH" in
        x86) ZIP_ARCH="amd64" ;;
        arm) ZIP_ARCH="arm64" ;;
    esac
    info "Zip arch: $ZIP_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 0.4.17      # 指定版本，x86 架构
  $0 0.4.17                 # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    tag=$(curl -sL "https://api.github.com/repos/certimate-go/certimate/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 0.4.17"

    info "目标版本: $APP_VERSION"
}

app_download() {
    local download_url="https://github.com/certimate-go/certimate/releases/download/v${APP_VERSION}/certimate_v${APP_VERSION}_linux_${ZIP_ARCH}.zip"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/certimate.zip" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/certimate.zip" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 certimate..."
    cd "$WORK_DIR"
    unzip -o certimate.zip

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui"

    local certimate_bin
    certimate_bin=$(find . -name "certimate" -type f | head -1)
    [ -z "$certimate_bin" ] && error "在 zip 中找不到 certimate 二进制文件"

    cp "$certimate_bin" "$dst/certimate"
    chmod +x "$dst/certimate"

    cp "$PKG_DIR/bin/certimate-server" "$dst/bin/certimate-server"
    chmod +x "$dst/bin/certimate-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
