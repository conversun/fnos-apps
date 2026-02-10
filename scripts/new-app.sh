#!/bin/bash
set -e

# Scaffold a new fnOS app in the monorepo.
#
# Usage: ./scripts/new-app.sh <appname> <display_name> <port>
#
# Example: ./scripts/new-app.sh jellyfin "Jellyfin Media Server" 8096

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

APPNAME="$1"
DISPLAY_NAME="$2"
PORT="$3"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

[ -z "$APPNAME" ] && error "Usage: $0 <appname> <display_name> <port>"
[ -z "$DISPLAY_NAME" ] && error "Usage: $0 <appname> <display_name> <port>"
[ -z "$PORT" ] && error "Usage: $0 <appname> <display_name> <port>"

APP_DIR="$REPO_ROOT/apps/$APPNAME"
SCRIPTS_APP_DIR="$REPO_ROOT/scripts/apps/$APPNAME"
[ -d "$APP_DIR" ] && error "App directory already exists: $APP_DIR"
[ -d "$SCRIPTS_APP_DIR" ] && error "Scripts app directory already exists: $SCRIPTS_APP_DIR"

info "Creating app: $APPNAME ($DISPLAY_NAME) on port $PORT"

# Create directory structure
mkdir -p "$APP_DIR/fnos/"{bin,cmd,config,ui/images}
mkdir -p "$SCRIPTS_APP_DIR"

# manifest
cat > "$APP_DIR/fnos/manifest" << EOF
appname         = $APPNAME
version         = 0.0.0
display_name    = $DISPLAY_NAME
platform        = x86
maintainer      = TODO
maintainer_url  = TODO
distributor     = conversun
distributor_url = https://github.com/conversun/fnos-apps
desktop_uidir   = ui
desktop_applaunchname = ${APPNAME}.Application
service_port    = $PORT
desc            = TODO: Add description
source          = thirdparty
checksum        = 
EOF

# service-setup
cat > "$APP_DIR/fnos/cmd/service-setup" << 'EOF'
#!/bin/bash

LOG_FILE="${TRIM_PKGVAR}/${TRIM_APPNAME}.log"
PID_FILE="${TRIM_PKGVAR}/${TRIM_APPNAME}.pid"

APP_DIR="${TRIM_APPDEST}"
APP_DATA_DIR="${TRIM_PKGVAR}"

SERVICE_COMMAND="$APP_DIR/bin/TODO-server $APP_DATA_DIR"
SVC_BACKGROUND=y
SVC_WRITE_PID=y
EOF

# bin/server launcher
cat > "$APP_DIR/fnos/bin/${APPNAME}-server" << 'EOF'
#!/bin/sh
APP_DIR="${TRIM_APPDEST}"
APP_DATA_DIR=$1

# TODO: Set environment variables for the app

cd $APP_DIR || exit 1
# TODO: exec ./your-binary
EOF
chmod +x "$APP_DIR/fnos/bin/${APPNAME}-server"

# config/privilege
cat > "$APP_DIR/fnos/config/privilege" << EOF
{
    "defaults": {
        "run-as": "package"
    },
    "username": "$APPNAME",
    "groupname": "$APPNAME"
}
EOF

# config/resource
cat > "$APP_DIR/fnos/config/resource" << EOF
{
    "data-share": {
        "shares": [
            {
                "name": "$DISPLAY_NAME",
                "permission": {
                    "rw": [
                        "$APPNAME"
                    ]
                }
            }
        ]
    },
    "systemd-unit": {
    }
}
EOF

# ui/config
cat > "$APP_DIR/fnos/ui/config" << EOF
{
    ".url": {
        "${APPNAME}.Application":
        {
            "title": "$DISPLAY_NAME",
            "desc": "$DISPLAY_NAME",
            "icon": "images/{0}.png",
            "type": "url",
            "port": "$PORT",
            "protocol": "http",
            "url": "/",
            "allUsers": true
        }
    }
}
EOF

# Placeholder README
cat > "$APP_DIR/README.md" << EOF
# $DISPLAY_NAME for fnOS

TODO: Add description and build instructions.

## Local Build

