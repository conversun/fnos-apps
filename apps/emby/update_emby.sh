#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="emby"
APP_DISPLAY_NAME="Emby"
APP_VERSION_VAR="EMBY_VERSION"
APP_VERSION="${EMBY_VERSION:-latest}"
APP_DEPS=(curl ar tar sed)
APP_FPK_PREFIX="embyserver"
APP_HELP_VERSION_EXAMPLE="4.9.3.0"

# Emby-specific: track original version (may include -beta suffix)
EMBY_VERSION_ORIG=""

app_set_arch_vars() {
    case "$ARCH" in
        x86) DEB_ARCH="amd64" ;;
        arm) DEB_ARCH="arm64" ;;
    esac
    info "Deb arch: $DEB_ARCH"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 4.9.3.0     # 指定版本，x86 架构
  $0 4.9.3.0                 # 指定版本，自动检测架构
  $0 beta                    # 最新 beta 版本
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    EMBY_VERSION_ORIG="$APP_VERSION"

    if [ "$APP_VERSION" = "latest" ] || [ "$APP_VERSION" = "beta" ]; then
        local html
        html=$(curl -sL "https://github.com/MediaBrowser/Emby.Releases/releases" 2>/dev/null)

        if [ "$APP_VERSION" = "latest" ]; then
            APP_VERSION=$(echo "$html" | grep -oE '(releases/tag/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+[^"]*|Latest)' | grep -B1 "^Latest$" | head -1 | sed 's|releases/tag/||')
        else
            APP_VERSION=$(echo "$html" | grep -oE 'releases/tag/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's|releases/tag/||')
        fi
        EMBY_VERSION_ORIG="$APP_VERSION"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 4.9.3.0"

    # Strip -beta suffix for clean version used in manifest/fpk
    APP_VERSION="${APP_VERSION%-beta}"
    info "目标版本: $EMBY_VERSION_ORIG (clean: $APP_VERSION)"
}

app_download() {
    local download_tag="${EMBY_VERSION_ORIG:-$APP_VERSION}"
    local deb_url="https://github.com/MediaBrowser/Emby.Releases/releases/download/${download_tag}/emby-server-deb_${APP_VERSION}_${DEB_ARCH}.deb"

    info "下载 ($ARCH): $deb_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/emby-server.deb" "$deb_url" || error "下载失败"
    info "下载完成: $(du -h "$WORK_DIR/emby-server.deb" | cut -f1)"
}

app_build_app_tgz() {
    info "解压 deb 包..."
    cd "$WORK_DIR"
    ar -x emby-server.deb
    mkdir -p extracted
    tar -xf data.tar.xz -C extracted
    [ -d "extracted/opt/emby-server" ] || error "deb 包结构异常"

    info "构建 app.tgz..."
    local src="$WORK_DIR/extracted/opt/emby-server"
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst"

    cp -a "$src/bin" "$src/etc" "$src/lib" "$src/licenses" "$src/share" "$src/system" "$dst/"
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

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
