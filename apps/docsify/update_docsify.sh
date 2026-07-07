#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="docsify"
APP_DISPLAY_NAME="Docsify"
APP_VERSION_VAR="DOCSIFY_VERSION"
APP_VERSION="${DOCSIFY_VERSION:-latest}"
APP_DEPS=(curl tar python3)
APP_FPK_PREFIX="docsify"
APP_HELP_VERSION_EXAMPLE="1.31.2"

app_set_arch_vars() {
    case "$ARCH" in
        x86) DOCKER_PLATFORM="linux/amd64" ;;
        arm) DOCKER_PLATFORM="linux/arm64" ;;
    esac
    info "Docker platform: $DOCKER_PLATFORM"
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 1.31.2      # 指定 nginx-unprivileged 版本，x86 架构
  $0 1.31.2                 # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取 nginx-unprivileged 最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION=$(curl -sL "https://hub.docker.com/v2/repositories/nginxinc/nginx-unprivileged/tags?page_size=100" | \
            python3 -c 'import json, re, sys
data=json.load(sys.stdin)
versions=[]
for item in data.get("results", []):
    name=item.get("name", "")
    if re.fullmatch(r"\d+\.\d+\.\d+", name):
        versions.append(tuple(map(int, name.split("."))))
if not versions:
    raise SystemExit(1)
print(".".join(map(str, max(versions))))')
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 1.31.2"

    info "目标版本: $APP_VERSION"
}

app_download() {
    info "使用 Docker 镜像: nginxinc/nginx-unprivileged:${APP_VERSION} ($DOCKER_PLATFORM)"
    mkdir -p "$WORK_DIR"
}

app_build_app_tgz() {
    info "构建 app.tgz..."
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/docker" "$dst/ui"

    cp "$PKG_DIR/docker/docker-compose.yaml" "$dst/docker/docker-compose.yaml"
    sed -i.tmp "s/\${VERSION}/${APP_VERSION}/g" "$dst/docker/docker-compose.yaml"
    rm -f "$dst/docker/docker-compose.yaml.tmp"

    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
