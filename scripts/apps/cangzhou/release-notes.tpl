藏舟官方 fnOS 安装包直通发布

- 直接采用 [KnotDing/cangzhou](https://github.com/KnotDing/cangzhou) 的官方 FPK，字节一致，保留应用用户、目录授权检查与网关认证。
- 支持 x86 和 ARM（上游自 0.4.10 提供 ARM 包），要求 fnOS ≥ 1.1.3100。
- 通过 fnOS 桌面 /app/cangzhou/ 打开，需要管理员身份；应用不单独监听 TCP 端口。
- 基于 Kopia 进行本地、WebDAV 或 SFTP 加密备份，支持计划任务、历史快照与文件恢复。
- 使用前授权源目录，准备可写目标仓库，并独立保存至少 12 字节的仓库密码；升级前等待任务结束。

${CHANGELOG}

**国内镜像**:
- [${FILE_PREFIX}_${FPK_VERSION}_x86.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_x86.fpk)
- [${FILE_PREFIX}_${FPK_VERSION}_arm.fpk](https://ghfast.top/https://github.com/conversun/fnos-apps/releases/download/${RELEASE_TAG}/${FILE_PREFIX}_${FPK_VERSION}_arm.fpk)
