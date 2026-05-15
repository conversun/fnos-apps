#!/bin/bash
# L1 static validation for fnos-apps.
#
# Catches the failure classes that produced recent CI red:
#   - lxserver-style "Validate App Input" failures (missing icons / metadata)
#   - get-latest-version.sh output drift (e.g. librechat, copyparty)
#   - new-app.sh template TODOs left in released apps
#   - manifest <-> meta.env <-> ui/config port mismatch
#   - manifest fields missing or malformed
#   - service-setup bash syntax errors
#
# Usage:
#   scripts/test/static-check.sh                 # all apps
#   scripts/test/static-check.sh <slug> [<slug>] # specific apps
#
# Exits 0 on all-pass, 1 on any failure.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib.sh
source "$SCRIPT_DIR/lib.sh"

require_cmd jq "install jq via apt / brew"

REQUIRED_MANIFEST_KEYS=(
    appname version display_name platform maintainer maintainer_url
    distributor distributor_url desktop_uidir desktop_applaunchname
    service_port desc source checksum
)
ALLOWED_PLATFORMS=(x86 arm)
ALLOWED_SOURCES=(thirdparty official community)

TODO_PATTERN='\bTODO\b'

# ---------------------------------------------------------------------------
# Per-app checks
# ---------------------------------------------------------------------------

check_app_dir_layout() {
    local slug="$1"
    local d
    d="$(app_dir "$slug")"
    local missing=()
    [ -d "$d/fnos" ]                       || missing+=("fnos/")
    [ -d "$d/fnos/cmd" ]                   || missing+=("fnos/cmd/")
    [ -d "$d/fnos/config" ]                || missing+=("fnos/config/")
    [ -d "$d/fnos/ui" ]                    || missing+=("fnos/ui/")
    [ -f "$d/fnos/manifest" ]              || missing+=("fnos/manifest")
    [ -f "$d/fnos/ICON.PNG" ]              || missing+=("fnos/ICON.PNG")
    [ -f "$d/fnos/ICON_256.PNG" ]          || missing+=("fnos/ICON_256.PNG")
    if [ "${#missing[@]}" -gt 0 ]; then
        fail "$slug: missing files/dirs: ${missing[*]}"
        return 1
    fi
    pass "$slug: directory layout"
}

check_icons_nonempty() {
    local slug="$1"
    local d
    d="$(app_dir "$slug")"
    local bad=()
    for icon in ICON.PNG ICON_256.PNG; do
        local p="$d/fnos/$icon"
        [ -f "$p" ] || continue
        local size
        size="$(portable_stat_size "$p")"
        if [ "${size:-0}" -lt 256 ]; then
            bad+=("$icon=${size}B")
        fi
    done
    if [ "${#bad[@]}" -gt 0 ]; then
        fail "$slug: icons too small (<256B), likely empty: ${bad[*]}"
        return 1
    fi
    pass "$slug: icons non-trivial"
}

is_service_app() {
    local slug="$1"
    local h
    h="$(app_dir "$slug")/fnos/health.json"
    [ ! -f "$h" ] && return 0
    local t
    t="$(jq -r '.type // "http"' "$h" 2>/dev/null)"
    [ "$t" != "skip" ]
}

check_manifest_keys() {
    local slug="$1"
    local manifest
    manifest="$(app_dir "$slug")/fnos/manifest"
    [ -f "$manifest" ] || { fail "$slug: manifest missing"; return 1; }
    local missing=()
    for k in "${REQUIRED_MANIFEST_KEYS[@]}"; do
        if [ -z "$(manifest_get "$manifest" "$k")" ]; then
            [ "$k" = "checksum" ] && continue
            if ! is_service_app "$slug"; then
                case "$k" in
                    desktop_uidir|desktop_applaunchname|service_port) continue ;;
                esac
            fi
            missing+=("$k")
        fi
    done
    if [ "${#missing[@]}" -gt 0 ]; then
        fail "$slug: manifest missing keys: ${missing[*]}"
        return 1
    fi
    pass "$slug: manifest keys complete"
}

