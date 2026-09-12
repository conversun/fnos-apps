#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="frps"
APP_DISPLAY_NAME="FRP Server"
APP_VERSION_VAR="FRPS_VERSION"
APP_VERSION="${FRPS_VERSION:-latest}"
APP_DEPS=(curl tar)
APP_FPK_PREFIX="frps"
APP_HELP_VERSION_EXAMPLE="0.71.0"

app_set_arch_vars() {
    case "$ARCH" in
        x86) UPSTREAM_ARCH="amd64" ;;
        arm) UPSTREAM_ARCH="arm64" ;;
    esac
    info "Upstream arch: $UPSTREAM_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 0.71.0       # 指定版本，x86 架构
  $0 0.71.0                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    tag=$(curl -sL "https://api.github.com/repos/fatedier/frp/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 0.71.0"

    info "目标版本: $APP_VERSION"
}

app_download() {
    local download_url="https://github.com/fatedier/frp/releases/download/v${APP_VERSION}/frp_${APP_VERSION}_linux_${UPSTREAM_ARCH}.tar.gz"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/frp.tar.gz" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/frp.tar.gz" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 frps..."
    tar -xzf "$WORK_DIR/frp.tar.gz" -C "$WORK_DIR" --strip-components=1 "frp_${APP_VERSION}_linux_${UPSTREAM_ARCH}/frps"

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui"

    mv "$WORK_DIR/frps" "$dst/frps"
    chmod +x "$dst/frps"

    cp "$PKG_DIR/bin/frps-server" "$dst/bin/frps-server"
    chmod +x "$dst/bin/frps-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
