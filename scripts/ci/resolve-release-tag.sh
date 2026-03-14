#!/bin/bash
set -euo pipefail

APP_SLUG="${1:-}"
VERSION="${2:-}"
EVENT_NAME="${3:-}"
REVISION="${4:-}"

error() {
  echo "[ERROR] $1" >&2
  exit 1
}

emit_output() {
  local key="$1"
  local value="$2"
  if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "${key}=${value}" >> "${GITHUB_OUTPUT}"
  else
    echo "${key}=${value}"
  fi
}

[ -z "${APP_SLUG}" ] && error "APP_SLUG is required"
[ -z "${VERSION}" ] && error "VERSION is required"
[ -z "${EVENT_NAME}" ] && error "EVENT_NAME is required"

BASE_TAG="${APP_SLUG}/v${VERSION}"

# Find all existing releases for this version (base tag and any -rN revisions).
# Cleanup step deletes old revisions, so we must check both base and -rN to
# detect whether this version has ever been released.
EXISTING_TAGS=$(
  gh release list --limit 200 --json tagName -q '.[].tagName' | \
    { grep -E "^${BASE_TAG}(-r[0-9]+)?$" || true; }
)

if [ -n "${REVISION}" ]; then
  RELEASE_TAG="${BASE_TAG}-${REVISION}"
  echo "Manual revision specified: ${RELEASE_TAG}"
elif [ "${EVENT_NAME}" = "schedule" ]; then
  if [ -n "${EXISTING_TAGS}" ]; then
    # Version already released (possibly as -rN after cleanup deleted base).
    # Schedule builds are for NEW upstream versions only — skip.
    echo "Scheduled run: version ${VERSION} already released (${EXISTING_TAGS}), skipping"
    emit_output "release_tag" "${BASE_TAG}"
    emit_output "should_build" "false"
    emit_output "fpk_version" "${VERSION}"
    exit 0
  fi
  RELEASE_TAG="${BASE_TAG}"
  echo "Scheduled run: new version ${RELEASE_TAG}"
else
  if [ -n "${EXISTING_TAGS}" ]; then
    HIGHEST_REV=$(
      echo "${EXISTING_TAGS}" | \
        sed -n "s/.*-r\([0-9]*\)$/\1/p" | sort -n | tail -1
    )
    if [ -n "${HIGHEST_REV}" ]; then
      NEXT_REV=$((HIGHEST_REV + 1))
    else
      NEXT_REV=1
    fi
    RELEASE_TAG="${BASE_TAG}-r${NEXT_REV}"
    echo "Version exists, using revision: ${RELEASE_TAG}"
  else
    RELEASE_TAG="${BASE_TAG}"
    echo "New version: ${RELEASE_TAG}"
  fi
fi

if gh release view "${RELEASE_TAG}" &>/dev/null; then
  SHOULD_BUILD="false"
  echo "Release ${RELEASE_TAG} already exists, skipping"
else
  SHOULD_BUILD="true"
fi

# fpk_version: version string for fpk filename (includes -rN if revision)
if [[ "${RELEASE_TAG}" =~ -r[0-9]+$ ]]; then
  FPK_VERSION="${VERSION}${BASH_REMATCH[0]}"
else
  FPK_VERSION="${VERSION}"
fi

emit_output "release_tag" "${RELEASE_TAG}"
emit_output "should_build" "${SHOULD_BUILD}"
emit_output "fpk_version" "${FPK_VERSION}"
