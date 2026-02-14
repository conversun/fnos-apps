# Plex Media Server for fnOS

每日自动同步 [Plex 官方下载](https://www.plex.tv/media-server-downloads/) 最新版本并构建 `.fpk` 安装包。

## 下载

从 [Releases](https://github.com/conversun/fnos-apps/releases?q=plex) 下载最新的 `.fpk` 文件。

## 安装

1. 根据设备架构下载对应的 `.fpk` 文件
2. fnOS 应用管理 → 手动安装 → 上传

**访问地址**: `http://<NAS-IP>:32400/web`

## 添加媒体库

在 fnOS 中为 Plex 授予共享文件夹权限后，Plex 添加媒体库时**无法通过浏览按钮找到文件夹**。这是因为 fnOS 的卷目录（`/vol1`、`/vol2` 等）仅允许 root 访问，Plex 进程无法逐级浏览目录树。

**解决方法**：添加媒体库时，不要点击「浏览文件夹」，而是**手动输入完整路径**，例如：

```
/vol2/1000/Download_Temp
```

> 共享文件夹的完整路径格式为 `/vol{N}/{uid}/{共享文件夹名}`，其中 `{uid}` 为创建共享文件夹的用户 ID 目录（通常为 `1000`）。可通过 SSH 执行 `find /vol* -maxdepth 2 -name "你的文件夹名"` 查找。

## 本地构建

```bash
./update_plex.sh                          # 最新版本，自动检测架构
./update_plex.sh --arch arm               # 指定架构
./update_plex.sh --arch arm 1.42.2.10156  # 指定版本
./update_plex.sh --help                   # 查看帮助
```

## 版本标签

- `plex/v1.42.2.10156` — 首次发布
- `plex/v1.42.2.10156-r2` — 同版本打包修订

## Credits

- [Plex](https://www.plex.tv/) - Media Server
