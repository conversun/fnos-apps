# Aellus (fnOS)

轻量局域网文件互传服务：手机 / 电脑浏览器访问 NAS 地址即可上传、浏览与下载文件。
上游：<https://github.com/YGQ8988/Aellus>（Go 单文件二进制，前端资源编译进二进制）。

- 打包模式：native（上游静态 ELF，双架构 x86_64 / arm64）
- 默认端口：8000
- 环境变量：`AELLUS_PORT`（跟随 manifest service_port）、`AELLUS_STRICT_PORT=1`、`AELLUS_HEADLESS=1`
- 授权目录：`config/resource` 声明 `api-scope: trim.file.sharedAccess / trim.file.path`，与上游飞牛适配一致
