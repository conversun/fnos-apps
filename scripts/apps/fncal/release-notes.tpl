FnCal 官方 fnOS 安装包直通发布

- 直接采用 [PaulCAI1593/FnCal](https://github.com/PaulCAI1593/FnCal) 的官方 FPK，字节一致，保留上游向导、账号与生命周期。
- 上游通用包 platform=all，同一文件用于 x86 与 ARM，应用标识为 FnCal。
- 要求 fnOS ≥ 1.2.0401，依赖 nodejs_v22；默认 HTTP 端口 ${DEFAULT_PORT}，安装向导可调整，HTTPS 默认 5243。
- 提供多视图日历、CalDAV 同步与 MCP 接入，AI 写入默认先提案再由用户审批。
- 安装向导需设置管理员账号、密码与端口。0.8.0 以前的版本需按上游说明保留资料卸载后重装。
- MIT 许可。0.8.34 通用包内 canvas 原生模块仅含 x86-64，ARM 的 MCP 年度总结服务端 PNG 渲染会退回 SVG，需上游补齐并实机验证。

${CHANGELOG}

**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
