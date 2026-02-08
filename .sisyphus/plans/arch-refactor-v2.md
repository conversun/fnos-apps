# Architecture Refactoring V2: Per-App Contracts, Shared Libraries & Framework Cleanup

## TL;DR

> **Quick Summary**: Eliminate case-statement proliferation in the reusable CI workflow by introducing per-app contract directories, extract ~150 lines of duplicated boilerplate from local build scripts into a shared library, fix qBittorrent's broken installer abstraction (activating previously-dead upgrade logic), and harden the release tag resolution script.
>
> **Deliverables**:
> - `scripts/apps/{plex,emby,qbittorrent,nginx}/` — per-app contract directories (meta.env, build.sh, get-latest-version.sh, release-notes.tpl)
> - `scripts/lib/update-common.sh` — shared local build library
> - Refactored `reusable-build-app.yml` with zero case-statement blocks
> - Fixed qBittorrent lifecycle (service_postupgrade activated, dead code removed)
> - Hardened `resolve-release-tag.sh` with structured JSON output
> - Updated `scripts/new-app.sh` scaffold for new structure
> - Simplified `update_*.sh` scripts (~60% code reduction each)
>
> **Estimated Effort**: Medium (4-8 hours)
> **Parallel Execution**: YES - 3 waves
> **Critical Path**: Task 1 → Task 2 → Task 4 → Task 6 → Task 8

---

## Context

### Original Request
Review the current CI/CD and build refactoring for architectural improvements. The initial refactoring successfully consolidated 4 near-identical ~240-line GitHub workflows into 1 reusable template, but introduced new structural issues.

### Interview Summary
**Key Discussions**:
- Scope: All P0-P3 items (7 improvements + scaffold update = 8 work items)
- Per-app contract location: `scripts/apps/<app>/`
- Migration strategy: Move existing `scripts/ci/build-*.sh` into new directories, delete old paths
- qBittorrent `postupgrade()`: Activate it (move to `service_postupgrade()` in service-setup)
- `scripts/new-app.sh`: Include in this plan

**Research Findings**:
- Oracle recommended per-app contract pattern with security allow-list validation
- Metis discovered qBittorrent's `postupgrade()` is dead code — defined but never called in the execution chain
- Metis identified qBittorrent.conf default config exists in two places (CI and local build)
- Metis verified `functions` file has zero references across codebase (confirmed dead code)

### Metis Review
**Identified Gaps** (addressed):
- `postupgrade()` dead code: User chose to activate it via `service_postupgrade()` — this is a behavioral change, not just refactoring
- `scripts/new-app.sh` generates old structure: Included as Task 8
- Per-app contract interface needs precise definition: Added as Task 1
- qBittorrent.conf duplicated in 2 files: Will be extracted to single source in Task 2
- `gh release list --json` availability: CI runs ubuntu-latest with gh ≥ 2.x, confirmed available
- APP input security validation: Added allow-list check before sourcing meta.env

---

## Work Objectives

### Core Objective
Transform the CI/CD architecture from case-statement-driven dispatch to a plugin-based per-app contract system, while consolidating local build scripts and fixing the qBittorrent lifecycle framework violation.

### Concrete Deliverables
- 4 per-app contract directories under `scripts/apps/`
- 1 shared local build library (`scripts/lib/update-common.sh`)
- Refactored `reusable-build-app.yml` (zero `case "$APP"` blocks)
- 4 simplified `update_*.sh` scripts
- Fixed qBittorrent `service-setup` with activated `service_postupgrade()`
- Hardened `resolve-release-tag.sh`
- Updated `new-app.sh` scaffold
- Deleted: `scripts/ci/build-*.sh` (4 files), `apps/qbittorrent/fnos/cmd/installer`, `apps/qbittorrent/fnos/cmd/functions`

### Definition of Done
- [ ] `case "$APP"` count in `reusable-build-app.yml` is 0
- [ ] All 4 apps have complete contract directories in `scripts/apps/<app>/`
- [ ] All 4 `update_*.sh` scripts source `update-common.sh` and pass `--help` test
- [ ] qBittorrent custom `installer` and `functions` files deleted
- [ ] `service_postupgrade()` defined in qBittorrent's `service-setup`
- [ ] `gh release list` uses `--json tagName -q` structured output
- [ ] `new-app.sh` generates per-app contract structure
- [ ] No old files remain in `scripts/ci/build-*.sh`

### Must Have
- Per-app contract interface: meta.env + get-latest-version.sh + build.sh + release-notes.tpl
- APP input allow-list validation before sourcing meta.env
- Single source of truth for qBittorrent.conf defaults
- All Chinese text preserved character-for-character

### Must NOT Have (Guardrails)
- DO NOT touch `shared/cmd/common` (376 lines, runtime-critical for all 4 apps)
- DO NOT touch `shared/cmd/main` (service dispatcher)
- DO NOT touch `shared/cmd/installer` (shared installer template)
- DO NOT modify entry workflow files (`build-plex.yml` etc.) beyond updating the path to build scripts if needed
- DO NOT consolidate entry workflows into a single file (breaks GitHub path-filter triggers)
- DO NOT change manifest format or content
- DO NOT add linting, testing, or any infrastructure not listed here
- DO NOT translate or reformat any Chinese text in release notes, help messages, or log output
- DO NOT introduce new dependencies (no jq requirement where it doesn't already exist, no Python)

---

## Verification Strategy (MANDATORY)

> **UNIVERSAL RULE: ZERO HUMAN INTERVENTION**
>
> ALL tasks in this plan MUST be verifiable WITHOUT any human action.
> No "user manually tests on fnOS device" or "user visually confirms release notes."

### Test Decision
- **Infrastructure exists**: NO
- **Automated tests**: None
- **Framework**: N/A

### Agent-Executed QA Scenarios (MANDATORY — ALL tasks)

> Every task will include shell-command-based verification. QA scenarios verify structural correctness
> (file existence, content patterns, script parse-ability) since there's no test framework and no
> live fnOS device available.

**Verification Tool by Deliverable Type:**

| Type | Tool | How Agent Verifies |
|------|------|-------------------|
| Bash scripts | Bash | `bash -n` (syntax check), `--help` flag, grep for expected patterns |
| YAML workflows | Bash (grep/yq) | Pattern matching for case elimination, required fields |
| File structure | Bash (test/ls) | Existence, permissions, content verification |
| Deleted files | Bash (test) | `test ! -f` to confirm removal |

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately):
├── Task 1: Define per-app contract interface [no dependencies]
├── Task 3: Fix qBittorrent lifecycle (installer override + dead code) [no dependencies]
└── Task 5: Harden resolve-release-tag.sh [no dependencies]

