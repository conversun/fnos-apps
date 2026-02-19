# 新增应用指南

本文档旨在指导开发者如何在 `fnos-apps` 项目中新增并维护第三方应用。本项目采用 monorepo 结构，通过 Bash 脚本将第三方应用重新打包为 fnOS 专用的 `.fpk` 安装包。

在开始之前，请务必阅读 [fnOS 官方开发指南](fnos-developer-guide.md) 以了解 fnOS 应用的基本架构和规范。

---

## 1. 概述

`fnos-apps` 的核心逻辑是：**下载上游二进制产物 -> 合并共享生命周期框架 -> 注入应用特定配置 -> 打包为 .fpk**。

### 核心原则
- **100% Bash**: 项目不使用复杂的包管理器或编译语言，确保构建过程透明且易于维护。
- **透明重打包**: 仅下载并重新组织官方发布的产物，严禁修改上游业务逻辑。
- **非 Root 运行**: 所有应用默认以应用专用用户身份运行，确保系统安全。
- **双架构支持**: 每个应用必须同时支持 x86_64 (amd64) 和 arm64 架构。

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

该脚本会生成以下关键文件：
1. `apps/jellyfin/fnos/`: 应用定义目录（图标、manifest、权限等）。
2. `scripts/apps/jellyfin/`: 构建合约目录（下载逻辑、版本获取等）。
3. `.github/workflows/build-jellyfin.yml`: GitHub Actions 自动构建流水线。

---

## 3. 目录结构

一个完整的应用由两部分组成：

### 应用定义 (`apps/{app}/fnos/`)
定义应用在 fnOS 系统中的身份和行为。
- `manifest`: 应用身份证，包含名称、版本、端口等。
- `config/privilege`: 权限配置，定义运行用户和额外用户组。
- `config/resource`: 资源配置，定义数据共享目录等。
- `cmd/service-setup`: 应用特定的启动参数配置。
- `ui/config`: 桌面入口配置。
- `ICON.PNG` / `ICON_256.PNG`: 应用图标。

### 构建合约 (`scripts/apps/{app}/`)
定义如何从互联网获取并准备应用产物。
- `meta.env`: 静态元数据（前缀、标题、默认端口）。
- `get-latest-version.sh`: 自动获取上游最新版本的逻辑。
- `build.sh`: 下载、解压并生成 `app.tgz` 的核心逻辑。
- `release-notes.tpl`: 发布日志模板。

---

## 4. 构建合约

构建合约是 CI/CD 系统的接口规范，详细说明请参考 [构建合约接口规范](../scripts/apps/README.md)。

### 关键脚本说明
- **`get-latest-version.sh`**: 必须输出 `VERSION=x.y.z`。如果运行在 GitHub Actions 环境，还需写入 `$GITHUB_OUTPUT`。
- **`build.sh`**: 接收版本和架构参数，最终必须在当前目录生成 `app.tgz`。`app.tgz` 解压后的内容将作为应用的 `target` 目录。

---

## 5. 打包策略

根据应用类型的不同，我们采用不同的打包策略：

### Go 单二进制 (最简单)
直接下载对应架构的静态编译二进制文件。
- **参考**: `apps/gopeed/`
- **特点**: 无需额外依赖，直接放入 `bin/` 即可。

### Java 捆绑 JRE (或依赖运行时)
对于 Java 应用，可以选择在 `app.tgz` 中捆绑轻量级 JRE，或者利用 fnOS 提供的运行时环境。
- **参考**: `apps/ani-rss/`
- **策略**: 推荐在 `manifest` 中声明 `install_dep_apps = java-17-openjdk` 以减小包体积。如果需要特定版本的 JRE，也可以在 `build.sh` 中下载并捆绑。

### Node.js 应用 (捆绑运行时)
对于需要特定 Node.js 版本或复杂依赖的应用，可以在构建时捆绑运行时。
- **参考**: `apps/audiobookshelf/`
- **策略**: 在 `build.sh` 中下载对应架构的 Node.js 二进制，并编写包装脚本（Wrapper）来启动应用。

