# Nginx UI for fnOS

每日自动同步 [Nginx UI](https://github.com/0xJacky/nginx-ui) 最新版本并构建 `.fpk` 安装包。

## 下载

从 [Releases](https://github.com/conversun/fnos-apps/releases?q=nginx-ui) 下载最新的 `.fpk` 文件。

## 前置要求

⚠️ **必须先安装 [Nginx](../nginx/) 应用**，Nginx UI 作为管理面板对接已安装的 Nginx 服务。

## 安装

1. 确认已安装并启动过 Nginx 应用
2. 根据设备架构下载对应的 `.fpk` 文件
3. fnOS 应用管理 → 手动安装 → 上传

**访问地址**: `http://<NAS-IP>:9000`

## 说明

- 可视化管理面板，对接已安装的 Nginx 应用
- 支持在线编辑 Nginx 配置并一键 Reload，无需 SSH
- 支持 Let's Encrypt SSL 证书自动申请与续签
- 支持反向代理、负载均衡等常用配置的可视化管理
- 首次访问需注册管理员账号
- 与 Nginx 应用共用同一个系统用户 (`nginxserver`)

## 端口说明

| 端口 | 用途 |
|------|------|
| 9000 | Nginx UI 管理面板 |

> Nginx HTTP 服务端口由 Nginx 应用管理（默认 8888）。

## 本地构建

```bash
./update_nginx-ui.sh                     # 最新版本，自动检测架构
./update_nginx-ui.sh --arch arm          # 指定架构
./update_nginx-ui.sh --help              # 查看帮助
```

## 版本标签

- `nginx-ui/v2.3.3` — 首次发布
- `nginx-ui/v2.3.3-r2` — 同版本打包修订

## Credits

- [Nginx UI](https://github.com/0xJacky/nginx-ui) - Yet another WebUI for Nginx
- [Nginx](https://nginx.org/) - HTTP and reverse proxy server
