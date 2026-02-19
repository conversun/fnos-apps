#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="vaultwarden"
APP_DISPLAY_NAME="Vaultwarden"
APP_VERSION_VAR="VAULTWARDEN_VERSION"
APP_VERSION="${VAULTWARDEN_VERSION:-latest}"
APP_DEPS=(curl docker)
APP_FPK_PREFIX="vaultwarden"
APP_HELP_VERSION_EXAMPLE="1.35.3"

app_set_arch_vars() {
    case "$ARCH" in
        x86) DOCKER_PLATFORM="linux/amd64" ;;
        arm) DOCKER_PLATFORM="linux/arm64" ;;
    esac
    info "Docker platform: $DOCKER_PLATFORM"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 1.35.3      # 指定版本，x86 架构
  $0 1.35.3                  # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    local tag
    tag=$(curl -sL "https://api.github.com/repos/dani-garcia/vaultwarden/releases/latest" 2>/dev/null | \
        grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION="$tag"
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 1.35.3"

    info "目标版本: $APP_VERSION"
}

app_download() {
    info "从 Docker 镜像提取 vaultwarden ($ARCH)..."
    mkdir -p "$WORK_DIR"

    local image="vaultwarden/server:${APP_VERSION}-alpine"

    info "拉取 Docker 镜像: $image (platform: $DOCKER_PLATFORM)"
    docker pull --platform "$DOCKER_PLATFORM" "$image" || error "Docker 镜像拉取失败"

    local container_id
    container_id=$(docker create --platform "$DOCKER_PLATFORM" "$image")
    info "创建临时容器: $container_id"

    # Extract vaultwarden binary
    docker cp "$container_id:/vaultwarden" "$WORK_DIR/vaultwarden" || error "提取 vaultwarden 二进制文件失败"

    # Extract web-vault
    docker cp "$container_id:/web-vault" "$WORK_DIR/web-vault" || error "提取 web-vault 失败"

    # Cleanup
    docker rm "$container_id" > /dev/null
    info "提取完成: vaultwarden + web-vault"
}

app_build_app_tgz() {
    info "构建 app.tgz..."
    cd "$WORK_DIR"
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/ui"

    cp vaultwarden "$dst/vaultwarden"
    chmod +x "$dst/vaultwarden"
    cp -r web-vault "$dst/web-vault"

    cp "$PKG_DIR/bin/vaultwarden-server" "$dst/bin/vaultwarden-server"
    chmod +x "$dst/bin/vaultwarden-server"
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
