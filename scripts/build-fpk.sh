#!/bin/bash
set -e

# Build fnOS .fpk package by merging shared framework with app-specific files.
#
# Usage: ./scripts/build-fpk.sh <app-dir> <app-tgz> [version] [platform]
#   app-dir   - Path to app directory (e.g., apps/plex)
#   app-tgz   - Path to pre-built app.tgz
#   version   - Override version in manifest (optional)
#   platform  - Override platform in manifest (optional)
#
# The fpk is written to the current directory.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SHARED_DIR="$REPO_ROOT/shared"

APP_DIR="$1"
APP_TGZ="$2"
VERSION="$3"
PLATFORM="$4"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

require_manifest_key() {
    local key="$1"
    grep -q "^${key}[[:space:]]*=" "$APP_DIR/fnos/manifest" || error "manifest missing key: ${key}"
}

[ -z "$APP_DIR" ] && error "Usage: $0 <app-dir> <app-tgz> [version] [platform]"
[ -z "$APP_TGZ" ] && error "Usage: $0 <app-dir> <app-tgz> [version] [platform]"
[ -d "$APP_DIR/fnos" ] || error "App directory not found: $APP_DIR/fnos"
[ -f "$APP_TGZ" ] || error "app.tgz not found: $APP_TGZ"
[ -d "$APP_DIR/fnos/cmd" ] || error "Missing directory: $APP_DIR/fnos/cmd"
[ -d "$APP_DIR/fnos/config" ] || error "Missing directory: $APP_DIR/fnos/config"
[ -d "$APP_DIR/fnos/ui" ] || error "Missing directory: $APP_DIR/fnos/ui"
[ -f "$APP_DIR/fnos/ICON.PNG" ] || error "Missing icon: $APP_DIR/fnos/ICON.PNG"
[ -f "$APP_DIR/fnos/ICON_256.PNG" ] || error "Missing icon: $APP_DIR/fnos/ICON_256.PNG"

require_manifest_key "appname"
require_manifest_key "version"
require_manifest_key "display_name"
require_manifest_key "service_port"
require_manifest_key "source"

# Read appname from manifest
APPNAME=$(grep "^appname" "$APP_DIR/fnos/manifest" | awk -F'=' '{print $2}' | tr -d ' ')
[ -z "$APPNAME" ] && error "Cannot read appname from manifest"

info "Building fpk for: $APPNAME"

# Calculate checksum
CHECKSUM=$(md5sum "$APP_TGZ" | cut -d' ' -f1 2>/dev/null || md5 -q "$APP_TGZ")

# Build package directory
WORK_DIR=$(mktemp -d)
PKG_DIR="$WORK_DIR/package"
mkdir -p "$PKG_DIR/cmd"

# 1. Copy app.tgz
cp "$APP_TGZ" "$PKG_DIR/app.tgz"

# 2. Copy shared framework cmd/* (exclude non-script files)
for f in "$SHARED_DIR"/cmd/*; do
    case "$(basename "$f")" in
        *.md|*.MD) continue ;;
    esac
    cp "$f" "$PKG_DIR/cmd/"
done

# 3. Overlay app-specific cmd/* (overrides shared files)
if [ -d "$APP_DIR/fnos/cmd" ]; then
    cp "$APP_DIR"/fnos/cmd/* "$PKG_DIR/cmd/" 2>/dev/null || true
fi

# 4. Copy config/
if [ -d "$APP_DIR/fnos/config" ]; then
    cp -a "$APP_DIR/fnos/config" "$PKG_DIR/"
fi

# 5. Copy wizard/ - app-specific first, fall back to shared
if [ -d "$APP_DIR/fnos/wizard" ]; then
    cp -a "$APP_DIR/fnos/wizard" "$PKG_DIR/"
elif [ -d "$SHARED_DIR/wizard" ]; then
    cp -a "$SHARED_DIR/wizard" "$PKG_DIR/"
fi

# 6. Copy port forwarding config (*.sc)
cp "$APP_DIR"/fnos/*.sc "$PKG_DIR/" 2>/dev/null || true

# 7. Copy icons
cp "$APP_DIR"/fnos/ICON*.PNG "$PKG_DIR/" 2>/dev/null || true

# 8. Copy ui/
if [ -d "$APP_DIR/fnos/ui" ]; then
    cp -a "$APP_DIR/fnos/ui" "$PKG_DIR/"
fi

# 9. Build manifest
cp "$APP_DIR/fnos/manifest" "$PKG_DIR/manifest"

if [ -n "$VERSION" ]; then
    sed -i.tmp "s/^version.*/version         = ${VERSION}/" "$PKG_DIR/manifest"
fi
if [ -n "$PLATFORM" ]; then
    if grep -q "^platform" "$PKG_DIR/manifest"; then
        sed -i.tmp "s/^platform.*/platform        = ${PLATFORM}/" "$PKG_DIR/manifest"
    else
        echo "platform        = ${PLATFORM}" >> "$PKG_DIR/manifest"
    fi
fi
sed -i.tmp "s/^checksum.*/checksum        = ${CHECKSUM}/" "$PKG_DIR/manifest"
rm -f "$PKG_DIR/manifest.tmp"

# Determine output filename
MANIFEST_VERSION=$(grep "^version" "$PKG_DIR/manifest" | awk -F'=' '{print $2}' | tr -d ' ')
MANIFEST_PLATFORM=$(grep "^platform" "$PKG_DIR/manifest" | awk -F'=' '{print $2}' | tr -d ' ')
FPK_NAME="${APPNAME}_${MANIFEST_VERSION}_${MANIFEST_PLATFORM:-x86}.fpk"

# 11. Create fpk
cd "$PKG_DIR"
[ -f "app.tgz" ] || error "packaging validation failed: app.tgz missing"
[ -f "manifest" ] || error "packaging validation failed: manifest missing"
[ -d "cmd" ] || error "packaging validation failed: cmd missing"
[ -d "config" ] || error "packaging validation failed: config missing"
[ -f "ICON.PNG" ] || error "packaging validation failed: ICON.PNG missing"
[ -f "ICON_256.PNG" ] || error "packaging validation failed: ICON_256.PNG missing"
tar -czf "$OLDPWD/$FPK_NAME" *
cd "$OLDPWD"

# Cleanup
rm -rf "$WORK_DIR"

info "Built: $FPK_NAME ($(du -h "$FPK_NAME" | cut -f1))"
echo "$FPK_NAME"