check_manifest_values() {
    local slug="$1"
    local manifest
    manifest="$(app_dir "$slug")/fnos/manifest"
    [ -f "$manifest" ] || return 0

    local platform source port appname
    platform="$(manifest_get "$manifest" platform)"
    source="$(manifest_get "$manifest" source)"
    port="$(manifest_get "$manifest" service_port)"
    appname="$(manifest_get "$manifest" appname)"

    local ok=1

    if ! printf '%s\n' "${ALLOWED_PLATFORMS[@]}" | grep -qx "$platform"; then
        fail "$slug: manifest.platform='$platform' not in (${ALLOWED_PLATFORMS[*]})"
        ok=0
    fi

    if ! printf '%s\n' "${ALLOWED_SOURCES[@]}" | grep -qx "$source"; then
        fail "$slug: manifest.source='$source' not in (${ALLOWED_SOURCES[*]})"
        ok=0
    fi

    if [ -n "$port" ]; then
        if [ "$port" = "0" ] && ! is_service_app "$slug"; then
            :
        elif ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
            fail "$slug: manifest.service_port='$port' is not a valid port"
            ok=0
        fi
    fi

    local meta_env file_prefix expected_appname
    meta_env="$(scripts_app_dir "$slug")/meta.env"
    file_prefix=""
    if [ -f "$meta_env" ]; then
        file_prefix="$(grep -E '^FILE_PREFIX=' "$meta_env" | head -1 | cut -d= -f2- | tr -d '"' || true)"
    fi
    expected_appname="${file_prefix:-$slug}"
    if [ "$appname" != "$expected_appname" ]; then
        fail "$slug: manifest.appname='$appname' != expected '$expected_appname' (FILE_PREFIX from meta.env, fallback to slug)"
        ok=0
    fi

    [ "$ok" -eq 1 ] && pass "$slug: manifest values valid"
    return $((1 - ok))
}

check_ui_port_matches() {
    local slug="$1"
    local d
    d="$(app_dir "$slug")"
    local ui_config="$d/fnos/ui/config"
    [ -f "$ui_config" ] || return 0
    local manifest_port ui_port
    manifest_port="$(manifest_get "$d/fnos/manifest" service_port)"
    if ! jq -e . <"$ui_config" >/dev/null 2>&1; then
        fail "$slug: ui/config is not valid JSON"
        return 1
    fi
    local ui_ports
    ui_ports="$(jq -r '.. | objects | .port? // empty' <"$ui_config")"
    if [ -z "$ui_ports" ]; then
        return 0
    fi
    if printf '%s\n' "$ui_ports" | grep -qx "$manifest_port"; then
        pass "$slug: ui/config exposes manifest.service_port ($manifest_port)"
        return 0
    fi
    local distinct
    distinct="$(printf '%s\n' "$ui_ports" | sort -u | paste -sd, -)"
    warn "$slug: ui/config ports=[$distinct] do not include manifest.service_port='$manifest_port' — verify if this is a multi-port app (legitimate) or a mismatch"
}

check_scripts_contract() {
    local slug="$1"
    local sd
    sd="$(scripts_app_dir "$slug")"
    if [ ! -d "$sd" ]; then
        fail "$slug: scripts/apps/$slug/ missing — required for CI"
        return 1
    fi
    local missing=()
    [ -f "$sd/meta.env" ]                || missing+=("meta.env")
    [ -f "$sd/get-latest-version.sh" ]   || missing+=("get-latest-version.sh")
    [ -f "$sd/build.sh" ]                || missing+=("build.sh")
    [ -f "$sd/release-notes.tpl" ]       || missing+=("release-notes.tpl")
    if [ "${#missing[@]}" -gt 0 ]; then
        fail "$slug: scripts/apps/$slug/ missing: ${missing[*]}"
        return 1
    fi
    pass "$slug: build contract complete"
}

