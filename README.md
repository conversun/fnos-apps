# fnOS Apps

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
![Apps](https://img.shields.io/badge/apps-54-2ea44f)
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
| <img src="apps/koel/fnos/ICON.PNG" width="28"> | [**Koel**](apps/koel/) | `8060` | 个人音乐流媒体，默认账号 `admin@koel.dev/KoelIsCool` | [Release][r-koel] |
| <img src="apps/immich/fnos/ICON.PNG" width="28"> | [**Immich**](apps/immich/) | `2283` | 自托管照片/视频备份，支持人脸识别 | [Release][r-immich] |
| <img src="apps/kavita/fnos/ICON.PNG" width="28"> | [**Kavita**](apps/kavita/) | `5000` | 漫画/电子书阅读 | [Release][r-kavita] |
| <img src="apps/tinymediamanager/fnos/ICON.PNG" width="28"> | [**tinyMediaManager**](apps/tinymediamanager/) | `5800` | 影视元数据管理 | [Release][r-tmm] |
| <img src="apps/photoprism/fnos/ICON.PNG" width="28"> | [**PhotoPrism**](apps/photoprism/) | `2342` | AI 驱动的照片管理 | [Release][r-photoprism] |
| <img src="apps/jellyseerr/fnos/ICON.PNG" width="28"> | [**Jellyseerr**](apps/jellyseerr/) | `5055` | Jellyfin/Plex 媒体请求管理 | [Release][r-jellyseerr] |

### ⬇️ 下载工具

| | App | 端口 | 说明 | 下载 |
|:---:|---|---:|---|:---:|
| <img src="apps/qbittorrent/fnos/ICON.PNG" width="28"> | [**qBittorrent**](apps/qbittorrent/) | `8085` | BitTorrent 客户端，默认账号 `admin/adminadmin` | [Release][r-qb] |
| <img src="apps/transmission/fnos/ICON.PNG" width="28"> | [**Transmission**](apps/transmission/) | `9091` | 轻量级 BitTorrent 客户端 | [Release][r-transmission] |
| <img src="apps/gopeed/fnos/ICON.PNG" width="28"> | [**Gopeed**](apps/gopeed/) | `9999` | 高速下载器，支持 HTTP/BT/Magnet | [Release][r-gopeed] |
| <img src="apps/syncthing/fnos/ICON.PNG" width="28"> | [**Syncthing**](apps/syncthing/) | `8384` | 文件同步工具，P2P 架构 | [Release][r-syncthing] |

### 📚 内容管理

| | App | 端口 | 说明 | 下载 |
|:---:|---|---:|---|:---:|
| <img src="apps/ani-rss/fnos/ICON.PNG" width="28"> | [**ANI-RSS**](apps/ani-rss/) | `7789` | 动漫 RSS 自动追番，默认账号 `admin/admin` | [Release][r-ani] |
| <img src="apps/auto-bangumi/fnos/ICON.PNG" width="28"> | [**AutoBangumi**](apps/auto-bangumi/) | `7892` | RSS 自动追番下载整理，默认账号 `admin/adminadmin` | [Release][r-ab] |
| <img src="apps/audiobookshelf/fnos/ICON.PNG" width="28"> | [**Audiobookshelf**](apps/audiobookshelf/) | `13378` | 有声书和播客服务器 | [Release][r-abs] |
| <img src="apps/moviepilot/fnos/ICON.PNG" width="28"> | [**MoviePilot**](apps/moviepilot/) | `3000` | 影视自动化管理 | [Release][r-mp] |
| <img src="apps/openlist/fnos/ICON.PNG" width="28"> | [**OpenList**](apps/openlist/) | `5244` | 文件列表/WebDAV | [Release][r-openlist] |
| <img src="apps/kodbox/fnos/ICON.PNG" width="28"> | [**KodBox**](apps/kodbox/) | `8500` | 私有云存储/在线文档协作 | [Release][r-kodbox] |
| <img src="apps/chinesesubfinder/fnos/ICON.PNG" width="28"> | [**ChineseSubFinder**](apps/chinesesubfinder/) | `19035` | 中文字幕自动下载 | [Release][r-csf] |
| <img src="apps/freshrss/fnos/ICON.PNG" width="28"> | [**FreshRSS**](apps/freshrss/) | `8082` | 自托管 RSS 阅读器 | [Release][r-freshrss] |
| <img src="apps/miniflux/fnos/ICON.PNG" width="28"> | [**Miniflux**](apps/miniflux/) | `8084` | 极简 RSS 阅读器 | [Release][r-miniflux] |
| <img src="apps/linkwarden/fnos/ICON.PNG" width="28"> | [**Linkwarden**](apps/linkwarden/) | `3005` | 协作式书签管理 | [Release][r-linkwarden] |
| <img src="apps/wikijs/fnos/ICON.PNG" width="28"> | [**Wiki.js**](apps/wikijs/) | `3080` | 现代化 Wiki 引擎 | [Release][r-wikijs] |
| <img src="apps/mealie/fnos/ICON.PNG" width="28"> | [**Mealie**](apps/mealie/) | `9925` | 食谱管理与膳食计划 | [Release][r-mealie] |
| <img src="apps/paperless-ngx/fnos/ICON.PNG" width="28"> | [**Paperless-ngx**](apps/paperless-ngx/) | `8000` | 文档数字化管理，OCR 支持 | [Release][r-paperless] |

### 🎵 *arr 媒体自动化

| | App | 端口 | 说明 | 下载 |
|:---:|---|---:|---|:---:|
| <img src="apps/sonarr/fnos/ICON.PNG" width="28"> | [**Sonarr**](apps/sonarr/) | `8989` | 电视剧自动下载管理 | [Release][r-sonarr] |
| <img src="apps/radarr/fnos/ICON.PNG" width="28"> | [**Radarr**](apps/radarr/) | `7878` | 电影自动下载管理 | [Release][r-radarr] |
| <img src="apps/lidarr/fnos/ICON.PNG" width="28"> | [**Lidarr**](apps/lidarr/) | `8686` | 音乐自动下载管理 | [Release][r-lidarr] |
| <img src="apps/readarr/fnos/ICON.PNG" width="28"> | [**Readarr**](apps/readarr/) | `8787` | 电子书自动下载管理 | [Release][r-readarr] |
| <img src="apps/prowlarr/fnos/ICON.PNG" width="28"> | [**Prowlarr**](apps/prowlarr/) | `9696` | 索引器管理，整合 Sonarr/Radarr 等 | [Release][r-prowlarr] |
| <img src="apps/bazarr/fnos/ICON.PNG" width="28"> | [**Bazarr**](apps/bazarr/) | `6767` | 字幕自动下载管理 | [Release][r-bazarr] |

### 🔧 系统工具

| | App | 端口 | 说明 | 下载 |
|:---:|---|---:|---|:---:|
| <img src="apps/sun-panel/fnos/ICON.PNG" width="28"> | [**Sun-Panel**](apps/sun-panel/) | `3002` | 服务器/NAS 导航面板 | [Release][r-sunpanel] |
| <img src="apps/homepage/fnos/ICON.PNG" width="28"> | [**Homepage**](apps/homepage/) | `3003` | 高度可定制的应用仪表盘 | [Release][r-homepage] |
| <img src="apps/homarr/fnos/ICON.PNG" width="28"> | [**Homarr**](apps/homarr/) | `7575` | 服务器仪表盘与应用管理 | [Release][r-homarr] |
| <img src="apps/certimate/fnos/ICON.PNG" width="28"> | [**Certimate**](apps/certimate/) | `8090` | SSL 证书管理 | [Release][r-certimate] |
| <img src="apps/vaultwarden/fnos/ICON.PNG" width="28"> | [**Vaultwarden**](apps/vaultwarden/) | `8880` | 密码管理（Bitwarden 兼容） | [Release][r-vw] |
| <img src="apps/nginx/fnos/ICON.PNG" width="28"> | [**Nginx**](apps/nginx/) | `8888` | HTTP 服务与反向代理 | [Release][r-nginx] |
| <img src="apps/nginx-ui/fnos/ICON.PNG" width="28"> | [**Nginx UI**](apps/nginx-ui/) | `9000` | Nginx 可视化管理面板，内置 Nginx 引擎 | [Release][r-nginx-ui] |
| <img src="apps/gotify/fnos/ICON.PNG" width="28"> | [**Gotify**](apps/gotify/) | `8070` | 自托管推送通知服务 | [Release][r-gotify] |
| <img src="apps/ddns-go/fnos/ICON.PNG" width="28"> | [**DDNS-GO**](apps/ddns-go/) | `9876` | 动态 DNS 解析客户端 | [Release][r-ddnsgo] |
| <img src="apps/wolgoweb/fnos/ICON.PNG" width="28"> | [**WolGoWeb**](apps/wolgoweb/) | `9090` | 网络唤醒 (Wake-on-LAN) 管理 | [Release][r-wolgoweb] |
| <img src="apps/adguardhome/fnos/ICON.PNG" width="28"> | [**AdGuardHome**](apps/adguardhome/) | `3080` | 全网广告拦截与 DNS 管理 | [Release][r-adguardhome] |
| <img src="apps/uptime-kuma/fnos/ICON.PNG" width="28"> | [**Uptime Kuma**](apps/uptime-kuma/) | `3001` | 自托管服务监控 | [Release][r-uptimekuma] |
| <img src="apps/beszel/fnos/ICON.PNG" width="28"> | [**Beszel**](apps/beszel/) | `18090` | 轻量级服务器监控 | [Release][r-beszel] |
| <img src="apps/filebrowser/fnos/ICON.PNG" width="28"> | [**FileBrowser**](apps/filebrowser/) | `8089` | Web 文件管理器 | [Release][r-filebrowser] |
| <img src="apps/stirling-pdf/fnos/ICON.PNG" width="28"> | [**Stirling-PDF**](apps/stirling-pdf/) | `18080` | 自托管 PDF 工具箱 | [Release][r-stirlingpdf] |
| <img src="apps/actual-budget/fnos/ICON.PNG" width="28"> | [**Actual Budget**](apps/actual-budget/) | `5006` | 自托管个人财务管理 | [Release][r-actual] |
| <img src="apps/lucky/fnos/ICON.PNG" width="28"> | [**Lucky**](apps/lucky/) | `16601` | DDNS/反向代理/端口转发多功能工具 | [Release][r-lucky] |

### 🌐 网络工具

| | App | 端口 | 说明 | 下载 |
|:---:|---|---:|---|:---:|
| <img src="apps/smartdns/fnos/ICON.PNG" width="28"> | [**SmartDNS**](apps/smartdns/) | `6580` | 本地 DNS 加速与优选 | [Release][r-smartdns] |
| <img src="apps/mosdns/fnos/ICON.PNG" width="28"> | [**MosDNS**](apps/mosdns/) | `5353` | DNS 转发与分流 | [Release][r-mosdns] |

### 🌐 浏览器

| | App | 端口 | 说明 | 下载 |
|:---:|---|---:|---|:---:|
| <img src="apps/firefox/fnos/ICON.PNG" width="28"> | [**Firefox**](apps/firefox/) | `5801` | 远程浏览器，支持中文 | [Release][r-firefox] |
| <img src="apps/chromium/fnos/ICON.PNG" width="28"> | [**Chromium**](apps/chromium/) | `5802` | 远程浏览器，支持中文 | [Release][r-chromium] |

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
3. CI 自动发现新应用，无需手动创建 workflow 文件

## CI/CD 设计

- 单一入口 `build-apps.yml` 自动发现 `apps/` 下所有应用，动态矩阵构建
- 统一使用 `scripts/build-fpk.sh` 打包，减少各应用行为漂移
- 统一使用 `reusable-build-app.yml` 实现版本检查、矩阵构建、发布
- 标签策略由 `scripts/ci/resolve-release-tag.sh` 管理，支持 `-r2/-r3` 修订版自动递增
- 日常构建由定时任务和手动触发驱动，push 触发仅构建变更的应用

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
[r-transmission]: https://github.com/conversun/fnos-apps/releases?q=transmission
[r-gopeed]: https://github.com/conversun/fnos-apps/releases?q=gopeed
[r-syncthing]: https://github.com/conversun/fnos-apps/releases?q=syncthing
[r-ani]: https://github.com/conversun/fnos-apps/releases?q=ani-rss
[r-abs]: https://github.com/conversun/fnos-apps/releases?q=audiobookshelf
[r-mp]: https://github.com/conversun/fnos-apps/releases?q=moviepilot
[r-openlist]: https://github.com/conversun/fnos-apps/releases?q=openlist
[r-kodbox]: https://github.com/conversun/fnos-apps/releases?q=kodbox
[r-sunpanel]: https://github.com/conversun/fnos-apps/releases?q=sun-panel
[r-certimate]: https://github.com/conversun/fnos-apps/releases?q=certimate
[r-vw]: https://github.com/conversun/fnos-apps/releases?q=vaultwarden
[r-nginx]: https://github.com/conversun/fnos-apps/releases?q=nginx
[r-nginx-ui]: https://github.com/conversun/fnos-apps/releases?q=nginx-ui
[r-gotify]: https://github.com/conversun/fnos-apps/releases?q=gotify
[r-ddnsgo]: https://github.com/conversun/fnos-apps/releases?q=ddns-go
[r-wolgoweb]: https://github.com/conversun/fnos-apps/releases?q=wolgoweb
[r-adguardhome]: https://github.com/conversun/fnos-apps/releases?q=adguardhome
[r-firefox]: https://github.com/conversun/fnos-apps/releases?q=firefox
[r-chromium]: https://github.com/conversun/fnos-apps/releases?q=chromium
[r-ab]: https://github.com/conversun/fnos-apps/releases?q=auto-bangumi
[r-immich]: https://github.com/conversun/fnos-apps/releases?q=immich
[r-koel]: https://github.com/conversun/fnos-apps/releases?q=koel
[r-photoprism]: https://github.com/conversun/fnos-apps/releases?q=photoprism
[r-jellyseerr]: https://github.com/conversun/fnos-apps/releases?q=jellyseerr
[r-csf]: https://github.com/conversun/fnos-apps/releases?q=chinesesubfinder
[r-freshrss]: https://github.com/conversun/fnos-apps/releases?q=freshrss
[r-miniflux]: https://github.com/conversun/fnos-apps/releases?q=miniflux
[r-linkwarden]: https://github.com/conversun/fnos-apps/releases?q=linkwarden
[r-wikijs]: https://github.com/conversun/fnos-apps/releases?q=wikijs
[r-mealie]: https://github.com/conversun/fnos-apps/releases?q=mealie
[r-paperless]: https://github.com/conversun/fnos-apps/releases?q=paperless-ngx
[r-sonarr]: https://github.com/conversun/fnos-apps/releases?q=sonarr
[r-radarr]: https://github.com/conversun/fnos-apps/releases?q=radarr
[r-lidarr]: https://github.com/conversun/fnos-apps/releases?q=lidarr
[r-readarr]: https://github.com/conversun/fnos-apps/releases?q=readarr
[r-prowlarr]: https://github.com/conversun/fnos-apps/releases?q=prowlarr
[r-bazarr]: https://github.com/conversun/fnos-apps/releases?q=bazarr
[r-homepage]: https://github.com/conversun/fnos-apps/releases?q=homepage
[r-homarr]: https://github.com/conversun/fnos-apps/releases?q=homarr
[r-uptimekuma]: https://github.com/conversun/fnos-apps/releases?q=uptime-kuma
[r-beszel]: https://github.com/conversun/fnos-apps/releases?q=beszel
[r-filebrowser]: https://github.com/conversun/fnos-apps/releases?q=filebrowser
[r-stirlingpdf]: https://github.com/conversun/fnos-apps/releases?q=stirling-pdf
[r-actual]: https://github.com/conversun/fnos-apps/releases?q=actual-budget
[r-lucky]: https://github.com/conversun/fnos-apps/releases?q=lucky
[r-smartdns]: https://github.com/conversun/fnos-apps/releases?q=smartdns
[r-mosdns]: https://github.com/conversun/fnos-apps/releases?q=mosdns
