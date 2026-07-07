# VibeNVR for fnOS

每日自动同步 [VibeNVR](https://github.com/spupuz/VibeNVR) 最新版本并构建 `.fpk` 安装包。

VibeNVR 是一套 AI 网络视频录像机（NVR），用于摄像头接入、录像、回放和视频处理。本 fnOS 包按上游生产 compose 部署 4 个容器：frontend、backend、engine 和 PostgreSQL。

## 下载

从 [Releases](https://github.com/conversun/fnos-apps/releases?q=vibenvr) 下载最新的 `.fpk` 文件。

## 安装

1. 下载 `vibenvr_<version>_x86.fpk`
2. fnOS 应用管理 → 手动安装 → 上传
3. 根据向导设置 PostgreSQL 密码、后端密钥和 Webhook 密钥

**访问地址**: `http://<NAS-IP>:8087`

## 重要说明

- **仅支持 x86 (amd64)**：VibeNVR 上游 Docker 镜像当前仅发布 amd64 架构，本应用不会构建 arm64 包。
- **默认端口 8087**：只发布 frontend Web UI；backend、engine、db 仅在 Docker 内部网络通信，避免和 Open WebUI 的 8080 冲突。
- **硬件加速**：engine 容器按上游配置使用 `privileged: true` 并挂载 `/dev/dri`，用于 Intel/AMD VAAPI。请确保 NAS 硬件与系统已暴露 `/dev/dri`。
- **数据持久化**：录像、日志和数据库均存储在 fnOS 应用数据目录 `${TRIM_PKGVAR}` 的子目录中。

## Local Build

```bash
cd fnos-apps/apps/vibenvr
./update_vibenvr.sh --arch x86
```

## Credits

- [VibeNVR](https://github.com/spupuz/VibeNVR)
- 图标来自 [Dashboard Icons](https://dashboardicons.com/)
