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
│   └── ci/              # CI 共享脚本（版本判定/各应用构建）
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
- 各应用构建步骤拆分到 `scripts/ci/build-*.sh`，降低 workflow 内联脚本复杂度。
- `scripts/build-fpk.sh` 已增加打包前结构校验（manifest 关键字段、`cmd/config/ui`、图标文件）。

## 迁移与维护说明

- 新增应用时，优先复用 `scripts/build-fpk.sh` 与 `/.github/workflows/reusable-build-app.yml`，避免再复制整段打包 YAML。
- 如需调整发布标签策略，请只修改 `scripts/ci/resolve-release-tag.sh`。
- 如需调整某个应用“下载/解包/组装 app.tgz”逻辑，请修改对应 `scripts/ci/build-<app>.sh`。
- `shared/cmd` 已补充 `config_init/config_callback` 入口，可用于配置变更后的服务重载。

## 开源透明

本项目完全开源，仅从官方渠道下载原版软件并重新打包，**无任何后门或修改**。构建脚本和 CI 流程公开透明，欢迎审查。