Wave 2 (After Wave 1):
├── Task 2: Create per-app contract directories [depends: 1]
├── Task 4: Extract update-common.sh shared library [depends: 1]
└── Task 7: Extract qBittorrent.conf to single source [depends: 3]

Wave 3 (After Wave 2):
├── Task 6: Refactor reusable workflow + simplify update scripts [depends: 2, 4]
└── Task 8: Update new-app.sh scaffold [depends: 2]

Wave 4 (After Wave 3):
└── Task 9: Cleanup old files + final verification [depends: all]

Critical Path: Task 1 → Task 2 → Task 6 → Task 9
Parallel Speedup: ~40% faster than sequential
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 | None | 2, 4 | 3, 5 |
| 2 | 1 | 6, 8 | 4, 7, 3, 5 |
| 3 | None | 7 | 1, 5 |
| 4 | 1 | 6 | 2, 7, 3, 5 |
| 5 | None | 9 | 1, 3 |
| 6 | 2, 4 | 9 | 8 |
| 7 | 3 | 9 | 2, 4 |
| 8 | 2 | 9 | 6, 7 |
| 9 | All | None | None (final) |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Dispatch |
|------|-------|---------------------|
| 1 | 1, 3, 5 | 3 parallel agents |
| 2 | 2, 4, 7 | 3 parallel agents |
| 3 | 6, 8 | 2 parallel agents |
| 4 | 9 | 1 sequential agent |

---

## TODOs

