# fnOS Apps

飞牛 fnOS 第三方应用集合，每日自动同步上游最新版本并构建 `.fpk` 安装包。

## 应用列表

| 应用 | 端口 | 说明 | 下载 |
|------|------|------|------|
| [Plex Media Server](apps/plex/) | 32400 | 媒体服务器，支持硬件转码 | [Releases](https://github.com/conversun/fnos-apps/releases?q=plex) |
| [Emby Server](apps/emby/) | 8096 | 媒体管理和流式传输 | [Releases](https://github.com/conversun/fnos-apps/releases?q=emby) |
| [qBittorrent](apps/qbittorrent/) | 8085 | 轻量级 BitTorrent 客户端 | [Releases](https://github.com/conversun/fnos-apps/releases?q=qbittorrent) |
| [Nginx](apps/nginx/) | 8888 | 高性能 HTTP 和反向代理服务器 | [Releases](https://github.com/conversun/fnos-apps/releases?q=nginx) |

## 安装

1. 从上方链接下载对应应用的 `.fpk` 文件（x86 或 arm）
2. 在 fnOS 应用管理中选择「手动安装」
3. 上传 fpk 文件完成安装

## 项目结构

```
fnos-apps/
├── shared/              # 共享框架（所有应用复用）
│   ├── cmd/             # 通用生命周期脚本和守护进程管理
│   └── wizard/          # 通用向导模板
├── apps/
│   ├── plex/            # Plex 应用特有文件
│   ├── emby/            # Emby 应用特有文件
│   ├── qbittorrent/     # qBittorrent 应用特有文件
│   └── nginx/           # Nginx 应用特有文件
├── scripts/
│   ├── build-fpk.sh     # 通用 fpk 打包脚本
│   ├── new-app.sh       # 新应用脚手架
│   ├── apps/            # 各应用构建合约（meta.env, build.sh, get-latest-version.sh, release-notes.tpl）
│   │   ├── plex/
│   │   ├── emby/
│   │   ├── qbittorrent/
│   │   └── nginx/
│   ├── lib/             # 共享构建工具库
│   │   └── update-common.sh  # 应用构建通用函数
│   └── ci/              # CI 辅助脚本
│       └── resolve-release-tag.sh  # 版本标签判定（含 -r2/-r3 自动递增）
└── .github/workflows/   # 入口工作流 + 可复用 workflow 模板
```

## 新增应用

```bash
./scripts/new-app.sh jellyfin "Jellyfin Media Server" 8096
```

## 本地构建

```bash
cd apps/plex && ./update_plex.sh
cd apps/emby && ./update_emby.sh
cd apps/qbittorrent && ./update_qbittorrent.sh
cd apps/nginx && ./update_nginx.sh
```

## 统一 CI / 打包架构（2026 重构）

- 所有应用最终打包统一使用 `scripts/build-fpk.sh`，避免重复实现与行为漂移。
- CI 统一收敛到 `/.github/workflows/reusable-build-app.yml`，入口 workflow 仅负责触发与传参。
- 版本发布标签判定统一使用 `scripts/ci/resolve-release-tag.sh`（包含 `-r2/-r3` 自动递增逻辑）。
- 各应用构建步骤拆分到 `scripts/apps/<app>/build.sh`，降低 workflow 内联脚本复杂度。
- `scripts/build-fpk.sh` 已增加打包前结构校验（manifest 关键字段、`cmd/config/ui`、图标文件）。

## 迁移与维护说明

- 新增应用时，优先复用 `scripts/build-fpk.sh` 与 `/.github/workflows/reusable-build-app.yml`，避免再复制整段打包 YAML。
- 如需调整发布标签策略，请只修改 `scripts/ci/resolve-release-tag.sh`。
- 如需调整某个应用"下载/解包/组装 app.tgz"逻辑，请修改对应 `scripts/apps/<app>/build.sh`。
- `shared/cmd` 已补充 `config_init/config_callback` 入口，可用于配置变更后的服务重载。

## 更新日志

### 2026-02-10 安全与打包改进

**⚠️ 重要变更：所有应用改为非 root 用户运行**

为提升安全性，所有应用（Plex、Emby、qBittorrent、Nginx）均已从 `root` 改为以独立用户身份运行。

升级时自动修正数据目录权限，无需手动操作。各应用运行用户：Plex → `plex`，Emby → `EmbyServer`，qBittorrent → `qBittorrent`，Nginx → `nginxserver`。

**其他改进：**
- 修复 Nginx 启动时 `could not open error log file` 错误
- CI 不再由代码推送触发，仅在每日定时检查上游更新或手动触发时构建
- 修订版发布（`-r2`、`-r3`）说明：修订版仅包含打包修复，如当前版本运行正常无需更新；修订版需先卸载再重新安装
- 本地构建产物统一输出到 `dist/` 目录

## 开源透明

本项目完全开源，仅从官方渠道下载原版软件并重新打包，**无任何后门或修改**。构建脚本和 CI 流程公开透明，欢迎审查。
