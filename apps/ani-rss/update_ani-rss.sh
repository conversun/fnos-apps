#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PKG_DIR="$SCRIPT_DIR/fnos"

APP_NAME="ani-rss"
APP_DISPLAY_NAME="ANI-RSS"
APP_VERSION_VAR="ANIRSS_VERSION"
APP_VERSION="${ANIRSS_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="ani-rss"
APP_HELP_VERSION_EXAMPLE="2.5.2"

app_set_arch_vars() {
    # JRE 不再捆绑，改用 fnOS 系统 Java 运行时 (install_dep_apps=java-17-openjdk)
    :
}

app_show_help_examples() {
    cat << EOF
  $0 --arch x86 2.5.2        # 指定版本，x86 架构
  $0 2.5.2                    # 指定版本，自动检测架构
EOF
}

app_get_latest_version() {
    info "获取最新版本信息..."

    if [ "$APP_VERSION" = "latest" ]; then
        APP_VERSION=$(curl -sL "https://api.github.com/repos/wushuo894/ani-rss/releases/latest" | \
          jq -r '.tag_name' | sed 's/^v//')
    fi

    [ -z "$APP_VERSION" ] && error "无法获取版本信息，请手动指定: $0 2.5.2"
    info "目标版本: $APP_VERSION"
}

app_download() {
    local jar_url="https://github.com/wushuo894/ani-rss/releases/download/v${APP_VERSION}/ani-rss-jar-with-dependencies.jar"

    info "下载 JAR: $jar_url"
    mkdir -p "$WORK_DIR"
    curl -L -f -o "$WORK_DIR/ani-rss.jar" "$jar_url" || error "JAR 下载失败"
    info "JAR 下载完成: $(du -h "$WORK_DIR/ani-rss.jar" | cut -f1)"

    # JRE 不再捆绑，改用 fnOS 系统 Java 运行时 (install_dep_apps=java-17-openjdk)
}

app_build_app_tgz() {
    info "构建 app.tgz..."
    cd "$WORK_DIR"
    local dst="$WORK_DIR/app_root"
    mkdir -p "$dst/bin" "$dst/config" "$dst/ui/images"

    cp ani-rss.jar "$dst/ani-rss-jar-with-dependencies.jar"

    # JRE 不再捆绑，使用 fnOS 系统 Java 运行时

    cp "$PKG_DIR/bin/ani-rss-server" "$dst/bin/ani-rss-server" 2>/dev/null || true
    chmod +x "$dst/bin/ani-rss-server" 2>/dev/null || true
    cp -a "$PKG_DIR/ui"/* "$dst/ui/" 2>/dev/null || true

    cd "$dst"
    tar -czf "$WORK_DIR/app.tgz" .
    info "app.tgz: $(du -h "$WORK_DIR/app.tgz" | cut -f1)"
}

source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