- [ ] 1. Define per-app contract interface specification

  **What to do**:
  - Create `scripts/apps/README.md` documenting the contract interface
  - Define `meta.env` required keys: `FILE_PREFIX`, `RELEASE_TITLE`, `DEFAULT_PORT`
  - Define `meta.env` optional keys: `HOMEPAGE_URL` (for release notes links)
  - Define `get-latest-version.sh` interface:
    - Input: `$1` = optional version override (empty string for latest)
    - Output to stdout: `VERSION=x.y.z` (required), `FULL_VERSION=...` (optional, Plex-specific), `UPSTREAM_TAG=...` (optional, qBittorrent-specific)
    - When run in CI: also writes to `$GITHUB_OUTPUT` if set
  - Define `build.sh` interface:
    - Input: positional args are app-specific (documented in each script's header comment)
    - Output: `app.tgz` in current working directory
    - Exit: 0 on success, non-zero on failure
  - Define `release-notes.tpl` format:
    - Plain text with `${VARIABLE}` placeholders
    - Required variables: `${VERSION}`, `${RELEASE_TAG}`, `${FILE_PREFIX}`, `${REVISION_NOTE}`
    - App-specific variables documented in each template
    - Substitution mechanism: `envsubst` (available on ubuntu-latest runners)

  **Must NOT do**:
  - Do not implement the actual scripts yet — this task only creates the specification document
  - Do not touch any existing files

  **Recommended Agent Profile**:
  - **Category**: `writing`
    - Reason: This is a specification document, not code
  - **Skills**: []
  - **Skills Evaluated but Omitted**:
    - `git-master`: Not needed for writing a spec doc

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 3, 5)
  - **Blocks**: Tasks 2, 4
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `scripts/ci/build-plex.sh` — Current Plex build script (27 lines) to understand input/output pattern
  - `scripts/ci/build-emby.sh` — Current Emby build script (32 lines) to understand input/output pattern
  - `scripts/ci/build-qbittorrent.sh` — Current qBittorrent build script (58 lines), most complex build
  - `scripts/ci/build-nginx.sh` — Current Nginx build script (43 lines), handles multiple deb compression formats
  - `.github/workflows/reusable-build-app.yml:47-70` — Current `Resolve App Metadata` step showing meta.env equivalent
  - `.github/workflows/reusable-build-app.yml:72-129` — Current `Get Latest Version` step showing version detection patterns

  **Documentation References**:
  - `README.md` — Project structure section describes current layout

  **WHY Each Reference Matters**:
  - The 4 build scripts show what inputs each app needs (VERSION + arch-specific param) and what they output (app.tgz)
  - The workflow steps show what metadata (FILE_PREFIX, RELEASE_TITLE) and version info (VERSION, FULL_VERSION, UPSTREAM_TAG) each app produces
  - These are the exact contracts being formalized

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Contract specification document exists and is complete
    Tool: Bash
    Preconditions: None
    Steps:
      1. test -f scripts/apps/README.md
      2. grep -q "meta.env" scripts/apps/README.md
      3. grep -q "get-latest-version.sh" scripts/apps/README.md
      4. grep -q "build.sh" scripts/apps/README.md
      5. grep -q "release-notes.tpl" scripts/apps/README.md
      6. grep -q "FILE_PREFIX" scripts/apps/README.md
      7. grep -q "RELEASE_TITLE" scripts/apps/README.md
      8. grep -q "envsubst" scripts/apps/README.md
    Expected Result: All greps succeed (exit 0)
    Evidence: grep output captured
  ```

  **Commit**: YES
  - Message: `docs(scripts): define per-app contract interface specification`
  - Files: `scripts/apps/README.md`

---

- [ ] 2. Create per-app contract directories and migrate build scripts

  **What to do**:
  - Create directory structure: `scripts/apps/{plex,emby,qbittorrent,nginx}/`
  - For each of the 4 apps, create:

    **meta.env** — Source the spec from Task 1. Example for Plex:
    ```bash
    FILE_PREFIX=plexmediaserver
    RELEASE_TITLE="Plex Media Server"
    DEFAULT_PORT=32400
    HOMEPAGE_URL="https://www.plex.tv/media-server-downloads/"
    ```

    **build.sh** — Move from `scripts/ci/build-{app}.sh`, no logic changes. Keep identical content. Mark executable.

    **get-latest-version.sh** — Extract version detection logic from `reusable-build-app.yml` lines 81-123 (the `Get Latest Version` step's case block for each app). Each script:
    - Accepts `$1` as optional version override
    - Outputs `VERSION=x.y.z` to stdout
    - If `$GITHUB_OUTPUT` is set, also writes there
    - App-specific extra outputs (Plex: `FULL_VERSION`, qBittorrent: `UPSTREAM_TAG`)

    **release-notes.tpl** — Extract release notes text from `reusable-build-app.yml` lines 237-286 (the `Create Release` step's case block). Convert heredoc variables to `${VARIABLE}` placeholders. Preserve Chinese text exactly.

  - Add APP input allow-list validation: the reusable workflow should validate `$APP` against known values before sourcing any per-app files. Add a validation step at the top that checks `[[ " plex emby qbittorrent nginx " == *" ${APP} "* ]]`.

  **Must NOT do**:
  - Do not modify the reusable workflow yet (that's Task 6)
  - Do not delete old `scripts/ci/build-*.sh` yet (that's Task 9)
  - Do not change any build logic — this is purely file reorganization

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low`
    - Reason: File moves and straightforward extraction, no complex logic
  - **Skills**: [`git-master`]
    - `git-master`: Need clean file moves tracked by git

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 4, 7)
  - **Blocks**: Tasks 6, 8
  - **Blocked By**: Task 1

  **References**:

  **Pattern References**:
  - `scripts/ci/build-plex.sh` (full file, 27 lines) — Move to `scripts/apps/plex/build.sh`
  - `scripts/ci/build-emby.sh` (full file, 32 lines) — Move to `scripts/apps/emby/build.sh`
  - `scripts/ci/build-qbittorrent.sh` (full file, 58 lines) — Move to `scripts/apps/qbittorrent/build.sh`
  - `scripts/ci/build-nginx.sh` (full file, 43 lines) — Move to `scripts/apps/nginx/build.sh`
  - `.github/workflows/reusable-build-app.yml:47-70` — Source for meta.env values (file_prefix, release_title per app)
  - `.github/workflows/reusable-build-app.yml:72-129` — Source for get-latest-version.sh logic per app
  - `.github/workflows/reusable-build-app.yml:237-286` — Source for release-notes.tpl content per app

  **Contract References**:
  - `scripts/apps/README.md` (created in Task 1) — Interface specification to follow

  **WHY Each Reference Matters**:
  - The build scripts are moved verbatim (no logic change)
  - The workflow steps contain the version detection logic and release notes that need to be extracted into per-app files
  - The Task 1 README defines the exact interface contracts each file must satisfy

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: All 4 apps have complete contract directories
    Tool: Bash
    Preconditions: Task 1 complete
    Steps:
      1. for app in plex emby qbittorrent nginx; do
           test -f "scripts/apps/${app}/meta.env" || echo "FAIL: ${app}/meta.env"
           test -f "scripts/apps/${app}/build.sh" || echo "FAIL: ${app}/build.sh"
           test -x "scripts/apps/${app}/build.sh" || echo "FAIL: ${app}/build.sh not executable"
           test -f "scripts/apps/${app}/get-latest-version.sh" || echo "FAIL: ${app}/get-latest-version.sh"
           test -x "scripts/apps/${app}/get-latest-version.sh" || echo "FAIL: ${app}/get-latest-version.sh not executable"
           test -f "scripts/apps/${app}/release-notes.tpl" || echo "FAIL: ${app}/release-notes.tpl"
         done
      2. bash -n scripts/apps/plex/build.sh && echo "PASS: plex build.sh syntax"
      3. bash -n scripts/apps/emby/build.sh && echo "PASS: emby build.sh syntax"
      4. bash -n scripts/apps/qbittorrent/build.sh && echo "PASS: qbt build.sh syntax"
      5. bash -n scripts/apps/nginx/build.sh && echo "PASS: nginx build.sh syntax"
    Expected Result: All tests pass, no FAIL output
    Evidence: Terminal output captured

  Scenario: meta.env files have required keys
    Tool: Bash
    Preconditions: Contract directories created
    Steps:
      1. for app in plex emby qbittorrent nginx; do
           grep -q "FILE_PREFIX=" "scripts/apps/${app}/meta.env" || echo "FAIL: ${app} missing FILE_PREFIX"
           grep -q "RELEASE_TITLE=" "scripts/apps/${app}/meta.env" || echo "FAIL: ${app} missing RELEASE_TITLE"
           grep -q "DEFAULT_PORT=" "scripts/apps/${app}/meta.env" || echo "FAIL: ${app} missing DEFAULT_PORT"
         done
    Expected Result: All greps succeed
    Evidence: Terminal output captured

  Scenario: release-notes.tpl files preserve Chinese content
    Tool: Bash
    Preconditions: Templates extracted
    Steps:
      1. grep -q "自动构建" scripts/apps/plex/release-notes.tpl
      2. grep -q "国内镜像" scripts/apps/plex/release-notes.tpl
      3. grep -q "默认用户" scripts/apps/qbittorrent/release-notes.tpl
    Expected Result: Chinese text preserved
    Evidence: grep output captured
  ```

  **Commit**: YES
  - Message: `refactor(ci): create per-app contract directories with meta, build, version, release-notes`
  - Files: `scripts/apps/*/meta.env`, `scripts/apps/*/build.sh`, `scripts/apps/*/get-latest-version.sh`, `scripts/apps/*/release-notes.tpl`

---

- [ ] 3. Fix qBittorrent lifecycle: activate service_postupgrade, delete dead code

  **What to do**:
  - **Delete** `apps/qbittorrent/fnos/cmd/functions` (79 lines of dead code, zero references)
  - **Delete** `apps/qbittorrent/fnos/cmd/installer` (69 lines, full override of shared installer)
  - **Add** `service_postupgrade()` function to `apps/qbittorrent/fnos/cmd/service-setup`:
    ```bash
    service_postupgrade() {
        log_step "qbittorrent_postupgrade"

        # Symlink persistent config directory
        if [ -d "${TRIM_PKGVAR}/config" ]; then
            $RM "${TRIM_APPDEST}/conf" 2>&1 | install_log
            $LN "${TRIM_PKGVAR}/config" "${TRIM_APPDEST}/conf" 2>&1 | install_log
        fi

        # Add default credentials if missing (upgrade from older versions)
        local need_password_warning=false

        if [ -f "${QBIT_CONF}" ]; then
            if ! grep -q "WebUI\\\\Username" "${QBIT_CONF}"; then
                sed -i '/WebUI\\Port/i\WebUI\\Username=admin' ${QBIT_CONF}
                need_password_warning=true
            fi

            if ! grep -q "Password_PBKDF2" "${QBIT_CONF}"; then
                sed -i '/WebUI\\Port/i\WebUI\\Password_PBKDF2=\"@ByteArray(xK2EwRvfGtxfF+Ot9v4WYQ==:bNStY\/6mFYYW8m\/Xm4xSbBjoR2tZNsLZ4KvdUzyCLEOg7tfpchVJucIK9Dwcp6Xe9DI4RwpoCPI9zhicTdtf5A==)\"' ${QBIT_CONF}
                need_password_warning=true
            fi
        fi

        if [ "$need_password_warning" = true ]; then
            echo "默认用户名: admin，密码: adminadmin<br/>"
            echo "请及时修改默认密码！Change default password NOW！！！"
        fi
    }
    ```
  - **CRITICAL BEHAVIORAL NOTE**: This ACTIVATES previously-dead code. The `service_postupgrade()` function will now be called by `shared/cmd/common`'s `upgrade_callback()` during upgrades. This was never executed before. The user explicitly chose to activate this.
  - Verify execution chain: `upgrade_callback` (file) → sources shared `installer` → sources `common` + `service-setup` → `upgrade_callback()` function calls `service_postupgrade()` (now defined in qBittorrent's service-setup)

  **Must NOT do**:
  - Do not touch `shared/cmd/common` or `shared/cmd/installer`
  - Do not modify any other app's service-setup
  - Do not change the `service_postupgrade()` logic — preserve exact behavior from the old `postupgrade()` function

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Small, targeted changes — 2 file deletions + 1 function addition to existing file
  - **Skills**: [`git-master`]
    - `git-master`: Clean commit with proper diff

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 5)
  - **Blocks**: Task 7
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `apps/qbittorrent/fnos/cmd/installer:35-68` — The `postupgrade()` function being migrated. Extract lines 37-67 as the body of `service_postupgrade()`
  - `apps/qbittorrent/fnos/cmd/service-setup` (full file, 39 lines) — Target file where `service_postupgrade()` will be added at the end
  - `shared/cmd/common:252-258` — The `upgrade_callback()` function that calls `service_restore()` then `service_postupgrade()`. This confirms the hook is invoked.
  - `shared/cmd/common:76-79` — The default no-op `service_postupgrade()` that qBittorrent's service-setup will override

  **Dead Code References**:
  - `apps/qbittorrent/fnos/cmd/functions` (full file, 79 lines) — Confirmed dead code. Duplicates functions from `shared/cmd/common`. Zero references found via grep across entire codebase.

  **WHY Each Reference Matters**:
  - The `installer:35-68` contains the EXACT logic to migrate — must be moved character-for-character
  - The `service-setup` is where the new function goes — append at end of file
  - `common:252-258` proves the hook will actually be called after migration
  - `common:76-79` shows the no-op default being overridden

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Dead code files are deleted
    Tool: Bash
    Preconditions: None
    Steps:
      1. test ! -f apps/qbittorrent/fnos/cmd/functions
      2. test ! -f apps/qbittorrent/fnos/cmd/installer
    Expected Result: Both files do not exist
    Evidence: test exit codes

  Scenario: service_postupgrade is defined in service-setup
    Tool: Bash
    Preconditions: service-setup modified
    Steps:
      1. grep -q "service_postupgrade" apps/qbittorrent/fnos/cmd/service-setup
      2. grep -q "WebUI\\\\\\\\Username" apps/qbittorrent/fnos/cmd/service-setup
      3. grep -q "Password_PBKDF2" apps/qbittorrent/fnos/cmd/service-setup
      4. grep -q "TRIM_PKGVAR" apps/qbittorrent/fnos/cmd/service-setup
      5. bash -n apps/qbittorrent/fnos/cmd/service-setup
    Expected Result: All patterns found, syntax valid
    Evidence: grep and bash -n output

  Scenario: Execution chain is intact
    Tool: Bash
    Preconditions: Files modified
    Steps:
      1. grep -q "service_postupgrade" shared/cmd/common
      2. grep -q "upgrade_callback" shared/cmd/common
      3. test -f shared/cmd/installer
    Expected Result: Shared framework untouched, hooks still defined
    Evidence: grep output confirms no shared changes
  ```

  **Commit**: YES
  - Message: `fix(qbittorrent): activate service_postupgrade hook, remove dead installer override and functions`
  - Files: `apps/qbittorrent/fnos/cmd/service-setup`, deleted: `apps/qbittorrent/fnos/cmd/installer`, `apps/qbittorrent/fnos/cmd/functions`
  - Pre-commit: `bash -n apps/qbittorrent/fnos/cmd/service-setup`

