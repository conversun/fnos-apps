#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PKG_DIR="${SCRIPT_DIR}/fnos"

APP_NAME="calibre-web"
APP_DISPLAY_NAME="Calibre-Web"
APP_VERSION_VAR="CALIBRE_WEB_VERSION"
APP_VERSION="${CALIBRE_WEB_VERSION:-latest}"
APP_DEPS=(curl tar jq)
APP_FPK_PREFIX="calibre-web"
APP_HELP_VERSION_EXAMPLE="x.y.z"

app_set_arch_vars() { :; }

app_get_latest_version() {
    info "获取最新版本信息..."
    if [ "${APP_VERSION}" = "latest" ]; then
        APP_VERSION="$(bash "${REPO_ROOT}/scripts/apps/calibre-web/get-latest-version.sh" | awk -F= '/^VERSION=/{print $2}')"
    fi
    [ -n "${APP_VERSION}" ] || error "无法获取版本信息，请手动指定"
    info "目标版本: ${APP_VERSION}"
}

app_download() { :; }

app_build_app_tgz() {
    info "构建 app.tgz (Docker)..."
    VERSION="${APP_VERSION}" bash "${REPO_ROOT}/scripts/apps/calibre-web/build.sh"
    cp "${REPO_ROOT}/app.tgz" "${WORK_DIR}/app.tgz"
}

source "${REPO_ROOT}/scripts/lib/update-common.sh"
main_flow "$@"
