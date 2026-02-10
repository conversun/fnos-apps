# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Summary

Monorepo packaging third-party apps (Plex, Emby, qBittorrent, Nginx) as `.fpk` installers for fnOS NAS. 100% Bash — downloads upstream binaries, merges with shared lifecycle framework, outputs `.fpk` tarballs. Daily CI auto-syncs upstream versions. See `AGENTS.md` for detailed knowledge base.

## Build Commands

```bash
# Build an app locally (from repo root)
cd apps/plex && ./update_plex.sh                        # latest version, auto-detect arch
cd apps/plex && ./update_plex.sh --arch arm              # force ARM build
cd apps/plex && ./update_plex.sh --arch x86 1.42.2.10156 # specific version + arch

# Same pattern for all apps
cd apps/emby && ./update_emby.sh
cd apps/qbittorrent && ./update_qbittorrent.sh
cd apps/nginx && ./update_nginx.sh

# Generic fpk packager (used by CI, rarely needed locally)
./scripts/build-fpk.sh apps/plex app.tgz [version] [platform]

# Scaffold a new app
./scripts/new-app.sh <name> "<display name>" <port>
```

## Validation (No Test Framework)

There is no test framework. Validation is structural only:
- `bash -n <script>` for syntax checking
- `scripts/build-fpk.sh` validates manifest keys, icon files, and directory structure before packaging
- Functional testing requires a real fnOS device

No linting tools (shellcheck, etc.) are configured.

## Architecture

### Plugin Contract System

Each app implements a standardized contract in `scripts/apps/<app>/`:

| File | Purpose | Key Output |
|------|---------|------------|
| `meta.env` | Static metadata (sourced) | `FILE_PREFIX`, `RELEASE_TITLE`, `DEFAULT_PORT` |
| `get-latest-version.sh` | Query upstream for latest version | `VERSION=x.y.z` to stdout + `$GITHUB_OUTPUT` |
| `build.sh` | Download upstream + create `app.tgz` | `app.tgz` in cwd |
| `release-notes.tpl` | Release notes template | `${VARIABLE}` placeholders for `envsubst` |

Full contract spec: `scripts/apps/README.md`

### Overlay Packaging Pattern

`.fpk` files are built by layering:
1. `shared/cmd/` — common lifecycle hooks (install/upgrade/uninstall/start/stop)
2. `apps/<app>/fnos/cmd/` — app-specific overrides (wins on conflict)
3. `apps/<app>/fnos/config/`, `ui/`, icons, manifest

Core lifecycle framework: `shared/cmd/common` (~375 lines)

### Local Build Library

`scripts/lib/update-common.sh` provides shared functions for all `update_*.sh` scripts. Each app's update script defines callbacks (`app_set_arch_vars`, `app_get_latest_version`, `app_download`, `app_build_app_tgz`) then sources the library and calls `main "$@"`.

### CI Pipeline

```
Per-app entry workflow (.github/workflows/build-<app>.yml)
  → Reusable workflow (reusable-build-app.yml)
    → check-version: source meta.env + get-latest-version.sh + resolve-release-tag.sh
    → build: matrix [x86, arm] → build.sh + build-fpk.sh
    → release: create GitHub release with release-notes.tpl
```

CI is idempotent — skips if release tag already exists. Version tags: `<app>/v<version>` with `-r2`, `-r3` auto-increment for rebuilds.

## Key Conventions

- **Language**: Chinese for user-facing messages (info/warn/error), English for code comments
- **Architecture**: Always dual-build x86 + arm. Detect via `uname -m` or `--arch` flag
- **Manifest format**: Fixed-width alignment at column 16 (`appname         = value`)
- **Color output helpers**: `info()` green, `warn()` yellow, `error()` red + exit
- **Cleanup**: All scripts use `trap cleanup EXIT` for temp dir removal
- **fnOS runtime env vars**: `TRIM_APPNAME`, `TRIM_APPDEST`, `TRIM_PKGVAR`, `TRIM_PKGETC`, `TRIM_PKGHOME`

## Anti-Patterns

- Never modify upstream binaries — download and repackage only
- Never hardcode architecture — always use detection or `--arch` flag
- Never duplicate `shared/cmd/` logic in app-specific overrides — only override what differs
- Never skip checksum — `app.tgz` md5 must be written to manifest
- Never create per-app CI build scripts in `scripts/ci/` — use `scripts/apps/<app>/build.sh`
