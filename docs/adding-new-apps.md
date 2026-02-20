# 新增应用指南

本文档旨在指导开发者如何在 `fnos-apps` 项目中新增并维护第三方应用。本项目采用 monorepo 结构，通过 Bash 脚本将第三方应用重新打包为 fnOS 专用的 `.fpk` 安装包。

在开始之前，请务必阅读 [fnOS 官方开发指南](fnos-developer-guide.md) 以了解 fnOS 应用的基本架构和规范。

---

## 1. 概述

`fnos-apps` 支持两种打包模式：

- **原生二进制模式**: 下载上游二进制产物 -> 合并共享生命周期框架 -> 注入应用特定配置 -> 打包为 .fpk。
- **Docker 容器模式**: 定义 docker-compose.yaml -> 打包容器配置 + UI -> 由 fnOS 管理容器生命周期。

### 核心原则
- **100% Bash**: 项目不使用复杂的包管理器或编译语言，确保构建过程透明且易于维护。
- **透明重打包**: 仅下载并重新组织官方发布的产物，严禁修改上游业务逻辑。
- **非 Root 运行**: 所有应用默认以应用专用用户身份运行，确保系统安全。
- **双架构支持**: 每个原生二进制应用必须同时支持 x86_64 (amd64) 和 arm64 架构。Docker 应用由镜像自身提供多架构支持。

### 选择打包模式

| 场景 | 推荐模式 | 原因 |
|------|----------|------|
| Go / Rust / C/C++ 单二进制 | 原生二进制 | 无运行时依赖，体积小 |
| .deb 包提供的应用 | 原生二进制 | 直接提取二进制即可 |
| Node.js / Java 捆绑运行时 | 原生二进制 | 运行时可打包在 app.tgz 中 |
| 复杂运行时依赖 (.NET, Python venv) | Docker 容器 | 避免依赖地狱 |
| 上游已提供优质 Docker 镜像 | Docker 容器 | 直接复用，维护成本低 |

---

## 2. 快速开始

项目提供了一个脚手架工具，可以快速生成新应用的目录结构和基础模板。

### 使用脚手架
在项目根目录下执行：
```bash
./scripts/new-app.sh <slug> "<display_name>" <port>
```

**示例**:
```bash
./scripts/new-app.sh jellyfin "Jellyfin" 8096
```

该脚本会生成以下文件：
1. `apps/<slug>/fnos/` — 应用定义目录（manifest、cmd、config、ui 等）。
2. `apps/<slug>/CHANGELOG.md` — 更新日志模板。
3. `apps/<slug>/README.md` — 应用说明模板。
4. `scripts/apps/<slug>/` — 构建合约目录（meta.env、build.sh、get-latest-version.sh、release-notes.tpl）。
5. `.github/workflows/build-<slug>.yml` — GitHub Actions 入口工作流（调用可复用工作流）。