### .deb 提取 (主流策略)
许多 Linux 应用提供 `.deb` 包，我们可以提取其中的文件。
- **参考**: `apps/plex/`
- **策略**: 使用 `ar -x` 提取 `.deb`，再解压 `data.tar.xz`，将 `usr/lib/{appname}` 下的内容复制到 `app_root`。

### 预置配置 (复杂应用)
对于需要初始化配置或数据库的应用，可以在 `build.sh` 中生成默认配置文件。
- **参考**: `apps/qbittorrent/`
- **策略**: 在 `build.sh` 中使用 `cat << EOF` 生成初始配置，并利用 `service_postupgrade` 钩子进行初始化。

---

## 6. 本地构建

在提交代码前，建议在本地进行构建测试。

### 使用 update 脚本
每个应用目录下都有一个 `update_{app}.sh` 脚本，它封装了本地构建逻辑。
```bash
cd apps/plex
./update_plex.sh --arch x86  # 构建 x86 版本
./update_plex.sh --arch arm  # 构建 ARM 版本
```

### 共享库 `update-common.sh`
本地构建脚本通常会引用 `scripts/lib/update-common.sh`，它提供了：
- 架构自动检测。
- 临时目录管理（Cleanup Trap）。
- `manifest` 自动更新（版本、校验和）。
- 调用 `scripts/build-fpk.sh` 进行最终打包。

---

## 7. CI/CD

项目使用 GitHub Actions 进行自动化管理。

### 工作流逻辑
1. **Check Version**: 每天定时运行 `get-latest-version.sh`，对比已发布的版本。
2. **Build Matrix**: 如果有新版本，启动 x86 和 arm 双架构构建任务。
3. **Release**: 构建成功后，自动创建 GitHub Release 并上传 `.fpk` 文件。

### 版本标签规范
标签采用命名空间格式：`appname/v1.2.3`。
如果同一版本需要重新发布（如修复了打包脚本），请使用修订后缀：`appname/v1.2.3-r2`。

---

## 8. 发布维护

### 更新日志
每次发布新版本或修复打包问题时，必须更新 `apps/{app}/CHANGELOG.md`。
- 格式必须为 `## YYYY-MM-DD`。
- CI 会自动提取最新的一段内容作为发布日志。

### 覆盖模式 (Overlay Pattern)
构建 `.fpk` 时，系统会：
1. 先复制 `shared/cmd/*` 中的通用框架脚本。
2. 再复制 `apps/{app}/fnos/cmd/*` 中的文件进行覆盖。
**注意**: 除非需要特殊逻辑，否则不要在应用目录中重复编写 `main` 或 `installer` 脚本。

---

## 9. 检查清单

在提交 PR 之前，请检查以下事项：
- [ ] **双架构**: `build.sh` 是否正确处理了 `x86_64` 和 `aarch64`？
- [ ] **图标**: 是否包含 `ICON.PNG` (64x64) 和 `ICON_256.PNG` (256x256)？
- [ ] **权限**: `config/privilege` 是否配置了正确的运行用户？
- [ ] **端口**: `manifest` 中的 `service_port` 是否与应用默认端口一致？
- [ ] **校验和**: `manifest` 中的 `checksum` 字段在本地构建后是否已更新？
- [ ] **清理**: `build.sh` 是否清理了下载的临时文件？

---

## 10. 常见问题

### 如何检测当前架构？
在 Bash 脚本中使用 `uname -m`。在 `update-common.sh` 环境下，可以直接使用 `$ARCH` 变量（值为 `x86` 或 `arm`）。

### 应用启动失败怎么办？
1. 检查 `TRIM_TEMP_LOGFILE` 中的日志。
2. 确保 `cmd/service-setup` 中的 `SERVICE_COMMAND` 路径正确。
3. 检查 `config/privilege` 是否缺少必要的系统组（如硬件转码需要的 `video` 组）。

### 如何处理嵌套依赖？
fnOS 目前仅支持一层依赖检查。如果应用 A 依赖 B，B 依赖 C，请在 A 的 `manifest` 中同时声明 B 和 C。
