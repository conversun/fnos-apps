## 2026-07-07

- 【修复】Docker 镜像拉取失败 `manifest unknown` (issue #175)
  - 上游 ghcr.io/immich-app 镜像标签保留前缀 `v`（如 `v3.0.1`），旧脚本 `sed 's/^v//'` 剥离后得到 `3.0.1`，该标签在 ghcr.io 不存在，导致安装报 `manifest unknown`
  - docker-compose 改为固定跟踪滚动 `:release` 标签（immich 官方推荐），server 与 machine-learning 均已修正
  - get-latest-version.sh 版本号改为日期戳格式；安装向导补充 ghcr.io 镜像加速器不生效的说明

## 2026-02-27

- 首次发布
