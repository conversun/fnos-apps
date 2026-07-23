#!/bin/bash
# Validate apps/<slug>/fnos/health.json against the schema in
# docs/testing/HEALTH_SCHEMA.md.
#
# Usage:
#   scripts/test/health-schema.sh                  # validate all apps
#   scripts/test/health-schema.sh <slug> [<slug>]  # validate specific apps
#
# Behaviour:
#   - Apps without health.json are skipped (file is optional).
#   - Each present health.json must be valid JSON and conform to the schema.
#   - Exit 0 on all-pass, 1 on any failure.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib.sh
source "$SCRIPT_DIR/lib.sh"

require_cmd jq "install jq via apt / brew"

VALID_TYPES=(http tcp skip)
DEFAULT_PROBE_PORT_REQUIRED_TYPES=(http tcp)

# Returns 0 if $1 is in the rest of the args.
_in() {
    local needle="$1"; shift
    for v in "$@"; do
        [ "$v" = "$needle" ] && return 0
    done
    return 1
}

validate_one() {
    local slug="$1"
    local d
    d="$(app_dir "$slug")"
    local health="$d/fnos/health.json"
    local manifest="$d/fnos/manifest"

    if [ ! -f "$health" ]; then
        debug "$slug: no health.json (defaults will apply)"
        return 0
    fi

    if [ ! -f "$manifest" ]; then
        fail "$slug: manifest missing, cannot validate health.json"
        return 1
    fi

    # 1. Valid JSON.
    if ! jq -e . <"$health" >/dev/null 2>&1; then
        fail "$slug: health.json is not valid JSON"
        return 1
    fi

    # 2. Required: type.
    local type
    type="$(jq -r '.type // ""' <"$health")"
    if [ -z "$type" ]; then
        fail "$slug: health.json missing required field 'type'"
        return 1
    fi
    if ! _in "$type" "${VALID_TYPES[@]}"; then
        fail "$slug: health.json type='$type' not in (${VALID_TYPES[*]})"
        return 1
    fi

    # 3. Type-specific port resolution.
    if _in "$type" "${DEFAULT_PROBE_PORT_REQUIRED_TYPES[@]}"; then
        local override_port manifest_port effective_port
        override_port="$(jq -r '.port // ""' <"$health")"
        manifest_port="$(manifest_get "$manifest" service_port)"
        effective_port="${override_port:-$manifest_port}"
        if [ -z "$effective_port" ]; then
            fail "$slug: type=$type requires .port or manifest.service_port (both empty)"
            return 1
        fi
        if ! [[ "$effective_port" =~ ^[0-9]+$ ]] || [ "$effective_port" -lt 1 ] || [ "$effective_port" -gt 65535 ]; then
            fail "$slug: effective port '$effective_port' is not a valid 1-65535 value"
            return 1
        fi
    fi

    # 4. Optional: expect_status must be a non-empty array of valid HTTP codes.
    local raw_es
    raw_es="$(jq -c '.expect_status // null' <"$health")"
    if [ "$raw_es" != "null" ]; then
        if ! jq -e 'type == "array" and length > 0' <<<"$raw_es" >/dev/null; then
            fail "$slug: expect_status must be a non-empty array"
            return 1
        fi
        # All entries must be numbers 100-599.
        if ! jq -e 'all(.[]; type == "number" and . >= 100 and . < 600)' <<<"$raw_es" >/dev/null; then
            fail "$slug: expect_status entries must be HTTP codes 100-599"
            return 1
        fi
    fi

    # 4b. Optional: scheme must be http or https (http probe type only).
    local scheme
    scheme="$(jq -r '.scheme // "http"' <"$health")"
    if [ "$scheme" != "http" ] && [ "$scheme" != "https" ]; then
        fail "$slug: scheme='$scheme' must be http or https"
        return 1
    fi
    if [ "$scheme" = "https" ] && [ "$type" != "http" ]; then
        fail "$slug: scheme=https is only meaningful with type=http"
        return 1
    fi

    # 5. Optional: startup_timeout_seconds in [1, 600].
    local timeout
    timeout="$(jq -r '.startup_timeout_seconds // 60' <"$health")"
    if ! [[ "$timeout" =~ ^[0-9]+$ ]] || [ "$timeout" -lt 1 ] || [ "$timeout" -gt 600 ]; then
        fail "$slug: startup_timeout_seconds='$timeout' must be 1-600"
        return 1
    fi

    # 6. Optional: post_install_warmup_seconds in [0, 600].
    local warmup
    warmup="$(jq -r '.post_install_warmup_seconds // 0' <"$health")"
    if ! [[ "$warmup" =~ ^[0-9]+$ ]] || [ "$warmup" -lt 0 ] || [ "$warmup" -gt 600 ]; then
        fail "$slug: post_install_warmup_seconds='$warmup' must be 0-600"
        return 1
    fi

    # 7. Optional: skip_arch is an array of strings, entries in {x86, arm}.
    local skip_arch
    skip_arch="$(jq -c '.skip_arch // []' <"$health")"
    if ! jq -e 'type == "array"' <<<"$skip_arch" >/dev/null; then
        fail "$slug: skip_arch must be an array"
        return 1
    fi
    if ! jq -e 'all(.[]; type == "string" and (. == "x86" or . == "arm"))' <<<"$skip_arch" >/dev/null; then
        fail "$slug: skip_arch entries must be 'x86' or 'arm'"
        return 1
    fi

    # 8. type=skip should be accompanied by a note.
    if [ "$type" = "skip" ]; then
        local note
        note="$(jq -r '.note // ""' <"$health")"
        if [ -z "$note" ]; then
            fail "$slug: type=skip requires a non-empty 'note' explaining why"
            return 1
        fi
    fi

    pass "$slug: health.json valid"
}

main() {
    local apps=("$@")
    if [ "${#apps[@]}" -eq 0 ]; then
        while IFS= read -r _line; do apps+=("$_line"); done < <(list_apps)
    fi

    info "Validating health.json for ${#apps[@]} app(s)"
    for slug in "${apps[@]}"; do
        validate_one "$slug" || true
    done
    report_summary "health-schema"
}

main "$@"
