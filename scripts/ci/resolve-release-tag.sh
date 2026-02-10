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

if [ -n "${REVISION}" ]; then
  RELEASE_TAG="${BASE_TAG}-${REVISION}"
  echo "Manual revision specified: ${RELEASE_TAG}"
elif [ "${EVENT_NAME}" = "schedule" ]; then
  RELEASE_TAG="${BASE_TAG}"
  echo "Scheduled run: using base tag ${RELEASE_TAG}"
else
  if gh release view "${BASE_TAG}" &>/dev/null; then
    HIGHEST_REV=$(
      gh release list --limit 200 --json tagName -q '.[].tagName' | \
        { grep "^${BASE_TAG}-r" || true; } | \
        sed -n "s/.*-r\([0-9]*\)$/\1/p" | sort -n | tail -1
    )
    if [ -n "${HIGHEST_REV}" ]; then
      NEXT_REV=$((HIGHEST_REV + 1))
      RELEASE_TAG="${BASE_TAG}-r${NEXT_REV}"
    else
      RELEASE_TAG="${BASE_TAG}-r1"
    fi
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