> **注意**: 脚手架生成的是**原生二进制模式**的模板。如需 Docker 模式，请参考 [第 5 节](#5-打包策略) 中的 Docker 容器策略。

---

## 3. 目录结构

一个完整的应用由两部分组成：

### 应用定义 (`apps/<app>/fnos/`)

定义应用在 fnOS 系统中的身份和行为。

#### 原生二进制模式
```
apps/<app>/fnos/
├── manifest              # 应用身份证：名称、版本、端口等
├── cmd/
│   └── service-setup     # 应用启动参数配置
├── bin/
│   └── <app>-server      # 启动包装脚本
├── config/
│   ├── privilege          # 权限配置：运行用户和额外用户组
│   └── resource           # 资源配置：数据共享目录等
├── ui/
│   ├── config             # 桌面入口配置
│   └── images/
│       └── 64.png         # 桌面图标
├── <App>.sc               # 防火墙端口转发规则
├── ICON.PNG               # 应用图标 (64x64)
└── ICON_256.PNG           # 应用大图标 (256x256)
```

#### Docker 容器模式
```
apps/<app>/fnos/
├── manifest              # 应用身份证（同上）
├── cmd/
│   ├── main              # 自定义入口：Docker 状态检查（覆盖 shared/cmd/main）
│   └── service-setup     # 生命周期钩子（目录创建、wizard 集成等）
├── docker/
│   └── docker-compose.yaml  # 容器编排定义
├── config/
│   ├── privilege
│   └── resource
├── ui/
│   ├── config
│   └── images/
│       └── 64.png
├── wizard/               # 安装向导 (可选)
│   └── install           # 安装向导 JSON 定义
├── <App>.sc
├── ICON.PNG
└── ICON_256.PNG
```

#### 关键文件说明

| 文件 | 说明 |
|------|------|
| `manifest` | Key=Value 格式，固定宽度对齐（列 16）。包含 `appname`、`version`、`service_port`、`checksum` 等。 |
| `cmd/service-setup` | 原生模式：设置 `SERVICE_COMMAND`、`PID_FILE`、`LOG_FILE`。Docker 模式：定义生命周期钩子。 |
| `cmd/main` | 仅 Docker 模式需要覆盖。原生模式使用 `shared/cmd/main`。 |
| `bin/<app>-server` | 原生模式的启动包装脚本，设置环境变量后 `exec` 实际二进制。 |
| `docker/docker-compose.yaml` | Docker 模式的容器编排。使用 `${VERSION}` 占位符（构建时替换）。 |
| `config/privilege` | JSON 格式。`run-as: package` 表示以应用专用用户运行。可添加 `video`、`render` 等附加组。 |
| `config/resource` | JSON 格式。`data-share` 定义共享目录。 |
| `ui/config` | JSON 格式。定义桌面启动入口的 URL、端口、图标。 |
| `<App>.sc` | 防火墙端口转发规则。 |
| `wizard/install` | 安装向导 JSON。用户安装时可配置自定义路径、密码等。 |

### 构建合约 (`scripts/apps/<app>/`)

定义如何从互联网获取并准备应用产物。详细说明请参考 [构建合约接口规范](../scripts/apps/README.md)。

```
scripts/apps/<app>/
├── meta.env               # 静态元数据
├── get-latest-version.sh  # 自动获取上游最新版本
├── build.sh               # 下载、组装并生成 app.tgz
└── release-notes.tpl      # 发布日志模板 (envsubst 格式)
```

---

## 4. 构建合约

构建合约是 CI/CD 系统的接口规范，每个文件的职责如下：

### `meta.env` — 静态元数据

```bash
FILE_PREFIX=plexmediaserver    # fpk 文件名前缀
RELEASE_TITLE="Plex Media Server"  # 发布标题
DEFAULT_PORT=32400             # 默认端口
HOMEPAGE_URL="https://plex.tv" # 官方网站 (可选)
```

### `get-latest-version.sh` — 版本解析

- **输入**: `$1` — 可选的版本覆盖值。为空时自动解析最新版本。
- **输出 (stdout)**:
  - `VERSION=x.y.z`（必须）
  - `FULL_VERSION=...`（可选，应用特定的详细版本号）
  - `UPSTREAM_TAG=...`（可选，上游仓库的实际 tag 名称）
- **CI 集成**: 当 `$GITHUB_OUTPUT` 环境变量存在时，必须同时写入该文件。

### `build.sh` — 构建逻辑

- **输入**: 通过环境变量传递（由 CI matrix 提供）：
  - `VERSION` — 版本号
  - `DEB_ARCH` — Debian 架构名 (`amd64` / `arm64`)
  - `TARBALL_ARCH` — 通用架构名 (`amd64` / `arm64`)
  - `JRE_ARCH` — JRE 架构名 (`x64` / `aarch64`)
  - 其他应用特定变量（`PLEX_BUILD`、`QB_BINARY_PREFIX` 等）
- **输出**: 当前目录下生成 `app.tgz`。
- **退出码**: `0` 成功，非 `0` 失败。

### `release-notes.tpl` — 发布日志模板

使用 `envsubst` 渲染。可用变量：
- `${VERSION}`、`${FPK_VERSION}`、`${RELEASE_TAG}`、`${FILE_PREFIX}`
- `${REVISION_NOTE}` — 修订版本时自动生成提示
- `${CHANGELOG}` — 从 `apps/<app>/CHANGELOG.md` 自动提取最新条目
- `meta.env` 中定义的所有变量

---

## 5. 打包策略

### Go 单二进制 (最简单)

直接下载对应架构的静态编译二进制文件。

- **参考**: `apps/gopeed/`、`apps/certimate/`、`apps/syncthing/`、`apps/navidrome/`、`apps/sun-panel/`、`apps/openlist/`
- **特点**: 无需额外依赖。在 `bin/` 中编写启动包装脚本，设置环境变量后 `exec` 实际二进制。
- **build.sh 模式**:
  ```bash
  # 下载 -> 解压 -> 复制 bin/ 和 ui/ -> 打包 app.tgz
  curl -L -o app.tar.gz "$DOWNLOAD_URL"
  mkdir -p app_root/bin app_root/ui
  tar -xzf app.tar.gz -C app_root
  cp apps/<app>/fnos/bin/<app>-server app_root/bin/
  cd app_root && tar -czf ../app.tgz .
  ```

### .deb 提取

许多 Linux 应用提供 `.deb` 包，可以提取其中的文件。

- **参考**: `apps/plex/`、`apps/emby/`、`apps/jellyfin/`
- **特点**: 使用 `ar -x` 提取 `.deb`，再解压 `data.tar.xz`，将应用文件复制到 `app_root`。
- **注意**: 媒体类应用通常需要在 `config/privilege` 中添加 `video` 和 `render` 组以支持硬件转码。

### Java 应用

可以选择捆绑 JRE 或声明运行时依赖。

- **参考**: `apps/ani-rss/`（捆绑 JRE）
- **策略**: 推荐在 `manifest` 中声明 `install_dep_apps = java-17-openjdk`。如需特定 JRE 版本，可在 `build.sh` 中下载并捆绑。

### Node.js 应用

对于需要特定 Node.js 版本或复杂依赖的应用。

- **参考**: `apps/audiobookshelf/`
- **策略**: 在 `build.sh` 中下载对应架构的 Node.js 二进制，并编写包装脚本启动应用。

### Docker 容器 (复杂运行时依赖)

适用于运行时依赖复杂的应用，或上游已提供优质 Docker 镜像的场景。

- **参考**: `apps/vaultwarden/`（Rust）、`apps/moviepilot/`（Python）、`apps/kavita/`（.NET）、`apps/tinymediamanager/`（Java）
- **特点**:
  - `app.tgz` 中仅包含 `docker/docker-compose.yaml` 和 `ui/` 目录，体积极小。
  - 必须覆盖 `cmd/main`，使用 Docker 状态检查逻辑替代共享的 PID 管理。
  - 容器的 start/stop 由 fnOS 平台管理，`cmd/main` 中的 `start)` 和 `stop)` 直接 `exit 0`。
- **docker-compose.yaml 约定**:
  ```yaml
  services:
    <app>:
      image: <registry>/<image>:${VERSION}  # 构建时替换版本
      container_name: <app>
      ports:
        - "${TRIM_SERVICE_PORT}:<container_port>"
      volumes:
        - ${TRIM_PKGVAR}/data:/data
      environment:
        - TZ=Asia/Shanghai
      restart: unless-stopped
  ```
- **cmd/main 模板** (Docker 模式固定写法):
  ```bash
  #!/bin/bash
  FILE_PATH="${TRIM_APPDEST}/docker/docker-compose.yaml"
  is_docker_running () {
      DOCKER_NAME=""
      if [ -f "$FILE_PATH" ]; then
          DOCKER_NAME=$(cat $FILE_PATH | grep "container_name" | awk -F ':' '{print $2}' | xargs)
      fi
      if [ -n "$DOCKER_NAME" ]; then
          docker inspect $DOCKER_NAME | grep -q "\"Status\": \"running\"," || exit 1
          return
      fi
  }
  case $1 in
  start) exit 0 ;;
  stop) exit 0 ;;
  status) if is_docker_running; then exit 0; else exit 3; fi ;;
  *) exit 1 ;;
  esac
  ```
- **build.sh 模式** (Docker 应用通用):
  ```bash
  # 复制 docker-compose.yaml -> 替换 ${VERSION} -> 打包 app.tgz
  mkdir -p "${WORK_DIR}/docker"
  cp "apps/<app>/fnos/docker/docker-compose.yaml" "${WORK_DIR}/docker/"
  sed -i "s/\${VERSION}/${VERSION}/g" "${WORK_DIR}/docker/docker-compose.yaml"
  cp -a "apps/<app>/fnos/ui" "${WORK_DIR}/ui"
  cd "${WORK_DIR}" && tar czf ../app.tgz docker/ ui/
  ```

### 预置配置 (复杂应用)

对于需要初始化配置或数据库的应用。

- **参考**: `apps/qbittorrent/`
- **策略**: 在 `build.sh` 中使用 `cat << EOF` 生成初始配置，并利用 `service_postupgrade` 钩子进行初始化。

---

## 6. 共享生命周期框架

### 原生模式的执行链

```
shared/cmd/main       → sources common → sources service-setup
shared/cmd/installer  → sources common → sources service-setup → loads wizard variables
```

`main` 脚本处理 `start`/`stop`/`status` 命令，通过 `SERVICE_COMMAND` 管理进程。

### 可用的生命周期钩子

在 `cmd/service-setup` 中重写以下函数即可自定义行为（默认均为空操作）：

| 钩子 | 触发时机 | 典型用途 |
|------|----------|----------|
| `service_preinst` | 安装前 | 环境预检 |
| `service_postinst` | 安装后 | 创建目录、初始化配置、设置权限 |
| `service_preuninst` | 卸载前 | 强制停止残留进程 |
| `service_postuninst` | 卸载后 | 清理额外资源 |
| `service_preupgrade` | 升级前 | 备份配置文件 |
| `service_save` | 升级前（preupgrade 之后） | 保存状态 |
| `service_restore` | 升级后（postupgrade 之前） | 恢复状态 |
| `service_postupgrade` | 升级后 | 数据迁移、配置初始化 |
| `service_prestart` | 启动前 | 启动前准备 |
| `service_poststop` | 停止后 | 清理锁文件、残留进程 |

### 常用工具函数

| 函数 | 说明 |
|------|------|
| `error_exit "msg"` | 向用户展示错误弹窗并退出（写入 `TRIM_TEMP_LOGFILE`） |
| `install_log "msg"` | 带时间戳的安装日志 |
| `get_key_value file key` | 从 key=value 文件中读取值 |
| `sync_var_folder` | 将 `TRIM_APPDEST/var/` 同步到 `TRIM_PKGVAR`（install_callback 自动调用） |
| `fix_data_ownership` | 修复数据目录所有权（upgrade_callback 自动调用） |

### 覆盖模式 (Overlay Pattern)

构建 `.fpk` 时，`scripts/build-fpk.sh` 会：
1. 先复制 `shared/cmd/*` 中的通用框架脚本。
2. 再复制 `apps/<app>/fnos/cmd/*` 中的文件进行覆盖。

**原则**: 除非需要特殊逻辑，否则不要在应用目录中重复编写 `common`、`installer` 等共享脚本。仅覆盖 `service-setup`，以及 Docker 模式下的 `main`。

### fnOS 运行时环境变量

| 变量 | 说明 |
|------|------|
| `TRIM_APPNAME` | 应用名称 |
| `TRIM_APPDEST` | 应用安装目录 |
| `TRIM_PKGVAR` | 应用数据目录 |
| `TRIM_PKGETC` | 应用配置目录 |
| `TRIM_PKGHOME` | 应用 home 目录 |
| `TRIM_TEMP_LOGFILE` | 临时日志文件（错误弹窗用） |
| `TRIM_TEMP_UPGRADE_FOLDER` | 升级临时目录 |
| `TRIM_APP_STATUS` | 应用当前状态 |
| `TRIM_SERVICE_PORT` | 配置的服务端口 |
| `TRIM_UID` / `TRIM_GID` | 应用运行用户的 UID/GID |
| `TRIM_USERNAME` / `TRIM_GROUPNAME` | 应用运行用户/组名 |

---

## 7. 本地构建

### 使用 update 脚本

每个原生模式应用目录下都有一个 `update_<app>.sh` 脚本，它封装了本地构建逻辑。

```bash
cd apps/plex
./update_plex.sh             # 最新版本，自动检测架构
./update_plex.sh --arch x86  # 构建 x86 版本
./update_plex.sh --arch arm  # 构建 ARM 版本
./update_plex.sh 1.42.2      # 指定版本
```

构建产物输出到 `dist/` 目录。

### 共享构建库 `scripts/lib/update-common.sh`

本地构建脚本引用此共享库，采用**回调模式**：

```bash
#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# === 必须定义的变量 ===
APP_NAME="myapp"
APP_DISPLAY_NAME="My App"
APP_VERSION="${MYAPP_VERSION:-latest}"
APP_FPK_PREFIX="myapp"
APP_DEPS=(curl tar)          # 依赖的系统命令

PKG_DIR="$SCRIPT_DIR/fnos"   # manifest 所在目录

# === 必须定义的回调函数 ===
app_get_latest_version() {
    # 获取最新版本号，更新 APP_VERSION
}

app_download() {
    # 下载上游产物到 $WORK_DIR
}

app_build_app_tgz() {
    # 在 $WORK_DIR 中组装并生成 app.tgz
}

# === 可选回调函数 ===
app_set_arch_vars() {
    # 根据 $ARCH (x86/arm) 设置应用特定的架构变量
}

app_compare_version() {
    # 返回用于比较和命名的版本字符串（默认 $APP_VERSION）
    echo "$APP_VERSION"
}

# 加载共享库并执行
source "$REPO_ROOT/scripts/lib/update-common.sh"
main_flow "$@"
```

共享库提供：
- 架构自动检测（`detect_arch`）
- 参数解析（`--arch`、`--help`、版本号）
- 临时目录管理（cleanup trap）
- `manifest` 自动更新（版本、校验和、平台）
- 调用 `scripts/build-fpk.sh` 进行最终打包

### 使用通用打包脚本

对于不使用 update 脚本的场景，可以直接使用通用打包脚本：

```bash
# 先构建 app.tgz，再打包为 .fpk
./scripts/build-fpk.sh apps/plex app.tgz [version] [platform]
```

`build-fpk.sh` 会验证必要文件（manifest、cmd/、config/、ICON.PNG、ICON_256.PNG），并自动将 `ICON_256.PNG` 复制为 `ui/images/256.png`。

---

## 8. CI/CD

### 架构概览

项目使用 GitHub Actions，采用**入口工作流 + 可复用工作流**的两层结构。

```
.github/workflows/
├── reusable-build-app.yml     # 可复用工作流：版本检测 → 双架构构建 → 发布
├── build-plex.yml             # 入口：触发条件 + 调用 reusable-build-app
├── build-emby.yml
├── build-<app>.yml            # 每个应用一个入口工作流
└── update-apps-json.yml       # 发布后自动更新 apps.json
```

### 入口工作流

每个应用的入口工作流结构相同，仅 `app` 参数和触发路径不同：

```yaml
name: Build <Display Name> fnOS Package
permissions:
  contents: write
on:
  push:
    paths: ['apps/<app>/**', 'shared/**', '!**/*.md']
  schedule:
    - cron: '0 8 * * *'
  workflow_dispatch:
    inputs:
      version:
        description: 'Version (leave empty for latest)'
      revision:
        description: 'Revision suffix (e.g., r2)'
jobs:
  build:
    uses: ./.github/workflows/reusable-build-app.yml
    with:
      app: <app-slug>
      version: ${{ github.event.inputs.version || '' }}
      revision: ${{ github.event.inputs.revision || '' }}
      event_name: ${{ github.event_name }}
    secrets: inherit
```

### 可复用工作流 (`reusable-build-app.yml`)

三阶段流水线：

1. **check-version**: 运行 `get-latest-version.sh` 解析版本 → 调用 `scripts/ci/resolve-release-tag.sh` 确定发布标签。
2. **build** (matrix: x86 + arm): 运行 `build.sh` 生成 `app.tgz` → 调用 `build-fpk.sh` 打包 `.fpk`。
3. **release**: 创建 GitHub Release，上传双架构 `.fpk` 文件，渲染发布日志。

**`VALID_APPS` 白名单**: `reusable-build-app.yml` 中维护了一份合法应用列表。**新增应用时必须将 slug 添加到此列表**，否则 CI 会拒绝构建。

### 版本标签规范

- 标签格式：`<app-slug>/v<version>`，如 `plex/v1.42.2.10156`。
- 修订后缀：同一版本需要重新发布时，自动递增 `-r1`、`-r2`、`-r3`...
- `scripts/ci/resolve-release-tag.sh` 自动处理：
  - 定时任务 → 使用基础标签
  - 手动触发，指定 revision → 使用指定后缀
  - 手动触发，标签已存在 → 自动递增修订号
  - 标签已有 Release → 跳过构建（幂等）

### `apps.json` 自动生成

每次发布后，`update-apps-json.yml` 工作流会调用 `scripts/ci/generate-apps-json.sh` 从所有应用的 manifest + GitHub Release 元数据自动生成 `apps.json`。此文件供 `fnos-store` 使用，**无需手动维护**。

---

## 9. 发布维护

### 更新日志

每次发布新版本或修复打包问题时，必须更新 `apps/<app>/CHANGELOG.md`。

- 格式必须为 `## YYYY-MM-DD`，最新条目在前。
- CI 会自动提取最新的一段内容（第一个 `##` 到第二个 `##` 之间）作为发布日志的 `${CHANGELOG}` 变量。

示例：
```markdown
## 2026-02-10

- 改为非 root 用户运行，提升安全性
- 升级后需手动为数据目录添加对应用户的读写权限

## 2026-01-15

- 首次发布
```

---

## 10. 检查清单

### 所有应用通用

- [ ] **manifest**: `appname`、`display_name`、`service_port`、`desc` 是否填写完整？
- [ ] **图标**: 是否包含 `ICON.PNG` (64x64) 和 `ICON_256.PNG` (256x256)？
- [ ] **UI 图标**: `ui/images/64.png` 是否存在？（`256.png` 由 `build-fpk.sh` 自动从 `ICON_256.PNG` 复制）
- [ ] **权限**: `config/privilege` 是否配置了正确的运行用户？
- [ ] **端口**: `manifest` 中的 `service_port` 是否与应用默认端口一致？
- [ ] **防火墙**: `<App>.sc` 文件是否定义了端口转发规则？
- [ ] **构建合约**: `meta.env`、`get-latest-version.sh`、`build.sh`、`release-notes.tpl` 是否齐全？
- [ ] **CI 入口**: `.github/workflows/build-<app>.yml` 是否创建？
- [ ] **VALID_APPS**: 是否已将 slug 添加到 `reusable-build-app.yml` 的 `VALID_APPS` 列表？
- [ ] **CHANGELOG**: `apps/<app>/CHANGELOG.md` 是否包含首次发布条目？

### 原生二进制模式追加

- [ ] **双架构**: `build.sh` 是否正确处理了 `x86_64` 和 `aarch64`？
- [ ] **启动脚本**: `bin/<app>-server` 是否正确设置环境变量并 `exec` 二进制？
- [ ] **service-setup**: `SERVICE_COMMAND`、`PID_FILE`、`LOG_FILE` 路径是否正确？
- [ ] **校验和**: `manifest` 中的 `checksum` 字段在本地构建后是否已更新？
- [ ] **清理**: `build.sh` 是否清理了下载的临时文件？

### Docker 容器模式追加

- [ ] **docker-compose.yaml**: 是否使用 `${VERSION}` 占位符？
- [ ] **端口映射**: 是否使用 `${TRIM_SERVICE_PORT}:<container_port>`？
- [ ] **cmd/main**: 是否覆盖为 Docker 状态检查逻辑？
- [ ] **数据持久化**: volumes 是否正确映射到 `${TRIM_PKGVAR}`？
- [ ] **wizard**: 如需用户配置自定义路径，是否提供了安装向导？

---

## 11. 常见问题

### 如何检测当前架构？

在 Bash 脚本中使用 `uname -m`。在 `update-common.sh` 环境下，可以直接使用 `$ARCH` 变量（值为 `x86` 或 `arm`）。在 CI build matrix 中，架构相关变量通过环境变量传递（`DEB_ARCH`、`TARBALL_ARCH` 等）。

### 应用启动失败怎么办？

1. 检查 `TRIM_TEMP_LOGFILE` 中的日志。
2. 确保 `cmd/service-setup` 中的 `SERVICE_COMMAND` 路径正确。
3. 检查 `config/privilege` 是否缺少必要的系统组（如硬件转码需要的 `video` 组）。
4. Docker 应用：检查 `docker inspect <container_name>` 和 `docker logs <container_name>`。

### 如何处理嵌套依赖？

fnOS 目前仅支持一层依赖检查。如果应用 A 依赖 B，B 依赖 C，请在 A 的 `manifest` 中同时声明 B 和 C。

### Docker 应用和原生应用有什么区别？

| 方面 | 原生二进制 | Docker 容器 |
|------|-----------|-------------|
| app.tgz 内容 | 实际二进制 + 启动脚本 | docker-compose.yaml + UI |
| 进程管理 | 共享框架通过 PID 管理 | fnOS 平台管理容器 |
| cmd/main | 使用 shared/cmd/main | 必须覆盖为 Docker 状态检查 |
| 架构支持 | build.sh 下载对应架构二进制 | Docker 镜像自身提供多架构 |
| 包体积 | 取决于二进制大小（几 MB~100MB+） | 极小（仅 YAML + 图标） |
| 首次启动 | 即时 | 需要拉取 Docker 镜像 |

### 如何向用户展示错误信息？

使用 `error_exit "错误信息"` 函数。它会将消息写入 `TRIM_TEMP_LOGFILE` 并退出，fnOS 前端会弹窗展示给用户。

### 修订发布 (-rN) 是什么？

当需要修复打包问题（如脚本 bug）但上游版本未变时，发布修订版本。CI 会自动在标签后追加 `-r1`、`-r2` 等后缀。用户需卸载后重新安装修订版。
