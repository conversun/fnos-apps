#!/bin/bash
# Behavioural tests for release decisions when either remote query fails.
# Uses exported functions so the real resolver runs without network access.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./lib.sh
source "$SCRIPT_DIR/lib.sh"
RESOLVER="$(repo_root)/scripts/ci/resolve-release-tag.sh"
SANDBOX="$(mktemp -d "${TMPDIR:-/tmp}/fnos-release-tag.XXXXXX")" || exit 1
trap 'rm -rf "$SANDBOX"' EXIT

git() {
    [ "$1" = "ls-remote" ] || return 99
    printf '%s\n' "$MOCK_GIT_TAGS" |
        awk 'NF {print "deadbeef\trefs/tags/" $0}'
    return "$MOCK_GIT_STATUS"
}
gh() {
    case "$1 $2" in
        "release list")
            printf '%s\n' "$MOCK_RELEASE_TAGS"
            return "$MOCK_RELEASE_STATUS"
            ;;
        "release view") return "$MOCK_VIEW_STATUS" ;;
        *) return 99 ;;
    esac
}

run_case() {
    local name="$1" git_status="$2" release_status="$3" git_tags="$4"
    local release_tags="$5" event="$6" revision="$7" expected_status="$8"
    local expected_tag="$9" expected_build="${10}" expected_version="${11}"
    local actual_status=0 expected_output=""
    (
        export MOCK_GIT_STATUS="$git_status" MOCK_RELEASE_STATUS="$release_status"
        export MOCK_GIT_TAGS="$git_tags" MOCK_RELEASE_TAGS="$release_tags"
        export MOCK_VIEW_STATUS="${12:-1}"
        export -f git gh
        export GITHUB_OUTPUT="$SANDBOX/output"
        : > "$GITHUB_OUTPUT"
        bash "$RESOLVER" ollama 0.40.11 "$event" "$revision"
    ) > "$SANDBOX/stdout" 2> "$SANDBOX/stderr" || actual_status=$?

    if [ "$actual_status" -eq "$expected_status" ]; then
        pass "$name: exit $actual_status"
    else
        fail "$name: expected exit $expected_status, got $actual_status"
    fi
    if [ "$expected_status" -eq 0 ]; then
        expected_output="$(printf 'release_tag=%s\nshould_build=%s\nfpk_version=%s' \
            "$expected_tag" "$expected_build" "$expected_version")"
    fi
    if [ "$(< "$SANDBOX/output")" = "$expected_output" ]; then
        pass "$name: exact decision outputs"
    else
        fail "$name: unexpected decision outputs [$(< "$SANDBOX/output")]"
    fi
    if [ "$git_status" -ne 0 ] || [ "$release_status" -ne 0 ]; then
        if [ -s "$SANDBOX/stderr" ]; then
            pass "$name: query failure is visible"
        else
            fail "$name: query failure was silent"
        fi
    fi
}

BASE="ollama/v0.40.11"
run_case existing 0 0 "$BASE" "$BASE" schedule "" 0 "$BASE" false 0.40.11
run_case new_version 0 0 "" "" schedule "" 0 "$BASE" true 0.40.11
run_case deleted_release 0 0 "$BASE-r3" "" schedule "" 0 "$BASE" false 0.40.11
run_case annotated_tag 0 0 "$BASE^{}" "" schedule "" 0 "$BASE" false 0.40.11
run_case manual_union 0 0 "$BASE-r3" "$BASE-r5" workflow_dispatch "" 0 "$BASE-r6" true 0.40.11-r6
run_case explicit_revision 0 0 "$BASE" "$BASE" workflow_dispatch r8 0 "$BASE-r8" true 0.40.11-r8
run_case explicit_existing 0 0 "$BASE-r8" "$BASE-r8" workflow_dispatch r8 0 "$BASE-r8" false 0.40.11-r8 0
run_case exact_version 0 0 "$BASE"'0' "$BASE"'0' schedule "" 0 "$BASE" true 0.40.11

run_case release_failure_existing 0 1 "$BASE" "" schedule "" 0 "$BASE" false 0.40.11
run_case release_failure_new 0 1 "" "" schedule "" 0 "$BASE" true 0.40.11
run_case release_failure_manual 0 1 "$BASE-r3" "$BASE-r99" workflow_dispatch "" 0 "$BASE-r4" true 0.40.11-r4
run_case git_failure_existing 128 0 "" "$BASE" schedule "" 0 "$BASE" false 0.40.11
run_case git_failure_unknown 128 0 "" "" schedule "" 1 "" "" ""
run_case git_failure_manual 128 0 "" "$BASE-r3" workflow_dispatch "" 1 "" "" ""
run_case git_failure_revision 128 0 "" "$BASE" schedule r8 1 "" "" ""
run_case git_failure_partial 128 0 "$BASE" "" schedule "" 1 "" "" ""
run_case both_failure 128 1 "" "" schedule "" 1 "" "" ""
run_case both_failure_partial 128 1 "$BASE" "$BASE" schedule "" 1 "" "" ""

report_summary "test-resolve-release-tag"