---

- [ ] 4. Extract shared local build library (update-common.sh)

  **What to do**:
  - Create `scripts/lib/update-common.sh` containing:
    - Color definitions (`RED`, `GREEN`, `YELLOW`, `NC`)
    - Logging functions (`info()`, `warn()`, `error()`)
    - `cleanup()` and `trap cleanup EXIT` setup function
    - `detect_arch()` — parameterized to accept app-specific variable mappings
    - `parse_args()` — generic arg parser (--arch, --help, version positional)
    - `show_help_template()` — base help with app-specific sections injected
    - `update_manifest()` — unified manifest update logic
    - `build_fpk()` — unified fpk build via `scripts/build-fpk.sh`
    - `main_flow()` — orchestration template that apps customize via callbacks
  - The library must be designed to be `source`d by each `update_*.sh`
  - Each `update_*.sh` will define app-specific variables and functions, then call the shared flow
  - Pattern: `update_plex.sh` becomes ~80 lines (currently 247) defining only:
    - `APP_NAME`, `VERSION_VAR`, `BINARY_PREFIX_MAP`, etc.
    - `get_latest_version()` — app-specific version detection
    - `download_and_extract()` — app-specific download logic
    - `build_app_tgz()` — app-specific assembly
    - Then: `source "$REPO_ROOT/scripts/lib/update-common.sh"` + `main "$@"`

  **Must NOT do**:
  - Do not refactor the actual `update_*.sh` files yet (that's in Task 6)
  - Do not change any app-specific download or build logic
  - Do not add new dependencies

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Extracting a shared library from 4 scripts requires careful API design
  - **Skills**: [`git-master`]
    - `git-master`: Track the new file properly

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2, 7)
  - **Blocks**: Task 6
  - **Blocked By**: Task 1 (needs contract interface awareness)

  **References**:

  **Pattern References**:
  - `apps/plex/update_plex.sh:12-22` — Color defs + logging functions (identical in all 4 scripts)
  - `apps/plex/update_plex.sh:24-58` — `detect_arch()` (identical pattern, different variable names)
  - `apps/plex/update_plex.sh:131-138` — `update_manifest()` (slight variations across apps)
  - `apps/plex/update_plex.sh:141-156` — `build_fpk()` (identical in all 4 scripts)
  - `apps/plex/update_plex.sh:158-180` — `show_help()` (only examples differ)
  - `apps/plex/update_plex.sh:182-206` — `parse_args()` (identical in all 4 scripts)
  - `apps/plex/update_plex.sh:208-246` — `main()` (identical flow, different function names)
  - `apps/qbittorrent/update_qbittorrent.sh` (full file, 272 lines) — Compare to Plex to identify exact delta

  **WHY Each Reference Matters**:
  - Lines 12-22, 24-58, 141-156, 182-206 are VERBATIM identical across all 4 scripts — prime extraction targets
  - Lines 131-138 and 158-180 have minor variations — need parameterization
  - Lines 208-246 show the common orchestration flow — becomes `main_flow()` template

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Shared library exists and has valid syntax
    Tool: Bash
    Preconditions: None
    Steps:
      1. test -f scripts/lib/update-common.sh
      2. bash -n scripts/lib/update-common.sh
      3. grep -q "detect_arch" scripts/lib/update-common.sh
      4. grep -q "parse_args" scripts/lib/update-common.sh
      5. grep -q "build_fpk" scripts/lib/update-common.sh
      6. grep -q "info()" scripts/lib/update-common.sh || grep -q "info ()" scripts/lib/update-common.sh || grep -q "^info" scripts/lib/update-common.sh
    Expected Result: File exists, parses, contains expected functions
    Evidence: bash -n and grep output
  ```

  **Commit**: YES
  - Message: `refactor(scripts): extract shared local build library update-common.sh`
  - Files: `scripts/lib/update-common.sh`
  - Pre-commit: `bash -n scripts/lib/update-common.sh`

---

- [ ] 5. Harden resolve-release-tag.sh with structured JSON output

  **What to do**:
  - Replace line 39's unstructured `gh release list | grep` with structured JSON query:
    ```bash
    # Before (fragile — greps tab-separated output, could match release titles)
    HIGHEST_REV=$(
      gh release list --limit 200 | grep "${BASE_TAG}" | \
        sed -n "s/.*${APP_SLUG//\//\\/}\/v${VERSION}-r\([0-9]*\).*/\1/p" | sort -n | tail -1
    )

    # After (structured — queries only tag names via JSON)
    HIGHEST_REV=$(
      gh release list --limit 200 --json tagName -q '.[].tagName' | \
        grep "^${BASE_TAG}-r" | \
        sed -n "s/.*-r\([0-9]*\)$/\1/p" | sort -n | tail -1
    )
    ```
  - Also update line 37's `gh release view` to use the same structured approach for checking if base tag exists:
    ```bash
    # This is already fine — gh release view checks exact tag match
    ```
  - Add inline comment explaining the JSON query approach

  **Must NOT do**:
  - Do not change the revision logic (auto-increment behavior)
  - Do not change the `emit_output()` function
  - Do not change the scheduled/manual dispatch branching logic

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Single-line replacement in a 65-line script
  - **Skills**: [`git-master`]
    - `git-master`: Clean atomic commit

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1, 3)
  - **Blocks**: Task 9
  - **Blocked By**: None

  **References**:

  **Pattern References**:
  - `scripts/ci/resolve-release-tag.sh:37-53` — The version existence check and revision auto-increment block being hardened

  **External References**:
  - `gh release list --json` documentation — GitHub CLI structured output format

  **WHY Each Reference Matters**:
  - Lines 37-53 are the EXACT lines being modified — must understand the full branching logic to change only the parsing, not the behavior

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Script uses structured JSON output
    Tool: Bash
    Preconditions: None
    Steps:
      1. grep -q "\-\-json tagName" scripts/ci/resolve-release-tag.sh
      2. grep -q "\.tagName" scripts/ci/resolve-release-tag.sh || grep -q "tagName" scripts/ci/resolve-release-tag.sh
      3. bash -n scripts/ci/resolve-release-tag.sh
    Expected Result: JSON flag present, syntax valid
    Evidence: grep and bash -n output

  Scenario: Script still handles all 3 trigger modes
    Tool: Bash
    Preconditions: None
    Steps:
      1. grep -q "schedule" scripts/ci/resolve-release-tag.sh
      2. grep -q "REVISION" scripts/ci/resolve-release-tag.sh
      3. grep -q "should_build" scripts/ci/resolve-release-tag.sh
      4. grep -q "emit_output" scripts/ci/resolve-release-tag.sh
    Expected Result: All trigger paths preserved
    Evidence: grep output
  ```

  **Commit**: YES
  - Message: `fix(ci): use structured JSON output for gh release list tag parsing`
  - Files: `scripts/ci/resolve-release-tag.sh`
  - Pre-commit: `bash -n scripts/ci/resolve-release-tag.sh`

