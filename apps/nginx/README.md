# Nginx for fnOS

每日自动同步 [Nginx 官方](https://nginx.org/) 最新稳定版并构建 `.fpk` 安装包。

## 下载

从 [Releases](https://github.com/conversun/fnos-apps/releases?q=nginx) 下载最新的 `.fpk` 文件。

## 安装

1. 根据设备架构下载对应的 `.fpk` 文件
2. fnOS 应用管理 → 手动安装 → 上传

**访问地址**: `http://<NAS-IP>:8888`

## 说明

- 首次启动会在数据目录自动生成默认 `nginx.conf`
- 配置文件位于 `var/nginx.conf`，修改后重启服务生效
- 默认网站根目录 `var/html/`
- 日志目录 `var/logs/`

## 本地构建

```bash
./update_nginx.sh                     # 最新版本，自动检测架构
./update_nginx.sh --arch arm          # 指定架构
./update_nginx.sh --arch arm 1.28.2   # 指定版本
./update_nginx.sh --help              # 查看帮助
```

## 版本标签

- `nginx/v1.28.2` — 首次发布
- `nginx/v1.28.2-r2` — 同版本打包修订

## Credits

- [Nginx](https://nginx.org/) - HTTP and reverse proxy server
