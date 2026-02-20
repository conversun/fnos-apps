#!/bin/bash
# generate-apps-json.sh — Regenerate apps.json from manifests + GitHub releases
# Runs in CI only. The Store app NEVER calls this script.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
REPO="conversun/fnos-apps"
OUTPUT="${REPO_ROOT}/apps.json"

command -v jq >/dev/null 2>&1 || { echo "[ERROR] jq is required" >&2; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "[ERROR] gh CLI is required" >&2; exit 1; }

parse_manifest() {
  local file="$1" key="$2"
  sed -n "s/^${key}[[:space:]]*=[[:space:]]*//p" "$file" | head -1
}

echo "Fetching release list from ${REPO}..."
ALL_RELEASES=$(gh release list --repo "$REPO" --limit 200 --json tagName,publishedAt)

echo "Fetching download statistics..."
DOWNLOAD_DATA=$(gh api "repos/${REPO}/releases" --paginate | jq '[.[] | {tag: .tag_name, downloads: ([.assets[].download_count] | add // 0)}]')

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

APPS_JSON="[]"

for app_dir in "${REPO_ROOT}"/scripts/apps/*/; do
  [ -f "${app_dir}/meta.env" ] || continue

  slug=$(basename "$app_dir")

  FILE_PREFIX=""
  RELEASE_TITLE=""
  DEFAULT_PORT=""
  HOMEPAGE_URL=""
  source "${app_dir}/meta.env"

  manifest="${REPO_ROOT}/apps/${slug}/fnos/manifest"
  if [ ! -f "$manifest" ]; then
    echo "[WARN] No manifest for ${slug}, skipping" >&2
    continue
  fi

  appname=$(parse_manifest "$manifest" "appname")
  display_name=$(parse_manifest "$manifest" "display_name")
  desc=$(parse_manifest "$manifest" "desc")
  service_port=$(parse_manifest "$manifest" "service_port")

  service_port="${service_port:-$DEFAULT_PORT}"

  if [ -z "$HOMEPAGE_URL" ]; then
    HOMEPAGE_URL=$(parse_manifest "$manifest" "maintainer_url")
  fi
  HOMEPAGE_URL="${HOMEPAGE_URL%\"}"
  HOMEPAGE_URL="${HOMEPAGE_URL#\"}"

  latest_release=$(echo "$ALL_RELEASES" | jq -r \
    --arg prefix "${slug}/" \
    '[.[] | select(.tagName | startswith($prefix))] | sort_by(.publishedAt) | last // empty')

  if [ -z "$latest_release" ] || [ "$latest_release" = "null" ]; then
    echo "[WARN] No release found for ${slug}, skipping" >&2
    continue
  fi

  release_tag=$(echo "$latest_release" | jq -r '.tagName')
  updated_at=$(echo "$latest_release" | jq -r '.publishedAt')

  download_count=$(echo "$DOWNLOAD_DATA" | jq \
    --arg prefix "${slug}/" \
    '[.[] | select(.tag | startswith($prefix)) | .downloads] | add // 0')

  tag_version="${release_tag#${slug}/v}"
  version="${tag_version%%-r[0-9]*}"
  fpk_version="$tag_version"

  icon_url="https://raw.githubusercontent.com/${REPO}/main/apps/${slug}/fnos/ICON_256.PNG"

  app_type="native"
  if [ -f "${REPO_ROOT}/apps/${slug}/fnos/docker/docker-compose.yaml" ]; then
    app_type="docker"
  fi

  app_obj=$(jq -n \
    --arg slug "$slug" \
    --arg appname "$appname" \
    --arg file_prefix "$FILE_PREFIX" \
    --arg display_name "$display_name" \
    --arg description "$desc" \
    --arg version "$version" \
    --arg fpk_version "$fpk_version" \
    --arg release_tag "$release_tag" \
    --argjson service_port "$service_port" \
    --arg homepage_url "$HOMEPAGE_URL" \
    --arg icon_url "$icon_url" \
    --arg updated_at "$updated_at" \
    --argjson download_count "$download_count" \
    --arg app_type "$app_type" \
    '{
      slug: $slug,
      appname: $appname,
      file_prefix: $file_prefix,
      display_name: $display_name,
      description: $description,
      version: $version,
      fpk_version: $fpk_version,
      release_tag: $release_tag,
      service_port: $service_port,
      homepage_url: $homepage_url,
      icon_url: $icon_url,
      platforms: ["x86", "arm"],
      updated_at: $updated_at,
      download_count: $download_count,
      app_type: $app_type
    }')

  APPS_JSON=$(echo "$APPS_JSON" | jq --argjson app "$app_obj" '. + [$app]')
  echo "  ✓ ${slug} → ${release_tag}"
done

APPS_JSON=$(echo "$APPS_JSON" | jq 'sort_by(.slug)')

jq -n \
  --argjson schema_version 1 \
  --arg generated_at "$NOW" \
  --arg source_name "$REPO" \
  --arg source_url "https://github.com/${REPO}" \
  --argjson apps "$APPS_JSON" \
  '{
    schema_version: $schema_version,
    generated_at: $generated_at,
    source: {
      name: $source_name,
      url: $source_url
    },
    apps: $apps
  }' > "$OUTPUT"

app_count=$(jq '.apps | length' "$OUTPUT")
echo ""
echo "Generated ${OUTPUT} with ${app_count} apps."