check_meta_env() {
    local slug="$1"
    local sd
    sd="$(scripts_app_dir "$slug")"
    local meta="$sd/meta.env"
    [ -f "$meta" ] || return 0

    if ! (set -e; set -u; FILE_PREFIX=""; RELEASE_TITLE=""; DEFAULT_PORT="";
          HOMEPAGE_URL=""; source "$meta" 2>/dev/null) >/dev/null 2>&1; then
        fail "$slug: meta.env is not sourceable bash"
        return 1
    fi

    local file_prefix release_title default_port homepage_url
    file_prefix="$(grep -E '^FILE_PREFIX=' "$meta" | head -1 | cut -d= -f2- | tr -d '"' || true)"
    release_title="$(grep -E '^RELEASE_TITLE=' "$meta" | head -1 | cut -d= -f2- | tr -d '"' || true)"
    default_port="$(grep -E '^DEFAULT_PORT=' "$meta" | head -1 | cut -d= -f2- | tr -d '"' || true)"
    homepage_url="$(grep -E '^HOMEPAGE_URL=' "$meta" | head -1 | cut -d= -f2- | tr -d '"' || true)"

    local ok=1
    [ -n "$file_prefix" ]   || { fail "$slug: meta.env missing FILE_PREFIX"; ok=0; }
    [ -n "$release_title" ] || { fail "$slug: meta.env missing RELEASE_TITLE"; ok=0; }
    [ -n "$default_port" ]  || { fail "$slug: meta.env missing DEFAULT_PORT"; ok=0; }

    if [ "$homepage_url" = "TODO" ]; then
        fail "$slug: meta.env HOMEPAGE_URL is still 'TODO' (left from scaffold)"
        ok=0
    fi

    local manifest_port
    manifest_port="$(manifest_get "$(app_dir "$slug")/fnos/manifest" service_port)"
    if [ -n "$default_port" ] && [ -n "$manifest_port" ] && [ "$default_port" != "$manifest_port" ]; then
        fail "$slug: meta.env DEFAULT_PORT='$default_port' != manifest.service_port='$manifest_port'"
        ok=0
    fi

    [ "$ok" -eq 1 ] && pass "$slug: meta.env valid"
    return $((1 - ok))
}

check_no_scaffold_todos() {
    local slug="$1"
    local d sd
    d="$(app_dir "$slug")"
    sd="$(scripts_app_dir "$slug")"

    local hits
    hits="$(grep -lrE "$TODO_PATTERN" \
            "$d/fnos/manifest" \
            "$d/fnos/cmd/service-setup" \
            "$d/fnos/bin" \
            "$sd/build.sh" \
            "$sd/get-latest-version.sh" \
            2>/dev/null || true)"
    if [ -n "$hits" ]; then
        local rel
        rel="$(echo "$hits" | sed "s|$(repo_root)/||g" | paste -sd, -)"
        fail "$slug: scaffold TODO markers remain in: $rel"
        return 1
    fi
    pass "$slug: no scaffold TODOs"
}

check_get_latest_version_script() {
    local slug="$1"
    local sd
    sd="$(scripts_app_dir "$slug")"
    local script="$sd/get-latest-version.sh"
    [ -f "$script" ] || return 0
    if ! bash -n "$script" 2>/dev/null; then
        fail "$slug: get-latest-version.sh has bash syntax errors"
        return 1
    fi
    if ! grep -qE '^[[:space:]]*echo[[:space:]]+["'\'']?VERSION=' "$script"; then
        fail "$slug: get-latest-version.sh does not 'echo VERSION=...' (CI requires this output)"
        return 1
    fi
    pass "$slug: get-latest-version.sh syntax & output contract OK"
}

check_build_script_syntax() {
    local slug="$1"
    local sd
    sd="$(scripts_app_dir "$slug")"
    local script="$sd/build.sh"
    [ -f "$script" ] || return 0
    if ! bash -n "$script" 2>/dev/null; then
        fail "$slug: build.sh has bash syntax errors"
        return 1
    fi
    pass "$slug: build.sh syntax OK"
}