\`\`\`bash
cd apps/$APPNAME && bash ../../scripts/build-fpk.sh . app.tgz
\`\`\`
EOF

# Create scripts/apps/{app}/ contract structure

# meta.env - Static metadata
cat > "$SCRIPTS_APP_DIR/meta.env" << EOF
FILE_PREFIX=${APPNAME}
RELEASE_TITLE="$DISPLAY_NAME"
DEFAULT_PORT=$PORT
HOMEPAGE_URL="TODO"
EOF

# get-latest-version.sh - Version resolution
cat > "$SCRIPTS_APP_DIR/get-latest-version.sh" << 'EOF'
#!/bin/bash
set -euo pipefail

INPUT_VERSION="${1:-}"

# TODO: Implement version resolution logic
# This script should:
# 1. Query upstream API or repository for latest version
# 2. If INPUT_VERSION is provided, validate and use it
# 3. Output VERSION=x.y.z (required)
# 4. Optionally output FULL_VERSION=... or UPSTREAM_TAG=...
# 5. If GITHUB_OUTPUT is set, write variables to it

VERSION="${INPUT_VERSION:-0.0.0}"

[ -z "$VERSION" ] && { echo "Failed to resolve version" >&2; exit 1; }

echo "VERSION=$VERSION"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=$VERSION" >> "$GITHUB_OUTPUT"
fi
EOF
chmod +x "$SCRIPTS_APP_DIR/get-latest-version.sh"

# build.sh - Build logic
cat > "$SCRIPTS_APP_DIR/build.sh" << 'EOF'
#!/bin/bash
set -euo pipefail

VERSION="${1:-}"
ARCH="${2:-$(uname -m)}"

[ -z "$VERSION" ] && { echo "VERSION is required" >&2; exit 1; }

echo "==> Building $VERSION for $ARCH"

# TODO: Implement build logic
# This script should:
# 1. Download upstream binary/source for the given VERSION
# 2. Extract and prepare the application
# 3. Create app_root/ directory with the application structure
# 4. Package into app.tgz in the current directory
# 5. Exit with 0 on success, non-zero on failure

# Placeholder: create minimal app.tgz
mkdir -p app_root
cd app_root
tar -czf ../app.tgz .
EOF
chmod +x "$SCRIPTS_APP_DIR/build.sh"

# release-notes.tpl - Release notes template
cat > "$SCRIPTS_APP_DIR/release-notes.tpl" << 'EOF'
自动构建的 fnOS 安装包

- 基于 $RELEASE_TITLE ${VERSION}
- 平台: fnOS
- 默认端口: ${DEFAULT_PORT}${REVISION_NOTE}

**国内镜像**:
- [${FILE_PREFIX}_${VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${VERSION}_x86.fpk)
- [${FILE_PREFIX}_${VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${VERSION}_arm.fpk)
EOF

# Create .github/workflows/build-{app}.yml entry workflow
WORKFLOW_FILE="$REPO_ROOT/.github/workflows/build-${APPNAME}.yml"
cat > "$WORKFLOW_FILE" << EOF
name: Build $DISPLAY_NAME fnOS Package

permissions:
  contents: write

on:
  push:
    paths:
      - 'apps/$APPNAME/**'
      - 'shared/**'
      - '!**/*.md'
  schedule:
    - cron: '0 8 * * *'
  workflow_dispatch:
    inputs:
      version:
        description: 'Version (leave empty for latest)'
        required: false
        default: ''
      revision:
        description: 'Revision suffix (e.g., r2 for re-release, leave empty for auto)'
        required: false
        default: ''

jobs:
  build:
    uses: ./.github/workflows/reusable-build-app.yml
    with:
      app: $APPNAME
      version: \${{ github.event.inputs.version || '' }}
      revision: \${{ github.event.inputs.revision || '' }}
      event_name: \${{ github.event_name }}
    secrets: inherit
EOF

info "App scaffolded at: apps/$APPNAME/"
info "App contract at: scripts/apps/$APPNAME/"
info ""
info "Next steps:"
info "  1. Add app icons to apps/$APPNAME/fnos/ICON.PNG and ICON_256.PNG"
info "  2. Add UI icon to apps/$APPNAME/fnos/ui/images/64.png (256.png is auto-generated from ICON_256.PNG)"
info "  3. Edit fnos/bin/${APPNAME}-server with correct launch command"
info "  4. Edit fnos/cmd/service-setup with correct SERVICE_COMMAND"
info "  5. Implement scripts/apps/$APPNAME/get-latest-version.sh"
info "  6. Implement scripts/apps/$APPNAME/build.sh"
info "  7. Update scripts/apps/$APPNAME/meta.env with HOMEPAGE_URL"
info "  8. Update scripts/apps/$APPNAME/release-notes.tpl with app-specific notes"
info "  9. Fill in manifest TODO fields"
