# fnOS Apps

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Apps](https://img.shields.io/badge/apps-18-2ea44f)
![Platform](https://img.shields.io/badge/fnOS-third--party-orange)

面向飞牛 fnOS 的第三方应用打包仓库。自动跟踪上游版本，构建可直接安装的 `.fpk` 包。

> ⭐️ 如果觉得本项目对你有帮助，请右上角点个 Star！

## 应用一览

> 💡 推荐先安装 **fnOS Apps** 应用中心，可一键管理以下所有应用的安装与更新。

### 📦 应用中心

| | App | 端口 | 说明 | 下载 |
|:---:|---|---:|---|:---:|
| <img src="apps/fnos-apps-store/fnos/ICON.PNG" width="28"> | [**fnOS Apps**](apps/fnos-apps-store/) | `8011` | 第三方应用中心，一键安装与更新 | [Release][r-store] |

### 🎬 媒体服务

| | App | 端口 | 说明 | 下载 |
|:---:|---|---:|---|:---:|
| <img src="apps/plex/fnos/ICON.PNG" width="28"> | [**Plex**](apps/plex/) | `32400` | 媒体服务器，支持硬件转码 | [Release][r-plex] |
| <img src="apps/emby/fnos/ICON.PNG" width="28"> | [**Emby**](apps/emby/) | `8096` | 媒体管理与流式传输 | [Release][r-emby] |
| <img src="apps/jellyfin/fnos/ICON.PNG" width="28"> | [**Jellyfin**](apps/jellyfin/) | `8097` | 开源媒体系统，内置 FFmpeg | [Release][r-jellyfin] |
| <img src="apps/navidrome/fnos/ICON.PNG" width="28"> | [**Navidrome**](apps/navidrome/) | `4533` | 音乐流媒体服务器 | [Release][r-navidrome] |
| <img src="apps/kavita/fnos/ICON.PNG" width="28"> | [**Kavita**](apps/kavita/) | `5000` | 漫画/电子书阅读 | [Release][r-kavita] |
| <img src="apps/tinymediamanager/fnos/ICON.PNG" width="28"> | [**tinyMediaManager**](apps/tinymediamanager/) | `5800` | 影视元数据管理 | [Release][r-tmm] |

### ⬇️ 下载工具

| | App | 端口 | 说明 | 下载 |
|:---:|---|---:|---|:---:|
| <img src="apps/qbittorrent/fnos/ICON.PNG" width="28"> | [**qBittorrent**](apps/qbittorrent/) | `8085` | BitTorrent 客户端，默认账号 `admin/adminadmin` | [Release][r-qb] |
| <img src="apps/gopeed/fnos/ICON.PNG" width="28"> | [**Gopeed**](apps/gopeed/) | `9999` | 高速下载器，支持 HTTP/BT/Magnet | [Release][r-gopeed] |
| <img src="apps/syncthing/fnos/ICON.PNG" width="28"> | [**Syncthing**](apps/syncthing/) | `8384` | 文件同步工具，P2P 架构 | [Release][r-syncthing] |

### 📚 内容管理

| | App | 端口 | 说明 | 下载 |
|:---:|---|---:|---|:---:|
| <img src="apps/ani-rss/fnos/ICON.PNG" width="28"> | [**ANI-RSS**](apps/ani-rss/) | `7789` | 动漫 RSS 自动追番，默认账号 `admin/admin` | [Release][r-ani] |
| <img src="apps/audiobookshelf/fnos/ICON.PNG" width="28"> | [**Audiobookshelf**](apps/audiobookshelf/) | `13378` | 有声书和播客服务器 | [Release][r-abs] |
| <img src="apps/moviepilot/fnos/ICON.PNG" width="28"> | [**MoviePilot**](apps/moviepilot/) | `3000` | 影视自动化管理 | [Release][r-mp] |
| <img src="apps/openlist/fnos/ICON.PNG" width="28"> | [**OpenList**](apps/openlist/) | `5244` | 文件列表/WebDAV | [Release][r-openlist] |

### 🔧 系统工具

| | App | 端口 | 说明 | 下载 |
|:---:|---|---:|---|:---:|
| <img src="apps/sun-panel/fnos/ICON.PNG" width="28"> | [**Sun-Panel**](apps/sun-panel/) | `3002` | 服务器/NAS 导航面板 | [Release][r-sunpanel] |
| <img src="apps/certimate/fnos/ICON.PNG" width="28"> | [**Certimate**](apps/certimate/) | `8090` | SSL 证书管理 | [Release][r-certimate] |
| <img src="apps/vaultwarden/fnos/ICON.PNG" width="28"> | [**Vaultwarden**](apps/vaultwarden/) | `8880` | 密码管理（Bitwarden 兼容） | [Release][r-vw] |
| <img src="apps/nginx/fnos/ICON.PNG" width="28"> | [**Nginx**](apps/nginx/) | `8888` | HTTP 服务与反向代理 | [Release][r-nginx] |

## 反馈与请求

- 新应用请求：[Open App Request](https://github.com/conversun/fnos-apps/issues/new?template=new-app-request.yml)
- 问题反馈：[Open Bug Report](https://github.com/conversun/fnos-apps/issues/new?template=bug-report.yml)

## 快速开始

### 安装

1. 下载对应 App 的 [Release](https://github.com/conversun/fnos-apps/releases) 页面中的 `.fpk` 文件
2. 在 fnOS 应用中心选择「手动安装」
3. 上传 `.fpk` 并完成安装

### 本地构建

```bash
# 构建单个应用（以 plex 为例）
cd apps/plex && ./update_plex.sh

# 通用格式
cd apps/<app> && ./update_<app>.sh
```

构建产物统一输出到仓库根目录 `dist/`。

## 项目结构

```text
fnos-apps/
├── apps/                    # 各应用的 fnOS 包定义与构建脚本
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

## 致谢

- 应用图标来自 [Dashboard Icons](https://dashboardicons.com)（MIT License）

## 安全与透明

- 本仓库仅下载并重打包官方发布内容，不修改上游业务逻辑
- 当前应用均按非 root 用户运行（提升默认安全性）
- 构建脚本、CI 流程与发布记录均公开可审计

<!-- Release Links -->
[r-store]: https://github.com/conversun/fnos-apps/releases?q=fnos-apps-store
[r-plex]: https://github.com/conversun/fnos-apps/releases?q=plex
[r-emby]: https://github.com/conversun/fnos-apps/releases?q=emby
[r-jellyfin]: https://github.com/conversun/fnos-apps/releases?q=jellyfin
[r-navidrome]: https://github.com/conversun/fnos-apps/releases?q=navidrome
[r-kavita]: https://github.com/conversun/fnos-apps/releases?q=kavita
[r-tmm]: https://github.com/conversun/fnos-apps/releases?q=tinymediamanager
[r-qb]: https://github.com/conversun/fnos-apps/releases?q=qbittorrent
[r-gopeed]: https://github.com/conversun/fnos-apps/releases?q=gopeed
[r-syncthing]: https://github.com/conversun/fnos-apps/releases?q=syncthing
[r-ani]: https://github.com/conversun/fnos-apps/releases?q=ani-rss
[r-abs]: https://github.com/conversun/fnos-apps/releases?q=audiobookshelf
[r-mp]: https://github.com/conversun/fnos-apps/releases?q=moviepilot
[r-openlist]: https://github.com/conversun/fnos-apps/releases?q=openlist
[r-sunpanel]: https://github.com/conversun/fnos-apps/releases?q=sun-panel
[r-certimate]: https://github.com/conversun/fnos-apps/releases?q=certimate
[r-vw]: https://github.com/conversun/fnos-apps/releases?q=vaultwarden
[r-nginx]: https://github.com/conversun/fnos-apps/releases?q=nginx
