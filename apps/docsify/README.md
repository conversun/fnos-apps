# Docsify for fnOS

Docsify 是一个轻量级 Markdown 文档站点生成器。此 fnOS 包使用多架构 `nginxinc/nginx-unprivileged` 容器提供静态文件服务，并在首次安装时初始化可直接访问的 Docsify 示例站点。

- 默认端口：4001
- 文档目录：应用数据目录下的 `docs/`
- 容器镜像：`nginxinc/nginx-unprivileged`（支持 linux/amd64 与 linux/arm64）

## Local Build

```bash
cd apps/docsify && ./update_docsify.sh
```