---

- [ ] 6. Refactor reusable workflow and simplify update_*.sh scripts

  **What to do**:

  **Part A: Reusable Workflow Refactoring**
  - Replace ALL 4 `case "$APP"` blocks in `.github/workflows/reusable-build-app.yml` with per-app contract sourcing:
    - `Resolve App Metadata` step → `source "scripts/apps/${APP}/meta.env"`
    - `Get Latest Version` step → `bash "scripts/apps/${APP}/get-latest-version.sh" "${INPUT_VERSION}"`
    - `Build Package` step → `bash "scripts/apps/${APP}/build.sh" [app-specific-args]`
    - `Create Release` step → `envsubst < "scripts/apps/${APP}/release-notes.tpl"`
  - Add APP validation step at the very beginning:
    ```yaml
    - name: Validate App Input
      run: |
        APP="${{ inputs.app }}"
        VALID_APPS="plex emby qbittorrent nginx"
        if ! echo "$VALID_APPS" | grep -qw "$APP"; then
          echo "Invalid app: $APP. Must be one of: $VALID_APPS" >&2
          exit 1
        fi
    ```
  - The `build` job's matrix still handles arch-specific variables (deb_arch, plex_build, qb_binary_prefix) — these stay in the matrix definition, NOT in per-app contracts
  - The `build` job needs to pass matrix variables to `build.sh` as positional args — this requires a dispatch mechanism. Use the matrix `include` to define which args each app/arch combo needs, and pass them through.

  **Part B: Simplify update_*.sh Scripts**
  - Refactor each `update_*.sh` to source `scripts/lib/update-common.sh` from Task 4
  - Each script defines ONLY:
    - App-specific variables (APP_NAME, VERSION_VAR, etc.)
    - `get_latest_version()` — app-specific version detection
    - `download_and_extract()` — app-specific download + extraction
    - `build_app_tgz()` — app-specific assembly
  - Target: each script reduces from ~200-270 lines to ~80-120 lines

  **Must NOT do**:
  - Do not modify entry workflow files (`build-plex.yml` etc.)
  - Do not change any download URLs or version detection logic
  - Do not change app.tgz assembly patterns
  - Do not touch `scripts/build-fpk.sh`

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
    - Reason: Multi-file refactoring across YAML and bash, requires careful coordination
  - **Skills**: [`git-master`]
    - `git-master`: Multi-file commit with proper tracking

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Task 8)
  - **Blocks**: Task 9
  - **Blocked By**: Tasks 2, 4

  **References**:

  **Pattern References**:
  - `.github/workflows/reusable-build-app.yml` (full file, 295 lines) — THE file being refactored
  - `scripts/apps/*/meta.env` (created in Task 2) — Replaces `Resolve App Metadata` case block
  - `scripts/apps/*/get-latest-version.sh` (created in Task 2) — Replaces `Get Latest Version` case block
  - `scripts/apps/*/build.sh` (created in Task 2) — Replaces `Build Package` case block
  - `scripts/apps/*/release-notes.tpl` (created in Task 2) — Replaces `Create Release` case block
  - `scripts/lib/update-common.sh` (created in Task 4) — Shared library for update scripts
  - `apps/plex/update_plex.sh` (full file, 247 lines) — Representative update script to simplify
  - `apps/qbittorrent/update_qbittorrent.sh` (full file, 272 lines) — Most complex update script

  **Contract References**:
  - `scripts/apps/README.md` (created in Task 1) — Interface spec for per-app contract

  **WHY Each Reference Matters**:
  - `reusable-build-app.yml` is the primary target — all 4 case blocks must be eliminated
  - The per-app contract files (from Task 2) are the replacements for the case blocks
  - `update-common.sh` (from Task 4) is the shared library being adopted
  - The two update scripts show the current duplication pattern being eliminated

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Zero case blocks remain in reusable workflow
    Tool: Bash
    Preconditions: Workflow refactored
    Steps:
      1. count=$(grep -c 'case "\$' .github/workflows/reusable-build-app.yml || true)
      2. test "$count" -eq 0 || test -z "$count"
    Expected Result: Zero case statements
    Evidence: grep count output

  Scenario: APP validation exists in reusable workflow
    Tool: Bash
    Preconditions: Workflow refactored
    Steps:
      1. grep -q "Validate" .github/workflows/reusable-build-app.yml || grep -q "valid" .github/workflows/reusable-build-app.yml
      2. grep -q "plex emby qbittorrent nginx" .github/workflows/reusable-build-app.yml
    Expected Result: Validation step exists with allow-list
    Evidence: grep output

  Scenario: Per-app contract sourcing in workflow
    Tool: Bash
    Preconditions: Workflow refactored
    Steps:
      1. grep -q "scripts/apps/" .github/workflows/reusable-build-app.yml
      2. grep -q "meta.env" .github/workflows/reusable-build-app.yml
      3. grep -q "get-latest-version" .github/workflows/reusable-build-app.yml
      4. grep -q "release-notes" .github/workflows/reusable-build-app.yml
    Expected Result: All per-app contract files referenced
    Evidence: grep output

  Scenario: All update scripts source shared library and pass help test
    Tool: Bash
    Preconditions: Scripts refactored
    Steps:
      1. for script in apps/*/update_*.sh; do
           grep -q "update-common.sh" "$script" || echo "FAIL: $script missing source"
         done
      2. bash apps/plex/update_plex.sh --help | grep -q "用法:" || echo "FAIL: plex help"
      3. bash apps/emby/update_emby.sh --help | grep -q "用法:" || echo "FAIL: emby help"
      4. bash apps/qbittorrent/update_qbittorrent.sh --help | grep -q "用法:" || echo "FAIL: qbt help"
      5. bash apps/nginx/update_nginx.sh --help | grep -q "用法:" || echo "FAIL: nginx help"
    Expected Result: All scripts source library, all help commands work
    Evidence: Terminal output

  Scenario: Update scripts are significantly smaller
    Tool: Bash
    Preconditions: Scripts refactored
    Steps:
      1. plex_lines=$(wc -l < apps/plex/update_plex.sh)
      2. test "$plex_lines" -lt 150 || echo "WARN: plex still ${plex_lines} lines"
      3. qbt_lines=$(wc -l < apps/qbittorrent/update_qbittorrent.sh)
      4. test "$qbt_lines" -lt 180 || echo "WARN: qbt still ${qbt_lines} lines"
    Expected Result: Each script under 150-180 lines (from 247-272)
    Evidence: wc -l output
  ```

  **Commit**: YES (single commit for coherent refactoring)
  - Message: `refactor: eliminate case blocks in reusable workflow, simplify update scripts with shared library`
  - Files: `.github/workflows/reusable-build-app.yml`, `apps/*/update_*.sh`
  - Pre-commit: `bash -n scripts/lib/update-common.sh && bash -n apps/plex/update_plex.sh`

---

- [ ] 7. Extract qBittorrent.conf default config to single source file

  **What to do**:
  - Create `apps/qbittorrent/fnos/defaults/qBittorrent.conf` with the default config content
  - Update `apps/qbittorrent/update_qbittorrent.sh:117-140` to `cp` from this file instead of inline heredoc
  - Update `scripts/apps/qbittorrent/build.sh` (migrated in Task 2, was `scripts/ci/build-qbittorrent.sh:31-54`) to `cp` from this file instead of inline heredoc
  - Both build paths now reference the same single file

  **Must NOT do**:
  - Do not change the config content — preserve exact key=value pairs
  - Do not move the file outside `apps/qbittorrent/` (it's app-specific)

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Extract heredoc to file, replace 2 inline occurrences with cp
  - **Skills**: [`git-master`]
    - `git-master`: Track the extraction cleanly

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Tasks 2, 4)
  - **Blocks**: Task 9
  - **Blocked By**: Task 3 (qBittorrent cleanup must be done first)

  **References**:

  **Pattern References**:
  - `apps/qbittorrent/update_qbittorrent.sh:117-140` — First copy of inline qBittorrent.conf heredoc
  - `scripts/ci/build-qbittorrent.sh:31-54` (or `scripts/apps/qbittorrent/build.sh` after Task 2) — Second copy of inline qBittorrent.conf heredoc

  **WHY Each Reference Matters**:
  - These are the TWO locations with duplicated config content that must both reference the new single file

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Single source config file exists
    Tool: Bash
    Preconditions: None
    Steps:
      1. test -f apps/qbittorrent/fnos/defaults/qBittorrent.conf
      2. grep -q "WebUI\\\\Port=8085" apps/qbittorrent/fnos/defaults/qBittorrent.conf
      3. grep -q "admin" apps/qbittorrent/fnos/defaults/qBittorrent.conf
    Expected Result: Config file exists with expected content
    Evidence: grep output

  Scenario: No inline heredoc in build scripts
    Tool: Bash
    Preconditions: Build scripts updated
    Steps:
      1. ! grep -q "QBCONF" apps/qbittorrent/update_qbittorrent.sh || echo "FAIL: heredoc still in update script"
      2. ! grep -q "QBCONF" scripts/apps/qbittorrent/build.sh || echo "FAIL: heredoc still in CI build script"
    Expected Result: No QBCONF heredoc markers in either file
    Evidence: grep output
  ```

  **Commit**: YES
  - Message: `refactor(qbittorrent): extract default config to single source file`
  - Files: `apps/qbittorrent/fnos/defaults/qBittorrent.conf`, `apps/qbittorrent/update_qbittorrent.sh`, `scripts/apps/qbittorrent/build.sh`

