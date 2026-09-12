#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="vikunja"
APP_DISPLAY_NAME="Vikunja"
APP_VERSION_VAR="VIKUNJA_VERSION"
APP_VERSION="${VIKUNJA_VERSION:-latest}"
APP_DEPS=(curl unzip)
APP_FPK_PREFIX="vikunja"
APP_HELP_VERSION_EXAMPLE="2.6.0"

app_set_arch_vars() {
    case "$ARCH" in
        x86) UPSTREAM_ARCH="amd64" ;;
        arm) UPSTREAM_ARCH="arm64" ;;
    esac
    info "Upstream arch: $UPSTREAM_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 2.6.0       # 指定版本，x86 架构
  $0 2.6.0                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    tag=$(curl -sL "https://api.github.com/repos/go-vikunja/vikunja/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 2.6.0"

    info "目标版本: $APP_VERSION"
}

app_download() {
    local download_url="https://github.com/go-vikunja/vikunja/releases/download/v${APP_VERSION}/vikunja-v${APP_VERSION}-linux-${UPSTREAM_ARCH}-full.zip"

    info "下载 ($ARCH): $download_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/vikunja.zip" "$download_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/vikunja.zip" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 vikunja..."
    unzip -qo "$WORK_DIR/vikunja.zip" -d "$WORK_DIR"

    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui"

    cp "$WORK_DIR/vikunja-v${APP_VERSION}-linux-${UPSTREAM_ARCH}" "$dst/vikunja"
    chmod +x "$dst/vikunja"

    cp "$PKG_DIR/bin/vikunja-server" "$dst/bin/vikunja-server"
    chmod +x "$dst/bin/vikunja-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
