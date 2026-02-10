# fnOS Apps

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Apps](https://img.shields.io/badge/apps-7-2ea44f)
![Platform](https://img.shields.io/badge/fnOS-third--party-orange)

面向飞牛 fnOS 的第三方应用打包仓库。项目会自动跟踪上游版本并构建可直接安装的 `.fpk` 包。

## 支持应用

| App | Port | Notes | Release |
|---|---:|---|---|
| [Plex](apps/plex/) | 32400 | 媒体服务器，支持硬件转码 | [Download](https://github.com/conversun/fnos-apps/releases?q=plex) |
| [Emby](apps/emby/) | 8096 | 媒体管理与流式传输 | [Download](https://github.com/conversun/fnos-apps/releases?q=emby) |
| [Jellyfin](apps/jellyfin/) | 8097 | 开源媒体系统，内置 FFmpeg | [Download](https://github.com/conversun/fnos-apps/releases?q=jellyfin) |
| [qBittorrent](apps/qbittorrent/) | 8085 | BitTorrent 客户端，默认账号 `admin/adminadmin` | [Download](https://github.com/conversun/fnos-apps/releases?q=qbittorrent) |
| [Gopeed](apps/gopeed/) | 9999 | 高速下载器，支持 HTTP/BT/Magnet | [Download](https://github.com/conversun/fnos-apps/releases?q=gopeed) |
| [ANI-RSS](apps/ani-rss/) | 7789 | 动漫 RSS 工具，默认账号 `admin/admin` | [Download](https://github.com/conversun/fnos-apps/releases?q=ani-rss) |
| [Nginx](apps/nginx/) | 8888 | HTTP 服务与反向代理 | [Download](https://github.com/conversun/fnos-apps/releases?q=nginx) |

## 反馈与请求

- 新应用请求：[Open App Request](https://github.com/conversun/fnos-apps/issues/new?template=new-app-request.yml)
- 问题反馈：[Open Bug Report](https://github.com/conversun/fnos-apps/issues/new?template=bug-report.yml)

## 快速开始

### 安装

1. 打开对应 App 的 Release 页面并下载 `.fpk`
2. 在 fnOS 应用中心选择「手动安装」
3. 上传 `.fpk` 并完成安装

### 本地构建

```bash
cd apps/plex && ./update_plex.sh
cd apps/emby && ./update_emby.sh
cd apps/jellyfin && ./update_jellyfin.sh
cd apps/qbittorrent && ./update_qbittorrent.sh
cd apps/gopeed && ./update_gopeed.sh
cd apps/ani-rss && ./update_ani-rss.sh
cd apps/nginx && ./update_nginx.sh
```

构建产物统一输出到仓库根目录 `dist/`。

## 项目结构

```text
fnos-apps/
├── apps/                    # 各应用的 fnOS 包定义与本地构建脚本
├── shared/                  # 通用生命周期脚本与向导模板
├── scripts/
│   ├── build-fpk.sh         # 通用 fpk 打包器
│   ├── new-app.sh           # 新应用脚手架
│   ├── apps/<app>/          # 每个应用的构建合约
│   └── ci/resolve-release-tag.sh
└── .github/workflows/       # 入口 workflow + 可复用构建 workflow
```

## 新增应用（维护者）

```bash
./scripts/new-app.sh <app-slug> "<display-name>" <port>
# example
./scripts/new-app.sh jellyfin "Jellyfin" 8097
```

推荐流程：

1. 在 `apps/<app>/` 完成 fnOS 清单和启动脚本
2. 在 `scripts/apps/<app>/` 完成版本探测与 `app.tgz` 组装
3. 新增 `.github/workflows/build-<app>.yml` 入口 workflow
4. 将 app 名称加入 `reusable-build-app.yml` 的 `VALID_APPS`

## CI/CD 设计

- 统一使用 `scripts/build-fpk.sh` 打包，减少各应用行为漂移
- 统一使用 `reusable-build-app.yml` 实现版本检查、矩阵构建、发布
- 标签策略由 `scripts/ci/resolve-release-tag.sh` 管理，支持 `-r2/-r3` 修订版自动递增
- 日常构建由定时任务和手动触发驱动，不由普通 push 触发

## 变更记录

项目变更记录请查看 [CHANGELOG.md](CHANGELOG.md)。

## 图标来源

应用图标来自 [Dashboard Icons](https://dashboardicons.com)（MIT License）。

## 安全与透明

- 本仓库仅下载并重打包官方发布内容，不修改上游业务逻辑
- 当前应用均按非 root 用户运行（提升默认安全性）
- 构建脚本、CI 流程与发布记录均公开可审计