---

- [ ] 8. Update new-app.sh scaffold to generate per-app contract structure

  **What to do**:
  - Modify `scripts/new-app.sh` to generate the new directory structure when scaffolding:
    - Generate `scripts/apps/<app>/meta.env` with template values
    - Generate `scripts/apps/<app>/build.sh` with TODO skeleton
    - Generate `scripts/apps/<app>/get-latest-version.sh` with TODO skeleton
    - Generate `scripts/apps/<app>/release-notes.tpl` with template placeholders
  - Remove generation of old `scripts/ci/build-<app>.sh` path
  - Update the entry workflow template to match current `build-plex.yml` structure (simple pass-through to reusable workflow)
  - Update help text and output messages to reflect new structure

  **Must NOT do**:
  - Do not change the scaffold for `apps/<app>/fnos/` structure (that's unchanged)
  - Do not add complex logic — keep skeletons simple with TODO markers

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: Updating template strings in a single script
  - **Skills**: [`git-master`]
    - `git-master`: Clean commit

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Task 6)
  - **Blocks**: Task 9
  - **Blocked By**: Task 2 (need to know final contract structure)

  **References**:

  **Pattern References**:
  - `scripts/new-app.sh` (full file) — The scaffold script being updated
  - `scripts/apps/plex/meta.env` (created in Task 2) — Example of what the scaffold should generate
  - `scripts/apps/plex/build.sh` (created in Task 2) — Example build script structure
  - `.github/workflows/build-plex.yml` (34 lines) — Example entry workflow the scaffold should generate

  **Contract References**:
  - `scripts/apps/README.md` (created in Task 1) — Interface spec the scaffold must generate conforming files for

  **WHY Each Reference Matters**:
  - The existing scaffold defines current generated structure — need to know what to change
  - The Plex per-app contract files are the gold standard for what the scaffold should produce
  - The entry workflow shows the minimal caller structure

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Scaffold generates per-app contract structure
    Tool: Bash
    Preconditions: new-app.sh updated
    Steps:
      1. bash scripts/new-app.sh testapp "Test App" 9999
      2. test -f scripts/apps/testapp/meta.env
      3. test -f scripts/apps/testapp/build.sh
      4. test -f scripts/apps/testapp/get-latest-version.sh
      5. test -f scripts/apps/testapp/release-notes.tpl
      6. grep -q "FILE_PREFIX" scripts/apps/testapp/meta.env
      7. grep -q "RELEASE_TITLE" scripts/apps/testapp/meta.env
      8. test -f .github/workflows/build-testapp.yml
      9. test -f apps/testapp/fnos/manifest
      10. rm -rf apps/testapp scripts/apps/testapp .github/workflows/build-testapp.yml
    Expected Result: All contract files generated, then cleaned up
    Evidence: test and grep output

  Scenario: Scaffold does NOT generate old structure
    Tool: Bash
    Preconditions: new-app.sh updated
    Steps:
      1. bash scripts/new-app.sh testapp2 "Test App 2" 9998
      2. test ! -f scripts/ci/build-testapp2.sh || echo "FAIL: old CI path still generated"
      3. rm -rf apps/testapp2 scripts/apps/testapp2 .github/workflows/build-testapp2.yml
    Expected Result: No files at old scripts/ci/ path
    Evidence: test output
  ```

  **Commit**: YES
  - Message: `refactor(scaffold): update new-app.sh to generate per-app contract structure`
  - Files: `scripts/new-app.sh`

---

- [ ] 9. Cleanup: delete old files and final verification

  **What to do**:
  - Delete old CI build scripts that have been migrated:
    - `scripts/ci/build-plex.sh`
    - `scripts/ci/build-emby.sh`
    - `scripts/ci/build-qbittorrent.sh`
    - `scripts/ci/build-nginx.sh`
  - Keep `scripts/ci/resolve-release-tag.sh` (it's a shared utility, not per-app)
  - If `scripts/ci/` directory is now empty except for `resolve-release-tag.sh`, consider whether it should stay or `resolve-release-tag.sh` should move. Decision: keep in `scripts/ci/` — it's CI-specific shared logic, not per-app.
  - Update `AGENTS.md` to reflect new architecture:
    - Add `scripts/apps/<app>/` to the structure
    - Add `scripts/lib/` to the structure
    - Update the "WHERE TO LOOK" table
    - Remove references to `scripts/ci/build-*.sh`
  - Update `README.md` project structure section to match
  - Run full verification suite

  **Must NOT do**:
  - Do not delete `scripts/ci/resolve-release-tag.sh` (it's still in use)
  - Do not make any logic changes — this is purely cleanup

  **Recommended Agent Profile**:
  - **Category**: `quick`
    - Reason: File deletions + doc updates
  - **Skills**: [`git-master`]
    - `git-master`: Clean final commit

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 4 (final, sequential)
  - **Blocks**: None (final task)
  - **Blocked By**: All previous tasks

  **References**:

  **Pattern References**:
  - `AGENTS.md` (full file) — Project knowledge base to update
  - `README.md` (full file) — Project README to update

  **Deletion Targets**:
  - `scripts/ci/build-plex.sh` — Migrated to `scripts/apps/plex/build.sh` in Task 2
  - `scripts/ci/build-emby.sh` — Migrated to `scripts/apps/emby/build.sh` in Task 2
  - `scripts/ci/build-qbittorrent.sh` — Migrated to `scripts/apps/qbittorrent/build.sh` in Task 2
  - `scripts/ci/build-nginx.sh` — Migrated to `scripts/apps/nginx/build.sh` in Task 2

  **WHY Each Reference Matters**:
  - The 4 old build scripts are confirmed migrated — safe to delete
  - AGENTS.md and README.md must reflect the new structure for future contributors

  **Acceptance Criteria**:

  **Agent-Executed QA Scenarios:**

  ```
  Scenario: Old CI build scripts are deleted
    Tool: Bash
    Preconditions: All migrations complete
    Steps:
      1. test ! -f scripts/ci/build-plex.sh
      2. test ! -f scripts/ci/build-emby.sh
      3. test ! -f scripts/ci/build-qbittorrent.sh
      4. test ! -f scripts/ci/build-nginx.sh
      5. test -f scripts/ci/resolve-release-tag.sh
    Expected Result: Old build scripts gone, resolve-release-tag.sh preserved
    Evidence: test output

  Scenario: Documentation reflects new structure
    Tool: Bash
    Preconditions: Docs updated
    Steps:
      1. grep -q "scripts/apps/" AGENTS.md
      2. grep -q "scripts/lib/" AGENTS.md
      3. grep -q "scripts/apps/" README.md
    Expected Result: New paths documented
    Evidence: grep output

  Scenario: Full structure integrity check
    Tool: Bash
    Preconditions: All tasks complete
    Steps:
      1. echo "=== Per-app contract directories ==="
         for app in plex emby qbittorrent nginx; do
           for f in meta.env build.sh get-latest-version.sh release-notes.tpl; do
             test -f "scripts/apps/${app}/${f}" && echo "OK: ${app}/${f}" || echo "FAIL: ${app}/${f}"
           done
         done
      2. echo "=== Shared library ==="
         test -f scripts/lib/update-common.sh && echo "OK" || echo "FAIL"
      3. echo "=== qBittorrent cleanup ==="
         test ! -f apps/qbittorrent/fnos/cmd/installer && echo "OK: no custom installer" || echo "FAIL"
         test ! -f apps/qbittorrent/fnos/cmd/functions && echo "OK: no dead functions" || echo "FAIL"
         grep -q "service_postupgrade" apps/qbittorrent/fnos/cmd/service-setup && echo "OK: hook active" || echo "FAIL"
      4. echo "=== Old files removed ==="
         for f in scripts/ci/build-plex.sh scripts/ci/build-emby.sh scripts/ci/build-qbittorrent.sh scripts/ci/build-nginx.sh; do
           test ! -f "$f" && echo "OK: ${f} removed" || echo "FAIL: ${f} still exists"
         done
      5. echo "=== Workflow check ==="
         case_count=$(grep -c 'case "\$' .github/workflows/reusable-build-app.yml 2>/dev/null || echo 0)
         echo "Case blocks in reusable workflow: ${case_count}"
         test "${case_count}" -eq 0 && echo "OK" || echo "FAIL"
      6. echo "=== Script syntax ==="
         bash -n scripts/lib/update-common.sh && echo "OK: update-common.sh"
         bash -n scripts/ci/resolve-release-tag.sh && echo "OK: resolve-release-tag.sh"
         for app in plex emby qbittorrent nginx; do
           bash -n "scripts/apps/${app}/build.sh" && echo "OK: ${app}/build.sh"
         done
    Expected Result: All checks pass
    Evidence: Full terminal output captured to .sisyphus/evidence/task-9-final-check.txt
  ```

  **Commit**: YES
  - Message: `chore: remove migrated CI build scripts, update documentation for new architecture`
  - Files: deleted `scripts/ci/build-*.sh`, `AGENTS.md`, `README.md`

---

## Commit Strategy

| After Task | Message | Key Files | Verification |
|------------|---------|-----------|--------------|
| 1 | `docs(scripts): define per-app contract interface specification` | `scripts/apps/README.md` | grep for required sections |
| 2 | `refactor(ci): create per-app contract directories` | `scripts/apps/*/` | file existence + syntax checks |
| 3 | `fix(qbittorrent): activate service_postupgrade hook, remove dead code` | `apps/qbittorrent/fnos/cmd/service-setup` | `bash -n` + grep |
| 4 | `refactor(scripts): extract shared local build library` | `scripts/lib/update-common.sh` | `bash -n` |
| 5 | `fix(ci): use structured JSON for gh release list parsing` | `scripts/ci/resolve-release-tag.sh` | `bash -n` + grep `--json` |
| 6 | `refactor: eliminate case blocks, simplify update scripts` | `.github/workflows/reusable-build-app.yml`, `apps/*/update_*.sh` | case count = 0, `--help` tests |
| 7 | `refactor(qbittorrent): extract default config to single source` | `apps/qbittorrent/fnos/defaults/qBittorrent.conf` | file exists, no heredoc in scripts |
| 8 | `refactor(scaffold): update new-app.sh for per-app contracts` | `scripts/new-app.sh` | scaffold test + cleanup |
| 9 | `chore: remove old CI scripts, update docs` | deleted `scripts/ci/build-*.sh`, `AGENTS.md`, `README.md` | full integrity check |

---

## Success Criteria

### Verification Commands
```bash
# Case statement elimination
grep -c 'case "\$' .github/workflows/reusable-build-app.yml  # Expected: 0

