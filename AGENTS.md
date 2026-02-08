# PROJECT KNOWLEDGE BASE

**Generated:** 2026-02-06
**Commit:** bb6e075
**Branch:** main

## OVERVIEW

Monorepo packaging third-party apps (Plex, Emby, qBittorrent) as `.fpk` installers for fnOS NAS. Pure bash — downloads upstream binaries, merges with shared lifecycle framework, outputs `.fpk` tarballs. Daily CI auto-syncs upstream versions.

## STRUCTURE

```
fnos-apps/
├── shared/              # Shared lifecycle framework (all apps inherit)
│   ├── cmd/             # Daemon mgmt, install/upgrade/uninstall hooks (see shared/cmd/AGENTS.md)
│   └── wizard/          # Default uninstall wizard (JSON)
├── apps/
│   ├── plex/            # Plex: port 32400, downloads .deb from plex.tv API
│   ├── emby/            # Emby: port 8096, downloads .deb from GitHub Releases
│   ├── qbittorrent/     # qBittorrent: port 8085, downloads static binary. Most complex app.
│   └── nginx/           # Nginx: port 8888, reverse proxy and HTTP server
├── scripts/
│   ├── build-fpk.sh     # Generic fpk packager (shared + app-specific → .fpk)
│   ├── new-app.sh       # Scaffold new app: ./scripts/new-app.sh <name> <display> <port>
│   ├── apps/            # Per-app build contracts (meta.env, build.sh, get-latest-version.sh, release-notes.tpl)
│   │   ├── plex/
│   │   ├── emby/
│   │   ├── qbittorrent/
│   │   └── nginx/
│   ├── lib/             # Shared build utilities
│   │   └── update-common.sh  # Common functions for app builds
│   └── ci/              # CI helper scripts
│       └── resolve-release-tag.sh  # Version tag resolution with -r2/-r3 auto-increment
└── .github/workflows/   # Per-app CI: check-version → build (x86+arm matrix) → release
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add new app | `scripts/new-app.sh` | Generates full skeleton with TODO markers |
| Understand app lifecycle | `shared/cmd/common` | 352-line core: daemon start/stop, install hooks, logging |
| Service entry point | `shared/cmd/main` | start/stop/status dispatcher, sources `common` + `service-setup` |
| App-specific service config | `apps/*/fnos/cmd/service-setup` | Sets SERVICE_COMMAND, PID/LOG paths |
| App-specific overrides | `apps/*/fnos/cmd/` | Files here overlay shared/cmd/ in fpk |
| Build locally | `apps/*/update_*.sh` | Downloads upstream, builds app.tgz + fpk |
| App build contract | `scripts/apps/<app>/` | meta.env, build.sh, get-latest-version.sh, release-notes.tpl |
| Build utilities | `scripts/lib/update-common.sh` | Shared functions: info(), warn(), error(), cleanup trap |
| Version tag resolution | `scripts/ci/resolve-release-tag.sh` | Determines release tag with -r2/-r3 auto-increment |
| Generic fpk packager | `scripts/build-fpk.sh` | Unified packaging: shared + app-specific → .fpk |
| CI/CD pipeline | `.github/workflows/reusable-build-app.yml` | Reusable workflow: check-version → build (matrix) → release |
| App metadata | `apps/*/fnos/manifest` | Key=value: appname, version, port, checksum |
| User/group permissions | `apps/*/fnos/config/privilege` | JSON: run-as user, extra groups (video/render for Plex) |
| Port forwarding rules | `apps/*/fnos/*.sc` | fnOS firewall port config |
| Desktop UI entry | `apps/*/fnos/ui/config` | JSON: app launcher URL, port, icon paths |
| Icons | `apps/*/fnos/ICON*.PNG` + `ui/images/` | ICON.PNG (small) + ICON_256.PNG (large) |

## CONVENTIONS

- **Language**: 100% bash. No package managers, no compiled languages.
- **Manifest format**: Fixed-width alignment at column 16 (`appname         = value`).
- **fpk = tar.gz** containing: `app.tgz` + `cmd/` + `config/` + `wizard/` + `manifest` + icons + UI.
- **Overlay pattern**: `shared/cmd/*` copied first, then `apps/*/fnos/cmd/*` overwrites. App-specific wins.
- **Architecture**: Always dual-build x86 + arm. Detect via `uname -m`.
- **Version tags**: Namespaced — `plex/v1.42.2.10156`, `qbittorrent/v5.1.4-r2`.
- **Revision suffix**: `-r2`, `-r3` auto-incremented for same-version re-releases.
- **Scripts use Chinese** for user-facing messages (info/warn/error), English for code comments.
- **Color output**: `info()` green, `warn()` yellow, `error()` red+exit.
- **Cleanup trap**: All update scripts use `trap cleanup EXIT` with temp dir removal.
- **TRIM_* env vars**: Provided by fnOS at runtime — `TRIM_APPNAME`, `TRIM_APPDEST`, `TRIM_PKGVAR`, `TRIM_PKGETC`, `TRIM_PKGHOME`, `TRIM_TEMP_LOGFILE`, `TRIM_TEMP_UPGRADE_FOLDER`, `TRIM_APP_STATUS`.

## ANTI-PATTERNS (THIS PROJECT)

- **NEVER modify upstream binaries** — download and repackage only. Transparency is the core principle.
- **NEVER hardcode architecture** — always use `uname -m` detection or `--arch` flag.
- **DO NOT duplicate shared/cmd/ logic in app-specific cmd/** — only override what differs.
- **DO NOT skip checksum** — `app.tgz` md5 must be written to manifest.
- **DO NOT create per-app build scripts in scripts/ci/** — use `scripts/apps/<app>/build.sh` instead.

## UNIQUE STYLES

- **qBittorrent is the outlier**: Ships pre-configured with hardcoded `admin/adminadmin` creds, Chinese locale, disabled CSRF/clickjacking for fnOS reverse proxy compat. Uses `service_postupgrade` hook for config initialization.
- **Plex needs hardware transcoding groups**: `privilege` config adds `video` + `render` groups.
- **Emby service launcher**: Unique env vars (`LD_LIBRARY_PATH`, `EMBY_DATA_PATH`).
- **No tests**: Zero test infrastructure. Validation is manual + CI build success.
- **No linting/formatting**: No shellcheck, no editorconfig. Scripts follow loose bash conventions.

## COMMANDS

```bash
# Scaffold new app
./scripts/new-app.sh jellyfin "Jellyfin Media Server" 8096

# Build locally (each app independently)
cd apps/plex && ./update_plex.sh                    # latest, auto-detect arch
cd apps/plex && ./update_plex.sh --arch arm          # force ARM
cd apps/emby && ./update_emby.sh
cd apps/qbittorrent && ./update_qbittorrent.sh
cd apps/nginx && ./update_nginx.sh

# Generic fpk packager (used by CI)
./scripts/build-fpk.sh apps/plex app.tgz [version] [platform]
```

## NOTES

- **CI triggers**: push to `apps/*/` or `shared/`, daily cron at 08:00 UTC, manual dispatch. Markdown changes ignored.
- **CI skips if release tag exists** — idempotent. Won't rebuild existing versions.
- **China mirror links** (ghfast.top) auto-included in release notes.
- **fnOS runtime paths**: apps install to `/var/apps/{appname}/`, data to `TRIM_PKGVAR`, config to `TRIM_PKGETC`.
- **Docker support**: `shared/cmd/common` has `check_docker()` for docker-compose apps — currently unused by all 3 apps.
