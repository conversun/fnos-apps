# Immich for fnOS

每日自动同步 [Immich 官方](https://immich.app/) 最新版本并构建 `.fpk` 安装包。

## 下载

从 [Releases](https://github.com/conversun/fnos-apps/releases?q=immich) 下载最新的 `.fpk` 文件。

## 安装

1. 根据设备架构下载对应的 `.fpk` 文件
2. fnOS 应用管理 → 手动安装 → 上传

**访问地址**: `http://<NAS-IP>:2283`

## 说明

- Immich 是自托管的照片和视频备份方案，类似 Google Photos
- 支持人脸识别、智能搜索、时间线浏览
- 支持 iOS/Android 客户端自动备份
- 支持 Intel QuickSync 硬件加速转码
- 包含 4 个服务容器: Web 服务、机器学习、PostgreSQL、Redis
- 首次启动需要拉取镜像，耗时较长

## 本地构建

```bash
cd apps/immich && bash ../../scripts/build-fpk.sh . app.tgz
```

## 版本标签

- `immich/v2.5.6` — 首次发布
- `immich/v2.5.6-r2` — 同版本打包修订

## Credits

- [Immich](https://immich.app/) - Self-hosted photo and video management solution
