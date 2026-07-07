# Feigram

Feigram 是第三方开发的非官方 Telegram Web 客户端，面向 fnOS 打包为原生 `.fpk`：内置 Node.js 运行时、Express 服务端和 React 前端，不依赖 Docker。

## 说明

- 默认端口：`3088`
- 上游仓库：<https://github.com/g-star1024/Feigram-Public>
- 本包会按架构分别捆绑 Node.js `linux-x64` 或 `linux-arm64` 运行时，支持 x86 与 ARM fnOS 设备。
- Feigram 不隶属于 Telegram、Telegram Messenger Inc. 或飞牛官方。

## Telegram API 凭据

安装向导支持填写自己的 Telegram `api_id` 与 `api_hash`。建议用户前往 <https://my.telegram.org> 注册应用并使用自己的凭据；留空时会沿用上游公开构建的默认配置，后续也可在 Feigram 管理后台覆盖。