check_service_setup_syntax() {
    local slug="$1"
    local d
    d="$(app_dir "$slug")"
    local svc="$d/fnos/cmd/service-setup"
    [ -f "$svc" ] || return 0
    if ! bash -n "$svc" 2>/dev/null; then
        fail "$slug: cmd/service-setup has bash syntax errors"
        return 1
    fi
    if grep -nE '\bpkill[[:space:]]+(-9[[:space:]]+)?-f\b' "$svc" | grep -v '# pkill-f-ok' >/dev/null; then
        fail "$slug: cmd/service-setup uses 'pkill -f' — issue #112 footgun. Use 'pkill -x', or annotate the line with trailing '# pkill-f-ok' if -f is genuinely required (e.g. pattern contains absolute path or unique cmdline substring)."
        return 1
    fi
    pass "$slug: cmd/service-setup syntax & no pkill -f"
}

check_shellcheck_optional() {
    local slug="$1"
    has_cmd shellcheck || return 0
    local d
    d="$(app_dir "$slug")"
    local svc="$d/fnos/cmd/service-setup"
    [ -f "$svc" ] || return 0
    if ! shellcheck -S warning -e SC1091,SC2034,SC2148 "$svc" >/dev/null 2>&1; then
        warn "$slug: shellcheck reports warnings on cmd/service-setup (non-blocking)"
        return 0
    fi
    pass "$slug: shellcheck clean (warning+)"
}

check_docker_compose_when_present() {
    local slug="$1"
    is_docker_app "$slug" || return 0
    local d
    d="$(app_dir "$slug")"
    local compose="$d/fnos/docker/docker-compose.yaml"
    if has_cmd python3 && python3 -c 'import yaml' >/dev/null 2>&1; then
        if ! python3 -c "import sys, yaml; yaml.safe_load(open('$compose'))" >/dev/null 2>&1; then
            fail "$slug: docker-compose.yaml is not valid YAML"
            return 1
        fi
        pass "$slug: docker-compose.yaml parses as YAML"
        return 0
    fi
    if has_cmd yq; then
        if ! yq eval '.' "$compose" >/dev/null 2>&1; then
            fail "$slug: docker-compose.yaml is not valid YAML"
            return 1
        fi
        pass "$slug: docker-compose.yaml parses as YAML"
        return 0
    fi
    debug "$slug: no YAML parser available (python3/yq), skipping compose lint"
}

run_health_schema_subcheck() {
    local slug="$1"
    local h
    h="$(app_dir "$slug")/fnos/health.json"
    [ -f "$h" ] || return 0
    if bash "$SCRIPT_DIR/health-schema.sh" "$slug" >/dev/null 2>&1; then
        pass "$slug: health.json schema valid"
    else
        fail "$slug: health.json schema validation failed (run scripts/test/health-schema.sh $slug for details)"
    fi
}

check_one_app() {
    local slug="$1"
    note "── $slug ──"
    # Distributor-built apps (no local scripts/apps/<slug>/meta.env) are released by
    # an external repo and follow their own conventions. Skip — not in scope for this
    # repo's static contract checks.
    if [ ! -f "$(repo_root)/scripts/apps/$slug/meta.env" ]; then
        info "$slug: skipped (distributor-built — no scripts/apps/$slug/meta.env)"
        return 0
    fi
    check_app_dir_layout "$slug" || return 0
    check_icons_nonempty "$slug" || true
    check_manifest_keys  "$slug" || true
    check_manifest_values "$slug" || true
    check_ui_port_matches "$slug" || true
    check_scripts_contract "$slug" || true
    check_meta_env "$slug" || true
    check_no_scaffold_todos "$slug" || true
    check_get_latest_version_script "$slug" || true
    check_build_script_syntax "$slug" || true
    check_service_setup_syntax "$slug" || true
    check_shellcheck_optional "$slug" || true
    check_docker_compose_when_present "$slug" || true
    run_health_schema_subcheck "$slug" || true
}

main() {
    local apps=("$@")
    if [ "${#apps[@]}" -eq 0 ]; then
        while IFS= read -r _line; do apps+=("$_line"); done < <(list_apps)
    fi

    info "Static check across ${#apps[@]} app(s)"
    for slug in "${apps[@]}"; do
        check_one_app "$slug"
    done
    report_summary "static-check"
}

main "$@"
