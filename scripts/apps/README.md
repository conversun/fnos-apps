# fnOS App Contract Interface Specification

This document defines the standard contract interface for fnOS application plugins. Any directory under `scripts/apps/` (e.g., `scripts/apps/plex/`) must adhere to this specification to be compatible with the unified CI/CD pipeline.

## Directory Structure

Each application plugin should follow this layout:

```text
scripts/apps/{app-slug}/
├── meta.env               # Static metadata configuration
├── get-latest-version.sh  # Version resolution logic
├── build.sh               # Build logic producing app.tgz
└── release-notes.tpl      # Release notes template (envsubst format)
```

---

## 1. `meta.env`

A simple key-value file sourced by the CI/CD pipeline.

### Required Keys
- `FILE_PREFIX`: The prefix used for the output `.fpk` file (e.g., `plexmediaserver`, `embyserver`).
- `RELEASE_TITLE`: The human-readable name of the app used in release titles (e.g., `Plex Media Server`).
- `DEFAULT_PORT`: The default network port the application listens on.

### Optional Keys
- `HOMEPAGE_URL`: The official website or documentation URL for the application (used in release notes).

---

## 2. `get-latest-version.sh`

Resolves the latest available version from upstream.

- **Input**: `$1` - Optional version override. If provided, the script should validate and use this version. If empty, resolve the latest version.
- **Output (stdout)**:
  - `VERSION=x.y.z` (Required): The semantic version for fnOS manifest and tagging.
  - `FULL_VERSION=...` (Optional): App-specific detailed version (e.g., used by Plex).
  - `UPSTREAM_TAG=...` (Optional): The actual tag name from the upstream repository (e.g., used by qBittorrent).
- **CI Integration**: When running in GitHub Actions, the script MUST also write these variables to `$GITHUB_OUTPUT` if the environment variable is set.

---

## 3. `build.sh`

Contains the logic to download upstream binaries and package them into `app.tgz`.

- **Input**: Positional arguments. These are app-specific and should be documented in the script's header comment (e.g., `$1=VERSION`, `$2=ARCH_SPECIFIC_BUILD_ID`).
- **Output**: A file named `app.tgz` in the current working directory.
- **Exit Code**:
  - `0`: Success.
  - `Non-zero`: Failure (will abort the CI pipeline).

---

## 4. `release-notes.tpl`

A plain text template file used to generate GitHub Release notes.

- **Format**: Plain text with `${VARIABLE}` placeholders.
- **Substitution**: Processed using `envsubst`.
- **Standard Variables** (Provided by CI):
  - `${VERSION}`: The resolved version of the app.
  - `${RELEASE_TAG}`: The final git tag for this release (e.g., `plex/v1.40.0.7998-r1`).
  - `${FILE_PREFIX}`: The prefix defined in `meta.env`.
  - `${REVISION_NOTE}`: Auto-generated note if this is a revision (e.g., `- **打包修订**: r2`).
- **App-Specific Variables**: Any additional variables output by `get-latest-version.sh` or defined in `meta.env` can be used if supported by the dispatcher.
  - `${CHANGELOG}`: Auto-extracted from `apps/{app}/CHANGELOG.md` (latest entry only).

---

## 5. `apps/{app}/CHANGELOG.md`

Per-app changelog used to inject update notes into GitHub Release notes.

- **Location**: `apps/{app}/CHANGELOG.md` (not in `scripts/apps/`).
- **Format**: Markdown with `## YYYY-MM-DD` section headers. Latest entry first.
- **CI Behavior**: The CI pipeline extracts the content between the first `## ` header and the second `## ` header (or EOF), and injects it as `${CHANGELOG}` into `release-notes.tpl`.

Example:
```markdown
## 2026-02-10

- ⚠️ 改为非 root 用户运行，提升安全性
- 升级后需手动为数据目录添加对应用户的读写权限

## 2026-01-15

- 首次发布
```
