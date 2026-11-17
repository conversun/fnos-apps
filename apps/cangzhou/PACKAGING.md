# 藏舟

请求 #360。上游 0.4.10 起提供 ARM 包；本契约保留 x86 和 ARM 两种架构。
CI 使用 `scripts/apps/cangzhou/meta.env`，本地运行
`bash apps/cangzhou/update_cangzhou.sh --arch x86` 或 `--arch arm` 下载原始 FPK。

`fnos/` 仅用于元数据和 L1 检查，不用于重打包；图标来自官方 FPK。
目录中的端口为 0，避免把 fnOS 网关的 5666 当成藏舟独占端口而触发商店安装冲突预检。
实际包不声明 `service_port`，通过 Unix socket `app.sock` 和 `/app/cangzhou/` 网关访问，
需 fnOS 管理员身份与 fnOS ≥ 1.1.3100。

先授权源目录，准备可写本地目录或 WebDAV/SFTP 目标，使用至少 12 字节的仓库密码。
使用测试数据进行备份、快照浏览、在线及离线恢复；SFTP 需核对主机密钥。
升级前等待任务完成。远端仓库和密码需独立保存。

许可审计：0.4.11 仓库未提供项目级 LICENSE，GitHub license 字段为 null；
包内 `KOPIA-LICENSE` 仅适用于 Kopia，不能据此推定藏舟的许可。
本契约只指向官方原包；对外再分发前需确认作者授权。本次未发布安装包。
