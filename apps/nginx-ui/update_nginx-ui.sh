#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="nginx-ui"
APP_DISPLAY_NAME="Nginx UI"
APP_VERSION_VAR="NGINX_UI_VERSION"
APP_VERSION="${NGINX_UI_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="nginx-ui"
APP_HELP_VERSION_EXAMPLE="2.3.3"

app_set_arch_vars() {
    case "$ARCH" in
        x86) NGINX_UI_ARCH="64" ;;
        arm) NGINX_UI_ARCH="arm64-v8a" ;;
    esac
    info "Nginx UI arch: $NGINX_UI_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 2.3.3      # 指定版本，x86 架构
  $0 2.3.3                 # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取 Nginx UI 最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        local tag
        # Try stable release first
        tag=$(curl -sL "https://api.github.com/repos/0xJacky/nginx-ui/releases/latest" 2>/dev/null | \
            jq -r '.tag_name // empty' 2>/dev/null)
        # Fall back to most recent release
        if [ -z "$tag" ]; then
            tag=$(curl -sL "https://api.github.com/repos/0xJacky/nginx-ui/releases" 2>/dev/null | \
                jq -r '.[0].tag_name // empty' 2>/dev/null)
        fi
        APP_VERSION=$(echo "$tag" | sed 's/^v//')
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 2.3.3"

    info "Nginx UI 版本: $APP_VERSION"
}

app_download() {
    mkdir -p "$WORK_DIR"

    # Download nginx-ui
    local nginx_ui_url="https://github.com/0xJacky/nginx-ui/releases/download/v${APP_VERSION}/nginx-ui-linux-${NGINX_UI_ARCH}.tar.gz"
    info "下载 Nginx UI ($ARCH): $nginx_ui_url"
    curl -L -f -o "$WORK_DIR/nginx-ui.tar.gz" "$nginx_ui_url" || error "Nginx UI 下载失败"
    info "Nginx UI 下载完成: $(du -h "$WORK_DIR/nginx-ui.tar.gz" | cut -f1)"
}

app_build_app_tgz() {
    cd "$WORK_DIR"

    # Extract nginx-ui
    info "解压 Nginx UI..."
    mkdir -p nginx_ui_extracted
    tar -xzf nginx-ui.tar.gz -C nginx_ui_extracted

    # Assemble app_root
    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui/images"

    # Nginx UI binary
    local nginx_ui_bin
    nginx_ui_bin=$(find nginx_ui_extracted -name "nginx-ui" -type f | head -1)
    [ -z "$nginx_ui_bin" ] && error "在压缩包中找不到 nginx-ui 二进制文件"
    cp "$nginx_ui_bin" "$dst/nginx-ui"
    chmod +x "$dst/nginx-ui"

    # Startup wrapper + UI
    cp "$PKG_DIR/bin/nginx-ui-server" "$dst/bin/nginx-ui-server"
    chmod +x "$dst/bin/nginx-ui-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