# Per-app contract completeness
for app in plex emby qbittorrent nginx; do
  ls scripts/apps/${app}/{meta.env,build.sh,get-latest-version.sh,release-notes.tpl}
done  # Expected: all files listed

# qBittorrent cleanup
test ! -f apps/qbittorrent/fnos/cmd/installer && echo "OK"  # Expected: OK
test ! -f apps/qbittorrent/fnos/cmd/functions && echo "OK"  # Expected: OK
grep -c "service_postupgrade" apps/qbittorrent/fnos/cmd/service-setup  # Expected: 1+

# Shared library adoption
for script in apps/*/update_*.sh; do
  grep -l "update-common.sh" "$script"
done  # Expected: all 4 scripts listed

# Old files removed
ls scripts/ci/build-*.sh 2>/dev/null  # Expected: only resolve-release-tag.sh remains

# Syntax checks
bash -n scripts/lib/update-common.sh  # Expected: exit 0
bash -n scripts/ci/resolve-release-tag.sh  # Expected: exit 0

# Help flag tests
bash apps/plex/update_plex.sh --help | head -1  # Expected: contains "用法:"
```

### Final Checklist
- [ ] All "Must Have" present (per-app contracts, APP validation, single qBittorrent.conf, Chinese text preserved)
- [ ] All "Must NOT Have" absent (no shared/cmd/common changes, no entry workflow changes, no new dependencies)
- [ ] Zero `case "$APP"` blocks in reusable workflow
- [ ] All 4 update scripts under 180 lines
- [ ] All bash scripts pass `bash -n` syntax check
- [ ] AGENTS.md and README.md reflect new structure
